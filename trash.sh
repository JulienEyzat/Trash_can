#!/bin/sh

usage='NAME:
    trash - manage a trash can by command line

USAGE:
    trash [option] files to remove

VERSION:
    2.1

OPTION:
    -c clear the trash can
    -l list the files in the trash can
    -d delete files in the trash can that are here for more than n days
    -v verbose mode
    -r recover a file to his last position
    -u update the recoverFile
    -debug debug
'

trashPos=~/.trash/trash_can/
recoverFile=~/.trash/recoverFile

#init
mkdir -p $trashPos
touch $recoverFile

#Check the number of arguments to show the help
if [[ $# -lt 1 ]]
then
    printf '%s' "$usage"
    exit 1
fi

#Clear the trash can
if [[ $1 = "-c" ]]; then
    if  [[ `ls -A $trashPos` != "" ]]; then
        rm -r $trashPos/**
        rm $recoverFile
        echo The trash is now empty
    else
        echo The trash is already empty
    fi

#Give the list of the files and directories in the trash can
elif [[ $1 = "-l" ]]; then
    echo `cut -d " " -f 1 < $recoverFile`

#Show the content of the recoverFile and the trash_can directory
elif [[ $1 = "-debug" ]]; then
    echo "recoverFile content :"
    cat $recoverFile
    echo "======================"
    echo "trash can content :"
    find $trashPos

#Delete the files older than the second argument given
elif [[ $1 = "-d" ]]; then
    if [[ $# != 2 ]]; then
        echo "trash -r number_of_days files"
    else
        find $trashPos -mtime +$2 -exec rm -r "{}" \;
    fi

#Still in progress
elif [[ $1 = "-r" ]]; then
    if [[ $# != 2 ]]; then
        echo "trash -r files"
        echo "you can see the files list with trash -l"
        exit 1
    fi
    shift 1
    for files do
        last_dir=`grep -e ^"$files" < $recoverFile | cut -d " " -f 2`
        deplaced_file=`find $trashPos -name "$files"`
        mv $deplaced_file $last_dir
        cat $recoverFile | grep -v -e "^$files" > $recoverFile
    done

#Coming soon
elif [[ $1 = "-u" ]]; then
    echo "coming soon"

#Move the files and directories in the trash_can and update the recoverFile
else
    if [[ $1 = "-v" ]]; then
        verbose=true
        shift 1
    fi
    for files
    do
        if [[ $verbose = "true" ]]; then
            echo removing "$files"
        fi
        if [[ -a $files ]]; then
            current_dir=`pwd`
            touch "$files"
            if [[ -d $files ]]; then
                corrected_file=""
                if [[ `echo $files | grep -e "/$"` ]]; then
                    corrected_file=${files*/}
                else
                    corrected_file="$files"
                fi
                complete_dir="$current_dir/$corrected_file"
                final_dir=${complete_dir%/*}
                file="${complete_dir##*/}"
                echo "complete $complete_dir"
                echo "final $final_dir"
                echo "file $file"
                echo "$file $final_dir" >> $recoverFile
            else
                complete_dir="$current_dir/$corrected_file"
                final_dir=${complete_dir%/*}
                file="${complete_dir##*/}"
                echo "$file $final_dir" >> $recoverFile
            fi
            mv "$corrected_file" "$trashPos"
        else
            echo "The file or directory $corrected_file doesn't exist"
        fi
    done
fi

exit 0
