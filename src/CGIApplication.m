/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import <stdlib.h>
#import <fcgiapp.h>
#import <stdio.h>

#import "CGIKit/CGIApplication.h"
#import "CGIKit/CGIString.h"

#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIAutoreleasePool.h"
#import "CGIKit/CGIRequest.h"

id CGIApp = nil;

int CGIApplicationMain (int argc, const char **argv, const char **envp, CGIString *applicationName) {

  id pool = [[CGIAutoreleasePool alloc] init];
  
  CGIApplication *application = [[CGIApplication alloc] initWithArguments:argv count:argc environment:envp];
  
  CGIString *applicationPath = [[CGIString alloc] initWithFormat:@"/usr/local/share/%@.app/Contents/", applicationName];
  
  CGIString *infoPlistPath = [applicationPath stringByAppendingString:@"Info.plist"];
  
  CGIString *infoPlistData = [[CGIString alloc] initWithContentsOfFile:infoPlistPath];
  
  id infoPlist = CGIReadPropertyList(infoPlistData);
  
  [application setDelegate:[[objc_get_class([[infoPlist objectForKey:@"CGIKitApplicationDelegateClass"] UTF8String]) alloc] init]];
  
  //printf("%@\n", infoPlist);
  

  [application run];
  
  [pool drain];

  return 0;
}

@implementation CGIApplication

- (id)init {
  self = [super init];
  if (self != nil) {
    if (CGIApp)
      @throw @"CGIInternalInconsistencyError";
    else
      CGIApp = self;
  }
  return self;
}

- (id)initWithArguments:(const char **)argv count:(int)argc environment:(const char **)envp {
  self = [self init];
  if (self != nil) {
    arguments = [[CGIMutableArray alloc] init];
    
    int i;
    for (i = 0; i < argc; i++) {
      [(CGIMutableArray *)arguments addObject:[CGIString stringWithUTF8String:argv[i]]];
    }

    environment = [[CGIMutableDictionary alloc] initWithCapacity:16];
    
    const char **env = envp;
    while (env = env++, *env) {
      CGIString *pairString = [CGIString stringWithUTF8String:*env];
      CGIArray *pair = [pairString componentsSeparatedByString:@"="];
         
      [environment setObject:[pairString substringFromIndex:[[pair objectAtIndex:0] length] + 1] forKey:[pair objectAtIndex:0]];
    }
  }
  return self;
}

- (id <CGIApplicationDelegate>)delegate {
  if (!delegate) @throw @"CGIInternalInconsistencyError";
  return delegate;
}
- (void)setDelegate:(id <CGIApplicationDelegate>)anObject {
  delegate = anObject;
}

+ (id)sharedApplication {
  return CGIApp;
}

- (void)run {
  int fd, error;
  FCGX_Init();

  fd = FCGX_OpenSocket(":14000", 50);
  FCGX_Request req;
  error = FCGX_InitRequest(&req, fd, 0);
  
  while ((error = FCGX_Accept_r(&req)) >= 0) {
  
    CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
    
    @try {

    CGIMutableDictionary *requestEnvironment = [[[CGIMutableDictionary alloc] initWithCapacity:32] autorelease];
  
    char **env = req.envp;
    while (env = env++, *env) {
      CGIString *pairString = [CGIString stringWithUTF8String:*env];
      CGIArray *pair = [pairString componentsSeparatedByString:@"="];
      
      if ([pair count] > 2) {   
        [requestEnvironment setObject:[pairString substringFromIndex:[[pair objectAtIndex:0] length] + 1] forKey:[pair objectAtIndex:0]];
      } else if ([pair count] == 2) {
        [requestEnvironment setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
      } else {
        [requestEnvironment setObject:@"" forKey:[pair objectAtIndex:0]];
      }
    }
    
    CGIString *contentLength = [requestEnvironment objectForKey:@"CONTENT_LENGTH"];
    CGIString *method = [requestEnvironment objectForKey:@"REQUEST_METHOD"];
    
    int len = 0;
    CGIString *path = [requestEnvironment objectForKey:@"REQUEST_URI"];
    
    if (contentLength != nil)
      len = strtol([contentLength UTF8String], NULL, 10);
    
    //printf("%@ %@\nContent-Length: %d\n", method, path, len);
    //printf("%@\n\n", requestEnvironment);
    
    // Parameter parsing
    
    CGIString *queryString = [requestEnvironment objectForKey:@"QUERY_STRING"];
    CGIMutableDictionary *requestParameters = [[[CGIMutableDictionary alloc] initWithCapacity:16] autorelease];

    if (queryString && [queryString length]) {
      CGIArray *queryParts = [queryString componentsSeparatedByString:@"&"];
      int i;
      for (i = 0; i < [queryParts count]; i++) {
        CGIArray *pair = [[queryParts objectAtIndex:i] componentsSeparatedByString:@"="];
        if ([pair count] == 1) {
          [requestParameters setObject:@"1" forKey:[[pair objectAtIndex:0] URLDecodedString]];
        } else {
          [requestParameters setObject:[[pair objectAtIndex:1] URLDecodedString] forKey:[[pair objectAtIndex:0] URLDecodedString]];
        }
      }
    }
    
        
    if ([method isEqualToString:@"POST"] && len != 0) {
      CGIString *dataString = nil;
      char *data = malloc(len);
      FCGX_GetStr(data, len, req.in);
      
      dataString = [CGIString stringWithUTF8String:data length:len];
      free(data);
      
      if ([[requestEnvironment objectForKey:@"CONTENT_TYPE"] isEqualToString:@"application/x-www-form-urlencoded"]) {
        if (queryString && [queryString length]) {
          CGIArray *queryParts = [dataString componentsSeparatedByString:@"&"];
          int i;
          for (i = 0; i < [queryParts count]; i++) {
            CGIArray *pair = [[queryParts objectAtIndex:i] componentsSeparatedByString:@"="];
            if ([pair count] == 1) {
              [requestParameters setObject:@"1" forKey:[[pair objectAtIndex:0] URLDecodedString]];
            } else {
              [requestParameters setObject:[[pair objectAtIndex:1] URLDecodedString] forKey:[[pair objectAtIndex:0] URLDecodedString]];
            }
          }
        }
      } else {
        @throw @"CGINotImplementedException";
      }
      
    }
    
    //printf("%@\n", requestParameters);
    
    // Parameter parsing done
    
    CGIRequest *request = [CGIRequest requestWithPath:path parameters:requestParameters environment:requestEnvironment];
    
    FCGX_FPrintF(req.out,
      "Content-type: application/xml; charset=UTF-8\r\n\r\n<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n%s",
      [[[self delegate] applicationDidReceiveRequest:request] UTF8String]
    );
    
    }
    @catch (CGIString *e) {
      printf("%@\n", e);
    }
    
    [pool release];
  }

}

- (void)dealloc {
  [arguments release];
  [environment release];
  
  [super dealloc];
}

@end
