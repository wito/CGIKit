#import "CGIKit/CGINumber.h"

@interface CGIIntegralNumber : CGINumber {
  CGIInteger payload;
}

@end

@implementation CGINumber

- (id)initWithInteger:(CGIInteger)value {
  [self release];
  return [[CGIIntegralNumber alloc] initWithInteger:value];
}

+ (id)numberWithInteger:(CGIInteger)value {
  return [[[CGIIntegralNumber alloc] initWithInteger:value] autorelease];
}

@end

@implementation CGIIntegralNumber

- (id)initWithInteger:(CGIInteger)value {
  self = [super init];
  if (self) {
    payload = value;
  }
  return self;
}

@end
