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
onmtDIR=/DEV/opennmt9


cd onmtDIR
#perl ../corpus/tok.pl < ${file} > ${file}.tok
th translate.lua -src ${file} -model ${model} -output ${out} -gpuid 1 -replace_unk        #gpu model
#perl ../corpus/detok.pl < ${out}.tok > ${out}

cp ${out} ${out}"_bpe"
sed -i 's/@@ //g' ${out}

echo "****** start bleu/chrF/ribes/dlratio/ter ******"
$SCRDIR/evalhyp.bash $SCRDIR ${out} ${ref}

th ./tools/score.lua ${ref} -scorer dlratio < ${out}  &>> ${out}.eval
th ./tools/score.lua ${ref} -scorer ter < ${out}  &>> ${out}.eval
