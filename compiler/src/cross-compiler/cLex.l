/* cLex.l */

%{
#include "y.tab.h"
extern YYSTYPE yylval;
%}

D 		[0-9]
Addr 		0x[a-f0-9]+

%START COMMENT

%%
"- begin declarations -"	return tBEGINDECL;
"- end declarations -"		return tENDDECL;
ADD				return tADD;
MUL				return tMUL;
SUB				return tSUB;
DIV				return tDIV;
COP				return tCOP;
AFC				return tAFC;
JMP			 	return tJMP;	
JMF				return tJMF;	
INF				return tINF;	
SUP				return tSUP;	
EQU				return tEQU;
PRI				return tPRI;
NOP				return tNOP;
{Addr}				{yylval.addr = (unsigned char) ((unsigned int) strtod(yytext, NULL)); /*printf("%2.2X\n", yylval.addr);*/ return tADDR;}
{D}+:				{yylval.line = (unsigned int) atoi(yytext); /*printf("line n°%d\t", atoi(yytext));*/ return tNUMLINE;} 
[\+\-]?{D}+				{yylval.ival = (signed char) atoi(yytext); return tNBR ;}
\n				{}	
[ \t]*				{}
.				printf("Erreur lexicale : %s\n",yytext);

%%
void yyerror(char *s)
{
   printf("%d: %s at %s\n", yylineno, s, yytext);
}

/*void main(void) {
  yylex();
}*/
