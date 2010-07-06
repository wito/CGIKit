/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIString.h"
#include <stdarg.h>
#import <objc/objc-api.h>
#import "CGIKit/CGIFunctions.h"
#include <assert.h>
#import "CGIKit/CGIAutoreleasePool.h"

typedef struct _CGIDictBucket CGIDictBucket;

struct _CGIDictBucket {
  id key;
  id object;
  CGIDictBucket *next;
  unsigned int hash;
};

unsigned int indexFor (unsigned hash, CGIUInteger capacity) {
  return (hash & (capacity - 1u));
}

void CGIDictionaryInsertBucketInBacking(CGIDictBucket** backing, CGIDictBucket *bucket, CGIUInteger capacity) {
  CGIUInteger index = indexFor(bucket->hash, capacity);
  bucket->next = NULL;
  if (backing[index] == NULL) {
    backing[index] = bucket;
  } else { /* ONOES COLLISION!! */
    CGIDictBucket *someBucket = backing[index];
    while (someBucket->next != NULL)
      someBucket = someBucket->next;
    someBucket->next = bucket;
  }
}

CGIDictBucket **CGIDictionaryGrowBacking(CGIDictBucket **backing, CGIUInteger oldCapacity,CGIUInteger *newCapacity) {
  *newCapacity = oldCapacity * 2;
  CGIDictBucket **newBacking = objc_calloc(*newCapacity, sizeof(CGIDictBucket*));
  if (newBacking == NULL) {
    *newCapacity = oldCapacity;
    return backing;
  }
  CGIUInteger i;
  for (i = 0; i < oldCapacity; i++) {
    CGIDictBucket *thisBucket = backing[i];
    if (thisBucket == NULL) continue;
    CGIDictBucket *nextBucket;
    do {
      nextBucket = thisBucket->next;
      CGIDictionaryInsertBucketInBacking(newBacking, thisBucket, *newCapacity);
      thisBucket = nextBucket;
    } while (thisBucket);
  }
  objc_free(backing);
  return newBacking;
}

@interface CGIPlaceholderDictionary : CGIDictionary

+ (Class)concreteClass;
- (Class)concreteClass;

@end
    
@class CGIConcreteDictionary;

@implementation CGIDictionary

+ (id)alloc
{
  if ([CGIDictionary self] == self)
    return [CGIPlaceholderDictionary alloc];
  else
    return [super alloc];
}

+ (id)dictionaryWithObject:(id)anObject forKey:(id)aKey {
  return [[[self alloc] initWithObject:anObject forKey:aKey] autorelease];
}

+ (id)dictionaryWithObjects:(id*)objects forKeys:(id*)keys count:(CGIUInteger)count {
  return [[[self alloc] initWithObjects:objects forKeys:keys count:count] autorelease];
}

+ (id)dictionary {
  return [[[self alloc] init] autorelease];
}

+ (id)dictionaryWithObjects:(CGIArray *)objects forKeys:(CGIArray *)keys {
  return [[[self alloc] initWithObjects:objects forKeys:keys] autorelease];
}

- (id)init {
  return [super init];
}

- (CGIUInteger)count {
  @throw @"CGIKitAbstractClassViolationException";
  return 0;
}

- (id)objectForKey:(id)aKey {
  @throw @"CGIKitAbstractClassViolationException";
  return nil;
}

- (CGIArray*)allKeys {
  @throw @"CGIKitAbstractClassViolationException";
  return nil;
}

- (CGIArray*)allKeysForObject:(id)anObject {
  @throw @"CGIKitAbstractClassViolationException";
  return nil;
}

- (CGIArray*)allValues {
  @throw @"CGIKitAbstractClassViolationException";
  return nil;
}

