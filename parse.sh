#!/bin/bash

BUILD_URL="https://www.czc.cz/83dvj0i0tghk6adaot6tq21c16/seznam"
RESULT_FILE_NAME="build_$(date +'%d-%m_%H-%M')_{BUILD_PRICE}kc.json"



DATA_FILE="build.dat"
JSON_ARRAY_FILE="build_array.json"

curl $BUILD_URL \
 | grep "data-ga-impression" \
 | cut -f2 -d"'" >> $DATA_FILE

LINES=$(wc -l $DATA_FILE | cut -d" " -f1)
I=0
while read p; do
	if [ ${#p} -gt 2 ]
	then
		if [ $I -eq 0 ]
		then
			echo "[$p," >> $JSON_ARRAY_FILE
		elif [ $I -eq $[$LINES-1] ]
		then
			echo "$p]" >> $JSON_ARRAY_FILE
		else
			echo "$p," >> $JSON_ARRAY_FILE
		fi
	fi
	I=$[$I+1]
done <$DATA_FILE


SUM=$(cat $JSON_ARRAY_FILE | jq '.[] .price' | awk '{s+=$1} END {print s}')

RESULT_FILE_NAME=$(sed "s/{BUILD_PRICE}/$SUM/" <<< $RESULT_FILE_NAME)

cat $JSON_ARRAY_FILE | jq . > $RESULT_FILE_NAME

rm $DATA_FILE
rm $JSON_ARRAY_FILE




