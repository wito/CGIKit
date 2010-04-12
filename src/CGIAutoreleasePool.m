/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGIAutoreleasePool.h"
#include <stdio.h>
#import <objc/objc-api.h>

struct _AutoMemory  {
  void *block;
  CGIAutomaticMemoryBlock *next;
};

struct _Autorelease {
  id object;
  CGIAutoreleasedObject *next;
};

@implementation CGIAutoreleasePool

static CGIAutoreleasePool *topPool = nil;

- (id)init {
  self = [super init];
  if (self != nil) {
    _nextPool = topPool;
    _objects = NULL;
    _blocks = NULL;
    topPool = self;
  }
  return self;
}

+ (void)addObjectToPool:anObject {
  if (topPool != nil) {
    [topPool addObjectToPool:anObject];
  }
  else
    fprintf(stderr, "Warning: autorelease called with no autorelease pool in place.\n");
}
+ (void)addMemoryBlockToPool:(void*)aBlock {
  if (topPool != nil) {
    [topPool addMemoryBlockToPool:aBlock];
  }
  else
    fprintf(stderr, "Warning: autorelease called with no autorelease pool in place.\n");
}

- (void)addObjectToPool:anObject {
  CGIAutoreleasedObject *newContainer = objc_malloc(sizeof(CGIAutoreleasedObject));
  newContainer->next = _objects;
  _objects = newContainer;
  newContainer->object = anObject;
}

- (void)addMemoryBlockToPool:(void*)aBlock {
  CGIAutomaticMemoryBlock *newContainer = objc_malloc(sizeof(CGIAutoreleasedObject));
  newContainer->next = _blocks;
  _blocks = newContainer;
  newContainer->block = aBlock;
}

- (void)drain {
  CGIAutomaticMemoryBlock *thisBlock = _blocks, *nextBlock;
  while (thisBlock) {
    nextBlock = thisBlock->next;
    objc_free(thisBlock->block);
    objc_free(thisBlock);
    thisBlock = nextBlock;
  } _blocks = NULL;
  CGIAutoreleasedObject *thisObject = _objects, *nextObject;
  while (thisObject) {
    nextObject = thisObject->next;
    [thisObject->object release];
    objc_free(thisObject);
    thisObject = nextObject;
  } _objects = NULL;
}

- (void)dealloc {
  [self drain];
  topPool = _nextPool;
  [super dealloc];
}

@end
