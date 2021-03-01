## CompTIA Linux+ Notes
### Package Management

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
| ----------- | -------- | ------- |
| **Install .rpm package** | `rpm -ivh cowsay.rpm` ||
||| `-i` - **i**nstall |
|||`-v` - **v**erbose|
|||`-h` - show progress with **h**ashmarks|
| **Display .rpm package's dependencies** | `rpm -qpR cowsay.rpm` ||
||| `-q` - **q**uery a package|
||| `-p` - specify **p**ackage file |
||| `-R` - get package **r**equirements |
| **Check if package is installed**  | `rpm -q cowsay` ||
||| `-q` - **q**uery installed packages (since `-p` not used)|
| **List all installed packages** | `rpm -qa \| less` ||
||| `-q` - **q**uery packages |
||| `-a` - *a*ll packages |
||| `\| less` - pipe into `less` so we can read it |
| **Get info about installed package** | `rpm -qi cowsay` ||
||| `-q` - **q**uery package |
||| `-a`  - **i**nfo |