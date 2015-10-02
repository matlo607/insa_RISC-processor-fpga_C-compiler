#ifndef _OPERATION_
#define _OPERATION_

#ifdef	__cplusplus
extern "C" {
#endif

  //----------------
  // CODE OPERATIONS
  //----------------
#define _code_NOP (unsigned char)0x00; // NOP (No OPeration)
#define _code_ADD (unsigned char)0x01; // ADD Rx Ry Rz (Rx <- Ry + Rz)
#define _code_SUB (unsigned char)0x03; // SUB Rx Ry Rz (Rx <- Ry - Rz)
#define _code_MUL (unsigned char)0x02; // MUL Rx Ry Rz (Rx <- Ry * Rz)
#define _code_DIV (unsigned char)0x04; // DIV Rx Ry Rz (Rx <- Ry / Rz)
#define _code_JMP (unsigned char)0x05; // JMP $val (ip <= ip + $val)
#define _code_JMF (unsigned char)0x06; // JMF Rx $val (ip <= ip + $val si Rx >= 1)
#define _code_INF (unsigned char)0x07; // INF Rx Ry Rz (Rx <- Ry < Rz)
#define _code_SUP (unsigned char)0x08; // SUP Rx Ry Rz (Rx <- Ry > Rz)
#define _code_EQU (unsigned char)0x09; // EQU Rx Ry Rz (Rx <- Ry == Rz)
#define _code_PRI (unsigned char)0x0a; // PRI Rx (Affiche le contenu du registre Rx)
#define _code_COP (unsigned char)0x0b; // COP Rx Ry (Rx <- Ry)
#define _code_AFC (unsigned char)0x0c; // AFC Rx $val (Rx <- $val)
#define _code_LOAD (unsigned char)0x0d; // LOAD Rx [@addr] (Rx <- [@addr])
#define _code_STORE (unsigned char)0x0e; // STORE [@addr] Rx ([@addr] <- Rx)

  //--------------------
  //- OPERATION STRUCT -
  //--------------------

  typedef struct operation Operation;
  struct operation {
    unsigned char A;
    unsigned char OP;
    unsigned char B;
    unsigned char C;
  
    void (*set) (Operation* this, unsigned char A, unsigned char OP, unsigned char B, unsigned char C);
    void (*print) (Operation* this);
    void (*free) (Operation* this);
  };

  // constructeur
  Operation* newOperation(void);

#ifdef	__cplusplus
}
#endif

#endif
