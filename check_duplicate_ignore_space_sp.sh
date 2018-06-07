tr -d "( |\.|\?|\!|,|\"|\'|\r|\x{FEFF})" <korean_280000_setence.txt |paste -- - korean_280000_setence.txt |sort -u -k1,1 | cut -f 2
