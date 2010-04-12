#import "CGIObject.h"

@class CGIString;
@class CGIDictionary;

@interface CGIXMLParser : CGIObject {
  @private
  void * _parser;
  id _delegate;
  CGIString *_documentData;
}

- (id)initWithXMLString:(CGIString *)string;

- (id)delegate;
- (void)setDelegate:(id)delegate;
- (void)parse;
- (void)abortParsing;
- (void)parserError;

@end

id<CGIPropertyListObject> CGIReadPropertyList (CGIString *filename);

@interface CGIObject (CGIXMLParserDelegateAdditions)

- (void)parserDidStartDocument:(CGIXMLParser *)parser;
- (void)parserDidEndDocument:(CGIXMLParser *)parser;
- (void)parser:(CGIXMLParser *)parser didStartElement:(CGIString *)elementName namespaceURI:(CGIString *)namespaceURI qualifiedName:(CGIString *)qualifiedName attributes:(CGIDictionary *)attributeDict;
- (void)parser:(CGIXMLParser *)parser didEndElement:(CGIString *)elementName namespaceURI:(CGIString *)namespaceURI qualifiedName:(CGIString *)qName;

- (void)parser:(CGIXMLParser *)parser foundCharacters:(CGIString *)string;
- (void)parser:(CGIXMLParser *)parser foundIgnorableWhitespace:(CGIString *)whitespaceString;

//- (void)parser:(CGIXMLParser *)parser foundCDATA:(NSData *)CDATABlock;
- (void)parser:(CGIXMLParser *)parser foundProcessingInstructionWithTarget:(CGIString *)target data:(CGIString *)data;

- (void)parser:(CGIXMLParser *)parser foundComment:(CGIString *)comment;

//- (NSData *)parser:(CGIXMLParser *)parser resolveExternalEntityName:(CGIString *)entityName systemID:(CGIString *)systemID;
// - (void)parser:(CGIXMLParser *)parser parseErrorOccurred:(NSError *)parseError;

@end

