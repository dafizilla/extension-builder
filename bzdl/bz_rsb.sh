#!/bin/bash

export ITEM_ID=88
export EXT_ID=3114

tmp_name=`ls -l $0`
tmp_name=`expr "$tmp_name" : ".* -> \(.*\)"`
tmp_name=`dirname $tmp_name`

echo -n "BZ password: "
read -s passwd
echo
$tmp_name/bz_downloadtar.sh $passwd $*
