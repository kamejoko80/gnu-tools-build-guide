# 
#   Copyright (C) 2013, 2014, 2015 Linaro, Inc
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 

dnl  
dnl This script configures the build machine to have what it needs to
dnl build and test a GNU toolchain.
dnl 

AC_PREREQ(2.59c)
AC_INIT(abe, 2.0dev)
AC_CONFIG_SRCDIR([abe.sh])
dnl AC_CONFIG_HEADERS([config.h])
dnl AC_CONFIG_MACRO_DIR([macros])

dnl --------------------------------------------------------
dnl Figure out development tool stuff
dnl --------------------------------------------------------
missing=
optional=
AC_PROG_CC
AC_PROG_CXX
if test x"${CC}" = x -a x"${CXX}" = x; then
   AC_MSG_ERROR([You need 'gcc' and 'g++' to fully run abe!])
   missing="${missing} gcc"
fi
AC_PROG_INSTALL
dnl AC_CANONICAL_BUILD
dnl AC_CANONICAL_HOST

dnl Get and store often used information on this build machine
CPUS="`nproc --all`"
AC_SUBST(CPUS)
LIBC="`getconf GNU_LIBC_VERSION`"
AC_SUBST(LIBC)
KERNEL="`uname -r`"
AC_SUBST(KERNEL)
BUILDHOST="`${srcdir}/config.guess`"
BUILD_ARCH="`uname -m`"
if test x"`uname -s`" = "xDarwin"; then
   BUILD_ARCH="`uname -p`"
fi
AC_SUBST(BUILD_ARCH)
AC_SUBST(BUILDHOST)
HOSTNAME="`uname -n`"
AC_SUBST(HOSTNAME)
DISTRIBUTION="`lsb_release -sc`"
AC_SUBST(DISTRIBUTION)

AC_PATH_PROG(WGET, wget)
AC_SUBST(WGET)
if test x"${WGET}" = x; then
   AC_MSG_WARN([You need 'wget' to fully run abe!])
   missing="${missing} wget"
fi

dnl AC_PATH_PROG(GITBZR, git-bzr)
AC_PATH_PROG(BASH, bash)
AC_SUBST(BASH)
if test x"${BASH}" = x; then
   AC_MSG_WARN([You need Bash to run configure properly!])
   missing="${missing} bash"
fi

AC_PATH_PROG(FLEX, flex)
if test x"${FLEX}" = x; then
   AC_MSG_WARN([You need 'flex' to run configure  GCC properly!])
   missing="${missing} flex"
fi

AC_PATH_PROG(BISON, bison)
if test x"${BISON}" = x; then
   AC_MSG_WARN([You need 'bison' to run configure  GCC properly!])
   missing="${missing} bison"
fi

AC_PATH_PROG(AUTOGEN, autogen)
if test x"${AUTOGEN}" = x; then
   AC_MSG_WARN([You need 'autogen' to run configure for GCC properly!])
   missing="${missing} autogen"
fi

AC_PATH_PROG(FAKEROOT, fakeroot)
if test x"${FAKEROOT}" = x; then
   AC_MSG_WARN([You need 'fakeroot' to build binary Deb packages !])
#   missing="${missing} fakeroot"
fi

AC_PATH_PROG(ALIEN, alien)
if test x"${ALIEN}" = x; then
   AC_MSG_WARN([You need 'alien' to build binary Deb packages !])
#   missing="${missing} alien"
fi

dnl Building GDB requires ncurses and termcap
#AC_CHECK_LIB(ncurses, doupdate)
#if test x${ac_cv_lib_ncurses_doupdate} != x"yes"; then
#   AC_MSG_WARN([You need 'libncurses' to run configure for GDB properly!])
#   missing="${missing} libncurses5-dev"
#fi
AC_CHECK_LIB(z, gzread)

# Figure out which packaging system is in use. Since it's possible to
# install both on a system.
deb="`grep -ic 'ubuntu\|debian' /etc/issue`"

