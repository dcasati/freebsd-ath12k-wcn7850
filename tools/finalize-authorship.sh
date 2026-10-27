#!/bin/sh
#
# Rewrite author/committer identity and add a DCO Signed-off-by trailer
# to every commit in a range, as required by FreeBSD's CONTRIBUTING.md
# (real name and a reachable address; users.noreply.github.com is not
# accepted).
#
# usage: finalize-authorship.sh -n "Real Name" -e user@example.org
#            [-c keep|drop|assisted] <base> [<branch>]
#
#   -c keep      keep "Co-authored-by: Copilot ..." trailers (default)
#   -c drop      remove them
#   -c assisted  replace them with "Assisted-by: GitHub Copilot"
#
# The branch is rewritten in place; a backup ref is left at
# refs/original-authorship/<branch>.

set -e

if [ "$1" = "--amend-one" ]; then
	msg=$(git log -1 --format=%B)
	case "$copilot" in
	drop)
		msg=$(printf "%s\n" "$msg" | grep -v "^Co-authored-by: Copilot" || :)
		;;
	assisted)
		msg=$(printf "%s\n" "$msg" |
		    sed "s/^Co-authored-by: Copilot.*/Assisted-by: GitHub Copilot/")
		;;
	esac
	printf "%s\n" "$msg" |
	    git interpret-trailers --if-exists addIfDifferent \
	    --trailer "$trailer" |
	    GIT_COMMITTER_NAME="$name" GIT_COMMITTER_EMAIL="$email" \
	    git commit -q --amend --no-verify --author="$name <$email>" -F -
	exit
fi

usage()
{
	echo "usage: ${0##*/} -n name -e email [-c keep|drop|assisted]" \
	    "base [branch]" >&2
	exit 2
}

name=
email=
copilot=keep
while getopts n:e:c: opt; do
	case "$opt" in
	n) name=$OPTARG ;;
	e) email=$OPTARG ;;
	c) copilot=$OPTARG ;;
	*) usage ;;
	esac
done
shift $((OPTIND - 1))
[ -n "$name" ] && [ -n "$email" ] && [ $# -ge 1 ] || usage
case "$copilot" in keep|drop|assisted) ;; *) usage ;; esac
case "$email" in
*users.noreply.github.com)
	echo "${0##*/}: noreply addresses are not accepted by FreeBSD" >&2
	exit 1
	;;
esac

base=$1
branch=${2:-$(git symbolic-ref --short HEAD)}
git diff --quiet && git diff --cached --quiet ||
    { echo "${0##*/}: working tree not clean" >&2; exit 1; }

git update-ref "refs/original-authorship/$branch" "$branch"
git checkout -q "$branch"

trailer="Signed-off-by: $name <$email>"
export name email copilot trailer
GIT_SEQUENCE_EDITOR=: git -c rebase.autosquash=false rebase -q -i \
    --exec "/bin/sh '$(realpath "$0")' --amend-one" "$base"

echo "Rewrote $(git rev-list --count "$base..$branch") commits on $branch."
echo "Backup: refs/original-authorship/$branch"
