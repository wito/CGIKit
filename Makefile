CC=gcc
CFLAGS=-fobjc-exceptions -fconstant-string-class=CGIConstantString -fPIC -g -I. -I/usr/include/libxml2 -Wno-format
#CFLAGS=-Wall -I/usr/include/libxml2 -Iinc -D DEBUG
SOFLAGS=-shared -Wl,-soname,libcgikit.so.0
LFLAGS=-lobjc -lfcgi -lxml2
#LFLAGS=-lfcgi -lsqlite3 -lxml2
TLFLAGS=-lcgikit

TDIR=
TODIR=test
ODIR=obj

VERSION = 0.0.1

.PHONY: clean doc install

_TEST = harness.o String.o Array.o Archiver.o
TEST = $(patsubst %,$(TODIR)/%,$(_TEST))

_OBJ = CGIFunctions.o CGIAutoreleasePool.o CGIObject.o \
       CGIString.o CGIDictionary.o CGIArray.o \
       CGIParameters.o CGIApplication.o CGIRequest.o \
       CGIXMLParser.o CGICoder.o CGIData.o \
       CGIHTMLWindow.o CGIView.o

OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

lib/libcgikit.so.${VERSION}: $(OBJ)
	mkdir -p lib/
	$(CC) ${SOFLAGS} -o lib/libcgikit.so.${VERSION}  ${OBJ} $(LFLAGS)

$(ODIR)/%.o: src/%.m $(DEPS)
	mkdir -p obj/
	$(CC) -c -o $@ $< $(CFLAGS)

test: $(TEST)
	mkdir -p bin/
	$(CC) -o bin/test ${TEST} $(TLFLAGS)

$(TODIR)/%.o: test/%.m $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

install: lib/libcgikit.so.${VERSION}
	install lib/libcgikit.so.${VERSION} /usr/lib
	ln -fs /usr/lib/libcgikit.so.${VERSION} /usr/lib/libcgikit.so.0
	ln -fs /usr/lib/libcgikit.so.${VERSION} /usr/lib/libcgikit.so
	mkdir -p /usr/include/CGIKit
	install CGIKit/* /usr/include/CGIKit

.PHONY: clean

clean:
	rm -rf $(ODIR) lib bin
	rm -f $(TODIR)/*.o
