# Homebrew GDB Formula
This is a custom version of Homebrew's GDB formula, designed to work with MacOS Mojave 10.14.  While many users report that GDB 8.0.1 was the last version to work properly on MacOS, that version cannot recognize executables created in MacOS Mojave 10.14 because of a new flag present.  This formula builds the head version with the proper patches to enable debugging, resulting in a working version of GDB in Mojave.

# Installation
Simply run:
```bash
brew install https://raw.githubusercontent.com/joshuaspring9/brew-gdb/master/gdb.rb
```
To prevent Homebrew from updating the package and breaking the installation, run:
```bash
brew pin gdb
```