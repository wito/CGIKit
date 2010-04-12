#include "CGIKit/CGIKit.h"
#include <stdio.h>
#include <string.h>

int main () {

  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  
  
  //[[[CGIXMLParser alloc] initWithXMLString:@"<xmlElement></xmlElement>"] parse];
  //[aString writeToFile:@"stringtest.txt" atomic:YES];
  printf("%@\n", CGIReadPropertyList (@"<plist><array><string>Hello</string><dict><key>Hello</key><string>World</string></dict></array></plist>"));

  [pool release];


  return 0;
}
