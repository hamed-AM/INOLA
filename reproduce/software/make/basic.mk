# Build the VERY BASIC project software before higher-level ones. Assuming
# minimal/generic Make and Shell.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the project after that.
#
# This Makefile builds very low-level and basic tools like GNU Tar, GNU
# Bash, GNU Make, GCC and etc. Therefore this is the only Makefile in the
# project where you CANNOT assume that GNU Bash or GNU Make are used. After
# this Makefile (where GNU Bash and GNU Make are built), other Makefiles
# can safely assume the fixed version of all these software.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2018-2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.


# Top level environment
include reproduce/software/make/build-rules.mk
include reproduce/software/config/installation/LOCAL.mk
include reproduce/software/config/installation/versions.mk

lockdir = $(BDIR)/locks
tdir    = $(BDIR)/software/tarballs
ddir    = $(BDIR)/software/build-tmp
idir    = $(BDIR)/software/installed
ibdir   = $(BDIR)/software/installed/bin
ildir   = $(BDIR)/software/installed/lib
ibidir  = $(BDIR)/software/installed/version-info/bin
ilidir  = $(BDIR)/software/installed/version-info/lib

# We'll need the system's PATH for making links to low-level programs we
# won't be building ourselves.
syspath         := $(PATH)

# As we build more programs, we want to use this project's built programs
# and libraries, not the host's.
export CCACHE_DISABLE    := 1
export PATH              := $(ibdir):$(PATH)
export PKG_CONFIG_PATH   := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export LD_LIBRARY_PATH   := $(ildir):$(LD_LIBRARY_PATH)
export CPPFLAGS          := -I$(idir)/include $(CPPFLAGS)
export LDFLAGS           := $(rpath_command) -L$(ildir) $(LDFLAGS)

# Define the top-level programs (that don't depend on any other).
top-level-programs = low-level-links wget gcc
all: $(foreach p, $(top-level-programs), $(ibidir)/$(p))





