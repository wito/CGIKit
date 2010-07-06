#import "CGIKit/CGIObject.h"

#import "CGIKit/CGIPropertyList.h"
#import "CGIKit/CGICoding.h"

@interface CGINumber : CGIObject <CGIPropertyListObject,CGICoding> {

}

+ (id)numberWithInteger:(CGIInteger)value;

- (id)initWithInteger:(CGIInteger)value;
- (CGIInteger)integerValue;

+ (CGINumber *)null;
- (BOOL)isNull;

@end
