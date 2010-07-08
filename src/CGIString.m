/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */
// Muchos gracias CocoaDev.org

#define _GNU_SOURCE

#import "CGIKit/CGIString.h"
#import "CGIKit/CGIFunctions.h"
#import <string.h>
#import <stdlib.h>
#import <unistd.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#import <objc/objc-api.h>
#import "CGIKit/CGIArray.h"

#import "CGIKit/CGICoder.h"

@interface CGIPlaceholderString : CGIString
@end

@interface CGIMutablePlaceholderString : CGIMutableString
@end

@implementation CGIString

- (unsigned)hash {
  unsigned int hash = 5381;
  int c;
  const char *str = [self UTF8String];
  while (c = *str++)
    hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
  return hash;
}

- (CGIString *)lowercaseString {
  const unichar *myValue = [self UTF8String];
  CGIUInteger myLen = [self lengthOfBytes];
  unichar *newValue = malloc(myLen + 1);
  memcpy(newValue, myValue, myLen);
  newValue[myLen] = 0;
  
  unichar *iter = newValue;
  while (*iter) {
    if (isascii(*iter) && isupper(*iter)) {
      *iter = tolower(*iter);
    }
    ++iter;
  }
  
  return [CGIString stringWithUTF8String:newValue];
}

- (CGIString *)capitalizedString {
  const unichar *myValue = [self UTF8String];
  CGIUInteger myLen = [self lengthOfBytes];
  unichar *newValue = malloc(myLen + 1);
  memcpy(newValue, myValue, myLen);
  newValue[myLen] = 0;
  
  unichar *iter = newValue;
  while (*iter) {
    if (iter == newValue && isascii(*iter) && islower(*iter)) {
      *iter = toupper(*iter);
    } else if (isascii(*iter) && isupper(*iter)) {
      *iter = tolower(*iter);
    }
    ++iter;
  }
  
  return [CGIString stringWithUTF8String:newValue];
}

- (CGIString *)classNameForArchiver {
  return @"CGIString";
}

+ (id)string {
  return @"";
}

+ (id)stringWithString:(CGIString *)string {
  return [[[CGISimpleCString alloc] initWithUTF8String:[string UTF8String]] autorelease];
}

+ (id)stringWithUTF8String:(unichar *)bytes {
  return [[[self alloc] initWithUTF8String:bytes] autorelease];
}

+ (id)stringWithUTF8String:(unichar *)bytes length:(CGIUInteger)length {
  return [[[self alloc] initWithUTF8String:bytes length:length] autorelease];
}

+ (id)stringWithFormat:(CGIString *)format, ... {
  unichar *buf;
  va_list ap;
  va_start(ap, format);
  vasprintf(&buf, [format UTF8String], ap);
  va_end(ap);
  return [[[CGIUTF8String alloc] initWithUTF8StringNoCopy:buf length:strlen(buf) freeWhenDone:YES] autorelease];
}

- (id)copy {
  return [[CGIString alloc] initWithUTF8String:[self UTF8String]];
}

- (id)stringByAppendingString:(CGIString *)string {
  unichar *buf;
  asprintf(&buf, "%@%@", self, string);
  return [[[CGISimpleCString alloc] initWithUTF8StringNoCopy:buf length:strlen(buf) freeWhenDone:YES] autorelease];
}

+ (id)alloc
{
  if ([CGIString self] == self)
    return [CGIPlaceholderString alloc];
  else
    return [super alloc];
}

- (id)init {
  return [super init];
}

- (CGIUInteger)length {
  @throw @"CGIKitAbstractClassViolationException";
  return 0;
}

- (id)initWithContentsOfFile:(CGIString *)path {
  return [[CGISimpleCString alloc] initWithContentsOfFile:path];
}

- (id)initWithCoder:(CGICoder *)coder {
  unichar *stringData = [coder decodeString];

  return [[CGISimpleCString alloc] initWithUTF8StringNoCopy:stringData length:strlen(stringData) freeWhenDone:YES];
}

- (CGIUInteger)lengthOfBytes {
  return [self length];
}

- (unichar)characterAtIndex:(CGIUInteger)index {
  @throw @"CGIKitAbstractClassVialoationException";
  return 0;
}

- (CGIString *)description {
  return self;
}

