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
  
  Author *zun_tsu = [[authors all] objectAtIndex:0];
  Book *art_of_war = [[[zun_tsu books] all] objectAtIndex:0];

  CGILog(@"%@", art_of_war);
  
  [art_of_war setTitle:@"The Art of War"];
  
  CGILog(@"%@", art_of_war);
  
  [art_of_war update];
  
  [art_of_war setAuthor:nil];
  
  [art_of_war update];
  
  [art_of_war setAuthor:zun_tsu];

  [art_of_war update];
  
  [dbi close];
  
  [pool release];
  
  return 0;
}
