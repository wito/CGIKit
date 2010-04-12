/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"
#import "CGIPropertyList.h"

@class CGIArray;

/** @brief An unordered collection.
 *
 */
@interface CGIDictionary : CGIObject <CGIPropertyListObject>

- (CGIUInteger)count;

- (id)objectForKey:(id)aKey;
- (CGIArray*)allKeys;
- (CGIArray*)allKeysForObject:(id)anObject;
- (CGIArray*)allValues;

@end

@interface CGIDictionary (CGIDictionaryCreation)

+ (id)dictionary;
- (id)initWithObjectsAndKeys:(id)firstObject, ...;
+ (id)dictionaryWithObject:(id)anObject forKey:(id)aKey;
+ (id)dictionaryWithObjects:(CGIArray*)objects forKeys:(CGIArray*)keys;
+ (id)dictionaryWithObjects:(id*)objects forKeys:(id*)keys count:(CGIUInteger)count;
- (id)initWithObjects:(id*)objects forKeys:(id*)keys count:(CGIUInteger)count;
- (id)initWithObject:(id)anObject forKey:(id)aKey;

@end
    
@interface CGIDictionary (CGIMutableDictionary)
    
+ (id)dictionaryWithCapacity:(CGIUInteger)capacity;
- (id)initWithCapacity:(CGIUInteger)capacity;

- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;
- (void)removeObjectsForKeys:(CGIArray *)keyArray;

- (void)addEntriesFromDictionary:(CGIDictionary*)aDictionary;
- (void)setDictionary;

@end

@interface CGIMutableDictionary : CGIDictionary
@end
