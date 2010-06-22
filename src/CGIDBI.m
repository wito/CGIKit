#import "CGIKit/CGIDBI.h"

#import "CGIKit/CGIString.h"
#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIArray.h"

@class CGISQLiteDBI;

@implementation CGIDBI

- (id)initWithDatabase:(CGIString *)dsn {
  if ([CGIDBI self] == [self class]) {
    CGIArray *dsnPath = [dsn componentsSeparatedByString:@":"];
    if ([[dsnPath objectAtIndex:1] isEqualToString:@"SQLite"]) {
      [self autorelease];
      return [[CGISQLiteDBI alloc] initWithDatabase:dsn];
    } else {
      @throw @"CGINotImplementedException";
    }
  } else {
    return [super init];
  }
}

- (BOOL)connect {
  @throw @"CGIAbstractViolationException";
  return NO;
}

- (void)close {}

- (CGIUInteger)doQuery:(CGIDictionary *)query modalDelegate:(id<CGIDBIQueryDelegate>)delegate {
  @throw @"CGIAbstractViolationException";
  return 0;
}

- (void)dealloc {
  [self close];
  return [super dealloc];
}

@end
