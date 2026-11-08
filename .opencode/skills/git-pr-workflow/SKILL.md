---
name: git-pr-workflow
description: Use when creating branches, commits, or pull requests in the HMD621_monitoring repository, or when syncing the local master branch after a merge. Covers the rule that master is never changed directly, branch naming, the pull request template, English commit messages, and LF line endings.
---

# Git and pull request workflow

## Rules

- Never commit or push to `master`. Every change goes through a branch and a pull request into `master`.
- Branch names: `feature/<short-description>`, `fix/<short-description>`, or `docs/<short-description>`. Use lowercase letters and hyphens.
- Get approval before creating a branch, commit, push, or pull request. Show the exact files and content first.
- Commit messages, pull request titles, and descriptions are in English. Use the imperative mood in commit subjects.
- The user merges pull requests. Do not merge, close, or force-push.
- Do not delete branches without approval.

## Steps

1. Sync `master` before new work: `git checkout master`, then `git pull --ff-only origin master`.
2. Create the branch: `git checkout -b <branch-name>`.
3. Make the changes. Keep repository files LF. Check with `git ls-files --eol <path>`: the index must show `i/lf`.
4. Stage only the intended paths and check `git status --short`.
5. Commit with one descriptive subject line.
6. Push with `git push -u origin <branch-name>`.
7. Open the pull request using `.github/pull_request_template.md`. Fill in every section. Mark items as not applicable or not tested when that is true.
8. After the user confirms the merge, sync `master` again (step 1).

## Notes

- Windows checkouts may show CRLF because of `core.autocrlf`. Committed files must still be LF.
- Shell scripts must be LF because they run in Linux containers.
