#!/bin/bash

base_dir=$PWD
tool_dir=$base_dir/tools
sevenzip="$tool_dir/darwin/7za"

rm -rf ./eufix-base/system
mkdir ./eufix-base/system

for f in *.zip; do
    arr=(${f//_/ })
    if [[ "${arr[0]}" != "miui" ]]; then
        continue
    fi
    if [ -f $f.aria2 ]; then
        echo "--> skip incomplete file: $f"
        continue
    fi
    model=${arr[1]}
    ver=${arr[2]}
    ####update module.prop
    verCode=`cat ./eufix-base/module.prop | grep versionCode= | cut -d '=' -f 2`
    verCode=$(($verCode+1))
    version=$(date "+%Y%m%d")
    cat > ./eufix-base/module.prop <<-EOF
id=eufix
name=eumiuifix
version=$version-$model-$ver-$verCode
versionCode=$verCode
author=kooritea
description=xiaomieufix-$model-$ver
EOF

####
    echo "---cleaner-fix begin: app localization (from eu to cn)---"
    ./cleaner-fix.sh --clock
    cp -R ./miui-$model-$ver/deodex/system ./eufix-base/
    echo "---cleaner-fix done---"
    
    echo "---extract begin: (restore deleted app)---"
    ./extract.sh --appvault
    echo "---extract done---"
    cp -R ./miui-$model-$ver/deodex/system ./eufix-base/
    cp -R ./PersonalAssistant ./eufix-base/system/priv-app/
    cd eufix-base/
    zip -r ../eufix-$ver-$model-magisk.zip ./*
    cd ..
    rm -rf ./eufix-base/system
done
