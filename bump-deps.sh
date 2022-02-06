#!/bin/bash
# bump tutorials based on dependencies found in tut01/package.json
# For each tutorial, run spago (install, build, run), clean up after
logfile="bump-deps-log.txt"

function bump-deps {
    cp ../tut01/package.json .
    cp ../tut01/.gitignore .
    cp ../tut01/test/Main.purs ./test/
    npm run -s clean
    npm install
    echo "***" | tee -a "../${logfile}"
    echo $1 | tee -a "../${logfile}"
    npm audit fix 2>&1 | tee -a "../${logfile}"
    npm run -s install
    npm run -s build
    npm run -s exec 2>&1 | tee -a "../${logfile}"
    npm run -s clean
}

set -x
rm "./${logfile}"
touch "./${logfile}"

for i in $(seq 3 5);
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
