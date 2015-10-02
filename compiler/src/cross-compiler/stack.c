#include <stdlib.h>
#include <stdio.h>
#include "stack.h"

void pushInStack(Stack* this, unsigned char val);
unsigned char popFromStack(Stack* this);
unsigned char topAddrStack(Stack* this);
void freeStack(Stack* this);
void printStack(Stack* this);
unsigned char getPosAddrStack(Stack* this, unsigned char addr);

Stack* newStack(void) {
  Stack* s = malloc(sizeof(Stack));
  s->stack = malloc(sizeof(unsigned char) * STACK_SIZE);
  
  s->top = 0;
  s->push = &pushInStack;
  s->pop = &popFromStack;
  s->getTop = &topAddrStack;
  s->getPosAddr = &getPosAddrStack;
  s->free = &freeStack;
  s->print = &printStack;
}

unsigned char getPosAddrStack(Stack* this, unsigned char addr) {
  int i;
  
  for(i=0; i<this->top; i++) {
    if(this->stack[i] == addr) {
      return (unsigned char)(ADDR_STACK - i);
    }
  }

  return 0;
}

void pushInStack(Stack* this, unsigned char val) {
  this->stack[this->top] = val;
  this->top++;
}

unsigned char topAddrStack(Stack* this) {
  return (unsigned char) ADDR_STACK - this->top;
}

unsigned char popFromStack(Stack* this) {
  this->top--;
  return this->stack[this->top];
}

void printStack(Stack* this) {
  int i;
  unsigned char* tab = this->stack;

  printf("-- STACK DUMP --\n");
  printf("\ttop = %2.2X\n", ADDR_STACK - this->top);
  printf("----------------\n");
  for(i=0; i<this->top; i++) {
    printf("[ADDR_STACK - %d](0x%2.2X)\t->\t%2.2X\n", i, ADDR_STACK - i, tab[i]);
  }
  printf("----------------\n\n");
}

void freeStack(Stack* this) {
  if(this != NULL) {
    free(this->stack);
    free(this);
  }
}
