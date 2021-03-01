# CompTIA Linux+ Notes
## Installation Notes
### Installation Process
* RHEL, CentOS, and Fedora all use the Anaconda installer. Therefore, the installation process is very similar between them. [Here](https://www.tecmint.com/installation-of-rhel-8/) is a description of it. The Anaconda installer will create an anaconda-ks.cfg file in the **/root** directory. You can use modify and use this for unattended installations in the future!
* Ubuntu server uses a different installer, but you'll be making many of the same configurations. You can read more about it [here](https://ubuntu.com/server/docs/install/step-by-step). 
* OpenSUSE uses a installation tool called YaST ("Yet Another Setup Tool"). Again, it looks different, but performs many of the same functions. Documentation [here](https://doc.opensuse.org/documentation/leap/startup/html/book-opensuse-startup/art-opensuse-installquick.html).

### Partitioning and Filesystem
* Partitions divide disks into one or more segments
* Partitioning information can be tracked with MBR or GPT
    * **MBR** - Master Boot Record. Limited to 2TB disks and 4 primary partitions. *Legacy*.
    * **GPT** - GUID Partition Table. Supports huge disks and up to 128 partitions. *Preferred*.
* Each partition can be formatted with a unique filesystem
* Common Linux filesystems are:
    * XFS
    * ext3
    * ext4
* Different distributions may favor certain filesystems by default. For instance, Red Hat operating systems often favor XFS.
* In Windows, each partition is usually given a unique drive letter (e.g., C:, E:, Z:...)
* In Linux, there is a single **root** filesystem which may contain many mounted partitions. For instance, examine the output of the `lsblk` below. This command lists block storage devices and their mount points.

```
shane@ubuntu:~$ lsblk
sda                         8:0    0   16G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   15G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0   15G  0 lvm  /
```

Notice that the **root** filesytem (**/**) is on the sda3 partition. However, the sda2 partition is mounted to the **/boot** directory within the root filesystem.

Listing the contents of **/**, **/boot** is treated as a typical directory, even though it's a different filesystem  (and might not even be on the same disk!).

```
shane@ubuntu:~$ ls /
bin    dev   lib    libx32      mnt   root  snap      sys  var
boot   etc   lib32  lost+found  opt   run   srv       tmp
cdrom  home  lib64  media       proc  sbin  swap.img  usr
```

## LVM (Logical Volume Management)
In the installations we demonstrate during class, we installed Linux using LVM. This is usually a good idea because it abstracts away the physical partitioning and gives us flexibility as system administrators.

In a nutshell, LVM consists of a set of physical volumes (PVs) grouped together into a volume group (VG). In a VG, we can create logical volumes (LVs) to meet our needs. 

Consider the 3-disk setup below. We use each disk as a physical volume, group them into a single volume group, and then do something interesting when defining the logical volumes-- the first logical volume spans two disks!

```
 ________    ________    ________ 
|        |  |        |  |        |
| Disk 1 |  | Disk 2 |  | Disk 3 | 
|________|  |________|  |________|

|   PV   |  |   PV   |  |   PV   |

|           Volume Group         |

|    Logical Volume  |  |   LV   |

```

## Package Management

One of the most important differences between different distributions of Linux is the package managers they use. There are two "main" flavors of Linux: **RHEL** flavors and **Debian** flavors.

RHEL distributions use **.rpm** packages. Examples include:
* CentOS 
* Fedora
* RHEL 
* OpenSUSE

Debian distributions use **.deb** packages. Examples include:
* Ubuntu
* Linux Mint
* Debian
* Raspbian

Both flavors give us the ability to manage individual packages, but it is usually easier to use dependency-aware tools such as yum/dnf, zypper, or apt.

| Flavor | Manage Individual Packages | Manage Packages & Dependencies |
| ---- | ------- | ---------------------
| Red Hat (excluding OpenSUSE) | rpm | yum or dnf|
| OpenSUSE | rpm | zypper |
| Debian | dpkg | apt |

### Red Hat Package Management
*Note:* on RHEL, you should first configure your subscription using `sudo subscription-manager register --username YOUR_USERNAME --password YOUR_PASSWORD --auto-attach`

| Action | Command | Explanation |
| ------ | ------- | ----------- |
| **Install .rpm package** | `rpm -ivh cowsay.rpm` | `-i` - **i**nstall |
|||`-v` - **v**erbose|
|||`-h` - progress with **h**ashmarks|
| **Display .rpm package's dependencies** | `rpm -qpR cowsay.rpm` | `-q` - **q**uery package(s)|
||| `-p` - specify **p**ackage file |
||| `-R` - get package **r**equirements |
| **Check if package is installed**  | `rpm -q cowsay` | `-q` - **q**uery installed packages|
| **List installed packages** | `rpm -qa \| less` | `-q` - **q**uery packages |
||| `-a` - **a**ll packages |
||| `\| less` - pipe into `less` so we can read it |
| **Get info about installed package** | `rpm -qi cowsay` | `-q` - **q**uery package |
||| `-i`  - **i**nfo |
| **Install package with dependencies** | `yum install cowsay` | `dnf` uses same syntax |
| **Run updates** | `yum update`||
| **Remove package** | `yum remove cowsay` ||
| **Get info about a package** | `yum info cowsay` ||
| **Search for a package** | `yum search cowsay` ||
| **List package groups** | `yum grouplist` ||
| **Install a package group** | `yum groupinstall 'Virtualization Host'` ||
| **View enabled repositories** | `yum repolist` ||

A longer-form discussion of `yum` is available [here](https://www.cyberciti.biz/faq/rhel-centos-fedora-linux-yum-command-howto/)

### Debian Package Management
| Action | Command | Explanation |
| ------ | ------- | ----------- |
| **Install .deb package**| `dpkg -i cowsay.deb`| `-i` - **i**nstall |
| **Check if package is installed** | `dpkg -s cowsay`| `-s` - **s**tatus|
| **List installed packages** | `dpkg -l` | `-l` - **l**ist |
| **Install package with dependencies** | `apt install cowsay`||
| **Run updates** | `apt update && apt upgrade`| First update our view of repos, then run upgrades |
| **Remove package** | `apt remove cowsay`||
| **Get info about a package** | `apt-cache show cowsay` ||
| **Search for a package** |  `apt-cache search cowsay`||

A longer-form discussion of `apt` is available [here](https://itsfoss.com/apt-command-guide/).

### Git
Set up a git repository
```
shane@linux:~$ mkdir my_git_repo
shane@linux:~$ cd my_git_repo
shane@linux:~/my_git_repo$ git config --global user.name "Shane Sexton"
shane@linux:~/my_git_repo$ git config --global user.email "ferretologist88@gmail.com"
shane@linux:~/my_git_repo$ git init
Initialized empty Git repository in /home/shane/my_git_repo/.git/
shane@linux:~/my_git_repo$ git remote add origin https://github.com/ferretology/my_git_repo.git
shane@linux:~/my_git_repo$ echo ".tmp" >> .gitignore
shane@linux:~/my_git_repo$ git add -A
shane@linux:~/my_git_repo$ git commit -m "first commit"
[master (root-commit) 85251f5] first commit
 1 file changed, 1 insertion(+)
 create mode 100644 .gitignore
shane@linux:~/my_git_repo$ git push -u origin master
```

Clone a git repository
```
shane@linux:~$ git clone https://github.com/StormWindStudios/OpenSSL-Notes
Cloning into 'OpenSSL-Notes'...
remote: Enumerating objects: 46, done.
remote: Counting objects: 100% (46/46), done.
remote: Compressing objects: 100% (46/46), done.
remote: Total 46 (delta 17), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (46/46), 12.70 KiB | 4.23 MiB/s, done.
Resolving deltas: 100% (17/17), done.
shane@linux:~$ cd OpenSSL-Notes 
shane@linux:~/OpenSSL-Notes$  OpenSSL-Notes % ls
compilation.md		letsencrypt.md		rsa.md
ecdsa.md		letsencrypt_autopfx.md
```
Additonal coverage of `git` can be found [here](https://areknawo.com/git-basics-the-only-introduction-you-will-ever-need/).