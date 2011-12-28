#!/bin/bash
# Run Gecko based applications (firefox, thunderbird, flock) using profile directory.
# Author: Davide Ficano <davide.ficano@gmail.com>

PROFILE_CONF=$HOME/.moz_profilerc
LINK_TARGET=$0

create_links() {
    LINK_DEST_DIR=`awk '/^linkDestDir[[:blank:]]+/ {print $2}' $PROFILE_CONF`
    if [ -z "$LINK_DEST_DIR" ];
    then
        echo "Unable to find linkDestDir in configuration file $PROFILE_CONF"
        return -1
    fi
    
    COMMAND_DIR=
    get_current_command_dir COMMAND_DIR
    COMMAND_PATH=$COMMAND_DIR/`basename $LINK_TARGET`

    delete_links

    for i in `awk '/^(mozapp|komodo)[[:blank:]]+/ {print $2}' $PROFILE_CONF` ;
    do
        ln -fs $COMMAND_PATH $LINK_DEST_DIR/$i
        echo Created application link $i
    done
}

get_current_command_dir() {
  here=`/bin/pwd`
  cd `dirname "$LINK_TARGET"`
  dir=`/bin/pwd`
  cd "$here"
  eval "$1=$dir"
}

run_profile() {
    profileDir=`awk 'BEGIN { FS="^profileDir[[:blank:]]+"} /^profileDir[[:blank:]]+/ {print $2}' $PROFILE_CONF`
    profileDir=`eval "echo $profileDir"`

    #profileDir=`awk '/^profileDir[[:blank:]]+/ {match($0, "^profileDir[[:blank:]]+(.*)",a); print a[1]}' $PROFILE_CONF`
    profileDirCreateSilently=`awk '/^profileDirCreateSilently[[:blank:]]+/ {print $2}' $PROFILE_CONF`
    if [ ! -d $profileDir ];
    then
        if [ "$profileDirCreateSilently" == "true" ];
        then
            echo "Creating profile directory $profileDir..."
            # eval ensures special path characters are resolved correctly (eg ~ home dir)
            mkdir -p $profileDir
        else
            echo "The directory $profileDir must be created before run, see profileDirCreateSilently on configuration"
            exit
        fi
    fi

    # remove the script extensions (if present)
    PROFILE_NAME=`basename $0 | sed 's/\..*//'`
    #grep '^gp\s*=' apps.lst | sed 's/^gp\s*=//'

    APP_PATH=`awk "/^.*[[:blank:]]+${PROFILE_NAME}[[:blank:]]+/ {print \\$3}" $PROFILE_CONF`
    APP_TYPE=`awk "/^.*[[:blank:]]+${PROFILE_NAME}[[:blank:]]+/ {print \\$1}" $PROFILE_CONF`
    PROFILE_DATA=`awk "/^.*-data[[:blank:]]+${PROFILE_NAME}[[:blank:]]+/ {print $3}" $PROFILE_CONF`
    
    if [ -z "$APP_PATH" ];
    then
        echo "Unable to find a valid path for '$PROFILE_NAME' check configuration $PROFILE_CONF"
    fi

    # if first arg exists and doesn't start with dash then use it as profile name
    if [ -n "$1" ] && [ "${1:0:1}" != "-" ];
    then
        PROFILE_NAME=$PROFILE_NAME$1
        shift
    fi
    
    if [ -n "$PROFILE_DATA" ]; then
        if [ ! -d "$PROFILE_DATA" ]; then
            echo Unpacking $PROFILE_DATA
            echo To be implemented
        fi
    fi
    #    echo 'start /wait I:\Programmi2\WinRAR\WinRAR.exe x $PROFILE_DATA profile\$PROFILE\'
    
    mkdir -p "$profileDir/$PROFILE_NAME"
    
    echo Running $PROFILE_NAME
    if [ $APP_TYPE == "mozapp" ]; then
        export MOZ_NO_REMOTE=1
    
        if [ `uname | sed -e 's/WIN.\+/WIN/'` = "CYGWIN" ]; then
            APP_PATH=`cygpath $APP_PATH`
        fi
        "$APP_PATH" -profile $profileDir/$PROFILE_NAME $1 $2 $3 $4 $5 $6 $7 $8 $9 &
    elif [ $APP_TYPE == "komodo" ]; then
        export KOMODO_USERDATADIR=$profileDir/$PROFILE_NAME
        "$APP_PATH" -v
    else
        echo Unknown type $APP_TYPE
    fi
}

