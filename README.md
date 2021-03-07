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
3. [Booting](#booting)
    * [BIOS Boot Process](#bios-boot-process)
    * [UEFI Boot Process](#uefi-boot-process)
    * [GRUB Configuration](#grub-configuration)
    * [Grubby!](#grubby)
    * [Ad-Hoc GRUB Configurations](#ad-hoc-grub-configurations)
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
      * [Managing Groups](#managing-groups)
      * [Passwords](#passwords)


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

### Permissions
### Links
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

### Managing Groups
### Passwords