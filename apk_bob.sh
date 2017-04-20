#!/bin/bash
function copyBuildToTagFolder {  
        mkdir -p $newDir
	echo "----COPYING----"
	(cd ~/Brandon/ &&  cp -a ~/curofy/presentation/build/outputs/apk/* $newDir"/")
}


echo "----BUILD APK STARTED-----"
inputValue=${1,,}
inputTagValue=${2,,}
cleanCommand="bash gradlew clean"
fetchTag=$( cd ~/curofy && git fetch --tags )
if [[ $inputValue == *"prod"* ]]; then
	buildType="PRODUCTION"
        echo "----"$buildType"----"
	echo "----ClEAN----"
        (cd ~/curofy && $cleanCommand)
	echo "----BUILD----"
        buildCommand="assembleProductionDebug"
elif [[ $inputValue == *"stag"* ]]; then
	buildType="STAGING"
        echo "----"$buildType"----"
	echo "----CLEAN----"
        (cd ~/curofy && $cleanCommand)
	echo "----BUILD----"
        buildCommand="assembleStagingDebug"
fi
if [[ ! -z $buildCommand ]]; then
        if [[ ! -z $inputTagValue ]]; then
		echo "----Fetching....----"
                $fetchTag
                echo "----Git checking out... -"$inputTagValue"----"
                ( cd ~/curofy && git checkout $inputTagValue )
                tagFolder=$buildType"_"$inputTagValue
        else
		echo "----Fetching....----"
                echo "----Git checking out... -development""----"
                ( cd ~/curofy && git fetch origin development && git checkout development )
                latestCommitHash=$(git log -n 1 | grep "commit" | awk '{print $2}')
                tagFolder=$buildType"_development_"$latestCommitHash
        fi
  	newDir=~/"Brandon/builds/"$tagFolder
	echo "----DIRECTORY: "$newDir"----"
	if [[ ! -d $newDir ]]; then
        	( cd ~/curofy && bash gradlew $buildCommand )
	      	trap copyBuildToTagFolder EXIT			
	fi
else
        echo "Please enter correct build type"
fi
