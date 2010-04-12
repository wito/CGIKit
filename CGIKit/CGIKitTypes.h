/* CGIKitTypes.h */
/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import <stdint.h>

typedef uint64_t CGIUInteger;
typedef int64_t CGIInteger;

typedef char unichar;

typedef struct _CGIRange {
  CGIUInteger location;
  CGIUInteger length;
} CGIRange;
