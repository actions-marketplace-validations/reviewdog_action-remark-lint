#!/bin/bash
set -eu # Increase bash error strictness

if [[ -n "${GITHUB_WORKSPACE}" ]]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# NOTE: Used for debugging
if [[ "$#" -eq 0 && "${INPUT_REMARK_FLAGS}" != "" ]]; then
  remark_args=(${INPUT_REMARK_FLAGS})
elif [[ "$#" -ne 0 && "${INPUT_REMARK_FLAGS}" != "" ]]; then
  remark_args=($* ${INPUT_REMARK_FLAGS})
elif [[ "$#" -ne 0 && "${INPUT_REMARK_FLAGS}" == "" ]]; then
  remark_args=($*)
fi

# NOTE: ${VAR,,} Is bash 4.0 syntax to make strings lowercase.
echo "[action-remark-lint] Checking markdown code with the remark-lint linter and reviewdog..."
remark --use=remark-preset-lint-recommended . ${remark_args[@]} 2>&1 |
  sed 's/\x1b\[[0-9;]*m//g' | # Removes ansi codes see https://github.com/reviewdog/errorformat/issues/51
  reviewdog -f=remark-lint \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER,,}" \
    -filter-mode="${INPUT_FILTER_MODE,,}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR,,}" \
    -level="${INPUT_LEVEL,,}" \
    -tee \
    ${INPUT_REVIEWDOG_FLAGS}