- (CGIString *)description {
  if ([self count] == 0) return @"{}";
  CGIUTF8String *retval = [CGIUTF8String stringWithString:@"{\n"];
  CGIArray *myKeys = [self allKeys];
  CGIUInteger i;
  for (i = 0; i < [myKeys count]; i++) {
    id thisKey = [myKeys objectAtIndex:i];
    id thisObject = [self objectForKey:thisKey];
    [retval appendFormat:@"  %@ = %@;\n", [[thisKey description] plistEscapedString], ([thisObject conformsToProtocol:@protocol(CGIPropertyListObject)]?[thisObject plistRepresentation]:[[thisObject description] plistEscapedString])];
  }
  [retval appendString:@"}"];
  return retval;
}

- (CGIString *)plistRepresentation {
  return [self description];
}

- (CGIString *)XMLRepresentation {
  if ([self count] == 0) return @"<dict></dict>";
  CGIUTF8String *retval = [CGIUTF8String string];
  [retval appendString:@"<dict>"];
  CGIArray *myKeys = [self allKeys];
  CGIUInteger i;
  for (i = 0; i < [myKeys count]; i++) {
    id thisKey = [myKeys objectAtIndex:i];
    id thisObject = [self objectForKey:thisKey];
    [retval appendFormat:@"<key>%@</key>%@", [[thisKey description] XMLEscapedString], [thisObject XMLRepresentation]];
  }
  [retval appendString:@"</dict>"];
  return retval;
  return nil;
}


@end

@interface CGIConcreteDictionary : CGIDictionary {
  CGIUInteger _capacity;
  CGIUInteger _count;
  CGIDictBucket **_buckets;
}

@end
    
@implementation CGIConcreteDictionary
    
- (id)init {
  self = [super init];
  if (self != nil) {
    _count = 0;
    _capacity = 0;
    _buckets = NULL;
  }
  return self;
}

- (id)initWithObjects:(id*)objects forKeys:(id*)keys count:(CGIUInteger)count {
  self = [super init];
  if (self != nil) {
    _count = count;
    _capacity = 1;
    do {
      _capacity *= 2;
    } while (_capacity < _count*2);
    _buckets = objc_calloc( _capacity,sizeof(CGIDictBucket*));
    CGIUInteger i;
    for (i = 0; i < _count; i++) {
      CGIDictBucket *aBucket = objc_malloc(sizeof(CGIDictBucket));
      aBucket->next = NULL;
      aBucket->key = [keys[i] retain];
      aBucket->object = [objects[i] retain];
      aBucket->hash = [keys[i] hash];
      CGIDictionaryInsertBucketInBacking(_buckets, aBucket, _capacity);
    }
  }
  return self;
}

- (id)initWithObjects:(CGIArray *)objects forKeys:(CGIArray *)keys {
  
  id *obuf = objc_malloc([objects count] * sizeof(id *));
  id *kbuf = objc_malloc([objects count] * sizeof(id *));
  int count;
  
  for (count = 0; count < [objects count]; count++) {
    obuf[count] = [objects objectAtIndex:count];
    kbuf[count] = [keys objectAtIndex:count];
  }
  
  [CGIAutoreleasePool addMemoryBlockToPool:obuf];
  [CGIAutoreleasePool addMemoryBlockToPool:kbuf];
  
  return [self initWithObjects:obuf forKeys:kbuf count:count];
}

- (id)initWithObject:(id)anObject forKey:(id)aKey {
  return [self initWithObjects:&anObject forKeys:&aKey count:1];
}

- (id)objectForKey:(id)aKey {
  unsigned hash = [aKey hash];
  CGIDictBucket *targetBucket = _buckets[indexFor(hash, _capacity)];
  if (!targetBucket) return nil;
  do {
    if ([targetBucket->key isEqual:aKey]) return [[targetBucket->object retain] autorelease];
  } while (targetBucket = targetBucket->next);
  return nil;
}

- (CGIUInteger)count {
  return _count;
}

