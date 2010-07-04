#import "CGIKit/CGIObject.h"
#import "CGIKit/CGIDBIQueryDelegate.h"

@class CGIDictionary;
@class CGIString;
@class CGIArray;

extern CGIString *CGIDBIQueryStringKey;
extern CGIString *CGIDBIQueryDataKey;

typedef enum {
  CGIDBINoAction = 0,
  CGIDBIRollback = 1,
  CGIDBIAbort = 2,
  CGIDBIFail = 3,
  CGIDBIIgnore = 4,
  CGIDBIReplace = 5
} CGIDBIOnConflictClause;

@interface CGIDBI : CGIObject {
  
}

- (id)initWithDatabase:(CGIString *)dsn;

- (BOOL)connect;
- (void)close;

- (CGIUInteger)doQuery:(CGIDictionary *)query modalDelegate:(id<CGIDBIQueryDelegate>)delegate;

- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table modalDelegate:(id<CGIDBIQueryDelegate>)delegate;
- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table properties:(CGIDictionary *)properties modalDelegate:(id<CGIDBIQueryDelegate>)delegate;

- (CGIUInteger)insert:(CGIArray *)columns values:(CGIArray *)values table:(CGIString *)table;
- (CGIUInteger)insert:(CGIArray *)columns values:(CGIArray *)values table:(CGIString *)table onConflict:(CGIDBIOnConflictClause)action;
- (CGIUInteger)insert:(CGIArray *)columns table:(CGIString *)table fromQuery:(CGIDictionary *)query;

- (CGIUInteger)deleteFromTable:(CGIString *)table where:(CGIDictionary *)query;

- (CGIUInteger)updateTable:(CGIString *)table set:(CGIDictionary *)updates where:(CGIDictionary *)query;
- (CGIUInteger)updateTable:(CGIString *)table set:(CGIDictionary *)updates where:(CGIDictionary *)query onConflict:(CGIDBIOnConflictClause)action;

@end
