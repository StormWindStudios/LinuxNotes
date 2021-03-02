# CompTIA Linux+ Notes
## Installation Notes
### Installation Process
* RHEL, CentOS, and Fedora all use the Anaconda installer. Therefore, the installation process is very similar between them. [Here](https://www.tecmint.com/installation-of-rhel-8/) is a description of it. The Anaconda installer will create an anaconda-ks.cfg file in the **/root** directory. You can modify and use this for unattended installations!
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

### LVM (Logical Volume Management)
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

## Booting
A series of actions are performed to get a system up and running. It is important to distinguish the boot process used by legacy BIOS systems from the one that occurs on UEFI systems.
### BIOS Boot Process
1. The BIOS performs the power-on self test (POST), making sure that all the components are functioning properly.
2. If POST succeeds, the BIOS locates the MBR and loads a tiny "first-stage" bootloader from it. This is *very* limited in size; in practice, it points to a more capable bootloader on another partition.
3. On Linux systems, the first-stage bootloader usually loads GRUB (the GRand Unified Bootloader) from the **/boot** partition.
4. GRUB then loads the Linux kernel.
5. The first process spawned is usually *systemd*, which manages the remainder of the startup process.

The output of `lsblk` below show the **/boot** partition. This contains GRUB, and is what the first-stage bootloader in the MBR "points to."
```
shane@ubuntu:~$ lsblk
sda                         8:0    0   16G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   15G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0   15G  0 lvm  /
```

The **/boot** directory on a BIOS system, containing the kernels (vmlinuz), and GRUB files.
```
shane@ubuntu:~$ ls /boot
config-5.4.0-66-generic      lost+found
grub                         System.map-5.4.0-66-generic
initrd.img                   vmlinuz
initrd.img-5.4.0-66-generic  vmlinuz-5.4.0-66-generic
initrd.img.old               vmlinuz.old
```
### UEFI Boot Process
1. The UEFI performs the power-on self test (POST), making sure that all the components are functioning properly.
2. If POST succeeds, the UEFI finds the EFI system partition (ESP) and loads a *.efi* bootloader. GRUB is optional for UEFI systems, but it's still commonly used.
3. The bootloader then loads the Linux kernel.
4. As usual, *systemd* takes over from there.

The output of `lsblk` is a bit different on EFI systems. In addition to the **/boot** partition, there's a dedicated **/boot/efi** partition, which the UEFI can find directly. 
```
shane@ubuntu-efi:~$ lsblk
sda                         8:0    0   10G  0 disk 
├─sda1                      8:1    0  512M  0 part /boot/efi
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0  8.5G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0  8.5G  0 lvm  /
```

The EFI files on an Ubuntu system. Again, the UEFI can load *grubx64.efi* directly.
```
shane@ubuntu-efi:~$ ls /boot/efi/EFI/ubuntu/
BOOTX64.CSV  grub.cfg  grubx64.efi  mmx64.efi  shimx64.efi
```

The EFI bootloader (such as grubx64.efi) will then load the kernel from **/boot**:

```
shane@ubuntu-efi:~$ ls /boot/
config-5.4.0-66-generic  initrd.img-5.4.0-66-generic  vmlinuz
efi                      initrd.img.old               vmlinuz-5.4.0-66-generic
grub                     lost+found                   vmlinuz.old
initrd.img               System.map-5.4.0-66-generic
```
You can read more about the boot process [here](https://linuxhint.com/understanding_boot_process_bios_uefi/).

### Configuration
Several common GRUB configurations are made in `/etc/default/grub`. 

Using the `head` command, we can print out the first 8 lines (and the most frequently changed configurations).
```
head -n 8 /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
```
* GRUB_DEFAULT specifies the default kernel that will be loaded without user intervention
* GRUB_TIMEOUT_STYLE changes how (and if) the GRUB menu is displayed during boot. 
    * hidden - the menu won't be displayed unless ESC is pressed
    * menu - the menu will be displayed during the countdown
* GRUB_TIMEOUT sets the time (in seconds) GRUB waits before loading the default kernel. A value of 0 causes it to boot immediately.

After making changes to `/etc/default/grub` on a RHEL system, run `sudo grub2-mkconfig` for them to take effect. By default, `grub2-mkconfig` just outputs the configuration to the command line. You must specify where to save it using the `-o` flag.
* BIOS: `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`
* UEFI: `sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg`

```
[shane@rhel ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
```

After making changes to `/etc/default/grub` on an Ubuntu system, run `sudo update-grub` for them to take effect.
```
shane@ubuntu-efi:~$ sudo update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.4.0-66-generic
Found initrd image: /boot/initrd.img-5.4.0-66-generic
Adding boot menu entry for UEFI Firmware Settings
done
```

## Managing Modules and Services