- (BOOL)isEqual:(id)other {
  return ([super isEqual:other] && [other isKindOfClass:[CGIString self]] && [self isEqualToString:other]);
}

- (BOOL)isEqualToString:(CGIString *)other {
  if ([self length] != [other length]) return NO;
  CGIUInteger i, len = [self length];
  for (i = 0; i < len; i++) {
    if (!([self characterAtIndex:i] == [other characterAtIndex:i])) return NO;
  }
  return YES;
}

- (id)initWithUTF8String:(unichar*)cString {
  self = [super init];
  [self release];
  return [[CGISimpleCString alloc] initWithUTF8String:cString];
}

- (id)initWithUTF8String:(unichar*)cString length:(CGIUInteger)length{
  self = [super init];
  [self release];
  return [[CGISimpleCString alloc] initWithUTF8String:cString length:length];
}

- (id)initWithFormat:(CGIString *)format, ... {
  self = [super init];
  [self release];
  unichar *buf;
  va_list ap;
  va_start(ap, format);
  vasprintf(&buf, [format UTF8String], ap);
  va_end(ap);
  return [[CGISimpleCString alloc] initWithUTF8StringNoCopy:buf length:strlen(buf) freeWhenDone:YES];
}

- (CGIString *)plistRepresentation {
  return [self plistEscapedString];
}

- (CGIString *)XMLRepresentation {
  return [CGIString stringWithFormat:@"<string>%@</string>", [self XMLEscapedString]];
}

- (CGIString *)plistEscapedString {
  const unichar *_bytes = [self UTF8String];
  const CGIUInteger _length = [self lengthOfBytes];
  unichar *buf = objc_malloc(_length * 2 + 3);
//  buf = objc_malloc(_length + extraLength + needsQuotes?2:0 + 1);
  CGIUInteger i;
  CGIUInteger j = 0;
  buf[j++] = '"';
  for (i = 0; i < _length; i++) {
    switch (_bytes[i]) {
    case '"':
      buf[j++] = '\\';
      buf[j++] = '"';
      break;
    default:
      buf[j++] = _bytes[i];
      break;
    }
  }
  buf[j++] = '"';
  buf[j++] = '\0';
  assert(j == strlen(buf) + 1);
  return [[[CGISimpleCString alloc] initWithUTF8StringNoCopy:buf length:strlen(buf) freeWhenDone:YES] autorelease];
}

- (CGIString *)XMLEscapedString {
  const unichar *_bytes = [self UTF8String];
  const CGIUInteger _length = [self lengthOfBytes];
  unichar *buf;
  CGIUInteger i;
  CGIUInteger extraLength = 0;
  for (i = 0; i < _length; i++) {
    switch (_bytes[i]) {
    case '"':
    case '\'':
      extraLength += 5;
      break;
    case '&':
      extraLength += 4;
      break;
    case '<':
    case '>':
      extraLength += 3;
      break;
    default:
      break;
    }
  }
  buf = objc_malloc(_length + extraLength + 1);
  CGIUInteger j = 0;
  for (i = 0; i < _length; i++) {
    switch (_bytes[i]) {
    case '"':
      memcpy(&buf[j], "&quot;", 6);
      j += 6;
      break;
    case '\'':
      memcpy(&buf[j], "&apos;", 6);
      j += 6;
      break;
    case '&':
      memcpy(&buf[j], "&amp;", 5);
      j += 5;
      break;
    case '<':
      memcpy(&buf[j], "&lt;", 4);
      j += 4;
      break;
    case '>':
      memcpy(&buf[j], "&gt;", 4);
      j += 4;
      break;
    default:
      buf[j++] = _bytes[i];
      break;
    }
  }
  buf[j++] = '\0';
  assert(j == strlen(buf) + 1);
  return [[[CGISimpleCString alloc] initWithUTF8StringNoCopy:buf length:strlen(buf) freeWhenDone:YES] autorelease];
}

