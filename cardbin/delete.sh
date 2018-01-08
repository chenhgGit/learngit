#!/bin/bash -
cd /root/cardbin || exit 3
shopt -s extglob
#rm -f !(t_card_bin.sh|delete.sh)
bak_dir=`date "+%F"`
mkdir -p ./_bak/$bak_dir
mv !(_bak|t_card_bin.sh|delete.sh) ./_bak/$bak_dir
