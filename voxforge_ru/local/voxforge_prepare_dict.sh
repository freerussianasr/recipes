#!/bin/bash

# Copyright 2012 Vassil Panayotov
# Apache 2.0

# Copyright 2016 Ubskiy Dmitriy, STC

. path.sh || exit 1

locdata=data/local
locdict=$locdata/dict

echo "=== Preparing the dictionary ..."

if [ ! -d $locdict/zero_ru_cont_8k_v3 ]; then
  echo "--- Downloading CMU dictionary ..."
  mkdir -p $locdict 
  wget -P $locdict http://downloads.sourceforge.net/project/cmusphinx/Acoustic%20and%20Language%20Models/Russian/zero_ru_cont_8k_v3.tar.gz 
  tar xzf $locdict/zero_ru_cont_8k_v3.tar.gz -C $locdict
fi

cp $locdict/zero_ru_cont_8k_v3/ru.lm $locdata/lm.arpa
cp $locdict/zero_ru_cont_8k_v3/ru.dic $locdict/cmudict-plain.txt

echo "--- Searching for OOV words ..."
awk 'NR==FNR{words[$1]; next;} !($1 in words)' \
  $locdict/cmudict-plain.txt $locdata/vocab-full.txt |\
  egrep -v '<.?s>' > $locdict/vocab-oov.txt

awk 'NR==FNR{words[$1]; next;} ($1 in words)' \
  $locdata/vocab-full.txt $locdict/cmudict-plain.txt |\
  egrep -v '<.?s>' > $locdict/lexicon-iv.txt

wc -l $locdict/vocab-oov.txt
wc -l $locdict/lexicon-iv.txt

if [[ "$(uname)" == "Darwin" ]]; then
  command -v greadlink >/dev/null 2>&1 || \
    { echo "Mac OS X detected and 'greadlink' not found - please install using macports or homebrew"; exit 1; }
  alias readlink=greadlink
fi

sequitur=$KALDI_ROOT/tools/sequitur
export PATH=$PATH:$sequitur/bin
export PYTHONPATH=$PYTHONPATH:`readlink -f $sequitur/lib/python*/site-packages`

if ! g2p=`which g2p.py` ; then
  echo "The Sequitur was not found !"
  echo "Go to $KALDI_ROOT/tools and execute extras/install_sequitur.sh"
  exit 1
fi

echo "--- Preparing pronunciations for OOV words ..."
g2p.py --model=conf/g2p_model --apply $locdict/vocab-oov.txt > $locdict/lexicon-oov.txt

cat $locdict/lexicon-oov.txt $locdict/lexicon-iv.txt |\
  sort > $locdict/lexicon.txt

echo "--- Prepare phone lists ..."
echo SIL > $locdict/silence_phones.txt
echo SIL > $locdict/optional_silence.txt
grep -v -w sil $locdict/lexicon.txt | \
  awk '{for(n=2;n<=NF;n++) { p[$n]=1; }} END{for(x in p) {print x}}' |\
  sort > $locdict/nonsilence_phones.txt

echo "--- Adding SIL to the lexicon ..."
echo -e "!SIL\tSIL" >> $locdict/lexicon.txt

# Some downstream scripts expect this file exists, even if empty
touch $locdict/extra_questions.txt

echo "*** Dictionary preparation finished!"
