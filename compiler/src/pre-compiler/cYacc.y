/* cYacc.y */
%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "fileUtils.h"

#define ADDR_BEGIN_STACK 		(int) 0x000000FF
#define ADDR_BEGIN_MAIN 		(int) 0x00000000
#define _TAILLE_IDENT 			49
#define LENGTH_TABLE_SYMB 		50
#define LENGTH_TABLE_ETIQUETTE_ADDR 	256
#define LENGTH_STACK_ENDIF              256
#define printASM(...)			line++; fprintf(fd,"%d:\t",line); fprintf(fd, __VA_ARGS__)


extern int yylineno;

  typedef struct row {
    char nom[_TAILLE_IDENT];
    int profondeur;
    int constante;
    int initialise;
    int* addrPile;
  } Row;

  Row tableSymboles[LENGTH_TABLE_SYMB];
  int indiceTable = 0;

  int profondeur = 0;
  int topStack = 0;

  /* ligne de l'instruction assembleur courante */
  int line = 0;

  /* numero de l'etiquette actuelle pour les sauts */
  int etiquette = 0;
  int tableEtiquetteAddr[LENGTH_TABLE_ETIQUETTE_ADDR];

  /* pile etiquette de fin de if */
  int topStackLabelEndIf = -1;
  int stackLabelEndIf[LENGTH_STACK_ENDIF];

  /* Indique si presence erreur de syntaxe */
  int syntaxError = 0;

  int isAlreadyDeclared(char * ident); 
  int isAlreadyDeclaredInThisScope(char * ident, int profondeur);
  int isLengthAcceptable(char * ident);
  void popLevel(void);
  void printSymbole(void);
  void belong(char * ident);
  int isAlreadyAffected(char * ident);
  int isConstant(char * ident); 
  int getIndiceVar(char* ident);
  void initTableEtiquetteAddr();
  void insertAddrEtiquette(int addr);
  void printTableEtiquette();
  int searchLabelForWhile();
%}

%union {
  int ival;
  char * string;
}

%token <ival> tNOMBRE
%token <string> tMAIN tIDENT tCONST tINT tAFFECT tPRINTF tINF tSUP tSUP_EQ tINF_EQ tEQUAL tNOT_EQUAL tAND tOR tIf tElse tWhile

%start startLine
%right tAFFECT
%left tOR
%left tAND
%left tEQUAL tNOT_EQUAL tINF tSUP tSUP_EQ tINF_EQ
%right '!'
%left '+' '-'
%left '*' '/'


%%

/* Structure générale du fichier.c (pour l'instant pas de fonction) */
startLine : 		tMAIN '{' CORPS '}';

CORPS : 		{ fprintf(fd, "- begin declarations -\n");} DECLARATIONS { fprintf(fd, "- end declarations -\n"); } INSTRUCTIONS;

/* partie déclarations */
DECLARATIONS :		DECLARATIONS_CONST
			| DECLA_NOT_CONST
			| ;

DECLARATIONS_CONST : 	tCONST tINT INTER_DECLA_CONST ';' DECLARATIONS; 

INTER_DECLA_CONST :   	DECLA_CONST_FINAL 
		     	| DECLA_CONST_FINAL ',' INTER_DECLA_CONST;

DECLA_CONST_FINAL :	tIDENT tAFFECT '+' tNOMBRE 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				 
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 1;
				  tableSymboles[indiceTable].constante = 1;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				  topStack++;
				
				  printASM("AFC %p %d\n", tableSymboles[indiceTable].addrPile,$4);
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	
				  indiceTable++;
				
				  free($1);
				}
			| tIDENT tAFFECT tNOMBRE 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				 
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 1;
				  tableSymboles[indiceTable].constante = 1;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				  topStack++;
				
				  printASM("AFC %p %d\n", tableSymboles[indiceTable].addrPile,$3);
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	
				  indiceTable++;
				
				  free($1);
				}
			| tIDENT tAFFECT '-' tNOMBRE 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				 
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 1;
				  tableSymboles[indiceTable].constante = 1;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				  topStack++;
				
				  printASM("AFC %p %d\n", tableSymboles[indiceTable].addrPile,-$4);
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	
				  indiceTable++;
				
				  free($1);
				};


