/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

typedef struct _AutoMemory  CGIAutomaticMemoryBlock;
typedef struct _Autorelease CGIAutoreleasedObject;

@interface CGIAutoreleasePool : CGIObject {
  CGIAutomaticMemoryBlock *_blocks;
  CGIAutoreleasedObject  *_objects;
  CGIAutoreleasePool *_nextPool;
}

+ (void)addObjectToPool:anObject;
+ (void)addMemoryBlockToPool:(void*)aBlock;

- (void)addObjectToPool:anObject;
- (void)addMemoryBlockToPool:(void*)aBlock;

- (void)drain;

@end