dnl Look for packages that do not have executables, so we are forced
dnl to ask the packaging system if they are installed. This is more
dnl reliable and portble than using pkg-config.
#packages="git-svn bzr-fastimport svn-all-fast-exp libncurses5-dev texinfo"
packages="texinfo gawk"

### Debian packages ###
if test ${deb} -ge 1; then
    # add Ubuntu specific packages
    packages="${packages} libncurses5-dev python3-dev zlib1g-dev"
    for i in ${packages}; do
    AC_MSG_CHECKING([if $i is installed])
    #exists=`dpkg --get-selections | grep -c "^$i\[[:space:]\]*install"`
    exists="`dpkg -l $i | tail -1| cut -d ' ' -f 1`"
    if test x"${exists}" != x'ii'; then
        AC_MSG_RESULT([no, install $i])
        missing="${missing} $i"
    else
        AC_MSG_RESULT([yes])
    fi
    done

### RPM Packages ###
else
if which rpm > /dev/null; then
    packages="${packages} ncurses-devel python3-devel zlib-devel"
    for i in ${packages}; do
        AC_MSG_CHECKING([if $i is installed])
	# RPM based systems might install via meta-packages but the rpm database
	# can't be searched on meta-package name, so strip off any trailing
	# information when searching the rpm database.
        exists="`rpm -q -a ${i//.*/}| grep -c -E \"${i//.*/}\"`"
        if test ${exists:-0} -eq 0; then
           AC_MSG_RESULT([no, install $i])
           missing="${missing} $i"
        else
            AC_MSG_RESULT([yes])
        fi
    done

### Arch Packages ###
else
if which pacman > /dev/null; then
    packages="${packages} zlib"
    for i in ${packages}; do
        AC_MSG_CHECKING([if $i is installed])
        exists="`pacman -Qs ${i} | wc -l`"
        if test ${exists} -eq 0; then
           AC_MSG_RESULT([no, install $i])
           missing="${missing} $i"
        else
            AC_MSG_RESULT([yes])
        fi
    done

### Unknown Packages ###
else
   AC_MSG_WARN([Unknown package management system])
fi # Arch
fi # RPM
fi # Debian

dnl FIXME: Look for git-svn and git-bzr, bzr-fastimport svn-all-fast-export

dnl Get build date for helping us debugging
BUILDDATE="`date +%Y%m%d`"
AC_SUBST(BUILDDATE)

dnl The top of the abe tree
AC_ARG_WITH(toplevel,
  AC_HELP_STRING([--with-toplevel], []),
  ABE_TOP=${withval},
  ABE_TOP="${PWD}")
AC_SUBST(ABE_TOP)

if test ! -d ${ABE_TOP}; then
   AC_MSG_WARN([${ABE_TOP} does not exist so creating directory!])
   mkdir -p ${ABE_TOP}
fi

AC_ARG_WITH(sources-conf,
  AC_HELP_STRING([--with-sources-conf], []),
  SOURCES_CONF=${withval},
  SOURCES_CONF="${srcdir}/config/sources.conf"
  dir="`dirname ${SOURCES_CONF}`"
  base="`cd ${dir} && pwd`"
  conf="`basename  ${SOURCES_CONF}`"
  SOURCES_CONF="${base}/${conf}")
AC_SUBST(SOURCES_CONF)

ABE_PATH=$(readlink -f ${srcdir})
AC_SUBST(ABE_PATH)

dnl The local directory where snapshots are stored
AC_ARG_WITH(local-snapshots,
  AC_HELP_STRING([--with-local-snapshots], [Where downloaded tarballs are stored]),
  LOCAL_SNAPSHOTS=${withval},
  LOCAL_SNAPSHOTS="${ABE_TOP}/snapshots")
AC_SUBST(LOCAL_SNAPSHOTS)

if test ! -d ${LOCAL_SNAPSHOTS}; then
   AC_MSG_WARN(${LOCAL_SNAPSHOTS} does not exist so creating directory!)
   mkdir -p ${LOCAL_SNAPSHOTS}
fi

