/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIString.h"
#include <stdarg.h>
#import <objc/objc-api.h>
#import "CGIKit/CGIFunctions.h"
#import "CGIKit/CGICoder.h"

typedef struct _CGIArrayBox CGIArrayBox;

struct _CGIArrayBox {
  id object;
  CGIArrayBox *next;
  CGIArrayBox *previous;
};

@interface CGIPlaceholderArray : CGIArray
@end
@interface CGIPlaceholderMutableArray : CGIMutableArray
@end
    
@class CGIConcreteArray;
@class CGIConcreteMutableArray;



@implementation CGIArray

- (CGIString *)classNameForArchiver {
  return @"CGIArray";
}

+ (id)alloc
{
  if ([CGIArray self] == self)
    return [CGIPlaceholderArray alloc];
  else
    return [super alloc];
}

+ (id)arrayWithObject:(id)anObject {
  return [[[self alloc] initWithObjects:anObject,nil] autorelease];
}

- (id)init {
  return [super init];
}

- (CGIUInteger)count {
  @throw @"CGIKitAbstractClassViolationException";
  return 0;
}

- (id)objectAtIndex:(CGIUInteger)index {
  @throw @"CGIKitAbstractClassViolationException";
  return 0;
}

- (CGIString *)description {
  if (![self count]) return @"()";
  CGIUInteger i;
  CGIUTF8String *retval = [CGIUTF8String stringWithString: @"("];
  for (i = 0; i < [self count]; i++) {
    id thisObject = [self objectAtIndex:i];
    [retval appendFormat:@"%@, ", ([thisObject conformsToProtocol:@protocol(CGIPropertyListObject)]?[thisObject plistRepresentation]:[[thisObject description] plistEscapedString])];
  }
  [retval appendString:@")"];
  return retval;
}

- (CGIString *)plistRepresentation {
  return [self description];
}

- (CGIString *)XMLRepresentation {
  if (![self count]) return @"<array></array>";
  CGIUTF8String *retval = [CGIUTF8String string];
  CGIUInteger i;
  [retval appendString:@"<array>"];
  for (i = 0; i < [self count]; i++) {
    id thisObject = [self objectAtIndex:i];
    if (![thisObject conformsToProtocol:@protocol(CGIPropertyListObject)]) @throw @"CGIPropertyListEncodingException";
    [retval appendString:[thisObject XMLRepresentation]];
  }
  [retval appendString:@"</array>"];
  return retval;
}

- (BOOL)isEqual:(id)other {
  if ([super isEqual:other]) return YES;
  if (![other isKindOfClass:[CGIArray class]]) return NO;
  if ([other count] != [self count]) return NO;
  CGIUInteger i;
  for (i = 0; i < [self count]; i++) {
    if (![[self objectAtIndex:i] isEqual:[other objectAtIndex:i]]) return NO;
  }
  return YES;
}

@end

@interface CGIConcreteArray : CGIArray {
  CGIUInteger _count;
  id *_items;
}

@end

@implementation CGIConcreteArray
    
- (id)init {
  self = [super init];
  if (self != nil) {
    _items = NULL;
    _count = 0;
  }
  return self;
}

- (id)initWithObject:(id)anObject {
  self = [super init];
  if (self != nil) {
    _count = 1;
    _items = objc_malloc(sizeof(id));
    *_items = [anObject retain];
  }
  return self;
}

- (id)initWithCoder:(CGICoder *)coder {
  self = [super init];
  if (self) {
    _count = [coder decodeUInteger];
    _items = objc_malloc(sizeof(id));
    CGIUInteger i;
    for (i = 0; i < _count; i++) {
      _items[i] = [coder decodeObject];
    }
  }
  return self;
}

- (void)encodeWithCoder:(CGICoder *)coder {
  [coder encodeUInteger:_count];
  CGIUInteger i;
  for (i = 0; i < _count; i++) {
    [coder encodeObject:_items[i]];
  }
}

- (id)objectAtIndex:(CGIUInteger)index {
  if (index >= _count) @throw @"CGIOutOfBoundsException";
  return _items[index];
}

- (CGIUInteger)count {
  return _count;
}

- (id)initWithObjects:(id*)items count:(CGIUInteger)count {
  self = [super init];
  if (self != nil) {
    _count = count;
    _items = objc_malloc(sizeof(id)*_count);
    CGIInteger i;
    for (i = 0; i < _count; i++) {
      _items[i] = [items[i] retain];
      if (!(items[i]))
        @throw @"CGINilArrayMemberException";
    }
  }
  return self;
}

