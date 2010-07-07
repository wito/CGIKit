#import "CGIKit/CGIResult.h"

#import "CGIKit/CGIDictionary.h"
#import "CGIKit/CGIArray.h"
#import "CGIKit/CGIString.h"
#import "CGIKit/CGIDBI.h"
#import "CGIKit/CGINumber.h"
#import "CGIKit/CGIFunctions.h"

#import <objc/objc-api.h>
#import <objc/sarray.h>

CGIInteger getIdColumn (id self, SEL _cmd) {
  IvarList *ivars = [self class]->ivars;
  
  int i;
  for (i = 0; i < ivars->ivar_count; i++) {        
    if (!strcmp(ivars->ivar_list[i].ivar_name, "id")) {
      return *((CGIInteger *)&(((char *)self)[ivars->ivar_list[i].ivar_offset]));
    }
  }
  
  @throw @"CGIKitInternalInconsistencyException";
}

id getResultIvar(id self, SEL _cmd) {
  IvarList *ivars = [self class]->ivars;
  
  int i;
  for (i = 0; i < ivars->ivar_count; i++) {        
    if (!strcmp(ivars->ivar_list[i].ivar_name, sel_get_name(_cmd))) {
      id retval = *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset]));
      [retval synchronize];
      return retval;
    }
  }
  
  @throw @"CGIKitInternalInconsistencyException";
}

void setResultIvar(id self, SEL _cmd, id newVal) {
  IvarList *ivars = [self class]->ivars;
  CGIString *iName = [CGIString stringWithUTF8String:sel_get_name(_cmd)];
  CGIString *name = [[iName substringWithRange:CGIMakeRange(3, [iName length] - 4)] lowercaseString];

  int i;
  for (i = 0; i < ivars->ivar_count; i++) {
    if (!strcmp(ivars->ivar_list[i].ivar_name, [name UTF8String])) {
      id *retval = ((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset]));
      [*retval release];
      *retval = [newVal retain];
      ((struct CGIResult *)(self))->_status = CGIInMemory;
      return;
    }
  }
  
  @throw @"CGIKitInternalInconsistencyException";

}

id getResultSetIvar(id self, SEL _cmd) {
  IvarList *ivars = [self class]->ivars;
  
  int i;
  for (i = 0; i < ivars->ivar_count; i++) {        
    if (!strcmp(ivars->ivar_list[i].ivar_name, sel_get_name(_cmd))) {
      id retval = *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset]));
      return retval;
    }
  }
  
  @throw @"CGIKitInternalInconsistencyException";
}

@implementation CGIResult

- (id)initWithDatabase:(CGIDBI *)database query:(CGIDictionary *)query {
  self = [super init];
  if (self) {
    _database = [database retain];
    _query = [query retain];
    _table = [[self table] retain];
    
    _status = CGIInStorage;
  }
  return self;
}

- (void)installMethodForIDColumn {
    Class myClass = [self class];
    
    SEL selector = sel_register_typed_name("id", "q16@0:8");
    
    MethodList_t methodList = objc_malloc(sizeof(MethodList));
    methodList->method_next = myClass->methods;
    methodList->method_count = 1;
    methodList->method_list[0].method_name = selector->sel_id;
    methodList->method_list[0].method_types = selector->sel_types;
    methodList->method_list[0].method_imp = (IMP)getIdColumn;
    
    myClass->methods = methodList;

    sarray_at_put_safe(myClass->dtable, (sidx)selector->sel_id, methodList->method_list[0].method_imp);
}

- (void)installMethodsForRSColumn:(CGIString *)col {
    Class myClass = [self class];
    
    CGIString *getter = col;
    CGIString *setter = [CGIString stringWithFormat:@"set%@:", [col capitalizedString]];
    
    SEL selector = sel_register_typed_name([getter UTF8String], "@16@0:8");
    
    MethodList_t methodList = objc_malloc(sizeof(MethodList));
    methodList->method_next = myClass->methods;
    methodList->method_count = 1;
    methodList->method_list[0].method_name = selector->sel_id;
    methodList->method_list[0].method_types = selector->sel_types;
    methodList->method_list[0].method_imp = (IMP)getResultSetIvar;
    
    myClass->methods = methodList;

    sarray_at_put_safe(myClass->dtable, (sidx)selector->sel_id, methodList->method_list[0].method_imp);
}

