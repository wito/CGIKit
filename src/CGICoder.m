/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGICoder.h"
#import "CGIKit/CGIData.h"
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIFunctions.h"
#import <objc/objc-api.h>

#import "CGIKit/CGICoding.h"

#include <string.h>
#include <stdlib.h>


static const unsigned char FILE_HEADER[] = { 'C', 'K', 'A', 'r', 0, 0, 0, 1, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00 };

@implementation CGICoder

- (void)encodeObject:(id)value { @throw @"CGIKitAbstractViolationException"; }

- (void)encodeLength:(uint32_t)value { @throw @"CGIKitAbstractViolationException"; }
- (void)encodeInteger:(CGIInteger)value { @throw @"CGIKitAbstractViolationException"; }
- (void)encodeUInteger:(CGIUInteger)value { @throw @"CGIKitAbstractViolationException"; }
- (void)encodeString:(const unichar *)string { @throw @"CGIKitAbstractViolationException"; }
- (void)encodeString:(const unichar *)string toLength:(CGIUInteger)length { @throw @"CGIKitAbstractViolationException"; }
- (void)encodeData:(const unsigned char *)data length:(CGIUInteger)length { @throw @"CGIKitAbstractViolationException"; }

- (id)decodeObject { @throw @"CGIKitAbstractViolationException"; }
- (unichar *)decodeString { @throw @"CGIKitAbstractViolationException"; }
- (CGIInteger)decodeInteger { @throw @"CGIKitAbstractViolationException"; }
- (CGIUInteger)decodeUInteger { @throw @"CGIKitAbstractViolationException"; }
- (unsigned char *)decodeDataWithLength:(CGIUInteger *)length { @throw @"CGIKitAbstractViolationException"; }

@end

@implementation CGIArchiver

- (id)init {
  return [self initForWritingWithMutableData:[[[CGIMutableData alloc] init] autorelease]];
}

- (id)initForWritingWithMutableData:(CGIMutableData *)data {
  self = [super init];
  if (self) {
    _data = [data retain];
    _refTable = [[CGIMutableArray alloc] init];
    _encodes = [[CGIMutableArray alloc] init];
    _typeStrings = [[CGIMutableArray alloc] init];
  }
  return self;
}

- (CGIData *)archiverData {
  return [[_data retain] autorelease];
}

- (void)encodeLength:(uint32_t)value {
  unsigned char split[4];
  
  split[0] = (value >> 24) & 0xff;
  split[1] = (value >> 16) & 0xff;
  split[2] = (value >>  8) & 0xff;
  split[3] = (value      ) & 0xff;
    
  [_data appendBytes:split length:4];
}

- (void)encodeInteger:(CGIInteger)value {
  if (_typeString) _typeString = [_typeString stringByAppendingString:@"q"];
  else _typeString = @"q";
  
  CGIUInteger realVal = *((CGIUInteger*)(&value));
  
  unsigned char split[8];
  
  split[0] = (realVal >> 56) & 0xff;
  split[1] = (realVal >> 48) & 0xff;
  split[2] = (realVal >> 40) & 0xff;
  split[3] = (realVal >> 32) & 0xff;
  split[4] = (realVal >> 24) & 0xff;
  split[5] = (realVal >> 16) & 0xff;
  split[6] = (realVal >>  8) & 0xff;
  split[7] = (realVal      ) & 0xff;
  
  [_data appendBytes:split length:8];
}

- (void)encodeUInteger:(CGIUInteger)value {
  if (_typeString) _typeString = [_typeString stringByAppendingString:@"Q"];
  else _typeString = @"Q";
  
  unsigned char split[8];
  
  split[0] = (value >> 56) & 0xff;
  split[1] = (value >> 48) & 0xff;
  split[2] = (value >> 40) & 0xff;
  split[3] = (value >> 32) & 0xff;
  split[4] = (value >> 24) & 0xff;
  split[5] = (value >> 16) & 0xff;
  split[6] = (value >>  8) & 0xff;
  split[7] = (value      ) & 0xff;
  
  [_data appendBytes:split length:8];
}

- (void)encodeData:(const unsigned char *)data length:(CGIUInteger)length {
  if (_typeString) _typeString = [_typeString stringByAppendingString:@"D"];
  else _typeString = @"D";
  
  [self encodeLength:length];
  [_data appendBytes:data length:length];
}

