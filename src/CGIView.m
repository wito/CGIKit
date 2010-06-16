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

- (CGIString *)render {
  CGIMutableString *retval = [CGIMutableString string];
  
  [retval appendFormat:@"<%@", elementName];

  if (elementID) {
    [retval appendFormat:@" id=\"%@\"", elementID];
  }
  
  [retval appendString:@">"];
  
  if (content) {
    [retval appendString:content];
  } else {
    CGIUInteger i;
    for (i = 0; i < [subviews count]; i++) {
      [retval appendString:[[subviews objectAtIndex:i] render]];
    }
  }
  
  [retval appendFormat:@"</%@>", elementName];
  
  return retval;
}

@end
