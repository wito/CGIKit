#import "CGIObject.h"
#import "CGIDBIQueryDelegate.h"

@class CGIDBI;
@class CGIString;
@class CGIArray;
@class CGIDictionary;

typedef enum {
  CGIInStorage = -1,
  CGISynchronized = 0,
  CGIInMemory = 1
} CGISynchronizationStatus;

@interface CGIResult : CGIObject <CGIDBIQueryDelegate> {
  CGIDBI *_database;
  CGIString *_table;
  CGIDictionary *_query;
  CGIArray *_columns;
  Class _rsClass;
  
  CGISynchronizationStatus _status;
}

- (id)initWithDatabase:(CGIDBI *)database data:(CGIDictionary *)data;
- (id)initWithDatabase:(CGIDBI *)database query:(CGIDictionary *)query;

- (CGIString *)table;

- (CGIDictionary *)columns;
- (void)setColumns:(CGIDictionary *)columns;

- (id)columnValue:(CGIString *)col;
- (void)setValue:(id)value forColumn:(CGIString *)col;

- (id)update;
- (id)update:(CGIDictionary *)data;
- (id)synchronize;

@end

@interface CGIResultSet : CGIObject <CGIDBIQueryDelegate> {
  CGIDBI *_database;
  CGIString *_table;
  CGIDictionary *_query;
  Class _resultClass;
  
  CGIArray *_results;
  CGIUInteger _count;
}

- (id)initWithDatabase:(CGIDBI *)database query:(CGIDictionary *)query;

- (CGIArray *)all;
- (CGIResultSet *)search:(CGIDictionary *)query;

- (Class)resultClass;
- (CGIString *)table;

- (CGIResult *)create:(CGIDictionary *)data;

@end
