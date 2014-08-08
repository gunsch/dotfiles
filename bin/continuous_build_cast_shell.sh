#!/usr/bin/env bash
# Builds cast_shell, compares to existing builds and notifies appropriate
# people.

set -e

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path to chromium (not src)>" 1>&2;
  exit 1;
fi


STATUS_FILENAME="last.result"
COMMIT_FILENAME="last.commit"
FAIL_STR="FAIL"
SUCCESS_STR="SUCCESS"
LAST_RESULT="$(cat ${STATUS_FILENAME} 2>/dev/null || echo -n "${SUCCESS_STR}")"
LAST_RESULT_COMMIT="$(cat ${COMMIT_FILENAME} 2>/dev/null || echo -n "")"
BINDIR="$(dirname $0)"

cd $1;
if $BINDIR/build_cast_shell.sh ${1}/src; then
  # Success.
  NEW_RESULT="${SUCCESS_STR}"
else
  NEW_RESULT="${FAIL_STR}"
fi

NEW_COMMIT="$(cd src && git log -1)"
echo -n "${NEW_RESULT}" > ${STATUS_FILENAME}
echo "${NEW_COMMIT}" > ${COMMIT_FILENAME}

# What happened last time?
if [[ "${LAST_RESULT}" != "${NEW_RESULT}" ]]; then
  # TODO
  echo "Email Jesse here. Was ${LAST_RESULT}, now ${NEW_RESULT}"
  echo "Last ${LAST_RESULT} happened at:"
  echo "================================"
  echo "${LAST_RESULT_COMMIT}"
  echo "================================"
  echo "Current ${NEW_RESULT} happened at:"
  echo "================================"
  echo "${NEW_COMMIT}"
  echo "================================"
fi

