# The ultimate makefile I wish I had for C development

This makefile is quite simply the ultimate makefile that I wish I had when I start developing in C.

It has no dependencies except for the make utility itself. It doesn't use any scripting language under the hood and does it all on its own.

These are the following features the makefile have:

 - Features:
   - Recompile if necessary (C source files as well as header files)
   - No link if no file needs to be recompiled
   - Support basic rules: all clean fclean re
   - Progress status during recompiling
   - Multithread support (native makefile feature)
   - Out-of-source builds
   - Change compiler and flags (default is clang with warning flags on C17)
   - Verbose mode with VERBOSE=1 `make VERBOSE=1`
   - Error handling (missing files.mk file, misssing variables, missing specified files, presence of unspecified files)

Things that I don't want:
 - Automatic tracking of source files
 - Automatic tracking of header files

Things that would be great it had but I don't need it at the moment:
 - Features:
   - make debug / make release
 - Hierarchical projects and deployment
   - Self init
   - Self update (Autocheck new version from repository)
   - makefile subprojects
   - Support for libraries (static or dynamic)
   - Install rule
 - Test and CI
   - Unit test
   - Black box tests (inputs / outputs behavior)
   - Test coverage (from black box)
   - Check memory leaks (from black box)
   - Code quality controls

todo:
 - check previous variables
 - crash when an error occured
 - check if one output file is a keyword
