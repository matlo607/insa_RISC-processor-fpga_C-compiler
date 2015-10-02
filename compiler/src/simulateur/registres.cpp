#include "registres.h"
#include <cstdio>

Registres::Registres() {
	for(signed int i=0; i < NBR_REGISTRES; i++) {
		this->table[i] = 0;
	}
}

Registres::~Registres() {}

void Registres::print() {
	for(signed int i=0; i < NBR_REGISTRES; i++) {
		printf("REG[%u] -> 0x%2.2X\n", i, (unsigned char)this->table[i]);
	}
}

signed char Registres::get(signed int num) {
	return this->table[num];
}

signed char Registres::set(signed int num, signed char content) {
	signed char old = this->table[num];
	this->table[num] = content;
	return old;
}
