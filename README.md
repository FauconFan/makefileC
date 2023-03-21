# [NOT STABLE YET] still developping this idea

# The (ultimate project manager) Makefile [![Main](https://github.com/FauconFan/makefileC/actions/workflows/main.yml/badge.svg)](https://github.com/FauconFan/makefileC/actions/workflows/main.yml)

This is the summary of my experience applied to programming in C. My ambition is to put together all good practices and necessary features of a well-driven C project. I would like to include good compilation, sub-projects, static analyzers, and testing processes.

I want this makefile to be easy to use, easy to get started with and well-documented.

## Ambition

The ultimate makefile must be ***intuitive***, ***simple***, ***configurable***, ***easy to understand*** and finally and most importantlty ***practical***.

# Documentation

## Getting Started

Basically you can copy/paste the whole content of the makefile into your project. You can then use `make init` in order to have a minimal viable project. This will create the minimal file you need in order to start your project.

```bash
curl -fsSL https://raw.githubusercontent.com/FauconFan/makefileC/master/Makefile -o Makefile
make init
```

## Features

- Support basic rules:
  - `make` or `make all`: build the binary
  - `make clean`: remove all binaries and generated files except the binary
  - `make fclean`: remove all binaries and generated files
  - `make re`: shortcut for `make fclean && make all`
- Debug mode `make debug` and `make redebug`
- Help command `make help`
- Init command `make init` (when starting a new project only)
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
  - Missing variables
  - Unauthorized variables are defined
  - Specified files are missing
  - Presence of unspecified files

Things that I don't want:
- Automatic tracking of source files
- Automatic tracking of header files

This is the current state of this project management project.  
A more precise list of feature and incoming features is done in a file called `.todo`.

## Documentation of `config.mk`

In the `config.mk` file, some variables can be defined. We have two types of variables: necessary variables in order to make the makefile work properly, and optional variables with default values. Here is the exhaustive list:

### Necessary Variables

| Name | Description |
| :--- | :---        |
| NAME | Name of the release binary |
| NAME_DEBUG | Name of the debug binary |
| BUILD_FOLDER | Folder name for generated files |
| INC_FOLDER | Folder name for header files |
| SRC_FOLDER | Folder name for source files |
| SRC | Exhaustive list of source files stored in SRC_FOLDER |

### Optional Variables

| Name | Description | Default value |
| :--- | :---        | :---          |
| CC | Compiler used | clang |
| CFLAGS_COMMON | Flags shared both for release and debug builds | -Wall -Wextra -Werror -Weverything -pedantic -std=c17 |
| CFLAGS_RELEASE | Flags used for relase build | -O2 -DNDEBUG |
| CFLAGS_DEBUG | Flags used for debug build | -O0 -DDEBUG -ggdb |
| LDFLAGS | Library flags given to compiler such as '-L' | |
| LDLIBS | Library flags given to compiler such as '-l' | |

## Available commands of `make`

Once all the necessary variables are available, a few commands are available:

```bash
$> make help
Usage: make [target]

Here is the list of targets:
  - make all                       Builds the release binary
  - make clean                     Removes generated files except binaries
  - make fclean                    Removes all generated files
  - make re                        Alias for "make fclean && make all"
  - make debug                     Same as "make all" except it uses debug flags
  - make redebug                   Alias for "make fclean && make debug"
  - make install                   Installs the binary/library on the system
  - make uninstall                 Uninstalls the binary/library from the system
  - make init                      Initialize the project (at start only)
  - make help                      Prints this message

  You can also provide two extra variables:
  - VERBOSE (default: 0):
      If enabled, meaningful commands are printed.
      A non-meaningful command is a print command, create directories, etc.
        ex: `make re VERBOSE=1`
  - NO_COLORS (default: 0):
      If enabled, no colors will be printed
        ex: `make help NO_COLORS=1`
```
