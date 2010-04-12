/* CGIObject.h */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import <objc/objc.h>
#import "CGIKitTypes.h"

@class CGIString;


/** @brief The root class for CGIKit.
 */
@interface CGIObject {
  Class isa; ///< @brief The Class object.
}

+ new; ///< @brief Creates a new object.
+ alloc; ///< @brief Allocates a new object.
- init; ///< @brief Initializes a new object.

- (CGIString *)description; ///< @brief Returns a description of the object.
+ (CGIString *)description; ///< @brief Returns a description of the class (the class name).

- retain; ///< @brief Increases the retain count by one.
- (CGIUInteger)retainCount; ///< @brief Returns the retain count.
- (void)release; ///< @brief Decreases the retain count by one.
- (void)dealloc; ///< @brief Finalizes the object.
- (id)autorelease; ///< @brief Autoreleases the object.

- (Class)class; ///< @brief Returns the Class object.
- (Class)superclass; ///< @brief Returns the Class object of the superclass.

- (BOOL)isEqual:(id)other; ///< @brief Compares two objects.
- (unsigned)hash; ///< @brief Returns a hash of the object.
- self; ///< @brief Returns a pointer to self.

- (BOOL)isKindOfClass:(Class)class; ///< @return YES if the object is a descendant of class.
- (BOOL)isMemberOfClass:(Class)class; ///< @return YES if the object is an object of class.
- (BOOL)respondsToSelector:(SEL)selector; ///< @return YES if the object responds to selector.
- (BOOL)conformsToProtocol:(Protocol *)aProtocol; ///< @return YES if the object conforms to aProtocol.

- performSelector:(SEL)selector; ///< @brief Causes the object to perform a selector.
- performSelector:(SEL)selector withObject:arg; ///< @brief Causes the object to perform a selector with one argument.
- performSelector:(SEL)selector withObject:arg1 withObject:arg2; ///< @brief Causes the object to perform a selector with two arguments.

- (id)zone; ///< @brief The memory zone the object belongs to.

- (BOOL)isProxy; ///< @return YES if the object is a proxy.

@end
