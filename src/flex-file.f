%{
#include "data-struct-file.h"
#include "bison-c-file.tab.h"
/* Better parsing with
^"global"/[ \t]*"{"[^}]*"}"[;]*
^"host"/{space}+{hostid}+[ \t]*"{"[^}]*"}"[ \t]*[;]*
{hostid}+/[ \t]*"{"[^}]*"}"[ \t]*[;]*
 
";"/[^;][ \t\n]*[^;]         {
 //    printf(">>%s<<\n", yytext);
 return  SCOLON;
 }
 
 ";"/[ \t]*[\n]+	{
 return ERROR;
 }
 
*/

int lineNumber=1;
int lexError = 0;
int startScolonLine = 0;
char strBuf[100];

char *qStr;

%}

%x QSTRING
%x SCLN

%option noyywrap
%option yylineno

digit   [0-9]
sign    "+"|"-"
space   [ \t]
alnum   [0-9a-zA-Z]
hostid  [0-9a-zA-Z]|[_]|[-]|[.]
comment "#"[^\n]*[\n]
endkeyval [ \t]*[}\n;#]+



%%

"#"[^\n]*/[\n]  {
//    printf("Comment: (Ignored) >>%s<<\n", yytext);
}

"global"/[ \t\n]*{comment}*{space}*[{] {
//    printf("Found Global Group\n");
    return  GLO;
}

"host"/[ \t\n]+{hostid}+[ \t\n]*[{#]    {
//    printf("Found Host Group: %s\n",yytext);
    return  HOST;
}

{hostid}+/[ \t\n]*{comment}*{space}*[{]   {
//    printf("Host ID: >>%s<<\n", yytext);
    yylval.str=strdup(yytext);
    return HOSTID;
}

[_a-zA-Z][_0-9a-zA-Z]*/[ \t\n]*"="  {
//    printf("Key: >>%s<<\n", yytext); yylval.str=strdup(yytext);
    yylval.str=strdup(yytext);
    return VAR;
}


([/]|[a-zA-Z])+([_]|[/]|[.]|[\-]|[a-zA-Z0-9])*/{endkeyval}	{
//    printf("Value: Unquoted String: >>%s<<\n", yytext);
    yylval.str=strdup(yytext);
    return STR;
}

{sign}?{digit}+/{endkeyval}  {
//	printf("Value: Int: >>%s<<\n", yytext); yylval.str=strdup(yytext);
    yylval.str=strdup(yytext);
    return INT;
}

{sign}?{digit}+"."{digit}+ {
//	printf("Value: Float: >>%s<<\n", yytext); yylval.str=strdup(yytext);
    yylval.str=strdup(yytext);
    return FLOAT;
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

<QSTRING>"\""/{endkeyval}	{
	*qStr = 0;
	BEGIN 0;
//	printf("QString: %s\n",yytext);
//    printf("LineNumber: %d\n",lineNumber);
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
	printf("ERR:L:%d\n", lineNumber);
	return ERROR;
}

<QSTRING>[ -~]       {
//	printf("%s",yytext);
	*qStr++ = *yytext;
}
<QSTRING>[^ -~]      {
	//	printf("\t\t>>invalid string:%s<<\n",yytext);
	lexError = 1;
	printf("ERR:L:%d\n", lineNumber);
	return ERROR;
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
	startScolonLine = lineNumber;
//    printf("Start SCOLON LineNumber: %d\n",lineNumber);
	BEGIN SCLN;
}

<SCLN>{space}*/[;]	{
	BEGIN 0;
//	printf("LineNumber: %d\n",lineNumber);
	return ERROR;
}

<SCLN>[\n]/";"	{
	lineNumber++;
//	printf("LineNumber: %d\n",lineNumber);
//	printf("\t=>%s<=\n",yytext);
	BEGIN 0;
	return ERROR;
}
<SCLN>[\n]	{
	lineNumber++;
//	printf("LineNumber: %d\n",lineNumber);
}


<SCLN>[\n]/{space}*[^;]+	{
	lineNumber++;
//    printf("LineNumber: %d\n",lineNumber);
//	printf("\t=>%s<=\n",yytext);
	BEGIN 0;
	return SCOLON;
}

<SCLN>{space}*/#	{
	BEGIN 0;
	return SCOLON;

}

"="         {
//    printf(">>%s<<\n", yytext);
    return  EQ;
}

{space}   {
/* Ignore white space. */
}

"\0"	{
    lexError = 1;
//    printf(">>%s<<\n", yytext);
    printf("ERR:L:%d\n", lineNumber);
    return ERROR;
}

[\n]    {
    lineNumber++;
//    printf("LineNumber: %d\n",lineNumber);
}

.          {
    lexError = 1;
//    printf(">>%s<<\n", yytext);
    printf("ERR:L:%d\n", lineNumber);
    return ERROR;
}


%%
