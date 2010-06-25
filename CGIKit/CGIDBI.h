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

- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table modalDelegate:(id<CGIDBIQueryDelegate>)delegate;
- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table properties:(CGIDictionary *)properties modalDelegate:(id<CGIDBIQueryDelegate>)delegate;

@end
