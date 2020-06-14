actor Main
  new create(env: Env) =>
    try
      let filename = env.args(1)?
      Archiver.extractZiptar(filename, ".", env.out)
    else
      env.out.print("Please enter a filename")
    end