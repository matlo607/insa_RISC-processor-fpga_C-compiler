#include "ROM.h"
#include "fileUtils.h"
#include <stdio.h>

ROM::ROM() {
  stream = newBinaryFile(FILENAME_ROM, "r");
  size = stream->seek(stream, 0, SEEK_END);
  stream->rewind(stream);
  endOfFile = 0;
}

ROM::~ROM() {
  this->stream->close(this->stream);
}

void ROM::print() {
  signed char A, B, C;
  unsigned char OP;
  
  for(unsigned int i=0; i<size; i+=4) {
    C = getByte();
    B = getByte();
    OP = getByte();
    A = getByte();
    printf("0x%2.2X %2.2X %2.2X %2.2X\n", A, OP, B, C);
  }

  this->stream->rewind(this->stream);
}

Operation ROM::getNextOP() {
  Operation op;
  
  op.C = getByte();
  op.B = getByte();
  op.OP = getByte();
  op.A = getByte();

  return op;
}

unsigned int ROM::getWord() {
  unsigned int res;
  int lu;

  lu = stream->read(stream, &res, sizeof(unsigned int), 1);
  endOfFile = lu > 0 ? 0 : 1; 

  return res;
}

unsigned short int ROM::getHalfWord() {
  unsigned short int res;
  int lu;

  lu = stream->read(stream, &res, sizeof(unsigned short int), 1);

  endOfFile = lu > 0 ? 0 : 1; 

  return res;
}

unsigned char ROM::getByte() {
  unsigned char res;
  int lu;

  lu = stream->read(stream, &res, sizeof(unsigned char), 1);
  endOfFile = lu > 0 ? 0 : 1; 

  return res;
}

void ROM::jump(int offset) {

  offset *= 4; // instruction = 4 octets
  offset -= 4; // saut en arriere : instruction courante en plus à à prendre en compte
               // saut en avant : instruction courante pas à prendre à compte

  stream->seek(stream, offset, SEEK_CUR);
}