- (CGIString *)URLEncodedString {
  const unichar *_bytes = [self UTF8String];
  const CGIUInteger _length = [self lengthOfBytes];
  unichar *buf;
  CGIUInteger i;
  CGIUInteger extraLength = 0;
  for (i = 0; i < _length; i++) {
    if (!strchr(".-_!~*'()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", _bytes[i]))
      extraLength += 2;
  }
  buf = objc_malloc(_length + extraLength + 1);
  CGIUInteger j = 0;
  for (i = 0; i < _length; i++) {
    if (!strchr(".-_!~*'()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", _bytes[i])) {
      sprintf(&buf[j], "%%%.2x", ((unsigned char*)_bytes)[i]);
      j += 3;
    } else buf[j++] = _bytes[i];
  }
  buf[j++] = '\0';
  assert(j == strlen(buf) + 1);
  return [[[CGISimpleCString alloc] initWithUTF8StringNoCopy:buf length:strlen(buf) freeWhenDone:YES] autorelease];
}


- (CGIString *)URLDecodedString {
  const unichar *_bytes = [self UTF8String];
  const CGIUInteger _length = [self lengthOfBytes];
  unichar *buf = objc_malloc(_length + 1);
  CGIUInteger i,j = 0;
  for (i = 0; i < _length; i++) {
    if (_bytes[i] == '%') {
      i++;
      unsigned int b;
      sscanf(&_bytes[i++], "%2x", &b);
      buf[j++] = b;
    } else if (_bytes[i] == '+'){
      buf[j++] = ' ';
    } else buf[j++] = _bytes[i];
  }
  buf[j] = '\0';
  assert(j == strlen(buf));
  return [[[CGISimpleCString alloc] initWithUTF8StringNoCopy:buf length:j freeWhenDone:YES] autorelease];
}

- (CGIArray *)componentsSeparatedByString:(CGIString *)string {
  if (!string)
    @throw @"CGIInvalidArgumentException";
  const unichar *_bytes = [self UTF8String];
  const unichar *delim = [string UTF8String];
  const CGIUInteger delimL = [string lengthOfBytes];
  CGIMutableArray *retval = [[CGIMutableArray alloc] init];
  const unichar *b = _bytes;
  const unichar *c = _bytes;
  while (c = strchrnul(b, delim[0])) {
    if (!strncmp(c,delim,delimL) || *c == 0) {
      [retval addObject:[[[CGISimpleCString alloc] initWithUTF8String:b length:(c - b)] autorelease]];
      if (*c == 0) break;
      b = c + delimL;
    }
  }
  return [retval autorelease];
}

- (CGIString *)substringFromIndex:(CGIUInteger)index {
  if (index >= [self length])
    @throw @"CGIRangeException";
  return [CGIString stringWithUTF8String:[self UTF8String] + index];
}

- (CGIString *)substringWithRange:(CGIRange)range {
  unichar *buf = objc_malloc(range.length + 1);
  buf[range.length] = 0;
  memcpy(buf, [self UTF8String] + range.location, range.length);
  return [CGIString stringWithUTF8String:buf];
}

- (BOOL)hasSuffix:(CGIString *)suffix {
  const CGIUInteger _length = [self lengthOfBytes];
  const CGIUInteger _sufflen = [suffix lengthOfBytes];
  if (_sufflen > _length) return NO;
  const unichar *_bytes = [self UTF8String];
  const unichar *_suffix = [suffix UTF8String];
  return !(strncmp(_suffix, &_bytes[_length - _sufflen], _sufflen));
}

- (id)stringByRemovingSuffix:(CGIString *)suffix {
  if ([self hasSuffix:suffix]) {
    return [[[CGISimpleCString alloc] initWithUTF8String:[self UTF8String] length:[self lengthOfBytes] - [suffix lengthOfBytes]] autorelease];
  } else {
    return [CGIString stringWithString:self];
  }
}

- (BOOL)writeToFile:(CGIString *)filename atomic:(BOOL)flag {
  CGIString *tmpname = [CGIString stringWithFormat:@".%@~", filename];
  FILE *newFile = fopen([tmpname UTF8String], "wb");
  if (!newFile) return NO;
  size_t written = fwrite([self UTF8String], 1, [self lengthOfBytes], newFile);
  if (written != [self lengthOfBytes]) return NO;
  if (rename([tmpname UTF8String], [filename UTF8String]) != 0) return NO;
  return YES;
}

- (void)encodeWithCoder:(CGICoder *)coder {
  [coder encodeString:[self UTF8String]];
}

@end

@implementation CGISimpleCString

