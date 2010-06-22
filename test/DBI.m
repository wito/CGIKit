#import "CGIKit/CGIKit.h"
#include <stdio.h>

int CGIKitTest_DBI () {

  // CGIDBI
  
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  CGIDBI *dbi = [[CGIDBI alloc] initWithDatabase:@"dbi:SQLite:test/test.db"];
  
  [dbi connect];
  
  [dbi close];
  
  [pool release];
  
  return 0;
}
