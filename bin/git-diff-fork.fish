#!/usr/bin/fish

set -l base
set -l target

switch (count $argv)
    case "0"
        set base "origin/master"
        set target "HEAD"
    
    case "1"
        set base $argv[1]
        set target "HEAD"

    case "2"
        set base $argv[1]
        set target $argv[2]

    case "*"
        echo "Usage: git diff-fork [BASE_BRANCH [COMMIT-ISH]]"
        exit
end

set -l rev (git rev-parse --abbrev-ref HEAD)
if test $status -ne 0; exit; end

set -l merge_base (git merge-base --fork-point $base $rev)
if test $status -ne 0; exit; end

git diff $merge_base
