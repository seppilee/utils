#!/bin/bash

if [ 4 -ne $# ]; then
          echo "usage: `basename $0` {model_name} {input_file} {output_file} {reference}"
                  exit 0
fi
echo "start..."

model="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
file="$(cd "$(dirname "$2")"; pwd)/$(basename "$2")"
out="$(cd "$(dirname "$3")"; pwd)/$(basename "$3")"
ref="$(cd "$(dirname "$4")"; pwd)/$(basename "$4")"

SCRDIR=/DEV/nmt-training-scripts
#onmtDIR=/DEV/opennmt9
coeff=(0.0 0.2 0.4 0.6 0.8 1.0)

cd $onmtDIR
for l_norm in "${coeff[@]}"
do
  for c_norm in "${coeff[@]}"
  do
    th translate.lua -src ${file} -model ${model} -output ${out}"_"${l_norm}"_"${c_norm} -gpuid 1 -replace_unk  -length_norm ${l_norm} -coverage_norm ${c_norm}
    cp ${out}"_"${l_norm}"_"${c_norm}  ${out}"_"${l_norm}"_"${c_norm}"_bpe"
    sed -i 's/@@ //g' ${out}"_"${l_norm}"_"${c_norm}
    echo ${out}"_"${l_norm}"_"${c_norm} "****** start bleu/chrF/ribes ******"
    $SCRDIR/evalhyp.bash $SCRDIR ${out}"_"${l_norm}"_"${c_norm} ${ref}
  done
done

#th ./tools/score.lua ${ref} -scorer dlratio < ${out}  &>> ${out}.eval
#th ./tools/score.lua ${ref} -scorer ter < ${out}  &>> ${out}.eval