- (void)installMethodsForColumn:(CGIString *)col {
    Class myClass = [self class];
    
    CGIString *getter = col;
    CGIString *setter = [CGIString stringWithFormat:@"set%@:", [col capitalizedString]];
    
    SEL selector = sel_register_typed_name([getter UTF8String], "@16@0:8");
    SEL selectwor = sel_register_typed_name([setter UTF8String], "v24@0:8@16");
    
    MethodList_t methodList = objc_malloc(sizeof(MethodList) + sizeof(Method) * 2);
    methodList->method_next = myClass->methods;
    methodList->method_count = 2;
    methodList->method_list[0].method_name = selector->sel_id;
    methodList->method_list[0].method_types = selector->sel_types;
    methodList->method_list[0].method_imp = (IMP)getResultIvar;
    
    methodList->method_list[1].method_name = selectwor->sel_id;
    methodList->method_list[1].method_types = selectwor->sel_types;
    methodList->method_list[1].method_imp = (IMP)setResultIvar;
    
    myClass->methods = methodList;

    sarray_at_put_safe(myClass->dtable, (sidx)selector->sel_id, methodList->method_list[0].method_imp);
    sarray_at_put_safe(myClass->dtable, (sidx)selectwor->sel_id, methodList->method_list[1].method_imp);
}

