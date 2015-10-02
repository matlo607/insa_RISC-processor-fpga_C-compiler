#!/bin/bash
if [ $# != 1 ]; then
  echo "syntax : cc.sh source_file"
  exit 1 
fi

if ( ! [ -f $1 ] ); then
  echo "error : $1 : file unknown"
  exit 2
fi

cd bin
./pre-compiler.elf < ../$1

if [ -f "out.asm" ]; then
  ./cross-compiler.elf < out.asm

  if [ -f "prog.rom" ]; then 
    ./simulator.elf
  fi
fi

exit 0
