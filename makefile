encode_image: main.o read_int.o modulo.o read_image.o write_image.o encode_image.o
	gcc -o encode main.o read_int.o modulo.o read_image.o write_image.o encode_image.o

main.o: main.s
	gcc -c -g main.s

read_int.o: read_int.s
	gcc -c -g read_int.s

modulo.o: modulo.s
	gcc -c -g modulo.s

read_image.o: read_image.s
	gcc -c -g read_image.s

write_image.o: write_image.s
	gcc -c -g write_image.s

encode_image.o: encode_image.s
	gcc -c -g encode_image.s

clean:
	rm *.o
