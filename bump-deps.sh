#!/bin/bash
# bump tutorials based on dependencies found in tut01/package.json
# For each tutorial, run spago (install, build, run), clean up after
function bump-deps {
    cp ../tut01/package.json .
    cp ../tut01/.gitignore .
    cp ../tut01/test/Main.purs ./test/
    npm run -s clean
    npm install
    npm run -s install
    npm run -s build
    echo "***" | tee -a ../bump-deps-log.txt
    echo $1 | tee -a ../bump-deps-log.txt
    npm run -s exec 2>&1 | tee -a ../bump-deps-log.txt
    npm run -s clean
}

set -x
rm ./spago-build-log.txt
touch ./spago-build-log.txt

for i in $(seq 4 4);
do
    if [ $i -eq 4 ]; then
        path="./tut04P1/"
        cd $path
        bump-deps $path
        cd ..
        path="./tut04P2/"
        cd $path
        bump-deps $path
    elif [ $i -lt 10 ]; then
      path="./tut0${i}/"
      cd $path
      bump-deps $path
    else
      path="./tut${i}/"
      cd $path
      bump-deps $path
    fi
    cd ..
done
