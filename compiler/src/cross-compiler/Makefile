SRC= $(wildcard *.c)
OBJ= $(wildcard *.y)
LEX= $(wildcard *.l)
COMP_YACC=yacc
COMP_LEX=lex
EXEC=cross-compiler.elf


all: $(EXEC)

$(EXEC): y.tab.c lex.yy.c y.tab.h operation.c operation.h registers.h registers.c stack.h stack.c fileUtils.h fileUtils.c
	$(CC) $^ -ll -ly -o $(EXEC)

y.tab.c: $(OBJ)
	$(COMP_YACC) -d -v $<

y.tab.h: $(OBJ) 
	$(COMP_YACC) -d $<

lex.yy.c: $(LEX) y.tab.h
	$(COMP_LEX) $<

lex.out: lex.yy.c
	$(CC) -ll $<

operation.o: operation.c
	$(CC) -c $<

registers.o: registers.c
	$(CC) -c $<

.PHONY: clean mrproper

clean:
	@rm -rf *.h.gch *.o *~ lex.yy.c y.tab.c y.tab.h *.output

mrproper: clean
	@rm -rf $(EXEC) prog.rom

test:
	@./$(EXEC) < output.asm

dumpROM:
	@xxd -u -c 4 -g 1 prog.rom
