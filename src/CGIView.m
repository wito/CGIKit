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

- (CGIView *)superview {
  return superview;
}

- (void)setSuperview:(CGIView *)view {
  superview = view;
}

- (void)addSubview:(CGIView *)subview {
  [(CGIMutableArray *)subviews addObject:subview];
  [subview setSuperview:self];
}

- (void)removeSubview:(CGIView *)subview {
  [(CGIMutableArray *)subviews removeObjectIdenticalTo:subview];
  [subview setSuperview:nil];
}

- (void)removeFromSuperview {
  [superview removeSubview:self];
}

- (CGIString *)render {
  return [self renderInContext:nil];
}

- (CGIString *)renderInContext:(id)ctx {
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

- (void)dealloc {
  [elementName release];
  [subviews release];
  
  [dataSource release];
  [delegate release];
  
  [super dealloc];
}

- (id)dataSource {
  return dataSource;
}

- (void)setDataSource:ds {
  [dataSource release];
  dataSource = [ds retain];
}

- (id)delegate {
  return delegate;
}

- (void)setDelegate:dg {
  [delegate release];
  delegate = [dg retain];
}

- (CGIUInteger)tag { return tag; }
- (void)setTag:(CGIUInteger)newTag { tag = newTag; }

@end

@implementation CGITextView

- (id)initWithElementName:(CGIString *)htmlElement content:(CGIString *)cval {
  self = [super initWithElementName:htmlElement];
  if (self) {
    [self setContent:cval];
  }
  return self;
}

- (CGIString *)content {
  return [[content copy] autorelease];
}

- (void)setContent:(CGIString *)cval {
  [content release];
  content = [cval copy];
}

- (CGIString *)renderInContext:(id)ctx {
  CGIMutableString *retval = [CGIMutableString string];
  
  [retval appendFormat:@"<%@", elementName];

  if (elementID) {
    [retval appendFormat:@" id=\"%@\"", elementID];
  }
  
  [retval appendString:@">"];
  
  if (content) {
    [retval appendString:content];
  } else {
    if (dataSource) {
      [retval appendString:[dataSource contentForView:self inContext:ctx]];
    } else {
      CGIUInteger i;
      for (i = 0; i < [subviews count]; i++) {
        [retval appendString:[[subviews objectAtIndex:i] render]];
      }
    }
  }
  
  [retval appendFormat:@"</%@>", elementName];
  
  return retval;
}

@end

@implementation CGIListView

- (id)init {
  return [self initWithElementName:@"ul"];
}

- (id)initWithElementName:(CGIString *)htmlElement {
  self = [super initWithElementName:htmlElement];
  if (self != nil) {
    contentCell = [[CGITextView alloc] initWithElementName:@"li"];
    [contentCell setDataSource:self];
  }
  return self;
}

- (CGITextView *)contentCell {
  return contentCell;
}

- (void)setContentCell:(CGITextView *)newCS {
  [contentCell release];
  contentCell = [newCS retain];
  [contentCell setDataSource:self];
}

- (CGIArray *)classesForView:(CGIView *)cell inContext:(id)ctx {
  return nil;
}

- (CGIString *)elementIDForView:(CGIView *)cell inContext:(id)ctx {
  return nil;
}

- (CGIString *)elementNameForView:(CGIView *)cell inContext:(id)ctx {
  return @"li";
}

- (CGIString *)contentForView:(CGITextView *)cell inContext:(id)ctx {
  void **context = (void **)ctx;
  
  id ctxt = context[0];
  CGIUInteger *i = context[1];
  
  return [dataSource listView:self contentForRow:*i context:ctxt];
}

- (CGIString *)renderInContext:(id)ctx {
  CGIMutableString *retval = [CGIMutableString string];
  
  [retval appendFormat:@"<%@", elementName];

  if (elementID) {
    [retval appendFormat:@" id=\"%@\"", elementID];
  }
  
  [retval appendString:@">"];
  
  CGIUInteger c = [dataSource numberOfRowsInListView:self context:ctx];
  CGIUInteger i;
  
  void *context[2] = {ctx,&i};
  
  for (i = 0; i < c; i++) {
    [retval appendString:[contentCell renderInContext:(id)context]];
  }
  
  [retval appendFormat:@"</%@>", elementName];
  
  return retval;
}

- (void)dealloc {
  [contentCell release];
  [super dealloc];
}

@end

