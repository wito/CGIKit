#import "CGIKit/CGIKitTypes.h"

@class CGIView;
@class CGITextView;
@class CGIListView;
@class CGIString;
@class CGIArray;

@protocol CGIViewDataSource

- (CGIString *)elementNameForView:(CGIView *)view inContext:(id)context;
- (CGIString *)elementIDForView:(CGIView *)view inContext:(id)context;
- (CGIArray *)classesForView:(CGIView *)view inContext:(id)context;

@end

@protocol CGITextViewDataSource <CGIViewDataSource>

- (CGIString *)contentForView:(CGITextView *)textView inContext:(id)context;

@end

@protocol CGIListViewDataSource <CGIViewDataSource>

- (CGIUInteger)numberOfRowsInListView:(CGIListView *)listView context:(id)context;
- (CGIString *)listView:(CGIListView *)listView contentForRow:(CGIUInteger)index context:(id)context;

@end
