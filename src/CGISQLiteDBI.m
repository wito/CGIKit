#import "CGIKit/CGIDBI.h"
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIData.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGINumber.h"

#include <sqlite3.h>

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
  CGIString *sql = [query objectForKey:@"CGI_DBI_SQL_SENTENCE"];
  const char *zSql = [sql UTF8String];
  CGIArray *data = [query objectForKey:@"CGI_DBI_SQL_DATA"];
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
  
  
  CGIUInteger j;
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
    
    [delegate DBI:self didGetRow:row];
  }
  
  sqlite3_finalize(statement);
  
  return i;
}

- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table properties:(CGIDictionary *)properties modalDelegate:(id<CGIDBIQueryDelegate>)delegate {
  CGIArray *qcols = [query allKeys];
  CGIArray *data = [query allValues];

  CGIMutableArray *predicates = [CGIMutableArray array];
  CGIUInteger i;
  for (i = 0; i < [qcols count]; i++) {
    [predicates addObject:[CGIString stringWithFormat:@"\"%@\" = ?", [qcols objectAtIndex:i]]];
  }
  
  CGIString *zSQL = [CGIString stringWithFormat:@"SELECT * FROM \"%@\" WHERE %@;", table, [predicates stringByJoiningComponentsWithString:@" AND "]];
  return [self doQuery:[[[CGIDictionary alloc] initWithObjectsAndKeys:data, @"CGI_DBI_SQL_DATA", zSQL, @"CGI_DBI_SQL_SENTENCE", nil] autorelease] modalDelegate:delegate];
}

- (CGIUInteger)search:(CGIDictionary *)query table:(CGIString *)table modalDelegate:(id<CGIDBIQueryDelegate>)delegate {
  return [self search:query table:table properties:nil modalDelegate:delegate];
}

- (void)dealloc {
  [path release];
  return [super dealloc];
}

@end