dnl The local directory where reference git repos are stored
AC_ARG_WITH(git-reference-dir,
  AC_HELP_STRING([--with-git-reference-dir], [Where reference git repos are stored, see git-clone --reference]),
  GIT_REFERENCE_DIR=${withval},
  GIT_REFERENCE_DIR="")
AC_SUBST(GIT_REFERENCE_DIR)

dnl The top directory for make install, also where all the components we build live
AC_ARG_WITH(local-builds,
  AC_HELP_STRING([--with-local-builds], []),
  LOCAL_BUILDS=${withval},
  LOCAL_BUILDS="${ABE_TOP}/builds",
  LOCAL_BUILDS="${ABE_TOP}/builds")
AC_SUBST(LOCAL_BUILDS)

if test ! -d ${LOCAL_BUILDS}; then
   AC_MSG_WARN(${LOCAL_BUILDS} does not exist so creating directory!)
   mkdir -p ${LOCAL_BUILDS}
fi

dnl A URL to the remote directory where snapshots are stored
AC_ARG_WITH(remote-snapshots,
  AC_HELP_STRING([--with-remote-snapshots], []),
  REMOTE_SNAPSHOTS="${withval}")
AC_SUBST(REMOTE_SNAPSHOTS)

dnl Display the default paths so the user does not need to look in the host.conf file.
echo ""
AC_MSG_NOTICE([Downloaded snapshots will be stored in: ${LOCAL_SNAPSHOTS}])
AC_MSG_NOTICE([My builds will be installed in: ${LOCAL_BUILDS}])
AC_MSG_NOTICE([Remote snapshots will be fetched from: ${REMOTE_SNAPSHOTS}])
echo ""

AC_ARG_WITH(languages,
  AC_HELP_STRING([--with-languages], [List of languages for the compiler]),
  WITH_LANGUAGES=${withval},
  WITH_LANGUAGES='default')
AC_SUBST(WITH_LANGUAGES)

dnl if you have SSH access to the remote machine
AC_ARG_ENABLE(ssh, AC_HELP_STRING([--enable-ssh], [If you have SSH access to remote build host]),
[case "${enableval}" in
  yes) ENABLE_SSH=yes ;;
  no)  ENABLE_SSH=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-ssh option]) ;;
esac], ENABLE_SSH=no)
AC_SUBST(ENABLE_SSH)

dnl if you want to run all tests by default
AC_ARG_ENABLE(alltests, AC_HELP_STRING([--enable-alltests], [If you want to run all tests by default]),
[case "${enableval}" in
  yes) ENABLE_ALLTESTS=yes ;;
  no)  ENABLE_ALLTESTS=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-alltests option]) ;;
esac], ENABLE_ALLTESTS=no)
AC_SUBST(ENABLE_ALLTESTS)

dnl if you want to install by default
AC_ARG_ENABLE(install, AC_HELP_STRING([--enable-install], [If you want to install by default]),
[case "${enableval}" in
  yes) ENABLE_INSTALL=yes ;;
  no)  ENABLE_INSTALL=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-install option]) ;;
esac], ENABLE_INSTALL=yes)
AC_SUBST(ENABLE_INSTALL)

dnl if you want to disable the building of the package documents.
AC_ARG_ENABLE(make-docs, AC_HELP_STRING([--enable-make-docs], [If you want to enable making package documentation]),
[case "${enableval}" in
  yes) ENABLE_MAKE_DOCS=yes ;;
  no)  ENABLE_MAKE_DOCS=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-make-docs option]) ;;
esac], ENABLE_MAKE_DOCS=yes)
AC_SUBST(ENABLE_MAKE_DOCS)

dnl Obsolete option, preserved for compatibility
AC_ARG_ENABLE(schroot-test, AC_HELP_STRING([--enable-schroot-test], [Obsolete option, preserved for compatibility]),
[case "${enableval}" in
  yes) ENABLE_SCHROOT_TEST=yes ;;
  no)  ENABLE_SCHROOT_TEST=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-schroot-test option]) ;;