- (unichar)characterAtIndex:(CGIUInteger)idx {
  if (idx < _length)
    return _bytes[idx];
  else
    @throw @"CGIOutOfBoundsException";
}

- (CGIUInteger)length {
  return _length;
}

- (id)initWithUTF8String:(const unichar*)cString {
 return [self initWithUTF8String:cString length:strlen(cString)];
}

- (id)initWithUTF8String:(const unichar*)cString length:(CGIUInteger)length {
  self = [super init];
  if (self != nil) {
    _length = length;
    _bytes = malloc(_length + 1);
    memcpy(_bytes, cString, _length);
    _bytes[_length] = 0;
  }
  return self;
}

- (id)initWithContentsOfFile:(CGIString *)path {
  self = [super init];
  if (self != nil) {
    const unichar *pathName = [path UTF8String];
    FILE *fp = fopen(pathName, "rb");
    fseek(fp, 0L, SEEK_END);
    _length = ftell(fp);
    rewind(fp);
    _bytes = malloc(_length + 1);
    fread(_bytes, 1, _length, fp);
    _bytes[_length] = 0;    
    fclose(fp);
  }
  return self;
}

// Length must not include the terminating null byte
- (id)initWithUTF8StringNoCopy:(unichar*)cString length:(CGIUInteger)length freeWhenDone:(BOOL)free{
  self = [super init];
  if (self != nil) {
    _length = length;
    _bytes = cString;
    _bytes[_length] = 0;
  }
  return self;
}

 - (const unichar*)UTF8String {
  return _bytes;
}

- (void)dealloc {
  objc_free(_bytes);
  [super dealloc];
}

@end

@implementation CGIConstantString

- (id)retain {return self;}
- (void)release {}
- (id)autorelease {return self;}
- (id)copy {return self;}

@end

@implementation CGIMutableString

- (CGIString *)classNameForArchiver {
  return @"CGIMutableString";
}

+ (id)alloc
{
  if ([CGIString self] == self)
    return [CGIMutablePlaceholderString alloc];
  else
    return [super alloc];
}

+ (id)string {
  return [[[CGIUTF8String alloc] init] autorelease];
}

+ (id)stringWithString:(CGIString *)string {
  return [CGIUTF8String stringWithString:string];
}

- (id)initWithContentsOfFile:(CGIString *)path {
  @throw @"CGINotImplementedException";
}

- (void)appendString:(CGIString*) string { @throw @"CGIAbstractViolationException"; }

- (void)appendFormat:(CGIString *)format, ... {
  unichar *buf;
  va_list ap;
  va_start(ap, format);
  vasprintf(&buf, [format UTF8String], ap);
  va_end(ap);
  [self appendString:[[[CGIString alloc] initWithUTF8String:buf] autorelease]];
  objc_free(buf);
}

@end

@implementation CGIPlaceholderString

static CGIPlaceholderString *sharedPlaceHolder;

+ (void)initialize {
  if ([CGIPlaceholderString self] == self) sharedPlaceHolder = CGIAllocateObject(self, 0);
}

+ (id)alloc {
    return sharedPlaceHolder;
}

- (id)init {
  return @"";
}

- (id)retain {return self;}
- (void)release {}
- (id)autorelease {return self;}
- (id)copy {return self;}

@end

@implementation CGIMutablePlaceholderString

static CGIMutablePlaceholderString *sharedMutablePlaceholder;

+ (void)initialize {
  if ([CGIMutablePlaceholderString self] == self) sharedMutablePlaceholder = CGIAllocateObject(self,0);
}

+ (id)alloc {
  return sharedMutablePlaceholder;
}

- (id)init {
  return [[CGIUTF8String alloc] init];
}

- (id)retain {return self;}
- (void)release {}
- (id)autorelease {return self;}
- (id)copy {return self;}

@end

@implementation CGIUTF8String

- (id)init {
  self = [super init];
  if (self != nil) {
    _length = 63;
    _bytes = objc_malloc(_length);
    _bytes[0] = '\0';
  }
  return self;
}

- (CGIUInteger)length {
  unsigned char *iter = (unsigned char*)_bytes;
  CGIUInteger retval = 0;
  while (*(iter++) != '\0') {
    if (*iter < 0x80 || *iter > 0xC1)
      retval++;
  }
  return retval;
}

