/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIKit/CGIData.h"
#import "CGIKit/CGIString.h"

#import <stdlib.h>
#import <string.h>

#define CGI_DATA_BLOCK_SIZE 256

@implementation CGIData

- (id)init {
  return [self initWithBytes:NULL length:0];
}

- (id)initWithData:(CGIData *)data {
  return [self initWithBytes:[data bytes] length:[data length]];
}

- (id)initWithBytes:(unsigned char *)data length:(CGIUInteger)length {
  self = [super init];
  if (self != nil) {
    if (length) _bytes = malloc(length);
    else _bytes = NULL;
    _length = length;
    if (length) memcpy(_bytes, data, _length);
  }
  return self;
}


- (CGIUInteger)length {
  return _length;
}

- (unsigned char *)bytes {
  return _bytes;
}


- (CGIData *)dataWithRange:(CGIRange)range {
  if (range.location + range.length > _length) @throw @"CGIRangeException";
  return [[[CGIData alloc] initWithBytes:&_bytes[range.location] length:range.length] autorelease];
}

- (unsigned char *)bytesWithRange:(CGIRange)range {
  if (range.location + range.length > _length) @throw @"CGIRangeException";
  unsigned char *retval = malloc(range.length);
  memcpy(retval, &_bytes[range.location], range.length);
  return retval;
}

- (void)dealloc {
  if (_bytes) free(_bytes);
  [super dealloc];
}

static const char dataParts[] = "0123456789abcdef";

- (CGIString *)plistRepresentation {
  CGIUInteger strLen = _length * 2 + 2 + _length / 4;
  char *str = malloc(strLen + 1);
  memset(str, ' ', strLen);
  str[0] = '<';
  str[strLen - 1] = '>';
  str[strLen] = 0;
  
  CGIUInteger i,j = 0;
  for (i = 0; i < _length * 2; i++) {
    if (!(i % 8 && i + j % 2)) j++;
  
    if (i % 2) {
      str[i + j] = dataParts[ (_bytes[i/2]) & 0x0F ];
    } else {
      str[i + j] = dataParts[ (_bytes[i/2] >> 4) & 0x0F ];
    }
  }
  
  return [CGIString stringWithUTF8String:str];
}

- (unsigned)hash {
  unsigned int hash = 5381;
  int i;
  for (i = 0; i < _length; i++)
    hash = ((hash << 5) + hash) + _bytes[i]; /* hash * 33 + c */
  return hash;
}

- (CGIString *)XMLRepresentation {
  static const char base64Table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  if (_length == 0) return @"";
  
  unichar *characters = calloc(((_length + 2) / 3 * 4) + 1, 1);
  [CGIAutoreleasePool addMemoryBlockToPool:characters];

  CGIUInteger i = 0;
  while (i < [data length]) {
    unichar buffer[3] = {0,0,0};
    CGIUInteger bufferLength = 0;
    while (bufferLength < 3 && i < _length)
      buffer[bufferLength++] = ((char *)[data bytes])[i++];

    //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
    characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
    characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];

    if (bufferLength > 1)
      characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
    else characters[length++] = '=';

    if (bufferLength > 2)
      characters[length++] = encodingTable[buffer[2] & 0x3F];
    else characters[length++] = '=';        
  }
  
  return [CGIString stringWithFormat:@"<data>%s</data>", characters];
}

@end

@implementation CGIMutableData

- (id)initWithBytes:(unsigned char *)data length:(CGIUInteger)length {
  self = [super initWithBytes:data length:length];
  if (self != nil) {
    _capacity = length;
  }
  return self;
}

- (void)appendData:(CGIData *)data {
  [self appendBytes:[data bytes] length:[data length]];
}

- (void)appendBytes:(const unsigned char *)data length:(CGIUInteger)length {
  CGIUInteger newLength = _length + length;
  if (newLength < _capacity) {
    while (newLength < _capacity) {
      _capacity += CGI_DATA_BLOCK_SIZE;
    }
    
    _bytes = realloc(_bytes, _capacity);
  }
  memcpy(&_bytes[_length], data, length);
  _length = newLength;
}

@end