- (void)encodeRootObject:(id)rootObject {
  // The file header, fortunately invariant
  [_data appendBytes:FILE_HEADER length:16];
  
  [_refTable addObject:@"CGIKIT_SENTINEL"];
  [_encodes addObject:@"CGIKIT_SENTINEL"];  
  [_typeStrings addObject:@"CGIKIT_SENTINEL"];
  
  id archiveData = _data;
  _data = nil;
  
  [self encodeObject:rootObject];
  
  _data = archiveData;
  
  int i;
  for (i = 1; i < [_refTable count]; i++) {
    id value = [_refTable objectAtIndex:i];
    [self encodeLength:i];
    
    [self encodeString:[[value classNameForArchiver] UTF8String]];
    [self encodeString:[[[_encodes objectAtIndex:i] objectForKey:@"CGIKIT_ARCHIVER_TYPESTRING"] UTF8String]];
    [_data appendData:[[_encodes objectAtIndex:i] objectForKey:@"CGIKIT_ARCHIVER_OBJECT_DATA"]];
    [self encodeLength:0xfffffffe];
  }
  
}

- (void)encodeObject:(id)value {
  if (_typeString) _typeString = [_typeString stringByAppendingString:@"@"];
  else _typeString = [CGIMutableString stringWithString:@"@"];

  if (!value) {
    [self encodeLength:0xfffffff0];
    return;
  }

  CGIUInteger refID = [_refTable indexOfObjectIdenticalTo:value];
  
  if (refID == CGINotFound) {
    CGIString *parentTypeString = _typeString;
    _typeString = nil;
  
    [self encodeLength:[_refTable count]];

    [_refTable addObject:value];
    CGIMutableData *objectData = [[[CGIMutableData alloc] init] autorelease];
    CGIMutableDictionary *_encode = [[[CGIMutableDictionary alloc] init] autorelease];
    [_encode setObject:objectData forKey:@"CGIKIT_ARCHIVER_OBJECT_DATA"];
    [_encodes addObject:_encode];
    

    CGIMutableData *archiveData = _data;
    _data = objectData;
    
    [value encodeWithCoder:self];
    
    _data = archiveData;
    [_encode setObject:_typeString forKey:@"CGIKIT_ARCHIVER_TYPESTRING"];
    _typeString = parentTypeString;
    
  } else {
    [self encodeLength:refID];
  }
}

+ (CGIData *)archivedDataWithRootObject:(id)rootObject {
  CGIArchiver *archiver = [[[CGIArchiver alloc] init] autorelease];
  [archiver encodeRootObject:rootObject];
  return [archiver archiverData];
}

- (void)encodeString:(const unichar *)string {
  if (_typeString) _typeString = [_typeString stringByAppendingString:@"*"];
  else _typeString = @"*";
  
  [_data appendBytes:string length:strlen(string) + 1];
}

@end

@implementation CGIUnarchiver

- (unichar *)decodeString {
  unsigned char *bytes = [_data bytes];
  
  size_t len = strlen(&bytes[_cursor]);
  unichar *retval = malloc(len + 1);
  strcpy(retval, &bytes[_cursor]);
  _cursor += (len + 1);
  
  return retval;
}

- (uint32_t)decodeLength {
  unsigned char *split;
  split = [_data bytesWithRange:CGIMakeRange(_cursor, 4)];
  
  uint32_t retval = (split[0] << 24) | (split[1] << 16) | (split[2] << 8) | split[3];
  free(split);
  _cursor += 4;
  return retval;
}

- (id)decodeObject {
  CGIUInteger reference = [self decodeLength];
  
  if (reference == 0xfffffff0 || reference == 0xffffffff) return nil;
  
  CGIMutableDictionary *refDict = [_refTable objectAtIndex:reference];
  id retval;
  if (retval = [refDict objectForKey:@"CGIKIT_UNARCHIVER_OBJECT"]) {
    return retval;
  } else {
    CGIData *archiveData = _data;
    _data = [refDict objectForKey:@"CGIKIT_UNARCHIVER_DATA"];
    CGIUInteger archiveCursor = _cursor;
    _cursor = 4;
    
    unichar *className = [self decodeString];
    free([self decodeString]); //discarding the typestring, we won't be needing it.
  
    Class objectClass = objc_get_class(className);
  
    retval = [objectClass alloc];
    
    [refDict setObject:retval forKey:@"CGIKIT_UNARCHIVER_OBJECT"];
    
    retval = [retval initWithCoder:self];
    
    if (retval != [refDict objectForKey:@"CGIKIT_UNARCHIVER_OBJECT"]) {
      [refDict setObject:retval forKey:@"CGIKIT_UNARCHIVER_OBJECT"];
    }
    
    _cursor = archiveCursor;
    _data = archiveData;
  }
  
  return retval;
}

