#!/bin/sh
files=`find . -name "*.md"`
for file in $files
do
	cat $file | ./space_padding > $file.padding
	mv $file.padding $file
done
