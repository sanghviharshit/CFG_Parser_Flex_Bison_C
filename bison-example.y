%{
#include <stdio.h>
#include <stdlib.h>
#include "example.h"
tree_t top, *cur;
%}

%union {char *str; tree_t *t;}
%token<str> VARIABLE INT
%token EQ END
%type<t> assign

%%
prog:
    assign prog {
//                    printf("Value at cur: 0x%08x\n",cur);
//                    printf("Address of top: 0x%08x\n",&top);
                  cur->next = $1; cur = cur->next;
//                    printf("value at top.next 0x%08x\n",top.next);
                  printf("Assign %s to %s!\n", cur->var_value, cur->var_name);
                }
    | error { printf("Error before we saw a variable name.\n"); exit(0); }
    | END     {};

assign:
     VARIABLE EQ INT { $$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                     }


   | VARIABLE error EQ INT { printf("Error after a variable name.\n"); exit(0);}
   | VARIABLE EQ error INT { printf("Error after equals sign.\n"); exit(0);}

%%

/*
X = 12 Y = 13 END
 */

int main() {
    
    FILE *myfile = fopen("test.cfg", "r");
    // make sure it's valid:
	if (!myfile) {
		printf("I can't open a.snazzle.file!\n");
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
    
    
  top.next = 0;
  cur      = &top;
//  printf("value at cur: 0x%08x\n",cur);
//  printf("Address of top: 0x%08x\n",&top);

  yyparse();
  printf("Let's walk the tree again:\n");

    cur = top.next; // The first node was a dummy node representing the <prog> production.
//  printf("value at cur: 0x%08x\n", cur);
  
  while (cur) {
    printf("%s: %s\n", cur->var_name, cur->var_value);
    cur = cur->next;
  }
}

void yyerror (char *s) {
  printf ("%s\n", s);
}
