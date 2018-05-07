# R-Scripts
A script for adjusting .png file paths in tikz image files. 
Usually tikz images contain a relative path to a .png. This creates an error if the tikz file and its referenced image are located in a subfolder relative to the compiling .tex file.
Once this script is run, it replaces all image links in .tikz files with a path relative to the folder from where it is executed, so it should be run from the folder that contains the main .tex file.
The convention is that all tikz files have .tikz as an extension.
Created for dealing with files exported with R's tikzDevice package.
