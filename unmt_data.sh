mkdir data && cd data
wget https://s3.amazonaws.com/opennmt-trainingdata/unsupervised-nmt-enfr.tar.bz2
tar xf unsupervised-nmt-enfr.tar.bz2
cd ..

# Download multi-bleu.perl.
wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/generic/multi-bleu.perl
