%{
#include "example.h"
#include "bison-example.tab.h"
/* Better parsing with
^"global"/[ \t]*"{"[^}]*"}"[;]*
^"host"/{space}+{hostid}+[ \t]*"{"[^}]*"}"[ \t]*[;]*
{hostid}+/[ \t]*"{"[^}]*"}"[ \t]*[;]*
*/

int lineNumber=0;
int lexError = 0;

char strBuf[100];

char *qStr;

%}

%x QSTRING


%option noyywrap
%option yylineno

digit   [0-9]
sign    "+"|"-"
space   [ \t]
alnum   [0-9a-zA-Z]
hostid  [0-9a-zA-Z]|[_\-\.]
comment "#"[^\n]*$
%%


"#"[^\n]*$  {
//    printf("Comment: (Ignored) >>%s<<\n", yytext);
}

^"global"/[ \t]*"{" {
//    printf("Found Global Group\n");
    return  GLO;
}

^"host"    {
//    printf("Found Host Group: %s\n",yytext);
    return  HOST;
}

{hostid}+/[ \t]*"{"   {
//    printf("Host ID: >>%s<<\n", yytext);
    yylval.str=strdup(yytext);
    return HOSTID;
}

[_a-zA-Z][_0-9a-zA-Z]*/[ \t]*"="  {
//    printf("Key: >>%s<<\n", yytext); yylval.str=strdup(yytext);
    yylval.str=strdup(yytext);
    return VAR;
}


\"				{
	BEGIN QSTRING;
	qStr = strBuf;
}

<QSTRING>"\\\\n"	{
//	printf("\nNL:");
	*qStr++ = '\n';
}

<QSTRING>"\\\\r"	{
	//	printf("\nNL:");
	*qStr++ = '\r';
}

<QSTRING>"\\\""	{
	*qStr++ = '\"';
}

<QSTRING>"\""      {
	*qStr = 0;
	BEGIN 0;
//	printf("found '%s'\n", strBuf);
	yylval.str=strdup(strBuf);
	return QUOTE;

}

<QSTRING>"\\".	{
	//	printf("\nNL:");
	*qStr++ = yytext[1];
}

<QSTRING>"\n"      {
//	printf("\t\t>>invalid string:%s<<\n",yytext);
	lexError = 1;
	printf("ERR:L:%d\n", yylineno);
	return ERROR;
}

<QSTRING>.       {
	*qStr++ = *yytext;
}


([/]|[a-zA-Z])+([_]|[/]|[.]|[\-]|[a-zA-Z0-9])*   {
//    printf("Value: Unquoted String: >>%s<<\n", yytext);
    yylval.str=strdup(yytext);
    return STR;
}


{sign}?{digit}+    {
//    printf("Value: Int: >>%s<<\n", yytext); yylval.str=strdup(yytext);
    yylval.str=strdup(yytext);
    return INT;
}

{sign}?{digit}+"."{digit}+ {
//    printf("Value: Float: >>%s<<\n", yytext); yylval.str=strdup(yytext);
    yylval.str=strdup(yytext);
    return FLOAT;
}


"/"         {
//    printf(">>%s<<\n", yytext);
    return  FSLASH;
}

"{"         {
//    printf(">>%s<<\n", yytext);
    return  OBRACE;
}

"}"         {
//    printf(">>%s<<\n", yytext);
    return  CBRACE;
}

";"         {
//    printf(">>%s<<\n", yytext);
    return  SCOLON;
}

"\\"        {
//    printf(">>%s<<\n", yytext);
    return  BSLASH;
}

"="         {
//    printf(">>%s<<\n", yytext);
    return  EQ;
}

[ \t]+   {
/* Ignore white space. */
}

"\0"	{
    lexError = 1;
	//    printf(">>%s<<\n", yytext);
    printf("ERR:L:%d\n", yylineno);
    return ERROR;
}

[\n]    {
    lineNumber = yylineno;
//    printf("Linenumner: %d\n",yylineno);
}

.          {
    lexError = 1;
//    printf(">>%s<<\n", yytext);
    printf("ERR:L:%d\n", yylineno);
    return ERROR;
}


%%
