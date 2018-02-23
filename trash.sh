#!/bin/sh

usage='NAME:
    trash - manage a trash can by command line

USAGE:
    trash [option] files to remove

VERSION:
    3.0

OPTION:
    -c clear the trash can
    -l list the files in the trash can
    -d delete a file from the trash can
    -od delete files in the trash can that are here for more than n days
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
    list=`cut -d " " -f 1 < $recoverFile`
    printf '%s\n' $list

#Show the content of the recoverFile and the trash can directory
elif [[ $1 = "-debug" ]]; then
    echo "recoverFile content :"
    cat $recoverFile
    echo "======================"
    echo "trash can content :"
    find $trashPos

#Definitely delete the files passed in argument
elif [[ $1 = "-d" ]]; then
    shift 1
    for files do
        rm -r $trashPos$files
        saveRecoverFile=`cat $recoverFile | grep -v -e "^$files"`
        echo $saveRecoverFile > $recoverFile
        echo "$files deleted"
    done

#NOT TESTED Delete the files older than the second argument given
elif [[ $1 = "-od" ]]; then
    if [[ $# != 2 ]]; then
        echo "trash -r number_of_days files"
    else
        find $trashPos -mtime +$2 -exec rm -r "{}" \;
    fi

#Allow the user to recover a file or directory put in the trash can
elif [[ $1 = "-r" ]]; then
    if [[ $# != 2 ]]; then
        echo "trash -r files"
        echo "you can see the files list with trash -l"
        exit 1
    fi
    shift 1
    for files do
        if [[ `grep $recoverFile -e "^$files"` ]]; then
            last_dir=`grep -e "^$files" < $recoverFile | cut -d " " -f 2`
            mv "$trashPos$files" $last_dir
            saveRecoverFile=`cat $recoverFile | grep -v -e "^$files"`
            echo $saveRecoverFile > $recoverFile
        fi
    done

#WIP Update the recoveryFile. Useful when the trash can is modified without
#using the trash command
elif [[ $1 = "-u" ]]; then
    echo "coming soon"

#Move the files and directories in the trash can and update the recoverFile
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
            corrected_file=""
            if [[ `echo $files | grep -e "/$"` ]]; then
                corrected_file=${files::-1}
            else
                corrected_file=$files
            fi
            complete_dir="$current_dir/$corrected_file"
            final_dir=${complete_dir%/*}
            file="${complete_dir##*/}"
            if [[ -d $files ]]; then
                echo "$file/ $final_dir" >> $recoverFile
            else
                echo "$file $final_dir" >> $recoverFile
            fi
            mv "$corrected_file" "$trashPos"
        else
            echo "The file or directory $corrected_file doesn't exist"
        fi
    done
fi

exit 0
