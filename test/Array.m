#import "CGIKit/CGIKit.h"
#include <stdio.h>

int CGIKitTest_Array () {

  // CGIArray
  
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  CGIArray *anArray = [[CGIArray alloc] initWithObjects:@"Peter", @"Frank", @"Tom", nil];
  printf("%s, %ld\n", [[anArray description] UTF8String], [anArray count]);
  CGIArray *anotherArray = [[CGIArray alloc] initWithObjects:@"Pan", [anArray autorelease], nil];
  printf("%s, %ld\n", [[anotherArray description] UTF8String], [anArray count]);
  [anotherArray release];
  
  [CGIArray arrayWithObject:@"Boom!"];
  printf("%ld\n", [[[[CGIArray alloc] initWithObject:@"Bang!"] autorelease] indexOfObjectIdenticalTo:@"Bang!"]);
  
  id fakeArray[] = { @"Voom!", @"Wham!" };
  [[[CGIArray alloc] initWithObjects:fakeArray count:2] autorelease];
  
  // CGIMutableArray
  
  CGIMutableArray *yana = [[CGIMutableArray alloc] initWithObject:@"Alice"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Bob"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Carl"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Diane"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Elizabeth \xC2\xA9"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Fred"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana insertObject:@"Gregory" atIndex:2];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Hannelore"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana addObject:@"Ida"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana removeObjectAtIndex:1];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  
  [yana addObject:@"Hannelore"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana removeObjectIdenticalTo:@"Hannelore"];
  printf("%s, %ld\n", [[yana description] UTF8String], [yana count]);
  [yana release];
  
  yana = [CGIMutableArray arrayWithObject:@"Shoop!"];
  yana = [[[CGIMutableArray alloc] initWithObjects:fakeArray count:2] autorelease];
  yana = [[[CGIMutableArray alloc] initWithObject:@"Woop!"] autorelease];
  yana = [[[CGIMutableArray alloc] initWithObjects:@"Doom", @"Death", nil] autorelease];
  
  CGIArray *archivableArray = [[[CGIArray alloc] initWithObjects:@"Archived!", @"Fo sho'", nil] autorelease];
  CGIData *archivedData = [CGIArchiver archivedDataWithRootObject:archivableArray];
  printf("Data: %@\n", [archivedData plistRepresentation]);
  
  archivableArray = [[CGIUnarchiver unarchiveObjectWithData:archivedData] autorelease];
  printf("%s\n", [archivableArray class]->name);
  printf("%@\n", archivableArray);
  
  [pool release];
  
  return 0;
}
