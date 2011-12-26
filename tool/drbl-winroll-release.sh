#!/bin/bash

######################################################
# Author: Ceasar Sun
# Description: Package and release toolkit for latest version from RC repository then 
# Usage: bash ./drbl-winroll-release.sh
#		--localdb local-git/path
# Note to commit into ~/drbl-winroll/tool if do something changes
######################################################

export LC_ALL=C

RELVER=
CURRENT_PATH=`pwd`
WORKDIR=`mktemp -d /tmp/pack.tmp.XXXXXX`
PACKNAME=drbl-winroll
REPOS_URL="free:/home/gitpool/drbl-winroll.git"

[ -z "$(which git 2/dev/null)" ] && echo 'Need git command installed !!' && exit 1;

# Parse command-line options
while [ $# -gt 0 ]; do
	case "$1" in
		--localdb) shift; REPOS_URL=$CURRENT_PATH/$1;
			[ ! -d "$REPOS_URL" ] && echo "Local path error: $REPOS_URL , exit !!" && exit ;
			 shift ;;
		-d|--debug) shift ; _DEBUG=y ;;
		-p|--purge) shift ; _PURGE="y" ;;
		--help)	shift ; echo "man me !!" ;;
		--)		shift ; break ;;
		-*)		echo "${0}: ${1}: invalid option" ; do_print_help=y; 	shift ;;
		*)	echo "man me !!" ; exit ;shift ;;
	esac
done

pushd $WORKDIR
git clone $REPOS_URL
pushd $PACKNAME
#PACKVER="$(svn info $REPOS_URL | grep 'Last Changed Rev'| awk -F ": " '{print $2}' )"
PACKVER="$(git log | grep -E '^commit' | wc -l)"
echo "Packaging $PACKNAME version: $PACKVER ..."

RELVER="$(grep 'drbl-winroll.VERSION' ./conf/winroll.conf | awk -F '=' '{print $2}' | sed -e 's/\s//g')"

echo "write version information into config file:  $PACKNAME/conf/winroll.conf"
sed -i -e "s/^rc.VERSION\s*=\s*.*/rc.VERSION = $PACKVER/g" ./conf/winroll.conf
rm -rf .git
popd

echo "run : zip -r -q drbl-winroll-v$RELVER-$PACKVER-setup.zip $PACKNAME"
zip -r -q $PACKNAME-v$RELVER-$PACKVER-setup.zip $PACKNAME
popd

mv $WORKDIR/$PACKNAME-v$RELVER-$PACKVER-setup.zip $CURRENT_PATH
md5sum $PACKNAME-*-setup.zip > MD5SUMS

if [ -d ../../doc/ ] && [ -w ../../doc/ ] ; then
	rsync -a $WORKDIR/$PACKNAME/doc/ ../../doc/
fi

[ -d "$WORKDIR" ] && rm -rf $WORKDIR

exit 0;
