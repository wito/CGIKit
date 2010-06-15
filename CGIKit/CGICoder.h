/* CGICoder.h */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

@class CGIData, CGIMutableData, CGIArray, CGIMutableArray, CGIMutableString;

@interface CGICoder : CGIObject {

}

/// @brief Encodes an object
- (void)encodeObject:(id)value;

/// @brief Encodes an unsigned 32 bit integer
- (void)encodeLength:(uint32_t)value;
/// @brief Encodes a signed 64 bit integer
- (void)encodeInteger:(CGIInteger)value;
/// @brief Encodes an unsigned 64 bit integer
- (void)encodeUInteger:(CGIUInteger)value;
/// @brief Encodes a NUL-terminated string of characters
- (void)encodeString:(const unichar *)string;
/// @brief Encodes a string of characters up to the first occurence of NUL or length is reached.
- (void)encodeString:(const unichar *)string toLength:(CGIUInteger)length;
/// @brief Encodes data with length
- (void)encodeData:(const unsigned char *)data length:(CGIUInteger)length;

/// @brief Decodes an object
- (id)decodeObject;

/// @brief Decodes a NUL-string of characters
- (unichar *)decodeString;
/// @brief Decodes a signed 64 bit integer
- (CGIInteger)decodeInteger;
/// @brief Decodes an unsigned 64 bit integer
- (CGIUInteger)decodeUInteger;
/// @brief Decodes data
- (unsigned char *)decodeDataWithLength:(CGIUInteger *)length;

@end

@interface CGIArchiver : CGICoder {
  CGIMutableData *_data;
  CGIMutableArray *_refTable;
  CGIMutableArray *_typeStrings;
  CGIMutableArray *_encodes;
  CGIString *_typeString;
}

- (id)initForWritingWithMutableData:(CGIMutableData *)data;

- (CGIData *)archiverData;

- (void)encodeRootObject:(id)rootObject;
+ (CGIData *)archivedDataWithRootObject:(id)rootObject;

@end

@interface CGIUnarchiver : CGICoder {
  CGIData *_data;
  CGIUInteger _cursor;
  CGIArray *_decodes;
  CGIArray *_refTable;
}

- (id)initForReadingWithData:(CGIData *)data;

+ (id)unarchiveObjectWithData:(CGIData *)data;

@end
