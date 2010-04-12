/**
  *
  *
  *
  */



#import <CGIKit/CGIDictionary.h>
#import <CGIKit/CGIString.h>
#import <CGIKit/CGIXMLParser.h>

#import <libxml/parser.h>

/** Parser callback functions */

void CGIXMLCharacters (void * ctx, const xmlChar * ch, int len) {
  CGIXMLParser *self = (CGIXMLParser*)ctx;
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(parser:foundCharacters:)]) {
    CGIString *characters = [CGIString stringWithUTF8String:ch length:len];
    [[self delegate] parser:self foundCharacters:characters];
  }
}

void CGIXMLElementStartNS (void * ctx, const xmlChar * localname, const xmlChar * prefix, const xmlChar * URI,
                     int nb_namespaces, const xmlChar ** namespaces, int nb_attributes, int nb_defaulted,
                     const xmlChar ** attributes) {
  CGIXMLParser *self = (CGIXMLParser*)ctx;
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
    CGIString *name = [CGIString stringWithUTF8String:localname];
    CGIString *pfx = (prefix?[CGIString stringWithUTF8String:prefix]:nil);
    CGIString *nsURI = (URI?[CGIString stringWithUTF8String:URI]:nil);
    CGIString *qName = name;
    if (pfx && ![pfx isEqualToString:@""]) {
      qName = [CGIString stringWithFormat:@"%@:%@", pfx, name];
    }
    CGIMutableDictionary *attrDict = [CGIMutableDictionary dictionary];
    int i;
    for (i = 0; i < nb_attributes + nb_defaulted; i++) {
      CGIString *attName = [CGIString stringWithUTF8String:attributes[i*5]];
      //CGIString *attPfx = [CGIString stringWithUTF8String:attributes[1+i*5]];
      //CGIString *attURI = [[CGIString stringWithCString:attributes[2+i*5]];
      CGIString *attVal = [CGIString stringWithUTF8String:attributes[3+i*5] length:attributes[4+i*5]-attributes[3+i*5]];
      //if (attPfx && ![attPfx isEqualToString:@""]) {
      //  attName = [CGIString stringWithFormat:@"%@:%@", attPfx,attName];
      //}
      [attrDict setObject:attVal forKey:attName];
    }
    [[self delegate] parser:self didStartElement:name namespaceURI:nsURI qualifiedName:qName attributes:attrDict];
  }
}

void CGIXMLError (void * ctx, const char * msg, ...) {
  @throw @"CGIKitMalformedXMLException";
}
//xmlEntityPtr entity (void * ctx, const xmlChar * name) { }
void CGIXMLPI (void *ctx, const xmlChar * target, const xmlChar * data) {
  CGIXMLParser *self = (CGIXMLParser*)ctx;
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(parser:foundProcessingInstructionWithTarget:data:)]) {
    [[self delegate] parser:self foundProcessingInstructionWithTarget:[CGIString stringWithUTF8String:target] data:[CGIString stringWithUTF8String:data]];
  }
}

void CGIXMLElementEndNS (void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {
  CGIXMLParser *self = (CGIXMLParser*)ctx;
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)]) {
    CGIString *name = [CGIString stringWithUTF8String:localname];
    CGIString *pfx = (prefix?[CGIString stringWithUTF8String:prefix]:nil);
    CGIString *nsURI = (URI?[CGIString stringWithUTF8String:URI]:nil);
    CGIString *qName = name;
    if (pfx && ![pfx isEqualToString:@""]) {
      qName = [CGIString stringWithFormat:@"%@:%@", pfx, name];
    }
    [[self delegate] parser:self didEndElement:name namespaceURI:nsURI qualifiedName:qName];
  }
}

void CGIXMLDocumentStart (void *ctx) {
  CGIXMLParser *self = (CGIXMLParser*)ctx;
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(parserDidStartDocument:)]) {
    [[self delegate] parserDidStartDocument:self];
  }
}

void CGIXMLDocumentEnd (void *ctx) {
  CGIXMLParser *self = (CGIXMLParser*)ctx;
  if ([self delegate] && [[self delegate] respondsToSelector:@selector(parserDidEndDocument:)]) {
    [[self delegate] parserDidEndDocument:self];
  }
}

@interface CGIXMLParser (CGIXMLParserPrivate)
- (id)_initWithData:(CGIString *)xmlData url:xmlURL;
@end

@implementation CGIXMLParser

- (id)initWithXMLString:(CGIString *)string {
  return [self _initWithData:string url:nil];
}

- (id)_initWithData:(CGIString *)xmlData url:(id)xmlURL {
  self = [super init];
  if (self != nil) {
    xmlParserCtxt *parserContext = xmlCreateDocParserCtxt([xmlData UTF8String]);
    if (parserContext == NULL) { [self release]; return nil; }
    xmlSetupParserForBuffer(parserContext, [xmlData UTF8String], NULL);
    
    xmlSAXHandler *_handler = calloc(1,sizeof(xmlSAXHandler));
    _handler->initialized = XML_SAX2_MAGIC;
    _handler->startDocument = &CGIXMLDocumentStart;
    _handler->endDocument = &CGIXMLDocumentEnd;
    _handler->startElementNs = &CGIXMLElementStartNS;
    _handler->endElementNs = &CGIXMLElementEndNS;
    _handler->characters = &CGIXMLCharacters;
    _handler->processingInstruction = &CGIXMLPI;
    //_handler->getEntity = &entity;
    _handler->error = &CGIXMLError;
    parserContext->sax = _handler;
    parserContext->sax2 = 1;
    parserContext->userData = self;
    _parser = (void*)parserContext;
  }
  return self;
}


- (id)delegate {
  return _delegate;
}

- (void)setDelegate:(id)delegate {
  if (delegate != _delegate) {
    [_delegate release];
    _delegate = [delegate retain];
  }
}

- (void)parse {
  xmlParseDocument(_parser);
  xmlFreeParserCtxt(_parser);
}

- (void)abortParsing {
  
}

- (void)parserError {
  
}

@end
