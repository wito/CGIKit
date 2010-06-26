#import "CGIKit/CGIKit.h"
#include <stdio.h>

@interface CGIKitTestDBIQueryDelegate : CGIObject <CGIDBIQueryDelegate> {

}

@end

@implementation CGIKitTestDBIQueryDelegate

- (void)DBI:(CGIDBI *)dbi didGetRow:(CGIArray *)row columns:(CGIArray *)colnames{
  printf("%@\n", row);
  printf("%@\n", colnames);
}

@end

int CGIKitTest_DBI () {

  // CGIDBI
  
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  CGIDBI *dbi = [[CGIDBI alloc] initWithDatabase:@"dbi:SQLite:test/test.db"];
  
  CGIArray *queryData = [CGIArray arrayWithObject:@"FOO"];
  CGIString *queryString = @"SELECT me.text, foo.text FROM test_table AS me join test_table_two as foo";
  
  CGIDictionary *query = [[[CGIDictionary alloc] initWithObjectsAndKeys:queryData, CGIDBIQueryDataKey, queryString, CGIDBIQueryStringKey, nil] autorelease];
  CGIDictionary *otherQuery = [[[CGIDictionary alloc] initWithObjectsAndKeys:@"FOO", @"text", nil] autorelease];
  
  CGIDictionary *props = [[[CGIDictionary alloc] initWithObjectsAndKeys:
    [[[CGIDictionary alloc] initWithObjectsAndKeys:@"id", @"LEFT_COLUMN", @"id", @"RIGHT_COLUMN", @"test_table_two", @"RIGHT_TABLE", nil] autorelease], @"JOIN",
    [[[CGIArray alloc] initWithObjects:@"me.id", @"test_table_two.text", nil] autorelease], @"COLUMNS",
    @"me.text", @"ORDER_BY",
    nil
  ] autorelease];
    
  [dbi connect];
  
  [dbi doQuery:query modalDelegate:[[CGIKitTestDBIQueryDelegate new] autorelease]];
  [dbi search:nil table:@"test_table" properties:props modalDelegate:[[CGIKitTestDBIQueryDelegate new] autorelease]];
  
  [dbi close];
  
  [pool release];
  
  return 0;
}
