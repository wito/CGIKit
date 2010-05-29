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

- (CGIString *)render;

@end
