%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "data-struct-file.h"
extern int lineNumber;
extern int lexError;
extern int startScolonLine;
int override=0;

KeyValTree* CreateKeyValPair(char *keyNamePassed, char *keyValuePassed, char *keyTypePassed);
void PrintGroupTree();
void CreateGroupTree(int groupTypePassed, char *hostIdPassed);

GroupTree global, *curGroupTree, *topGroupTree, *tmpGroupTree;
KeyValTree *curKeyValTree,*topKeyValTree, *tmpKeyValPtr, *tmpGloKeyValPtr, *tmpHostKeyValPtr;
%}


%union {char *str; GroupTree *g; KeyValTree *kv;}
%token<str> VAR INT FLOAT STR QUOTE COM HOSTID
%token EQ GLO HOST FSLASH BSLASH OBRACE CBRACE SCOLON ERROR
%type<str> hostid glo
%type<g> global hosts
%type<kv> keyvalpair

%%
prog:
global
|   global hosts {};

global:
glo OBRACE keyvalpair CBRACE    {
	PrintGroupTree();
	};
|   glo OBRACE CBRACE   {
	PrintGroupTree();
};
|   global SCOLON   {};

glo:
GLO {
	CreateGroupTree(0,"\0");
//    printf(">>Created global<<\n");
};


hosts:
HOST hostid OBRACE CBRACE   {
		PrintGroupTree();
};
|   HOST hostid OBRACE keyvalpair CBRACE    {
		PrintGroupTree();
    };
|   hosts hosts     {};
|   hosts SCOLON    {};

hostid:
    HOSTID  {
		CreateGroupTree(1,$1);
//        printf(">>Created host: %s<<\n", $1);
    };


keyvalpair:
VAR EQ INT  {
    $$ = CreateKeyValPair($1,$3,"I");
//    printf("\t%s\t%s=%s\n",$$->keyType,$$->keyName,$$->keyValue);
};
|   VAR EQ FLOAT  {
    $$ = CreateKeyValPair($1,$3,"F");
//    printf("\t%s\t%s=%s\n",$$->keyType,$$->keyName,$$->keyValue);
    
};
|   VAR EQ QUOTE  {
    $$ = CreateKeyValPair($1,$3,"Q");
//    printf("\t%s\t%s=%s\n",$$->keyType,$$->keyName,$$->keyValue);
    
};
|   VAR EQ STR  {
    $$ = CreateKeyValPair($1,$3,"S");
//    printf("\t%s\t%s=%s\n",$$->keyType,$$->keyName,$$->keyValue);
    
};
|   keyvalpair SCOLON       {
        printf ("ERR:P:%d\n",startScolonLine);
		exit(0);
};
|   keyvalpair keyvalpair   {};



%%

/*
 Some alternatives:
 global:
 GLO OBRACE rest    {};
 
 rest:
 keyvalpair CBRACE
 |   CBRACE
 |   rest SCOLON
 
 using val for INT, FLOAT, QUOTE, STRING
 val:
 INT {$$=$1;};
 |   FLOAT   {   $$=$1;  };
 |   QUOTE   {$$=$1;};
 |   STR     {$$=$1;};

 | error { printf("Error before we saw a variable name.\n"); exit(0); }
 | SCOLON     {};
 
 groups:
 GLO OBRACE CBRACE {
 //        $$ = (tree_t *)malloc(sizeof(tree_t));
 //        $$->var_name=$1; $$->var_value=$3; $$->next=0;
 $$ = $1;
 printf(">>%s<<\n",$1);
 }
 
 
 GroupTree *g; KeyValTree *kv
 %type<g> groups

 | VARIABLE error EQ INT { printf("Error after a variable name.\n"); exit(0);}
 | VARIABLE EQ error INT { printf("Error after equals sign.\n"); exit(0);}

 
 X = 12 Y = 13 END
 
*/

