/* cYacc.y */


%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "operation.h"
#include "registers.h"
#include "stack.h"

Operation* currentOP;
RegistersTable* tableRegistres;
Stack* stack;

unsigned int currentLine = 0;

%}

%union {
  signed char ival;
  unsigned char addr;
  unsigned int line;
  char* string;
}

%token <line> tNUMLINE
%token <ival> tNBR
%token <addr> tADDR
%token <string> tBEGINDECL tENDDECL tCOP tPRI tINF tSUP tAFC tJMP tJMF tEQU tMUL tADD tDIV tSUB tNOP

%start startLine

%%

startLine : 		INSTRUCTIONS ;

INSTRUCTIONS : 		tNUMLINE {currentLine = $1;} OPERATION {/*tableRegistres->print(tableRegistres); stack->print(stack);*/} INSTRUCTIONS
			| DECLARATION INSTRUCTIONS
			| ;

DECLARATION :		tBEGINDECL INSTRUCTIONS_DECL;

INSTRUCTIONS_DECL:	tNUMLINE {currentLine = $1;} tAFC tADDR tNBR {
				// RX sera le numéro du premier registre libre trouvé
				unsigned char numReg = tableRegistres->firstUnused(tableRegistres);
				unsigned char codeOP = _code_AFC;				
				// AFC RX $NBR
				currentOP->set(currentOP, numReg, codeOP, $5, 0);
				tableRegistres->setContent(tableRegistres, numReg, $5);
				printf("AFC R%u %d\t\t", numReg, $5);
				currentOP->print(currentOP);
				// STORE @topStack R0
				codeOP = _code_STORE;
				currentOP->set(currentOP, stack->getTop(stack), codeOP, numReg, 0);
				printf("STORE 0x%2.2X R%u\t\t", stack->getTop(stack), numReg);
				currentOP->print(currentOP);
				tableRegistres->setLastUsed(tableRegistres, numReg);
				tableRegistres->setLEAForReg(tableRegistres, numReg, $4);
				// on oublie pas de dire que le registre est désormais disponible
				tableRegistres->setUnused(tableRegistres, numReg);
				//tableRegistres->print(tableRegistres);

				stack->push(stack, $4);
				//stack->print(stack);
			} INSTRUCTIONS_DECL
			| tNUMLINE {currentLine = $1;} tNOP INSTRUCTIONS_DECL
			| tENDDECL;

OPERATION :		INST3OPERANDES
			| INST2OPERANDES
			| INST1OPERANDE
			| tNOP;

INST1OPERANDE :		tJMP tNBR {
				unsigned char codeOP = _code_JMP;
				currentOP->set(currentOP, 0, codeOP, (unsigned char) ($2 - currentLine), 0);
				printf("JMP %d\t\t\t", $2 - currentLine);
				currentOP->print(currentOP);
			}
			| tPRI tADDR {
			        unsigned char codeOP = _code_PRI;
				unsigned char numReg = tableRegistres->getRegForLEA(tableRegistres, $2);
			   	currentOP->set(currentOP, numReg, codeOP, 0, 0);
				printf("PRI R%u\t\t\t", numReg);
				currentOP->print(currentOP);

				// on libère le registre une fois avoir affiché la valeur
				tableRegistres->setUnused(tableRegistres, numReg);
			};

