#import "CGIKit/CGIKit.h"
#include <stdio.h>

@class Author;
@class Authors;

@interface Book : CGIResult {
  CGIInteger id;
  CGIString *title;
  Author *author;
}

- (CGIUInteger)id;

- (CGIString *)title;
- (void)setTitle:(CGIString *)title;

- (Author *)author;
- (void)setAuthor:(Author *)author;

@end

@interface Books : CGIResultSet {}

@end

@interface Author : CGIResult {
  CGIInteger id;
  CGIString *name;
  
  Books *books;
}

- (CGIUInteger)id;

- (CGIString *)name;
- (void)setName:(CGIString *)name;

- (Books *)books;

@end

@interface Authors : CGIResultSet {}

@end

@implementation Book

- (CGIString *)description {

  return [CGIString stringWithFormat:@"Book #%ld: \"%@\"\nWritten by: %@\n", self->id, title, [self author]];
}

@end

@implementation Books

- (CGIString *)description {
  return [_query description];
}

@end

@implementation Author

- (CGIString *)description {
  return [CGIString stringWithFormat:@"Author #%ld: \"%@\"", self->id, name];
}

@end

@implementation Authors @end

int CGIKitTest_Result () {

  // CGIArchiver
  
  CGIAutoreleasePool *pool = [[CGIAutoreleasePool alloc] init];
  
  CGIDBI *dbi = [[CGIDBI alloc] initWithDatabase:@"dbi:SQLite:test/books.db"];
  
  [dbi connect];
  
  Books *books = [[Books alloc] initWithDatabase:dbi query:nil];
  Authors *authors = [[Authors alloc] initWithDatabase:dbi query:nil];
  
  Author *zun_tsu = [authors create:[CGIDictionary dictionaryWithObject:@"Zun Tsu" forKey:@"name"]];
  
  CGIMutableDictionary *bDict = [CGIMutableDictionary dictionary];
  
  [bDict setObject:@"The Art of War" forKey:@"title"];
  [bDict setObject:zun_tsu forKey:@"author"];
  
  Book *art_of_war = [books create:bDict];
  
  [books delete];
  [authors delete];
  
  
  [dbi close];
  
  [pool release];
  
  return 0;
}
