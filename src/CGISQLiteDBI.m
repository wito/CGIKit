#import "CGIKit/CGIDBI.h"
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIData.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGINumber.h"

#include <sqlite3.h>

CGIString *CGIDBIQueryStringKey = @"CGIDBIQueryStringKeyName";
CGIString *CGIDBIQueryDataKey = @"CGIDBIQueryDataKeyName";

@interface CGISQLiteDBI : CGIDBI {
  sqlite3 *handle;
  CGIString *path;
}

@end

@implementation CGISQLiteDBI

- (id)initWithDatabase:(CGIString *)dsn {
  self = [super init];
  if (self != nil) {
    handle = NULL;
    path = [[dsn componentsSeparatedByString:@":"] objectAtIndex:2];
  }
  return self;
}

- (BOOL)connect {
  int ret = sqlite3_open_v2([path UTF8String], &handle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL);
  if (handle) {
    sqlite3_exec(handle, "PRAGMA foreign_keys = ON;", NULL, NULL, NULL);
  }
  return !ret;
}

- (void)close {
  sqlite3_close(handle);
  handle = NULL;
}

- (CGIUInteger)doQuery:(CGIDictionary *)query modalDelegate:(id <CGIDBIQueryDelegate>)delegate {
  CGIString *sql = [query objectForKey:CGIDBIQueryStringKey];
  const char *zSql = [sql UTF8String];
  CGIArray *data = [query objectForKey:CGIDBIQueryDataKey];
  CGIUInteger parameterCount = [data count];
  
  sqlite3_stmt *statement;
  sqlite3_prepare_v2(handle, zSql, -1, &statement, NULL);
  
  CGIUInteger i;
  for (i = 1; i <= parameterCount; i++) {
    id parameter = [data objectAtIndex:i - 1];
    
    if ([parameter isKindOfClass:[CGIString self]]) {
      sqlite3_bind_text(statement, i, [parameter UTF8String], -1, SQLITE_STATIC);
    } else if ([parameter isKindOfClass:[CGIData self]]) {
      sqlite3_bind_blob(statement, i, [parameter bytes], [parameter length], SQLITE_STATIC);
    } else if ([parameter isKindOfClass:[CGINumber self]]) {
      sqlite3_bind_int64(statement, i, [parameter integerValue]);
    }
  }
  
  CGIUInteger retcol = sqlite3_column_count(statement);
  CGIMutableArray *colnames = [CGIMutableArray array];
  
  CGIUInteger j;
  
  for (j = 0; j < retcol; j++) {
    const unichar *colname = sqlite3_column_name(statement, j);
    CGIString *columnName = [CGIString stringWithUTF8String:colname];
    const unichar *tablename = sqlite3_column_table_name(statement, j);
    CGIString *tableName = [CGIString stringWithUTF8String:tablename];
    [colnames addObject:[CGIString stringWithFormat:@"%@.%@", tableName, columnName]];
  }
  
  printf("\"%s\" : %@\n", zSql, data);
  
  i = 0;
  while (sqlite3_step(statement) == SQLITE_ROW) {
    CGIMutableArray *row = [[[CGIMutableArray alloc] init] autorelease];
    i++;
    for (j = 0; j < retcol; j++) {
      // deal with column
      
      CGIUInteger type = sqlite3_column_type(statement, j);
      
      if (type == SQLITE_BLOB) {
        CGIUInteger blobsize = sqlite3_column_bytes(statement, j);
        const unsigned char *blob = sqlite3_column_blob(statement, j);
        CGIData *blobData = [[[CGIData alloc] initWithBytes:blob length:blobsize] autorelease];
        [row addObject:blobData];
      } else if (type == SQLITE_INTEGER) {
        CGIInteger num = sqlite3_column_int64(statement, j);
        CGINumber *number = [CGINumber numberWithInteger:num];
        [row addObject:number];
      } else {
        const unichar *str = sqlite3_column_text(statement, j);
        CGIString *string = [CGIString stringWithUTF8String:str];
        [row addObject:string];
      }
    }
    
    [delegate DBI:self didGetRow:row columns:colnames];
  }
  
  if (!i) {
    i = sqlite3_changes(handle);
  }
  
  sqlite3_finalize(statement);
  
  return i;
}

- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table properties:(CGIDictionary *)properties modalDelegate:(id<CGIDBIQueryDelegate>)delegate {
  CGIMutableArray *predicates = nil;
  
  CGIArray *columns = [properties objectForKey:@"COLUMNS"];
  CGIMutableString *zSQL;
  
  if (columns) {
    zSQL = [CGIMutableString stringWithFormat:@"SELECT %@ FROM \"%@\" \"me\"", [columns stringByJoiningComponentsWithString:@", "], table];
  } else {
    zSQL = [CGIMutableString stringWithFormat:@"SELECT * FROM \"%@\" \"me\"", table];
  }
  
  CGIArray *data = nil;
  
  id joins = [properties objectForKey:@"JOIN"];
  CGIMutableString *joinString;
  
  // Do we want to join tables?
  if (joins) {
    joinString = [CGIMutableString stringWithString:@""];

    if (![joins isKindOfClass:[CGIArray self]]) { // Arrayify if neccessary
      joins = [CGIArray arrayWithObject:joins];
    }
    
    CGIUInteger i;
    for (i = 0; i < [joins count]; i++) {
      CGIDictionary *join = [joins objectAtIndex:i];
      
      CGIString *leftTable = [join objectForKey:@"LEFT_TABLE"];
      if (!leftTable) leftTable = @"me";
      
      CGIString *rightTable = [join objectForKey:@"RIGHT_TABLE"];
      CGIString *rightAlias = [join objectForKey:@"RIGHT_ALIAS"];
      if (!rightAlias) rightAlias = rightTable;
      
      CGIString *leftCol = [join objectForKey:@"LEFT_COLUMN"];
      CGIString *rightCol = [join objectForKey:@"RIGHT_COLUMN"];
      
      [joinString appendFormat:@" JOIN \"%@\" \"%@\" ON \"%@\".\"%@\" = \"%@\".\"%@\"", rightTable, rightAlias, leftTable, leftCol, rightAlias, rightCol];
    }
    [zSQL appendString:joinString];
  }
  
  if (query) {
    CGIArray *qcols = [query allKeys];
    data = [query allValues];

    predicates = [CGIMutableArray array];
    CGIUInteger i;
    for (i = 0; i < [qcols count]; i++) {
      [predicates addObject:[CGIString stringWithFormat:@"\"me\".\"%@\" = ?", [qcols objectAtIndex:i]]];
    }
    
    [zSQL appendFormat:@" WHERE %@", [predicates stringByJoiningComponentsWithString:@" AND "]];
  }
  
  CGIString *order_by = [properties objectForKey:@"ORDER_BY"];
  if (order_by) {
    if ([order_by isKindOfClass:[CGIString self]]) { // default order
      [zSQL appendFormat:@" ORDER BY %@", order_by];
    } else {
      @throw @"CGINotImplementedException";
    }
  }
  
  if (!data) {
    data = [CGIArray array];
  }

  return [self doQuery:[[[CGIDictionary alloc] initWithObjectsAndKeys:data, CGIDBIQueryDataKey, zSQL, CGIDBIQueryStringKey, nil] autorelease] modalDelegate:delegate];
}

- (CGIUInteger)insert:(CGIArray *)columns values:(CGIArray *)values table:(CGIString *)table {
  return [self insert:columns values:values table:table onConflict:CGIDBINoAction];
}

- (CGIUInteger)insert:(CGIArray *)columns values:(CGIArray *)values table:(CGIString *)table onConflict:(CGIDBIOnConflictClause)action {
  CGIString *actionStr = @""; /// FIXME: Get some actions in here.
  CGIString *cols, *vals;
  if (columns) {
    cols = [CGIString stringWithFormat:@"(%@) ", [columns stringByJoiningComponentsWithString:@", "]];
  } else {
    cols = @"";
  }
  
  if (values) {
    CGIMutableString *valsBuild = [CGIMutableString stringWithFormat:@"( "];
    
    int i;
    for (i = 0; i < [values count]; i++) {
      [valsBuild appendString:@"?"];
      if (i + 1 < [values count]) {
        [valsBuild appendString:@", "];
      }
    }
    
    [valsBuild appendString:@" )"];
    
    vals = valsBuild;
  } else {
    vals = @"";
  }
  
  CGIMutableString *zSQL = [CGIMutableString stringWithFormat:@"INSERT %@INTO \"%@\" %@VALUES %@", actionStr, table, cols, vals];
  
  return [self doQuery:[[[CGIDictionary alloc] initWithObjectsAndKeys:values, CGIDBIQueryDataKey, zSQL, CGIDBIQueryStringKey, nil] autorelease] modalDelegate:nil];
}

