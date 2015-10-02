/* cLex.l */

%{
#include "y.tab.h"
extern YYSTYPE yylval;
%}

D 		[0-9]+
E		[Ee]{D}+
I 		[a-zA-Z][a-zA-Z0-9_]*
Affectation 	=

%START COMMENT

%%

main[ \t]?\(\)			return tMAIN;
\/\*				{ BEGIN COMMENT; printf("start comment\n"); }
<COMMENT>\*\/			{ BEGIN 0; printf("end comment\n"); }
<COMMENT>.			{ printf("COMMENT\n");}
if				return tIf;
else				return tElse;
while				return tWhile;
const				return tCONST;
int				return tINT;
\{				return '{';
\}			 	return '}';	
\(				return '(';	
\)				return ')';	
,				return ',';	
printf				return tPRINTF;
\+	 			return '+';
-		    		return '-';
\*		      		return '*';
\/		      		return '/';
==				return tEQUAL;
!=				return tNOT_EQUAL;
\<				return tINF;
\>				return tSUP;
\>=				return tSUP_EQ;
\<=				return tINF_EQ;
!				return '!'; 
&&				return tAND;
\|\|				return tOR;
{I}				{yylval.string = strndup(yytext,strlen(yytext)+1); return tIDENT;}	
{D}{E}?	 			{yylval.ival= (int) strtod(yytext, NULL); return tNOMBRE ;}
{Affectation}			return tAFFECT;
;				return ';';
\n				{yylineno++;}	
[ \t]*				{}
.				printf("Erreur lexicale : %s\n",yytext);


%%
void yyerror(char *s)
{
   printf("%d: %s at %s lex precompilo\n", yylineno, s, yytext);
}

/*void main(void) {
  yylex();
}*/
