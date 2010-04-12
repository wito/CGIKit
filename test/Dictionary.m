#import "CGIKit/CGIKit.h"
#include <stdio.h>

int main () {
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  CGIDictionary *aDictionary = [[CGIMutableDictionary alloc] init];
  [aDictionary setObject:@"Peter" forKey:@"Pan"];
  [aDictionary setObject:@"Captain" forKey:@"Hook"];
  [aDictionary setObject:@"Mary" forKey:@"Poppins"];
  [aDictionary setObject:@"John" forKey:@"Travolta"];
  [aDictionary setObject:@"Samuel" forKey:@"Jackson"];
  [aDictionary setObject:@"Eric" forKey:@"Foreman"];
  [aDictionary setObject:@"Timmy" forKey:@"Cricket"];
  [aDictionary setObject:@"Led" forKey:@"Zeppelin"];
  [aDictionary setObject:@"Lord" forKey:@"Crumplebottom"];
  [aDictionary setObject:@"Ice" forKey:@"T"];
  [aDictionary setObject:@"Wu-Tang" forKey:[CGISimpleCString stringWithString:@"T"]];
  printf("%@\n",aDictionary);
  [pool release];
  return 0;
}
