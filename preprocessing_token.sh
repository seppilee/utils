
#!/bin/bash

set -e

if [ 2 -ne $# ]; then
          echo "usage: `basename $0` {src_file} {tgt_file} "
                  exit 0
fi
echo "start for SNW preprocessing"

src_file="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
tgt_file="$(cd "$(dirname "$2")"; pwd)/$(basename "$2")"


# sentencepiece training setting
__='
   --accept_language (comma-separated list of languages this model can accept)  type: string  default:
   --add_dummy_prefix (Add dummy whitespace at the beginning of text)  type: bool  default: true
   --bos_id (Override BOS (<s>) id. Set -1 to disable BOS.)  type: int32  default: 1
   --character_coverage (character coverage to determine the minimum symbols)  type: double  default: 0.9995
   --control_symbols (comma separated list of control symbols)  type: string  default:
   --eos_id (Override EOS (</s>) id. Set -1 to disable EOS.)  type: int32  default: 2
   --hard_vocab_limit (If set to false, --vocab_size is considered as a soft limit.)  type: bool  default: true
   --input (comma separated list of input sentences)  type: string  default:
   --input_format (Input format. Supported format is `text` or `tsv`.)  type: string  default:
   --input_sentence_size (maximum size of sentences the trainer loads)  type: int32  default: 10000000
   --max_sentencepiece_length (maximum length of sentence piece)  type: int32  default: 16
   --mining_sentence_size (maximum size of sentences to make seed sentence piece)  type: int32  default: 2000000
   --model_prefix (output model prefix)  type: string  default:
   --model_type (model algorithm: unigram, bpe, word or char)  type: string  default: unigram
   --normalization_rule_name (Normalization rule name. Choose from nfkc or identity)  type: string  default: nmt_nfkc
   --normalization_rule_tsv (Normalization rule TSV file. )  type: string  default:
   --num_sub_iterations (number of EM sub-iterations)  type: int32  default: 2
   --num_threads (number of threads for training)  type: int32  default: 16
   --pad_id (Override PAD (<pad>) id. Set -1 to disable PAD.)  type: int32  default: -1
   --remove_extra_whitespaces (Removes leading, trailing, and duplicate internal whitespace)  type: bool  default: true
   --seed_sentencepiece_size (the size of seed sentencepieces)  type: int32  default: 1000000
   --self_test_sample_size (the size of self test samples)  type: int32  default: 0
   --shrinking_factor (Keeps top shrinking_factor pieces with respect to the loss)  type: double  default: 0.75
   --split_by_unicode_script (use Unicode script to split sentence pieces)  type: bool  default: true
   --split_by_whitespace (use a white space to split sentence pieces)  type: bool  default: true
   --training_sentence_size (maximum size of sentences to train sentence pieces)  type: int32  default: 10000000
   --unk_id (Override UNK (<unk>) id.)  type: int32  default: 0
   --unk_surface (Dummy surface string for <unk>. In decoding <unk> is decoded to `unk_surface`.)  type: string  default:  ⁇
   --use_all_vocab (If set to true, use all tokens as vocab. Valid for word/char models.)  type: bool  default: false
   --user_defined_symbols (comma separated list of user defined symbols)  type: string  default:
   --vocab_size (vocabulary size)  type: int32  default: 8000
'
echo "training ro the sentencepiece model "
cat $src_file $tgt_file | shuf > all.txt
spm_train --input all.txt --model_prefix=spm_hellotalk --vocab_size=8000 --character_coverage=1.0

# bpe(sp)
# spm_train --input $src_file  --model_prefix=spm_hellotalk --vocab_size=8000 --character_coverage=1.0 --modeli_type bpe
# spm_train --input $src_file  --model_prefix=spm_hellotalk --vocab_size=8000 --character_coverage=1.0 --modeli_type bpe

# tokenizing with opennmt tokenizer
__='
-mode <string> (accepted: space, conservative, aggressive; default: conservative)
-joiner_annotate [<boolean>] (default: false) Include joiner annotation using -joiner character.
-joiner <string> (default: ￭) Character used to annotate joiners.
-joiner_new [<boolean>] (default: false) In -joiner_annotate mode, -joiner is an independent token.
-case_feature [<boolean>] (default: false) Generate case feature.
-segment_case [<boolean>] (default: false) Segment case feature, splits AbC to Ab C to be able to restore case
-segment_alphabet <table> (accepted: Tagalog, Hanunoo, Limbu, Yi, Hebrew, Latin, Devanagari, Thaana, Lao, Sinhala, Georgian, Kannada, Cherokee, Kanbun, Buhid, Malayalam, Han, Thai, Katakana, Telugu, Greek, Myanmar, Armenian, Hangul, Cyrillic, Ethiopic, Tagbanwa, Gurmukhi, Ogham, Khmer, Arabic, Oriya, Hiragana, Mongolian, Kangxi, Syriac, Gujarati, Braille, Bengali, Tamil, Bopomofo, Tibetan)
Segment all letters from indicated alphabet.
-segment_numbers [<boolean>] (default: false) Segment numbers into single digits.
-segment_alphabet_change [<boolean>] (default: false) Segment if alphabet change between 2 letters.
-bpe_model <string> (default: '')
-bpe_EOT_marker <string> (default: </w>) Marker used to mark the End of Token while applying BPE in mode 'prefix' or 'both'.
-bpe_BOT_marker <string> (default: <w>) Marker used to mark the Beginning of Token while applying BPE in mode 'suffix' or 'both'.
-bpe_case_insensitive [<boolean>] (default: false) Apply BPE internally in lowercase, but still output the truecase units. This option will be overridden/set automatically if the BPE model specified by -bpe_model is learnt using learn_bpe.lua.
-bpe_mode <string> (accepted: suffix, prefix, both, none; default: suffix)
'

echo "onmt tokenizing for src lang"
tokenize --sp_model spm_hellotalk.model -m aggressive --joiner_annotate < $src_file > $src_file.tok

echo "onmt tokenizing for tgt lang"
tokenize --sp_model spm_hellotalk.model -m aggressive --joiner_annotate < $tgt_file > $tgt_file.tok


#build vocaburary with python-getvocab script

echo "get vocab for src side"
subword-nmt get-vocab --input $src_file.tok  --output vocab-src.tmp
cut -f1 -d " " vocab-src.tmp > vocab-src.txt

echo "get vocab for tgt side"
subword-nmt get-vocab --input $tgt_file.tok  --output vocab-tgt.tmp
cut -f1 -d " " vocab-tgt.tmp > vocab-tgt.txt


echo "preprocessing is finished!"
rm -f all.txt vocab-src.tmp vocab-tgt.tmp $src_file.tok  $tgt_file.tok

