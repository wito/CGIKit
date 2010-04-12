/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

@class CGIString;

@protocol CGIPropertyListObject

- (CGIString *)plistRepresentation;
- (CGIString *)XMLRepresentation;

@end

BOOL CGIWritePropertyList (id<CGIPropertyListObject>, CGIString *);
id<CGIPropertyListObject> CGIReadPropertyList (CGIString *data);
