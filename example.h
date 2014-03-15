#ifndef __EXAMPLE_H__
#define __EXAMPLE_H__

int  yylex   ();
void yyerror (char *);
FILE *yyin;

typedef struct KeyValSt {
    char *keyName;
    char *keyValue;
    struct KeyValTree *next;
} KeyValTree;

typedef struct GroupSt {
    int groupType;
    struct KeyValTree *keyVal;
    struct GroupTree *next;
} GroupTree;

//extern GroupTree global, *curGroupTree, *curKeyValTree;


#endif
