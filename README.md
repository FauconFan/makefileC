# The ultimate makefile I wish I had for C development

This makefile is quite simply the ultimate makefile that I wish I had when I start developing in C.

It has no dependencies except for the make utility itself. It doesn't use any scripting language under the hood and does it all on its own.

These are the following features the makefile have:

- Support basic rules:
  - `make` or `make all`: build the binary
  - `make clean`: remove all binaries and generated files except the binary
  - `make fclean`: remove all binaries and generated files
  - `make re`: shortcut for make fclean && make all
- Debug mode `make debug` and `make redebug`
- Verbose mode with VERBOSE=1 `make VERBOSE=1 [target]` (prints out meaningful commands)
- Compile or recompile only if necessary (source files as well as header files)
- If no file needs to be recompiled, nothing is done (no relink)
- Progress status during (re)compiling (per file)
- Multithread support (native makefile feature)
- Out-of-source builds (the source and header directory is not altered in any way)
- Configuration through a config file `config.mk`
  - Specify names of final binaries (release and debug)
  - Change compiler and flags (warnings, optimization, debug, standard, etc...)
  - Specify source, build, and include directories names
  - List all source files
- Error handling
  - The `config.mk` file is missing
  - Unauthorized variables are defined
  - Specified files are missing
  - Presence of unspecified files

Things that I don't want:
- Automatic tracking of source files
- Automatic tracking of header files

This is the current state of this project management project.  
A more precise list of feature and incoming features is done in a file called `.todo`.
