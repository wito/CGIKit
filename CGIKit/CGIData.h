/* CGIData.h */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"
#import "CGIPropertyList.h"

@interface CGIData : CGIObject <CGIPropertyListObject> {
  unsigned char *_bytes;
  CGIUInteger _length;
}

- (id)initWithData:(CGIData *)data;
- (id)initWithBytes:(const unsigned char *)data length:(CGIUInteger)length;

- (CGIUInteger)length;
- (unsigned char *)bytes;

- (CGIData *)dataWithRange:(CGIRange)range;
- (unsigned char *)bytesWithRange:(CGIRange)range;

@end

@interface CGIMutableData : CGIData {
  CGIUInteger _capacity;
}

- (void)appendData:(CGIData *)data;
- (void)appendBytes:(const unsigned char *)data length:(CGIUInteger)length;

@end
