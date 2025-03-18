#!/bin/bash

set -e
set -u

GIT_REPOSITORY="git@github.com:psitny/enviros.git"
COMMIT_ID=""
GIT_BRANCH="" # Initialize to avoid unbound variable errors
APP_ENV="" # Initialize to avoid unbound variable errors

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      GIT_BRANCH="$2"
      shift 2
      ;;
    --env)
      APP_ENV="$2"
      shift 2
      ;;
    --commit-id)
      if [[ -z "$2" ]]; then
        echo "Error: --commit-id requires a commit hash" >&2
        exit 1
      fi
      COMMIT_ID="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Check that required parameters are provided
if [[ -z "$GIT_BRANCH" ]] || [[ -z "$APP_ENV" ]]; then
  echo "Usage: $0 --branch <branch-name> --env <environment> [--commit-id <commit-hash>]" >&2
  exit 1
fi

BASE_BUILD_DIR="$(cd "$(dirname "$0")" && pwd)/build"
TARGET_FOLDER="$BASE_BUILD_DIR/$GIT_BRANCH/app"

# ... (rest of your script, using $GIT_BRANCH and $APP_ENV)
echo "Branch: ${GIT_BRANCH}, Environment: ${APP_ENV}, Target folder: $TARGET_FOLDER"

# Check if the repository already exists
if [[ -d "$TARGET_FOLDER/.git" ]]; then
  echo "Repository already exists. Updating..."
  cd "$TARGET_FOLDER" || { echo "Error: Failed to cd to $TARGET_FOLDER"; exit 1; } # Improved error handling
  git fetch origin "$GIT_BRANCH" || { echo "Error: Git fetch failed"; exit 1; }
  git -c advice.detachedHead=false checkout origin/$GIT_BRANCH &> /dev/null || { echo "Error: Git checkout failed"; exit 1; }
  git reset --hard || { echo "Error: Git reset failed"; exit 1; }
else
  echo "Repository does not exist. Cloning..."
  mkdir -p "$TARGET_FOLDER" || { echo "Error: Failed to create directory $TARGET_FOLDER"; exit 1; }
  git clone --branch "$GIT_BRANCH" --depth 1 "$GIT_REPOSITORY" "$TARGET_FOLDER" || { echo "Error: Git clone failed"; exit 1; }

    if [[ ! -z "$COMMIT_ID" ]]; then
      git -C "$TARGET_FOLDER" checkout "$COMMIT_ID" || { echo "Error: Git checkout of commit $COMMIT_ID failed"; exit 1; }
    fi
fi

ENV_FILE="$TARGET_FOLDER/.env"
echo "Setting environment to ${APP_ENV} in $ENV_FILE"
echo "APP_ENV=${APP_ENV}" > "$ENV_FILE"  # Now, the directory exists

echo "Running build docker-compose.${APP_ENV}.yml"
export APP_ENV="$APP_ENV"
cd "${BASE_BUILD_DIR}/../" || { echo "Error: Failed to cd to ${BASE_BUILD_DIR}/../"; exit 1; }
export $(grep -v '^#' .env.${APP_ENV} | xargs)

cp docker-compose.${APP_ENV}.yml $BASE_BUILD_DIR/$GIT_BRANCH/docker-compose.yml
cp .env.${APP_ENV} $BASE_BUILD_DIR/$GIT_BRANCH/.env
cp -r php $BASE_BUILD_DIR/$GIT_BRANCH/
cp -r nginx $BASE_BUILD_DIR/$GIT_BRANCH/

cd $BASE_BUILD_DIR/$GIT_BRANCH

if command -v docker-compose &> /dev/null; then
  DOCKER_COMPOSE="docker-compose -f docker-compose.yml"
else
  DOCKER_COMPOSE="docker compose -f docker-compose.yml"
fi

$DOCKER_COMPOSE stop
$DOCKER_COMPOSE up --build -d || { echo "Error: docker compose failed"; exit 1; }
$DOCKER_COMPOSE exec php git config --global --add safe.directory /var/www/enviros

$DOCKER_COMPOSE exec php sh -c '[ -d var ] || mkdir var'
$DOCKER_COMPOSE exec php sh -c '[ -d var/log ] || mkdir var/log'
$DOCKER_COMPOSE exec php chown -R www-data:www-data var

if [[ "$APP_ENV" == "dev" ]]; then
  echo "APP_ENV is 'dev'"
else
  $DOCKER_COMPOSE exec php composer install || { echo "Error: composer install failed"; exit 1; }
  $DOCKER_COMPOSE exec php bin/doctrine orm:clear-cache:metadata|| { echo "Error: bin/doctrine failed"; exit 1; }
fi


echo "Environment is ready in $TARGET_FOLDER and running on 127.0.0.1:${NGINX_PORT}"