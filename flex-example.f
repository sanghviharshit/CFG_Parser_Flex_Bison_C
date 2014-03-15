%{
#include "example.h"
#include "bison-example.tab.h"
%}

%option noyywrap
digit   [0-9]
sign    "+"|"-"
space   [ \t]
alnum   [0-9a-zA-Z]
hostid  [0-9a-zA-Z]|[_\-\.]
comment "#"[^\n]*$
%%


"#"[^\n]*$   {   printf("Comment: (Ignored) >>%s<<\n", yytext);  }

^"global"/[ \t]*"{"[^}]*"}"[;]*    {    printf("Found Global Group\n"); yylval.str=strdup(yytext); return  GLO;    }

^"host"/{space}+{hostid}+[ \t]*"{"[^}]*"}"[ \t]*[;]*    {   printf("Found Host Group: %s\n",yytext); return  HOST;   }

{hostid}+/[ \t]*"{"[^}]*"}"[ \t]*[;]*  {   printf("Host ID: >>%s<<\n", yytext); yylval.str=strdup(yytext);   return HOSTID; }

[_a-zA-Z][_0-9a-zA-Z]*/[ \t]*"="  { printf("Key: >>%s<<\n", yytext); return VAR; }

\"(\\.|[^"])*\"  {   printf("Value: Quoted String with/without BSLASH: >>%s<<\n", yytext); return QUOTE;  }
"/"[_//.a-zA-Z0-9]+   {   printf("Value: Unquoted String starting with FSLASH: >>%s<<\n", yytext); return STR;  }
[a-zA-Z][_/\.a-zA-Z0-9]+ {   printf("Value: Unquoted String without FSLASH: >>%s<<\n", yytext); return STR;  }
{digit}+  { printf("Value: Int: >>%s<<\n", yytext); return INT;  }
{digit}+"."{digit}+   { printf("Value: Float: >>%s<<\n", yytext); return FLOAT;  }


"/"         {/*   printf(">>%s<<\n", yytext);*/  return  FSLASH; }
"{"         {/*   printf(">>%s<<\n", yytext);*/  return  OBRACE; }
"}"         {/*   printf(">>%s<<\n", yytext);*/  return  CBRACE; }
";"         {/*   printf(">>%s<<\n", yytext);*/  return  SCOLON; }
"\\"        {/*   printf(">>%s<<\n", yytext);*/  return  BSLASH; }
"="         {/*   printf(">>%s<<\n", yytext);*/  return  EQ;     }


[ \n\t]+   {} /* Ignore white space. */

.          {    printf("Unrecognized character: %c\n", yytext[0]);  return ERROR;   }


%%
