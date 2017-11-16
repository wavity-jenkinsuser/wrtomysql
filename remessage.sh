#!/usr/bin/env bash

printenv

echo "Hello, i'm temp script."

echo "My var GIT_PREVIOUS_SUCCESSFUL_COMMIT is: ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}"
echo "My var GIT_PREVIOUS_SUCCESSFUL_COMMIT is: ${GIT_COMMIT}" 
echo "My var GIT_PREVIOUS_SUCCESSFUL_COMMIT is: GIT LOG:"
COMMIT_ARRAY=$(git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD)
for commit in ${COMMIT_ARRAY[@]}
do
echo "Let's check commit ${commit}"
MESSAGE=$(git log --format=%B -n 1 ${commit})
echo "Message is: ${MESSAGE}"
done

echo "Goodbye i'm done."
