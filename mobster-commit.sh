#!/usr/bin/env bash
USER_EMAIL=`git config --get user.email`
MOBSTERS=`cat ~/Library/Application\ Support/mobster/active-mobsters`
# NOTE: authors must have an email to be valid, so they need to be in the form "Some name, another name, ... <email@address.com>"
git commit -v --author="$MOBSTERS <$USER_EMAIL>"
