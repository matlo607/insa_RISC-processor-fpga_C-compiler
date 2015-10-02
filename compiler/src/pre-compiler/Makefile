SRC= $(wildcard *.c)
OBJ= $(wildcard *.y)
LEX= $(wildcard *.l)
COMP_YACC=yacc
COMP_LEX=lex
EXEC=pre-compiler.elf
#FLAGS= -Wint-to-pointer-cast

all: $(EXEC)

$(EXEC): y.tab.c lex.yy.c y.tab.h fileUtils.h fileUtils.c
	$(CC) $(FLAGS) $^ -ll -ly -o $(EXEC)

y.tab.c: $(OBJ)
	$(COMP_YACC) -d -v $<

y.tab.h: $(OBJ) 
	$(COMP_YACC) -d $<

lex.yy.c: $(LEX) y.tab.h
	$(COMP_LEX) $<

lex.out: lex.yy.c
	$(CC) -ll $<

.PHONY: clean mrproper

clean:
	@rm -rf lex.yy.c y.tab.c y.tab.h *.output *.asm

mrproper: clean
	@rm -rf $(EXEC)

test:
	@./$(EXEC) < test7.c
