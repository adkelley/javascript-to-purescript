#!/bin/bash
# Test the installation of build of each example, clean up after
set -x
rm ./test-build-log.txt
touch ./test-build-log.txt
for files in ./tut01 ./tut02/ ./tut03/ ./tut04P1/ ./tut04P2/ ./tut05/ ./tut06/ ./tut07/ ./tut08/ ./tut09/ ./tut10/ ./tut11/ ./tut12/ ./tut13/ ./tut14/ ./tut15/ ./tut16/ ./tut16/. ./tut18/ ./tut19/ ./tut20/ ./tut21/ ./tut22/ ./tut23/ ./tut24/ ./tut25/ ./tut26/ ./tut27/ ./tut28/ ./tut29/; do
    cd $files
    npm run -s clean
    npm run -s install
    npm run -s build 2>&1 | tee -a ../test-build-log.txt
    npm run -s clean
    cd ..
done
