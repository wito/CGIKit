#import "CGIKit/CGIObject.h"
#import "CGIKit/CGIDBIQueryDelegate.h"

@class CGIString;
@class CGIDictionary;

@interface CGIDBI : CGIObject {
  
}

- (id)initWithDatabase:(CGIString *)dsn;

- (BOOL)connect;
- (void)close;

- (CGIUInteger)doQuery:(CGIDictionary *)query modalDelegate:(id<CGIDBIQueryDelegate>)delegate;

@end
