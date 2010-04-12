/* CGIRequest.h */
/* Copyright 2010 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

@class CGIDictionary;

@interface CGIRequest : CGIObject {
  CGIString *path;

  CGIDictionary *parameters;
  CGIDictionary *environment;
}

+ (id)requestWithPath:(CGIString *)pa parameters:(CGIDictionary *)p environment:(CGIDictionary *)env;

- (CGIString *)path;

- (CGIDictionary *)parameters;
- (CGIDictionary *)environment;

@end
