#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compare the main sys-devel/gcc directory to the one here.
# Ideally, this should be executed after every update to the system.

if [ -z ${1} ]; then
    PORTAGE_DIR="/usr/portage"
else
    PORTAGE_DIR=${1}
fi

GCC_DIR="sys-devel/gcc"
PORTAGE_GCC_DIR="${PORTAGE_DIR}/${GCC_DIR}"
PORTAGE_ECLASS_DIR="${PORTAGE_DIR}/eclass"

printf ">> ${YELLOW}SYSTEM EBUILDS${NC}\n"

EBUILDS=$(ls ${PORTAGE_GCC_DIR}/*.ebuild)

for e in ${EBUILDS}; do
    echo ">> Checking '${e}' in system ebuilds..."

    FILE_NAME=$(basename ${e})
    VERSION=$(echo ${FILE_NAME} | awk -F\- '{ print $2 }' | awk -F\. '{ print $1 }')

    if [ ${VERSION} -ge 9 ]; then
        if [ ! -e "./${GCC_DIR}/${FILE_NAME}" ]; then
            printf "\t${RED}Not found${NC}, copying it over.\n"

           cp ${e} ./${GCC_DIR}/
        else
            echo -en "\tFound, now diffing..."

            diff ${e} ./${GCC_DIR}/${FILE_NAME} &> /dev/null

            if [ $? != 0 ]; then
                printf "${RED}not the same${NC}, copying it over.\n"

               cp ${e} ./${GCC_DIR}/
            else
                printf "${GREEN}same${NC}.\n"
            fi
        fi
    else
        printf "\t${YELLOW}Skipping${NC}, not supported, version is ${GREEN}< 9${NC}...\n"
    fi
done

# Check for ebuilds in overlay which have been removed.
printf "\n>> ${YELLOW}OVERLAY EBUILDS${NC}\n"

EBUILDS=$(ls ${GCC_DIR}/*.ebuild)

for e in ${EBUILDS}; do
    echo ">> Checking for existence of '${e}' in overlay..."

    FILE_NAME=$(basename ${e})

    if [ ! -e "${PORTAGE_GCC_DIR}/${FILE_NAME}" ]; then
        printf "\t${RED}Not found${NC}, deleting ${FILE_NAME}.\n"

        rm ./${e}
    else
        printf "\t${YELLOW}Found${YELLOW}, keeping.${NC}\n"
    fi
done

# Check for the patches in the ebuild/eclass.
printf "\n>> ${YELLOW}PATCHES${NC}\n"

PATCHES=$(ls ${PORTAGE_GCC_DIR}/files/*)

function check_error() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Found${NC}."
    else
        echo -e "${YELLOW}Not found${NC}."

        RESULT=$?
    fi
}

for p in ${PATCHES}; do
    RESULT=0
    PATCH=$(basename ${p})

    echo ">> Checking for existence of '${PATCH}'..."
    echo -en "\tIn system ebuilds..."

    grep -r ${PATCH} ${PORTAGE_GCC_DIR}/*.ebuild &> /dev/null

    check_error

    echo -en "\tIn system toolchain.eclass..."

    grep -r ${PATCH} ${PORTAGE_ECLASS_DIR}/toolchain.eclass &> /dev/null

    check_error

    if [ ${RESULT} != 0 ]; then
        echo -e "\t\t${YELLOW}Not found${NC} in either ebuild's or eclass, possibly safe to remove."
    fi
done

git status