int main() {
    
    FILE *myfile = fopen("test/test.cfg", "r");
    // make sure it's valid:
	if (!myfile) {
		printf("ERR:F:\n");
		return 0;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	yyparse();
}

KeyValTree* CreateKeyValPair(char *keyNamePassed, char *keyValuePassed, char *keyTypePassed)
{
	KeyValTree *newKeyValPtr = (KeyValTree *)malloc(sizeof(KeyValTree));
    newKeyValPtr->keyName = keyNamePassed;
    newKeyValPtr->keyValue = keyValuePassed;
    newKeyValPtr->keyType = keyTypePassed;
    newKeyValPtr->nextKeyVal = 0;

	if(topKeyValTree==0)
    {
        topKeyValTree = newKeyValPtr;
        curKeyValTree = topKeyValTree;
    }
    else
    {
        curKeyValTree->nextKeyVal = newKeyValPtr;
        curKeyValTree = curKeyValTree->nextKeyVal;
    }
	return newKeyValPtr;
}

void PrintGroupTree()
{
	curGroupTree->keyValPairsPtr = topKeyValTree;
	//        printf(">>Linked Keys to %s<<\n",curGroupTree->hostId);
	
	tmpGroupTree = curGroupTree;
	tmpKeyValPtr = tmpGroupTree->keyValPairsPtr;
	if(tmpGroupTree->groupType==0)
	{
		printf("GLOBAL:\n");
	}
	else
	{
		printf("HOST %s:\n",tmpGroupTree->hostId);
	}
	while(tmpKeyValPtr)
	{
		printf("    %s:",tmpKeyValPtr->keyType);
		
		if(tmpGroupTree->groupType!=0)
		{
			tmpGloKeyValPtr = topGroupTree->keyValPairsPtr;
			
			while(tmpGloKeyValPtr)
			{
				if(!strcmp(tmpGloKeyValPtr->keyName,tmpKeyValPtr->keyName))
				{
					override = 1;
				}
				tmpGloKeyValPtr = tmpGloKeyValPtr->nextKeyVal;
			}
		}
		
		tmpHostKeyValPtr = curGroupTree->keyValPairsPtr;
		while(tmpHostKeyValPtr && tmpHostKeyValPtr!=tmpKeyValPtr)
		{
			if(!strcmp(tmpHostKeyValPtr->keyName,tmpKeyValPtr->keyName))
			{
				override = 1;
			}
			tmpHostKeyValPtr = tmpHostKeyValPtr->nextKeyVal;
		}
		
		if(override==1)
		{
			printf("O");
			override=0;
		}
		printf(":%s:",tmpKeyValPtr->keyName);
		
		if(strcmp(tmpKeyValPtr->keyType,"Q")==0)
		{
			printf("\"\"\"");
		}
		
		printf("%s",tmpKeyValPtr->keyValue);
		if(strcmp(tmpKeyValPtr->keyType,"Q")==0)
		{
			printf("\"\"\"");
		}
		printf("\n");
		tmpKeyValPtr = tmpKeyValPtr->nextKeyVal;
	};
}

void CreateGroupTree(int groupTypePassed, char *hostIdPassed)
{
	tmpGroupTree = (GroupTree *)malloc(sizeof(GroupTree));
    tmpGroupTree->groupType = groupTypePassed;
    tmpGroupTree->nextGroup = 0;

	topKeyValTree = 0;
	tmpGroupTree->keyValPairsPtr = topKeyValTree;

	if(groupTypePassed == 0)
	{
		topGroupTree = tmpGroupTree;
		curGroupTree = tmpGroupTree;
	}
	else
	{
        tmpGroupTree->hostId = hostIdPassed;
        curGroupTree->nextGroup = tmpGroupTree;
        curGroupTree = curGroupTree->nextGroup;
	}
}

void yyerror (char *s) {
    if(lexError==0)
    {
        printf ("ERR:P:%d\n",lineNumber);
    }
}
