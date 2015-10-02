#include "registers.h"
#include <stdio.h>
#include <stdlib.h>

void initRegisters(Registre* tab);
unsigned char findFirstRegisterUnused(RegistersTable* this);
unsigned char getLastRegisterUsed(RegistersTable* this);
void setLastRegisterUsed(RegistersTable* this, unsigned char numReg);
void setUnusedRegisterX(RegistersTable* this, unsigned char numReg);
void setContentRegisterX(RegistersTable* this, unsigned char numReg, unsigned char content);
void printRegistersTab(RegistersTable* this);
void freeRegistersTable(RegistersTable* this);
void setLastEquivAddrForReg(RegistersTable* this, unsigned char numReg, unsigned char addrEquiv);
signed char getRegForLastEquivAddr(RegistersTable* this, unsigned char addrEquiv);

RegistersTable* newRegistersTable(void) {
  RegistersTable* tabRegs = malloc(sizeof(RegistersTable));
  
  tabRegs->tab = malloc(sizeof(Registre) * NBR_REGISTERS);
  initRegisters(tabRegs->tab);
  tabRegs->lastRegUsed = 0;
  
  tabRegs->setLEAForReg = &setLastEquivAddrForReg;
  tabRegs->getRegForLEA = &getRegForLastEquivAddr;
  tabRegs->setUnused = &setUnusedRegisterX;
  tabRegs->setContent = &setContentRegisterX;
  tabRegs->firstUnused = &findFirstRegisterUnused;
  tabRegs->getLastUsed = &getLastRegisterUsed;
  tabRegs->setLastUsed = &setLastRegisterUsed;
  tabRegs->print = &printRegistersTab;
  tabRegs->free = &freeRegistersTable;
}

void setLastEquivAddrForReg(RegistersTable* this, unsigned char numReg, unsigned char addrEquiv) {
  this->tab[numReg].lastEquivAddr = addrEquiv;
}

signed char getRegForLastEquivAddr(RegistersTable* this, unsigned char addrEquiv) {
  int i;
  
  for(i=0; i<NBR_REGISTERS; i++) {
    if(this->tab[i].lastEquivAddr == addrEquiv && this->tab[i].used) {
      return (signed char) i;
    }
  }
  
  // l'adresse n'a pas été trouvée
  return -1;
}

void initRegisters(Registre* tab) {
  int i;

  // initialisation de tous les registres à 0
  for(i=0; i<NBR_REGISTERS; i++) {
    tab[i].content = 0;
    tab[i].used = 0;
  }
}

void printRegistersTab(RegistersTable* this) {
  Registre* tab = this->tab;
  int i;
  
  printf("-- TABLE DES REGISTRES --\n");
  printf("\tlast used = %d\n", this->lastRegUsed);
  printf("-------------------------\n");
  for(i=0; i<NBR_REGISTERS; i++) {
    printf("| REG[%d]\tused = %d\tLEA = 0x%2.2X |\n", i, tab[i].used, tab[i].lastEquivAddr);
  }
  printf("-------------------------\n\n");
}

void freeRegistersTable(RegistersTable* this) {
  if(this != NULL) {
    free(this->tab);
    free(this);
  }
}

/*
 * Récupère le numéro du premier registre disponible et le marque désormais comme utilisé 
 * si aucun n'est disponible, retourne une valeur supérieure à un numéro de registre possible
 */
unsigned char findFirstRegisterUnused(RegistersTable* this) {
  int i, found = 0;
  Registre* tab = this->tab;

  unsigned char numReg = 255;

  for(i=0; i<NBR_REGISTERS && !found; i++) {
    if(!tab[i].used) {
      found = 1;
      
      // met à jour l'état du registre
      tab[i].used = 1;

      numReg = (unsigned char) i;
    }
  }

  if (found != 1) { // aucun registre de dispo : impossible de poursuivre
    fprintf(stderr,"Fatal error : compilation impossible : pas assez de ressources registres\n");
    
    exit(1);
  }

  return numReg;
}

void setLastRegisterUsed(RegistersTable* this, unsigned char numReg) {
  this->lastRegUsed = numReg;
}

unsigned char getLastRegisterUsed(RegistersTable* this) {
  return this->lastRegUsed;
}

/*
 * Désalloue un registre utilisé
 */
void setUnusedRegisterX(RegistersTable* this, unsigned char numReg) {
  if(numReg < NBR_REGISTERS) {
    this->tab[numReg].used = 0;
  }
}

void setContentRegisterX(RegistersTable* this, unsigned char numReg, unsigned char content) {
  if(numReg < NBR_REGISTERS) {
    this->tab[numReg].content = content;
  }
}
