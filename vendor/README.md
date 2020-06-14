This folder contains vendored dependencies:
1. libarchive 3.4.3
1. lzma
1. bzip
1. gzip

These four dependencies have static libraries built for Windows (64 bit) in `lib/`. Unfortunately, we do not have builds for OSX and Linux yet. 

Of the 4 projects, only libarchive have releases for OSX and Linux. [libarchive release](https://github.com/libarchive/libarchive/releases)

The other 3 projects have their source code vendored here, and luckily can be easily built with GNU autotools and g++. 

## Build instructions
(WIP)

## Libarchive headers
These can be found in `include/archive.h` and `include/archive_entry.h`

## Licensing
TODO
can be found in respective `doc/` folders