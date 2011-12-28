#!/bin/bash

# viewsourcewith
#ITEM_ID=88
#EXT_ID=2626

if [ ! -d tmp ];
then
    echo Unable to find tmp directory, run this script from extension directory
    exit
fi
OUT_FILE_NAME=tmp/bz_locales_${ITEM_ID}_${EXT_ID}
OUT_LOCALE_DIR=tmp/bz_locales_unzipped
OUT_LOG_FILE=tmp/bz_locales_${ITEM_ID}_${EXT_ID}.log

CFG_DIR=~/.bzdl
COOKIE_FILE=${CFG_DIR}/bz_cookie.txt

if [ $# -eq 0 ];
then
    echo $0 bz_password '(outputfilename)'
else

    # Always get cookie
    rm ${COOKIE_FILE}
    
    #######
    ## Get the cookie if not already got
    #######
    if [ ! -f ${COOKIE_FILE} ]
    then
        mkdir ${CFG_DIR}/ 2>/dev/null
        postdata=`echo \''op2=login&lang=english&message=0&option=ipblogin&username=dafi&passwd='$1'&task=login&0b14737c5ade1f7697a8f81b33b0bacf=1'\'`
        wget -U dafi/1.0.0 \
        --save-cookies=${COOKIE_FILE} --keep-session-cookies \
        --post-data=$postdata \
        -O dummylogin.html \
        'http://www.babelzilla.org/index.php?option=com_ipblogin&task=login'
        rm dummylogin.html
    else
        echo Cookie file already exists
    fi

    #######
    ## Download the required extension locales
    #######
    if [ -n "$2" ];
    then
        OUT_FILE_NAME=$2;
    fi
    url=`echo 'http://www.babelzilla.org/index.php?option=com_wts&Itemid='$ITEM_ID'&type=downloadtar&extension='$EXT_ID`

    wget -U dafi/1.0.0 --load-cookies=${COOKIE_FILE} --keep-session-cookies \
    -O $OUT_FILE_NAME.tar.gz \
    -o $OUT_LOG_FILE \
    $url

    rm -Rf $OUT_LOCALE_DIR
    mkdir $OUT_LOCALE_DIR
    tar mzxf $OUT_FILE_NAME.tar.gz -C $OUT_LOCALE_DIR/

if [ `uname | sed -e 's/WIN.\+/WIN/'` = "CYGWIN" ]; then
    CYGDIR=`cygpath -w $OUT_LOCALE_DIR`
    echo Extracting `cygpath -w $OUT_FILE_NAME.tar.gz` in $CYGDIR ...
    I:/Programmi2/Beyond/Beyond32.exe $CYGDIR src/main/locale /expandall /display=mismatches&
else
    echo Extracting $OUT_FILE_NAME.tar.gz in $OUT_LOCALE_DIR ...
    wine /opt/devel/beyond/BC2.exe $OUT_LOCALE_DIR src/main/locale /expandall /display=mismatches&
fi

fi