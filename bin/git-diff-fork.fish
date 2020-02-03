#!/usr/bin/fish

set -l base
set -l other
set -l diff_with_working_tree

switch (count $argv)
    case "0"
        set base "origin/master"
        set other "HEAD"
        set diff_with_working_tree "1"
    
    case "1"
        set base $argv[1]
        set other "HEAD"
        set diff_with_working_tree "1"

    case "2"
        set base $argv[1]
        set other $argv[2]
        set diff_with_working_tree "0"

    case "*"
        echo "Usage: git diff-fork [BASE_BRANCH [COMMIT-ISH]]"
        exit
end

set -l other_branch (git rev-parse --abbrev-ref $other)
if test $status -ne 0; exit; end

set -l merge_base (git merge-base $base $other_branch)
if test $status -ne 0; exit; end

switch $diff_with_working_tree
    case "0"
        git diff --ignore-space-change $merge_base $other
    case "1"
        git diff --ignore-space-change $merge_base
end
