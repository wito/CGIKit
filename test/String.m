#include "CGIKit/CGIKit.h"
#include <stdio.h>
#include <string.h>

int CGIKitTest_String () {

  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  CGIUTF8String *aString = [CGIUTF8String stringWithString:@"Copyright \xC2\xA9"];
  printf("%lu, %lu, %lu\n", [aString length], [aString lengthOfBytes], strlen([aString UTF8String]));
  
  printf("%s\n", [aString UTF8CharacterAtIndex:10]);
  
  [aString appendString:@" 2009 Williham Totland\nThis is additionally a very, very long string (relatively speaking).\n\nIf you want more information on exactly how long it is, keep reading. It's really long, you see."];
  printf("%@\n", aString);
  
  aString = [CGIUTF8String stringWithString:@"Test string 2"];
  [aString appendFormat:@" %d", 2009];
  printf("%@\n", aString);
  
  printf("%@\n", [@"<test>This's an \"XML-escaped\" test string & test.</test>" XMLEscapedString]);

  printf("%@\n", [[@"This is an URL-escaped string, \xC2\xA9 2009 Williham Totland" URLEncodedString] URLDecodedString]);
  printf("%d\n", [@"HasSuffix" hasSuffix:@"Sufffix"]);
  printf("%@\n", [@"f=x&y=b" componentsSeparatedByString:@"&"]);
  
  //[aString writeToFile:@"stringtest.txt" atomic:YES];
  
  [pool release];


  return 0;
}
