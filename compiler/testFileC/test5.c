main() {

	int a = 10 , b = 1;
	const int c = 50;

	while (a >= 0) {
		if (0 < a &&  a < 5) {
			printf(a + 10);
		} else if (a >= 5 || a == 0) {
			printf(b);
		} else {
			printf(c);
		}
		a = a - 1;
		b = 1 - b;
	}

}