- (CGIArray *)allKeys {
  id *anArray = objc_malloc(sizeof(id)*_count);
  id *iter = anArray;
  CGIUInteger i;
  for (i = 0; i < _capacity; i++) {
    CGIDictBucket *aBucket;
    if (aBucket = _buckets[i]) {
      *iter++ = aBucket->key;
      while (aBucket = aBucket->next) {
        *iter++ = aBucket->key;
      }
    }
  }
  assert(iter - anArray == _count);
  CGIArray *retval = [[CGIArray alloc] initWithObjects:anArray count:[self count]];
  objc_free(anArray);
  return [retval autorelease];
}

- (CGIArray *)allValues {
  id *anArray = objc_malloc(sizeof(id)*_count);
  id *iter = anArray;
  CGIUInteger i;
  for (i = 0; i < _capacity; i++) {
    CGIDictBucket *aBucket;
    if (aBucket = _buckets[i]) {
      *iter++ = aBucket->object;
      while (aBucket = aBucket->next) {
        *iter++ = aBucket->object;
      }
    }
  }
  assert(iter - anArray == _count);
  CGIArray *retval = [[CGIArray alloc] initWithObjects:anArray count:[self count]];
  objc_free(anArray);
  return [retval autorelease];
}

- (void)dealloc {
  CGIUInteger i;
  for (i = 0; i < _capacity; i++) {
    CGIDictBucket *aBucket;
    CGIDictBucket *nextBucket;
    if (aBucket = _buckets[i]) {
      while (nextBucket = aBucket->next) {
        [aBucket->key release];
        [aBucket->object release];
        objc_free(aBucket);
        aBucket = nextBucket;
      }
      [aBucket->key release];
      [aBucket->object release];
      objc_free(aBucket);
    }
  }
  objc_free(_buckets);
  [super dealloc];
}

@end

@implementation CGIPlaceholderDictionary

static CGIPlaceholderDictionary *sharedPlaceHolder;

+ (Class)concreteClass {
  return [CGIConcreteDictionary class];
}

- (Class)concreteClass {
  return [CGIConcreteDictionary class];
}

+ (void)initialize {
  if ([CGIPlaceholderDictionary self] == self) sharedPlaceHolder = CGIAllocateObject(self, 0);
}

+ (id)alloc {
  return sharedPlaceHolder;
}

- (id)init {
  return [[[self concreteClass] alloc] init];
}

- (id)initWithObjects:(id*)objects forKeys:(id*)keys count:(CGIUInteger)count {
  return [[[self concreteClass] alloc] initWithObjects:objects forKeys:keys count:count];
}

- (id)initWithObjects:(CGIArray *)os forKeys:(CGIArray *)ks {
  return [[[self concreteClass] alloc] initWithObjects:os forKeys:ks];
}

