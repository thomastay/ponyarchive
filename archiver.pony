use "path:./vendor/lib"
use "lib:liblzma"
use "lib:bz2"
use "lib:zlibstatic"
use "lib:archive_static"
use "files"
use "debug"
// --------------------------------------------
// ----------- FFI Declarations ---------------
// ------- If you need more, add more ---------
// --------------------------------------------
// TODO: generate these automagically by modding c2nim
//
// Read support declarations
use @archive_read_new[_Archptr]()
use @archive_read_support_compression_gzip[I32](a: _Archptr)
use @archive_read_support_compression_lzip[I32](a: _Archptr)
use @archive_read_support_compression_bzip2[I32](a: _Archptr)
use @archive_read_support_format_zip[I32](a: _Archptr)
use @archive_read_support_format_tar[I32](a: _Archptr)
use @archive_read_support_format_all[I32](a: _Archptr)
use @archive_read_open_filename[I32](a: _Archptr,
      filename: Pointer[U8] tag,
      block_size: USize)
use @archive_read_next_header[I32](a: _Archptr, b: Pointer[_ArchEntryptr])
use @archive_read_data_block[I32](a: _Archptr,
  buff: Pointer[Pointer[None]],
  size: Pointer[USize],
  offset: Pointer[I64])
use @archive_read_free[None](a: _Archptr)
// write declarations
use @archive_write_disk_new[_Archptr]()
use @archive_write_disk_set_options[I32](a: _Archptr, flags: I32)
use @archive_write_disk_set_standard_lookup[I32](a: _Archptr)
use @archive_write_header[I32](a: _Archptr, b: _ArchEntryptr)
use @archive_write_data_block[I32](a: _Archptr,
  buff: Pointer[None],
  size: USize,
  offset: I64)
use @archive_write_finish_entry[I32](a: _Archptr)
use @archive_write_free[None](a: _Archptr)
// Misc
use @archive_entry_size[I64](entry: _ArchEntryptr)
use @archive_error_string[Pointer[U8]](a: _Archptr)
// data block declarations

primitive _Archive
primitive _ArchiveEntry
type _Archptr is Pointer[_Archive] //for ease of reading
type _ArchEntryptr is Pointer[_ArchiveEntry] //for ease of reading

actor Archiver
  // libarchive defined constants
  let archive_EOF: I32 = 1
  let archive_OK: I32 = 0
  // Domain Specific constants
  let stdBlockSize: USize = 10240 // recommended by libarchive doc
  let flags: I32 = 102

  // Extract method
  be extractZiptar(filename: String, extractDir: String, out: (OutStream | None) = None) => 
    """
    Implements an extractor based on the example
    provided in the libarchive Examples
    https://github.com/libarchive/libarchive/wiki/Examples#a-complete-extractor
    specifically only does zip and tar files,
    for use in Ponyup
    """
    Debug("Archiver: Extracting files")
    let arch = @archive_read_new()
    let ext = @archive_write_disk_new()
    var entry = _ArchEntryptr
    // let tmp_dir = "data"
    //  try
    //    FilePath.mkdtemp(env.root as AmbientAuth, "temp-dir")?
    //  else
    //    env.out.print("Cannot make temp dir, error")
    //    return 
    //  end
    var err: I32 = 0
    try
      // Add the formats that you wish to unzip
      // ponyup uses only zip files (for Windows), and tar.gz files (OSX, GNU/Linux)
      // to avoid bloat, we only link in support for these libraries.
      err = @archive_read_support_compression_gzip(arch)
      check(err, arch, out)?
      err = @archive_read_support_compression_bzip2(arch)
      check(err, arch, out)?
      err = @archive_read_support_compression_lzip(arch)
      check(err, arch, out)?
      err = @archive_read_support_format_zip(arch)
      check(err, arch, out)?
      err = @archive_read_support_format_tar(arch)
      check(err, arch, out)?
      err = @archive_read_open_filename(arch, filename.cstring(), stdBlockSize)
      check(err, arch, out)?

      err = @archive_write_disk_set_options(ext, flags)
      check(err, ext, out)?
      err = @archive_write_disk_set_standard_lookup(ext)
      check(err, ext, out)?

      // Read files from archive and write them to disk
      try
        err = @archive_read_next_header(arch, addressof entry)
        while err != archive_EOF do 
          check(err, arch, out)?
          err = @archive_write_header(ext, entry)
          check(err, ext, out)?
          if @archive_entry_size(entry) > 0 then
            copyData(arch, ext, out)?
          end
          err = @archive_write_finish_entry(ext)
          check(err, ext, out)?

          // loop
          err = @archive_read_next_header(arch, addressof entry)
        end // end while
      end // end of try-catch for while loop
      @archive_read_free(arch)
      @archive_write_free(ext)
      Debug("Archiver: Extraction complete")
    end



  // --------- HELPER FUNCTIONS ------------
  fun getErrStr(p: _Archptr): String ref =>
    String.from_cstring(@archive_error_string(p))

  fun check(err: I32, p: _Archptr, out: (OutStream | None) = None)? =>
    if err != archive_OK then
      match out
      | let o: OutStream => 
        o.write("Error: " + getErrStr(p) + "\n")
      | None => None
      end
      error
    end
  
  fun copyData(from: _Archptr, to: _Archptr, out: (OutStream | None) = None)? =>
    var err: I32
    var buf: Pointer[None] = Pointer[None]
    var size: USize = 0
    var offset: I64 = 0
    err = @archive_read_data_block(from, addressof buf, addressof size, addressof offset)
    check(err, from, out)?
    err = @archive_write_data_block(to, buf, size, offset)
    check(err, to, out)?
