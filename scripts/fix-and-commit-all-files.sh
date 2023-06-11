#!/bin/sh

function check_error()
{
    if [ $? != 0 ]; then
        echo "  ERROR: Something went wrong!"
        exit 2;
    else
        touch $1
    fi
}


./scripts/remove-all-deleted-ebuilds.sh

check_error

./scripts/commit-all-modified-ebuilds.sh

check_error

./scripts/commit-all-new-ebuilds.sh

check_error

./scripts/commit-all-new-files.sh

check_error

./scripts/create-new-manifest.sh

check_error
