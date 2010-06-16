#import "CGIKit/CGIObject.h"

@class CGIString;
@class CGIArray;
@class CGIView;

@interface CGIHTMLWindow : CGIObject {
  CGIString *title;
  CGIView *contentView;
}

- (id)initWithTitle:(CGIString *)title;

- (CGIString *)title;
- (void)setTitle:(CGIString *)title;

- (CGIView *)contentView;
- (void)setContentView:(CGIView *)value;

- (CGIString *)render;
- (CGIString *)renderInContext:(id)context;

@end