- (id)decodeRootObject {
  CGIUInteger archiveCursor = _cursor;
  _cursor = 4;
  
  _data = [[_refTable objectAtIndex:1] objectForKey:@"CGIKIT_UNARCHIVER_DATA"];
  id retval = nil;
  
  unichar *className = [self decodeString];
  free([self decodeString]); //discarding the typestring, we won't be needing it.
  
  Class objectClass = objc_get_class(className);
  
  retval = [objectClass alloc];
  
  [[_refTable objectAtIndex:1] setObject:retval forKey:@"CGIKIT_UNARCHIVER_OBJECT"];
  
  [retval initWithCoder:self];
  
  _cursor = archiveCursor;
  return retval;
}

- (void)unpackArchive {
  _cursor = 16;
  
  CGIMutableArray *referenceTable = [[CGIMutableArray alloc] init];
  
  [referenceTable addObject:@"CGIKIT_SENTINEL"];
  
  while (_cursor < [_data length]) {
    CGIRange dataRange = CGIMakeRange(_cursor,0);
    _cursor += 4;
    unichar *className = [self decodeString];
    unichar *typeString = [self decodeString];
    
    unichar *type;
    
    for (type = typeString; *type != '\0'; *type++) {
      CGIUInteger len = 0;
      switch (*type) {
      case '@':
        _cursor += 4;
        break;
      case '*':
        free([self decodeString]);
        break;
      case 'q':
      case 'Q':
        _cursor += 8;
        break;
      case 'D':
        len = [self decodeLength];
        _cursor += len;
        break;
      default:
        break;
      }
    }
    _cursor += 4;
    dataRange.length = _cursor - dataRange.location;
    CGIMutableDictionary *refDict = [[[CGIMutableDictionary alloc] init] autorelease];
    [refDict setObject:[_data dataWithRange:dataRange] forKey:@"CGIKIT_UNARCHIVER_DATA"];
    [referenceTable addObject:refDict];
    free(className);
    free(typeString);
  }
  
  _refTable = referenceTable;
  [_data release];
  
  _data = nil;
  
}

- (id)init {
  @throw @"CGIPerversionException";
}

- (id)initForReadingWithData:(CGIData *)data {
  self = [super init];
  if (self) {
    _data = [data retain];
    [self unpackArchive];
  }
  return self;
}

+ (id)unarchiveObjectWithData:(CGIData *)data {
  CGIUnarchiver *unarchiver = [[[CGIUnarchiver alloc] initForReadingWithData:data] autorelease];
  return [unarchiver decodeRootObject];
}

- (CGIUInteger)decodeUInteger {
  unsigned char *split;
  split = [_data bytesWithRange:CGIMakeRange(_cursor, 8)];
  
  CGIUInteger retval =  ((CGIUInteger)(split[0]) << 56) |
                        ((CGIUInteger)(split[1]) << 48) |
                        ((CGIUInteger)(split[2]) << 40) |
                        ((CGIUInteger)(split[3]) << 32) |
                        ((CGIUInteger)(split[4]) << 24) |
                        ((CGIUInteger)(split[5]) << 16) |
                        ((CGIUInteger)(split[6]) <<  8) |
                        ((CGIUInteger)(split[7]) <<  0);
  free(split);
  _cursor += 8;
  return retval;
}

- (CGIInteger)decodeInteger {
  unsigned char *split;
  split = [_data bytesWithRange:CGIMakeRange(_cursor, 8)];
  
  CGIUInteger retval =  ((CGIUInteger)(split[0]) << 56) |
                        ((CGIUInteger)(split[1]) << 48) |
                        ((CGIUInteger)(split[2]) << 40) |
                        ((CGIUInteger)(split[3]) << 32) |
                        ((CGIUInteger)(split[4]) << 24) |
                        ((CGIUInteger)(split[5]) << 16) |
                        ((CGIUInteger)(split[6]) <<  8) |
                        ((CGIUInteger)(split[7]) <<  0);
  free(split);
  _cursor += 8;
  return *((CGIInteger *)(&retval));
}

- (unsigned char *)decodeDataWithLength:(CGIUInteger *)length {
  CGIUInteger len = [self decodeLength];
  
  unsigned char *retval = [_data bytesWithRange:CGIMakeRange(_cursor, len)];
  
  _cursor += len;
  return retval;
}

@end
