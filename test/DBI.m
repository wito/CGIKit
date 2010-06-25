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
  
  CGIDictionary *query = [[[CGIDictionary alloc] initWithObjectsAndKeys:queryData, @"CGI_DBI_SQL_DATA", queryString, @"CGI_DBI_SQL_SENTENCE", nil] autorelease];
  CGIDictionary *otherQuery = [[[CGIDictionary alloc] initWithObjectsAndKeys:@"FOO", @"text", nil] autorelease];
    
  [dbi connect];
  
  [dbi doQuery:query modalDelegate:[[CGIKitTestDBIQueryDelegate new] autorelease]];
  [dbi search:otherQuery table:@"test_table" modalDelegate:[[CGIKitTestDBIQueryDelegate new] autorelease]];
  
  [dbi close];
  
  [pool release];
  
  return 0;
}