- (const unichar *)UTF8String {
  return _bytes;
}

- (CGIUInteger)lengthOfBytes {
  return strlen(_bytes);
}

- (unichar)characterAtIndex:(CGIUInteger)idx {
  if (idx < _length)
    return _bytes[idx];
  else
    @throw @"CGIOutOfBoundsException";
}

+ (id)stringWithString:(CGIString *)string {
  return [[[self alloc] initWithUTF8String:[string UTF8String] length:[string lengthOfBytes]] autorelease];
}

- (id)initWithUTF8String:(const unichar *)bytes length:(CGIUInteger)length {
  self = [super init];
  if (self != nil) {
    _length = length;
    _bytes = objc_malloc(_length + 1);
    memcpy(_bytes, bytes, _length);
    _bytes[_length] = '\0';
  }
  return self;
}

- (id)initWithUTF8StringNoCopy:(unichar*)cString length:(CGIUInteger)length freeWhenDone:(BOOL)free {
  self = [super init];
  if (self != nil) {
    _length = length;
    _bytes = cString;
    _bytes[_length] = 0;
  }
  return self;
}

- (unichar *)UTF8CharacterAtIndex:(CGIUInteger)index {
  CGIUInteger i;
  unsigned char *iter = (unsigned char*)_bytes;
  for (i = 0; i < index; i++,iter++) {
    if (*iter == 0x00u)
      @throw @"CGIOutOfBoundsException";
    else if (*iter < 0x80u)
      continue;
    else if ((*iter & 0xE0u) == 0xC0)
      iter += 1;
    else if ((*iter & 0xF0u) == 0xE0)
      iter += 2;
    else if ((*iter & 0xF8) == 0xF0)
      iter += 3;
    else
      @throw @"CGIInvalidUTF8Exception";
  }
  unichar *retval = objc_malloc(5);

  if (*iter < 0x80u) {
    *retval = *iter;
    retval[1] = '\0';
  } else if ((*iter & 0xE0) == 0xC0) {
    memcpy(retval, iter, 2);
    retval[2] = '\0';
  } else if ((*iter & 0xF0) == 0xE0) {
    memcpy(retval, iter, 3);
    retval[3] = '\0';
  } else if ((*iter & 0xF8) == 0xF0) {
    memcpy(retval, iter, 4);
    retval[4] = '\0';
  } else
    @throw @"CGIInvalidUTF8Exception";
  return retval;
}

- (void)dealloc {
  objc_free(_bytes);
  [super dealloc];
}

- (void)appendString:(CGIString *)aString {
  CGIUInteger len = [self lengthOfBytes] + [aString lengthOfBytes];
  if (len + 1 >= _length) {
    _length = len + 31;
    _bytes = objc_realloc(_bytes, _length);
    if (_bytes == NULL)
      @throw @"CGIOutOfMemoryException";
  }
  
  memcpy(&_bytes[[self lengthOfBytes]], [aString UTF8String], [aString lengthOfBytes]);
  _bytes[len] = '\0';
}

@end



// @implementation CGIString
// 
// - (id)initWithContentsOfFile:(CGIString *)fileName {
//   self = [super init];
//   if (self != nil) {
//     char *fname = [fileName cString];
//     FILE *fp = fopen(fname, "rb");
//     fseek(fp, 0, SEEK_END);
//     _length = ftell(fp);
//     rewind(fp);
//     _bytes = malloc(_length + 1);
//     fread(_bytes, 1, _length, fp);
//     fclose(fp);
//     free(fname);
//   }
//   return self;
// }
// // // 
// - (BOOL)writeToFile:(CGIString*)fileName atomically:(BOOL)flag {
//   unichar *fname, *tfname;
//   fname = [fileName cString];
//   if (flag && access(fname, W_OK) != -1) {
//     asprintf(&tfname, ".~%s", fname);
//   } else {
//     tfname = fname;
//   }
//   
//   FILE *fp;
//   fp = fopen(tfname, "wb");
//   fwrite(_bytes, 1, _length, fp);
//   fclose(fp);
//   
//   if (tfname != fname) {
//     rename(tfname,fname);
//     free(tfname);
//   }
//   free(fname);
//   return YES;
// }
// 
// @end
