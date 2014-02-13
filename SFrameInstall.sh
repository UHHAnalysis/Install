#!/bin/sh

if [ "$#" -ne 2 ] ; then
    echo "Usage: ./SFrameInstall.sh <directory to install sframe> <directory of fastjet lib directory>"
    exit 1;
fi

if [ "${ROOTSYS}" = "" ] ; then
    echo "Please setup ROOT before calling this script"
    exit 1;
fi

SFRAMEDIR=`readlink -f $1`
FASTJETDIR=`readlink -f $2`

if [ -z $SFRAMEDIR ]; then
   echo "Error: could not resolve given SFRAME target directory '$1'. Make sure to provide a path for which all components but the last exist, omitting the trailing '/'.";
   exit 1
fi


if [[ -e $SFRAMEDIR ]]; then
    echo "Error: directory $SFRAMEDIR already exists; please use a non-existent dir."
    exit 1;
fi

if [ ! -e $FASTJETDIR/libfastjet.so ]; then
    echo "Error: fastjet dir does not contain 'libfastjet.so'";
    exit 1;
fi

function run_checked () {
   $*
   if [ $? -ne 0 ]; then
     echo "Executing $* failed (pwd: $PWD)";
     exit 1;
   fi
}

run_checked svn co https://svn.code.sf.net/p/sframe/code/SFrame/tags/SFrame-03-06-27 $SFRAMEDIR

cd $SFRAMEDIR || { echo "svn co failed!"; exit 1; }

git clone https://github.com/UHHAnalysis/NtupleWriter.git NtupleWriter
git clone https://github.com/UHHAnalysis/SFrameTools.git SFrameTools
git clone https://github.com/UHHAnalysis/SFrameAnalysis.git SFrameAnalysis
git clone https://github.com/UHHAnalysis/SFramePlotter.git SFramePlotter

# apply patches:
export SFRAME_DIR=$SFRAMEDIR
./SFrameTools/apply-sframe-patches.sh || { echo "Error applying sframe patched"; exit 1; }

# create and source fullsetup.sh:
echo -e 'export FASTJETDIR='${FASTJETDIR}' \nexport BOOSTDIR=/cvmfs/cms.cern.ch/slc5_amd64_gcc462/external/boost/1.47.0/include\nexport LD_LIBRARY_PATH="'$FASTJETDIR:${SFRAMEDIR}'/SFrameTools/JetMETObjects/lib:$LD_LIBRARY_PATH" \nsource setup.sh' > fullsetup.sh
# SFrame's setup.sh does not like if there is already a SFRAME_DIR set, so unset it:
export SFRAME_DIR=""
source fullsetup.sh


ln -s SFrameTools/makeall .
ln -s SFrameTools/python/bsframe.py ${SFRAMEDIR}/bin

# compile eveything:
run_checked ./makeall -j 8

echo "\n--------------------------------------------------------------"
echo "SFrame installed. Have fun!"
echo "Additional packages can be installed using:"
echo "git clone https://github.com/UHHAnalysis/XYZ.git XYZ"
echo "where XYZ is the name of the analysis package"
echo "\n--------------------------------------------------------------"

