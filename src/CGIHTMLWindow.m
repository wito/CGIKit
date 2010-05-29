#include "CGIKit/CGIHTMLWindow.h"
#include "CGIKit/CGIString.h"

@implementation CGIHTMLWindow

- (id)initWithTitle:(CGIString *)tval {
  self = [super init];
  if (self) {
    [self setTitle:tval];
  }
  return self;
}

- (CGIString *)title {
  return [title copy];
}

- (void)setTitle:(CGIString *)value {
  [title release];
  title = [value copy];
}

- (CGIString *)render {
  return [CGIString stringWithFormat:@"<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title>%@</title></head><body></body></html>"];
}

@end
