# The ultimate makefile I wish I had for C development

This makefile is quite simply the ultimate makefile that I wish I had when I start developing in C.

It has no dependencies except for the make utility itself. It doesn't use any scripting language under the hood and does it all on its own.

These are the following features the makefile have:

 - Features:
   - Recompile if necessary (C files as well as header files)
   - No link if no file needs to be recompiled
   - Support basic rules: all clean fclean re
   - Progress status during recompiling
   - Multithread support (normal makefile behavior)
   - Out-of-source builds

Things that I don't want:
 - Automatic tracking of source files
 - Automatic tracking of header files

Things that would be great it had but I don't need it at the moment:
 - Features:
   - verbose mode for makefile
   - Change compiler on demand
   - Good error handling
 - Hierarchical projects and deployment
   - Self install
   - Self update (Autocheck new version from repository)
   - make debug / make release
   - makefile subprojects
   - Support for libraries (static of dynamic)
   - Install rule
 - Test and CI
   - Unit test
   - Test coverage
   - Check for memory leaks from black box tests
   - Code quality controls