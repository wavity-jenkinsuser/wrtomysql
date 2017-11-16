#!/usr/bin/env bash

regexp_message () {
  echo "Hello, i'm regexp function"
  echo "My message is: $1"
  echo "My regexp string is :$2"
}

echo "Hello, i'm temp script."

echo "My var GIT_PREVIOUS_SUCCESSFUL_COMMIT is: ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}"
echo "My var GIT_COMMIT is: ${GIT_COMMIT}" 

COMMIT_ARRAY=$(git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD)
for commit in ${COMMIT_ARRAY[@]}
do
if [ "${commit}" != "${GIT_PREVIOUS_SUCCESSFUL_COMMIT}" ]
then
echo "Let's check commit ${commit}"
MESSAGE=$(git log --format=%B -n 1 ${commit})
regexp_message ${MESSAGE} string
fi
done

echo "Goodbye i'm done."
