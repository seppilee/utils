#!/usr/bin/shell

#for ubuntu distribution env.
#apt-get update, apt-get install python-dev

#install mecab
sudo apt-get install libmecab-dev
sudo apt-get install mecab mecab-ipadic-utf8

# Check the latest version at https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/
wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.1-20150920.tar.gz
tar xzvf mecab-ko-dic-2.0.1-20150920.tar.gz

cd mecab-ko-dic-2.0.1-20150920/
./configure
make
sudo make install

# install Mecab python binding
sudo pip install mecab-python3

# edit dictionary path
# vi "/etc/mecabrc";  "dicdir = /where/to/mecab-ko-dic-2.0.1-20150920"
