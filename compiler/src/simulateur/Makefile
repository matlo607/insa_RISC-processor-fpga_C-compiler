DEBUG=yes
CC=g++

CXXFLAGS=-W -Wall -Wextra -pedantic -std=c++11
LDFLAGS=

ifeq ($(DEBUG),yes)
	CXXFLAGS+= -g
endif

EXEC=simulator.elf
SRC= $(wildcard *.cpp)
OBJ= $(SRC:.cpp=.o)

all: $(EXEC)

$(EXEC): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CXXFLAGS) -o $@ -c $<

.PHONY : clean
clean:
	@rm -f *.o *~ *.h.gch

mrproper: clean
	@rm -f $(EXEC)
