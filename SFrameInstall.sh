#!/bin/sh

if [ "$#" -ne 2 ] ; then
    echo "Usage: source SFrameInstall.sh <directory to install sframe> <directory of fastjet lib directory>"
    return
fi

if [ "${ROOTSYS}" = "" ] ; then
    echo "Please setup ROOT before calling this script"
    return 
fi

export SFRAMEDIR=$1
export FASTJETDIR=$2

if [[ -e $SFRAMEDIR ]]; then
    echo "Warning: directory $SFRAMEDIR already exists, content may be overwritten"
fi

svn co https://sframe.svn.sourceforge.net/svnroot/sframe/SFrame/tags/SFrame-03-06-11 $SFRAMEDIR

cd $SFRAMEDIR
touch fullsetup.sh

echo 'export FASTJETDIR='${FASTJETDIR}' \nexport LD_LIBRARY_PATH="'$FASTJETDIR:${SFRAMEDIR}'/SFrameTools/JetMETObjects/lib:$LD_LIBRARY_PATH" \nsource setup.sh' > fullsetup.sh
source fullsetup.sh

make -j 8

git clone https://github.com/UHHAnalysis/NtupleWriter.git NtupleWriter
git clone https://github.com/UHHAnalysis/SFrameTools.git SFrameTools
git clone https://github.com/UHHAnalysis/SFrameAnalysis.git SFrameAnalysis

cd NtupleWriter
source configure.sh
make -j 8
cd ../SFrameTools
make -j 8
cd JetMETObjects 
make -j 8
cd ../../SFrameAnalysis
make -j 8