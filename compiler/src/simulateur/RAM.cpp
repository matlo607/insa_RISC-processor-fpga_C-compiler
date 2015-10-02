#include "RAM.h"
#include <cstdio>

RAM::RAM() {

}

RAM::~RAM() {

}

void RAM::print() {
	unsigned int i;
	for(i=RAM_SIZE; i>RAM_SIZE/2; i--) {
		printf("RAM:0x%2.2X --> 0x%2.2X\n", i, tab[i]);
	}
}

unsigned char RAM::get(unsigned int position) {
	return tab[position];
}

void RAM::set(unsigned int position, unsigned char val) {
	tab[position] = val;
}
