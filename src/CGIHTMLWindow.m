#include "CGIKit/CGIHTMLWindow.h"
#include "CGIKit/CGIString.h"

#include "CGIKit/CGIView.h"

@implementation CGIHTMLWindow

- (id)initWithTitle:(CGIString *)tval {
  self = [super init];
  if (self) {
    [self setTitle:tval];
  }
  return self;
}

- (CGIString *)title {
  return [[title copy] autorelease];
}

- (void)setTitle:(CGIString *)value {
  [title release];
  title = [value copy];
}

- (CGIString *)render {
  return [self renderInContext:nil];
}

- (CGIString *)renderInContext:(id)ctx {
  return [CGIString stringWithFormat:@"<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title>%@</title></head>%@</html>", title, [contentView renderInContext:ctx]];
}

- (CGIView *)contentView {
  return contentView;
}

- (void)setContentView:(CGIView *)value {
  [contentView release];
  contentView = [value retain];
}

- (void)dealloc {
  [title release];
  [contentView release];
  
  [super dealloc];
}

@end
