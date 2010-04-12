//
//  CGIParameters.m
//  Zen
//
//  Created by Williham Totland on 02.04.09.
//  Copyright 2009 Totland Software. All rights reserved.
//

#import "CGIKit/CGIParameters.h"
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIArray.h"
#include <stdlib.h>
#include <stdio.h>
#include <objc/objc-api.h>
#include <unistd.h>
#include <string.h>

@interface CGIParameters (CGIParametersPrivate)
- (void)_parseGetQuery:(CGIString *)queryString;
- (void)_parsePostQuery;
- (void)_parseCookie;
- (void)_parseEnvironment;
@end

@implementation CGIParameters

- (id) init {
  self = [super init];
  if (self != nil) {
    // dictionary for query key value pairs
    params = [[CGIMutableDictionary alloc] init];
/*    const unichar *request_method = getenv("REQUEST_METHOD");
    if (!request_method) return self;
    CGIString *reqM = [[[CGIString alloc] initWithUTF8String:request_method] autorelease];
    if ([reqM isEqualToString: @"GET"]) {*/
    const unichar *query_string = getenv("QUERY_STRING");
    if (query_string)
      [self _parseGetQuery: [[[CGIString alloc] initWithUTF8String:query_string] autorelease]];
/*    } else if ([reqM isEqualToString: @"POST"])*/
    [self _parsePostQuery];
    [self _parseCookie];
    server = [[CGIMutableDictionary alloc] init];
    [self _parseEnvironment];
/*    else
    {
      @throw @"CGIUnrecognizedRequestMethodException";
      return nil;
    }*/
  }
  return self;
}

- (void)dealloc {
  [params release];
  [server release];
  [super dealloc];
}

- (CGIString *)parameterForKey: (CGIString *)key {
  return [params objectForKey: key];
}

- (CGIDictionary *) parameters {
  return params;
}

- (void) _parseGetQuery:(CGIString *)queryString {
  
  if ([queryString length] == 0)
    return;

  CGIArray *pairs = [queryString componentsSeparatedByString: @"&"];

  CGIUInteger i;  
  for (i = 0; i < [pairs count]; i++) {
    CGIArray *elem = [[pairs objectAtIndex: i] componentsSeparatedByString: @"="];
    if ([[elem objectAtIndex:0] hasSuffix:@"[]"]) {
      CGIString *realKey = [[elem objectAtIndex: 0] stringByRemovingSuffix:@"[]"];
      CGIMutableArray *keys;
      if (keys = [params objectForKey:realKey]) {
        [keys addObject:[[elem objectAtIndex: 1] URLDecodedString]];
      } else {
        [params setObject:[[CGIMutableArray alloc] initWithObject:[[elem objectAtIndex: 1] URLDecodedString]] forKey:realKey];
      }
    } else
      [params setObject:[[elem objectAtIndex: 1] URLDecodedString] forKey:[elem objectAtIndex: 0]];
  }
}

- (void) _parsePostQuery {
  const unichar *content_length = getenv("CONTENT_LENGTH");
  if (!content_length) return;
  CGIUInteger len = atol(content_length);
  if (len == 0) return;
  unichar *buf = objc_malloc(len);
  fread(buf, len, 1, stdin);
  [self _parseGetQuery:[[[CGIString alloc] initWithUTF8String:buf length:len] autorelease]];
}

- (void)_parseCookie {
  const unichar *cookie = getenv("HTTP_COOKIE");
  if (!cookie || !strlen(cookie)) return;
  
  CGIArray *pairs = [[[[CGIString alloc] initWithUTF8String:cookie] autorelease] componentsSeparatedByString: @"; "];
  CGIUInteger i;  
  for (i = 0; i < [pairs count]; i++) {
    CGIArray *elem = [[pairs objectAtIndex: i] componentsSeparatedByString: @"="];
    if ([[elem objectAtIndex:0] hasSuffix:@"[]"]) {
      CGIString *realKey = [[elem objectAtIndex: 0] stringByRemovingSuffix:@"[]"];
      CGIMutableArray *keys;
      if (keys = [params objectForKey:realKey]) {
        [keys addObject:[[elem objectAtIndex: 1] URLDecodedString]];
      } else {
        [params setObject:[[CGIMutableArray alloc] initWithObject:[[elem objectAtIndex: 1] URLDecodedString]] forKey:realKey];
      }
    } else
      [params setObject:[[elem objectAtIndex: 1] URLDecodedString] forKey:[elem objectAtIndex: 0]];
  }
}

- (void)_parseEnvironment {
  extern const char **environ;
  const char **env = environ;
  while (*env) {
    CGIUInteger nameLength = (strchr(*env, '=') - *env);
    if ((nameLength + 1) == strlen(*env)) {env++; continue;}
    CGIString *name = [[[CGIString alloc] initWithUTF8String:*env length:nameLength] autorelease];
    CGIString *value = [[[CGIString alloc] initWithUTF8String:&((*env)[nameLength + 1])] autorelease];
    [server setObject:value forKey:name];
    env++;
  }  
}

- (CGIDictionary*)server {
  return server;
}

@end