edit() {
    if [ ! -f $PROFILE_CONF ]; then
        echo "$PROFILE_CONF must be created"
        mk_default_conf
    fi
    detect_editor
    #run editor
    $PROF_EDITOR $PROFILE_CONF
}

detect_editor() {
    if [ -n "$VISUAL" ]; then
        PROF_EDITOR=$VISUAL
    elif [ -n "$EDITOR" ]; then
        PROF_EDITOR=$EDITOR
    elif [ -f /usr/bin/editor ]; then
        PROF_EDITOR=/usr/bin/editor
    else
        PROF_EDITOR=/usr/bin/vi
    fi
}

delete_links() {
    LINK_DEST_DIR=`awk '/^linkDestDir[[:blank:]]+/ {print $2}' $PROFILE_CONF`

    if [ -z "$LINK_DEST_DIR" ];
    then
        echo "Unable to find linkDestDir in configuration file $PROFILE_CONF"
        return -1
    fi

    COMMAND_DIR=
    get_current_command_dir COMMAND_DIR
    
    COMMAND_PATH=$COMMAND_DIR/`basename $LINK_TARGET`

    links_names=`ls -l $LINK_DEST_DIR | grep "$COMMAND_PATH" | sed -e "s/.* \(.*\) -> .*/\1/g"`
    
    for i in $links_names ;
    do
        echo Removing ${i}...
        rm $LINK_DEST_DIR/$i
    done
}

find_orphan_links() {
    LINK_DEST_DIR=`awk '/^linkDestDir[[:blank:]]+/ {print $2}' $PROFILE_CONF`

    if [ -z "$LINK_DEST_DIR" ];
    then
        echo "Unable to find linkDestDir in configuration file $PROFILE_CONF"
        return -1
    fi

    COMMAND_DIR=
    get_current_command_dir COMMAND_DIR
    
    COMMAND_PATH=$COMMAND_DIR/`basename $LINK_TARGET`

    links_names=`ls -l $LINK_DEST_DIR | grep "$COMMAND_PATH" | sed -e "s/.* \(.*\) -> .*/\1/g"`

    valid_links=`awk '/^(mozapp|komodo)[[:blank:]]+/ {print $2}' $PROFILE_CONF`
    for i in $links_names ;
    do
        if [[ !($valid_links =~ "$i") ]];
        then
            echo $i is an orphan link
        fi
    done
}

mk_default_conf() {
    cat >$PROFILE_CONF << EOF_CONF
# This file contains the mozilla application used to run separated profiles

# Directory where links will be created, generally resides in env PATH
linkDestDir     /usr/local/bin

# Directory where profiles will be created
profileDir      ~/.moz_profiles

# If true create profileDir silently, otherwise generate error
profileDirCreateSilently    true

# Application links to create
# Lines must have the following format
# mozapp    <<link name used to invoke profile>>  <<path to application>>

# Example
#mozapp     ff30        /opt/devel/mozilla/ff3a8/firefox/firefox
#mozapp     tb20        /usr/bin/thunderbird

EOF_CONF
}

usage="[-h]elp [-c]reate [-e]dit [-f]ind orphan links"

SCRIPT_NAME=`basename $0 | sed 's/\..*//'`
APP_PATH=`awk "/^mozapp[[:blank:]]+${SCRIPT_NAME}[[:blank:]]+/ {print \\$2}" $PROFILE_CONF`

# Check args only when calling script isn't a profile app
if [ -z "$APP_PATH" ];
then
    while getopts "cefh" options; do
      case $options in
        c) create_links;;
        e) edit;;
        f) find_orphan_links;;
        h) echo $usage
           exit
           ;;
      esac
    done
fi

#shift $(($OPTIND - 1))
if [ $OPTIND -eq 1 ];
then
    run_profile $*
fi
