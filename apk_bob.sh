#!/bin/bash
function copyBuildToTagFolder {
        newDir="builds/"$tagFolder
        mkdir -p $newDir
        echo "----DIRECTORY: "$newDir
        (cd ~/Brandoni/ &&  cp -a ~/curofy/presentation/build/outputs/apk/* $newDir)
}


echo "BUILD APK STARTED"
inputValue=${1,,}
inputTagValue=${2,,}
cleanCommand="bash gradlew clean"
fetchTag=$( cd ~/curofy && git fetch --tags )
Red='\033[0;31m'  
if [[ $inputValue == *"prod"* ]]; then
        echo "${Red}----PRODCUTION----"
	echo "${Red}----ClEAN----"
        (cd ~/curofy && $cleanCommand)
	echo "${Red}----BUILD----"
        buildCommand="assembleProductionDebug"
elif [[ $inputValue == *"stag"* ]]; then
        echo "----STAGING----"
	echo "${Red}----CLEAN----"
        (cd ~/curofy && $cleanCommand)
	echo "${Red}----BUILD----"
        buildCommand="assembleStagingDebug"
fi
if [[ ! -z $buildCommand ]]; then
        if [[ ! -z $inputTagValue ]]; then
		echo "----Fetching....----"
                $fetchTag
                echo "----Git checking out... -"$inputTagValue"----"
                ( cd ~/curofy && git checkout $inputTagValue )
                tagFolder=$inputTagValue"/"
        else
		echo "----Fetching....----"
                echo "----Git checking out... -development""----"
                ( cd ~/curofy && git fetch origin development && git checkout development )
                latestCommitHash=$(git log -n 1 | grep "commit" | awk '{print $2}')
                tagFolder="development_"$latestCommitHash"/"
        fi
        ( cd ~/curofy && bash gradlew $buildCommand )
        trap copyBuildToTagFolder EXIT
else
        echo "Please enter correct build type"
fi
