#import "CGIKit/CGIKit.h"
#include <stdio.h>

int CGIKitTest_Array () {

  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  CGIArray *anArray = [[CGIArray alloc] initWithObjects:@"Peter", @"Frank", @"Tom", nil];
  printf("%s\n", [[anArray description] UTF8String]);
  CGIArray *anotherArray = [[CGIArray alloc] initWithObjects:@"Pan", [anArray autorelease], nil];
  printf("%s\n", [[anotherArray description] UTF8String]);
  [anotherArray release];
  
  CGIMutableArray *yana = [[CGIMutableArray alloc] initWithObject:@"Alice"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Bob"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Carl"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Diane"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Elizabeth \xC2\xA9"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Fred"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana insertObject:@"Gregory" atIndex:2];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Hannelore"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana addObject:@"Ida"];
  printf("%s\n", [[yana description] UTF8String]);
  [yana removeObjectAtIndex:1];
  printf("%s\n", [[yana description] UTF8String]);
  
  [pool release];
  
  return 0;
}
