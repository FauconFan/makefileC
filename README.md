# [NOT STABLE YET] still developping this idea

# The (ultimate project manager) Makefile

This is the summary of my experience applied to programming in C and C++. My ambition is to put together all good practices and necessary features of a well-driven C or C++ project. I would like to include good compilation, sub-projects, static analyzers, and testing processes.

I want this makefile to be easy to use, easy to get started with and well-documented.

## Ambition

The ultimate makefile must be ***intuitive***, ***simple***, ***configurable***, ***easy to understand*** and finally and most importantlty ***practical***.

# Documentation

## Getting Started

Basically you can copy/paste the whole content of the makefile into your project. You can then create a file called `config.mk`, run `make` and follow the instructions, you can also use the default template available in this repository as `template.config.mk`.

```bash
curl -fsSL https://raw.githubusercontent.com/FauconFan/makefileC/master/Makefile -o Makefile
```

Then create the `config.mk` file and follow the instructions from `make`

```bash
touch config.mk
make
```

OR

You can use the default template:

```bash
curl -fsSL https://raw.githubusercontent.com/FauconFan/makefileC/master/template.config.mk -o config.mk
```

## Features

- Support basic rules:
  - `make` or `make all`: build the binary
  - `make clean`: remove all binaries and generated files except the binary
  - `make fclean`: remove all binaries and generated files
  - `make re`: shortcut for `make fclean && make all`
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

## Availables commands of `make`

Once all the Necessary Variables are available, a few commands are available:

- `make` or `make all`: Compiles the source files and generate the final binary
- `make clean`: Remove all generated files except final binaries
- `make fclean`: Remove all generated files
- `make re`: Alias for `make fclean && make all`
- `make debug`: Same as `make all` except it uses debug flags
- `make redebug`: Alias for `make fclean && make debug`

There are also two additional variables that can be provided through command line: VERBOSE and DEBUG. These variables looks like boolean variables, their values are either 0 or 1. Their both values are 0 by default.

If VERBOSE is enabled, meaningful commands are printed. A non-meaningful command is a print command, creating directories, ...  
If DEBUG is enabled, all commands are printed. This is usefell when maintaining this subject.
