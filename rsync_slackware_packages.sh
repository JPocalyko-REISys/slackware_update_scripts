#!/bin/sh

MIRROR=${MIRROR:-ftp.slackware.com}
VERSION=${VERSION:-current}
MAXSIZE=${MAXSIZE:-500k}
BWLIM=${BWLIM:-100k}

function rmlockNexit() {

    rm /var/lock/slackpkg.$$ &>/dev/null
    exit
}

function RSYNCSLACKWARE() {

rsync $@ --bwlimit=$BWLIM --info=progress -acvz --max-size $MAXSIZE --exclude "source" --del

}

trap 'rmlockNexit' 2 14 15          # trap CTRL+C and kill

if [ "$(ls /var/lock/slackpkg.* 2>/dev/null)" ] ; then
    echo -e "\
\nAnother instance of slackpkg is running. If this is not correct, you can\n\
remove /var/lock/slackpkg.* files and run slackpkg again.\n"

    rmlockNexit

    else
      touch /var/lock/slackpkg.$$
    fi

echo "Bandwith = $BWLIM and Maximun filesize = $MAXSIZE"

RSYNCSLACKWARE $MIRROR::slackware/slackware64-$VERSION/slackware64/ /var/cache/packages/slackware64
RSYNCSLACKWARE $MIRROR::slackware/slackware64-$VERSION/patches/ /var/cache/packages/patches
RSYNCSLACKWARE $MIRROR::slackware/slackware64-$VERSION/testing/ /var/cache/packages/testing
RSYNCSLACKWARE $MIRROR::slackware/slackware64-$VERSION/extra/ /var/cache/packages/extra

RSYNCSLACKWARE rsync://bear.alienbase.nl/mirrors/people/alien/sbrepos/$VERSION/x86_64/ /var/cache/packages/SLACKPKGPLUS_alienbob
RSYNCSLACKWARE rsync://bear.alienbase.nl/mirrors/people/alien/restricted_sbrepos/$VERSION/x86_64/ /var/cache/packages/SLACKPKGPLUS_restricted
RSYNCSLACKWARE rsync://bear.alienbase.nl/mirrors/alien-kde/$VERSION/latest/x86_64/ /var/cache/packages/SLACKPKGPLUS_ktown

rmlockNexit
