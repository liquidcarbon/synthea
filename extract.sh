### This script extracts relevant files from Synthea archives ###

# Download https://storage.googleapis.com/synthea-public/historical/synthea_1m_fhir_3_0_May_24.tar.gz
# Untar it and grab first file: output_1_20170524T232103.tar.gz

#!/bin/bash

DATE_FMT='+%y%m%d@%H:%M:%S'
OUTPUT1='output_1_20170524T232103.tar.gz'
RELEVANT_FILES_PAT='patients|medications|conditions|procedures'

echo $(date $DATE_FMT) INFO [${0##*/}] scanning archive $OUTPUT1
files=$(gzip -cd $OUTPUT1 | tar -t | grep -E "csv$" | grep -E $RELEVANT_FILES_PAT)
n_files=$(echo $files | wc -w)

echo $(date $DATE_FMT) INFO [${0##*/}] found $n_files matching files
for f in $files
do
  echo $(date $DATE_FMT) INFO [${0##*/}] extracting file $f
  tar -xzf $OUTPUT1 $f
done

echo $(date $DATE_FMT) INFO [${0##*/}] finished extracting files


# inspection with awk shows that patients.csv has broken lines (other files are fine)
# awk -F, '{print NF}' output_1/csv/patients.csv | sort | uniq -c
# we will ignore the lines with number of fields not equal to 17 (about 0.3% of the data)

echo $(date $DATE_FMT) INFO [${0##*/}] repairing patients.csv file
mv output_1/csv/patients.csv output_1/csv/patients.csv.bad
awk -F, 'NF == 17 {print $0}' output_1/csv/patients.csv.bad > output_1/csv/patients.csv
rm output_1/csv/patients.csv.bad

# QC with awk shows that now the file is good to go
# awk -F, '{print $(NF-2)}' output_1/csv/patients.csv | sort | uniq -c
# returns 66083 F, 66524 M

echo $(date $DATE_FMT) INFO [${0##*/}] packaging relevant files
files=$(find . -iname "*" | grep -E $RELEVANT_FILES_PAT | grep -v gz)
for f in $files
do
  gzip $f -c > data/${f##*/}.gz
done

echo $(date $DATE_FMT) INFO [${0##*/}] files ready for analysis

# Output:
# 210408@15:41:13 INFO [extract.sh] scanning archive output_1_20170524T232103.tar.gz
# 210408@15:41:45 INFO [extract.sh] found 4 matching files
# 210408@15:41:45 INFO [extract.sh] extracting file output_1/csv/conditions.csv
# 210408@15:42:11 INFO [extract.sh] extracting file output_1/csv/medications.csv
# 210408@15:42:37 INFO [extract.sh] extracting file output_1/csv/patients.csv
# 210408@15:43:03 INFO [extract.sh] extracting file output_1/csv/procedures.csv
# 210408@15:43:29 INFO [extract.sh] repairing patients.csv file
# 210408@15:43:29 INFO [extract.sh] finished extracting files
# 210408@15:43:30 INFO [extract.sh] packaging relevant files
# 210408@15:43:39 INFO [extract.sh] files ready for analysis