- (CGIUInteger)indexOfObjectIdenticalTo:(id)anObject {
  CGIUInteger i;
  for (i = 0; i < _count; i++) {
    if (_items[i] == anObject)
      return i;
  }
  return CGINotFound;
}

- (void)dealloc {
  int i;
  for (i = 0; i < _count; i++) {
    [[self objectAtIndex:i] release];
  }
  if (_count > 0)
    objc_free(_items);
  [super dealloc];
}

@end

@implementation CGIPlaceholderArray

static CGIPlaceholderArray *sharedPlaceHolder;

+ (void)initialize {
  if ([CGIPlaceholderArray self] == self) sharedPlaceHolder = CGIAllocateObject(self, 0);
}

+ (id)alloc {
  return sharedPlaceHolder;
}

- (id)init {
  return [[CGIConcreteArray alloc] init];
}

- (id)initWithObject:(id)anObject {
  return [[CGIConcreteArray alloc] initWithObject:anObject];
}

- (id)initWithObjects:(id*)items count:(CGIUInteger)count {
  return [[CGIConcreteArray alloc] initWithObjects:items count:count];
}

- (id)initWithCoder:(CGICoder *)coder {
  return [[CGIConcreteArray alloc] initWithCoder:coder];
}

- (id)initWithObjects:(id)firstObject, ... {
  id* _items;
  CGIUInteger _count;
  va_list ap;
  va_start(ap, firstObject);
  CGIUInteger count = (firstObject)?1:0;
  id current;
  if (firstObject) {
    while (current = va_arg(ap, id)) count++;
  }
  va_end(ap);
  _count = count;

  if (count > 0) {
    va_start(ap, firstObject);
    _items = objc_malloc(sizeof(id)*count);
    id *this = _items;
    *this++ = firstObject;
    while (current = va_arg(ap, id)) {
      *this++ = current;
    }
    va_end(ap);
  } else if (count == 0) {
    _items = NULL;
  }
  id retval = [[CGIConcreteArray alloc] initWithObjects:_items count:_count];
  objc_free(_items);
  return retval;
}

- (id)retain {return self;}
- (void)release {}
- (id)autorelease {return self;}
- (id)copy {return self;}

@end

@implementation CGIMutableArray

- (CGIString *)classNameForArchiver {
  return @"CGIMutableArray";
}

+ (id)alloc
{
  if ([CGIMutableArray self] == self)
    return [CGIPlaceholderMutableArray alloc];
  else
    return [super alloc];
}

- (void)addObject:item {
  @throw @"CGIKitAbstractViolationException";
}

- (void)insertObject:(id)anObject atIndex:(CGIUInteger)idx {
  @throw @"CGIKitAbstractViolationException";
}

- (void)removeObjectAtIndex:(CGIUInteger)idx {
  @throw @"CGIKitAbstractViolationException";
}

- (void)removeObjectIdenticalTo:(id)object {
  @throw @"CGIKitAbstractViolationException";
}

@end

@implementation CGIPlaceholderMutableArray

static CGIPlaceholderMutableArray *sharedMutablePlaceHolder;

+ (void)initialize {
  if ([CGIPlaceholderMutableArray self] == self) sharedMutablePlaceHolder = CGIAllocateObject(self, 0);
}

+ (id)alloc {
  return sharedMutablePlaceHolder;
}

- (id)init {
  return [[CGIConcreteMutableArray alloc] init];
}

- (id)initWithObject:anObject {
  return [[CGIConcreteMutableArray alloc] initWithObject:anObject];
}

- (id)initWithObjects:(id)firstObject, ... {
  id* _items;
  CGIUInteger _count;
  va_list ap;
  va_start(ap, firstObject);
  CGIUInteger count = (firstObject)?1:0;
  id current;
  if (firstObject) {
    while (current = va_arg(ap, id)) count++;
  }
  va_end(ap);
  _count = count;

  if (count > 0) {
    va_start(ap, firstObject);
    _items = objc_malloc(sizeof(id)*count);
    id *this = _items;
    *this++ = firstObject;
    while (current = va_arg(ap, id)) {
      *this++ = current;
    }
    va_end(ap);
  } else if (count == 0) {
    _items = NULL;
  }
  id retval = [[CGIConcreteMutableArray alloc] initWithObjects:_items count:_count];
  objc_free(_items);
  return retval;
}

