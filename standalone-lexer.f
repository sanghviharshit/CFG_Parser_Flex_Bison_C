%{
#define VAR    100
#define EQ       101
#define INT      102
#define END      103
#define COM 104
#define GLO 105
#define FSLASH  106
#define OBRACE  107
#define CBRACE  108
#define SCOLON  109
#define QUOTE   110
#define FLOAT   111
#define BSLASH  112
#define HOST    113
#define SIGN    114
#define STR     115
%}

%option noyywrap
digit   [0-9]
sign    "+"|"-"
space   [ \t]
hostid  [0-9a-zA-Z]|[_\-\.]
%%

"/"         {   return  FSLASH; }
"{"         {   return  OBRACE; }
"}"         {   return  CBRACE; }
";"         {   return  SCOLON; }
"\\"        {   return  BSLASH; }
"="         {   return  EQ;     }


"#"[^\n]*   {   printf("Comment: (Ignored) >>%s<<\n", yytext);   return COM; }

"global"/[ \t]*"{"[^}]*"}"[;]*    {     printf("Found Global Group\n"); return  GLO;    }

"host"/{space}+{hostid}+[ \t]*"{"[^}]*"}"[ \t]*[;]*    {   printf("Found Host Group\n"); return  HOST;   }

{hostid}+/[ \t]*"{"[^}]*"}"[ \t\n]*[;]*  {   printf("Host ID: >>%s<<\n", yytext);    return STR; }

[_a-zA-Z][_[:alnum:]]*/[ \t]*"="  { printf("Key: >>%s<<\n", yytext); return VAR; }

\"(\\.|[^"])*\"$  {   printf("Value: Quoted String with/without BSLASH: >>%s<<\n", yytext); return QUOTE;  }
"/"[_/\.a-zA-Z0-9]+$   {   printf("Value: Unquoted String starting with FSLASH: >>%s<<\n", yytext); return STR;  }
[a-zA-Z][_/\.a-zA-Z0-9]+$    {   printf("Value: Unquoted String without FSLASH: >>%s<<\n", yytext); return STR;  }
{digit}+$   { printf("Value: Int: >>%s<<\n", yytext); return INT;  }
{sign}?{space}*{digit}+.{digit}+$   { printf("Value: Float: >>%s<<\n", yytext); return FLOAT;  }


[ \n\t]+   {} /* Ignore white space. */
.          {printf("Unrecognized character: %c\n", yytext[0]);}

%%

/*

*/

int main(int argc, char **argv) {
  int n;

  while(1) {
    n = yylex();
    printf("Token type: %d\n", n);
    if (!n) /* End of file */
      return 0;
  }
}
