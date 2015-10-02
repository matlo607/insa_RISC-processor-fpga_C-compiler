#include "RAM.h"
#include "ROM.h"
#include "registres.h"

#include <iostream>
using namespace std;

// Instruction set
#define _code_NOP     0x00 // NOP (No OPeration)
#define _code_ADD     0x01 // ADD Rx Ry Rz (Rx <- Ry + Rz)
#define _code_SUB     0x03 // SUB Rx Ry Rz (Rx <- Ry - Rz)
#define _code_MUL     0x02 // MUL Rx Ry Rz (Rx <- Ry * Rz)
#define _code_DIV     0x04 // DIV Rx Ry Rz (Rx <- Ry / Rz)
#define _code_JMP     0x05 // JMP $val (ip <= ip + $val)
#define _code_JMF     0x06 // JMF Rx $val (ip <= ip + $val si Rx >= 1)
#define _code_INF     0x07 // INF Rx Ry Rz (Rx <- Ry < Rz)
#define _code_SUP     0x08 // SUP Rx Ry Rz (Rx <- Ry > Rz)
#define _code_EQU     0x09 // EQU Rx Ry Rz (Rx <- Ry == Rz)
#define _code_PRI     0x0a // PRI Rx (Affiche le contenu du registre Rx)
#define _code_COP     0x0b // COP Rx Ry (Rx <- Ry)
#define _code_AFC     0x0c // AFC Rx $val (Rx <- $val)
#define _code_LOAD    0x0d // LOAD Rx [@addr] (Rx <- [@addr])
#define _code_STORE   0x0e // STORE [@addr] Rx ([@addr] <- Rx)

int main(void)
{
	RAM* ram = new RAM();
	ROM* rom = new ROM();
	Registres* regs = new Registres();

	Operation op;

	while(!rom->getEndOfFile()) {
		op = rom->getNextOP();

		//printf("op = %2.2X %2.2X %2.2X %2.2X\n",op.A,op.OP,op.B,op.C);

		if (rom->getEndOfFile()) { // fin du fichier
			continue;
		}


		switch(op.OP) {
			case _code_NOP:
				break;

			case _code_ADD:
				regs->set(op.A, regs->get(op.B) + regs->get(op.C));
				break;

			case _code_MUL:
				regs->set(op.A, regs->get(op.B) * regs->get(op.C));
				break;

			case _code_SUB:
				regs->set(op.A, regs->get(op.B) - regs->get(op.C));
				break;

			case _code_DIV:
				regs->set(op.A, regs->get(op.B) / regs->get(op.C));
				break;

			case _code_INF:
				printf ( "var : %d < %d = %d | en dur : 0<0 =%d\n",regs->get(op.B),regs->get(op.B),((int)(regs->get(op.B))) < ((int)(regs->get(op.C))),0<0);
				regs->set(op.A, (unsigned char)(regs->get(op.B) < regs->get(op.C)));
				break;

			case _code_SUP:
				regs->set(op.A, (unsigned char)(regs->get(op.B) > regs->get(op.C)));
				break;

			case _code_EQU:
				regs->set(op.A, (unsigned char)(regs->get(op.B) == regs->get(op.C)));
				break;

			case _code_PRI:
				//printf("R%u = 0x%2.2X\n", op.A, regs->get(op.A));
				printf("%d\n", regs->get(op.A));
				break;

			case _code_AFC:
				regs->set(op.A, op.B);
				break;

			case _code_LOAD:
				regs->set(op.A, ram->get(op.B));
				break;

			case _code_STORE:
				ram->set(op.A, regs->get(op.B));
				break;

			case _code_JMP:
				rom->jump(op.B);
				break;

			case _code_JMF:
				if(regs->get(op.A) == 0) {

					rom->jump(op.B);
				}
				break;

			default:
				cerr << "ERROR !!!\n";
				break;
		}
	}

	delete rom;
	delete regs;
	//  delete ram;

	return 0;
}
