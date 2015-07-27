#!/bin/bash

######################################################
# Author: Ceasar Sun
# Description: Package and release toolkit for latest version from RC repository then 
# Usage: bash ./drbl-winroll-release.sh
#		--localdb local-git/path
######################################################

export LC_ALL=C

RELVER=
CURRENT_PATH=`pwd`
WORKDIR=`mktemp -d /tmp/pack.tmp.XXXXXX`
PACKNAME=drbl-winroll
REPOS_URL="free:/home/gitpool/drbl-winroll.git"

[ -z "$(which git 2/dev/null)" ] && echo 'Need git command installed !!' && exit 1;

usage(){
	echo "$0 [option]
	-l, --localdb /local/git/respository
				Use local as git repository
	-d			debug mode
	-k			keep temporary folder
";
}


# Parse command-line options
while [ $# -gt 0 ]; do
	case "$1" in
		-l|--localdb) shift; 
			[ -d "$1/.git" ] && REPOS_URL="$(cd $1 ; pwd)" || (echo "Local path error: $REPOS_URL , exit !!" && exit ;)
			 shift ;;
		-d|--debug) shift ; _DEBUG=y ;;
		-k|--keep) shift ; _KEEP="y" ;;
		-h|--help)	shift ; usage ; exit 0 ;;
		--)		shift ; usage ; exit 0 ;;
		-*)		echo "${0}: ${1}: invalid option" ; usage; exit; shift ;;
		*)	usgae; exit ;shift ;;
	esac
done

pushd $WORKDIR
git clone $REPOS_URL
pushd $PACKNAME

#PACKVER="$(svn info $REPOS_URL | grep 'Last Changed Rev'| awk -F ": " '{print $2}' )"
PACKVER="$(git log | grep -E '^commit' | wc -l)"
RELVER="$(grep 'drbl-winroll.VERSION' ./conf/winroll.conf | awk -F '=' '{print $2}' | sed -e 's/\s//g')"
echo "Packaging $PACKNAME version: $PACKVER-$RELVER ..."
echo "write version information into config file:  $PACKNAME/conf/winroll.conf"
sed -i -e "s/^rc.VERSION\s*=\s*.*/rc.VERSION = $PACKVER/g" ./conf/winroll.conf
sed -i -e "s/^\!define PRODUCT_VERSION\s*.*/!define PRODUCT_VERSION \"$RELVER-$PACKVER\"/g" ./tool/winroll.nsi
rm -rf .git _dev
popd

echo "run : zip -r -q drbl-winroll-$RELVER-$PACKVER-setup.zip $PACKNAME"
zip -r -q $PACKNAME-$RELVER-$PACKVER-setup.zip $PACKNAME
echo "run : makensis drbl-winroll/tool/winroll.nsi"
makensis -V2 drbl-winroll/tool/winroll.nsi
popd

mv $WORKDIR/$PACKNAME-$RELVER-$PACKVER-setup.* $CURRENT_PATH
md5sum $PACKNAME-*-setup.* > MD5SUMS

if [ -d ../../doc/ ] && [ -w ../../doc/ ] ; then
	rsync -a $WORKDIR/$PACKNAME/doc/ ../../doc/
fi

[ -d "$WORKDIR" -a -z "$_KEEP" ] && rm -rf $WORKDIR

exit 0;
