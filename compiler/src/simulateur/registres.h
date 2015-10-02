#ifndef _REGISTRES_
#define _REGISTRES_

#define NBR_REGISTRES 16

class Registres
{
	private:
		//unsigned int table[NBR_REGISTRES]; 
		signed char table[NBR_REGISTRES];

	public:
		Registres();
		~Registres();

		void print();
		signed char get(signed int num);
		signed char set(signed int num, signed char content);
};

#endif
