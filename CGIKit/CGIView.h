#import "CGIKit/CGIObject.h"
#import "CGIKit/CGIViewDataSource.h"

@class CGIArray;
@class CGIString;

@interface CGIView : CGIObject {
  CGIView *superview;
  id dataSource;
  id delegate;
  
  CGIUInteger tag;

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

- (id)dataSource;
- (void)setDataSource:(id)delegate;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (CGIUInteger)tag;
- (void)setTag:(CGIUInteger)tag;

- (void)removeFromSuperview;

- (CGIString *)render;
- (CGIString *)renderInContext:(id)context;

@end

@interface CGITextView : CGIView {
  CGIString *content;
}

- (id)initWithElementName:(CGIString *)htmlElement content:(CGIString *)content;

- (CGIString *)content;
- (void)setContent:(CGIString *)content;

- (CGIString *)renderWithContent:(CGIString *)content;
- (CGIString *)renderWithContent:(CGIString *)content inContext:(id)context;

@end

@interface CGIListView : CGIView <CGITextViewDataSource> {
  CGITextView *contentCell;
}

- (CGITextView *)contentCell;
- (void)setContentCell:(CGITextView *)contentCell;

@end

@interface CGITableRowView : CGIView {

}

- (CGIString *)renderWithRepresentedObject:(id)object;
- (CGIString *)renderWithRepresentedObject:(id)object inContext:(id)context;

@end

@interface CGITableView : CGIView {
  CGITableRowView *contentCell;
}

- (CGITableRowView *)contentCell;
- (void)setContentCell:(CGITableRowView *)contentCell;

@end