esac], ENABLE_SCHROOT_TEST=no)
AC_SUBST(ENABLE_SCHROOT_TEST)

dnl if you want to update sources by default
AC_ARG_ENABLE(source-update, AC_HELP_STRING([--enable-source-update], [If you want to update sources by default]),
[case "${enableval}" in
  yes) ENABLE_SOURCE_UPDATE=yes ;;
  no)  ENABLE_SOURCE_UPDATE=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-source-update option]) ;;
esac], ENABLE_SOURCE_UPDATE=yes)
AC_SUBST(ENABLE_SOURCE_UPDATE)

dnl if you want to update sources by default
AC_ARG_ENABLE(parallel, AC_HELP_STRING([--enable-parallel], [If you want to build with make -j<number of CPUs> by default]),
[case "${enableval}" in
  yes) ENABLE_PARALLEL=yes ;;
  no)  ENABLE_PARALLEL=no ;;
  *)   AC_MSG_WARN([bad value ${enableval} for enable-parallel option]) ;;
esac], ENABLE_PARALLEL=yes)
AC_SUBST(ENABLE_PARALLEL)

dnl AC_ARG_WITH(snapshots,
dnl   AC_HELP_STRING([--with-snapshots], []),
dnl   snapshots=${withval},
dnl   snapshots='abe')

dnl Since the configure script is actually checked in, a developer
dnl does not need to have the GNU Autotools installed. However,
dnl installing these is a good idea anyway.
dnl AC_MSG_NOTICE([These are needed by everything to rebuild configure scripts and Makefiles])
AC_CHECK_PROGS(AUTOCONF,autoconf)
AC_CHECK_PROGS(AUTOMAKE,automake)
AC_CHECK_PROGS(LIBTOOL,libtool)
if test x"${AUTOCONF}" = x -o x"${AUTOMAKE}" = x -o x"${LIBTOOL}" = x; then
   AC_MSG_WARN([You should install autoconf, automake, and libtool])
fi

dnl DejaGnu is used for testing
AC_PATH_PROG(DEJAGNU,runtest)
if test x"${DEJAGNU}" = x; then
   AC_MSG_WARN([You should install dejagnu so you can run tests])
   missing="${missing} dejagnu"
fi

AC_PATH_PROG(MAKEINFO,makeinfo)
# Texinfo 5.0 can't process the gcc texinfo files until they are fixed, 
# so we have to disable it for Ubuntu 14.04 "trusty".
#if test "`uname -v | grep -c  Ubuntu`" -gt 0; then
#   texversion="`dpkg-query -W -f='\${Version}' texinfo | cut -d '.' -f 1`"
#   if test "${texversion}" -gt 4; then
dnl      MAKEINFO="echo"
#         AC_MSG_WARN([On Ubuntu Trusty systems, you may need to upgrade to have a working version of makeinfo])
#   fi
#fi
AC_SUBST(MAKEINFO)

AC_PATH_PROG(NEWWORKDIR,git-new-workdir)
   if test x"${NEWWORKDIR}" = x; then
      AC_MSG_WARN([You need to install git-new-workdir to use GIT!])
      AC_MSG_NOTICE([copy /usr/share/doc/git/contrib/workdir/git-new-workdir to /usr/local/bin and then make it executable])
      missing="${missing} git-new-workdir"
fi
AC_SUBST(NEWWORKDIR)

# A symbolic link needs to be made in this directory
#if test -w /opt/linaro -eq 0; then
#   AC_MSG_WARN([/opt/linaro is not writable!])
#fi

AC_OUTPUT(host.conf)

if test x"${missing}" != x; then
    AC_MSG_ERROR([You need to install these packages: ${missing}])
fi

rm -f Makefile
cat<<EOF > Makefile
check:
	${srcdir}/testsuite/test.sh
	${srcdir}/test.sh

clean:
	rm -fr builds/*

EOF

# Local Variables:
# c-basic-offset: 2
# tab-width: 2
# indent-tabs-mode: nil
# End:

