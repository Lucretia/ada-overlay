# Gentoo Ada overlay

**WARNING:** There still some issues with this overlay.
  * This is in a very alpha state right now, use at your own risk.
  * For some reason ```gprbuild``` cannot find ```libgnarl.so```, when compiled with the -R flag.
  * There are Gentoo security issues due to not having this flag enabled.

## A brief overview

Installing GNAT and it's associated tools is a massive pain in the arse and it always has been. The idea behind this overlay is to make it easier on Gentoo.

The original Ada support in Gentoo is using gnat-gpl and that is now dead.

GNAT GPL is being [discontinued](https://www.reddit.com/r/ada/comments/hwgbwa/survey_on_the_future_of_gnat_community) ([results](https://www.reddit.com/r/ada/comments/j6oz6i/results_of_the_survey_on_the_future_of_gnat/)) and can not be relied upon as the basis for Ada on Gentoo from now on. The plan is as follows:

## Installation

Install the over using eselect, the new way of handling overlays.

```
# emerge -av app-eselect/eselect-repository
# eselect repository add ada git https://github.com/Lucretia/ada-overlay.git
```

### Enable Ada support from this repo

To enable the ada use flag and disable the Gentoo default packages, run the following:

```
# /var/db/repos/ada/scripts/enable-overlay.sh
# eix gnat-gpl
* dev-lang/gnat-gpl
     Available versions:  (10) [m]2021-r4
       {(+)ada +bootstrap cet +cxx d debug default-stack-clash-protection default-znow doc fixed-point +fortran go graphite hardened jit libssp lto modula2 multilib +nls +nptl objc objc++ objc-gc +openmp +pch pgo +pie rust +sanitize +ssp systemtap test vanilla vtv zstd}
     Homepage:            http://libre.adacore.com/
     Description:         GNAT Ada Compiler - GPL version
```

This package should be masked (marked with a "[m]"), if so, the above script has worked.

The ```enable-overlay.sh``` script will enable all the use flags and disable the ```::gentoo``` specific packages. The script will detect whether you have ```package.mask``` and ```package.use``` directories or files and insert the rules accordingly.

### Select a toolchain

You need to select which toolchain you are going to use. The overlay installs packages only for the enabled toolchain. The ```sys-devel/gcc``` ebuilds (via the ```toolchain.eclass```) will actually set the correct compiler to build with, whether that it the ```dev-lang/ada-bootstrap``` or an already compiled gcc with Ada enabled.
```
# eselect gcc list
 [1] x86_64-pc-linux-gnu-9.5.0
 [2] x86_64-pc-linux-gnu-10
 [3] x86_64-pc-linux-gnu-11 *
 [4] x86_64-pc-linux-gnu-12
```

You then need to install the Ada tools you will need to get going.

```
# emerge -av =dev-ada/ada-meta-11

These are the packages that would be merged, in order:

Calculating dependencies... done!
Dependency resolution took 41.09 s.

[ebuild  N     ] dev-ada/gprconfig_kb-23.2::ada  0 KiB
[ebuild  N     ] dev-ada/gprbuild-bootstrap-23.2::ada  0 KiB
[ebuild  N     ] dev-ada/xmlada-23.2::ada  0 KiB
[ebuild  N     ] dev-ada/gprbuild-23.2::ada  0 KiB
[ebuild   R    ] dev-ada/ada-meta-11:0::ada [11:9::ada] 0 KiB

Total: 5 packages (4 new, 1 reinstall), Size of downloads: 0 KiB

Would you like to merge these packages? [Yes/No]
```

Remove ```dev-ada/gprbuild-bootstrap``` once this has completed as you'll have no need for it afterwards.

## Updating GCC

When a new version of gcc is available, you can upgrade it and the new version will build using the old version as a boostrap so you will continue to have Ada available. Just remember to select the new gcc with ```eselect gcc set``` then remove and re-emerge the above packages.

```bash
# select gcc list
 [1] x86_64-pc-linux-gnu-11 *
 [2] x86_64-pc-linux-gnu-12
# eselect gcc set 2 && . /etc/profile && gcc -v
...
gcc version 12.3.1 20230526 (Gentoo 12.3.1_p20230526 p2)
# emerge -av sys-devel/gcc:12
[ebuild   R    ] sys-devel/gcc-12.3.1_p20230526:12::ada  USE="ada (cxx) d fortran graphite jit (multilib) nls nptl openmp (pie) sanitize ssp (-cet) (-custom-cflags) -debug -default-stack-clash-protection -default-znow -doc (-fixed-point) -go -hardened (-ieee-long-double) (-libssp) -lto -objc -objc++ -objc-gc (-pch) -pgo -systemtap -test -valgrind -vanilla -vtv -zstd" 0 KiB
```

```
# emerge -av =dev-ada/ada-meta-12

These are the packages that would be merged, in order:

Calculating dependencies... done!
Dependency resolution took 41.14 s.

[ebuild  N     ] dev-ada/gprconfig_kb-23.2::ada  0 KiB
[ebuild  N     ] dev-ada/gprbuild-bootstrap-23.2::ada  0 KiB
[ebuild  N     ] dev-ada/xmlada-23.2::ada  0 KiB
[ebuild  N     ] dev-ada/gprbuild-23.2::ada  0 KiB
[ebuild  NS    ] dev-ada/ada-meta-12:0::ada [11:9::ada] 0 KiB

Total: 5 packages (4 new, 1 in new slot), Size of downloads: 0 KiB

Would you like to merge these packages? [Yes/No]
```

### GCC 13-14

I have built ada-bootstrap's based on these versions, I just haven't tested them yet.

## What is provided?

### GCC-9+ is supported

I tried to build 6.5.0, 7.6.0 and 8.5.0, but they all fail to build, quite quickly. It just seems that 9 is now the lowest version we can compile GNAT for. 6 and 7 are masked in gentoo now anyway.

### AdaCore Components

* [X] XMLAda
* [X] GPRBuild
* [ ] GNATProve
* [ ] Alire

* The following have been nicked from ::gentoo and butchered to work:

* [X] GNATColl-Core
* [X] GNATColl-Bindings
* [X] GNATColl-DB

## Crossdev

Support for Ada is automatically built when you build crossdev.

## TODO

* [ ] Have sources (ad[sb] files) stored into /usr/include/ada/<package>
* [ ] Have libs (and ali files) stored into /usr/lib64/ada/<package>

## Roadmap and Status

1. Add eclasses for Ada ebuilds:
   * ```gnatmake.eclass```
   * ```gprbuild.eclass```
   * ```alire.eclass```
     * Not sure about this one now. During the emerge process, it's not allowed to call emerge again and I was considering adding emerge support to Alire, this would make Alire a user command only; I'm not even sure it can be used as a system command.
2. Get toolchain.eclass modifications added to Gentoo base.
3. More??

## Contributions

Luke A. Guest (aka Lucretia)

Steve Arnold (aka nerdboy)
