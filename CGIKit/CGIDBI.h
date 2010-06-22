#import "CGIKit/CGIObject.h"

@class CGIString;
@class CGIDictionary;

@interface CGIDBI : CGIObject {
  
}

- (id)initWithDatabase:(CGIString *)dsn;

- (BOOL)connect;
- (void)close;

- (CGIUInteger)doQuery:(CGIDictionary *)query modalDelegate:(id)delegate;

@end
