#ifndef _ROM_
#define _ROM_

#include "fileUtils.h"

#define FILENAME_ROM "./prog.rom"

typedef struct operation {
  signed char A;
  unsigned char OP;
  signed char B;
  signed char C;
} Operation;

class ROM
{
 private:
  unsigned int size;
  BinaryFile* stream;
  int endOfFile;
  
 public:
  ROM();
  ~ROM();

  void print();
  unsigned char getByte();
  unsigned short int getHalfWord();
  unsigned int getWord();
  Operation getNextOP();
  void jump(int offset);
  int getEndOfFile() { return endOfFile; }
};

#endif
