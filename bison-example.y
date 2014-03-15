%error-verbose /* instruct bison to generate verbose error messages*/
%{
/* enable debugging of the parser: when yydebug is set to 1 before the
* yyparse call the parser prints a lot of messages about what it does */
#define YYDEBUG 1
%}


%{
#include <stdio.h>
#include <stdlib.h>
#include "example.h"
GroupTree global, *curGroupTree, *curKeyValTree;

%}


%union {char *str; GroupTree *g; KeyValTree *kv;}
%token<str> VAR INT FLOAT STR QUOTE COM HOSTID
%token EQ GLO HOST FSLASH BSLASH OBRACE CBRACE SCOLON ERROR

%%
prog:
global
|   global hosts {
//                    printf("Value at cur: 0x%08x\n",cur);
//                    printf("Address of top: 0x%08x\n",&top);
//                  cur->next = $1; cur = cur->next;
//                    printf("value at top.next 0x%08x\n",top.next);
//                  printf("Assign %s to %s!\n", cur->var_value, cur->var_name);
//                    printf(">>string accepted<<\n");
                }
global:
GLO OBRACE keyvalpair CBRACE    {};
|   GLO OBRACE CBRACE   {};
|   global SCOLON   {};


/*  Alternate implementation
global:
GLO OBRACE rest    {};

rest:
keyvalpair CBRACE
|   CBRACE
|   rest SCOLON
*/


hosts:
HOST HOSTID OBRACE CBRACE   {
    printf("Created host:");
    };
|   HOST HOSTID OBRACE keyvalpair CBRACE    {

//    $$ = (GroupTree *)malloc(sizeof(GroupTree));
//    $$->groupType = $1;
//    $$->keyVal = $4;
//    $$->next = 0;
    printf("Created host:");
    };
|   hosts hosts     {};
|   hosts SCOLON    {};


keyvalpair:
VAR EQ val  {
    /*
    $$ = (KeyValTree *)malloc(sizeof(KeyValTree));
    $$->keyName = $1;
    $$->keyValue = $3;
    $$->next = 0;
    printf("Set %s=>%s\n",$1,$3);
     */
    };
|   keyvalpair SCOLON       {};
|   keyvalpair keyvalpair   {};

val:
INT {};
|   FLOAT   {};
|   QUOTE   {};
|   STR     {};


%%

/*
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
    
    FILE *myfile = fopen("x2.cfg", "r");
    // make sure it's valid:
	if (!myfile) {
		printf("I can't open test.cfg!\n");
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
    
//    
//  top.next = 0;
//  cur      = &top;
//  printf("value at cur: 0x%08x\n",cur);
//  printf("Address of top: 0x%08x\n",&top);

  yyparse();
  printf("Let's walk the tree again:\n");
/*
 
    cur = top.next; // The first node was a dummy node representing the <prog> production.
//  printf("value at cur: 0x%08x\n", cur);
  
  while (cur) {
    printf("%s: %s\n", cur->var_name, cur->var_value);
    cur = cur->next;
  }
  */
}

void yyerror (char *s) {
  printf ("%s\n", s);
}
