#!/bin/sh

if [ "$#" -ne 2 ] ; then
    echo "Usage: ./SFrameInstall.sh <directory to install sframe> <directory of fastjet lib directory>"
    return
fi

if [ "${ROOTSYS}" = "" ] ; then
    echo "Please setup ROOT before calling this script"
    return 
fi

SFRAMEDIR=`readlink -f $1`
FASTJETDIR=`readlink -f $2`

if [[ -e $SFRAMEDIR ]]; then
    echo "Warning: directory $SFRAMEDIR already exists, content may be overwritten"
fi

if [ ! -e $FASTJETDIR/libfastjet.so ]; then
    echo "Error: fastjet dir does not contain 'libfastjet.so'";
    return 1;
fi

svn co https://sframe.svn.sourceforge.net/svnroot/sframe/SFrame/tags/SFrame-03-06-11 $SFRAMEDIR

cd $SFRAMEDIR
# remove -lpcre from the core to make sframe_main compile:
sed -i s/-lpcre// core/Makefile
# create and source fullsetup.sh:
echo 'export FASTJETDIR='${FASTJETDIR}' \nexport LD_LIBRARY_PATH="'$FASTJETDIR:${SFRAMEDIR}'/SFrameTools/JetMETObjects/lib:$LD_LIBRARY_PATH" \nsource setup.sh' > fullsetup.sh
source fullsetup.sh

make -j 8

git clone https://github.com/UHHAnalysis/NtupleWriter.git NtupleWriter
git clone https://github.com/UHHAnalysis/SFrameTools.git SFrameTools
git clone https://github.com/UHHAnalysis/SFrameAnalysis.git SFrameAnalysis

cd NtupleWriter
./configure.sh
make -j 8
cd ../SFrameTools
make -j 8
cd JetMETObjects 
make -j 8
cd ../../SFrameAnalysis
make -j 8

