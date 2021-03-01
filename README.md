# CompTIA Linux+ Notes
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
| Debian | dpkg | apt

### Red Hat Package Management
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

### Git
Set up a git repository
```shane@linux:~$ mkdir my_git_repo
shane@linux:~$ cd my_git_repo
shane@linux:~/my_git_repo$ git config --global user.name "Shane Sexton"
shane@linux:~/my_git_repo$ git config --global user.email "ferretologist88@gmail.com"
shane@linux:~/my_git_repo$ git init
Initialized empty Git repository in /home/shane/my_git_repo/.git/
shane@linux:~/my_git_repo$ git remote add origin https://github.com/ferretology/my_git_repo.git
shane@linux:~/my_git_repo$ echo ".tmp" >> .gitignore
shane@linux:~/my_git_repo$git add -A
shane@linux:~/my_git_repo$ git commit -m "first commit"
[master (root-commit) 85251f5] first commit
 1 file changed, 1 insertion(+)
 create mode 100644 .gitignore
shane@linux:~/my_git_repo$ git push -u origin master```

Clone a git repository
```shane@linux:~$ git clone https://github.com/StormWindStudios/OpenSSL-Notes
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