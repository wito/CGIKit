#import "CGIKit/CGIObject.h"

@class CGIString;
@class CGIArray;

@interface CGIHTMLWindow : CGIObject {
  CGIString *title;
  id contentView;
}

- (id)initWithTitle:(CGIString *)title;

- (CGIString *)title;
- (void)setTitle:(CGIString *)title;

- (CGIString *)render;

@end
