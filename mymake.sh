#!/usr/bin/env bash
#=============================================================================#
# do all the make at once
#=============================================================================#
export PATH="$HOME/anaconda2/bin:$PATH" # <- when running script from sublime-build, python calls from /usr/bin/python.  i want anaconda python to run
# which python # <- verify python from anaconda is running
make clean
rm -r ./source/generated*
rm -r ./source/io/generated*
# mkdir ./source/generated
# mkdir ./source/generated/generated
# cp -r ./source/_templates ./source/generated/
# cp -r ./source/_templates ./source/generated/generated/
make html
# mv $(find *.png -maxdepth 1) ./build/html/_static/
# rsync -r build/html/ bs4doc/