# Gentoo Ada overlay

**WARNING:** This reporsitory is currently unusable to get the system compiler built with Ada support.

This overlay contains a modified set of packages and toolchain.eclass to enable
Ada based on a USE flag.  The gnat bootstrap compilers are currently hosted on
dropbox and should eventually be moved to distfiles.

## To install

### With Layman

```
$ layman -p 20 -f -a ada -o https://raw.githubusercontent.com/Lucretia/ada-overlay/master/configs/layman.xml
```

### Cloning

Find a place to put the overlay and clone it, note the name of the overlay is
*ada* when using layman, not *ada-overlay*.

```bash
git clone https://github.com/Lucretia/ada-overlay.git
```

Add the following to ```/etc/portage/repos.conf/local.conf```:

```bash
[ada]
priority = 20
location = /usr/local/overlays/ada
masters = gentoo
auto-sync = no
```

## Roadmap and Status

As stated above, this no longer is up to date and working. GNAT GPL is being [discontinued](https://www.reddit.com/r/ada/comments/hwgbwa/survey_on_the_future_of_gnat_community) ([results](https://www.reddit.com/r/ada/comments/j6oz6i/results_of_the_survey_on_the_future_of_gnat/)) and can not be relied upon as the basis for Ada on Gentoo from now on. The plan is as follows:

1. Be able to build a normal system toolchain (sys-devel/gcc) including with Ada support using the ```ada``` use flag.
   * Needs ebuild's for gcc copied over from ::gentoo.
   * Needs the ```toolchain.eclass``` to be modified to build using ```ada-bootstrap``` for the relevant version, but only if the system compiler does *not* have Ada built-in.
2. Add ebuild's for the following:
   * GPR Tools and libraries.
   * XMLAda
   * GNATColl
   * Alire
   * Move over existing ebuild's from ::gentoo where possible.
   * Other various libraries:
     * [dev-ada-overlay](https://github.com/sarnold/dev-ada-overlay)
     * [Awesome Ada](https://github.com/ohenley/awesome-ada)
3. Crossdev support for Ada - automatic once this is done.
4. More eclasses for Ada ebuilds:
   * ```gpr.eclass```
   * ```gnatmake.eclass```
   * ```alire.eclass```
5. Add ```profiles/package``` to block ::gentoo Ada packages, for now.
6. Add a basic/default environment to gcc-config (note gprbuild doesn't use this) - Is this still required?
7. Get toolchain.eclass modifications added to Gentoo base.
8. More??

## Contributions

Luke A. Guest (aka Lucretia)

Steve Arnold (aka nerdboy)
