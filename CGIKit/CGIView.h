#import "CGIKit/CGIObject.h"

@class CGIArray;
@class CGIString;

@interface CGIView : CGIObject {
  CGIString *elementName;
  CGIString *elementID;
  CGIArray  *classes;
  CGIArray  *subviews;
}

- (id)initWithElementName:(CGIString *)htmlElement;

- (void)addSubview:(CGIView *)subview;

- (CGIString *)render;

@end

@interface CGITextView : CGIView {
  CGIString *content;
}

- (id)initWithElementName:(CGIString *)htmlElement content:(CGIString *)content;

- (CGIString *)content;
- (void)setContent:(CGIString *)content;

@end
