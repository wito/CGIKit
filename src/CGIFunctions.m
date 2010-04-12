/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */
/* CGIFunctions.m */

/* Portions (CGIRangeFunctions) Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.*/
#import "CGIKit/CGIFunctions.h"
#include <stdio.h>
#include <printf.h>
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIXMLParser.h"
#import "CGIKit/CGIPropertyList.h"
#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIAutoreleasePool.h"
#import <objc/objc-api.h>

CGIRange CGIMakeRange (CGIUInteger loc, CGIUInteger len) {
  CGIRange r;
  r.location = loc;
  r.length = len;
  return r;
}

BOOL CGIEqualRanges(CGIRange range, CGIRange otherRange) {
   return (range.location == otherRange.location && range.length == otherRange.length);
}

CGIUInteger CGIMaxRange(CGIRange range){
   return range.location + range.length;
}


BOOL CGILocationInRange(CGIInteger location,CGIRange range){
   return (location >= range.location && location < CGIMaxRange(range))?YES:NO;
}


int CGIKitArgInfoFunction (const struct printf_info *info, size_t n, int *argtypes) {
  if (n > 0)
    argtypes[0] = PA_POINTER;
  return 1;
}

int CGIKitPrintFunction (FILE *stream, const struct printf_info *info, const void *const *args) {
  id self;
  CGIString *buffer;
  int len;
  self = *((id *) (args[0]));
  buffer = [self description];
  len = fprintf (stream, "%*s", (info->left ? -info->width : info->width), [buffer UTF8String]);
  return len;
}

__attribute__((constructor)) CGIKitLoadLibrary() {
  register_printf_function('@', CGIKitPrintFunction, CGIKitArgInfoFunction);
}

BOOL CGIWritePropertyList (id<CGIPropertyListObject> root, CGIString *filename) {
  CGIString *plistData = [CGIString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n%@\n</plist>\n", [root XMLRepresentation]];
  return [plistData writeToFile:filename atomic:YES];
}

#define ARRAY_CTXT 1
#define STRING_CTXT 2
#define DICT_CTXT 3
#define KEY_CTXT 4
#define PLIST_CTXT 5

@interface CGIPropertyListDeserializer : CGIObject {
  CGIXMLParser *xmlParser;
  id *context;
  CGIUInteger *cntxt;
  CGIString *key;
  id value;
  CGIUTF8String *buf;
  id<CGIPropertyListObject> root;
}

- (id<CGIPropertyListObject>)parseXMLPropertyList:(CGIString *)xmlString;

@end

@implementation CGIPropertyListDeserializer

- (id)init {
  self = [super init];
  if (self != nil) {
    context = objc_calloc(15, sizeof(id));
    cntxt = objc_calloc(15, sizeof(CGIUInteger));
    [CGIAutoreleasePool addMemoryBlockToPool:context];
    [CGIAutoreleasePool addMemoryBlockToPool:cntxt];
    cntxt++;
    context++;
  }
  return self;
}

- (id<CGIPropertyListObject>)parseXMLPropertyList:(CGIString *)xmlString {
  xmlParser = [[CGIXMLParser alloc] initWithXMLString:xmlString];
  [xmlParser setDelegate:self];
  [xmlParser parse];
  return root;
}

- (void)parser:(CGIXMLParser *)parser didStartElement:(CGIString *)elementName namespaceURI:(CGIString *)namespaceURI qualifiedName:(CGIString *)qualifiedName attributes:(CGIDictionary *)attributeDict {
  if ([elementName isEqualToString:@"array"]) {
    *context = [[CGIMutableArray alloc] init];
    *cntxt = ARRAY_CTXT;
    context++, cntxt++;
  } else if ([elementName isEqualToString:@"string"]) {
    buf = [[CGIUTF8String alloc] init];
    context++, *cntxt = STRING_CTXT, cntxt++; return;
  } else if ([elementName isEqualToString:@"dict"]) {
    *context = [[CGIMutableDictionary alloc] init]; context++;
    *cntxt = DICT_CTXT; cntxt++;
  } else if ([elementName isEqualToString:@"key"]) {
    buf = [[CGIUTF8String alloc] init];
    context++, *cntxt = KEY_CTXT, cntxt++; return;
  } else if ([elementName isEqualToString:@"plist"]) {
    *context++, *cntxt = PLIST_CTXT, cntxt++; return;
  } else @throw @"CGIKitNotImplementedException";
  
  switch (cntxt[-2]) {
  case PLIST_CTXT:
    root = context[-1];
    break;
  case DICT_CTXT:
    [context[-2] setObject:context[-1] forKey:key];
    break;
  case ARRAY_CTXT:
    [context[-2] addObject:context[-1]];
    break;
  default:
    @throw @"CGIInvalidPropertyListException";
  }
}

- (void)parser:(CGIXMLParser *)parser didEndElement:(CGIString *)elementName namespaceURI:(CGIString *)namespaceURI qualifiedName:(CGIString *)qName {
  if ([elementName isEqualToString:@"array"]) {
    context--;
    cntxt--;
    return;
  } else if ([elementName isEqualToString:@"string"]) {
    *context = [CGIString stringWithString:buf], context--; cntxt--;
  } else if ([elementName isEqualToString:@"dict"]) {
    context--,cntxt--;
    return;
  } else if ([elementName isEqualToString:@"key"]) {
    key = [[CGIString stringWithString:buf] autorelease];
    context--,cntxt--;
    return;
  } else if ([elementName isEqualToString:@"plist"]) {
    context--,cntxt--;
    return;
  } else @throw @"CGIKitNotImplementedException";

  switch (cntxt[-1]) {
  case DICT_CTXT:
    [context[-1] setObject:context[1] forKey:key];
    break;
  case ARRAY_CTXT:
    [context[-1] addObject:context[1]];
    break;
  default:
    @throw @"CGIInvalidPropertyListException";
  }
}

- (void)parser:(CGIXMLParser *)parser foundCharacters:(CGIString *)string {
  [buf appendString:string];
}

- (void)parserDidStartDocument:(CGIXMLParser *)parser { }
- (void)parserDidEndDocument:(CGIXMLParser *)parser { }


@end

id<CGIPropertyListObject> CGIReadPropertyList (CGIString *data) {
  return [[[CGIPropertyListDeserializer alloc] init] parseXMLPropertyList:data];
}

