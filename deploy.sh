#!/bin/bash

TARGET_FOLDER_BASE=`pwd`/build
TEMPORARY_TARGET_FOLDER=/tmp
GIT_BRANCH="test"
GIT_REPOSITORY="git@github.com:psitny/enviros.git"
COMMIT_ID=""
APP_ENV=$GIT_BRANCH

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      GIT_BRANCH="$2"
      shift 2
      ;;
    --commit-id)
      COMMIT_ID="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

echo "Branch ${GIT_BRANCH} into folder $TARGET_FOLDER_BASE"

GIT_TEMPORARY_TARGET_FOLDER="${TEMPORARY_TARGET_FOLDER}/eis-temp"

# Check if the repository already exists
if [[ -d "$GIT_TEMPORARY_TARGET_FOLDER/.git" ]]; then  # Check for .git directory
  echo "Repository already exists. Updating..."
  cd $GIT_TEMPORARY_TARGET_FOLDER
  git fetch origin "$GIT_BRANCH" # Fetch the latest changes for the branch
  git reset --hard "origin/$GIT_BRANCH"  # Reset to the remote branch
else
  echo "Repository does not exist. Cloning..."
  mkdir -p "$GIT_TEMPORARY_TARGET_FOLDER"
  git clone --branch "$GIT_BRANCH" --depth 1 "$GIT_REPOSITORY" "$GIT_TEMPORARY_TARGET_FOLDER"
fi

COMMIT_ID=$(git -C $GIT_TEMPORARY_TARGET_FOLDER rev-parse HEAD)

# Use the first 7 characters of the commit ID or branch name as a release ID
RELEASE_ID="${COMMIT_ID:0:7}"
if [[ -z "$RELEASE_ID" ]]; then
  RELEASE_ID="${GIT_BRANCH:0:7}"
fi

echo " release ${RELEASE_ID} of commit $COMMIT_ID";

BUILD_FOLDER="${TARGET_FOLDER_BASE}/eis-${RELEASE_ID}"

echo " deleted build folder ${BUILD_FOLDER} deleted"

rm -fr $BUILD_FOLDER
mkdir -p $BUILD_FOLDER
mv "${GIT_TEMPORARY_TARGET_FOLDER}"/* "${BUILD_FOLDER}/"

echo " populated $BUILD_FOLDER"

echo "APP_ENV=${APP_ENV}" > $BUILD_FOLDER/.env

cd $BUILD_FOLDER
#composer install
#npm install
