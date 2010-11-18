/* CGIRequest.m */
/* Copyright 2010 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGIRequest.h"
#import "CGIKit/CGIString.h"

@implementation CGIRequest

+ (id)requestWithPath:(CGIString *)pa parameters:(CGIDictionary *)p environment:(CGIDictionary *)env {
  CGIRequest *retval = [[CGIRequest alloc] init];
  
  retval->path = [pa retain];
  retval->parameters = [p retain];
  retval->environment = [env retain];
  
  return [retval autorelease];
}

- (void)setMessageBody:(CGIString *)body withType:(CGIString *)type {
  [contentType release];
  [messageBody release];

  contentType = [type copy];
  messageBody = [body copy];
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

- (CGIString *)messageBody {
  return messageBody;
}

- (CGIString *)contentType {
  return contentType;
}

- (void)dealloc {
  [path release];

  [parameters release];
  [environment release];
  
  [self setMessageBody:nil withType:nil];

  [super dealloc];
}


@end
