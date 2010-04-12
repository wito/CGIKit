#include "CGIKit/CGIKit.h"
#include <stdio.h>
#include <string.h>

int main () {
  printf("Content-type: text/plain;charset=utf-8\n");
  printf("Set-Cookie: BOMB=setUp\n");
  printf("Set-Cookie: SESSID=12345ABCDE\n\n");
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  CGIParameters *parameters = [[CGIParameters alloc] init];
  printf("%@\n", [parameters parameters]);
  printf("%@\n", [parameters server]);
  [parameters release];
  [pool release];
  return 0;
}
