#!/bin/bash

# Download the latest
if [ -e ChtcRun.tar.gz ]; then
  rm ChtcRun.tar.gz
fi
wget http://chtc.cs.wisc.edu/downloads/ChtcRun.tar.gz

# unzip
tar xzf ChtcRun.tar.gz

# Update python libs
mv ChtcRun/Pythonin/shared/SLIBS.tar.gz .
tar xzf SLIBS.tar.gz # ==> SS/
mv ChtcRun/Pythonin/shared/ENV SS/
mv ChtcRun/Pythonin/shared/URLS SS/
rsync -a SS/ ~/lib/chtc-python/
rm -rf SS SLIBS.tar.gz
echo "Updated Python libraries lib/chtc-python"

# Update R libs
mv ChtcRun/Rin/shared/sl6-RLIBS.tar.gz .
tar xzf sl6-RLIBS.tar.gz # ==> RR/
rsync -a RR/ ~/lib/chtc-R/
rm -rf RR sl6-RLIBS.tar.gz
echo "Updated R libraries lib/chtc-R"

# Update executables
#mv ChtcRun/chtcinnerwrapper ~/bin
mv ChtcRun/handypostscript.pl ~/bin
mv ChtcRun/mkdag ~/bin
mv ChtcRun/make-graphs ~/bin
mv ChtcRun/mydag-status ~/bin
echo "Updated executables bin/"

# Remove fluff
rm -rf ChtcRun/Pythonin
rm -rf ChtcRun/Pythonsrcs
rm -rf ChtcRun/Rin
rm -rf ChtcRun/Rsrcs
rm -rf ChtcRun/Matlabin
rm -rf ChtcRun/Matlabsrcs
rm -rf ChtcRun/MatlabandRin
rm -rf ChtcRun/MatlabandRsrcs
rm -rf ChtcRun/Binin
rm -rf ChtcRun/Csrcs

# Package ChtcRun_lite
cd ChtcRun/
tar czf ChtcRun_lite.tgz chtcjobwrapper postjob.template process.template PROFILE README REPORTREADME RESULTVALUES
rm postjob.template chtcjobwrapper process.template PROFILE README REPORTREADME RESULTVALUES
mv ChtcRun_lite.tgz ~/
cd ../
rm -rf ChtcRun/ ChtcRun.tar.gz
echo "Packaged ChtcRun_lite"
echo ""
echo "Done!"
