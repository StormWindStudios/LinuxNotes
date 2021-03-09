# CompTIA Linux+ Notes
0. [Linux Resources](#linux-resources)
1. [Installation Notes](#installation-notes)
    * [Installation Process](installation-process)
    * [Partition and Filesystem](#partitioning-and-filesystem)
    * [LVM (Logical Volume Management)](#lvm-logical-volume-management)
2. [Package Management](#package-management)
    * [Red Hat Package Management](#red-hat-package-management)
    * [Debian Package Management](#debian-package-management)
    * [Git](#git)
    * [Compiling from Source](#compiling-from-source)
    * [Tiny Compilations](#tiny-compilations)
3. [Booting](#booting)
    * [BIOS Boot Process](#bios-boot-process)
    * [UEFI Boot Process](#uefi-boot-process)
    * [GRUB Configuration](#grub-configuration)
    * [Grubby!](#grubby)
    * [Ad-Hoc GRUB Configurations](#ad-hoc-grub-configurations)
    * [Other Bootloaders](#other-bootloaders)
4. [Managing Modules and Services](#managing-modules-and-services)
5. [systemd](#systemd)
    * [Interacting with systemd](#interacting-with-systemd)
6. [Time and Localization](#time-and-localization)
7. [Network Connectivity](#network-connectivity)
    * [Red Hat Systems](#red-hat-systems)
    * [Ubuntu Systems](#ubuntu-systems)
    * [Routing](#routing)
    * [Hostnames and Domain Resolution](#hostnames-and-domain-resolution)
    * [Network Maintenance Tools](#network-maintenance-tools)
 8. [Security](#security)
     * [SELinux](#selinux)
     * [AppArmor](#apparmor)
     * [Firewalls](#firewalls)
     * [Fail2Ban](#fail2ban)
  9. [Filesystem Administration](#filesystem-administration)
      * [Files and Directories](#files-and-directories)
      * [Utilization](#utilization)
      * [Permissions](#permissions)
      * [Links](#links)
      * [Compression](#compression)
      * [Mounting](#mounting)
      * [File System Structure](#file-system-structure)
      * [Formatting Partitions](#formatting-partitions)
      * [Swap Space](#swap-space)
      * [LVM](#lvm)
      * [Quotas](#quotas)
  10. [String Processing](#string-processing)
      * [sort](#sort)
      * [cut](#cut)
      * [tr](#tr)
      * [grep](#grep)
      * [sed](#sed)
      * [awk](#awk)
  11. [User and Group Administration](#user-and-group-administration)
      * [Creating and Modifying Users](#creating-and-modifying-users)
      * [User Scripts](#user-scripts)
      * [Managing Groups](#managing-groups)
      * [Passwords](#passwords)
  12. [Process Management](#process-management)
      * [Background and Foreground](#background-and-foreground)
      * [Viewing Processes](#viewing-processes)
      * [Ending Processes](#ending-processes)
      * [nice and renice](#nice-and-renice)
  13. [Scheduling Tasks](#scheduling-tasks)
      * [cron](#cron)
      * [anacron](#anacron)
      * [at and batch](#at-and-batch)
  14. [Graphical Interfaces](#graphical-interfaces)
  15. [Server Roles](#server-roles)


## Linux Resources
* [The Arch Wiki](https://wiki.archlinux.org)
* [nixCraft](https://www.cyberciti.biz)
* [The Linux Command Line](https://sourceforge.net/projects/linuxcommand/files/TLCL/19.01/TLCL-19.01.pdf/download) (free No Starch Press book!)
* [How Linux Works](https://nostarch.com/howlinuxworks2) (not-free No Starch Press book)
* [The Urban Penguin](https://www.youtube.com/user/theurbanpenguin)
* [git Handbook](https://guides.github.com/introduction/git-handbook/)


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

### Compiling from Source
You'll occasionally need to download source code and compile it manually. It's not common, but it happens. The process usually proceeds like this:
1. `wget download.site.xyz/source_code.tar.gz` - download from URL
2. `tar -xf source_code.tar.gz` - extract archive
3. `cd source_code` - enter the resulting directory
4. `./config` - to configure the compilation settings
5. `make` - to compile to a local directory
6. `sudo make install` - to install the package system-wide 


**Compiling OpenSSL**

Let's assume you need the newest version of OpenSSL: version 3. That's only available as source code right now.

The first step is to install some requirements and dependencies.
 * `build-essential` contains a number of build tools, such as compilers
 * `libssl-dev` is a library used when compiling OpenSSL
```
ubuntu@ubuntu-arm:~$ sudo apt install build-essential libssl-dev 
```

Next, we need to acquire the source code, extract it, and enter the directory.
```
ubuntu@ubuntu-arm:~$ wget https://www.openssl.org/source/openssl-3.0.0-alpha12.tar.gz
---snip---
openssl-3.0.0-alpha 100%[===================>]  13.49M  23.8MB/s    in 0.6s   

ubuntu@ubuntu-arm:~$ tar -xf openssl-3.0.0-alpha12.tar.gz 
ubuntu@ubuntu-arm:~$ cd openssl-3.0.0-alpha12
```

Now we need to generate the compilation configurations. For many projects, you'd use the `./config` command, but OpenSSL uses the `./Configure` command.

Note: *we're using `./Configure` without any arguments, but this is where you could enable or disable SSL versions, specify installation directories, so forth.*

```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ ./Configure
Configuring OpenSSL version 3.0.0-alpha12 for target linux-armv4
Using os-specific seed configuration

Creating configdata.pm
Running configdata.pm
Creating Makefile

---trim---
OpenSSL has been successfully configured 
---trim---
```

The `make` command will take care of compiling this beast. It may take quite some some.

```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ make
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" "-oMakefile" include/crypto/bn_conf.h.in > include/crypto/bn_conf.h
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" "-oMakefile" include/crypto/dso_conf.h.in > include/crypto/dso_conf.h
/usr/bin/perl "-I." -Mconfigdata "util/dofile.pl" "-oMakefile" include/openssl/asn1.h.in > include/openssl/asn1.h

---snip---
```

After the compilation is complete, run `make test` to perform tests on the program. This is a common step for OpenSSL, given its complexity, but may not be used by other projects.
```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ make test
make depend && make _tests
make[1]: Entering directory '/home/ubuntu/openssl-3.0.0-alpha12'
make[1]: Leaving directory '/home/ubuntu/openssl-3.0.0-alpha12'
make[1]: Entering directory '/home/ubuntu/openssl-3.0.0-alpha12'

---snip---
```

The program is currently compiled, but we need to install it.
```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ sudo make install

---snip---
```

Great! Drum roll, please. Does it work?
```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ which openssl
/usr/local/bin/openssl
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ openssl version
openssl: error while loading shared libraries: libssl.so.3: cannot open shared object file: No such file or directory
```

Nope!

A useful command when compiling your own programs is `ldconfig`, which generates any necessary links to the most recent shared libraries. If you try to run a new program and see a library error, this will often fix it:
```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ sudo ldconfig
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ openssl version
OpenSSL 3.0.0-alpha12 18 Feb 2021 (Library: OpenSSL 3.0.0-alpha12 18 Feb 2021)
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ 
```

You can also use the `ldd` command to list which shared library the executable requires; occasionally you'll need to troubleshoot missing libraries.

```
ubuntu@ubuntu-arm:~/openssl-3.0.0-alpha12$ ldd /usr/local/bin/openssl
	linux-vdso.so.1 (0xbefb8000)
	libssl.so.3 => /usr/local/lib/libssl.so.3 (0xb6e59000)
	libcrypto.so.3 => /usr/local/lib/libcrypto.so.3 (0xb6bd8000)
	libpthread.so.0 => /lib/arm-linux-gnueabihf/libpthread.so.0 (0xb6bb2000)
	libc.so.6 => /lib/arm-linux-gnueabihf/libc.so.6 (0xb6ab4000)
	/lib/ld-linux-armhf.so.3 (0xb6f78000)
	libdl.so.2 => /lib/arm-linux-gnueabihf/libdl.so.2 (0xb6aa1000)
```
### Tiny Compilations
For very small compilations, you don't have to use `make` and its brethren. The `gcc` command can be used to compile single-file projects. Here's an example of compiling a tiny C program.

```
ubuntu@ubuntu-arm:~$ cat <<EOF > tiny_program.c
> #include<stdio.h>
> 
> int main(void)
> {
>   printf("Hola. I is a C program. Boop.\n");
>   return 0;
> }
> EOF

ubuntu@ubuntu-arm:~$ gcc tiny_program.c -o tiny_program

ubuntu@ubuntu-arm:~$ ./tiny_program 
Hola. I is a C program. Boop.
```

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

### GRUB Configuration
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

### What's this vmlinuz and initrd nonsense?

* **vmlinuz** files are the Linux kernel images themselves. They usually end in a "z" to indicate that they are compressed.

* **initrd** files are the "inital ramdisks." They provide a minimal root filesystem which the kernel can use to load core drivers/modules before mounting the actual filesystems on disk partitions.

### Grubby!

The `grubby` command can be used to view and update GRUB configurations on supported systems (usually Red Hat flavors).

**View the default kernel with `grubby`**
```
[shane@rhel ~]$ sudo grubby --default-kernel
/boot/vmlinuz-4.18.0-240.15.1.el8_3.x86_64
```

**View info about current kernel and its boot parameters with `grubby`**
```
[shane@rhel ~]$ sudo grubby --info=/boot/vmlinuz-$(uname -r)
index=0
kernel="/boot/vmlinuz-4.18.0-240.15.1.el8_3.x86_64"
args="ro crashkernel=auto resume=/dev/mapper/rhel-swap rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet $tuned_params"
root="/dev/mapper/rhel-root"
initrd="/boot/initramfs-4.18.0-240.15.1.el8_3.x86_64.img $tuned_initrd"
title="Red Hat Enterprise Linux (4.18.0-240.15.1.el8_3.x86_64) 8.3 (Ootpa)"
id="fba36d7225b7455cb8f59f49a23499c7-4.18.0-240.15.1.el8_3.x86_64"
```
Note: *the `$(uname -r)` is called a command substitution. It provides the output of the `uname -r` command as part of the command we're issuing. `uname -r` prints the running kernel version (4.18.0-240.15.1.el8_3.x86_64), and is much easier to type!*

**Remove a boot argument (in this case, "quiet") from a kernel with `grubby`.** 

Removing the `quiet` argument will cause verbose output to be display during boot.
```
[shane@rhel ~]$ sudo grubby --remove-args "quiet" --update-kernel="/boot/vmlinuz-$(uname -r)"
[shane@rhel ~]$ sudo grubby --info=/boot/vmlinuz-$(uname -r)
---snip---
root rd.lvm.lv=rhel/swap rhgb $tuned_params"
---snip---
```

### Ad-Hoc GRUB Configurations
Sometimes, you need to change the GRUB configuration during boot because something broke. To do so, when the GRUB menu appears (you may need to hold `shift` to make it appear), you can select the entry you want to modify and type `e`. 

From there, you can edit the text of the boot entry as needed. What would an example of an edit be? Well, imagine you have a GUI installed, and you're unable to boot into the graphical interface. To perform maintenance and troubleshooting, you could append `systemd.unit=multi-user.target` to the kernel line to boot only into a CLI.

To boot with the changes, press `Ctrl+X`. These changes are non-persistent, so if something breaks you can usually fix it by rebooting.


### So Can Anyone Just Make These Ad Hoc Configurations?
Yes, by default. Which isn't great. It isn't difficult to set a GRUB password, though.

Note: *these configurations will have different behaviors. The Red Hat example will only prompt for credentials if users try to modify boot arguments. The Ubuntu example requires credentials for any booting to occur!*

**On Red Hat distributions**

Use the `grub2-setpassword` command. Don't forget to run `grub2-mkconfig` to updates the configurations.
```
[shane@rhel ~]$ sudo grub2-setpassword
Enter password: 
Confirm password: 
[shane@rhel ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
```

**On Debian distributions**

 You can manually place a password hash in `/etc/grub.d` and run `update-grub`.**

1. Create password hash using `grub-mkpasswd-pbkdf2`
```
shane@ubuntu:~$ grub-mkpasswd-pbkdf2
Enter password: 
Reenter password: 
PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.90E586E3533AD8B944FB411C5A50CDD1AC0974295B2B25ADE165564677B8B138B0CCA0875D8202C89DBF9BE7E46DB02CE4484651BDCF708100E25796F3541C6D.C4D98F83F5A710087DD4D4879A311B00F732DA41D752047C26E6EE03CA1892F825FF8FE1AE989E796F95229C579071E5A23916611067620D1B023BA573463775
```

2. Using nano or vim, set a superuser name and password in `/etc/grub.d/40_custom`. The first line is `set superusers="username"`and the second is `password_pbkdf2 username grub.pbkdf2.sha512...`
```
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
set superusers="shane"
password_pbkdf2 shane grub.pbkdf2.sha512.10000.90E586E3533AD8B944FB411C5A50CDD1AC0974295B2B25ADE165564677B8B138B0CCA0875D8202C89DBF9BE7E46DB02CE4484651BDCF708100E25796F3541C6D.C4D98F83F5A710087DD4D4879A311B00F732DA41D752047C26E6EE03CA1892F825FF8FE1AE989E796F95229C579071E5A23916611067620D1B023BA573463775                  
```

3. Finally, run `sudo update-grub`. Your Ubuntu system now has GRUB password-protected. 

**Yes-- it's a lot easier on Red Hat flavors!**

### Other Bootloaders
There are bootloaders other than GRUB, though they tend to be less common.
* ISOLINUX - for booting from CD-ROMs
* SYSLINUX - for booting from FAT filesystems
* PXELINUX - for booting over the network with PXE (may use with Kickstart files generated by Anaconda for unattend installations)

## Managing Modules and Services
The Linux kernel is modular, and can load and unload modules that enable different features. For instance, hardware drivers are loaded as modules.

The basic module management commands are:
* `lsmod` lists the modules that are currently load (output is extensive, `lsmod | less` is recommended)
* `insmod` and `rmmod` insert and remove modules, respectively. However, `insmod` requires the full file path of the module, and both commands don't manage dependencies. 
* `modprobe` will load a module and its dependencies; `modprobe -r` will remove a module and its dependencies. You usually want to use this instead of `insmod` or `rmmod`.
* `modinfo` prints verbose information about a module, including its location

## systemd
Most modern Linux systems use systemd to manage services; it is the first process spawned by the kernel, and the parent of nearly everything else.

systemd units and targets are located in `/usr/lib/systemd/system/`. You'll commonly encounter `.service` and `.target` files. The service files contain configuration for individual services; targets are related constellations of individual services.

systemd services have a number of sections. 
* The `[Unit]` section has high-level information and requirements. 
* The `[Service]` section defines service behavior (for instance, how `systemctl reload`, `systemctl restart`, and other commands work). 
* `[Install]` defines how the service is enabled or disabled (which target "wants" it), and can optionally define aliases the service goes by.

The sshd service is a good example:
```
[Unit]
Description=OpenBSD Secure Shell server
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target auditd.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Service]
EnvironmentFile=-/etc/default/ssh
ExecStartPre=/usr/sbin/sshd -t
ExecStart=/usr/sbin/sshd -D $SSHD_OPTS
ExecReload=/usr/sbin/sshd -t
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
Type=notify
RuntimeDirectory=sshd
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
Alias=sshd.service
```

Common systemd targets are: 
* `poweroff.target` -- powers the system off
* `rescue.target` -- boots into a minimal rescure mode
* `multi-user.target` -- multi-user CLI
* `graphical.target`  -- GUI
* `reboot.target` -- reboots the system  

For backward-compatibility, some systemd targets are just symbolic links to others. It's worth remembering these runlevels.
```
shane@ubuntu:~$ ls -l /usr/lib/systemd/system/runlevel*.target | cut -f 10-13 -d" "
/usr/lib/systemd/system/runlevel0.target -> poweroff.target
/usr/lib/systemd/system/runlevel1.target -> rescue.target
/usr/lib/systemd/system/runlevel2.target -> multi-user.target
/usr/lib/systemd/system/runlevel3.target -> multi-user.target
/usr/lib/systemd/system/runlevel4.target -> multi-user.target
/usr/lib/systemd/system/runlevel5.target -> graphical.target
/usr/lib/systemd/system/runlevel6.target -> reboot.target
```
Note: *in the above command, we piped our ls command into `| cut -f 10-13 -d" "`. This was to show only the columns we were interested in (fields 10-13, deliminited by a space). The output of `ls -la` is usually much more verbose* 

### Interacting with systemd

The king of systemd commands is `systemctl`. It's used heavily for managing services and targets, as well as gathering information.

| Command | Explanation |
| ------- | ----------- |
|`systemctl status httpd`| Gets the httpd service's status |
|`systemctl start httpd`| Starts the httpd service |
|`systemctl stop httpd`| Stops the httpd service|
|`systemctl reload httpd`| Gracefully reloads httpd's configuration|
|`systemctl restart httpd`| Restarts the httpd service (not so graceful)|
|`systemctl daemon-reload httpd`| Reloads the configuration in the .service file (useful if edits were made) |
|`systemctl enable httpd`| Enables httpd to start on boot |
|`systemctl disable httpd`| Disables httpd start during boot 
|`systemctl mask httpd`| Masks httpd (won't start until unmasked) |
|`systemctl unmask httpd`| Unmasks httpd |
|`systemctl is-active httpd`| Shows if httpd is active (useful for scripts)|
|`systemctl is-enabled httpd`| Show if http is enabled (useful for scripts) |
|`systemctl list-units --type service`| Lists all active services |
|`systmectl list-units --type service --all`| Lists all active & inactive services |
|`systemctl isolate graphical.target`|Jumps directly to the graphical target|
|`systemctl reboot`| Jumps to the reboot target |
|`systemctl poweroff`| Jumps to the poweroff target|

systemd has a number of other commands, such as `localctl`, `hostnamectl`, and `timedatectl`, covered in other areas.

For more information, check out [Demystifying systemd](https://www.youtube.com/watch?v=tY9GYsoxeLg).

## Time and Localization
`date` can be used to view and set the system time.

```
shane@ubuntu:~$ date
Tue 02 Mar 2021 08:54:16 PM UTC

shane@ubuntu:~$ sudo date -s "2 OCT 2020 18:15:00"
Fri 02 Oct 2020 06:15:00 PM UTC
```

`hwclock` can be used to view and set the time of the hardware clock.

```
shane@ubuntu:~$ sudo hwclock 
2021-03-02 21:01:24.718963+00:00

shane@ubuntu:~$ sudo hwclock --systohc 

shane@ubuntu:~$ sudo hwclock 
2021-03-02 21:01:40.236664+00:00
```
`timedatectl` is the easiest command for viewing and setting timezones, times, and dates.
```
shane@ubuntu:~$ timedatectl 
               Local time: Tue 2021-03-02 21:02:55 UTC
           Universal time: Tue 2021-03-02 21:02:55 UTC
                 RTC time: Tue 2021-03-02 21:02:55    
                Time zone: Etc/UTC (UTC, +0000)       
System clock synchronized: yes                        
              NTP service: active                     
          RTC in local TZ: no

shane@ubuntu:~$ sudo timedatectl set-timezone America/Phoenix
shane@ubuntu:~$ timedatectl 
               Local time: Tue 2021-03-02 14:03:25 MST 
           Universal time: Tue 2021-03-02 21:03:25 UTC 
                 RTC time: Tue 2021-03-02 21:03:25     
                Time zone: America/Phoenix (MST, -0700)
System clock synchronized: yes                         
              NTP service: active                      
          RTC in local TZ: no      
```
Note: *ideally, you'll have chronyd or ntpd in place to automatically do time synchronization*


Localization information can be viewed with `locale`. It's actually just a collection of environmental variables.

```
shane@ubuntu:~$ locale
LANG=en_US.UTF-8
LANGUAGE=
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=

shane@ubuntu:~$ echo $LANG
en_US.UTF-8
shane@ubuntu:~$ 
```

Use `localectl` to modify localization information. The changes will be reflected on the next login.

```
shane@ubuntu:~$ sudo localectl set-locale en_CA.UTF-8
```

## Network Connectivity

Network interfaces can be configured in multiple ways.

* `nmtui`, if installed, gives you a quasi-graphical interface
* `nmcli`, if installed, allows you to view and modify settings from the CLI
* `netplan` is commonly seen on Ubuntu systems
* Manual modification of text files may or may not be required

### Red Hat Systems
 
 `nmtui` and `nmcli` are good options. Remember to reload the interface for changes to take effect. An example of `nmcli` is below
```
[shane@rhel ~]$ nmcli | head -n 5
enp0s3: connected to enp0s3
	"Intel 82540EM"
	ethernet (e1000), 08:00:27:0E:26:0D, hw, mtu 1500
	ip4 default
	inet4 10.0.1.223/24

[shane@rhel ~]$ sudo nmcli con mod enp0s3 ipv4.address "10.0.1.224/24"

[shane@rhel ~]$ sudo nmcli con down id enp0s3 && sudo nmcli con up id enp0s3
Connection 'enp0s3' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/1)
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)

[shane@rhel ~]$ nmcli | head -n 5
enp0s3: connected to enp0s3
	"Intel 82540EM"
	ethernet (e1000), 08:00:27:0E:26:0D, hw, mtu 1500
	ip4 default
	inet4 10.0.1.224/24
```

You can look for the text configuration file in `/etc/sysconfig/network-scripts/`.

```
[shane@rhel ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s3 
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=enp0s3
UUID=de0ffd32-5c1b-4eb6-a836-b67f874c0e07
DEVICE=enp0s3
ONBOOT=yes
IPADDR=10.0.1.224
PREFIX=24
GATEWAY=10.0.1.1
DNS1=10.0.1.53
DNS2=10.0.1.133
IPV6_DISABLED=yes
```

### Ubuntu Systems
Network configurations can be found in `/etc/netplan/00-installer-config.yaml`.

```
shane@ubuntu:~$ cat /etc/netplan/00-installer-config.yaml 
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 10.0.1.225/24
      gateway4: 10.0.1.1
      nameservers:
        addresses: [10.0.1.133]
  version: 2
```

YAML can be tricky, so it's good to back up the file "just in case."
```
shane@ubuntu:~$ cp /etc/netplan/00-installer-config.yaml 00-installer-config.yaml.bak
shane@ubuntu:~$ ls
00-installer-config.yaml.bak
```

Changes to the configuration can be loaded using `sudo netplan apply`.
```
shane@ubuntu:~$ sudo netplan apply
shane@ubuntu:~$ 
```

### Routing
The routing table tells Linux "to get traffic to this place, send it through that address."

If it is messed up, it might be sending traffic to the wrong place.

The quickest way to view the routing table is with the `route` command.
```
shane@ubuntu:~$ route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         _gateway        0.0.0.0         UG    0      0        0 enp0s3
10.0.1.0        0.0.0.0         255.255.255.0   U     0      0        0 enp0s3
```

To get numeric output, use `route -n`.

```
shane@ubuntu:~$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.0.1.1        0.0.0.0         UG    0      0        0 enp0s3
10.0.1.0        0.0.0.0         255.255.255.0   U     0      0        0 enp0s3
```

### Hostnames and Domain Resolution

How can you set a system's hostname? Let us count the ways.

Via `hostnamectl`
```
shane@ubuntu:~$ sudo hostnamectl set-hostname ubuuuntu
```

Via `hostname`
```
shane@ubuntu:~$ sudo hostname -b ubuuuntu
```

Via `nmcli`
```
[shane@rhel ~]$ sudo nmcli general hostname rhelly
```

By editing `/etc/hostname`
```
[shane@rhel ~]$ sudo vi /etc/hostname
```

And also by `nmtui`

Domain resolution is a related topic. DNS (or the hosts file) maps the names of remote system to IP addresses. We've elready examined how DNS servers can be configured in prior examples. Another way is by editing `resolv.conf.` 

```
[shane@rhelly ~]$ cat /etc/resolv.conf 
# Generated by NetworkManager
nameserver 10.0.1.53
nameserver 10.0.1.133
```
Note: *certain services, such as NetworkManager, may alter or overwrite resolv.conf. Also, it doesn't end in an 'e' for some reason.*

You can statically define hostname-to-IP mappings in `/etc/hosts`. For instance, here we define a lab VM at 10.0.1.225 as "ubuskis.labvm"
```
[shane@rhelly ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[shane@rhelly ~]$ sudo vi /etc/hosts

[shane@rhelly ~]$ tail -n 1 /etc/hosts
10.0.1.225  ubuskis.labvm

[shane@rhelly ~]$ ping -c 2 ubuskis.labvm
PING ubuskis.labvm (10.0.1.225) 56(84) bytes of data.
64 bytes from ubuskis.labvm (10.0.1.225): icmp_seq=1 ttl=64 time=0.196 ms
64 bytes from ubuskis.labvm (10.0.1.225): icmp_seq=2 ttl=64 time=0.144 ms
```

### Network Maintenance Tools
|Tool|Examples|Notes|
|----|-------|-----|
|`ping`|`ping myspace.com`| Sends infinite pings to MySpace (exit with Ctrl+C)|
||`ping -c 4 google.com`| Send 4 pings to Google|
|`nslookup`|`nslookup hotmail.com`| Retrieves DNS records for Hotmail from the normal DNS server |
||`nslookup bing.com 9.9.9.9`| Retrieves DNS records for Bing from the specified server (9.9.9.9)|
|`dig`|`dig askjeeves.com`| Retrieves DNS records for AskJeeves; more detailed than `nslookup`|
|`host`|`host dogpile.com`| Retrieves DNS records for DogPile|
|`netstat`|`netstat -at`| List all TCP sockets|
||`netstat -lt`| List listening TCP sockets|
||`netstat -au` | List all UDP sockets|
||`netstat -s`| Show protocol statistics|
|`ss`|`ss -at`| List all TCP sockets|
||`ss -lt`| List listening TCP sockets|
||`ss -au` | List all UDP sockets|
||`ss -s`| Show protocol statistics|
|||Note: *netstat and ss are very similar. However, ss is more robust and runs faster.* |
|`mtr`|`mtr google.com`| Displays live, hop-by-hop traffic metrics to Google|
|`traceroute`|`traceroute google.com`| Traces the route to to Google |
|`tracepath`|`tracepath google.com`| Similar to `traceroute`, but also discovers MTU!|
|`iftop`|`iftop`|Live output of network traffics (like `top` provides for processes)|
## Security
### SELinux

*Following along? Mise-en-place!* `sudo dnf install policycoreutils-python-utils`

SELinux was originally made by the NSA before being released as open-source software and integrated into many Linux distributions. It allows MAC (mandatory access control), in which access control rules are defined by administrators. This is fundamentally different to the DAC (discretionary access control) we usually see with filesystems. With DAC, the owner of a file or resource is allowed to define permissions and privileges for other users.

It can operate in three modes:
* *enforcing*
* *permissive* (still evauluating policies and generating logs, but not enforcing)
* *disabled*

SELinux has a robust policy system and granular labelling, but for Linux+ you won't need to be an expert. Let's start with how you gather information. 

Use `sestatus` to check the SELinux mode, configuration directory, and status.
```
[shane@rhelly ~]$ sudo sestatus
[sudo] password for shane: 
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      32
```

Use `getenforce` if you're mainly interested in (suprise) whether SELinux is enforcing.
```
[shane@rhelly ~]$ sudo getenforce
Enforcing
```

`setenforce` allows you to toggle between enforcing and permissive (you can't set it to disabled while its running).

```
[shane@rhelly ~]$ sudo setenforce permissive
[shane@rhelly ~]$ sudo getenforce
Permissive
```

Running `ls` with the `-Z` option will display the labels applied to the filesystem.
```
[shane@rhelly ~]$ ls -Z ~/.ssh/
unconfined_u:object_r:ssh_home_t:s0 known_hosts
```
Use `getsebool` to search the SELinux boolean configurations or view the values of a specific one.

```
[shane@rhelly ~]$ sudo getsebool -a | grep httpd_enable
httpd_enable_cgi --> on
httpd_enable_ftp_server --> off
httpd_enable_homedirs --> on

[shane@rhelly ~]$ sudo getsebool samba_share_nfs
samba_share_nfs --> off
```
Predictably, `setsebool` can be used to change these values.
```
[shane@rhelly ~]$ sudo getsebool samba_share_nfs
samba_share_nfs --> on
```

SELinux log denials can be found by grepping `/var/log/audit/audit.log`.
```
[shane@rhelly ~]$ sudo cat /var/log/audit/audit.log | grep 'AVC.*denied'
type=AVC msg=audit(1614771379.774:739): avc:  denied  { node_bind } .....
--- snip output ---
```
Note: *`grep 'AVC.*denied'` will output all lines with "AVC" and "denied" in them.*

There are three common issues with SELinux that we will cover:

* Mislabelling in the filesystem
* Incorrect SELinux boolean settings
* Atypical network ports

**Mislabelling in the Filesystem**

`httpd.conf` has a type of `httpd_config_t`. This is the correct label.
```
[shane@rhelly ~]$ ls -Z /etc/httpd/conf/httpd.conf 
system_u:object_r:httpd_config_t:s0 /etc/httpd/conf/httpd.conf
```

Changing its type to `admin_home_t` is a bold move.

```
[shane@rhelly ~]$ sudo chcon -t admin_home_t /etc/httpd/conf/httpd.conf

[shane@rhelly ~]$ls -Z /etc/httpd/conf/httpd.conf 
system_u:object_r:admin_home_t:s0 /etc/httpd/conf/httpd.conf

[shane@rhelly ~]$ sudo systemctl reload httpd
Job for httpd.service failed.
See "systemctl status httpd.service" and "journalctl -xe" for details.

[shane@rhelly ~]$ sudo cat /var/log/audit/audit.log | grep 'AVC.*denied' | tail -1
type=AVC msg=audit(1614810838.981:2360): avc:  denied  { read } for  pid=8092 comm="httpd" name="httpd.conf" ...
---snip---
```

We can use `restorecon` to reapply the default labels.
```
[shane@rhelly ~]$ sudo restorecon /etc/httpd/conf/httpd.conf 
[shane@rhelly ~]$ ls -Z /etc/httpd/conf/httpd.conf 
system_u:object_r:httpd_config_t:s0 /etc/httpd/conf/httpd.conf
[shane@rhelly ~]$ sudo systemctl start httpd
```

**Incorrect SELinux Boolean Setting**

Occasionally the labelling is fine, but we're doing something that SELinux denies by default. The following directory is labelled correctly and its filesystem permissions are permissive.
```
[shane@rhelly ~]$ ls -Z public_html/
unconfined_u:object_r:httpd_user_content_t:s0 index.html

[shane@rhelly ~]$ curl -I 127.0.0.1
HTTP/1.1 403 Forbidden
Date: Wed, 03 Mar 2021 22:54:54 GMT
Server: Apache/2.4.37 (Red Hat Enterprise Linux)
Content-Type: text/html; charset=iso-8859-1
```
Note: *`curl -I` will tell you whether the request is successful or not without outputting a bunch of HTML.*

The issue here is that SELinux doesn't let httpd poke around in users' home directories by default. This is an easy fix.

```
[shane@rhelly ~]$ sudo getsebool -a | grep httpd
---snip---
httpd_enable_ftp_server --> off
httpd_enable_homedirs --> off
httpd_execmem --> off
---snip---

[shane@rhelly ~]$ sudo setsebool httpd_enable_homedirs 1
[shane@rhelly ~]$ curl -I 127.0.0.1
HTTP/1.1 200 OK
Date: Wed, 03 Mar 2021 22:59:53 GMT
Server: Apache/2.4.37 (Red Hat Enterprise Linux)
Last-Modified: Wed, 03 Mar 2021 12:30:18 GMT
ETag: "7-5bca1038865fa"
Accept-Ranges: bytes
Content-Length: 7
Content-Type: text/html; charset=UTF-8
```

**Atypical Network Ports**

Consider this error.
```
[shane@rhelly ~]$ sudo systemctl start httpd
Job for httpd.service failed because the control process exited with error code.
See "systemctl status httpd.service" and "journalctl -xe" for details.

[shane@rhelly ~]$ sudo tail /var/log/messages
Mar  3 16:02:14 rhel systemd[1]: Stopping The Apache HTTP Server...
Mar  3 16:02:15 rhel systemd[1]: httpd.service: Succeeded.
Mar  3 16:02:15 rhel systemd[1]: Stopped The Apache HTTP Server.
Mar  3 16:02:18 rhel systemd[1]: Starting The Apache HTTP Server...
Mar  3 16:02:21 rhel httpd[8758]: (13)Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:1337
Mar  3 16:02:21 rhel httpd[8758]: no listening sockets available, shutting down
Mar  3 16:02:21 rhel httpd[8758]: AH00015: Unable to open logs
Mar  3 16:02:21 rhel systemd[1]: httpd.service: Main process exited, code=exited, status=1/FAILURE
Mar  3 16:02:21 rhel systemd[1]: httpd.service: Failed with result 'exit-code'.
Mar  3 16:02:21 rhel systemd[1]: Failed to start The Apache HTTP Server.
```

The more recent entries in `/var/log/messages` indicate that permission to create a socket was denied. A quick check of Apache's configuration file shows that we're using the l33t hacker port.

```
[shane@rhelly ~]$ sudo grep -i "^listen" /etc/httpd/conf/httpd.conf 
Listen 1337
```

Let's inform SELinux.
```
[shane@rhelly ~]$ sudo semanage port -a -t http_port_t -p tcp 1337

shane@rhelly ~]$ sudo systemctl start httpd
[shane@rhelly ~]$ systemctl is-active httpd
active

[shane@rhelly ~]$ curl -I 127.0.0.1:1337
HTTP/1.1 200 OK
Date: Wed, 03 Mar 2021 23:18:28 GMT
Server: Apache/2.4.37 (Red Hat Enterprise Linux)
Last-Modified: Wed, 03 Mar 2021 12:30:18 GMT
ETag: "7-5bca1038865fa"
Accept-Ranges: bytes
Content-Length: 7
Content-Type: text/html; charset=UTF-8
```

### AppArmor
*Following along? Mise-en-place!*
`sudo apt install apparmor-utils apparmor-profiles apparmor-profiles-extra libapache2-mod-apparmor`

AppArmor, like SELinux, provides MAC. It uses profiles which define what services are allowed to do and access. There are many predefined profiles available, such as those installed by the above command.

In this example, we just installed Apache on an Ubuntu server. Running `aa-unconfined` shows us that Apache is, well, unconfined.

```
shane@ubuuuntu:~$ sudo aa-unconfined
626 /usr/lib/systemd/systemd-resolved (/lib/systemd/systemd-resolved) not confined
671 /usr/sbin/sshd (sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups) not confined
7258 /usr/sbin/apache2 not confined
7261 /usr/sbin/apache2 not confined
7262 /usr/sbin/apache2 not confined
```

We can put Apache in complain mode for a period of time to ensure AppArmor won't break it. Anything that would otherwise be denied is allowed and logged in `/var/log/kern.log`

```
shane@ubuuuntu:~$ sudo aa-complain /etc/apparmor.d/usr.sbin.apache2
```

When you're satisfied that AppArmor won't blow up your webserver, you can start enforcing the profile.
```
shane@ubuuuntu:~$ sudo aa-enforce /etc/apparmor.d/usr.sbin.apache2

shane@ubuuuntu:~$ sudo aa-status
apparmor module is loaded.
62 profiles are loaded.
42 profiles are in enforce mode.
---snip---
   apache2
   apache2//DEFAULT_URI
   apache2//HANDLING_UNTRUSTED_INPUT
   apache2//phpsysinfo
---snip---
```
### Firewalls

When we talk about Linux firewalls, we're usually referring to frontends for *the* Linux firewall. More accurately, we're referring to frontends to frontends of the Linux firewall!

**firewalld** and **UFW** are both frontends to the more difficult **iptables** [1], but **iptables** is itself a frontend to **netfilter** in the Linux kernel [2]. 

``` 
    |-------------|      |-------------|
    |             |      |             |
    |  firewalld  |      |     UFW     |
    |    (RHEL)   |      |   (Debian)  |
    |_____________|      |_____________|
            \                   /
             \                 /
              \ [1]       [1] /
               \             /
                \           / 
               |-------------|    
               |             |
               |  iptables   |   
               |             | 
               |_____________|    
                     |
                     | [2]
                     |
               |-------------|    
               |             |
               |  netfilter  |   
               |             | 
               |_____________|     
``` 
**firewalld Basics**

firewalld is managed as a zone-based firewall through the `firewall-cmd` tool. It is primarily found on RHEL-flavored distributions.

| Command                    | Explanation                           |
| -------------------------- | ------------------------------------- |
|`firewalld --get-zones`| List the zones currently defined      |
|`firewalld --get-active-zones`| List the zones which are currently active |
|`firewall-cmd --zone=public --add-service=https --permanent`| Permanently allow HTTPS in the public zone. |
|`firewall-cmd --zone=trusted --add-port=3389/tcp --permanent`| Permanently allow RDP in the trusted zone |
|`firewall-cmd --zone=public --list-all`| List all rules defined for the public zone |
|`firewall-cmd --reload`| Reload firewalld (for changes to take effect)|


**UFW Basics**

UFW is commonly seen on Debian systems. It is managed with the `ufw` command.

| Command                    | Explanation                           |
| -------------------------- | ------------------------------------- |
|`ufw enable`| Enable UFW |
|`ufw status verbose`| Show the firewall rules |
|`ufw allow https`| Allows HTTPS |
|`ufw allow 8080/tcp`| Allow connection to TCP port 80 |
|`ufw allow from 10.0.0.0/16 to any 25/tcp`| Allow SMTP traffic from a block of addresses |
|`ufw status numbered`| Show the firewall rules and their numbers |
|`ufw delete 6`| Delete rule 6 |


**iptables Basics**

iptables is present on most Linux systems, but you should avoid interacting with it directly if you're using tools like firewalld or UFW. 

You probably don't want to anyway. For example, here are two commands to allow SSH (input and output).

```
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

Let's "translate" them into English.

| iptables | -A INPUT | -i eth0 | -p tcp |--dport 22| -m state | --state NEW,ESTABLISHED |-j ACCEPT| 
|---|---|---|---|---|---|---|---|
|iptables|append to INPUT chain|for input int eth0|for tcp traffic| to port 22|with a state of |NEW or ESTABLISHED|jump to accept|

| iptables | -A OUTPUT | -o eth0 | -p tcp | --sport 22 | -m state | --state ESTABLISHED | -j ACCEPT
|---|---|---|---|---|---|---|---|
|iptables | append to OUTPUT chain|for output int eth0|for tcp traffic| from port 22|with a state of|ESTABLISHED|jump to accept|

Make note of the `-J` flag. It defines the action that will be taken. Common actions are:
* ACCEPT - traffic is allowed
* REJECT - traffic is denied with message
* DROP   - traffic is silently dropped

If you are still determined to use iptables, be aware that any rules you defined are *not* persistent by default. You must either install a helper service or save the rules on shutdown (`iptables-save > fw.rules`) and reload them on startup (`iptables-restore fw.rules`)

### Fail2Ban
Fail2Ban is a cool tool. It monitors log entries for authentication failures and, once a threshold is met, will dynamically generate firewall rules to block offending IP addresses.

Let's get it up and running on Ubuntu.

```
shane@ubuntu-efi:~$ sudo apt install fail2ban
```

Create a new configuration file with `sudo nano /etc/fail2ban/jail.d/local.jail`

```
[DEFAULT]
backend = systemd

[sshd]
enabled = true
port = 22
findtime = 2m
bantime = 10m
logpath = /var/log/auth.log
maxretry = 2
```

Enable and start fail2ban, and optionally check the logs.

```
shane@ubuntu-efi:~$ sudo systemctl enable fail2ban
Synchronizing state of fail2ban.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable fail2ban
shane@ubuntu-efi:~$ sudo systemctl start fail2ban.service 

shane@ubuntu-efi:~$ sudo tail /var/log/fail2ban.log 
2021-03-04 00:15:05,671 fail2ban.jail           [7430]: INFO    Creating new jail 'sshd'
2021-03-04 00:15:05,690 fail2ban.jail           [7430]: INFO    Jail 'sshd' uses systemd {}
2021-03-04 00:15:05,691 fail2ban.jail           [7430]: INFO    Initiated 'systemd' backend
2021-03-04 00:15:05,692 fail2ban.filter         [7430]: INFO      maxLines: 1
2021-03-04 00:15:05,723 fail2ban.filtersystemd  [7430]: INFO    [sshd] Added journal match for: '_SYSTEMD_UNIT=sshd.service + _COMM=sshd'
2021-03-04 00:15:05,723 fail2ban.filter         [7430]: INFO      maxRetry: 2
2021-03-04 00:15:05,723 fail2ban.filter         [7430]: INFO      findtime: 120
2021-03-04 00:15:05,723 fail2ban.actions        [7430]: INFO      banTime: 600
2021-03-04 00:15:05,723 fail2ban.filter         [7430]: INFO      encoding: UTF-8
2021-03-04 00:15:05,725 fail2ban.jail           [7430]: INFO    Jail 'sshd' started

```

From another IP address, fail multiple SSH authentications. Success!

```
shane@Shanes-MacBook-Pro LinuxNotes % ssh shane@10.0.1.227
shane@10.0.1.227's password: 
Permission denied, please try again.
shane@10.0.1.227's password: 
Permission denied, please try again.
shane@10.0.1.227's password: 
^C
shane@Shanes-MacBook-Pro LinuxNotes % ssh shane@10.0.1.227
ssh: connect to host 10.0.1.227 port 22: Connection refused
```

`fail2ban-client` can be used to view the status and unban IP addresses.

```
shane@ubuntu-efi:~$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	2
|  `- Journal matches:	_SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned:	1
   |- Total banned:	1
   `- Banned IP list:	10.0.1.12

sudo fail2ban-client set sshd unbanip 10.0.1.12
```

## Filesystem Administration
### Files and Directories

Make a quick directory structure with these commands.
```
shane@ubuuuntu:~/testdir$ mkdir public_stuff
shane@ubuuuntu:~/testdir$ echo "111-222-4444 ext 11235" > public_stuff/my_phone_number

shane@ubuuuntu:~/testdir$ mkdir private_stuff
shane@ubuuuntu:~/testdir$ echo "123-12-1234" > private_stuff/my_social_security_number

```
`ls -lah` gives us a wealth of information about these new filesystem objects.
```
shane@ubuuuntu:~/testdir$ ls -lah 
total 16K
drwxrwxr-x 4 shane shane 4.0K Mar  3 19:15 .
drwxr-xr-x 6 shane shane 4.0K Mar  3 19:15 ..
drwxrwxr-x 2 shane shane 4.0K Mar  3 19:17 private_stuff
drwxrwxr-x 2 shane shane 4.0K Mar  3 19:16 public_stuff
```
* The current directory is about 16Kb.
* Column 1 displays permissions (`d` denotes a directory)
* Column 2 displays the number of links
* Column 3 shows the owner
* Column 4 shows the group
* Column 5 show the size
* Columns 6, 7, and 8 are timestamp information
* The final column gives us the identity of each object being displayed
    * `.` is the current directory
    * `..` is the parent directory
    * `public_stuff` and `private_stuff` are directories we made

To view the same information about the files we made, you can run `ls -lah ./*`.
```
shane@ubuuuntu:~/testdir$ ls -lah ./*
./private_stuff:
total 16K
drwxrwxr-x 2 shane shane 4.0K Mar  3 19:17 .
drwxrwxr-x 4 shane shane 4.0K Mar  3 19:15 ..
-rw-rw-r-- 1 shane shane   12 Mar  3 19:21 my_social_security_number

./public_stuff:
total 12K
drwxrwxr-x 2 shane shane 4.0K Mar  3 19:16 .
drwxrwxr-x 4 shane shane 4.0K Mar  3 19:15 ..
-rw-rw-r-- 1 shane shane   23 Mar  3 19:21 my_phone_number
```
The primary visual difference is that directory entries start with a `d` and files start with a `-`. What's *really* most notable is that our social security number has the same permissions as our phone number! Let's lock the permissions down.

### Utilization
Linux provides a number of tools to check the utilization of storage capacity and throughput. For capacity, we'll focus on `df` and `du` (with special guest `lsof`). For throughput, we'll look at `iostat`, `hdparm`, and `vmstat`.

**df**

You can use `df` to check free disk space on a system's block devices.

Its default output is in bytes, but you can make it human readable with the `-h` flag.
```
ubuntu@ubuntu-arm:~$ df
Filesystem     1K-blocks     Used Available Use% Mounted on
/dev/mmcblk0p2  30445404 15369216  13794044  53% /
/dev/mmcblk0p1    258095   114297    143798  45% /boot/firmware
---snip--

ubuntu@ubuntu-arm:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/mmcblk0p2   30G   15G   14G  53% /
/dev/mmcblk0p1  253M  112M  141M  45% /boot/firmware
---snip---
```

If a filesystem's inodes are at capacity, you will get an error that makes it sound like the disk is out of space. You'll probably then run a `df -h` and scratch your head because there's plenty of space!

If you're getting out-of-space errors, but there is still space, consider taking a look at the inode consumptions with `df -i`.
```
ubuntu@ubuntu-arm:~$ df -i
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/mmcblk0p2 1937712 166615 1771097    9% /s
```

**du**

`du` is similar to `df`, but can be used to check the size of specific directories.

By default, it outputs size information (in bytes) about all subdirectories of the directory you specify. You can get human readable with `-h` and a summary with `-s`.

```
ubuntu@ubuntu-arm:~$ sudo du /home/shane
4	/home/shane/.cache
24	/home/shane

ubuntu@ubuntu-arm:~$ sudo du -hs /home/shane
24K	/home/shane

ubuntu@ubuntu-arm:~$ sudo du -hs /usr/bin/
76M	/usr/bin/
```

**lsof**

`lsof` lists currently open files. 

It is mentioned here because if you delete a large file, the space will not be freed up if a process is still using the file (even though `df` would report the space as free).

You can use the command `sudo lsof +L1` to identify processes which are keeping deleted files open.
```
ubuntu@ubuntu-arm:~$ sudo lsof +L1
COMMAND     PID   USER  FD   TYPE DEVICE SIZE/OFF NLINK  NODE NAME
networkd-  1658   root txt    REG  179,2  3910400     0  6421 /usr/bin/python3.8 (deleted)
systemd-l  1665   root txt    REG  179,2   177740     0 28165 /usr/lib/systemd/systemd-logind (deleted)
unattende  1709   root txt    REG  179,2  3910400     0  6421 /usr/bin/python3.8 (deleted)
none       1773   root txt    REG    0,1     8400     0 61177 / (deleted)
systemd   25300 ubuntu txt    REG  179,2  1075228     0 28148 /usr/lib/systemd/systemd (deleted)
(sd-pam)  25301 ubuntu txt    REG  179,2  1075228     0 28148 /usr/lib/systemd/systemd (deleted)
```

**iostat**

`iostat` (install as part of `sysstat`) provides statistics about input/output operations to storage devices.

Note: */dev/mmcblk0p2 is the name of the storage on this Raspberry Pi*

```
ubuntu@ubuntu-arm:~$ i
sudo apt install sysstat
---snip---


ubuntu@ubuntu-arm:~$ iostat /dev/mmcblk0p2
Linux 5.4.0-1023-raspi (ubuntu-arm) 	03/09/21 	_armv7l_	(4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.02    0.01    0.02    0.01    0.00   99.95

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
mmcblk0p2         0.05         0.10         3.17         5.53     749530   24799512   43294264
```

**hdparm**
`hdparm` can be used to get block storage device paramaters (hence the name), as well as to benchmark them.

To view information about parameters:
```
ubuntu@ubuntu-arm:~$ sudo hdparm /dev/mmcblk0p2

/dev/mmcblk0p2:
 HDIO_DRIVE_CMD(identify) failed: Invalid argument
 readonly      =  0 (off)
 readahead     = 256 (on)
 HDIO_DRIVE_CMD(identify) failed: Invalid argument
 geometry      = 968671/4/16, sectors = 61994975, start = 526336
```

To benchmark:
```
ubuntu@ubuntu-arm:~$ sudo hdparm -tT /dev/mmcblk0p2

/dev/mmcblk0p2:
 Timing cached reads:   1456 MB in  2.00 seconds = 728.25 MB/sec
 HDIO_DRIVE_CMD(identify) failed: Invalid argument
 Timing buffered disk reads: 132 MB in  3.02 seconds =  43.72 MB/sec
```

**vmstat**
`vmstat` is another utility for viewin input/output statistics. This one is more focused on virtual memory.

```
ubuntu@ubuntu-arm:~$ vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0 775140  49304 2935232    0    0     0     1    0    1  0  0 100  0  0
 ```
### Permissions
Filesystem permissions provide discretionary access control (DAC) for Linux systems. They are organized as three triplets of **read**, **write**, and **execute** permissions: one for the file's owner, one for the file's group, and one for all other users.

In the following output of `ls -la`, the permissions are the string of characters in the leftmost column.

```
ubuntu@ubuntu-arm:~/permissions$ ls -la
---snip---
-rw-rw-r--  1 ubuntu sales    0 Mar  9 03:29 test_file
drwxrwxr-x  2 ubuntu sales 4096 Mar  9 03:29 test_dir
```
The first position is a `d` or a `-`. If it begins with a `d`, its a directory. Otherwise, it's a file. The remaining 9 positions define read, write, and execute permissions for the user, group, and others.

Lets look at each entry. 

|| Permissions | Directory | User | Group | Others |
|-| ----------- | --------- | ---- | ----- | ------ |
|`test_file`| -rw-rw-r--  |     -     | rw-  | rw-   | r--    |
|`test_dir`| drwxrwxr-x  |   d       | rwx  | rwx   | r-x    |


The permissions for `test_file` are:
* User (ubuntu): read & write
* Group (sales): read & write
* Others: read


The permissions for `test_dir` are:
* User (ubuntu): read, write, and execute
* Group (sales): read, write, and execute
* Others: read and execute

Permissions mean different things for files and directories.
| Permission | Files | Directories |
| ---------  | ----- | ----------- |
| Read | Read contents of file  | List contents of directory |
| Write  | Modify file | Create, delete, or rename directory contents |
| Execute | Execute file | Enter directory (required for **r** or **w**) |

File permissions are intuitive, but let's look closer at directory permissions.

By default, we can create a file in `test_dir`. When we remove write permissions using `chmod -w`, we can no longer create a file.
```
ubuntu@ubuntu-arm:~/permissions$ echo "hello" >> test_dir/my_file
ubuntu@ubuntu-arm:~/permissions$ chmod -w test_dir

ubuntu@ubuntu-arm:~/permissions$ echo "hello again" >> test_dir/my_other_file
-bash: test_dir/my_other_file: Permission denied
```

By default, we can also list the contents of `test_dir`. When we remove read permissions using `chmod -r`, we can no longer do that.
```
ubuntu@ubuntu-arm:~/permissions$ ls test_dir/
my_file
ubuntu@ubuntu-arm:~/permissions$ chmod -r test_dir/
ubuntu@ubuntu-arm:~/permissions$ ls test_dir/
ls: cannot open directory 'test_dir/': Permission denied
```

We still have execute permissions, so we can technically enter the directory. But even inside, we can't see the contents or the edit them.
```
ubuntu@ubuntu-arm:~/permissions$ cd test_dir/
ubuntu@ubuntu-arm:~/permissions/test_dir$ touch test123
touch: cannot touch 'test123': Permission denied

ubuntu@ubuntu-arm:~/permissions/test_dir$ ls 
ls: cannot open directory '.': Permission denied

ubuntu@ubuntu-arm:~/permissions$ cd ..
```

Let's see what the `chmod -r` and `chmod -w` commands did to the permission strings.
```
ubuntu@ubuntu-arm:~/permissions$ ls -la 
-rw-rw-r--  1 ubuntu sales     0 Mar  9 03:29 test_file
d--x--x--x  2 ubuntu sales  4096 Mar  9 03:58 test_dir
```

Notice that `chmod -r` removes ALL read permissions, and `chmod -w` removes ALL write permissions. We're left with only execute permissions.

We can add back the read and write permissions with `chmod +r` and `chmod +w`. Notice that others did not get write permissions. This is due to a `umask`, which we will cover later.

```
ubuntu@ubuntu-arm:~/permissions$ ls -la 
total 12
-rw-rw-r--  1 ubuntu sales     0 Mar  9 03:29 test_file
drwxrwxr-x  2 ubuntu sales  4096 Mar  9 03:58 test_dir
```

If you want to make more specific permissions modifications, you can use an extension of the previous `chmod` syntax. It has three parts: 
* **who** you're modifying the permissions for. `u`, `g`, or `o`.
* **what** you're doing (adding or removing) `+` or `-`
* **which** permissions `r`, `w`, or `x`

Here are a few examples.

Adding user execute permissions.
```
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rw-rw-r-- 1 ubuntu sales 0 Mar  9 03:29 test_file

ubuntu@ubuntu-arm:~/permissions$ chmod u+x test_file 

ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rwxrw-r-- 1 ubuntu sales 0 Mar  9 03:29 test_file
```

Removing user execute permissions.
```
ubuntu@ubuntu-arm:~/permissions$ chmod u-x test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rw-rw-r-- 1 ubuntu sales 0 Mar  9 03:29 test_file
```

Adding group execute permissions.
```
ubuntu@ubuntu-arm:~/permissions$ chmod g+x test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rw-rwxr-- 1 ubuntu sales 0 Mar  9 03:29 test_file
```

Adding others read, write, and execute permissions.
```
ubuntu@ubuntu-arm:~/permissions$ chmod o+rwx test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rw-rwxrwx 1 ubuntu sales 0 Mar  9 03:29 test_file
```

Substracting write and execute permissions from group and others.
```
ubuntu@ubuntu-arm:~/permissions$ chmod og-wx test_file
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rw-r--r-- 1 ubuntu sales 0 Mar  9 03:29 test_file
```

It is more common to use `chmod` with numeric permissions (commonly referred to as **octal**). instead of the syntax used above. You can represent all permissions with just three numbers. With practice, you'll find it a lot easier to use.

The syntax is `chmod ugo`.
* `u` is the user permissions
* `g` is the group permissions
* `o` is the others permissions

You calculate `u`, `g`, and `o` by adding together three numbers:
* **4** for read
* **2** for write
* **1** for execute

`rwx` is 4 + 2 + 1 = 7

`rw-` is 4 + 2 = 6

`r-x` is 4 + 1 = 5

And so on. Here's a few examples.
```
ubuntu@ubuntu-arm:~/permissions$ chmod 777 test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rwxrwxrwx 1 ubuntu sales 0 Mar  9 03:29 test_file

ubuntu@ubuntu-arm:~/permissions$ chmod 000 test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
---------- 1 ubuntu sales 0 Mar  9 03:29 test_file

ubuntu@ubuntu-arm:~/permissions$ chmod 444 test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-r--r--r-- 1 ubuntu sales 0 Mar  9 03:29 test_file

ubuntu@ubuntu-arm:~/permissions$ chmod 764 test_file 
ubuntu@ubuntu-arm:~/permissions$ ls -la test_file 
-rwxrw-r-- 1 ubuntu sales 0 Mar  9 03:29 test_file
```

### Links
Links are similar to shortcuts. They allow you to reference a file from another place in the filesystem. 

There are two types of links: **hard** links and **soft** links:
* **Hard links** point directly to inodes, and inodes point to  locations in storage. When you run `touch cats`, you are creating a file `cats` that is a hard link to a specific inode responsible for holding metadata and pointing to storage locations. 
* **Soft links** don't point directly to inodes. Rather, they point toward a file (like `cats`), which is often itself a hard link.

```
 ________           _________          _________________
|   HL   |         |         |        |                 |
|  cats  |  -----> |  inode  | -----> |  data location  |     
|________|         |_________|        |_________________|

 ________           ________           _________          _________________
|   SL   |         |   HL   |         |         |        |                 |
|  cats  |  -----> |  cats  |  -----> |  inode  | -----> |  data location  |     
|________|         |________|         |_________|        |_________________|

```

You can create new hard links with `ln`, or soft link with `ln -s`.
```
ubuntu@ubuntu-arm:~/links$ mkdir link
ubuntu@ubuntu-arm:~/links$ echo "I am a linked file!" >> link/linked
ubuntu@ubuntu-arm:~/links$ ln link/linked hard_link
ubuntu@ubuntu-arm:~/links$ ln -s link/linked soft_link

ubuntu@ubuntu-arm:~/links$ ls -la
total 16
drwxrwxr-x  3 ubuntu ubuntu 4096 Mar  9 04:52 .
drwxr-xr-x 14 ubuntu ubuntu 4096 Mar  9 04:51 ..
-rw-rw-r--  2 ubuntu ubuntu   20 Mar  9 04:52 hard_link
drwxrwxr-x  2 ubuntu ubuntu 4096 Mar  9 04:52 link
lrwxrwxrwx  1 ubuntu ubuntu   11 Mar  9 04:52 soft_link -> link/linked
```

`ln -l` represented softlinks with arrows to the files they link to. Hard links appear the same as normal files.

```
ubuntu@ubuntu-arm:~/links$ cat link/linked 
I am a linked file!

ubuntu@ubuntu-arm:~/links$ cat hard_link 
I am a linked file!

ubuntu@ubuntu-arm:~/links$ cat soft_link 
I am a linked file!
```

If we run `ls -li` (`i` for inodes), we can see that hard_link and link/linked have the same inode number, but soft link does not.

```
ubuntu@ubuntu-arm:~/links$ ls -li hard_link soft_link link/linked 
283769 -rw-rw-r-- 2 ubuntu ubuntu 20 Mar  9 04:52 hard_link
283769 -rw-rw-r-- 2 ubuntu ubuntu 20 Mar  9 04:52 link/linked
283770 lrwxrwxrwx 1 ubuntu ubuntu 11 Mar  9 04:52 soft_link -> link/linked
```

What happens if we delete the original file?
```
ubuntu@ubuntu-arm:~/links$ rm link/linked 
ubuntu@ubuntu-arm:~/links$ cat hard_link 
I am a linked file!

ubuntu@ubuntu-arm:~/links$ cat soft_link 
cat: soft_link: No such file or directory
```
The hard link still works! That's because it's pointing to the same inode, and that inode still exists because it has at least one link. However, the soft link fails because it was pointing to the file (link/linked) that we deleted.

Note that soft links can be a security concern. If the target of the link is changed, we might be opening something we don't expect.
```
ubuntu@ubuntu-arm:~/links$ echo "malicious code. very bad stuff." >> link/linked
ubuntu@ubuntu-arm:~/links$ cat hard_link 
I am a linked file!

ubuntu@ubuntu-arm:~/links$ cat soft_link 
malicious code. very bad stuff.
```

### Compression
*Following along? Mise-in-place! Consider running `sudo dnf install tar bzip2 wget` if using RHEL.*

Tarballs aren't just what my Aunt Phyllis has in her heart where love and warmth are supposed to be. They're also a Linux thing!

A tarball is a group of files combined into one. It may be uncompressed or compressed. 
Usually we want to compress files. You'll commonly see tar files compressed with one of three algorithms.

| Name  | Filename Extension | Short Extension | Flag |
| ----- | ------------------ | --------------- | ---- |
| gzip  | .tar.gz            | .tgz            | `-z` |
| bzip2 | .tar.bz2           | .tbz            | `-j` |
|  xz   | .tar.xz            | .txz            | `-J` |

Lets try all three with some beefy classics.
```
wget https://raw.githubusercontent.com/GITenberg/Don-Quixote_996/master/old/1donq10.txt
wget https://raw.githubusercontent.com/mmcky/nyu-econ-370/master/notebooks/data/book-war-and-peace.txt

[shane@rhelly ~]$ du -h *.txt
2.3M	1donq10.txt
3.1M	book-war-and-peace.txt

[shane@rhelly ~]$ tar -cvzf books.tgz *.txt
[shane@rhelly ~]$ 
[shane@rhelly ~]$ tar -cvjf books.tbz *.txt
[shane@rhelly ~]$ tar -cvJf books.txz *.txt
[shane@rhelly ~]$ 
[shane@rhelly ~]$ du -h books*
1.5M	books.tbz
2.0M	books.tgz
1.5M	books.txz

```

bzip2 and xz tend to compress files more than gzip. 

| Compression | Size  |
| ----------- | ----- |
|    none     | 5.4MB |
|    gzip     | 2.0MB |
|    bzip2    | 1.5M  |
|    xz       | 1.5M  |

 
### File System Structure
*Following along? Mise-en-place! `sudo apt install tree` or `sudo dnf install tree`*
Though there are variations in how distributions arrange their filesystems, they have many commonalities.
```
tree -L 1 /
/
├── bin -> usr/bin
├── boot
├── cdrom
├── dev
├── etc
├── home
├── lib -> usr/lib
├── lib32 -> usr/lib32
├── lib64 -> usr/lib64
├── libx32 -> usr/libx32
├── lost+found
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin -> usr/sbin
├── snap
├── srv
├── swap.img
├── sys
├── tmp
├── usr 
└── var
```
The following is a *general* description of the common subdirectories of root. In practice, users, developers, and distribution vendors don't follow these definitions universally.

| Directory | Purpose |
| --------- | ------- |
|   bin     | general binares |
|   boot    | contains boot partition, configurations, bootloader, etc. |
|   dev     | contains files which represent system devices |
|   etc     | configuration files |
|   home    | user home directories |
|   lib*    | libraries |
|   lost+found | place to put corrupted/damaged files that'd otherwise be lost|
|   media | removable media mounted here | 
|   mnt   | commonly used for manually mounted devices |
|   opt   |  optional, add-on packages |
|   proc  | contains files which represent system processes |
|   root  | root user's home directory |
|   run   | holds runtime data for programs involved in early boot |
|   sbin  | binaries for superusers (administrators) | 
|   usr   | holds the bulk of installed items |
|   var   | holds variable files (files commonly written to) |

### Formatting Partitions and Mounting

Power down the VM of your choice and attach 3 or more empty virtual disks to it. These should be recognized by Linux on boot and reflected in the output of `lsblk`.

```
[shane@rhelly ~]$ lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda             8:0    0   16G  0 disk 
├─sda1          8:1    0    1G  0 part /boot
└─sda2          8:2    0   13G  0 part 
  ├─rhel-root 253:0    0 11.4G  0 lvm  /
  └─rhel-swap 253:1    0  1.6G  0 lvm  [SWAP]
sdb             8:16   0    8G  0 disk 
sdc             8:32   0    8G  0 disk 
sdd             8:48   0    8G  0 disk 
sde             8:64   0    8G  0 disk 
sdf             8:80   0    8G  0 disk 
```

Let's begin by using `fdisk` to partition `sdb` into two halves.
```
[shane@rhelly ~]$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x67418a7d.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-16777215, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-16777215, default 16777215): +4096MB

Created a new partition 1 of type 'Linux' and of size 3.8 GiB.

Command (m for help): p
---snip---

Device     Boot Start     End Sectors  Size Id Type
/dev/sdb1        2048 8001535 7999488  3.8G 83 Linux
```

And partition 2...
```
Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (8001536-16777215, default 8001536): 8001536
Last sector, +sectors or +size{K,M,G,T,P} (8001536-16777215, default 16777215): 

Created a new partition 2 of type 'Linux' and of size 4.2 GiB.

Command (m for help): p
---snip---

Device     Boot   Start      End Sectors  Size Id Type
/dev/sdb1          2048  8001535 7999488  3.8G 83 Linux
/dev/sdb2       8001536 16777215 8775680  4.2G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
``` 

Now, let's do the same process with `parted` and `sdc`.
```
[shane@rhelly ~]$ sudo parted /dev/sdc
GNU Parted 3.2
Using /dev/sdc
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel msdos
(parted) mkpart primary                                                   
File system type?  [ext2]? ext4                                           
Start? 0%                                                                 
End? 4000MB                                                               
(parted) mkpart primary                                                   
File system type?  [ext2]? ext4                                           
Start? 4000MB                                                             
End? 100%                                                                 
(parted) print                                                            
---snip---

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  4000MB  3999MB  primary  ext4         lba
 2      4000MB  8590MB  4590MB  primary  ext4         lba
(parted) align-check                                                      
alignment type(min/opt)  [optimal]/minimal?                               
Partition number? 1                                                       
1 aligned
(parted) align-check                                                      
alignment type(min/opt)  [optimal]/minimal?                               
Partition number? 2                                                       
2 aligned
parted) quit                                                             
Information: You may need to update /etc/fstab.
[shane@rhelly ~]$ sudo partprobe
```

And of course `gdisk` and `sdd`.
```
[shane@rhelly ~]$ sudo gdisk /dev/sdd
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): o
This option deletes all partitions and creates a new protective MBR.
Proceed? (Y/N): Y

Command (? for help): n
Partition number (1-128, default 1): 
First sector (34-16777182, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-16777182, default = 16777182) or {+-}size{KMGTP}: +4000M
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300):

Changed type of partition to 'Linux filesystem'

Command (? for help): n       
Partition number (2-128, default 2): 
First sector (34-16777182, default = 8194048) or {+-}size{KMGTP}: 
Last sector (8194048-16777182, default = 16777182) or {+-}size{KMGTP}: 
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 

Changed type of partition to 'Linux filesystem'

Command (? for help): p
Disk /dev/sdd: 16777216 sectors, 8.0 GiB
---snip---

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         8194047   3.9 GiB     8300  Linux filesystem
   2         8194048        16777182   4.1 GiB     8300  Linux filesystem

Command (? for help): v

No problems found. 2014 free sectors (1007.0 KiB) available in 1
segments, the largest of which is 2014 (1007.0 KiB) in size.

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdd.
The operation has completed successfully.

[shane@rhelly ~]$ sudo partprobe --summary /dev/sd{b,c,d}
/dev/sdb: msdos partitions 1 2
/dev/sdc: msdos partitions 1 2
/dev/sdd: gpt partitions 1 2
```

Formatting the partitions is a joy relative to the actual partitioning.
```
[shane@rhelly ~]$ sudo mkfs.ext4 -L tokyo /dev/sdb1
[shane@rhelly ~]$ sudo mkfs.ext4 -L hongkong /dev/sdb2
[shane@rhelly ~]$ sudo mkfs.xfs -L newyork /dev/sdc1
[shane@rhelly ~]$ sudo mkfs.xfs -L seattle /dev/sdc2
```

The `lsblk -o name,UUID,label /dev/sd{b,c}` command lists our new filesystems' assigned named, UUIDs, and labels.
We can use any of those 3 identifiers in `fstab` to references them.

```
[shane@rhelly ~]$ lsblk -o name,UUID,label /dev/sd{b,c}
NAME   UUID                                 LABEL
sdb                                         
├─sdb1 3fa95d6e-93a7-4a40-acbe-4476ce2fc986 tokyo
└─sdb2 1c554a3c-efd3-415a-ba8f-f008b297513f hongkong
sdc                                         
├─sdc1 d9911924-acb7-4818-a964-c03a474c15c6 newyork
└─sdc2 029c74c4-18ee-49ed-87bc-e883fd407fac seattle
```

Let's create three mountpoints via `fstab`and mount the filesystems using these three types of identifier. We'll save the seattle partition to demonstrate mount options.
```
[shane@rhelly ~]$ sudo mkdir /mnt/{tokyo,hongkong,newyork}
[shane@rhelly ~]$ sudo su
[root@rhelly shane]# echo "UUID=$(lsblk -n -o UUID /dev/sdb1)   /mnt/tokyo    ext4   defaults 0 0" >> /etc/fstab
[root@rhelly shane]# echo "LABEL=$(lsblk -n -o LABEL /dev/sdb2)   /mnt/hongkong   ext4   defaults 0 0" >> /etc/fstab 
[root@rhelly shane]# echo "/dev/sdc1    /mnt/newyork    xfs    defaults 0 0" >> /etx/fstab
[root@rhelly shane]# exit
[shane@rhelly ~]$ sudo systemctl daemon-reload

[shane@rhelly ~]$ sudo mount -a
[shane@rhelly ~]$ sudo mount | tail -n 3
/dev/sdb1 on /mnt/tokyo type ext4 (rw,relatime,seclabel)
/dev/sdb2 on /mnt/hongkong type ext4 (rw,relatime,seclabel)
/dev/sdc1 on /mnt/newyork type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)
```

Make a directory to mount seattle to. Mount it, and change the ownership to your user. Then, make an executable script and a text document. When done, unmount the filesystem.
```
[shane@rhelly ~]$ mkdir seattle
[shane@rhelly ~]$ sudo mount LABEL=seattle seattle/
[shane@rhelly ~]$ sudo chown -R shane:shane seattle/
[shane@rhelly ~]$ cd seattle/
[shane@rhelly seattle]$ cat <<EOF > execute_me.sh
#!/bin/bash
echo "I am shell script."
EOF
[shane@rhelly seattle]$ chmod u+x execute_me.sh 
[shane@rhelly seattle]$ echo "I am a text document." > edit_me.txt
[shane@rhelly seattle]$ cd ..
[shane@rhelly ~]$ sudo umount seattle/
```

Remount the filesystem with the `readonly` and `noexec` options. Notice that, according to the filesystem permissions, you should be able to edit and execute these files.
```
[shane@rhelly ~]$ sudo mount -o ro,noexec LABEL=seattle seattle/
[shane@rhelly ~]$ cd seattle/
[shane@rhelly seattle]$ ls -l
total 8
-rw-rw-r--. 1 shane shane 22 Mar  4 16:41 edit_me.txt
-rwxrw-r--. 1 shane shane 38 Mar  4 16:39 execute_me.sh

[shane@rhelly seattle]$ echo "can I edit this?" >> edit_me.txt 
-bash: edit_me.txt: Read-only file system
[shane@rhelly seattle]$ ./execute_me.sh
-bash: ./execute_me.sh: Permission denied
```

No dice! But surely root can. Right?
```
[shane@rhelly seattle]$ sudo su
[root@rhelly seattle]# echo "can root edit this?" >> edit_me.txt 
bash: edit_me.txt: Read-only file system
[root@rhelly seattle]# ./execute_me.sh
bash: ./execute_me.sh: Permission denied
[root@rhelly seattle]# exit
```

### Swap Space

Swap space can be allocated using partitions or files. We'll take use the latter option to demonstrate a quick-n-easy way to add swap space.

```
[shane@rhelly ~]$ sudo dd if=/dev/zero of=/swappyboi bs=1M count=512
[shane@rhelly ~]$ sudo chmod 0600 /swappyboi 
[shane@rhelly ~]$ sudo mkswap /swappyboi 
Setting up swapspace version 1, size = 512 MiB (536866816 bytes)
no label, UUID=c2e0bef9-4eb2-46dd-a9b4-ca76f7b8a40
[shane@rhelly ~]$ sudo swapon /swappyboi
```

### LVM

Let's spin up some LVM storage from scratch. You'll need two free drives (I'm using `sde` and `sdf`).

First, turn `/dev/sde` into a physical volume with `pvcreate`.
```
[shane@rhelly ~]$ sudo pvcreate /dev/sde

[shane@rhelly ~]$ sudo pvs /dev/sde
  PV         VG      Fmt  Attr PSize   PFree
  /dev/sde   demo_vg lvm2 a--   <8.00g    0
```

Next, create a new volume group with `vgcreate`.
```
[shane@rhelly ~]$ sudo vgcreate demo_vg /dev/sde
  Volume group "demo_vg" successfully created

[shane@rhelly ~]$ sudo vgs demo_vg
  VG      #PV #LV #SN Attr   VSize  VFree
  demo_vg   1   2   0 wz--n- <8.00g    0 
```

We'll use the volume group to store two logical volumes. They are defined using `lvcreate`.
```
[shane@rhelly ~]$ sudo lvcreate -L +5G --name Stuff1 demo_vg
  Logical volume "Stuff1" created.
[shane@rhelly ~]$ sudo lvcreate -l 100%FREE --name Stuff2 demo_vg
  Logical volume "Stuff2" created. 

[shane@rhelly ~]$ sudo lvs demo_vg
  LV     VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  Stuff1 demo_vg -wi-a-----  5.00g                                                    
  Stuff2 demo_vg -wi-a----- <3.00g    
```

Format the partitions with your favorite filesystem. 
```
sudo mkfs.ext4 /dev/demo_vg/Stuff1 -L Stuff1
sudo mkfs.ext4 /dev/demo_vg/Stuff2 -L Stuff2

[shane@rhelly ~]$ lsblk /dev/sde
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sde               8:64   0    8G  0 disk 
├─demo_vg-Stuff1 253:2    0    5G  0 lvm  
└─demo_vg-Stuff2 253:3    0    3G  0 lvm  
```
At this point, you can mount the logical volumes if you prefer. Once you're done playing with your new filesystems, we will extend the volume group, logical volumes, and filesytems.

Create a new physical volume and add to the existing volume group.
```
[shane@rhelly ~]$ sudo pvcreate /dev/sdf 
  Physical volume "/dev/sdf" successfully created.
[shane@rhelly ~]$ sudo vgextend demo_vg /dev/sdf
  Volume group "demo_vg" successfully extended
```

Now we can extend the logical volumes.
```
[shane@rhelly ~]$ sudo lvextend -L +4G /dev/demo_vg/Stuff1
  Size of logical volume demo_vg/Stuff1 changed from 5.00 GiB (1280 extents) to 9.00 GiB (2304 extents).
  Logical volume demo_vg/Stuff1 successfully resized.
[shane@rhelly ~]$ sudo lvextend -L +3G /dev/demo_vg/Stuff2
  Size of logical volume demo_vg/Stuff2 changed from <3.00 GiB (767 extents) to <6.00 GiB (1535 extents).
  Logical volume demo_vg/Stuff2 successfully resized.
```

And finally, the filesystem themselves.
```
[shane@rhelly ~]$ sudo resize2fs /dev/demo_vg/Stuff1 
resize2fs 1.45.6 (20-Mar-2020)
Resizing the filesystem on /dev/demo_vg/Stuff1 to 2359296 (4k) blocks.
The filesystem on /dev/demo_vg/Stuff1 is now 2359296 (4k) blocks long.

[shane@rhelly ~]$ sudo resize2fs /dev/demo_vg/Stuff2
resize2fs 1.45.6 (20-Mar-2020)
Resizing the filesystem on /dev/demo_vg/Stuff2 to 1571840 (4k) blocks.
The filesystem on /dev/demo_vg/Stuff2 is now 1571840 (4k) blocks long.

[shane@rhelly ~]$ lsblk /dev/sd{e,f}
NAME             MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sde                8:64   0   8G  0 disk 
├─demo_vg-Stuff1 253:2    0   9G  0 lvm  
└─demo_vg-Stuff2 253:3    0   6G  0 lvm  
sdf                8:80   0   8G  0 disk 
├─demo_vg-Stuff1 253:2    0   9G  0 lvm  
└─demo_vg-Stuff2 253:3    0   6G  0 lvm 
```

### Quotas
On multi-user systems, you may need to implement quotas to ensure that any single user or group can't consume more than their fair share of disk capacity. 

There are two types of quotas: *user* quotas and *group* quotas. To use quotas, you should first make sure that the `quota` package is installed.

```
shane@ubuuuntu:~$ which quota
/usr/bin/quota
```

Through VirtualBox (or your hypervisor of choice), add two new virtual disks to your system. In this example, we're using `/dev/sdb` and `/dev/sdc`. We need to do the usual partitioning rigmarole.

```
shane@ubuuuntu:~$ sudo gdisk /dev/sdb
GPT fdisk (gdisk) version 1.0.5

---snip---

Command (? for help): o
This option deletes all partitions and creates a new protective MBR.
Proceed? (Y/N): Y

Command (? for help): n
Partition number (1-128, default 1): 
First sector (34-20971486, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-20971486, default = 20971486) or {+-}size{KMGTP}: 
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdb.
The operation has completed successfully.

shane@ubuuuntu:~$ sudo gdisk /dev/sdc
GPT fdisk (gdisk) version 1.0.5

---snip---

Command (? for help): o
This option deletes all partitions and creates a new protective MBR.
Proceed? (Y/N): Y

Command (? for help): n
Partition number (1-128, default 1): 
First sector (34-20971486, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-20971486, default = 20971486) or {+-}size{KMGTP}: 
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdc.
The operation has completed successfully.
shane@ubuuuntu:~$ 
```

Now we'll format them with `ext4`.
```
shane@ubuuuntu:~$ sudo mkfs.ext4 /dev/sdb1
---snip---
Writing superblocks and filesystem accounting information: done 

shane@ubuuuntu:~$ sudo mkfs.ext4 /dev/sdc1
---snip---
Writing superblocks and filesystem accounting information: done 
```

Let's create the mount points in `/mnt`.
```
shane@ubuuuntu:~$ sudo mkdir /mnt/usr_quota_demo
shane@ubuuuntu:~$ sudo mkdir /mnt/grp_quota_demo
```

To echo the entries into `/etc/fstab`, we need to drop into root momentarily. The `$(lsblk -n -o UUID ...)` command outputs (`-o`) the UUID of the disk without headings (`-n`). 

**Make sure you use the append redirector (`>>`)!**
```
shane@ubuuuntu:~$ sudo su
root@ubuuuntu:/home/shane# echo "UUID=$(lsblk -n -o UUID /dev/sdb1)   /mnt/usr_quota_demo  ext4  defaults,usrquota 0 0" >> /etc/fstab 
root@ubuuuntu:/home/shane# echo "UUID=$(lsblk -n -o UUID /dev/sdc1)   /mnt/grp_quota_demo  ext4  defaults,grpquota 0 0" >> /etc/fstab
root@ubuuuntu:/home/shane# exit
exit
shane@ubuuuntu:~$ lsblk
---snip---
sdb                         8:16   0   10G  0 disk 
└─sdb1                      8:17   0   10G  0 part /mnt/usr_quota_demo
sdc                         8:32   0   10G  0 disk 
└─sdc1                      8:33   0   10G  0 part /mnt/grp_quota_demo
```

Create a `storageusers` group for your user, and change the group ownership of both mounts to it. Also, make sure that group has write permissions.
```
shane@ubuuuntu:~$ sudo groupadd storageusers
shane@ubuuuntu:~$ sudo usermod -aG storageusers shane

shane@ubuuuntu:~$ sudo chgrp -R storageusers /mnt/usr_quota_demo /mnt/grp_quota_demox
shane@ubuuuntu:~$ sudo chmod 771 /mnt/usr_quota_demo /mnt/grp_quota_demo

```
Now we can use the `quotacheck` command to enable user or group quotas (or both with `-cugm`). If you attempt to enable a quota type that isn't specified in the mount options, it will display an error.
```
shane@ubuuuntu:~$ sudo quotacheck -cum /mnt/usr_quota_demo
shane@ubuuuntu:~$ sudo quotacheck -cgm /mnt/grp_quota_demo

shane@ubuuuntu:~$ sudo quotacheck -cgm /mnt/usr_quota_demo
quotacheck: Cannot find filesystem to check or filesystem not mounted with quota option.
```

The `quotaon` command will actually turn quotas on.
```
shane@ubuuuntu:~$ sudo quotaon -v /mnt/usr_quota_demo
/dev/sdb1 [/mnt/usr_quota_demo]: user quotas turned on
shane@ubuuuntu:~$ sudo quotaon -v /mnt/grp_quota_demo
/dev/sdc1 [/mnt/grp_quota_demo]: group quotas turned on
```

You can edit a user quota with the `edquota -u` command. Here, I set the hard limit on blocks to 65536, and inodes to 49152.

*On my system (and many systems), the block size is 4096 bytes. The hard limit of 65536 translates to 65536 * 4096 bytes, or 268435456 bytes. Divide it by 1024 once to get the kilobytes, or twice to get the megabytes. That's 262,144KB, or 256MB.*

The inodes hard limit functions as a limit on the total number of files.
```
shane@ubuuuntu:~$ sudo edquota -u shane
Disk quotas for user shane (uid 1000):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/sdb1                         0          0      65536          0        0    49152
```

Note: *don't edit the blocks or inodes columns, as they are dynamically updated.*

Now lets put some files in the new filesystem and monitor the quota.
```
shane@ubuuuntu:~$ echo "this little text file 'o mine" >> /mnt/usr_quota_demo/shane.txt
shane@ubuuuntu:~$ dd if=/dev/zero of=/mnt/usr_quota_demo/shane_zeroes_16MB bs=1M count=16
```

Running `edquota` again show the updated block and inode utilization for the user. Alternatively, we can use the `repquota -au` command.
```
shane@ubuuuntu:~$ sudo edquota -u shane
Disk quotas for user shane (uid 1000):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/sdb1                     16388          0      65536          2        0    49152

shane@ubuuuntu:~$ sudo repquota -au
*** Report for user quotas on device /dev/sdb1
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
shane     --   16388       0   65536              2     0 49152       
```
It's good idea to set a lower soft limit, because it can generate a warning and allow the user to rectify the situation within the configured gracetime. Let's set a low soft limit on inodes, exceed it, and check the quota report.

```
shane@ubuuuntu:~$ sudo edquota -u shane
Disk quotas for user shane (uid 1000):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/sdb1                     16388          0      65536          2        12    49152

shane@ubuuuntu:~$ sudo edquota -ut
Grace period before enforcing soft limits for users:
Time units may be: days, hours, minutes, or seconds
  Filesystem             Block grace period     Inode grace period
  /dev/sdb1                     7days                  7days

shane@ubuuuntu:~$ for i in {1..16}; do touch /mnt/usr_quota_demo/soft_$i; done

shane@ubuuuntu:~$ sudo repquota -au
*** Report for user quotas on device /dev/sdb1
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
shane     -+   16388       0   65536             18    12 49152  6days
```

Note: *you'll also want to configure `/etc/warnquoata.conf` to inform users if they exceeed their soft quotas.*

Groups quotas work in a similar way, the main difference is substituting a `u` with a `g` in the relevant commands. Let's implement a draconian inode limit and then exceed it.

We'll then use a `for` loop to create files until the inode limit is reached. 

Note the `sg storageusers "command"` construct. This will create files using the storageusers group. The default is to use the user's primary group (in this case, it would be "shane", and we haven't set quotas for it).
```
shane@ubuuuntu:~$ sudo edquota -g storageusers
Disk quotas for group storageusers (gid 1001):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/sdc1                        20          0          0          2        0       12

shane@ubuuuntu:~$ for i in {1..12}; do sg storageusers "touch /mnt/grp_quota_demo/hrd_$i"; done
touch: cannot touch '/mnt/grp_quota_demo/11': Disk quota exceeded
touch: cannot touch '/mnt/grp_quota_demo/12': Disk quota exceeded

*** Report for group quotas on device /dev/sdc1
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
Group           used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
storageusers --  20       0       0             12     0    12  
```

## String Processing
Linux configuration files are primarily plaintext, so developing your skill with string processing utilities will make you a more efficient administrator.
### sort
`sort` does exactly what it sounds like. It sorts text. By default, it sorts alphabetically:
```
ubuntu@ubuntu-arm:~$ cat <<EOF >cats.txt
> lily
> hulk
> aurora
> harry
> kirby
> kimmy
> calypso
> midnight
> EOF
ubuntu@ubuntu-arm:~$ sort cats.txt 
aurora
calypso
harry
hulk
kimmy
kirby
lily
midnight
```

It can also sort numerically with the `-n` option, and in reverse with the `-r` option.
```
ubuntu@ubuntu-arm:~$ cat <<EOF >favorite_numbers.txt
> 42
> 1337
> 636
> 31415
> 112358
> 777
> EOF
ubuntu@ubuntu-arm:~$ sort -nr favorite_numbers.txt 
112358
31415
1337
777
636
42
ubuntu@ubuntu-arm:~$ 

```
### cut
`cut` is useful for selecting columns from delineated lists. Specify the delineator with `-d` and fields with `-f`.

The following command gives a list of users and their shells.
```
ubuntu@ubuntu-arm:~$ cut -d":" -f 1,7 /etc/passwd
root:/bin/bash
daemon:/usr/sbin/nologin
bin:/usr/sbin/nologin
sys:/usr/sbin/nologin
---snip---
ubuntu:/bin/bash
lxd:/bin/false
tftp:/usr/sbin/nologin
shane:/bin/bash
```
### tr
`tr` is used to "translate" between sets of characters. It can be useful for situations that require specific text formatting.
```
ubuntu@ubuntu-arm:~$ echo "can i buy a vowel?" | tr "aeiou" "_"
c_n _ b_y _ v_w_l?

ubuntu@ubuntu-arm:~$ echo "capitalize me please" | tr [:lower:] [:upper:]
CAPITALIZE ME PLEASE
```

If you're ever working on a text document created in Windows, it may have ugly carriages returns that look like `^M`. You can use `tr` to purge them. The `-d` option performs a delete instead of substitution.
```
cat windows.txt | tr -d '\r' > windows_cleaned.txt
```

Want a useless skill? You can implement ROT13 encryption with `tr`. 

```
ubuntu@ubuntu-arm:~$ cat plaintext 
ROT13 works by moving each character of the alphabet forward by 13 characters. 
A becomes N, B becomes O, and so on.
Since there are 26 characters in the alphabet, applying ROT13 twice returns the plaintext.
The encryption and decryption operations are identical.

ubuntu@ubuntu-arm:~$ cat plaintext | tr 'A-Za-z' 'N-ZA-Mn-za-m' | tee rot13_ciphertext 
EBG13 jbexf ol zbivat rnpu punenpgre bs gur nycunorg sbejneq ol 13 punenpgref.
N orpbzrf A, O orpbzrf B, naq fb ba.
Fvapr gurer ner 26 punenpgref va gur nycunorg, nccylvat EBG13 gjvpr ergheaf gur cynvagrkg.
Gur rapelcgvba naq qrpelcgvba bcrengvbaf ner vqragvpny.

ubuntu@ubuntu-arm:~$ cat rot13_ciphertext | tr 'A-Za-z' 'N-ZA-Mn-za-m'
ROT13 works by moving each character of the alphabet forward by 13 characters. 
A becomes N, B becomes O, and so on.
Since there are 26 characters in the alphabet, applying ROT13 twice returns the plaintext.
The encryption and decryption operations are identical.
```

### grep
`grep` is used to search for patterns of text. It uses a robust pattern-matching syntax called regular expressions or "regex". The best way to learn regex is through repeated failure. 

Common `grep` options are:
* `-o` to only print matches (instead of the entire line with the match)
* `-i` to ignore case
* `-v` to invert the match (only print non-matches)

Let's look at progressively more advanced examples, starting without regular expressions.

**Basic grep**

Here's the text file.
```
ubuntu@ubuntu-arm:~$ cat grep.txt 
In Xanadu did Kubla Khan
A stately pleasure-dome decree:
Where Alph, the sacred river, ran
Through caverns measureless to man
   Down to a sunless sea.
```

All lines with "Xanadu".
```
ubuntu@ubuntu-arm:~$ grep "Xanadu" grep.txt 
In Xanadu did Kubla Khan
```

Only strings exactly matching "Xanadu".
```
ubuntu@ubuntu-arm:~$ grep -o "Xanadu" grep.txt 
Xanadu
```

Only strings exactly matching "I".
```
ubuntu@ubuntu-arm:~$ grep -o "I" grep.txt 
I
```

Only strings matching "I" (case-insensitive).
```
ubuntu@ubuntu-arm:~$ grep -oi "I" grep.txt 
I
i
i
```

Only lines without "measureless".
```
ubuntu@ubuntu-arm:~$ grep -v "measureless" grep.txt 
In Xanadu did Kubla Khan
A stately pleasure-dome decree:
Where Alph, the sacred river, ran
   Down to a sunless sea.
```
**Basic grep with regex**

Four key regex are:
* `^` beginning-of-line anchor
* `$` end-of-line anchor
* `.` matches any character
* `*` matches any number of the previous character

Here's the text again.
```
ubuntu@ubuntu-arm:~$ cat grep.txt 
In Xanadu did Kubla Khan
A stately pleasure-dome decree:
Where Alph, the sacred river, ran
Through caverns measureless to man
   Down to a sunless sea.
```

All lines beginning with "A".
```
ubuntu@ubuntu-arm:~$ grep "^A" grep.txt 
A stately pleasure-dome decree:
```

All lines ending with "n".
```
ubuntu@ubuntu-arm:~$ grep "n$" grep.txt 
In Xanadu did Kubla Khan
Where Alph, the sacred river, ran
Through caverns measureless to man
```

All lines ending in 3-letter words ending in "an".
```
ubuntu@ubuntu-arm:~$ grep " .an$" grep.txt 
Where Alph, the sacred river, ran
Through caverns measureless to man
```

All strings that start with "X", followed by any 3 characters, and ending in "du".
```
ubuntu@ubuntu-arm:~$ grep "X...du " grep.txt 
In Xanadu did Kubla Khan
```

All strings that start with "X", followed by any number of characters, and ending in "du".
```
ubuntu@ubuntu-arm:~$ grep "X.*du " grep.txt 
In Xanadu did Kubla Khan
```

Any full line containing "Xanadu".
```
ubuntu@ubuntu-arm:~$ grep -o "^.*Xanadu.*$" grep.txt 
In Xanadu did Kubla Khan
```

To search for a special character (such as "."), you can escape it with a "\\".

All lines ending in "sea."
```
ubuntu@ubuntu-arm:~$ grep "sea\.$" grep.txt 
   Down to a sunless sea.
```
**Basic grep with more regex**

Here are four more regex operators that make life easier.

* `\w` matches word components (letters)
* `\b` matches the edge of a word (not including whitespace)
* `\s` matches whitespace
* `\{ and \}` can be used to quantify

The text.
```
ubuntu@ubuntu-arm:~$ cat grep.txt 
In Xanadu did Kubla Khan
A stately pleasure-dome decree:
Where Alph, the sacred river, ran
Through caverns measureless to man
   Down to a sunless sea.
```

Match any word ending in "ss."
```
ubuntu@ubuntu-arm:~$ grep "\w*ss" grep.txt 
Through caverns measureless to man
   Down to a sunless sea.
```

Match any line starting with whitespace.
```
ubuntu@ubuntu-arm:~$ grep "^\s" grep.txt 
   Down to a sunless sea.
```

Notice the difference between `\b` and `\s`. 

* `\b` acts as an anchor to the edge of a word, but is not included in the match.
* `\s` matches on the whitespace before and after "Kubla."
```
ubuntu@ubuntu-arm:~$ grep -o "\bKubla\b" grep.txt 
Kubla
ubuntu@ubuntu-arm:~$ grep -o "\sKubla\s" grep.txt 
 Kubla 
```

Match any word ending in two s's.
```
ubuntu@ubuntu-arm:~$ grep -o "\w*s\{2\}\b" grep.txt 
measureless
sunless
```

Match any word ending in either one or two s's.
```
ubuntu@ubuntu-arm:~$ grep -o "\w*s\{1,2\}\b" grep.txt 
caverns
measureless
sunless
```

### sed
`sed` is a stream editor. It can perform substitutions on text using robust regular expressions.

A common use of `sed` is to update configuration files.

An example of the syntax is `sed 's/dogs/cats/g'`. This will **s**ubstitute instances of the string "dogs" with "cats" **g**lobally.

```
echo "I can't wait to get my very own motorcycle" | sed 's/motorcycle/401k/g'
I can't wait to get my very own 401k
```
`sed` is very useful to update configuration files programmatically. However, think through your regex carefully. 

The first command below won't take effect because it doesn't remove the comment tag. 

The second command fixes this with `#\?`, which matches zero or one comment tags. But it's not perfect. For instance, it won't work if the port is already set to something other than 22.

The third command is what I use in my personal scripts.

```
ubuntu@ubuntu-arm:~$ sed "s/Port 22/Port 2222/g" /etc/ssh/sshd_config 

---snip---
#Port 2222
---snip---

ubuntu@ubuntu-arm:~$ sed "s/#\?Port 22/Port 2222/g" /etc/ssh/sshd_config

---snip---
Port 2222
---snip---

ubuntu@ubuntu-arm:~$ sed "s/^#\?Port\s\+[0-9]\{2,5\}$/Port 2222/g" /etc/ssh/sshd_config

---snip---
Port 2222
---snip---
```

The third command is complex, but far more targeted. It matches any port configuration entry but leaves comments alone. Reading it from left to right:
* `^#\?` line starting with zero or one comment tag
* `Port` ...the word "Port"
* `\s\+` one or more spaces
* `[0-9]\{2,5\}$` two to five digits ending the line

```
ubuntu@ubuntu-arm:~$ cat ssh_port_test.txt 
#Port 22
#Port  22
Port 22
Port  22
#Port 13555
#Port  1234
#Sometimes a comment might say #Port 22
# Sometimes a comment might say Port 22 too

ubuntu@ubuntu-arm:~$ sed "s/^#\?Port\s\+[0-9]\{2,5\}$/Port 2222/g" ssh_port_test.txt 
Port 2222
Port 2222
Port 2222
Port 2222
Port 2222
Port 2222
#Sometimes a comment might say #Port 22
# Sometimes a comment might say Port 22 too
```

By default, `sed` does not make changes to the document. If you like to live on the edge, the `-i` options turns on inline editing.

### awk
`awk` is a powerful command and a language unto itself. Rather than diving into that rabbit hole, let's look at a few examples of the `awk` command so that it isn't completely foreign to you.

The command `awk 'FS=":" {print $1,$7}' /etc/passwd` will print all accounts and their shells. It's components are:
* `FS=":"` - the field seperator, or delimiter, `awk` should use
* `{print $1, $7}` - print fields 1 and 7, which are the usernames and shells.
```
shane@ubuuuntu:~$ awk 'FS=":" {print $1,$7}' /etc/passwd
---snip---
sshd /usr/sbin/nologin
systemd-coredump /usr/sbin/nologin
shane /bin/bash
lxd /bin/false
```

Maybe we are only interested in this information for user accounts. User account IDs start at 1000 and are recorded in field 3 of `/etc/passwd`. Adding the statement `if ($3 > 999)` will only show records with UIDs greater than 999.

```
shane@ubuuuntu:~$ awk 'FS=":" {if ($3 > 999) print $1,$7}' /etc/passwd
nobody /usr/sbin/nologin
shane /bin/bash
```

However, the `nobody` user has a very high UID. We can limit the upper range of the user IDs to a sensible number.
```
shane@ubuuuntu:~$ awk 'FS=":" {if ($3 > 999 && $3 < 2000) print $1,$7}' /etc/passwd
shane /bin/bash
```

Let's add some users and retry it.
```
shane@ubuuuntu:~$ sudo useradd hulk
shane@ubuuuntu:~$ sudo useradd lily
shane@ubuuuntu:~$ sudo useradd aurora

shane@ubuuuntu:~$ awk 'FS=":" {if ($3 > 999 && $3 < 2000) print $1,$7}' /etc/passwd
shane /bin/bash
hulk /bin/sh
lily /bin/sh
aurora /bin/sh
```

## User and Group Administration
### Creating and Modifying Users
One command to add users to a system is creatively named `adduser`. It provides an interactive prompt for user creation.
```
shane@ubuuuntu:~$ sudo adduser midnight
Adding user `midnight' ...
Adding new group `midnight' (1005) ...
Adding new user `midnight' (1004) with group `midnight' ...
Creating home directory `/home/midnight' ...
Copying files from `/etc/skel' ...
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for midnight
Enter the new value, or press ENTER for the default
	Full Name []: Midnight
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: 
Is the information correct? [Y/n] Y
```

Another, lower-level command is `useradd`. Good luck not mixing these two commands up. In the command below, we are creating a user account for my childhood cat Kirby. We create a new user group with his name, a home directory, and also include him in the sudo group. For him to log in and use `sudo`, we also need to define a password. 
```
shane@ubuuuntu:~$ sudo useradd --home-dir /home/kirby --user-group --create-home --groups sudo kirby
shane@ubuuuntu:~$ sudo passwd kirby
New password: 
Retype new password: 
passwd: password updated successfully

shane@ubuuuntu:~$ sudo su - kirby
$ sudo ls
[sudo] password for kirby:
```

Kirby is almost there, but we might still need to make a few modifications. This is where `usermod` comes in handy. Let's update his shell to BASH, put him in a cats group, and add a comment.
```
shane@ubuuuntu:~$ sudo usermod --shell /bin/bash kirby

shane@ubuuuntu:~$ sudo groupadd cats
shane@ubuuuntu:~$ sudo usermod -aG cats kirby

shane@ubuuuntu:~$ sudo usermod --comment "feline obesity epidemic" kirby

shane@ubuuuntu:~$ tail -n 1 /etc/passwd
kirby:x:1005:1006:feline obesity epidemic:/home/kirby:/bin/bash

shane@ubuuuntu:~$ tail -n 2 /etc/group
kirby:x:1006:
cats:x:1007:kirby
```
User information is stored in `/etc/passwd`, and group information is stored in `/etc/group`. 

We can view Kirby's password expiration information with `chage -l kirby`. Also, it's a good practice to expire whatever password you define as the administrator, forcing the user to set their own.
```
shane@ubuuuntu:~$ sudo chage -l kirby
Last password change					: Mar 06, 2021
Password expires					: never
Password inactive					: never
Account expires						: never
Minimum number of days between password change		: 0
Maximum number of days between password change		: 99999
Number of days of warning before password expires	: 7


shane@ubuuuntu:~$ sudo chage -d 0 kirby

shane@ubuuuntu:~$ sudo su - kirby
You are required to change your password immediately (administrator enforced)
Changing password for kirby.
Current password: 
New password: 
Retype new password: 
kirby@ubuuuntu:~$ 
```
### User Scripts
Running `ls -la` in any user's home directory will probably yield a number of hidden files. These may include:
* `.profile` or `.bash_profile` - executed when you log on (e.g., with your username and password). May also call `.bashrc` automatically.
* `.bashrc` - executed for non-login interactive shells (e.g., opening a CLI while you're already logged in)
* `.bash_logout` - executed when you log out

Notice that adding `echo GOOD DAY TO YOU` to `.profile` causes the message to be printed when logging in via SSH, but not when opening a new BASH session.
```
ubuntu@ubuntu-arm:~$ echo "echo GOOD DAY TO YOU" >> .profile 
ubuntu@ubuntu-arm:~$ exit
logout
Connection to 10.0.1.71 closed.

shane@Shanes-MacBook-Pro ~ % ssh ubuntu@10.0.1.71
ubuntu@10.0.1.71's password: 

---snip---

GOOD DAY TO YOU
ubuntu@ubuntu-arm:~$ 
ubuntu@ubuntu-arm:~$ bash
ubuntu@ubuntu-arm:~$ exit
ubuntu@ubuntu-arm:~$ 
```

If we remove the `echo` statement from `.profile` and add it to `.bashrc` it gets a bit more obnoxious, and executes for any BASH shell, login or otherwise.
```
shane@Shanes-MacBook-Pro ~ % ssh ubuntu@10.0.1.71
ubuntu@10.0.1.71's password: 

---snip--- 

GOOD DAY TO YOU
ubuntu@ubuntu-arm:~$ bash
GOOD DAY TO YOU
```

We can use `.bashrc` to make our lives easier, such as by defining aliases. First, I'll remove the `echo` command, then add an alias. We can't use the alias immediately. We either need to log out and back in, or source `.bashrc` for the changes to take effect.

```
ubuntu@ubuntu-arm:~$ echo alias quick-apt='"sudo apt update -y && sudo apt upgrade -y"' >> .bashrc

ubuntu@ubuntu-arm:~$ quick-apt
quick_apt: command not found

ubuntu@ubuntu-arm:~$ source .bashrc 

ubuntu@ubuntu-arm:~$ quick_apt 
Hit:1 http://ports.ubuntu.com/ubuntu-ports focal InRelease
Get:2 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease [114 kB]
Get:3 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease [101 kB]
---snip---
```

You can view existing aliases using the `alias` command, or choose a specific alias to inspect.
```
ubuntu@ubuntu-arm:~$ alias
---snip---
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias quick-apt='sudo apt update -y && sudo apt upgrade -y'

ubuntu@ubuntu-arm:~$ alias quick-apt
alias quick-apt='sudo apt update -y && sudo apt upgrade -y'
```

If you want to make system-wide changes that apply to all users, you can do so in `/etc/profile`. For instance, lets have a cow quote Nietszche every time someone logs in.
```
ubuntu@ubuntu-arm:~$ sudo su
root@ubuntu-arm:/home/ubuntu# echo -e cowsay "'Whoever fights monsters should see to it that\nin the process he does not become a monster.\nAnd if you gaze long enough into an abyss,\nthe abyss will gaze back into you.'" >> /etc/profile
root@ubuntu-arm:/home/ubuntu# exit
ubuntu@ubuntu-arm:~$ exit

shane@Shanes-MacBook-Pro ~ % ssh ubuntu@10.0.1.71
ubuntu@10.0.1.71's password: 

---snip---
 ________________________________________
/ Whoever fights monsters should see to  \
| it that in the process he does not     |
| become a monster. And if you gaze long |
| enough into an abyss, the abyss will   |
\ gaze back into you.                    /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
ubuntu@ubuntu-arm:~$ 

```
Note: *echoing directly into files owned by root often fails unless you `sudo su` to drop directly into a root shell.*

### Managing Groups
Managing groups is relatively straightforward.

The `/etc/group` file contains group definitions and memberships.

```
ubuntu@ubuntu-arm:~$ cat /etc/group
root:x:0:
daemon:x:1:
---snip---
tftp:x:119:
shane:x:1001:
```
Groups can be created using the `groupadd` command, and members can be added to the group with the `usermod -aG` command.
```
ubuntu@ubuntu-arm:~$ sudo groupadd administrators
ubuntu@ubuntu-arm:~$ tail -n 1 /etc/group
administrators:x:1002:

ubuntu@ubuntu-arm:~$ sudo usermod -aG administrators shane
ubuntu@ubuntu-arm:~$ tail -n 1 /etc/group
administrators:x:1002:shane
```
You can quickly determine an individual's group memberships using `groups` or `id`.
```
ubuntu@ubuntu-arm:~$ groups shane
shane : shane sudo administrators

ubuntu@ubuntu-arm:~$ id shane
uid=1001(shane) gid=1001(shane) groups=1001(shane),27(sudo),1002(administrators)
```

To remove a group from a user's account, use `gpasswd -d`.
```
ubuntu@ubuntu-arm:~$ sudo gpasswd -d shane administrators
Removing user shane from group administrators

ubuntu@ubuntu-arm:~$ groups shane
shane : shane sudo
ubuntu@ubuntu-arm:~$ id shane
uid=1001(shane) gid=1001(shane) groups=1001(shane),27(sudo)
```

To delete a group, use the `groupdel` command.
```
ubuntu@ubuntu-arm:~$ sudo groupdel administrators
ubuntu@ubuntu-arm:~$ cat /etc/group | grep "^administrators"
ubuntu@ubuntu-arm:~$
```

### Passwords
Account passwords used to be stored in `/etc/passwd`, but that is no longer the case. Password hashes are now stored in `/etc/shadow`. 

The first characters of the password hash indicate the algorithm used. `$1$` is the insecure MD5 algorithm and should not be used.

```
ubuntu@ubuntu-arm:~$ sudo tail -n 1 /etc/shadow
lily:$6$guO4Z6Pyde2rOVqj$Bb2wGhFx9WnNfCpQdiDfuL8JB/4ajO5tFuSJSYzkvwoStXQD.ldAFltbrRM1tuFgP/dgHucXbh6fhtlV3gFNi.:18694:0:99999:7:::
```

You can change an account password with the `passwd` command. If you run it without any arguments, it will change the current account's password. Otherwise, it will change the password of the account you specify.

```
shane@ubuntu-arm:~$ passwd
Changing password for shane.
Current password: 
New password: 
Retype new password: 
passwd: password updated successfully

ubuntu@ubuntu-arm:~$ sudo passwd lily
New password: 
Retype new password: 
passwd: password updated successfully
```

Password aging policies can be configured globally in `/etc/login.defs`. These apply to new accounts, but not retroactively to existing accounts. 
* PASS_MAX_DAYS - max number of days a password can be used
* PASS_MIN_DAYS - minimum days allowed between password changes
* PASS_WARN_AGE - days before password expiration a warning is given

```
ubuntu@ubuntu-arm:~$ sudo cat /etc/login.defs | grep "^PASS_"
PASS_MAX_DAYS	99999
PASS_MIN_DAYS	0
PASS_WARN_AGE	7
```

To set these for an individual user, you can use the `chage` command The `-l` option displays the current settings.
```
ubuntu@ubuntu-arm:~$ sudo chage shane
Changing the aging information for shane
Enter the new value, or press ENTER for the default

	Minimum Password Age [0]: 2
	Maximum Password Age [99999]: 365
	Last Password Change (YYYY-MM-DD) [2021-03-08]: 
	Password Expiration Warning [7]: 8
	Password Inactive [-1]: 
	Account Expiration Date (YYYY-MM-DD) [-1]:

ubuntu@ubuntu-arm:~$ sudo chage -l shane
Last password change					: Mar 08, 2021
Password expires					: Mar 08, 2022
Password inactive					: never
Account expires						: never
Minimum number of days between password change		: 2
Maximum number of days between password change		: 365
Number of days of warning before password expires	: 8
```

As an aside, if `pwquality` is enabled via PAM, you can manage password quality rules in `/etc/security/passwordquality.conf` (sometimes `/etc/security/pwquality.conf`)

## Process Management
### Background and Foreground
Processes start in the foreground by default. If you want to start them in the background, you can end the command with an ampersand: `&`.

```
ubuntu@ubuntu-arm:~$ sleep 5 &
[1] 3784
ubuntu@ubuntu-arm:~$ I can still do stuff
```

If you want to move a foreground process to the background, you can do so in a two-step process:
* Press `Ctrl+Z`, which pauses the process
* Use `bg` to restart the process in the background

```
ubuntu@ubuntu-arm:~$ sleep 15
^Z
[2]+  Stopped                 sleep 15

ubuntu@ubuntu-arm:~$ bg 2
[2]+ sleep 15 &
```

Conversely, to bring a background process to the foreground, use `fg`. If you have multiple processes running, you can find the desired one using the `jobs` command. 

```
ubuntu@ubuntu-arm:~$ sleep 15 &
[2]   Done                    sleep 15
ubuntu@ubuntu-arm:~$ sleep 15 &
[4] 3790
ubuntu@ubuntu-arm:~$ sleep 15 &
[5] 3791

ubuntu@ubuntu-arm:~$ jobs
[3]   Running                 sleep 15 &
[4]-  Running                 sleep 15 &
[5]+  Running                 sleep 15 &

ubuntu@ubuntu-arm:~$ fg 5
sleep 15
```

The `+` and `-` indicate which jobs would be defaulted to you if don't specify a number with `fg` or `bg`. The `+` is the default job. If it ends, the `-` then becomes the default.

### Viewing Processes
You can view processes in your current shell using `ps`.

```
ubuntu@ubuntu-arm:~$ sleep 30 &
[1] 3913

ubuntu@ubuntu-arm:~$ ps
  PID TTY          TIME CMD
 3902 pts/0    00:00:00 bash
 3913 pts/0    00:00:00 sleep
 3914 pts/0    00:00:00 ps
```

More verbose information can be gleaned by running `sudo ps -aux`.
 * `-a` - all processes (when used with `-x`)
 * `-u` - user information
 * `-x` - used with `-a` to show all processes

 ```
 ubuntu@ubuntu-arm:~$ ps -aux
 USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.2  36136  9980 ?        Ss    2020   4:35 /lib/systemd/systemd --system --deserialize 27
root         2  0.0  0.0      0     0 ?        S     2020   0:06 [kthreadd]
root         3  0.0  0.0      0     0 ?        I<    2020   0:00 [rcu_gp]
root         4  0.0  0.0      0     0 ?        I<    2020   0:00 [rcu_par_gp]
root         8  0.0  0.0      0     0 ?        I<    2020   0:00 [mm_percpu_wq]
root         9  0.0  0.0      0     0 ?        S     2020   0:25 [ksoftirqd/0]
root        10  0.0  0.0      0     0 ?        I     2020   4:03 [rcu_preempt]
root        11  0.0  0.0      0     0 ?        S     2020   1:11 [migration/0]
--- clip ---
 ```

You might want to use `grep` in conjuction with `ps -aux`.
```
ubuntu@ubuntu-arm:~$ ps -aux | grep nginx
root      1789  0.0  0.0  44096  1060 ?        Ss    2020   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data  1790  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1791  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1792  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1793  0.0  0.1  44448  5024 ?        S     2020   0:00 nginx: worker process
ubuntu    3951  0.0  0.0   5952   552 pts/0    S+   23:39   0:00 grep --color=auto nginx
```

A few columns are worth mentioning.
* `USER` displays the user associated with a process
* `PID` displays the process identifier
* `STAT` displays process status codes. Examples:
    * R - running
    * S - sleeping (waiting on something)
    * Z - defunct ("zombie" process)

* `COMMAND` displays the command used to run the process

Here's another `ps` example. `ps -U www-data u` will show the processes owned by `www-data` and outputs the user format (`u`).
```
ubuntu@ubuntu-arm:~$ ps -U www-data u
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
www-data  1790  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1791  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1792  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1793  0.0  0.1  44448  5024 ?        S     2020   0:00 nginx: worker process
```

You can approximate live output with the `watch` command. Below, we run the command every 1 second (`-n 1`).
```
ubuntu@ubuntu-arm:~$ watch -n 1 ps -U www-data u

Every 1.0s: ps -U www-data u                      ubuntu-arm: Mon Mar  8 23:50:11 2021

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
www-data  1790  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1791  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1792  0.0  0.1  44448  5028 ?        S     2020   0:00 nginx: worker process
www-data  1793  0.0  0.1  44448  5024 ?        S     2020   0:00 nginx: worker process
```
Press `Ctrl+C` to exit.

In practice, you'd use `top` to view live information about processes. 

```
ubuntu@ubuntu-arm:~$ top

top - 23:51:38 up 90 days,  7:36,  1 user,  load average: 0.01, 0.01, 0.00
Tasks: 140 total,   1 running, 139 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   3822.4 total,    559.3 free,    156.3 used,   3106.8 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   3615.2 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND         
 4166 ubuntu    20   0    8392   2484   2140 R   0.7   0.1   0:00.07 top             
 3797 root      20   0       0      0      0 I   0.3   0.0   0:01.01 kworker/u8:3-ev+
    1 root      20   0   36136   9980   5672 S   0.0   0.3   4:35.63 systemd         
    2 root      20   0       0      0      0 S   0.0   0.0   0:06.23 kthreadd        
    3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp          
    4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp      
    8 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_percpu_wq    
    9 root      20   0       0      0      0 S   0.0   0.0   0:25.22 ksoftirqd/0     
   10 root      20   0       0      0      0 I   0.0   0.0   4:03.84 rcu_preempt     
   11 root      rt   0       0      0      0 S   0.0   0.0   1:11.73 migration/0    
```
### Ending Processes
Occasionally, you'll need to terminate misbehaving processes. The `kill` command accomplishes this, but you'll need to know the process identifier (PID).

To find the PID, you can use `ps`. Another option is shown below. `pidof` takes a process name and returns a PID.

```
ubuntu@ubuntu-arm:~$ sleep 15 & 
[1] 4172
ubuntu@ubuntu-arm:~$ pidof sleep
4172
ubuntu@ubuntu-arm:~$ kill 4172
```

Occasionally, you may notice a zombie process in the output of `ps` (status code `Z`). For these processes, you may need to restart the parent process or even the whole system.

More on [removing zombie processes](https://stackoverflow.com/questions/16944886/how-to-kill-zombie-process).

### nice and renice
Nice values can be used to assign priorities to processes. They range from -20 to 19.
* **Lower** nice values are "meaner" or "greedier" (higher priority).
* **Higher** nice values are "less greedy" (lower priority).

You can find a processes' nice values with `ps -el | awk '{ print $14 " ==> " $8 }'`.
* `ps -el` generates process information (including nice scores)
* `awk` prints the process name and nice value. 

We'll use this temporarily.

```
ubuntu@ubuntu-arm:~$ ps -el | awk '{ print $14 " ==> " $8 }'
systemd ==> 0
kthreadd ==> 0
rcu_gp ==> -20
rcu_par_gp ==> -20
mm_percpu_wq ==> -20
ksoftirqd/0 ==> 0
rcu_preempt ==> 0
migration/0 ==> -
idle_inject/0 ==> -
cpuhp/0 ==> 0
cpuhp/1 ==> 0
---snip---
```

If you spawn processes without specifying the nice value, they default to 0.
```
ubuntu@ubuntu-arm:~$ ps -el | awk '{ print $14 " ==> " $8 }' | grep sleep
sleep ==> 0
sleep ==> 0
```

To spawn them with explicit nice values, you can use the `nice` command. Here, we lower the priorities (by increasing the nice value.)
```
ubuntu@ubuntu-arm:~$ nice -n 12 sleep 15 &
[1] 4389
ubuntu@ubuntu-arm:~$ nice -n 10 sleep 15 &
[2] 4390
ubuntu@ubuntu-arm:~$ ps -el | awk '{ print $14 " ==> " $8 }' | grep sleep
sleep ==> 12
sleep ==> 10
```

It may require `sudo` to use lower nice values. If permission is denied, the process will run with the default nice value of 0.
```
ubuntu@ubuntu-arm:~$ nice -n -10 sleep 15 &
[1] 4394
ubuntu@ubuntu-arm:~$ nice: cannot set niceness: Permission denied

ubuntu@ubuntu-arm:~$ sudo nice -n -10 sleep 15 &
[2] 4395

ubuntu@ubuntu-arm:~$ ps -el | awk '{ print $14 " ==> " $8 }' | grep sleep
sleep ==> 0
sleep ==> -10
```

You may also change the nice value of an existing process using `renice`.

```
ubuntu@ubuntu-arm:~$ ps -el | awk '{ print $14 " ==> " $8 }' | grep sleep
sleep ==> 12

ubuntu@ubuntu-arm:~$ sudo renice -n -11 4411
4411 (process ID) old priority 12, new priority -11

ubuntu@ubuntu-arm:~$ ps -el | awk '{ print $14 " ==> " $8 }' | grep sleep
sleep ==> -11
```

## Scheduling Tasks
### cron
`cron` is the de facto utility for scheduling jobs on a system. Each user can create their own "crontab" comprising scheduled tasks.

To view your crontab, if it exists, run `crontab -l`. 

To create or edit it, you can use `crontab -e`.
```
ubuntu@ubuntu-arm:~$ crontab -l
no crontab for ubuntu
ubuntu@ubuntu-arm:~$ crontab -e
no crontab for ubuntu - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny
  4. /bin/ed

Choose 1-4 [1]: 1
```

In nano, we can add crontab entries.
```
# Syntax
# minutes, hours, day-of-month, month, day-of-week, command
# min hr dom mo dow         command

# Run script at 12:30 daily
30 12 * * *     /usr/local/bin/script.sh

# Run script at 12am on first day of the month
0 0 1 * *       /usr/local/bin/script.sh

# Run script on Sundays
0 0 * * 0       /usr/local/bin/script.sh
```

The root user (or someone using `sudo`) can edit other people's crontabs by specify the user with `-u`.

```
root@ubuntu-arm:/home/ubuntu# crontab -l -u ubuntu
---snip--

root@ubuntu-arm:/home/ubuntu# crontab -e -u ubuntu
---snip--
```

To delete a crontab, you can use the `-r` option.
```
ubuntu@ubuntu-arm:~$ crontab -r
ubuntu@ubuntu-arm:~$ crontab -l
no crontab for ubuntu
```

### anacron
`anacron` is like `cron`, but it doesn't assume the system is running 24/7. If a scheduled task occurs while the system is shutdown, `anacron` can run it at the next opportunity.

You can edit `anacron` entries in `/etc/anacrontab`
```
ubuntu@ubuntu-arm:~$ sudo vim /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
HOME=/root
LOGNAME=root

# These replace cron's entries
1       5       cron.daily      run-parts --report /etc/cron.daily
7       10      cron.weekly     run-parts --report /etc/cron.weekly
@monthly        15      cron.monthly    run-parts --report /etc/cron.monthly

14      60      mytask.biweekly         /usr/bin/ping -c 4 google.com
```

The bottom entry is an example of a custom entry. Column-by-column:
* **14** - it will run every 14 days
* **60** - it will wait 60 minutes after boot
* **mytask.biweekly** - an identifier for the anancrontab entry
* **/usr/bin/ping...** - the command or script to run

### at and batch
`at` is useful for one-off commands that don't need persistent scheduling. It has an intuitive syntax. 

Here are some examples:
```
ubuntu@ubuntu-arm:~$ at 10:05
warning: commands will be executed using /bin/sh
at> echo "hello" >> /home/ubuntu/hello
at> <EOT>
job 2 at Tue Mar  9 10:05:00 2021

ubuntu@ubuntu-arm:~$ at December 25
warning: commands will be executed using /bin/sh
at> ping -c 1 10.0.1.22       
at> <EOT>
job 3 at Sat Dec 25 05:06:00 2021

ubuntu@ubuntu-arm:~$ at Sunday
warning: commands will be executed using /bin/sh
at> echo "woohoo!"
at> <EOT>
job 4 at Sun Mar 14 05:07:00 2021
```
Note: *press Ctrl+D to end entry*

To view the `at` queue, use `atq`.
```
ubuntu@ubuntu-arm:~$ atq
4	Sun Mar 14 05:07:00 2021 a ubuntu
2	Tue Mar  9 10:05:00 2021 a ubuntu
3	Sat Dec 25 05:06:00 2021 a ubuntu
```

You can remove jobs with `at -r`.
```
ubuntu@ubuntu-arm:~$ at -r 4
ubuntu@ubuntu-arm:~$ at -r 2
ubuntu@ubuntu-arm:~$ at -r 3
ubuntu@ubuntu-arm:~$ atq
```

`batch` is a similar command (and part of the same suite). Rather than running at a particular time, `batch` runs when system utilization drops below a configured threshold.

## Graphical Interfaces
A **display server** provides an interface for applications to present a simple graphical interface to the user.

A **window manager** cooperates with a display server to present more or one applications (as windows).

A **desktop environment** provides a graphical shell (think task bar, system tray, login screens) and common userland applications such as word processors, browsers, and email clients. They usually come with a default window manager.

Common display servers are:
* X11 (older)
* Wayland (newer)

Common desktop environments are:
| Environment | Default Window Manager |
| ----------  | ---------------------- |
| GNOME | mutter |
| KDE Plasma | KWin |
| Cinammon | Muffin |
| XFCE | Xfwm |

In short, there are two key display servers (X11 and Wayland) and many available desktop environments, each of which ship with a default window manager.

Most of these components can be mixed, matched, and substituted with a little elbow grease.

## Server Roles

Linux servers can take on many roles. The following is a list of common roles and packages used to provide them.

* **Webservers**
   * Apache 
   * nginx
   * lighttpd 
* **Database Servers**
    * Relational/SQL - MySQL, PostgreSQL, MariaDB
    * Non-relation/NoSQL - MongoDB, Redis
* **File Servers** 
    * Usually NFS for Linux clients
    * Usually Samba (SMB) for Windows clients
* **Mail Servers** (also known as mail transfer agents or MTAs)
    * postfix
    * sendmail
    * exim
* **NTP Servers**
    * ntpd
    * chrony
* **Name Servers**
    * bind
    * unbound
* **Authentication Servers**
    * FreeRADIUS
    * OpenLDAP
    * FreeIPA