//
//  CGIParameters.h
//  Zen
//
//  Created by Williham Totland on 02.04.09.
//  Copyright 2009 Totland Software. All rights reserved.
//

#import "CGIObject.h"

@class CGIString;
@class CGIDictionary;

@interface CGIParameters : CGIObject {
  CGIDictionary *params;
  CGIDictionary *server;
}

- (CGIString *)parameterForKey:(CGIString *)key;
- (CGIDictionary *)parameters;
- (CGIDictionary *)server;

@end
