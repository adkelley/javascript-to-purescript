#!/bin/bash
# run the migration spago for each example, clean up after
set -x
rm ./spago-build-log.txt
touch ./spago-build-log.txt
for files in ./tut27/ ./tut28/ ./tut29/; do
    cd $files
    cp ../tut01/package.json .
    cp ../tut01/.gitignore .
    cp ../tut01/test/Main.purs ./test/
    spago init
    npm run -s clean
    npm run -s install
    npm run -s build 2>&1 | tee -a ../spago-build-log.txt
    npm run -s clean
    npm run -s exec
    npm run -s clean
    rm psc-package.json
    cd ..
done
