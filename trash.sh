#!/bin/sh

usage='NAME:
    trash - manage a trash can by command line

USAGE:
    trash [option] files to remove

VERSION:
    4.1

OPTION:
    -c clear the trash can
    -l list the files in the trash can
    -d delete a file from the trash can
    -old delete files in the trash can that are here for more than n days
    -v verbose mode
    -r recover a file to his last position
    -u update the recoverFile
    -debug debug
'

#Path to the directory containing the removed files
trashPos=~/.trash/trash_can/
#Path to the recoverFile which contains the data about files in the trash can
recoverFile=~/.trash/recoverFile
#This file is used to update the recoverFile
tmp=~/.trash/tmp
#The files which haven't a recovery directory will be send here when trying to
#recover them
default_recover_directory=~/
#It is used as a delimiter in the recoverFile
delimiter='!'

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
    list=`cut -d $delimiter -f 1 < $recoverFile`
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
        grep -v -e "^$files$delimiter" < $recoverFile > $tmp
        cat $tmp > $recoverFile
        echo "$files deleted"
    done

#Delete the files older than the second argument given
elif [[ $1 = "-old" ]]; then
    if [[ $# != 2 ]]; then
        echo "trash -r number_of_days"
    else
        path_length=`find $trashPos -maxdepth 0 | tr "/" " " | wc -w`
        real_path_length=$(($path_length+2))
        files=`find $trashPos -mtime +$2 | cut -d '/' -f $real_path_length`
        files_length=`echo $files | wc -w`
        for (( i = 1; i < $(($files_length+1)); i++ )); do
            file=`echo $files | cut -d " " -f $i`
            rm -r $trashPos$file
            grep -v -e "^$files$delimiter" < $recoverFile > $tmp
            cat $tmp > $recoverFile
            echo "$file deleted"
        done
    fi

#Allow the user to recover a file or directory put in the trash can
elif [[ $1 = "-r" ]]; then
    if [[ $# < 2 ]]; then
        echo "trash -r files"
        echo "you can see the files list with trash -l"
        exit 1
    fi
    shift 1
    for files do
        if [[ `grep $recoverFile -e "^$files$delimiter"` ]]; then
            last_dir=`grep -e "^$files$delimiter" < $recoverFile | cut -d $delimiter -f 2`
            mv "$trashPos$files" $last_dir
            grep -v -e "^$files$delimiter" < $recoverFile > $tmp
            cat $tmp > $recoverFile
        fi
    done

#Update the recoveryFile. Useful when the trash can is modified without
#using the trash command
elif [[ $1 = "-u" ]]; then
    #Add added files in the recovery file
    for files in $trashPos*
    do
        if [[ -d $files ]]; then
            file=${files::-1}
            directory="${files##*/}"
            final_dir="$directory/"
            if [[ `grep -e "^$final_dir$delimiter" < $recoverFile` ]]; then
                e=""
            else
                echo "$final_dir$delimiter$default_recover_directory" >> $recoverFile
            fi
        else
            file="${files##*/}"
            if [[ `grep -e "^$file$delimiter" < $recoverFile` ]]; then
                e=""
            else
                echo "$file$delimiter$default_recover_directory" >> $recoverFile
            fi
        fi
    done

    #Remove removed files in the recovery file
    for files in `cat $recoverFile | cut -d "$delimiter" -f 1`
    do
        if [[ `ls $trashPos | grep -e "^$files"` ]]; then
            e=""
        else
            grep -v -e "^$files$delimiter" < $recoverFile > $tmp
            cat $tmp > $recoverFile
        fi
    done

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
                echo "$file/$delimiter$final_dir" >> $recoverFile
            else
                echo "$file$delimiter$final_dir" >> $recoverFile
            fi
            mv "$corrected_file" "$trashPos"
        else
            echo "The file or directory $files doesn't exist"
        fi
    done
fi

exit 0
