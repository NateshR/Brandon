#!/bin/bash
function copyBuildToTagFolder {
        echo "COPYING INTO RESPECTIVE TAG FOLDER"
        newDir="builds/"$tagFolder
        mkdir -p $newDir
        (cd ~/ApkBuilder/ &&  cp -a ~/curofy/presentation/build/outputs/apk/* $newDir)
}


echo "BUILD APK STARTED"
inputValue=${1,,}
inputTagValue=${2,,}
cleanCommand="bash gradlew clean"
fetchTag=$( cd ~/curofy && git fetch --tags )

if [[ $inputValue == *"prod"* ]]; then
        echo "----PRODCUTION----"
        (cd ~/curofy && $cleanCommand)
        buildCommand="assembleProductionDebug"
elif [[ $inputValue == *"stag"* ]]; then
        echo "----STAGING----"
        (cd ~/curofy && $cleanCommand)
        buildCommand="assembleStagingDebug"
fi
if [[ ! -z $buildCommand ]]; then
        if [[ ! -z $inputTagValue ]]; then
                echo "Git checking out... -"$inputTagValue
                $fetchTag
                ( cd ~/curofy && git checkout $inputTagValue )
                tagFolder=$inputTagValue"/"
        else
                echo "Git checking out... -development"
                ( cd ~/curofy && git fetch origin development && git checkout development )
                latestCommitHash=$(git log -n 1 | grep "commit" | awk '{print $2}')
                tagFolder="development_"$latestCommitHash"/"
        fi
        ( cd ~/curofy && bash gradlew $buildCommand )
        trap copyBuildToTagFolder EXIT
else
        echo "Please enter correct build type"
fi
