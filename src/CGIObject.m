/* CGIObject.m */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */
/* Portions Copyright (c) 2006-2007 Christopher J. W. Lloyd (conformsToProtocol:)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*/

/** @file
 *  This file contains the implementation of CGIObject and the definitions of object-creation-related functions.
 *
 */

#import "CGIKit/CGIObject.h"
#import <objc/objc-api.h>
#import <objc/Protocol.h>
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIAutoreleasePool.h"

#ifdef ALIGN
#undef ALIGN
#endif
#define ALIGN __alignof__(double)

typedef struct obj_layout_unpadded {
  CGIUInteger refCount;
} unp;
#define UNP sizeof(unp)

struct obj_layout {
    CGIUInteger refCount;
    char padding[ALIGN - ((UNP % ALIGN) ? (UNP % ALIGN) : ALIGN)];
};
typedef struct obj_layout obj_layout;
typedef obj_layout *obj;


/** This function does the "heavy lifting" with regards to object allocation. It is responsible for creating a front-padded aligned object and give the object a sense of self.
 *  @param isa The Class object for the new object.
 *  @param extra Padding to add after the object.
 *  @return An uninitialized object.
 */
id CGIAllocateObject(Class isa, size_t extra) {
  size_t instance_size = sizeof(obj_layout) + class_get_instance_size(isa) + extra;
  id self = objc_malloc(instance_size);
  memset(self, 0, instance_size);
  self = (id)&(((obj)self)[1]);
  self->class_pointer = isa;
  return self;
}

id CGIKit_INTERNAL_GGIRetainObject(id self) {
  obj true_self = &((obj)self)[-1];
  true_self->refCount++;
  return self;
}

BOOL CGIKit_INTERNAL_CGIReleaseObjectWasZero(id self) {
  obj true_self = &((obj)self)[-1];
  if (true_self->refCount) {
    true_self->refCount--;
    return NO;
  } else return YES;
}

void CGIKit_INTERNAL_CGIDeallocateObject(id self) {
  obj true_self = &((obj)self)[-1];
  objc_free(true_self);
}

CGIUInteger CGIKit_INTERNAL_CGIRetainCount(id self) {
  obj true_self = &((obj)self)[-1];
  return (true_self->refCount);
}

@implementation CGIObject

+ alloc {
  return CGIAllocateObject(self, 0);
}

+ new {
  return [[self alloc] init];
}

- init {
  return self;
}

- retain {
  return CGIKit_INTERNAL_GGIRetainObject(self);
}

- (void)release {
  if (CGIKit_INTERNAL_CGIReleaseObjectWasZero(self)) [self dealloc];
}

- (id)autorelease {
  [CGIAutoreleasePool addObjectToPool:self];
  return self;
}

- (void)dealloc {
  CGIKit_INTERNAL_CGIDeallocateObject(self);
}

+ retain {
  return self;
}

+ (void)release {
  return;
}

+ (id)autorelease {
  return self;
}

+ (void)dealloc {
  return;
}

- (CGIUInteger)retainCount {
  return CGIKit_INTERNAL_CGIRetainCount(self) + 1;
}

+ (CGIUInteger)retainCount {
  return 1;
}

- (Class)class {
  object_get_class(self);
}

- (unsigned)hash {
  return (size_t)((CGIUInteger*)self) >> 3;
}

- (BOOL)isEqual:(id)other {
  return ((self == other) || [self hash] == [other hash]);
}

- (BOOL)isKindOfClass:(Class)class {
  Class aClass = [self class];
  do {
    if ([self class] == aClass) return YES;
  } while (aClass = class_get_super_class(aClass));
  return NO;
}

- (BOOL)isMemberOfClass:(Class)class {
  return ([self class] == class);
}

- self {
  return self;
}

- (Class)superclass {
  return class_get_super_class([self class]);
}

+ (Class)superclass {
  return class_get_super_class(self);
}

- (BOOL)respondsToSelector:(SEL)selector {
  return __objc_responds_to(self, selector);
}

+ (BOOL)conformsToProtocol:(Protocol *)aProtocol {
  struct objc_protocol_list* protoList = [self class]->protocols;
  for(; protoList != NULL; protoList = protoList->next){
    CGIUInteger i;
    for(i = 0; i<protoList->count; i++){
      if([protoList->list[i] conformsTo:aProtocol])
      return YES;
    }
  }
  if ([self superclass])
    return [[self superclass] conformsToProtocol:aProtocol];
   return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
  return [[self class] conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
  return NO;
}

/// @todo Implement memory zones.
- (id)zone {
  return nil;
}

- (CGIString *)description {
  return [CGIString stringWithFormat:@"%@ <%p>", [[self class] description], self];
}

+ (CGIString *)description {
  return [CGIString stringWithFormat:@"%s", ((Class)self)->name];
}

- (id)performSelector:(SEL)selector {
  IMP msg;
  msg = get_imp([self class],selector);
  return msg(self,selector);
}

- (id)performSelector:(SEL)selector withObject:arg {
  IMP msg;
  msg = get_imp([self class],selector);
  return msg(self,selector,arg);
}

- (id)performSelector:(SEL)selector withObject:arg1 withObject:arg2{
  IMP msg;
  msg = get_imp([self class],selector);
  return msg(self,selector,arg1,arg2);
}


@end
