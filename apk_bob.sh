#!/bin/bash
function buildCommandIndentifier {
        echo "----"$buildType"----"
	echo "----ClEAN----"
        (cd ~/curofy && $cleanCommand)
	echo "----BUILD----"
	if [[ $buildType == "PRODUCTION" ]]; then
	        buildCommand="assembleProductionDebug"
	else
	        buildCommand="assembleStagingDebug"
	fi			
}
function copyBuildToTagFolder { 
        mkdir -p $newDir
	echo "----COPYING----"
	(cd ~/Brandon/ &&  cp -a ~/curofy/presentation/build/outputs/apk/* $newDir"/")
	newFileName="ls $newDir"
	echo "----DIRECTORY: "$newFileName"----"
}

echo "----BUILD APK STARTED-----"
inputValue=${1,,}
inputTagValue=${2,,}
cleanCommand="bash gradlew clean"
fetchTag=$( cd ~/curofy && git fetch --tags )
if [[ $inputValue == *"prod"* ]]; then
	buildType="PRODUCTION"
elif [[ $inputValue == *"stag"* ]]; then
	buildType="STAGING"
fi
buildCommandIndentifier
if [[ ! -z $buildCommand ]]; then
	echo "----Fetching....----"
        if [[ ! -z $inputTagValue ]]; then
                $fetchTag
                echo "----Git checking out... -"$inputTagValue"----"
                ( cd ~/curofy && git checkout $inputTagValue )
                tagFolder=$buildType"_"$inputTagValue
        else
                echo "----Git checking out... -development""----"
                ( cd ~/curofy && git fetch origin development && git checkout development )
                latestCommitHash=$(git log -n 1 | grep "commit" | awk '{print $2}')
                tagFolder=$buildType"_development_"$latestCommitHash
        fi
  	newDir=~/"Brandon/builds/"$tagFolder
	if [[ ! -d $newDir ]]; then
        	( cd ~/curofy && bash gradlew $buildCommand )
	      	trap copyBuildToTagFolder EXIT		
	else
		echo "----DIRECTORY: "ls $newDir"----"
	fi
else
        echo "Please enter correct build type"
fi
