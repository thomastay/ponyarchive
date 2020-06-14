A Pony wrapper for [libarchive](https://github.com/libarchive/libarchive), a multi-format archive and compression library.

Currently supports one operation, namely extracting files from a tar.gz file, or a .zip file into the current directory.

See [archiver.pony](archiver.pony)

## Future work

- Support OSX and GNU/Linux
- Support extraction into a custom directory


## Requirements

You must provide a build of libarchive, liblzma, libbzip2, libgzip. Builds for Windows are provided but that's all.
See the vendored [README](vendor/README.md) for more details.

Other than that, all the logic is in archiver.pony


## License

This code is MIT licensed. Use it as you wish. libarchive and assorted libraries have their own license, see the vendored packages.
