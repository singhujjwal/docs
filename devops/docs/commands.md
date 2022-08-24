# Quick Reference Commands

## GIT

### Revert a PR

git checkout <branch>
git pull
git log

now switch to another branch
gco -b revert-pr

`git revert -m 1 <SHA-1>`
`git push`

###  Revert a local commit 

#### Revert last commit 
git reset --hard HEAD~1

#### Revert last 5 commits
git reset --hard HEAD~5

#### Rever commits but keep content

git reset --soft HEAD~1

#### Delete a specific commit

git reset --hard <sha1-commit-hash>