# Tarballs
# --------
#
# Prepare tarballs. Difference with that in `high-level.mk': `.ONESHELL' is
# not recognized by some versions of Make (even older GNU Makes). So we'll
# have to make sure the recipe doesn't break into multiple shell calls (so
# we can preserve the variables).
#
# Software hosted at akhlaghi.org/src: As of our latest check (November
# 2018) their major release tarballs either crash or don't build on some
# systems (for example Make or Gzip), or they don't exist (for example
# Bzip2).
#
# In the first case, we used their Git repo and bootstrapped them (just
# like Gnuastro) and built the most recent tarball off of that. In the case
# of Bzip2: its webpage has expired and doesn't host the data any more. It
# is available on the link below (archive.org):
#
# https://web.archive.org/web/20180624184806/http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
#
# However, downloading from this link is slow (because its just a link). So
# its easier to just keep a with the others.
$(lockdir): | $(BDIR); mkdir $@
downloadwrapper = ./reproduce/analysis/bash/download-multi-try
tarballs = $(foreach t, bash-$(bash-version).tar.gz                         \
                        binutils-$(binutils-version).tar.lz                 \
                        bzip2-$(bzip2-version).tar.gz                       \
                        cert.pem                                            \
                        coreutils-$(coreutils-version).tar.xz               \
                        diffutils-$(diffutils-version).tar.xz               \
                        file-$(file-version).tar.gz                         \
                        findutils-$(findutils-version).tar.lz               \
                        gawk-$(gawk-version).tar.lz                         \
                        gcc-$(gcc-version).tar.xz                           \
                        gmp-$(gmp-version).tar.lz                           \
                        grep-$(grep-version).tar.xz                         \
                        gzip-$(gzip-version).tar.gz                         \
                        isl-$(isl-version).tar.bz2                          \
                        libtool-$(libtool-version).tar.xz                   \
                        lzip-$(lzip-version).tar.gz                         \
                        m4-$(m4-version).tar.gz                             \
                        make-$(make-version).tar.lz                         \
                        mpfr-$(mpfr-version).tar.xz                         \
                        mpc-$(mpc-version).tar.gz                           \
                        ncurses-$(ncurses-version).tar.gz                   \
                        openssl-$(openssl-version).tar.gz                   \
                        patchelf-$(patchelf-version).tar.gz                 \
                        pkg-config-$(pkgconfig-version).tar.gz              \
                        readline-$(readline-version).tar.gz                 \
                        sed-$(sed-version).tar.xz                           \
                        tar-$(tar-version).tar.gz                           \
                        unzip-$(unzip-version).tar.gz                       \
                        wget-$(wget-version).tar.lz                         \
                        which-$(which-version).tar.gz                       \
                        xz-$(xz-version).tar.gz                             \
                        zip-$(zip-version).tar.gz                           \
                        zlib-$(zlib-version).tar.gz                         \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%: | $(lockdir)
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then                              \
	  cp $(DEPENDENCIES-DIR)/$* $@;                                     \
	else                                                                \
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g'                              \
	                     -e's/\./ /g'                                   \
	               | awk '{print $$1}' );                               \
	                                                                    \
	  mergenames=1;                                                     \
	  if   [ $$n = bash      ]; then w=http://ftp.gnu.org/gnu/bash;     \
	  elif [ $$n = binutils  ]; then w=http://ftp.gnu.org/gnu/binutils; \
	  elif [ $$n = bzip      ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = cert      ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = coreutils ]; then w=http://ftp.gnu.org/gnu/coreutils;\
	  elif [ $$n = diffutils ]; then w=http://ftp.gnu.org/gnu/diffutils;\
	  elif [ $$n = file      ]; then w=ftp://ftp.astron.com/pub/file;   \
	  elif [ $$n = findutils ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = gawk      ]; then w=http://ftp.gnu.org/gnu/gawk;     \
	  elif [ $$n = gcc       ]; then w=http://ftp.gnu.org/gnu/gcc/gcc-$(gcc-version); \
	  elif [ $$n = gmp       ]; then w=https://gmplib.org/download/gmp; \
	  elif [ $$n = grep      ]; then w=http://ftp.gnu.org/gnu/grep;     \
	  elif [ $$n = gzip      ]; then w=http://ftp.gnu.org/gnu/gzip;     \
	  elif [ $$n = isl       ]; then w=ftp://gcc.gnu.org/pub/gcc/infrastructure; \
	  elif [ $$n = libtool   ]; then w=http://ftp.gnu.org/gnu/libtool;  \
	  elif [ $$n = lzip      ]; then w=http://download.savannah.gnu.org/releases/lzip; \
	  elif [ $$n = m         ]; then                                    \
	    mergenames=0;                                                   \
	    w=http://akhlaghi.org/src/m4-1.4.18-patched.tar.gz;             \
	  elif [ $$n = make      ]; then w=http://akhlaghi.org/src;         \
	  elif [ $$n = mpfr      ]; then w=http://www.mpfr.org/mpfr-current;\
	  elif [ $$n = mpc       ]; then w=http://ftp.gnu.org/gnu/mpc;      \
	  elif [ $$n = ncurses   ]; then w=http://ftp.gnu.org/gnu/ncurses;  \
	  elif [ $$n = openssl   ]; then w=http://www.openssl.org/source;   \
	  elif [ $$n = patchelf  ]; then w=http://nixos.org/releases/patchelf/patchelf-$(patchelf-version); \
	  elif [ $$n = pkg       ]; then w=http://pkg-config.freedesktop.org/releases; \
	  elif [ $$n = readline  ]; then w=http://ftp.gnu.org/gnu/readline; \
	  elif [ $$n = sed       ]; then w=http://ftp.gnu.org/gnu/sed;      \
	  elif [ $$n = tar       ]; then w=http://ftp.gnu.org/gnu/tar;      \
	  elif [ $$n = unzip     ]; then                                    \
	    mergenames=0; v=$$(echo $(unzip-version) | sed -e's/\.//');     \
	    w=ftp://ftp.info-zip.org/pub/infozip/src/unzip$$v.tgz;          \
	  elif [ $$n = wget      ]; then w=http://ftp.gnu.org/gnu/wget;     \
	  elif [ $$n = which     ]; then w=http://ftp.gnu.org/gnu/which;    \
	  elif [ $$n = xz        ]; then w=http://tukaani.org/xz;           \
	  elif [ $$n = zip       ]; then                                    \
	    mergenames=0; v=$$(echo $(zip-version) | sed -e's/\.//');       \
	    w=ftp://ftp.info-zip.org/pub/infozip/src/zip$$v.tgz;            \
	  elif [ $$n = zlib      ]; then w=http://www.zlib.net;             \
	  else                                                              \
	    echo; echo; echo;                                               \
	    echo "'$$n' not a basic dependency name (for downloading)."     \
	    echo; echo; echo;                                               \
	    exit 1;                                                         \
	  fi;                                                               \
	                                                                    \
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*";               \
	  else                           tarballurl=$$w;                    \
	  fi;                                                               \
	                                                                    \
	  echo "Downloading $$tarballurl";                                  \
	  if [ -f $(ibdir)/wget ]; then                                     \
	    downloader="wget --no-use-server-timestamps -O";                \
	  else                                                              \
	    downloader="$(DOWNLOADER)";                                     \
	  fi;                                                               \
	                                                                    \
	  touch $(lockdir)/download;                                        \
	  $(downloadwrapper) "$$downloader" $(lockdir)/download             \
	                     $$tarballurl $@;                               \
	fi





# Low-level (not built) programs
# ------------------------------
#
# For the time being, we aren't building a local C compiler, but we'll use
# any C compiler that the system already has and just make a symbolic link
# to it.
#
# ccache: ccache acts like a wrapper over the C compiler and is made to
# avoid/speed-up compiling of identical files in a system (it is commonly
# used on large servers). It actually makes `gcc' or `g++' a symbolic link
# to itself so it can control them internally. So, for our purpose here, it
# is very annoying and can cause many complications. We thus remove any
# part of PATH of that has `ccache' in it before making symbolic links to
# the programs we are not building ourselves.
makelink = origpath="$$PATH";                                      \
	   export PATH=$$(echo $(syspath) | tr : '\n' | grep -v ccache \
	                       | tr '\n' :);                           \
	   a=$$(which $(1) 2> /dev/null);                              \
	   if [ -e $(ibdir)/$(1) ]; then rm $(ibdir)/$(1); fi;         \
	   if [ x$$a = x ]; then                                       \
	     if [ "x$(strip $(2))" = xmandatory ]; then                \
	       echo "'$(1)' is necessary for higher-level tools.";     \
	       echo "Please install it for the configuration to continue."; \
	       exit 1;                                                 \
	     fi;                                                       \
	   else                                                        \
	     ln -s $$a $(ibdir)/$(1);                                  \
	   fi;                                                         \
	   export PATH="$$origpath"
$(ibdir) $(ildir):; mkdir $@
$(ibidir)/low-level-links: | $(ibdir) $(ildir)

        # The Assembler
	$(call makelink,as)

        # Compiler (Cmake needs the clang compiler which we aren't building
        # yet in the project).
	$(call makelink,clang)
	$(call makelink,clang++)

        # The linker
	$(call makelink,ar)
	$(call makelink,ld)
	$(call makelink,nm)
	$(call makelink,ps)
	$(call makelink,ranlib)

        # Mac OS specific
	$(call makelink,sysctl)
	$(call makelink,sw_vers)
	$(call makelink,dsymutil)
	$(call makelink,install_name_tool)

        # On Mac OS, libtool is different compared to GNU Libtool. The
        # libtool we'll build in the high-level dependencies has the
        # executable name `glibtool'.
	$(call makelink,libtool)

        # GNU Gettext (translate messages)
	$(call makelink,msgfmt)

        # Needed by TeXLive specifically.
	$(call makelink,perl)

        # Necessary libraries:
        #   Libdl (for dynamic loading libraries at runtime)
        #   POSIX Threads library for multi-threaded programs.
	for l in dl pthread; do                    \
          rm -f $(ildir)/lib$$l*;                  \
	  if [ -f /usr/lib/lib$$l.a ]; then        \
	    ln -s /usr/lib/lib$$l.* $(ildir)/;     \
	  fi;                                      \
	done

        # We want this to be empty (so it doesn't interefere with the other
        # files in `ibidir'.
	touch $@










# Level 1 (MOST BASIC): Compression programs
# ------------------------------------------
#
# The first set of programs to be built are those that we need to unpack
# the source code tarballs of each program. First, we'll build the
# necessary programs, then we'll build GNU Tar.
$(ibidir)/gzip: $(tdir)/gzip-$(gzip-version).tar.gz
	$(call gbuild, $<, gzip-$(gzip-version), static, , V=1) \
	&& echo "GNU Gzip $(gzip-version)" > $@

# GNU Lzip: For a static build, the `-static' flag should be given to
# LDFLAGS on the command-line (not from the environment).
ifeq ($(static_build),yes)
lzipconf="LDFLAGS=-static"
else
lzipconf=
endif
$(ibidir)/lzip: $(tdir)/lzip-$(lzip-version).tar.gz
	$(call gbuild, $<, lzip-$(lzip-version), , $(lzipconf)) \
	&& echo "Lzip $(lzip-version)" > $@

$(ibidir)/xz: $(tdir)/xz-$(xz-version).tar.gz
	$(call gbuild, $<, xz-$(xz-version), static) \
	&& echo "XZ Utils $(xz-version)" > $@

$(ibidir)/bzip2: $(tdir)/bzip2-$(bzip2-version).tar.gz
        # Bzip2 doesn't have a `./configure' script, and its Makefile
        # doesn't build a shared library. So we can't use the `gbuild'
        # function here and we need to take some extra steps (inspired
        # from the "Linux from Scratch" guide for Bzip2):
        #   1) The `sed' call is for relative installed symbolic links.
        #   2) The special Makefile-libbz2_so builds shared libraries.
        #
        # NOTE: the major version number appears in the final symbolic
        # link.
	tdir=bzip2-$(bzip2-version);                                  \
	if [ $(static_build) = yes ]; then                            \
	  makecommand="make LDFLAGS=-static";                         \
	  makeshared="echo no-shared";                                \
	else                                                          \
	  makecommand="make";                                         \
	  if [ x$(on_mac_os) = xyes ]; then                           \
	    makeshared="echo no-shared";                              \
	  else                                                        \
	    makeshared="make -f Makefile-libbz2_so";                  \
	  fi;                                                         \
	fi;                                                           \
	cd $(ddir) && rm -rf $$tdir && tar xf $< && cd $$tdir         \
	&& sed -e 's@\(ln -s -f \)$$(PREFIX)/bin/@\1@' Makefile       \
	       > Makefile.sed                                         \
	&& mv Makefile.sed Makefile                                   \
	&& $$makeshared                                               \
	&& cp -a libbz2* $(ildir)/                                    \
	&& make clean                                                 \
	&& $$makecommand                                              \
	&& make install PREFIX=$(idir)                                \
	&& cd ..                                                      \
	&& rm -rf $$tdir                                              \
	&& cd $(ildir)                                                \
	&& ln -fs libbz2.so.1.0 libbz2.so                             \
	&& echo "Bzip2 $(bzip2-version)" > $@

$(ibidir)/unzip: $(tdir)/unzip-$(unzip-version).tar.gz
	v=$$(echo $(unzip-version) | sed -e's/\.//');            \
	$(call gbuild, $<, unzip$$v, static,,                    \
	               -f unix/Makefile generic_gcc              \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd,           \
	               -f unix/Makefile                          \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 ) \
	&& echo "Unzip $(unzip-version)" > $@

$(ibidir)/zip: $(tdir)/zip-$(zip-version).tar.gz
	v=$$(echo $(zip-version) | sed -e's/\.//');              \
	$(call gbuild, $<, zip$$v, static,,                      \
	               -f unix/Makefile generic_gcc              \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd,           \
	               -f unix/Makefile                          \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 ) \
	&& echo "Zip $(zip-version)" > $@

# Some programs (like Wget and CMake) that use zlib need it to be dynamic
# so they use our custom build. So we won't force a static-only build.
#
# Note for a static-only build: Zlib's `./configure' doesn't use Autoconf's
# configure script, it just accepts a direct `--static' option.
$(ilidir)/zlib: $(tdir)/zlib-$(zlib-version).tar.gz
	$(call gbuild, $<, zlib-$(zlib-version)) \
	&& echo "Zlib $(zlib-version)" > $@

# GNU Tar: When built statically, tar gives a segmentation fault on
# unpacking Bash. So we'll build it dynamically. Note that technically, zip
# and unzip aren't dependencies of Tar, but for a clean build, we'll set
# Tar to be the last compression-related software (the first-set of
# software to be built).
$(ibidir)/tar: $(tdir)/tar-$(tar-version).tar.gz \
	       $(ibidir)/bzip2                   \
	       $(ibidir)/unzip                   \
	       $(ibidir)/gzip                    \
	       $(ibidir)/lzip                    \
               $(ilidir)/zlib                    \
	       $(ibidir)/zip                     \
	       $(ibidir)/xz
        # Since all later programs depend on Tar, the configuration will be
        # stuck here, only making Tar. So its more efficient to built it on
        # multiple threads (when the user's Make doesn't pass down the
        # number of threads).
	$(call gbuild, $<, tar-$(tar-version), , , -j$(numthreads) V=1) \
	&& echo "GNU Tar $(tar-version)" > $@










# Level 2 (SECOND MOST BASIC): Bash and Make
# ------------------------------------------
#
# GNU Make and GNU Bash are the second layer that we'll need to build the
# basic dependencies.
#
# Unfortunately Make needs dynamic linking in two instances: when loading
# objects (dynamically linked libraries), or when using the `getpwnam'
# function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibidir)/make: $(tdir)/make-$(make-version).tar.lz \
                $(ibidir)/tar
        # See Tar's comments for the `-j' option.
	$(call gbuild, $<, make-$(make-version), , , -j$(numthreads)) \
	&& echo "GNU Make $(make-version)" > $@

$(ilidir)/ncurses: $(tdir)/ncurses-$(ncurses-version).tar.gz       \
                   $(ibidir)/make

        # Delete the library that will be installed (so we can make sure
        # the build process completed afterwards and reset the links).
	rm -f $(ildir)/libncursesw*

        # Delete the (possibly existing) low-level programs that depend on
        # `readline', and thus `ncurses'. Since these programs are actually
        # used during the building of `ncurses', we need to delete them so
        # the build process doesn't use the project's Bash and AWK, but the
        # host's.
	rm -f $(ibdir)/bash* $(ibdir)/awk* $(ibdir)/gawk*

        # Standard build process.
	$(call gbuild, $<, ncurses-$(ncurses-version), static,            \
	               --with-shared --enable-rpath --without-normal      \
	               --without-debug --with-cxx-binding                 \
	               --with-cxx-shared --enable-widec --enable-pc-files \
	               --with-pkg-config=$(ildir)/pkgconfig )

        # Unfortunately there are many problems with `ncurses' using
        # "normal" (or 8-bit) characters. The standard way that will work
        # is to build it with wide character mode as you see above in the
        # configuration (or the `w' prefix you see below). Also, most
        # programs (and in particular Bash and AWK), first look for other
        # (mostly obsolete) libraries like tinfo, which define the same
        # symbols. The links below address both situations: we need to fool
        # higher-level packages to find this library even if they aren't
        # explicitly mentioning its name correctly (as a value to `-l' at
        # link time in their configure scripts).
        #
        # This part is taken from the Arch Linux build script[1], then
        # extended to Mac thanks to Homebrew's script [2].
        #
        # [1] https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/ncurses
        # [2] https://github.com/Homebrew/homebrew-core/blob/master/Formula/ncurses.rb
        #
        # Since we can't have comments, in the connected script, here is a
        # summary:
        #
        #   1. We find the actual suffix of the library, from the file that
        #      is not a symbolic link (starting with `-' in the output of
        #      `ls -l').
        #
        #   2. We make symbolic links to all the "ncurses", "ncurses++",
        #      "form", "panel" and "menu" libraries to point to their
        #      "wide" (character) library.
        #
        #   3. We make symbolic links to the "tic" and "tinfo" libraries to
        #      point to the same `libncursesw' library.
        #
        #   4. Some programs link with "curses" (not "ncurses", notice the
        #      starting "n"), so we'll also make links for these to point
        #      to the `libncursesw' library.
        #
        #   5. A link is made to also be able to include files from the
        #      `ncurses' headers.
	if [ x$(on_mac_os) = xyes ]; then so="dylib"; else so="so"; fi;    \
	if [ -f $(ildir)/libncursesw.$$so ]; then                          \
	                                                                   \
	  sov=$$(ls -l $(ildir)/libncursesw*                               \
	               | awk '/^-/{print $$NF}'                            \
	               | sed -e's|'$(ildir)/libncursesw.'||');             \
	                                                                   \
	  cd "$(ildir)";                                                   \
	  for lib in ncurses ncurses++ form panel menu; do                 \
	    ln -fs lib$$lib"w".$$sov     lib$$lib.$$so;                    \
	    ln -fs $(ildir)/pkgconfig/"$$lib"w.pc pkgconfig/$$lib.pc;      \
	  done;                                                            \
	  for lib in tic tinfo; do                                         \
	    ln -fs libncursesw.$$sov     lib$$lib.$$so;                    \
	    ln -fs libncursesw.$$sov     lib$$lib.$$sov;                   \
	    ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/$$lib.pc;      \
	  done;                                                            \
	  ln -fs libncursesw.$$sov libcurses.$$so;                         \
	  ln -fs libncursesw.$$sov libcursesw.$$sov;                       \
	  ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/curses.pc;       \
	  ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/cursesw.pc;      \
	                                                                   \
	  ln -fs $(idir)/include/ncursesw $(idir)/include/ncurses;         \
	  echo "GNU NCURSES $(ncurses-version)" > $@;                      \
	else                                                               \
	  exit 1;                                                          \
	fi

$(ilidir)/readline: $(tdir)/readline-$(readline-version).tar.gz      \
                    $(ilidir)/ncurses
	$(call gbuild, $<, readline-$(readline-version), static,     \
	                --with-curses --disable-install-examples,    \
	                SHLIB_LIBS="-lncursesw" )                    \
	&& echo "GNU Readline $(readline-version)" > $@

$(ibidir)/patchelf: $(tdir)/patchelf-$(patchelf-version).tar.gz \
                    $(ibidir)/make
	$(call gbuild, $<, patchelf-$(patchelf-version), static) \
	&& echo "PatchELF $(patchelf-version)" > $@


# IMPORTANT: Even though we have enabled `rpath', Bash doesn't write the
# absolute adddress of the libraries it depends on! Therefore, if we
# configure Bash with `--with-installed-readline' (so the installed version
# of Readline, that we build below as a prerequisite or AWK, is used) and
# you run `ldd $(ibdir)/bash' on the resulting binary, it will say that it
# is linking with the system's `readline'. But if you run that same command
# within a rule in this project, you'll see that it is indeed linking with
# our own built readline.
ifeq ($(on_mac_os),yes)
needpatchelf =
else
needpatchelf = $(ibidir)/patchelf
endif
$(ibidir)/bash: $(tdir)/bash-$(bash-version).tar.gz \
                $(ilidir)/readline                  \
                $(needpatchelf)

        # Delete the (possibly) existing Bash executable.
	rm -f $(ibdir)/bash

        # Build Bash. Note that we aren't building Bash with
        # `--with-installed-readline'. This is because (as described above)
        # Bash needs the `LD_LIBRARY_PATH' set properly before it is
        # run. Within a recipe, things are fine (we do set
        # `LD_LIBRARY_PATH'). However, Make will also call the shell
        # outside of the recipe (for example in the `foreach' Make
        # function!). In such cases, our new `LD_LIBRARY_PATH' is not set.
        # This will cause a crash in the shell and thus the Makefile,
        # complaining that it can't find `libreadline'. Therefore, even
        # though we build readline below, we won't link Bash with an
        # external readline.
        #
        # Bash has many `--enable' features which are already enabled by
        # default. As described in the manual, they are mainly useful when
        # you disable them all with `--enable-minimal-config' and enable a
        # subset using the `--enable' options.
	if [ "x$(static_build)" = xyes ]; then stopt="--enable-static-link";\
	else                                   stopt="";                    \
	fi;                                             \
	$(call gbuild, $<, bash-$(bash-version),,       \
	                   --with-installed-readline=$(ildir) $$stopt )

        # Atleast on GNU/Linux systems, Bash doesn't include RPATH by
        # default. So, we have to manually include it, currently we are
        # only doing this on GNU/Linux systems (using the `patchelf'
        # program).
	if [ "x$(needpatchelf)" != x ]; then                         \
	  if [ -f $(ibdir)/bash ]; then                              \
	    $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/bash; fi \
	fi

        # To be generic, some systems use the `sh' command to call the
        # shell. By convention, `sh' is just a symbolic link to the
        # preferred shell executable. So we'll define `$(ibdir)/sh' as a
        # symbolic link to the Bash that we just built and installed.
        #
        # Just to be sure that the installation step above went well,
        # before making the link, we'll see if the file actually exists
        # there.
	if [ -f $(ibdir)/bash ]; then            \
	  ln -fs $(ibdir)/bash $(ibdir)/sh;      \
	  echo "GNU Bash $(bash-version)" > $@;  \
	else                                     \
	  echo "GNU Bash not built!"; exit 1; fi





# Downloader
# ----------
#
# OpenSSL: Some programs/libraries later need dynamic linking. So we'll
# build libssl (and libcrypto) dynamically also.
#
# Until we find a nice and generic way to create an updated CA file in the
# project, the certificates will be available in a file for this project
# along with the other tarballs.
#
# In case you do want a static OpenSSL and libcrypto, then uncomment the
# following conditional and put $(openssl-static) in the configure options.
#
#ifeq ($(static_build),yes)
#openssl-static = no-dso no-dynamic-engine no-shared
#endif
$(idir)/etc:; mkdir $@
$(ilidir)/openssl: $(tdir)/openssl-$(openssl-version).tar.gz         \
                   $(tdir)/cert.pem                                  \
                   $(ibidir)/bash | $(idir)/etc
        # According to OpenSSL's Wiki (link bellow), it can't automatically
        # detect Mac OS's structure. It will need some help. So we'll use
        # the `on_mac_os' Make variable that we defined in the configure
        # script and help it with some extra configuration options and an
        # environment variable.
        #
        # https://wiki.openssl.org/index.php/Compilation_and_Installation
	if [ x$(on_mac_os) = xyes ]; then                            \
	  export KERNEL_BITS=64;                                     \
	  copt="shared no-ssl2 no-ssl3 enable-ec_nistp_64_gcc_128";  \
	fi;                                                          \
	$(call gbuild, $<, openssl-$(openssl-version), ,             \
                   zlib                                          \
	               $$copt                                        \
                   $(rpath_command)                              \
                   --openssldir=$(idir)/etc/ssl                  \
	               --with-zlib-lib=$(ildir)                      \
                   --with-zlib-include=$(idir)/include, , ,      \
	               ./config ) &&                                 \
	cp $(tdir)/cert.pem $(idir)/etc/ssl/cert.pem;                \
	if [ $$? = 0 ]; then                                         \
	  if [ x$(on_mac_os) = xyes ]; then                          \
	    echo "No need to fix rpath in libssl";                   \
	  else                                                       \
	    patchelf --set-rpath $(ildir) $(ildir)/libssl.so;        \
	  fi;                                                        \
	  echo "OpenSSL $(openssl-version)" > $@;                    \
	fi

# GNU Wget
#
# Note that on some systems (for example GNU/Linux) Wget needs to explicity
# link with `libdl', but on others (for example Mac OS) it doesn't. We
# check this at configure time and define the `needs_ldl' variable.
#
# Also note that since Wget needs to load outside libraries dynamically, it
# gives a segmentation fault when built statically.
#
# There are many network related libraries that we are currently not
# building as part of this project. So to avoid too much dependency on the
# host system (especially a crash when these libraries are updated on the
# host), they are disabled here.
$(ibidir)/wget: $(tdir)/wget-$(wget-version).tar.lz \
                $(ibidir)/pkg-config                \
                $(ilidir)/openssl
	libs="-pthread";                                          \
	if [ x$(needs_ldl) = xyes ]; then libs="$$libs -ldl"; fi; \
	$(call gbuild, $<, wget-$(wget-version), ,                \
	               LIBS="$$LIBS $$libs"                       \
	               --with-libssl-prefix=$(idir)               \
	               --with-ssl=openssl                         \
	               --with-openssl=yes                         \
	               --without-metalink                         \
	               --without-libuuid                          \
	               --without-libpsl                           \
	               --without-libidn                           \
	               --disable-pcre2                            \
	               --disable-pcre                             \
	               --disable-iri )                            \
	&& echo "GNU Wget $(wget-version)" > $@





# Basic command-line tools and their dependencies
# -----------------------------------------------
#
# These are basic programs which are commonly necessary in the build
# process of the higher-level programs and libraries. Note that during the
# building of those higher-level programs (after this Makefile finishes),
# there is no access to the system's PATH.
$(ibidir)/coreutils: $(tdir)/coreutils-$(coreutils-version).tar.xz \
                     $(ilidir)/openssl
        # Coreutils will use the hashing features of OpenSSL's `libcrypto'.
        # See Tar's comments for the `-j' option.
	$(call gbuild, $<, coreutils-$(coreutils-version), static,           \
	               LDFLAGS="$(LDFLAGS)" CPPFLAGS="$(CPPFLAGS)"           \
	               --enable-rpath --disable-silent-rules --with-openssl, \
	               -j$(numthreads))                                      \
	&& echo "GNU Coreutils $(coreutils-version)" > $@

$(ibidir)/diffutils: $(tdir)/diffutils-$(diffutils-version).tar.xz \
                     $(ibidir)/bash
	$(call gbuild, $<, diffutils-$(diffutils-version), static, , V=1) \
	&& echo "GNU Diffutils $(diffutils-version)" > $@

$(ibidir)/findutils: $(tdir)/findutils-$(findutils-version).tar.lz \
                     $(ibidir)/bash
	$(call gbuild, $<, findutils-$(findutils-version), static, , V=1) \
	&& echo "GNU Findutils $(findutils-version)" > $@

$(ibidir)/gawk: $(tdir)/gawk-$(gawk-version).tar.lz \
                $(ibidir)/bash                      \
                $(ilidir)/mpfr                      \
                $(ilidir)/gmp
        # AWK doesn't include RPATH by default, so we'll have to manually
        # include it using the `patchelf' program (which was a dependency
        # of Bash). Just note that AWK produces two executables (for
        # example `gawk-4.2.1' and `gawk') and a symbolic link `awk' to one
        # of those executables.
	$(call gbuild, $<, gawk-$(gawk-version), static,              \
	               --with-readline=$(idir))                       \
	&& if [ "x$(needpatchelf)" != x ]; then                       \
	     if [ -f $(ibdir)/gawk ]; then                            \
	       $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/gawk;  \
	     fi;                                                      \
	     if [ -f $(ibdir)/gawk-$(gawk-version) ]; then            \
	       $(ibdir)/patchelf --set-rpath $(ildir)                 \
	                         $(ibdir)/gawk-$(gawk-version);       \
	    fi;                                                       \
	   fi                                                         \
	&& echo "GNU AWK $(gawk-version)" > $@

$(ilidir)/gmp: $(tdir)/gmp-$(gmp-version).tar.lz \
               $(ibidir)/bash
	$(call gbuild, $<, gmp-$(gmp-version), static, , , make check)  \
	&& echo "GNU Multiple Precision Arithmetic Library $(gmp-version)" > $@

# On Mac OS, libtool does different things, so to avoid confusion, we'll
# prefix GNU's libtool executables with `glibtool'.
$(ibidir)/glibtool: $(tdir)/libtool-$(libtool-version).tar.xz \
                    $(ibidir)/m4
	$(call gbuild, $<, libtool-$(libtool-version), static, \
                       --program-prefix=g)                     \
	&& echo "GNU Libtool $(libtool-version)" > $@

$(ibidir)/grep: $(tdir)/grep-$(grep-version).tar.xz \
                $(ibidir)/bash
	$(call gbuild, $<, grep-$(grep-version), static) \
	&& echo "GNU Grep $(grep-version)" > $@

$(ibidir)/m4: $(tdir)/m4-$(m4-version).tar.gz \
              $(ibidir)/bash
	$(call gbuild, $<, m4-$(m4-version), static) \
	&& echo "GNU M4 $(m4-version)" > $@

$(ilidir)/mpfr: $(tdir)/mpfr-$(mpfr-version).tar.xz \
                $(ilidir)/gmp
	$(call gbuild, $<, mpfr-$(mpfr-version), static, , , make check)  \
	&& echo "GNU Multiple Precision Floating-Point Reliably $(mpfr-version)" > $@

$(ibidir)/pkg-config: $(tdir)/pkg-config-$(pkgconfig-version).tar.gz \
                      $(ibidir)/bash
        # Some Mac OS systems may have a version of the GNU C Compiler
        # (GCC) installed that doesn't support some necessary features of
        # building Glib (as part of pkg-config). So to be safe, for Mac
        # systems, we'll make sure it will use LLVM's Clang.
	if [ x$(on_mac_os) = xyes ]; then export compiler="CC=clang"; \
	else                              export compiler="";         \
	fi;                                                           \
	$(call gbuild, $<, pkg-config-$(pkgconfig-version), static,   \
	               $$compiler --with-internal-glib                \
	               --with-pc-path=$(ildir)/pkgconfig)             \
	&& echo "pkg-config $(pkgconfig-version)" > $@

$(ibidir)/sed: $(tdir)/sed-$(sed-version).tar.xz \
               $(ibidir)/bash
	$(call gbuild, $<, sed-$(sed-version), static) \
	&& echo "GNU Sed $(sed-version)" > $@

$(ibidir)/which: $(tdir)/which-$(which-version).tar.gz \
                 $(ibidir)/bash
	$(call gbuild, $<, which-$(which-version), static) \
	&& echo "GNU Which $(which-version)" > $@










# GCC and its prerequisites
# -------------------------
#
# Binutils' linker `ld' is apparently only good for GNU/Linux systems and
# other OSs have their own. So for now we aren't actually building
# Binutils (`ld' isn't a prerequisite of GCC).
$(ibidir)/binutils: $(tdir)/binutils-$(binutils-version).tar.lz \
                    $(ibidir)/bash
	$(call gbuild, $<, binutils-$(binutils-version), static) \
	&& echo "GNU Binutils $(binutils-version)" > $@

# `file' is not a prerequisite of GCC. However, since it is low level, it is
# set as a prerequisite of GCC to have it installed.
$(ibidir)/file: $(tdir)/file-$(file-version).tar.gz \
                $(ibidir)/bash
	$(call gbuild, $<, file-$(file-version), static) \
	&& echo "File $(file-version)" > $@

$(ilidir)/isl: $(tdir)/isl-$(isl-version).tar.bz2 \
               $(ilidir)/gmp
	$(call gbuild, $<, isl-$(isl-version), static)  \
	&& echo "GNU Integer Set Library $(isl-version)" > $@

$(ilidir)/mpc: $(tdir)/mpc-$(mpc-version).tar.gz \
               $(ilidir)/mpfr
	$(call gbuild, $<, mpc-$(mpc-version), static, , , make check)  \
	&& echo "GNU Multiple Precision Complex library" > $@

# We are having issues with `libiberty' (part of GCC) on Mac. So for now,
# GCC won't be built there. Since almost no natural science paper's
# processing depends so strongly on the compiler used, for now, this isn't
# a bad assumption, but we are indeed searching for a solution.
#
# Based on the GCC manual, the GCC build can benefit from a GNU
# environment. So, we'll build GCC after building all the basic tools that
# are often used in a configure and build scripts of GCC components.
#
# Objective C and Objective C++ is necessary for installing `matplotlib'.
#
# We are currently having problems installing GCC on macOS, so for the time
# being, if the project is being run on a macOS, we'll just set a link.
ifeq ($(host_cc),1)
gcc-prerequisites =
else
gcc-prerequisites = $(tdir)/gcc-$(gcc-version).tar.xz \
                    $(ilidir)/isl                     \
                    $(ilidir)/mpc
endif
$(ibidir)/gcc: $(gcc-prerequisites)   \
               $(ibidir)/sed          \
               $(ibidir)/bash         \
               $(ibidir)/file         \
               $(ibidir)/gawk         \
               $(ibidir)/grep         \
               $(ibidir)/which        \
               $(ibidir)/glibtool     \
               $(ibidir)/coreutils    \
               $(ibidir)/diffutils    \
               $(ibidir)/findutils

        # GCC builds is own libraries in '$(idir)/lib64'. But all other
        # libraries are in '$(idir)/lib'. Since this project is only for a
        # single architecture, we can trick GCC into building its libraries
        # in '$(idir)/lib' by defining the '$(idir)/lib64' as a symbolic
        # link to '$(idir)/lib'.
	if [ $(host_cc) = 1 ]; then                                        \
	  $(call makelink,gcc);                                            \
	  $(call makelink,g++,mandatory);                                  \
	  $(call makelink,gfortran,mandatory);                             \
	  ccinfo=$$(gcc --version | awk 'NR==1');                          \
	  echo "C compiler (""$$ccinfo"")" > $@;                           \
	else                                                               \
	  rm -f $(ibdir)/gcc* $(ibdir)/g++ $(ibdir)/gfortran $(ibdir)/gcov*;\
	  rm -rf $(ildir)/gcc $(ildir)/libcc* $(ildir)/libgcc*;            \
	  rm -rf $(ildir)/libgfortran* $(ildir)/libstdc* rm $(idir)/x86_64*;\
	                                                                   \
	  ln -fs $(ildir) $(idir)/lib64;                                   \
	                                                                   \
	  cd $(ddir);                                                      \
	  rm -rf gcc-build gcc-$(gcc-version);                             \
	  tar xf $<                                                        \
	  && mkdir $(ddir)/gcc-build                                       \
	  && cd $(ddir)/gcc-build                                          \
	  && ../gcc-$(gcc-version)/configure SHELL=$(ibdir)/bash           \
	                    --prefix=$(idir)                               \
	                    --with-mpc=$(idir)                             \
	                    --with-mpfr=$(idir)                            \
	                    --with-gmp=$(idir)                             \
	                    --with-isl=$(idir)                             \
	                    --with-build-time-tools=$(idir)                \
	                    --enable-shared                                \
	                    --disable-multilib                             \
	                    --disable-multiarch                            \
	                    --enable-threads=posix                         \
	                    --with-local-prefix=$(idir)                    \
	                    --enable-languages=c,c++,fortran,objc,obj-c++  \
	                    --disable-libada                               \
	                    --disable-nls                                  \
	                    --enable-default-pie                           \
	                    --enable-default-ssp                           \
	                    --enable-cet=auto                              \
	                    --enable-decimal-float                         \
	  && make SHELL=$(ibdir)/bash -j$$(nproc)                          \
	  && make SHELL=$(ibdir)/bash install                              \
	  && cd ..                                                         \
	  && rm -rf gcc-build gcc-$(gcc-version)                           \
	                                                                   \
	  && if [ "x$(on_mac_os)" != xyes ]; then                          \
	       for f in $$(find $(idir)/libexec/gcc); do                   \
	         if ldd $$f &> /dev/null; then                             \
	           patchelf --set-rpath $(ildir) $$f;                      \
	         fi;                                                       \
	       done;                                                       \
	     fi                                                            \
	  && echo "GNU Compiler Collection (GCC) $(gcc-version)" > $@;     \
	fi