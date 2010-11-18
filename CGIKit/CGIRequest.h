/* CGIRequest.h */
/* Copyright 2010 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

@class CGIDictionary;
@class CGIString;

@interface CGIRequest : CGIObject {
  CGIString *path;

  CGIDictionary *parameters;
  CGIDictionary *environment;

  CGIString *contentType;
  CGIString *messageBody;
}

+ (id)requestWithPath:(CGIString *)pa parameters:(CGIDictionary *)p environment:(CGIDictionary *)env;

- (CGIString *)path;

- (CGIDictionary *)parameters;
- (CGIDictionary *)environment;

- (void)setMessageBody:(CGIString *)body withType:(CGIString *)type;

- (CGIString *)messageBody;
- (CGIString *)contentType;

@end
