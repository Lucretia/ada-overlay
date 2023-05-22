# Gentoo Ada overlay

**WARNING:** This repository can be used to get the system compiler built with Ada support. You will need to use the ```gprbuild``` within the ```ada-bootstrap``` directory, place this last in the PATH.

This overlay contains a modified set of packages and toolchain.eclass to enable
Ada based on a USE flag.  The gnat bootstrap compilers are currently hosted on
dropbox and should eventually be moved to distfiles.

## To install

### With Layman

```
# layman -f -a ada -o https://raw.githubusercontent.com/Lucretia/ada-overlay/master/repositories.xml
```

### Enable Ada support from this repo

To enable the ada use flag and disable the Gentoo default packages, run the following:

```
# /var/lib/layman/ada/scripts/enable-overlay.sh
# eix gnat-gpl
* dev-lang/gnat-gpl
     Available versions:  (10) [m]2021-r4   ## This should be masked "[m]" and if so, the above script has worked.
       {(+)ada +bootstrap cet +cxx d debug default-stack-clash-protection default-znow doc fixed-point +fortran go graphite hardened jit libssp lto modula2 multilib +nls +nptl objc objc++ objc-gc +openmp +pch pgo +pie rust +sanitize +ssp systemtap test vanilla vtv zstd}
     Homepage:            http://libre.adacore.com/
     Description:         GNAT Ada Compiler - GPL version
# emerge -av sys-devel/gcc
```

The ```enable-overlay.sh``` script will enable all the use flags and disable the ```::gentoo``` specific packages. Once you have built GCC with Ada enabled, you need to disable the ```-ada-bootstrap``` USE flag and then rebuild it.

The script will detect whether you have ```package.mask``` and ```package.use``` directories or files and insert the rules accordingly.

## Updating GCC

For now, when updating gcc, if you have multiple versions installed, ```eselect gcc set``` the version which matches the one you have installed with this overlay, until I can get this eclass working right, this will be necessary. e.g.

```bash
# select gcc list
 [1] x86_64-pc-linux-gnu-11
 [2] x86_64-pc-linux-gnu-12 *
# eselect gcc set 1 && . /etc/profile && gcc -v
...
gcc version 11.3.1 20230120 (Gentoo 11.3.1_p20230120-r1 p7)
# emerge -av sys-devel/gcc:11
[ebuild     U  ] sys-devel/gcc-11.3.1_p20230427:11::ada [11.3.1_p20230120-r1:11::ada] USE="ada (cxx) d fortran graphite jit (multilib) nls nptl openmp (pie) sanitize ssp -ada-bootstrap* (-cet) (-custom-cflags) -debug -doc (-fixed-point) -go -hardened (-libssp) -lto -objc -objc++ -objc-gc (-pch) -pgo -systemtap -test -valgrind -vanilla -vtv -zstd" 0 KiB
```

## Assumptions

You can only select one system toolchain (gcc) at a time. Therefore, it is assumed that if you install an ebuild, it is for that selected toolchain. This can't be right as gcc is slotted and gnat packages are installed within gcc's dir!!

Could do something like python does, ```PYTHON_TARGETS```, but in this case, ```GNAT_TARGETS``` and ```gnat_targets_gnat9|10|11|12```. This is going to require a gnat.eclass file.

## Ada Bootstrap

The script to build the bootstrap is incredibly fragile and can break every time the gcc archive versions change inside Gentoo. It might be worth not basing the bootstrap, on Gentoo's sources and just grab the version from git.

## What is provided?

### GCC-9+ is supported

I tried to build 6.5.0, 7.6.0 and 8.5.0, but they all fail to build, quite quickly. It just seems that 9 is now the lowest version we can compile GNAT for. 6 and 7 are masked in gentoo now anyway.

### AdaCore Components

* [] XMLAda
* [] GNATColl-Core
* [] GNATColl-Bindings
* [] GNATColl-DB
* [] GPRBuild

### Other Components

* [] Alire

## Roadmap and Status

As stated above, this no longer is up to date and working. GNAT GPL is being [discontinued](https://www.reddit.com/r/ada/comments/hwgbwa/survey_on_the_future_of_gnat_community) ([results](https://www.reddit.com/r/ada/comments/j6oz6i/results_of_the_survey_on_the_future_of_gnat/)) and can not be relied upon as the basis for Ada on Gentoo from now on. The plan is as follows:

1. Incorporate ```ada-bootstrap``` (would be a local use flag) and ```system-bootstrap``` (currently useed by rust, go and openjdk) use flags into the build.
   * These should be applied to the first two packages (XMLAda, GPRBuild), as they will need to access ```gprbuild``` in the ```ada-bootstrap``` package.
   * Can use these with BDEPEND to bring in the correct ```ada-bootstrap``` archive.
   * Will need to be switched to ```system-bootstrap``` once the system compiler is built with Ada.
2. Add ebuild's for the following:
   * XMLAda
   * GPR Tools and libraries.
   * GNATColl
   * Alire
   * GNATProve
   * Move over existing ebuild's from ::gentoo where possible.
   * Other various libraries:
     * [dev-ada-overlay](https://github.com/sarnold/dev-ada-overlay)
     * [Awesome Ada](https://github.com/ohenley/awesome-ada)
3. Crossdev support for Ada - automatic once this is done.
4. More eclasses for Ada ebuilds:
   * ```gnatmake.eclass```
   * ```gprbuild.eclass```
   * ```alire.eclass```
     * Not sure about this one now. During the emerge process, it's not allowed to call emerge again and I was considering adding emerge support to Alire, this would make Alire a user command only; I'm not even sure it can be used as a system command.
5. Add a basic/default environment to gcc-config (note gprbuild doesn't use this) - Is this still required?
6. Get toolchain.eclass modifications added to Gentoo base.
7. More??

## Contributions

Luke A. Guest (aka Lucretia)

Steve Arnold (aka nerdboy)
