#import "CGIKit/CGIDBI.h"
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIArray.h"

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
  return !ret;
}

- (void)close {
  sqlite3_close(handle);
  handle = NULL;
}

- (CGIUInteger)doQuery:(CGIDictionary *)query modalDelegate:(id)delegate {
  
  
  
  return 0;
}


- (void)dealloc {
  [path release];
  return [super dealloc];
}

@end
