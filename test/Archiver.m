#import "CGIKit/CGIKit.h"
#include <stdio.h>

@class TestClassB;

@interface TestClassA : CGIObject <CGICoding> {
  TestClassB *testObject;
  CGIString *testString;
  
  CGIUInteger uint1, uint2, uint3;
  CGIInteger int1, int2, int3;
}

- (void)setB:(TestClassB *)value;
- (CGIString *)testString;

@end

@interface TestClassB : CGIObject <CGICoding> {
  TestClassA *testObject;
  CGIString *testString;
}

- (TestClassA *)A;
- (CGIString *)testString;

@end

@implementation TestClassA

- (id)init {
  self = [super init];
  if (self) {
    testString = nil;
    
    uint1 = 0x00ff00ff;
    uint2 = 0xc0ffeedeadbeef00;
    uint3 = 0xffeeddccbbaa0099;
    
    int1 = 15;
    int2 = -411;
    int3 = 42;
    
  }
  return self;
}

- (void)setB:(TestClassB *)value {
  testObject = value;
}

- (void)encodeWithCoder:(CGICoder *)coder {
  [coder encodeObject:testObject];
  [coder encodeObject:testString];
  
  [coder encodeInteger:int1];
  [coder encodeInteger:int2];
  [coder encodeInteger:int3];
  
  [coder encodeUInteger:uint1];
  [coder encodeUInteger:uint2];
  [coder encodeUInteger:uint3];
}

- (id)initWithCoder:(CGICoder *)coder {
  self = [super init];
  if (self) {
    testObject = [coder decodeObject];
    testString = [coder decodeObject];
    
    int1 = [coder decodeInteger];
    int2 = [coder decodeInteger];
    int3 = [coder decodeInteger];

    uint1 = [coder decodeUInteger];
    uint2 = [coder decodeUInteger];
    uint3 = [coder decodeUInteger];
  }
  return self;
}

- (CGIString *)testString {
  return testString;
}

- (void)dealloc {
  [testString release];
  [super dealloc];
}

- (void)printInts {
  printf("%llu, %llu, %llu\n", uint1, uint2, uint3);
  printf("%lld, %lld, %lld\n", int1, int2, int3);
}

@end

@implementation TestClassB

- (id)init {
  self = [super init];
  if (self) {
    testString = @"TestString B";
    testObject = [TestClassA new];
  }
  return self;
}

- (TestClassA *)A {
  return testObject;
}

- (void)encodeWithCoder:(CGICoder *)coder {
  [coder encodeObject:testObject];
  [coder encodeObject:testString];
}

- (id)initWithCoder:(CGICoder *)coder {
  self = [super init];
  if (self) {
    testObject = [coder decodeObject];
    testString = [coder decodeObject];
  }
  return self;
}

- (CGIString *)testString {
  return testString;
}

- (void)dealloc {
  [testString release];
  [testObject release];
  [super dealloc];
}

@end


int CGIKitTest_Archiver () {

  // CGIArchiver
  
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  TestClassB *testObject = [[TestClassB new] autorelease];
  [[testObject A] setB:testObject];
  
  [[testObject A] printInts];
  
  CGIData *archiveData = [CGIArchiver archivedDataWithRootObject:testObject];
  printf("%@\n", [archiveData plistRepresentation]);
  
  TestClassB *decodedObject = [CGIUnarchiver unarchiveObjectWithData:archiveData];
  printf("%@, %@, %@, %@\n", decodedObject, [decodedObject testString], [decodedObject A], [[decodedObject A] testString]);
  
  [[decodedObject A] printInts];
  
  [pool release];
  
  return 0;
}