- (id)initWithObjects:(id*)items count:(CGIUInteger)count {
  return [[CGIConcreteMutableArray alloc] initWithObjects:items count:count];
}

- (id)retain {return self;}
- (void)release {}
- (id)autorelease {return self;}
- (id)copy {return self;}

@end

@interface CGIConcreteMutableArray : CGIMutableArray {
  CGIArrayBox *_first;
  CGIArrayBox *_last;
  CGIUInteger _count;
}

@end

@implementation CGIConcreteMutableArray

- (id)init {
  self = [super init];
  if (self != nil) {
    _first = _last = NULL;
    _count = 0;
  }
  return self;
}

- (id)initWithObjects:(id*)items count:(CGIUInteger)count {
  self = [super init];
  if (self != nil) {
    CGIUInteger i;
    for (i = 0; i < _count; i++) {
      [self addObject:items[i]];
    }
  }
  return self;
}

- (CGIUInteger)count { return _count; }

- (id)objectAtIndex:(CGIUInteger)index {
  if (index >= [self count])
    @throw @"CGIOutOfBoundsException";
  if (index == 0)
    return _first->object;
  if (index == [self count] - 1)
    return _last->object;
  CGIUInteger i;
  CGIArrayBox *aBox = _first;
  for (i = 0; i < index; i++) {
    aBox = aBox->next;
  }
  return aBox->object;
}

- (CGIUInteger)indexOfObjectIdenticalTo:(id)anObject {
  CGIUInteger i = 0;
  CGIArrayBox *aBox = _first;
  while (aBox) {
    if (aBox->object == anObject)
      return i;
    ++i;
    aBox = aBox->next;
  }
  return CGINotFound;
}

- (id)initWithObject:(id)anObject {
  if (!anObject) {
    @throw @"CGINilArrayMemberException";
    return nil;
  }
  self = [super init];
  if (self != nil) {
    _first = _last = objc_calloc(1,sizeof(CGIArrayBox));
    _first->object = [anObject retain];
    _count = 1;
  }
  return self;
}

- (void)addObject:(id)anObject {
  if (!anObject)
    @throw @"CGINilArrayMemberException";
  CGIArrayBox *newBox = objc_calloc(1, sizeof(CGIArrayBox));
  newBox->object = [anObject retain];
  if (_last) {
  newBox->previous = _last;
  _last = _last->next = newBox;
  } else {
    _first = _last = newBox;
  }
  _count++;
}

- (void)insertObject:(id)anObject atIndex:(CGIUInteger)index {
  if (!anObject)
    @throw @"CGINilArrayMemberException";
  if (index > [self count])
    @throw @"CGIOutOfBoundsException";
  if (index == [self count])
    return [self addObject:anObject];
  CGIArrayBox *newBox = objc_calloc(1, sizeof(CGIArrayBox));
  newBox->object = [anObject retain];
  if (index == 0)
    _first = _first->previous = newBox;
  else {
    CGIUInteger i;
    CGIArrayBox *oldBox = _first;
    for (i = 1; i < index; i++) {
      oldBox = oldBox->next;
    }
    oldBox->next->previous = newBox;
    newBox->next = oldBox->next;
    newBox->previous = oldBox;
    oldBox->next = newBox;
  }
  _count++;
}

- (void)removeObjectAtIndex:(CGIUInteger)index {
  if (index >= [self count])
    @throw @"CGIOutOfBoundsException";
  CGIUInteger i;
  CGIArrayBox *oldBox = _first;
  for (i = 0; i < index; ++i) {
    oldBox = oldBox->next;
  }
  if (oldBox->previous) {
    oldBox->previous->next = oldBox->next;
  } else {
    _first = oldBox->next;
  }
  
  if (oldBox->next) oldBox->next->previous = oldBox->previous;
  else _last = oldBox->previous;
  
  _count--;
}

- (void)removeObjectIdenticalTo:(id)anObject {
  CGIUInteger index;
  
  while ((index = [self indexOfObjectIdenticalTo:anObject]) != CGINotFound) {
    [self removeObjectAtIndex:index];
  }

}

- (void)dealloc {
  CGIArrayBox *next;
  CGIArrayBox *this = _first;
  while (this) {
    next = this->next;
    [this->object release];
    objc_free(this);
    this = next, next = NULL;
  }
  [super dealloc];
}

@end
