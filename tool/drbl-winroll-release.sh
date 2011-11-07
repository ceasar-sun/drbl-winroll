#!/bin/sh

######################################################
# Author: Ceasar Sun
# Description: Package and release toolkit for latest version from RC repository then 
#
# Usage: bash ./drbl-winroll-release.sh
######################################################

export LC_ALL=C

RELVER=
CURRENT_PATH=`pwd`
WORKDIR=`mktemp -d /tmp/pack.tmp.XXXXXX`
PACKNAME=drbl-winroll
REPOS_URL="ssh://free.nchc.org.tw:3322/home/gitpool/drbl-winroll.git"

[ -z "$(which git 2/dev/null)" ] && echo 'Need git command installed !!' && exit 1;

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
md5sum $WORKDIR-*-setup.zip > MD5SUMS

if [ -d ../../doc/ ] && [ -w ../../doc/ ] ; then
	rsync -a $WORKDIR/$PACKNAME/doc/ ../../doc/
fi

popd

[ -d "$WORKDIR" ] && rm -rf $WORKDIR

