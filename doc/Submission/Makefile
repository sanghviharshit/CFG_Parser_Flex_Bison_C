CC=cc
TARGETS= imp1

all: $(TARGETS)

imp1: bison-example.tab.o lex.yy.o
	$(CC) -o  imp1 bison-example.tab.o lex.yy.o

bison-example.tab.o: example.h bison-example.y
	bison -d bison-example.y
	$(CC) -c bison-example.tab.c

lex.yy.o: example.h bison-example.tab.h flex-example.f
	flex flex-example.f
	$(CC) -c lex.yy.c

clean:
	-rm *.o bison-example.tab.c bison-example.tab.h lex.yy.c $(TARGETS)
