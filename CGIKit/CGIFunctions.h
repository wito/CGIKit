/* CGIFunctions.h */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import <objc/objc.h>
#import "CGIKitTypes.h"

/** @file
 *  Contains the function declarations for general CGIKit functions for geometry and range manipulation, as well as runtime functions.
 */
/// @brief Creates a new instance.
id CGIAllocateObject(Class isa, size_t extra);

/// @brief Creates a new CGIRange.
CGIRange CGIMakeRange (CGIUInteger loc, CGIUInteger len);
