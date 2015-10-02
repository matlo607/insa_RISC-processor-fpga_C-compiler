#ifndef _STACK_
#define _STACK_

#ifdef	__cplusplus
extern "C" {
#endif

  //----------------------------
  //-- CONTENT STACK TRACKING --
  //----------------------------

  #define ADDR_STACK 0xff
  #define STACK_SIZE 50

  typedef struct stack Stack;
  struct stack {
    // la stack contient les addresses du cross-assembleur correspondant à cette variable situé à  cet emplacement
    unsigned char* stack;
    
    unsigned int top;

    void (*push)(Stack* this, unsigned char val);
    unsigned char (*pop)(Stack* this); // renvoie l'élément en haut de la pile
    unsigned char (*getTop)(Stack* this); // renvoie l'addresse du  haut de pile
    unsigned char (*getPosAddr)(Stack* this, unsigned char addr); //revoie la position de l'adresse dans la stack
    void (*print) (Stack* this);
    void (*free)(Stack* this);
  };
  
  Stack* newStack(void);

#ifdef	__cplusplus
}
#endif

#endif
