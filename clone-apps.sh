#!/bin/bash

set -e

clone_or_update()
{
  if [ -d $1 ]
  then
    if ! git -C $1 diff --quiet --ignore-submodules --no-ext-diff; then
      echo "skipped updating $1 due to local changes"
    else
      if ! git -C $1 checkout $3; then
        echo "git failed to checkout $3"
      fi
      if ! git -C $1 fetch origin; then
        echo "git fetch failed for $1"
        exit 1
      fi
      if ! git -C $1 merge --ff-only origin/$3; then
        echo "updating $1 failed"
        exit 1
      fi
    fi
  else
    git clone -b $3 $2
  fi
}

cd apps

clone_or_update govuk-content-schemas https://github.com/alphagov/govuk-content-schemas.git ${GOVUK_CONTENT_SCHEMAS_BRANCH:-"master"}
clone_or_update content-store https://github.com/alphagov/content-store.git ${CONTENT_STORE_BRANCH:-"master"}
clone_or_update router-api https://github.com/alphagov/router-api.git ${ROUTER_API_BRANCH:-"master"}
clone_or_update publishing-api https://github.com/alphagov/publishing-api.git ${PUBLISHING_API_BRANCH:-"master"}
clone_or_update specialist-publisher https://github.com/alphagov/specialist-publisher.git ${SPECIALIST_PUBLISHER_BRANCH:-"master"}
clone_or_update asset-manager https://github.com/alphagov/asset-manager.git ${ASSET_MANAGER_BRANCH:-"master"}
clone_or_update static https://github.com/alphagov/static.git ${STATIC_BRANCH:-"master"}
clone_or_update specialist-frontend https://github.com/alphagov/specialist-frontend.git ${SPECIALIST_FRONTEND_BRANCH:-"master"}
clone_or_update router https://github.com/alphagov/router.git ${ROUTER_BRANCH:-"master"}