- (CGIUInteger)insert:(CGIArray *)columns table:(CGIString *)table fromQuery:(CGIDictionary *)query {
  @throw @"CGIKitNotImplementedException";
  return 0;
}

- (CGIUInteger)deleteFromTable:(CGIString *)table where:(CGIDictionary *)query {
  CGIMutableString *zSQL;
  
  if (!query) {
     zSQL = [CGIMutableString stringWithFormat:@"DELETE FROM \"%@\"", table];
  } else {
    CGIArray *qcols = [query allKeys];
    CGIArray *data = [query allValues];

    CGIMutableArray *predicates = [CGIMutableArray array];
    CGIUInteger i;
    for (i = 0; i < [qcols count]; i++) {
      [predicates addObject:[CGIString stringWithFormat:@"\"%@\" = ?", [qcols objectAtIndex:i]]];
    }

    zSQL = [CGIMutableString stringWithFormat:@"DELETE FROM \"%@\" WHERE %@", table, [predicates stringByJoiningComponentsWithString:@" AND "]];
  }
  
  return [self doQuery:[[[CGIDictionary alloc] initWithObjectsAndKeys:[query allValues], CGIDBIQueryDataKey, zSQL, CGIDBIQueryStringKey, nil] autorelease] modalDelegate:nil];
}


- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table modalDelegate:(id<CGIDBIQueryDelegate>)delegate {
  return [self search:query table:table properties:nil modalDelegate:delegate];
}

- (CGIUInteger)updateTable:(CGIString *)table set:(CGIDictionary *)updates where:(CGIDictionary *)query {
  return [self updateTable:table set:updates where:query onConflict:CGIDBINoAction];
}

- (CGIUInteger)updateTable:(CGIString *)table set:(CGIDictionary *)updates where:(CGIDictionary *)query onConflict:(CGIDBIOnConflictClause)action {
  CGIString *actionStr = @"";
  CGIString *zSQL, *qString, *uString;


  CGIMutableArray *qData = [CGIMutableArray array];

  {
    CGIArray *qcols = [updates allKeys];
    CGIArray *data = [updates allValues];

    CGIMutableArray *predicates = [CGIMutableArray array];
    CGIUInteger i;
    for (i = 0; i < [qcols count]; i++) {
      [predicates addObject:[CGIString stringWithFormat:@"\"%@\" = ?", [qcols objectAtIndex:i]]];
      [qData addObject:[data objectAtIndex:i]];
    }

    uString = [predicates stringByJoiningComponentsWithString:@", "];
  }
  
  if (query) {
    CGIArray *qcols = [query allKeys];
    CGIArray *data = [query allValues];

    CGIMutableArray *predicates = [CGIMutableArray array];
    CGIUInteger i;
    for (i = 0; i < [qcols count]; i++) {
      [predicates addObject:[CGIString stringWithFormat:@"\"%@\" = ?", [qcols objectAtIndex:i]]];
      [qData addObject:[data objectAtIndex:i]];
    }

    qString = [predicates stringByJoiningComponentsWithString:@" AND "];
  } else {
    qString = @"1";
  }
  
  zSQL = [CGIMutableString stringWithFormat:@"UPDATE \"%@\" SET %@ WHERE %@", table, uString, qString];

  return [self doQuery:[[[CGIDictionary alloc] initWithObjectsAndKeys:qData, CGIDBIQueryDataKey, zSQL, CGIDBIQueryStringKey, nil] autorelease] modalDelegate:nil];
}

- (void)dealloc {
  [path release];
  return [super dealloc];
}

@end
