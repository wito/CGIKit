#import "CGIKit/CGIObject.h"

@class CGIArray;
@class CGIString;

@interface CGIView : CGIObject {
  CGIView *superview;
  id *dataSource;
  id *delegate;

  CGIString *elementName;
  CGIString *elementID;
  CGIArray  *classes;
  CGIArray  *subviews;  
}

- (id)initWithElementName:(CGIString *)htmlElement;

- (CGIView *)superview;
- (void)setSuperview:(CGIView *)superview;
- (void)addSubview:(CGIView *)subview;
- (void)removeSubview:(CGIView *)subview;

- (void)removeFromSuperview;

- (CGIString *)render;

@end

@interface CGITextView : CGIView {
  CGIString *content;
}

- (id)initWithElementName:(CGIString *)htmlElement content:(CGIString *)content;

- (CGIString *)content;
- (void)setContent:(CGIString *)content;

@end
