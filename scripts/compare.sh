#!/bin/sh

source ./scripts/colours.inc

# Compare the main sys-devel/gcc directory to the one here.
# Ideally, this should be executed after every update to the system.

if [ -z ${1} ]; then
    PORTAGE_DIR="/usr/portage"
else
    PORTAGE_DIR=${1}
fi

GCC_DIR="sys-devel/gcc"
FILES_DIR=${GCC_DIR}/files
PORTAGE_GCC_DIR="${PORTAGE_DIR}/${GCC_DIR}"
PORTAGE_FILES_DIR=${PORTAGE_GCC_DIR}/files
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

# Check for the files/patches in the ebuild/eclass.
printf "\n>> ${YELLOW}FILES${NC}\n"

FILES=$(ls ${PORTAGE_FILES_DIR}/*)

# Check for files missing from the overlay.
for f in ${FILES}; do
    echo ">> Checking '${f}' in portage files..."

    FILE_NAME=$(basename ${f})
    VERSION=$(echo ${FILE_NAME} | awk -F\- '{ print $2 }' | awk -F\. '{ print $1 }')

    if [ ! -e "./${FILES_DIR}/${FILE_NAME}" ]; then
        printf "\t${RED}Not found${NC}, copying it over.\n"

        cp ${f} ./${FILES_DIR}/
    else
        echo -en "\tFound, now diffing..."

        diff ${f} ./${FILES_DIR}/${FILE_NAME} &> /dev/null

        if [ $? != 0 ]; then
            printf "${RED}not the same${NC}, copying it over.\n"

            cp ${f} ./${FILES_DIR}/
        else
            printf "${GREEN}same${NC}.\n"
        fi
    fi
done

# Check for files in overlay which have been removed from portage.
printf "\n>> ${YELLOW}OVERLAY FILES${NC}\n"

FILES=$(ls ${FILES_DIR}/)

for f in ${FILES}; do
    echo ">> Checking for existence of '${f}' in portage..."

    FILE_NAME=$(basename ${f})

    if [ ! -e "${PORTAGE_FILES_DIR}/${FILE_NAME}" ]; then
        printf "\t${RED}Not found${NC}, deleting ${FILE_NAME}.\n"

        rm ./${f}
    else
        printf "\t${YELLOW}Found${YELLOW}, keeping.${NC}\n"
    fi
done


git status