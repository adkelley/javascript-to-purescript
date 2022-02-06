#!/bin/bash
# Attempt to fix any vulnerabilities
logfile="audit-fix-log.txt"
function npm-audit-fix {
    echo "**********" | tee -a "../${logfile}"
    echo $1 | tee -a "../${logfile}"
    npm audit fix 2>&1 | tee -a "../${logfile}"
    npm run -s clean
}

set -x
rm "./${logfile}"
touch "./${logfile}"

for i in $(seq 1 29);
do
    if [ $i -eq 4 ]; then
        path="./tut04P1/"
        cd $path
        npm-audit-fix $path
        cd ..
        path="./tut04P2/"
        cd $path
        npm-audit-fix $path
    elif [ $i -lt 10 ]; then
      path="./tut0${i}/"
      cd $path
      npm-audit-fix $path
    else
      path="./tut${i}/"
      cd $path
      npm-audit-fix $path
    fi
    cd ..
done
