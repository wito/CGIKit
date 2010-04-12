/* CGICoder.h */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

@interface CGICoder : CGIObject {

}

@end

@protocol CGICoding

- (id)initWithCoder:(CGICoder *)coder;
- (void)encodeWithCoder:(CGICoder *)coder;

@end
