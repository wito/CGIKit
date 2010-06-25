@class CGIArray;
@class CGIDBI;

@protocol CGIDBIQueryDelegate

- (void)DBI:(CGIDBI *)dbi didGetRow:(CGIArray *)row columns:(CGIArray *)columnNames;

@end
