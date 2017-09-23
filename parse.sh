#!/bin/bash
#
# Purpose:
#	The script parses saved public list of a products on czc.cz and saves result in json. Sum of products price at file name.
# Usage:
#	parse.sh build_name build_url
#	e.g. parse.sh my_workstation https://www.czc.cz/83dvj0i0tghk6adaot6tq21c16/seznam 	 	

BUILD_URL=$2
RESULT_FILE_NAME_PATTERN="$1_$(date +'%d-%m_%H-%M')_{BUILD_PRICE}kc.json"
RESULTS_FOLDER="results/"

DATA_FILE="build.dat"
JSON_ARRAY_FILE="build_array.json"

curl -s $BUILD_URL \
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

RESULT_FILE_NAME_PATTERN=$(sed "s/{BUILD_PRICE}/$SUM/" <<< $RESULT_FILE_NAME_PATTERN)

cat $JSON_ARRAY_FILE | jq . > $RESULT_FILE_NAME_PATTERN

cp $RESULT_FILE_NAME_PATTERN $RESULTS_FOLDER

rm $DATA_FILE
rm $JSON_ARRAY_FILE
rm $RESULT_FILE_NAME_PATTERN