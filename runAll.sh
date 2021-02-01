#!/bin/bash

translations=(/pub/pounds/CSC330/translations/*)
translations=("${translations[@]:0:12}" "${translations[@]:13}")

cd cpp
for f in "${translations[@]}"; do
	echo ""
	echo "C++"
	echo $f
	c++ flesch.cpp
	./a.out $f
done


cd ../java
for f in "${translations[@]}"; do
	echo ""
	echo "Java"
	echo $f
	javac flesch.java
	java flesch $f
done

cd ../python
for f in "${translations[@]}"; do
	echo ""
	echo "Python"
	echo $f
	python3 flesch.py $f
done

cd ../perl
for f in "${translations[@]}"; do
	echo ""
	echo "Perl"
	echo $f
	perl flesch.pl $f
done

cd ../fortran
for f in "${translations[@]}"; do
	echo ""
	echo "Fortran"
	echo $f
	gfortran flesch.f95
	./a.out $f
done
