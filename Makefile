CC=cc
TARGETS= imp1

all: $(TARGETS)

imp1: build/bison-c-file.tab.o build/lex.yy.o
	$(CC) -o  bin/imp1 build/bison-c-file.tab.o build/lex.yy.o

build/bison-c-file.tab.o: 
	bison -b build/bison-c-file -d src/bison-c-file.y
	$(CC) -I include -o build/bison-c-file.tab.o -c build/bison-c-file.tab.c

build/lex.yy.o:
	flex -o build/lex.yy.c src/flex-file.f
	$(CC) -I include -o build/lex.yy.o -c build/lex.yy.c

clean:
	-rm build/* bin/$(TARGETS)
