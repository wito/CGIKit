#import "CGIKit/CGIView.h"

#import "CGIKit/CGIString.h"
#import "CGIKit/CGIArray.h"

@implementation CGIView

- (CGIString *)elementName {
  return elementName;
}

- (id)init {
  return [self initWithElementName:@"div"];
}

- (id)initWithElementName:(CGIString *)element {
  self = [super init];
  if (self) {
    elementName = [element copy];
    subviews = [[CGIMutableArray alloc] init];
  }
  return self;
}

- (CGIString *)render {
  CGIMutableString *retval = [CGIMutableString string];
  
  [retval appendFormat:@"<%@", elementName];

  if (elementID) {
    [retval appendFormat:@" id=\"%@\"", elementID];
  }
  
  [retval appendString:@">"];
  
  CGIUInteger i;
  for (i = 0; i < [subviews count]; i++) {
    [retval appendString:[[subviews objectAtIndex:i] render]];
  }
  
  [retval appendFormat:@"</%@>", elementName];
  
  return retval;
}

@end
