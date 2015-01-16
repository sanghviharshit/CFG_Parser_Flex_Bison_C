#ifndef __EXAMPLE_H__
#define __EXAMPLE_H__

int  yylex   ();
void yyerror (char *);
FILE *yyin;

typedef struct KeyValSt {
    char *keyName;
    char *keyValue;
    char *keyType;
    struct KeyValSt *nextKeyVal;
} KeyValTree;

typedef struct GroupSt {
    int groupType;
    char *hostId;
    KeyValTree *keyValPairsPtr;
    struct GroupSt *nextGroup;
} GroupTree;

//extern GroupTree global, *curGroupTree, *curKeyValTree;


#endif
