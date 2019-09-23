#!/bin/bash

# -w zapisuje wynik na mikrokontroler

mcu="atmega8"
fsrc="./src"
finc="./inc"
fobj="./obj"
fbin="./bin"
out="out"

i=0
unset objs
for src in `ls ./src`
do
	echo "compiling: $src"
	avr-gcc -g -Os -mmcu=$mcu -o $fobj/${src%.*}.o -c $fsrc/$src
	objs[$i]="$fobj/${src%.*}.o"
	let i=i+1
done

echo "linking"
	avr-gcc -g -mmcu=$mcu -o $fbin/$out ${objs[*]}

echo "making hex file"
	avr-objcopy -j .text -j .data -O ihex $fbin/$out "$fbin/$out.hex"
	
avr-size -C --mcu=$mcu $fbin/$out

if [[ $1 == '-w' ]]; then
	echo "writing"
	avrdude -c usbasp -p $mcu -U flash:w:"$fbin/$out.hex":i
fi

echo done	