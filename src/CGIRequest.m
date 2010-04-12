/* CGIRequest.m */
/* Copyright 2010 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGIRequest.h"

@implementation CGIRequest

+ (id)requestWithPath:(CGIString *)pa parameters:(CGIDictionary *)p environment:(CGIDictionary *)env {
  CGIRequest *retval = [[CGIRequest alloc] init];
  
  retval->path = [pa retain];
  retval->parameters = [p retain];
  retval->environment = [env retain];
  
  return [retval autorelease];
}

- (CGIString *)path {
  return path;
}

- (CGIDictionary *)parameters {
  return parameters;
}

- (CGIDictionary *)environment {
  return environment;
}

- (void)dealloc {
  [path release];

  [parameters release];
  [environment release];
  
  [super dealloc];
}


@end
