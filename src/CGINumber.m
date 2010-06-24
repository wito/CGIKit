#import "CGIKit/CGINumber.h"
#import "CGIKit/CGIKitTypes.h"

#import "CGIKit/CGICoder.h"
#import "CGIKit/CGIString.h"

typedef  Payload;

@interface CGIIntegralNumber : CGINumber {
  union {
  CGIInteger d;
  CGIUInteger u;
  } payload;
  BOOL is_signed;
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

- (CGIString *)XMLRepresentation {
  @throw @"CGIKitAbstractViolationException";
}

- (CGIString *)plistRepresentation {
  @throw @"CGIKitAbstractViolationException";
}

- (id)initWithCoder:(CGICoder *)coder {
  return [self init];
}

- (void)encodeWithCoder:(CGICoder *)coder { }

- (CGIInteger)integerValue {
  @throw @"CGIKitAbstractViolationException";
}

@end

@implementation CGIIntegralNumber

- (id)initWithInteger:(CGIInteger)value {
  self = [super init];
  if (self) {
    payload.d = value;
    is_signed = YES;
  }
  return self;
}

- (CGIInteger)integerValue {
  return payload.d;
}

- (CGIString *)XMLRepresentation {
  return [CGIString stringWithFormat:@"<integer>%lld</integer>", payload.d];
}

- (CGIString *)plistRepresentation {
  return [CGIString stringWithFormat:@"%lld", payload.d];
}

- (id)initWithCoder:(CGICoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    payload.d = [coder decodeInteger];
    is_signed = YES;
  }
  return self;
}

- (void)encodeWithCoder:(CGICoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeInteger:payload.d];
}

@end
