#!/bin/bash
#
# Build i3 and depencendies.
# by Phillip Berndt, www.pberndt.com, June 2013
#
# The default developer packages from debian based distributions,
# cmake and cairo headers are prerequisites for this script. If
# anything else is missing on your system, this script should be
# easily extendible by inserting further packages into the 
# BUILD array below.
#
# Execute this using bash, and the script will try to build all packages in the
# directory ./prefix/build and install them to ./prefix. The process can be
# paused -- the script will consider all prerequisites, for which a directory
# in the build directory already exist, as met. If any package's build fails,
# remove that packages directory and restart the script after applying
# appropriate fixes.
#
# After installation, you can run i3 using
#  LD_LIBRARY_PATH=prefix/lib XDG_CONFIG_HOME=prefix/etc PATH=prefix/bin:$PATH prefix/bin/i3
#
PREFIX=`pwd`
[ -d $PREFIX/build ] || mkdir -p $PREFIX/build
cd $PREFIX/build

export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

### BUILD PREREQUISITES ########################################################
if which virtualenv >/dev/null 2>&1; then
	[ -e $PREFIX/bin/python ] || virtualenv $PREFIX
fi

BUILD=(
	ftp://xmlsoft.org/libxslt/libxml2-2.9.1.tar.gz
	ftp://xmlsoft.org/libxslt/libxslt-1.1.28.tar.gz
	http://xcb.freedesktop.org/dist/xcb-proto-1.8.tar.bz2
	http://xcb.freedesktop.org/dist/libxcb-1.9.tar.bz2
	http://xcb.freedesktop.org/dist/xcb-util-0.3.9.tar.bz2
	http://xcb.freedesktop.org/dist/xcb-util-keysyms-0.3.9.tar.bz2
	http://xcb.freedesktop.org/dist/xcb-util-wm-0.3.9.tar.bz2
	http://github.com/lloyd/yajl/tarball/1.0.12
	http://dist.schmorp.de/libev/libev-4.15.tar.gz
	http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz
	http://cgit.freedesktop.org/xorg/util/macros/snapshot/util-macros-1.17.tar.gz
	http://cgit.freedesktop.org/xorg/lib/libX11/snapshot/libX11-1.6.0.tar.gz
)

for PACKAGE in `seq 0 $[${#BUILD[@]}-1]`; do
	PACKAGE=${BUILD[$PACKAGE]}
	FILE=$(basename $PACKAGE)

	[ -d $FILE ] && continue

	echo "Building $FILE"
	LOGFILE=$(tempfile)

	(
		mkdir $FILE
		cd $FILE
		wget -O $FILE $PACKAGE || exit 1
		tar axf $FILE || exit 1
		rm -f $FILE
		cd * || exit 1
		if [ -e ./configure ]; then
			./configure --prefix=$PREFIX || exit 1
		else
			export ACLOCAL="aclocal -I $PREFIX/share/aclocal"
			./autogen.sh --prefix=$PREFIX
		fi
		make || exit 1
		make install || exit 1
		exit 0
	) >$LOGFILE 2>&1
	if [ "$?" != "0" ]; then
		echo
		echo "FAILED!"
		echo
		cat $LOGFILE
		rm -f $LOGFILE
		exit 1
	fi
	rm -f $LOGFILE
done


### BUILD i3 #############################################################
echo "Building i3"
LOGFILE=$(tempfile)
(
	if [ -d i3 ]; then
		cd i3
		git pull
	else
		git clone git://code.i3wm.org/i3 i3 || exit 1
		cd i3
	fi
	git checkout ${1:-"next"} || exit 1
	make || exit 1
	make install PREFIX=$PREFIX || exit 1
	exit 0
) >$LOGFILE 2>&1
if [ "$?" != "0" ]; then
	echo
	echo "FAILED!"
	echo
	cat $LOGFILE
	rm -f $LOGFILE
	exit 1
fi
rm -f $LOGFILE
echo
echo "Done."