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
    echo "Error: directory $SFRAMEDIR already exists."
    exit 1;
fi

if [ ! -e $FASTJETDIR/libfastjet.so ]; then
    echo "Error: fastjet dir does not contain 'libfastjet.so'";
    exit 1;
fi

svn co https://svn.code.sf.net/p/sframe/code/SFrame/tags/SFrame-03-06-11 $SFRAMEDIR
#if [ "$_" -neq "0" ]; then
#   echo "svn co failed!";
#   exit 1;
#fi


cd $SFRAMEDIR || { echo "svn co failed!"; exit 1; }
# remove -lpcre from the core to make sframe_main compile:
sed -i s/-lpcre// core/Makefile
# create and source fullsetup.sh:
echo -e 'export FASTJETDIR='${FASTJETDIR}' \nexport LD_LIBRARY_PATH="'$FASTJETDIR:${SFRAMEDIR}'/SFrameTools/JetMETObjects/lib:$LD_LIBRARY_PATH" \nsource setup.sh' > fullsetup.sh
# SFrame's setup.sh does not like if there is already a SFRAME_DIR set, so unset it:
export SFRAME_DIR=""
source fullsetup.sh

make -j 8

git clone https://github.com/UHHAnalysis/NtupleWriter.git NtupleWriter
git clone https://github.com/UHHAnalysis/SFrameTools.git SFrameTools
git clone https://github.com/UHHAnalysis/SFrameAnalysis.git SFrameAnalysis
git clone https://github.com/UHHAnalysis/SFramePlotter.git SFramePlotter

cd NtupleWriter
make -j 8
cd ../SFrameTools
make -j 8
cd JetMETObjects 
make -j 8
cd ../../SFrameAnalysis
make -j 8
cd $SFRAMEDIR/SFramePlotter
make
cd $SFRAMEDIR

echo "\n--------------------------------------------------------------"
echo "SFrame installed. Have fun!"
echo "Additional packages can be installed using:" 
echo "git clone https://github.com/UHHAnalysis/XYZ.git XYZ"
echo "where XYZ is the name of the analysis package"
echo "\n--------------------------------------------------------------"