INST2OPERANDES:		tCOP tADDR tADDR {
				unsigned char codeOP;
				
				/* on a 3 cas possibles :
				 * Registre <- Registre COP
				 * Memoire <- Registre STORE
				 * Registre <- Mémoire LOAD
				 */

				unsigned char addr1Pile = stack->getPosAddr(stack, $2);
				unsigned char addr2Pile = stack->getPosAddr(stack, $3);
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
				unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				
				if(addr1Pile == 0 && addr2Pile == 0) { // COP Rx Ry
				  codeOP = _code_COP;
				  currentOP->set(currentOP, numReg1, codeOP, numReg2, 0);
				  printf("COP R%u R%u\t\t", numReg1, numReg2);
				  currentOP->print(currentOP);
				  
				  // on libère le registre Ry puisqu'il a été copié
				  tableRegistres->setUnused(tableRegistres, numReg2);

				  tableRegistres->setLastUsed(tableRegistres, numReg1);
				  
				} else if(addr1Pile == 0) { // LOAD Rx [@addr]
				  codeOP = _code_LOAD;
				  numReg1 = tableRegistres->firstUnused(tableRegistres);
				  tableRegistres->setLEAForReg(tableRegistres, numReg1, $2); // mise à jour de l'adresse
				  currentOP->set(currentOP, numReg1, codeOP, addr2Pile, 0);
				  printf("LOAD R%u 0x%2.2X\t\t", numReg1, addr2Pile);
				  currentOP->print(currentOP);
				  
				  tableRegistres->setLastUsed(tableRegistres, numReg1);
				  
				} else { // STORE [@addr] Rx 
				  codeOP = _code_STORE;
				  currentOP->set(currentOP, addr1Pile, codeOP, numReg2, 0);
				  printf("STORE 0x%2.2X R%u\t\t", addr1Pile, numReg2);
				  currentOP->print(currentOP);
				  // on libère le registre car devient inutile
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}
			}
			| tJMF tADDR tNBR {
				unsigned char codeOP = _code_JMF;
				unsigned char numReg = tableRegistres->getRegForLEA(tableRegistres, $2);
				currentOP->set(currentOP, numReg, codeOP, (unsigned char) ($3 - currentLine), 0);
				printf("JMF R%u %d\t\t", numReg, $3 - currentLine);
				currentOP->print(currentOP);

				// on libère le registre car devient inutile
				tableRegistres->setUnused(tableRegistres, numReg);
			}
			| tAFC tADDR tNBR {
				// numReg (Rx) sera le numéro du premier registre libre trouvé
				unsigned char numReg = tableRegistres->firstUnused(tableRegistres);
				unsigned char codeOP = _code_AFC;				
				// AFC Rx $NBR
				currentOP->set(currentOP, numReg, codeOP, $3, 0);
				printf("AFC R%u %d\t\t", numReg, $3);
				currentOP->print(currentOP);
				// mise à jour d'utilisation du registre pour dire qu'il est désormais utilisé
				tableRegistres->setLEAForReg(tableRegistres, numReg, $2);

				tableRegistres->setLastUsed(tableRegistres, numReg);
			};

INST3OPERANDES:		tADD tADDR tADDR tADDR {
                                unsigned char codeOP = _code_ADD;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("ADD R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}

				tableRegistres->setLastUsed(tableRegistres, numReg1);
                        }
                        | tMUL tADDR tADDR tADDR {
                                unsigned char codeOP = _code_MUL;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("MUL R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}

				tableRegistres->setLastUsed(tableRegistres, numReg1);
                        }
                        | tSUB tADDR tADDR tADDR {
				unsigned char codeOP = _code_SUB;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("SUB R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}

				tableRegistres->setLastUsed(tableRegistres, numReg1);
			}
			| tDIV tADDR tADDR tADDR {
				unsigned char codeOP = _code_DIV;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("DIV R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}

				tableRegistres->setLastUsed(tableRegistres, numReg1);
			}
			| tINF tADDR tADDR tADDR {
				unsigned char codeOP = _code_INF;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("INF R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}
				
				tableRegistres->setLastUsed(tableRegistres, numReg1);
			}
			| tSUP tADDR tADDR tADDR {
                                unsigned char codeOP = _code_SUP;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("SUP R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}

				tableRegistres->setLastUsed(tableRegistres, numReg1);
			}
			| tEQU tADDR tADDR tADDR {
			        unsigned char codeOP = _code_EQU;
				// on ne pourra avoir que des adresses correspondants à des registres déjà chargés
				unsigned char numReg1 = tableRegistres->getRegForLEA(tableRegistres, $2);
			        unsigned char numReg2 = tableRegistres->getRegForLEA(tableRegistres, $3);
				unsigned char numReg3 = tableRegistres->getRegForLEA(tableRegistres, $4);
				
				currentOP->set(currentOP, numReg1, codeOP, numReg2, numReg3);
				printf("EQU R%u R%u R%u\t\t", numReg1, numReg2, numReg3);
				currentOP->print(currentOP);
				
				// on libère le registre qui n'apparait qu'une fois car c'est celui qui ne contiendra pas le résultat
				if($2 == $3) {
				  tableRegistres->setUnused(tableRegistres, numReg3);
				} else {
				  tableRegistres->setUnused(tableRegistres, numReg2);
				}

				tableRegistres->setLastUsed(tableRegistres, numReg1);
			};

%%

int main(int argc, char ** argv) {
  currentOP = newOperation();
  tableRegistres = newRegistersTable();
  stack = newStack();

  yyparse();

  //tableRegistres->print(tableRegistres);
  //stack->print(stack);  

  return 0;
}