- (id)initWithDatabase:(CGIDBI *)database data:(CGIDictionary *)data {
  self = [super init];
  if (self) {
    _database = [database retain];
    _table = [[self table] retain];
    
    IvarList *ivars = [self class]->ivars;
    CGIMutableArray *colnames = [CGIMutableArray array];
    
    int i;
    for (i = 0; i < ivars->ivar_count; i++) {
      //printf("%s: %s/%u\n", ivars->ivar_list[i].ivar_name, ivars->ivar_list[i].ivar_type, ivars->ivar_list[i].ivar_offset);
      CGIString *iName = [CGIString stringWithUTF8String:ivars->ivar_list[i].ivar_name];
      CGIString *tableName = [CGIString stringWithFormat:@"%@.%@", _table, iName];
      
      [colnames addObject:iName];
      
      if (ivars->ivar_list[i].ivar_type[0] == 'q') { // This should only be the PRIMARY KEY
        *((CGIInteger*)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [[data objectForKey:tableName] integerValue];
        
        SEL idSelector = sel_get_typed_uid("id", "q16@0:8");
        
        if (!idSelector || ![self respondsToSelector:idSelector]) {
          [self installMethodForIDColumn];
        }

      } else if (ivars->ivar_list[i].ivar_type[0] == '@') {
        CGIString *typeString = [CGIString stringWithUTF8String:ivars->ivar_list[i].ivar_type];
        CGIString *className = [typeString substringWithRange:CGIMakeRange(2, [typeString length] - 3)];
        Class ivarClass = objc_get_class([className UTF8String]);
        
        if ([ivarClass isKindOfClass:[CGIResult self]]) { // Referring out
          
          if ([[data objectForKey:tableName] integerValue]) {
            *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [[ivarClass alloc] initWithDatabase:_database query:[CGIDictionary dictionaryWithObject:[data objectForKey:tableName] forKey:@"id"]];
          } else {
            *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = nil;
          }
          
          SEL selector = sel_get_typed_uid([iName UTF8String], "@16@0:8");
          
          if (!selector || ![self respondsToSelector:selector]) {
            [self installMethodsForColumn:iName];
          }
          
        } else if ([ivarClass isKindOfClass:[CGIResultSet self]]) { // Here we are referring in
          
          *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [[ivarClass alloc] initWithDatabase:_database query:[CGIDictionary dictionaryWithObject:[data objectForKey:[CGIString stringWithFormat:@"%@.id", _table]] forKey:_table]];
          
          SEL selector = sel_get_typed_uid([iName UTF8String], "@16@0:8");
          
          if (!selector || ![self respondsToSelector:selector]) {
            [self installMethodsForRSColumn:iName];
          }
          
        } else { // Data
          *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [data objectForKey:tableName];
          
          SEL selector = sel_get_typed_uid([iName UTF8String], "@16@0:8");
          
          if (!selector || ![self respondsToSelector:selector]) {
            [self installMethodsForColumn:iName];
          }

        }
      }
    }
    
    _columns = [colnames retain];
    
  }
  return self;
}

- (CGIString *)table {
  return [[[self class] description] lowercaseString];
}

+ (CGIString *)table {
  return [[self description] lowercaseString];
}

- (id)synchronize {
  if (_status) {
    [_database search:_query table:_table modalDelegate:self];
  }
  return self;
}

- (id)update {
  return [self update:nil];
}

- (id)update:(CGIDictionary *)data {
  if (data == nil) {
    CGILog(@"%@", _columns);
    
    CGIMutableDictionary *updateDict = [CGIMutableDictionary dictionary];
    
    int i;
    for (i = 1; i < [_columns count]; i++) {
      CGIString *key = [_columns objectAtIndex:i];
      CGIString *object = [self performSelector:sel_get_uid([key UTF8String])];
      
      if (!object) {
        object = [CGINumber null];
      } else if ([[object class] isKindOfClass:[CGIResult self]]) {
        object = [CGINumber numberWithInteger:(CGIInteger)[object id]];
      }
    
      [updateDict setObject:object forKey:key];
    }
    
    CGIDictionary *queryDict = [CGIDictionary dictionaryWithObject:[CGINumber numberWithInteger:(CGIInteger)[self id]] forKey:@"id"];
    
    [_database updateTable:[self table] set:updateDict where:queryDict];
    _status = CGISynchronized;
  }
}

- (void)DBI:(CGIDBI *)dbi didGetRow:(CGIArray *)row columns:(CGIArray *)columns {
  CGIDictionary *data = [CGIDictionary dictionaryWithObjects:row forKeys:columns];

    IvarList *ivars = [self class]->ivars;
    CGIMutableArray *colnames = [CGIMutableArray array];
    
    int i;
    for (i = 0; i < ivars->ivar_count; i++) {
      //printf("%s: %s/%u\n", ivars->ivar_list[i].ivar_name, ivars->ivar_list[i].ivar_type, ivars->ivar_list[i].ivar_offset);
      CGIString *iName = [CGIString stringWithUTF8String:ivars->ivar_list[i].ivar_name];
      CGIString *tableName = [CGIString stringWithFormat:@"%@.%@", _table, iName];
      
      [colnames addObject:iName];
      
      if (ivars->ivar_list[i].ivar_type[0] == 'q') { // This should only be the PRIMARY KEY
        *((CGIInteger*)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [[data objectForKey:tableName] integerValue];
        
        SEL idSelector = sel_get_typed_uid("id", "q16@0:8");
        
        if (!idSelector || ![self respondsToSelector:idSelector]) {
          [self installMethodForIDColumn];
        }

      } else if (ivars->ivar_list[i].ivar_type[0] == '@') {
        CGIString *typeString = [CGIString stringWithUTF8String:ivars->ivar_list[i].ivar_type];
        CGIString *className = [typeString substringWithRange:CGIMakeRange(2, [typeString length] - 3)];
        Class ivarClass = objc_get_class([className UTF8String]);
        
        if ([ivarClass isKindOfClass:[CGIResult self]]) { // Referring out
          
          if ([[data objectForKey:tableName] integerValue]) {
            *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [[ivarClass alloc] initWithDatabase:_database query:[CGIDictionary dictionaryWithObject:[data objectForKey:tableName] forKey:@"id"]];
          } else {
            *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = nil;
          }
          
          SEL selector = sel_get_typed_uid([iName UTF8String], "@16@0:8");
          
          if (!selector || ![self respondsToSelector:selector]) {
            [self installMethodsForColumn:iName];
          }
          
        } else if ([ivarClass isKindOfClass:[CGIResultSet self]]) { // Here we are referring in
          
          *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [[ivarClass alloc] initWithDatabase:_database query:[CGIDictionary dictionaryWithObject:[data objectForKey:[CGIString stringWithFormat:@"%@.id", _table]] forKey:_table]];
          
          SEL selector = sel_get_typed_uid([iName UTF8String], "@16@0:8");
          
          if (!selector || ![self respondsToSelector:selector]) {
            [self installMethodsForRSColumn:iName];
          }
          
        } else { // Data
          *((id *)&(((char *)self)[ivars->ivar_list[i].ivar_offset])) = [data objectForKey:tableName];
          
          SEL selector = sel_get_typed_uid([iName UTF8String], "@16@0:8");
          
          if (!selector || ![self respondsToSelector:selector]) {
            [self installMethodsForColumn:iName];
          }

        }
      }
    }
  
  if (!_columns)
    _columns = [colnames retain];
  _status = 0;
}

- (void)delete {
  [_database deleteFromTable:[self table] where:[CGIDictionary dictionaryWithObject:[CGINumber numberWithInteger:(CGIInteger)[self id]] forKey:@"id"]];
}

@end

@implementation CGIResultSet

- (void)update {
  [_results release];
  _results = [CGIMutableArray new];
  _count = [_database search:_query table:_table modalDelegate:self];
}

- (void)DBI:(CGIDBI *)dbi didGetRow:(CGIArray *)row columns:(CGIArray *)colnames {
  id resultObject = [[[[self resultClass] alloc] initWithDatabase:_database data:[CGIDictionary dictionaryWithObjects:row forKeys:colnames]] autorelease];
  [_results addObject:resultObject];
}


- (id)initWithDatabase:(CGIDBI *)database query:(CGIDictionary *)query {
  self = [super init];
  if (self) {
    _database = [database retain];
    _query = [query retain];
    _table = [self table];
    _resultClass = [self resultClass];
    
    _count = 0;
    _results = nil;
  }
  return self;
}

- (CGIArray *)all {
  [self update];
  return _results;
}

- (Class)resultClass {
  CGIString *className = [[self class] description];
  CGIString *rClassName = [className substringWithRange:CGIMakeRange(0, [className length] - 1)];
  return objc_get_class([rClassName UTF8String]);
}

- (CGIString *)table {
  return [[self resultClass] table];
}

- (CGIResult *)create:(CGIDictionary *)data {
  CGIMutableDictionary *qDict = [CGIMutableDictionary dictionary];
  
  if (_query) {
    [qDict addEntriesFromDictionary:_query];
  }

  if (data) {
    [qDict addEntriesFromDictionary:data];
  }
  
  CGIArray *keys = [qDict allKeys];
  
  int i;
  for (i = 0; i < [keys count]; i++) {
    id anObject = [qDict objectForKey:[keys objectAtIndex:i]];
    
    if ([anObject isKindOfClass:[CGIResult self]]) {
      [qDict setObject:[CGINumber numberWithInteger:(CGIInteger)[anObject id]] forKey:[keys objectAtIndex:i]];
    }
  }
  
  CGIUInteger rowid = [_database insert:[qDict allKeys] values:[qDict allValues] table:[self table]];
  
  id retval = [[[self resultClass] alloc] initWithDatabase:_database query:[CGIDictionary dictionaryWithObject:[CGINumber numberWithInteger:rowid] forKey:@"id"]];
  [retval synchronize];
  
  return retval;
}

- (void)delete {
  [_database deleteFromTable:[self table] where:_query];
}

@end

@implementation CGIObject (CGIResultAddtions)

- (void)synchronize {
  return;
}

@end