- (id)initWithObject:(id)anObject forKey:(id)aKey {
  return [[[self concreteClass] alloc] initWithObject:anObject forKey:aKey];
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... {
  id* objects;
  id* keys;
  CGIUInteger _count;
  va_list ap;
  va_start(ap, firstObject);
  CGIUInteger count = (firstObject)?1:0;
  id current;
  if (firstObject) {
    while (current = va_arg(ap, id)) count++;
  }
  va_end(ap);
  if (count % 2) {
    @throw @"CGIDictionaryNilKeyException";
    return nil;
  }
  _count = count / 2;

  if (_count > 0) {
    va_start(ap, firstObject);
    objects = objc_malloc(sizeof(id)*count);
    keys = objc_malloc(sizeof(id)*count);
    id *this = objects;
    id *that = keys;
    *this++ = firstObject;
    *that++ = va_arg(ap, id);
    CGIUInteger i;
    for (i = 0; i < _count; i++) {
      *this++ = va_arg(ap, id);
      *that++ = va_arg(ap, id);
    }
    va_end(ap);
  } else if (count == 0) {
    objects = NULL;
    keys = NULL;
  }
  id retval = [[[self concreteClass] alloc] initWithObjects:objects forKeys:keys count:_count];
  objc_free(objects);
  objc_free(keys);
  return retval;
}

- (id)retain {return self;}
- (void)release {}
- (id)autorelease {return self;}
- (id)copy {return self;}

@end

@interface CGIConcreteMutableDictionary : CGIConcreteDictionary
@end

@interface CGIPlaceholderMutableDictionary : CGIPlaceholderDictionary
@end
    
@implementation CGIMutableDictionary

+ (id)dictionaryWithCapacity:(CGIUInteger)capacity {
  return [[[self alloc] initWithCapacity:capacity] autorelease];
}

+ (id)alloc {
  if ([CGIMutableDictionary self] == self)
    return [CGIPlaceholderMutableDictionary alloc];
  else
    return [super alloc];
}

@end

@implementation CGIPlaceholderMutableDictionary

static CGIPlaceholderMutableDictionary *sharedMutablePlaceHolder;

+ (void)initialize {
  if ([CGIPlaceholderMutableDictionary self] == self) sharedMutablePlaceHolder = CGIAllocateObject(self, 0);
}

+ (id)alloc {
  return sharedMutablePlaceHolder;
}

+ (Class)concreteClass {
  return [CGIConcreteMutableDictionary class];
}

- (Class)concreteClass {
  return [CGIConcreteMutableDictionary class];
}


- (id)initWithCapacity:(CGIUInteger)capacity {
  return [[[self concreteClass] alloc] initWithCapacity:capacity];
}

@end

@implementation CGIConcreteMutableDictionary

- (id)init {
  return [self initWithCapacity:15];
}

- (id)initWithCapacity:(CGIUInteger)capacity {
  self = [super init];
  if (self != nil) {
    _count = 0;
    _capacity = 1;
    do {
      _capacity *= 2;
    } while (_capacity < capacity*2);
    _buckets = objc_calloc( _capacity,sizeof(CGIDictBucket*));
  }
  return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey {
  if (!aKey) @throw @"CGIDictionaryNilKeyException";
  CGIDictBucket *newBucket = objc_calloc(1, sizeof(CGIDictBucket));
  newBucket->key = [aKey retain];
  newBucket->object = [anObject retain];
  newBucket->hash = [aKey hash];
  if ([self objectForKey:aKey])
    [self removeObjectForKey:aKey];
  CGIDictionaryInsertBucketInBacking(_buckets, newBucket, _capacity);
  _count++;
  if (_count == _capacity) {
    _buckets = CGIDictionaryGrowBacking(_buckets, _capacity, &_capacity);
  }
}

- (void)removeObjectForKey:(id)aKey {
  unsigned hash = [aKey hash];
  CGIUInteger index = indexFor(hash, _capacity);
  CGIDictBucket *targetBucket = _buckets[index];
  CGIDictBucket *parentBucket = NULL;
  if (!targetBucket) return;
  do {
    if ([targetBucket->key isEqual:aKey]) break;
    if (!targetBucket->next) return;
  } while (parentBucket = targetBucket, targetBucket = targetBucket->next);
  if (parentBucket) {
    parentBucket->next = targetBucket->next;
  }
  [targetBucket->key release];
  [targetBucket->object release];
  if (targetBucket == _buckets[index]) {
    _buckets[index] = targetBucket->next;
  }
  objc_free(targetBucket);
  _count--;
}

- (void)removeAllObjects {
  CGIUInteger i;
  for (i = 0; i < _capacity; i++) {
    CGIDictBucket *aBucket;
    CGIDictBucket *nextBucket;
    if (aBucket = _buckets[i]) {
      while (nextBucket = aBucket->next) {
        [aBucket->key release];
        [aBucket->object release];
        objc_free(aBucket);
        aBucket = nextBucket;
      }
      [aBucket->key release];
      [aBucket->object release];
      objc_free(aBucket);
      _buckets[i] = NULL;
    }
  }
}

- (void)removeObjectsForKeys:(CGIArray *)keyArray {
  CGIUInteger i;
  for (i = 0; i < [keyArray count]; i++) {
    [self removeObjectForKey:[keyArray objectAtIndex:0]];
  }
}

// 
// - (void)addEntriesFromDictionary:(CGIDictionary*)aDictionary;
// - (void)setDictionary;






@end
