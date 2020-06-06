#!/bin/bash
#This script implements a simplified version of sed utility in bash. Input may be given through a pipeline or the console.
#exit codes for troubleshooting: 
#exit 1(No argument)
#exit 2(Pipe regex failed) 
#exit 3(Provided file does not exist)
#exit 4(Console regex failed)  
#-------------------------------------------------------------------------------------------------------------
#Help message function
usage() {
echo "USAGE: sedBash 's/textToReplace/textToPaste/<g>' fileName || echo "text" | sedBash 's/textToReplace/textToPaste/<g>'"
echo "/g optional parameter stands for global replacement"
}
#Input Validation function using regular exp.
userInputValidation() {
if [[ $rawString =~ "'"s\/.+\/.+\/"'" ]]
then
    userInput="valid"
    echo $userInput
elif [[ $rawString =~ "'"s\/.+\/.+\/g"'" ]]
then
    userInput="valid and global"
    echo $userInput
else
    userInput="Not valid"
    echo $userInput
fi
}
#Beginning of main func.
main() {
#No argument provided by user.
if [ $# -eq 0 ]
then
    usage
    exit 1
fi
#User input.
rawString=$1
#Prevents null value case + makes regex comparison constant over different inputs.
rawString=\"\'${rawString}\'\"
#Decides whether the requested action is valid. 
userInput=$(userInputValidation $rawString)
#Can also be done with IFS env variable instead of -F delimiter flag.
#prinf preferred over echo since flags might be interpreted by mistake on echo.
textToReplace=`printf $rawString | awk -F '/' '{print $2}'`
textToPaste=`printf $rawString | awk -F '/' '{print $3}'`
#Lists stdin file descriptors (Pipe vs console)
stdin="$(ls -l /dev/fd/0)"
#String manipulation
stdin="${stdin/*-> /}"
#In case input provided by a pipeline.
if   [[ "$stdin" =~ ^pipe ]]
then
    #read user input from pipe.
    read inputString
    #Checks if requested action is a valid exchange (single).
    if [[ $userInput -eq "valid" ]]
    then
	#Performing the exchange using string manipulation.
        echo ${inputString/$textToReplace/$textToPaste}
    #Checks if requested action is a valid exchange (global).
    elif [[ $userInput -eq "valid and global" ]]
    then
	#String manipulation.
        echo ${inputString//$textToReplace/$textToPaste}
    else
	#In case provided argument is not valid print usage and exit.
        usage
	exit 2
    fi
else
    #Counts how many file were provided by user.
    filecounter=0
    #Array containing all files to be manipulated.
    declare -a fileArray
    #Insert file names into an array.
    while [ $# -gt 1 ]
    do
	if [ -f "$2" ]
	then
	    fileArray[$filecounter]=$2
	    let "filecounter+=1"
	    shift
        else
	    echo "$2 file does not exist. please provide a correct full path"
	    usage
	    exit 3
	fi
    done
    if [[ $userInput == "valid" ]]
    then
        #Loop through the array to print each file after string manipulation.
        for i in "${fileArray[@]}"
        do
            fileContent=`cat $i`
            echo ${fileContent/$textToReplace/$textToPaste}
        done
    #Check if requested action is a valid exchange (global).
    elif [[ $userInput == "valid and global" ]]
    then
        #Loop through the array to print each file after string manipulation.
        for i in "${fileArray[@]}"
        do
            fileContent=`cat $i`
            echo ${fileContent//$textToReplace/$textToPaste}
        done
    else
        #In case provided argument is not valid print usage and exit.
        usage
        exit 4
    fi
fi
}
#Run main method with the given arguments.
main "$@"
