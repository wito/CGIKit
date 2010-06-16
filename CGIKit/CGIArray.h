/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"
#import "CGIPropertyList.h"
#import "CGICoding.h"
/** @class CGIArray
 *  @brief An ordered collection of objects.
 *
 *  CGIArray is the abstract superclass of the CGIArray cluster and represents an ordered collection of objects for which random access is very fast.
 */
@interface CGIArray : CGIObject <CGIPropertyListObject, CGICoding>

- (CGIUInteger)count; ///< @brief Counts the array.
- (id)objectAtIndex:(CGIUInteger)index; ///< @brief Accesses the array.

@end

/// @group
/// @brief Methods related to array creation and initializiation.
@interface CGIArray (CGIArrayCreation)

+ (id)arrayWithObject:(id)anObject; ///< @brief Creates a single-object array.

- (id)initWithObject:(id)anObject; ///< @brief Initializes an array with one item.
- (id)initWithObjects:(id)firstObject, ...; ///< @brief Initializes an array with several items.
- (id)initWithObjects:(id*)items count:(CGIUInteger)count; ///< @brief Initializes an array with several items.

- (CGIUInteger)indexOfObjectIdenticalTo:(id)anObject;

@end

@interface CGIMutableArray : CGIArray

- (void)addObject:(id)anItem;
- (void)insertObject:(id)anItem atIndex:(CGIUInteger)index;
- (void)removeObjectAtIndex:(CGIUInteger)index;
- (void)removeObjectIdenticalTo:(id)anObjects;

@end