DECLA_NOT_CONST :	tINT INTER_DECLA ';' DECLARATIONS ;

INTER_DECLA :		DV 
               		| DV ',' INTER_DECLA ;

DV :			tIDENT 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				 
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 0;
				  tableSymboles[indiceTable].constante = 0;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				
				  // pour les programmeurs pas doués
				  printASM("AFC %p 0\n", tableSymboles[indiceTable].addrPile);	
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	

				  topStack++;
				  indiceTable++;
				  free($1);
				}
                        | tIDENT tAFFECT tNOMBRE 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 1;
				  tableSymboles[indiceTable].constante = 0;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				
				     
				  printASM("AFC %p %d\n", tableSymboles[indiceTable].addrPile,$3);	
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	

				  topStack++;
				  indiceTable++;
				  free($1);
				}
			| tIDENT tAFFECT '+' tNOMBRE 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 1;
				  tableSymboles[indiceTable].constante = 0;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				
				     
				  printASM("AFC %p %d\n", tableSymboles[indiceTable].addrPile,$4);	
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	

				  topStack++;
				  indiceTable++;
				  free($1);
				}
			| tIDENT tAFFECT '-' tNOMBRE 
				{ // On vérifie si l'identifiant est déjà présent dans la table
				  isLengthAcceptable($1);
				
				  if (isAlreadyDeclaredInThisScope($1, profondeur)) {
				    printf("%d: Erreur : variable '%s' deja declaree\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  strncpy(tableSymboles[indiceTable].nom,$1, _TAILLE_IDENT);
				  tableSymboles[indiceTable].initialise = 1;
				  tableSymboles[indiceTable].constante = 0;
				  tableSymboles[indiceTable].profondeur = profondeur;
				  tableSymboles[indiceTable].addrPile = (int*) (ADDR_BEGIN_STACK - topStack);
				
				     
				  printASM("AFC %p %d\n", tableSymboles[indiceTable].addrPile,-$4);	
			          printASM("NOP\n"); // affectation transformée plus tard en 2 instructions	

				  topStack++;
				  indiceTable++;
				  free($1);
				};
      

/* partie instructions */
OPERANDE :		tNOMBRE 
				{ // récupératon de la dernière opérande de la ligne, et mise de la valeur dans R2
				  printASM("AFC %p %d\n", (int*) (ADDR_BEGIN_STACK - topStack), $1);
				  topStack++;
				}
                      	| tIDENT 
				{ if (!isAlreadyDeclared($1)) {
				    printf("%d: Erreur : %s non declare\n",yylineno,$1);
				    syntaxError = 1;
				  } else if (!isAlreadyAffected($1)) {
				    printf("%d: warning : %s n'a pas ete initialisee.\n",yylineno,$1);
				  }
				
				  // On récupère la valeur associé à l'identifiant et on load sa valeur dans R2
				  printASM("COP %p %p\n", (int*) (ADDR_BEGIN_STACK - topStack), tableSymboles[getIndiceVar($1)].addrPile);
				  topStack++;
				
				  free($1);
				}
			| '+' tNOMBRE 
				{ // récupératon de la dernière opérande de la ligne, et mise de la valeur dans R2
				  printASM("AFC %p %d\n", (int*) (ADDR_BEGIN_STACK - topStack), $2);
				  topStack++;
				}
                      	| '+' tIDENT 
				{ if (!isAlreadyDeclared($2)) {
				    printf("%d: Erreur : %s non declare\n",yylineno,$2);
				    syntaxError = 1;
				  } else if (!isAlreadyAffected($2)) {
				    printf("%d: warning : %s n'a pas ete initialisee.\n",yylineno,$2);
				  }
				
				  // On récupère la valeur associé à l'identifiant et on load sa valeur dans R2
				  printASM("COP %p %p\n", (int*) (ADDR_BEGIN_STACK - topStack), tableSymboles[getIndiceVar($2)].addrPile);
				  topStack++;
				
				  free($2);
				}
			| '-' tNOMBRE 
				{ // récupératon de la dernière opérande de la ligne, et mise de la valeur dans R2
				  printASM("AFC %p %d\n", (int*) (ADDR_BEGIN_STACK - topStack), -$2);
				  topStack++;
				}
                      	| '-' tIDENT 
				{ if (!isAlreadyDeclared($2)) {
				    printf("%d: Erreur : %s non declare\n",yylineno,$2);
				    syntaxError = 1;
				  } else if (!isAlreadyAffected($2)) {
				    printf("%d: warning : %s n'a pas ete initialisee.\n",yylineno,$2);
				  }
				
				  // On récupère la valeur associé à l'identifiant et on load sa valeur dans R2
      				  printASM("AFC %p %d\n",(int *)(ADDR_BEGIN_STACK - topStack), 0);
				  printASM("SUB %p %p %p\n",
					(int *)(ADDR_BEGIN_STACK - topStack), 
					(int *)(ADDR_BEGIN_STACK - topStack), 
					tableSymboles[getIndiceVar($2)].addrPile);
				  //printASM("COP %p %p\n", (int*) (ADDR_BEGIN_STACK - topStack), tableSymboles[getIndiceVar($2)].addrPile);
				  topStack++;
				
				  free($2);
				};



EXPR:			'(' EXPR ')'
			| OPERANDE
			| EXPR '+' EXPR 
				{ topStack--; 
				  printASM("ADD %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)),
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}
			| EXPR '-' EXPR 
				{ topStack--; 
				  printASM("SUB %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), (
						int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}
			| EXPR '*' EXPR 
				{ topStack--; 
				  printASM("MUL %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}
			| EXPR '/' EXPR 
				{ topStack--; 
				  printASM("DIV %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}
			| EXPR tNOT_EQUAL EXPR 
				{ topStack--;
				  printASM("EQU %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack));
				
				  // not <=> a = 1 - a quand a = 1 ou 0
				  printASM("AFC %p 1\n", (int*) (ADDR_BEGIN_STACK - topStack));
				  printASM("SUB %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1))) ;
				}
			| EXPR tEQUAL EXPR 
				{ topStack--; 
				  printASM("EQU %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}

			| EXPR tINF EXPR 
				{ topStack--; 
				  printASM("INF %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}

			| EXPR tSUP EXPR 
				{ topStack--; 
				  printASM("SUP %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}

			| EXPR tSUP_EQ EXPR 
				{ topStack--; 
				  printASM("INF %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack))); 
				  // récupératon de la dernière opérande de la ligne, et mise de la valeur dans R2
                                  printASM("AFC %p %d\n", (int*) (ADDR_BEGIN_STACK - topStack), 0);
                                  //topStack++;
				  //topStack--;
                                  printASM("EQU %p %p %p\n",
                                                (int*) (ADDR_BEGIN_STACK - (topStack - 1)),
                                                (int*) (ADDR_BEGIN_STACK - (topStack - 1)),
                                                (int*) (ADDR_BEGIN_STACK - topStack));
				}

			| EXPR tINF_EQ EXPR 
				{ topStack--; 
				  printASM("SUP %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack))); 

				  // récupératon de la dernière opérande de la ligne, et mise de la valeur dans R2
                                  printASM("AFC %p %d\n", (int*) (ADDR_BEGIN_STACK - topStack), 0);
                                  //topStack++;
				  //topStack--;
                                  printASM("EQU %p %p %p\n",
                                                (int*) (ADDR_BEGIN_STACK - (topStack - 1)),
                                                (int*) (ADDR_BEGIN_STACK - (topStack - 1)),
                                                (int*) (ADDR_BEGIN_STACK - topStack));
				}

			| EXPR tAND EXPR 
				{ topStack--; 
				  printASM("MUL %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}

			| EXPR tOR EXPR 
				{ topStack--; 
				  printASM("ADD %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack)); 
				}

			| '!' EXPR 
				{ // on charge 1 dans un registre
				  printASM("AFC %p 1\n", (int*) (ADDR_BEGIN_STACK - topStack));
				
				  // on soustrait 1 à la valeur sur laquelle on va faire le NOT et le résultat du INF donne un NOT
				  printASM("SUB %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack));
				  printASM("AFC %p 0\n", (int*) (ADDR_BEGIN_STACK - topStack));
				  printASM("INF %p %p %p\n", 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - (topStack - 1)), 
						(int*) (ADDR_BEGIN_STACK - topStack));
				} 
			;


BLOC:                   '{' { profondeur++; } CORPS { popLevel(); profondeur--;} '}';

COND_BLOC : 		'(' EXPR ')' ;

INTER_IF : 		tElse tIf 
				{ insertAddrEtiquette(line+2); 
				  printASM("JMP $%d\n",stackLabelEndIf[topStackLabelEndIf]);
				} 
			COND_BLOC 
				{ topStack--; 
				  printASM("JMF %p $%d\n",
						(int*) (ADDR_BEGIN_STACK - topStack),
						etiquette); etiquette++; 
				}  
			BLOC INTER_IF
                        | tElse 
				{ insertAddrEtiquette(line+2); 
				  printASM("JMP $%d\n",stackLabelEndIf[topStackLabelEndIf]);
				} 
			BLOC 
				{ insertAddrEtiquette(line+1);
				  tableEtiquetteAddr[stackLabelEndIf[topStackLabelEndIf]] = line+1; topStackLabelEndIf--;
				}
			| { insertAddrEtiquette(line+1); tableEtiquetteAddr[stackLabelEndIf[topStackLabelEndIf]] = line+1;topStackLabelEndIf--;}
			;

INSTRUCTIONS :   	tIDENT tAFFECT EXPR ';' 
				{  
				
				  if (!isAlreadyDeclared($1)) {
				    printf("%d: Erreur : %s non declare\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  if ( isConstant($1) ) {
				    printf("%d: Erreur : %s est une constante, affectation impossible\n",yylineno,$1);
				    syntaxError = 1;
				  }
				
				  topStack--;
				  printASM("COP %p %p\n", tableSymboles[getIndiceVar($1)].addrPile, (int*) (ADDR_BEGIN_STACK - topStack));
				
				  free($1);
				} 
			INSTRUCTIONS

			| tIf COND_BLOC 
				{ topStack--; 
				  topStackLabelEndIf++; 
				  stackLabelEndIf[topStackLabelEndIf] = etiquette ; etiquette++; 
				  printASM("JMF %p $%d\n",(int*) (ADDR_BEGIN_STACK - topStack),etiquette); etiquette++; 
				} 
			BLOC INTER_IF INSTRUCTIONS

                	| tWhile {etiquette++; insertAddrEtiquette(-(line+1)); } COND_BLOC 
				{ topStack--; 
				  printASM("JMF %p $%d\n",(int*) (ADDR_BEGIN_STACK - topStack),etiquette); etiquette++;  
				}  
			BLOC {insertAddrEtiquette(line+2); printASM("JMP $%d\n",searchLabelForWhile()); }
			INSTRUCTIONS

                        | BLOC INSTRUCTIONS
			| tPRINTF '(' EXPR ')' ';'
				{ topStack--;
				  printASM("PRI %p\n", (int*) (ADDR_BEGIN_STACK - topStack));
				} 
			INSTRUCTIONS
			| ;
       

%%

/* On  s'en sert pour savoir si lorsqu'on utilise une variable elle est déclaré ou non */
int isAlreadyDeclared(char * ident) {

  int i;
  int equal, declared = 0;
  
  for (i = 0 ; i < indiceTable && !declared ; i++) {
  
    equal = strcmp(tableSymboles[i].nom,ident);
 
    declared = equal == 0; //&& tableSymboles[i].profondeur <= profondeur;

  }

  return declared;
}

/* On s'en sert pour savoir lors d'une déclaration de variable pour savoir si elle a déjà été déclaré */
int isAlreadyDeclaredInThisScope(char * ident , int profondeur) {
  
  int i;
  int equal, declared = 0;
  
  for (i = 0 ; i < indiceTable && !declared ; i++) {
  
    equal = strcmp(tableSymboles[i].nom,ident);
 
    declared = equal == 0 && tableSymboles[i].profondeur == profondeur;

  }

  return declared;
}


int isLengthAcceptable(char * ident) {

  if (strlen(ident) > _TAILLE_IDENT) {
    printf("%d: Erreur : '%s' : identificateur de variable trop long\n", yylineno,ident);
    syntaxError = 1;
  }

  return 1;
}

void popLevel(void) {
  
  int i, levelFinished = 0;
  
  for (i = indiceTable - 1; i > 0 && tableSymboles[i].profondeur == profondeur; i--) {
	topStack--;
  }

  indiceTable = i+1;
}

void printSymbole(void) {
  
  int i;
  
  for (i = 0; i < indiceTable; i++) {
    printf("nom = %s, profondeur = %d, const = %d, initialise = %d, adresseStack = %p\n", tableSymboles[i].nom, tableSymboles[i].profondeur, tableSymboles[i].constante, tableSymboles[i].initialise, tableSymboles[i].addrPile);
  }
  
  printf("---topStack = %p---\n", (void*) (ADDR_BEGIN_STACK - topStack));
}


int isAlreadyAffected(char * ident) {

  int i;
  int equal,affected = 0;
  // On part de la fin pour avoir la variable de meme nom la plus profonde
  for (i = indiceTable - 1 ; i >= 0 && !affected ; i--) {
  
    equal = strcmp(tableSymboles[i].nom,ident);
 
    affected = equal == 0 && tableSymboles[i].initialise == 1;

  }

  return affected;
}

int isConstant(char * ident) {

  int i;
  int trouve = 0, constante = 0;

  // On part de la fin pour avoir la variable de meme nom la plus profonde
  for (i = indiceTable - 1 ; i >= 0 && !trouve ; i--) {
  
    if(strcmp(tableSymboles[i].nom, ident) == 0) {
    	trouve = 1;
	constante = tableSymboles[i].constante;
    }
  }

  return constante;
}

int getIndiceVar(char* ident) {

  int i;
  int equal, trouve = -1;
  // On part de la fin pour avoir la variable de meme nom la plus profonde
  for (i = indiceTable - 1 ; i >= 0 && trouve == -1 ; i--) {

    equal = strcmp(tableSymboles[i].nom,ident);
    if(equal == 0) {
	trouve = i;
    }
  }

  return trouve;
}


/* initialise la table des étiquettes */
void initTableEtiquetteAddr() {

  int i;
  for (i = 0 ; i < LENGTH_TABLE_ETIQUETTE_ADDR ; i++) {
    tableEtiquetteAddr[i] = 0;
  }

}

/* place l'adresse de l'etiquette addrEtiquette au bon endroit dans le tableau
   des étiquettes  */
void insertAddrEtiquette(int addr) {

  // vérif si on peut stocker l'etiquette
  if (etiquette >= LENGTH_TABLE_ETIQUETTE_ADDR) {
    printf("Erreur : Table des étiquettes overflow : trop de saut dans le programme\n");
    deleteOutFile();
    exit(1);
  }


  int i;
  for (i = etiquette-1 ; i >= 0 && tableEtiquetteAddr[i] != 0 ; i--);
 
  tableEtiquetteAddr[i] = addr;
}


void printTableEtiquette() {

  printf("------------- TABLE DES ETIQUETTES -------------- \n");
  
  int i;
  
  for ( i = 0 ; i < etiquette ; i++) {
    printf("$%d => %d\n",i,tableEtiquetteAddr[i]);
  }

}
/* renvoie la numéro de la dernière étiquette insérée pour un while */
int searchLabelForWhile() {
  
 // vérif si on peut stocker l'etiquette
  if (etiquette >= LENGTH_TABLE_ETIQUETTE_ADDR) {
    printf("Erreur : Table des étiquettes overflow : trop de saut dans le programme\n");
    deleteOutFile();
    exit(1);
  }


  int i;
  // recherche d'un label non traite pour un while (val etiquette negative)
  for (i = etiquette-1 ; i >= 0 && tableEtiquetteAddr[i] >= 0 ; i--);
 
  tableEtiquetteAddr[i] *= -1 ; // inversion du signe => label traite

  return i;

}


/* Arrête la compilation si détection erreur(s) de syntaxe */
void detectedSyntaxError() {
  if (syntaxError == 1) {
    deleteOutFile();
    printf("------- Erreur(s) de syntaxe détectée(s) - la compilation a échouée. \n");
    exit(1);
  } // else : syntaxe ok => poursuite compilation
}

int main(int argc, char ** argv) {
  initOutFile();
  initTableEtiquetteAddr();
  yyparse();
  //printTableEtiquette();
  detectedSyntaxError();
  replaceLabel(tableEtiquetteAddr);
  return 0;
  //return yyparse();
}

