#include <stdlib.h>
#include <stdio.h>
#include "operation.h"
#include "fileUtils.h"

BinaryFile* stream = NULL;

//#define printCode(...)	; fprintf(stdout, __VA_ARGS__)

void setOperation(Operation* this, unsigned char A, unsigned char OP, unsigned char B, unsigned char C);
void printOperation(Operation* this);
void freeOperation(Operation* this);


Operation* newOperation(void) {
  Operation* op = malloc(sizeof(Operation));
  op->OP = _code_NOP;
  op->A = 0;
  op->B = 0;
  op->C = 0;
  
  op->set = &setOperation;
  op->print = &printOperation;
  op->free = &freeOperation;

  // Ouverture du fichier en écriture seule
  if(stream == NULL) {
    stream = newBinaryFile("prog.rom", "w");
    stream->rewind(stream);
  }

  return op;
}

void setOperation(Operation* this, unsigned char A, unsigned char OP, unsigned char B, unsigned char C) {
  this->A = A;
  this->OP = OP;
  this->B = B;
  this->C = C;
}

void printOperation(Operation* this) {
  printf("0x(%2.2X %2.2X %2.2X %2.2X)\n", this->A, this->OP, this->B, this->C);
  stream->write(stream, &(this->C), sizeof(unsigned char), 1);
  stream->write(stream, &(this->B), sizeof(unsigned char), 1);
  stream->write(stream, &(this->OP), sizeof(unsigned char), 1);
  stream->write(stream, &(this->A), sizeof(unsigned char), 1);
}

void freeOperation(Operation* this) {
  if(this != NULL) {
    if(stream != NULL) {
      stream->close(stream);
    }

    free(this);
  }
}
