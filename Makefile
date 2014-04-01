CC=cc
TARGETS= imp1

all: $(TARGETS)

imp1: bison-c-file.tab.o lex.yy.o
	$(CC) -o  imp1 bison-c-file.tab.o lex.yy.o

bison-c-file.tab.o: data-struct-file.h bison-c-file.y
	bison -d bison-c-file.y
	$(CC) -c bison-c-file.tab.c

lex.yy.o: data-struct-file.h bison-c-file.tab.h flex-file.f
	flex flex-file.f
	$(CC) -c lex.yy.c

clean:
	-rm *.o bison-c-file.tab.c bison-c-file.tab.h lex.yy.c $(TARGETS)
