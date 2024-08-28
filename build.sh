#!/bin/bash

if [ "$3" == "" ]; then
        echo usage: $0 \<Module\> \<Branch\> \<Workspace\>
        exit -1
else
        module=$1
        branch=$2
        workspace=$3
fi

function getProductNumber {
        product=`cat $workspace/build.cfg | grep $module | grep $branch | awk -F " " '{print $3}'`
}


function setRstate {

        revision=`cat $workspace/build.cfg | grep $module | grep $branch | awk -F " " '{print $4}'`

        if /usr/local/git/bin/git tag | grep $product-$revision; then
                rstate=`/usr/local/git/bin/git tag | grep $revision | tail -1 | sed s/.*-// | perl -nle 'sub nxt{$_=shift;$l=length$_;sprintf"%0${l}d",++$_}print $1.nxt($2) if/^(.*?)(\d+$)/';`
        else
                ammendment_level=01
                rstate=$revision$ammendment_level
        fi
        echo "Building R-State:$rstate"

}


function nexusDeploy {
        RepoURL=http://eselivm2v214l.lmera.ericsson.se:8081/nexus/content/repositories/releases

        GroupId=com.ericsson.oss.bsim.nisios
        ArtifactId=NodeIntegrationScanner


        echo "****"
        echo "Deploying the xcarchive /ENIS-release-${rstate}.xcarchive as ${ArtifactId}-${product}-${rstate}.xcarchive to Nexus...."
        echo "****"

        /usr/share/maven/bin/mvn deploy:deploy-file \
                -Durl=${RepoURL} \
                -DrepositoryId=releases \
                -Dpackaging=zip \
                -DgroupId=${GroupId} \
                -Dversion=${product}-${rstate} \
                -DartifactId=${ArtifactId} \
                -Dfile=$HOME/Library/Developer/Xcode/Archives/2013-02-20/iENIS.zip

}

getProductNumber
setRstate
/usr/local/git/bin/git checkout $branch
/usr/local/git/bin/git pull origin $branch


/usr/local/git/bin/git tag $product-$rstate
/usr/local/git/bin/git pull
/usr/local/git/bin/git push --tag origin $branch


nexusDeploy
