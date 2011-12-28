#!/bin/bash
# This script create a media wiki table starting from dafizilla $news variable
ls -1t /opt/devel/0dafiprj/SrcXML-VBS/sourceforge.site/dafizilla/$1/version* | awk '{print "php changelog-creator.php " $0}' > /tmp/createlog.sh
echo >/tmp/$1.changelog __NOTOC__
echo >>/tmp/$1.changelog =Release notes=
sh /tmp/createlog.sh >>/tmp/$1.changelog
echo Changelog written on /tmp/$1.changelog
