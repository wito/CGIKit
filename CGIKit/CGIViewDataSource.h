@class CGIView;
@class CGITextView;

@protocol CGIViewDataSource

- (CGIString *)elementNameForView:(CGIView *) inContext:(id)context;
- (CGIString *)elementIDForView:(CGIView *) inContext:(id)context;
- (CGIString *)classesForView:(CGIView *) inContext:(id)context;

@end

@protocol CGITextViewDataSource <CGIViewDataSource>

- (CGIString *)contentForView:(CGITextView *) inContext:(id)context;

@end

