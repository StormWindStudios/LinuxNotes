# Help! I'm at a Command Line and My Boss is Watching Me

## Basic Navigation
The Linux command line is a foreign interface for a lot of IT professionals. Let's do some basic excercises to build familiarity.

Log in to RHEL or Ubuntu as a normal user. Your first prompt may look like one of the following.

```
[shane@rhel ~]$ 
```

```
shane@ubuntu:~$ 
```

There's a lot of information in these prompts. 

* Your username
* The hostname of your system
* Your current location (the `~` means you're in your home directory)
* Whether you're a standard user or root. The `$` means you're a standard user. If you're logged in as root, it would be a `#`.

Note: *Your home directory is located in `/home/username` for normal users; the root user's home directory is in `/root`.*

Run the `pwd` command to confirm your location.
```
[shane@rhel ~]$ pwd
/home/shane
```

Run `ls` to see what's in your home directory.

```
[shane@rhel ~]$ ls
[shane@rhel ~]$ 
```

At first glance, it seems like there's nothing! But there are actually hidden files. Try running `ls -a`.

```
[shane@rhel ~]$ ls -a
.  ..  .bash_history  .bash_logout  .bash_profile  .bashrc  .ssh
```

Various hidden files appear (any file beginning with a period is hidden).

You can use the `touch` command to make new, empty files. Run `touch standardfile .stealthyfile`. Run both `ls` commands. 

```
[shane@rhel ~]$ touch standardfile .stealthyfile
[shane@rhel ~]$ ls
standardfile
[shane@rhel ~]$ ls -a
.   .bash_history  .bash_profile  .ssh          .stealthyfile
..  .bash_logout   .bashrc        standardfile
[shane@rhel ~]$
```

We can remove these empty files with the `rm` command. Issue  `rm standardardfile` and `rm .stealthyfile`.

```
[shane@rhel ~]$ rm standardfile 
[shane@rhel ~]$ rm .stealthyfile 
[shane@rhel ~]$ ls -a
.  ..  .bash_history  .bash_logout  .bash_profile  .bashrc  .ssh
[shane@rhel ~]$ 
```

Multiple files with similar names can be "globbed." Issue `touch cats.txt dogs.txt ferrets.txt foxes.txt`. Make sure the files were created, then run `rm *.txt`.
```
[shane@rhel ~]$ touch cats.txt dogs.txt ferrets.txt foxes.txt
[shane@rhel ~]$ ls
cats.txt  dogs.txt  ferrets.txt  foxes.txt
[shane@rhel ~]$ rm *.txt
[shane@rhel ~]$ ls
[shane@rhel ~]$
```

Make two directories with `mkdir cats dogs`. Enter the cats directory with `cd cats`. Check your present working directory with `pwd`.

```
[shane@rhel ~]$ mkdir cats dogs
[shane@rhel ~]$ ls
cats  dogs
[shane@rhel ~]$ cd cats
[shane@rhel cats]$ pwd
/home/shane/cats
```

`cd ..` will bring you up a directory.

```
[shane@rhel cats]$ cd ..
[shane@rhel ~]$
```

You can also us `..` as part of a path. For instance, running `cd ../dogs` from the cats directory bring you up a level, then down into the dog directory.
```
[shane@rhel ~]$ cd cats
[shane@rhel cats]$ cd ../dogs
[shane@rhel dogs]$ pwd
/home/shane/dogs
[shane@rhel dogs]$
```

Regardless of where you are, `cd ~` will return you to your home directory.
```
[shane@rhel dogs]$ cd ~
[shane@rhel ~]$ pwd
/home/shane
```

## BASHing Faster

### Tab Completion
You can use tab completion when typing commands. This cuts down on keystrokes and typos.

On a Red Hat, typing `subs` and pressing `Tab` will fill in the rest of the command.
```
[shane@rhel ~]$ subs
[shane@rhel ~]$ subscription-manager
```

When tab completion has multiple possibilities, it will show you them. Try tab completion with `grub2-mk`.
```
[shane@rhel ~]$ grub2-mk
grub2-mkconfig         grub2-mklayout         grub2-mkrelpath
grub2-mkfont           grub2-mknetdir         grub2-mkrescue
grub2-mkimage          grub2-mkpasswd-pbkdf2  grub2-mkstandalone
```
### History
You can view and edit previous commands by using the up and down arrow keys. This can be useful for long commands you don't want to completely retype.

### Jump to Beginning and End of Line
`Ctrl+A` brings you to the beginning of a line and `Ctrl+E` brings you to the end. Much better than holding down an arrow key for 5 seconds.

### Rerun the Previous Command With Sudo
If you try to run a command that requires root privileges but forget to use `sudo`, you can rerun it more quickly with `sudo !!`

```
[shane@rhel ~]$ ls /root
ls: cannot open directory '/root': Permission denied
[shane@rhel ~]$ sudo !!
sudo ls /root
anaconda-ks.cfg
[shane@rhel ~]$ 
```