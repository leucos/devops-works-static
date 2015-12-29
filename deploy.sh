#!/bin/bash
set -x
set -e
set -o pipefail

SOURCE_URL=${1:-"git@gitlab.com:devopsworks/devopsworks_website.git"}
DESTINATION_URL=${2:-"git@github.com:leucos/devops-works-static.git"}

echo "SOURCE: $SOURCE_URL"
echo "DESTINATION: $DESTINATION_URL"


SRC=$(pwd)
TEMP=$(mktemp -d -t jgd-XXX)
#trap "rm -rf ${TEMP}" EXIT
CLONE=${TEMP}/clone
SITE=${TEMP}/site

echo -e "Cloning Github repositories:"
git clone "${SOURCE_URL}" "${CLONE}"
git clone "${DESTINATION_URL}" "${SITE}"

cd "${SITE}"
git checkout gh-pages

cd "${CLONE}"

echo -e "\nBuilding Jekyll site:"
rm -rf _site

if [ -r _config-deploy.yml ]; then
  jekyll build --config _config.yml,_config-deploy.yml
else
  jekyll build
fi

if [ ! -e _site ]; then
  echo -e "\nJekyll didn't generate anything in _site!"
  exit -1
fi

cp -R _site/* ${SITE}

cd "${SITE}"

git add .
git commit -am "new version $(date)" --allow-empty
git push origin gh-pages 
#2>&1 | sed 's|'$SOURCE_URL'|[skipped]|g'

echo -e "\nCleaning up:"
rm -rf "${CLONE}"
rm -rf "${SITE}"
