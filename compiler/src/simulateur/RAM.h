#ifndef _RAM_
#define _RAM_

#define RAM_SIZE 0x100

class RAM
{
	private:
		unsigned char tab[RAM_SIZE];

	public:
		RAM();
		~RAM();

		void print();
		unsigned char get(unsigned int position);
		void set(unsigned int position, unsigned char val);
};

#endif
