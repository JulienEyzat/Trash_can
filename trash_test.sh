#!/bin/bash

echo "==========================="
echo "add a file to the trash can"
echo ""
echo "current state of the trash can"
trash.sh -l
touch test_file
trash.sh test_file
echo "new state of the trash can"
trash.sh -l
echo "remove the file from the trash can"
trash.sh -d test_file
echo "new state of the trash can"
trash.sh -l


echo "==========================="
echo "add a folder to the trash can"
echo ""
echo "current state of the trash can"
trash.sh -l
mkdir test_folder
touch test_folder/aa
trash.sh test_folder
echo "new state of the trash can"
trash.sh -l
echo "remove the folder from the trash can"
trash.sh -d test_folder
echo "new state of the trash can"
trash.sh -l


echo "==========================="
echo "add a file to the trash can and recover it"
echo ""
echo "current state of the trash can"
trash.sh -l
touch aa
trash.sh test_recover
echo "new state of the trash can"
trash.sh -l
echo "recover the file from the trash can"
trash.sh -r test_recover
echo "new state of the trash can"
trash.sh -l
