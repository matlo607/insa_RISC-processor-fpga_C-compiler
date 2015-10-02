#ifndef _REGISTERS_
#define _REGISTERS_

#ifdef	__cplusplus
extern "C" {
#endif

#define NBR_REGISTERS	16 // doit être inférieur à 255

  /* -------------
   * CONVENTIONS :
   * -------------
   *
   */

  typedef struct registre {
    unsigned char content;
    int used;
    unsigned char lastEquivAddr;
  } Registre;

  typedef struct registersTable RegistersTable; 
  struct registersTable {
    Registre* tab;
    unsigned char lastRegUsed;
    
    void (*setLEAForReg)(RegistersTable* this, unsigned char numReg, unsigned char addrEquiv);
    signed char (*getRegForLEA)(RegistersTable* this, unsigned char addrEquiv);
    void (*setContent)(RegistersTable* this, unsigned char numReg, unsigned char content);
    void (*setUnused)(RegistersTable* this, unsigned char numReg);
    unsigned char (*firstUnused)(RegistersTable* this);
    void (*setLastUsed)(RegistersTable* this, unsigned char numReg);
    unsigned char (*getLastUsed)(RegistersTable* this);
    void (*print) (RegistersTable* this);
    void (*free) (RegistersTable* this);
  }; 

  RegistersTable* newRegistersTable(void);
  
#ifdef	__cplusplus
}
#endif

#endif
