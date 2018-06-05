#!/bin/sh

# for loop
for ko_file in 20160627/*; do output_file=`echo $ko_file| sed 's/20160627/seg_20160627/'`; ./newline_align_simpl.pl $ko_file $output_file; done 

for ko_file in ko/*; do output_file=`echo $ko_file | sed 's/ko/ko_single_line/'`; ./parse_vktimes_file.pl $ko_file $output_file; done | head

for m in  models/*.t7 ; do ./correct.sh $m gold/testfile models/tst_${m%.t7}.out ; done

# perl command
perl -ne 'while(<>){ s/ /_/g; print join(" ",split(//,$_));}'  < input.txt          # char tokenizer  (space => _ )` (edited)

perl -CSD -pe 's/[\x{2028}\x{2029}\x{FEFF}]//g' < u+2028.input`

