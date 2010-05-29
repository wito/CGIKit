/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"
#import "CGIPropertyList.h"
/*
@interface CGIString : CGIObject

- (id)initWithContentsOfFile:(CGIString *)fileName;

- (char *)cString;

- (BOOL)writeToFile:(CGIString*)fileName atomically:(BOOL)flag;

- (id)copy;

@end*/

@class CGIArray;

/// @brief An UTF-8 string.
@interface CGIString : CGIObject <CGIPropertyListObject>

- (CGIUInteger)length; ///< Returns the number of characters in the receiver. Does not include space for a terminating NULL byte.
- (CGIUInteger)lengthOfBytes; ///< Returns the number of bytes in the receiver. Does not include space for a terminating NULL byte.
- (unichar)characterAtIndex:(CGIUInteger)index;

- (BOOL)isEqualToString:(CGIString *)other;

@end

@interface CGIString (CGIStringCreation)

+ (id)string;
+ (id)stringWithString:(CGIString *)string;
+ (id)stringWithUTF8String:(const unichar *)bytes;
+ (id)stringWithUTF8String:(const unichar *)bytes length:(CGIUInteger)length;
+ (id)stringWithUTF8StringNoCopy:(unichar *)bytes length:(CGIUInteger)length freeWhenDone:(BOOL)free;
+ (id)stringWithFormat:(CGIString *)format, ...;
- (id)init;
- (const unichar*)UTF8String;
- (id)initWithUTF8String:(const unichar *)string;
- (id)initWithUTF8String:(const unichar *)string length:(CGIUInteger)length;
- (id)initWithUTF8StringNoCopy:(unichar *)string length:(CGIUInteger)length freeWhenDone:(BOOL)free;
- (id)initWithFormat:(CGIString *)format, ...;
- (id)stringByAppendingString:(CGIString *)string;
- (id)stringByRemovingSuffix:(CGIString *)suffix;

- (BOOL)writeToFile:(CGIString *)filename atomic:(BOOL)flag;
- (id)initWithContentsOfFile:(CGIString *)path;

@end

@interface CGIString (CGIStringChopping)

- (CGIString *)plistEscapedString;
- (CGIString *)XMLEscapedString;

- (CGIString *)URLEncodedString;
- (CGIString *)URLDecodedString;

- (CGIArray *)componentsSeparatedByString:(CGIString *)separator;
- (CGIString *)substringFromIndex:(CGIUInteger)index;

- (BOOL)hasSuffix:(CGIString *)suff;

@end

@interface CGIMutableString : CGIString

- (void)appendString:(CGIString *)aString;
- (void)appendFormat:(CGIString *)format, ...;

@end

@interface CGIUTF8String : CGIMutableString {
  @protected
    unichar *_bytes;
    CGIUInteger _length;
}

- (unichar *)UTF8CharacterAtIndex:(CGIUInteger)index;

@end

@interface CGISimpleCString : CGIString {
  @protected
    unichar *_bytes;
    CGIUInteger _length;
}

@end

@interface CGIConstantString : CGISimpleCString
@end
