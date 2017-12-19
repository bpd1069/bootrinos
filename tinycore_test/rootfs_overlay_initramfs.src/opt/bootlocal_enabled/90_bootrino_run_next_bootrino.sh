#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

run_next_bootrino()
{
    echo "system is up, get the next bootrino and run it"
    # run next bootrino
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino





