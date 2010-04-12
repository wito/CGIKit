/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

@class CGIArray;

@interface CGISet : CGIObject

- (CGIUInteger)count;
- (CGIArray *)allObjects;
- (id)anyObject;
- (id)member:(id)anObject;
- (BOOL)containsObject:(id)anObject;

@end

@interface CGISet (CGISetCreation)

+ (id)arrayWithObject:(id)anObject;

- (id)initWithObject:(id)anObject;
- (id)initWithObjects:(id)firstObject, ...;
- (id)initWithObjects:(id*)items count:(CGIUInteger)count;

@end
