#import "CGIKit/CGIKit.h"
#import "stdio.h"
#import <stdlib.h>

int main () {
  CGILog(@"Test");
  
  @try {
    CGIKitTest_Array();
    CGIKitTest_String();
    CGIKitTest_Archiver();
    CGIKitTest_DBI();
    CGIKitTest_Result();
  }
  @catch (id e) {
    fprintf(stderr, "Terminating due to uncaught exception: %@\n", e);
    exit(1);
  }
  
  return 0;
}
