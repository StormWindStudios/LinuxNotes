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
  10. [User and Group Administration](#user-and-group-administration)
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
||`host -t MX geocities.com`| Queries for Geocities' mail (MX) records|
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
## Security
### SELinux
### Apparmor
### Firewalls
### Fail2Ban
## Filesystem Administration
### Files and Directories
### Permissions
### Links
### Compression
### Mounting 
### File System Structure
### Formatting Partitions
### Swap Space
### LVM
### Quotas
## User and Group Administration
### Creating and Modifying Users
### Managing Groups
### Passwords