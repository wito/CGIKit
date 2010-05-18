#import "CGIKit/CGIKit.h"
#import "stdio.h"

int main () {
  @try {
    CGIKitTest_Array();
    CGIKitTest_String();
  }
  @catch (id e) {
    fprintf(stderr, "Terminating due to uncaught exception: %@\n", e);
    exit(1);
  }
  
  return 0;
}
