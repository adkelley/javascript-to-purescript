#!/bin/bash
# run the migration spago for each example, clean up after
set -x
rm ./spago-build-log.txt
touch ./spago-build-log.txt
for files in ./tut10/ ./tut11/ ./tut12/ ./tut13/ ./tut14/ ./tut15/ ./tut16/ ./tut16/. ./tut18/ ./tut19/ ./tut20/ ./tut21/ ./tut22/ ./tut23/ ./tut24/ ./tut25/ ./tut26/; do
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
