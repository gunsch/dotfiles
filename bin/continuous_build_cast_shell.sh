#!/usr/bin/env bash
# Builds cast_shell, compares to existing builds and notifies appropriate
# people.

set -e

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path to chromium (not src)>" 1>&2;
  exit 1;
fi

# Put whole script under lock.
(
flock -n 9 || exit 1;

cd $1;

STATUS_FILENAME="last.result"
COMMIT_FILENAME="last.commit"
FAIL_STR="FAIL"
SUCCESS_STR="SUCCESS"
LAST_RESULT="$(cat ${STATUS_FILENAME} 2>/dev/null || echo -n "${SUCCESS_STR}")"
LAST_RESULT_COMMIT="$(cat ${COMMIT_FILENAME} 2>/dev/null || echo -n "")"
BINDIR="$(dirname $0)"

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
  cat <<END | email -t "gunsch@google.com" -s "Chromium build: ${NEW_RESULT} (${NEW_COMMIT})"
cast_shell build status changed:

Was ${LAST_RESULT}, now ${NEW_RESULT}
Current ${NEW_RESULT} happened at:
================================
${NEW_COMMIT}
================================


Last ${LAST_RESULT} happened at:
================================
${LAST_RESULT_COMMIT}
================================
END
fi


# End of lock.
) 9>/var/lock/chromium-lockfile
