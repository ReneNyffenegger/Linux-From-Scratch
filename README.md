# Linux-From-Scratch

Scripts for Linux From Scratch (LFS)

## Setting environment

`env`: File to be sourced by original user and lfs user. Sets among others the `$LFS` variable

## Host System Requirements

Check if requirements are met:

    . ./00.host-system-requirements.sh


## Creating partitions

    . ./01.create-partitions

## Mount LFS partition

    . ./02.mount-lfs-partition

## Start executing the steps

# TODO

## Deploying LFS on multiple systems

  <a href='http://www.linuxfromscratch.org/lfs/view/stable/chapter06/pkgmgt.html'>http://www.linuxfromscratch.org/lfs/view/stable/chapter06/pkgmgt.html</a>:  Configuration files that may need to be updated include: /etc/hosts, /etc/fstab, /etc/passwd, /etc/group, /etc/shadow, /etc/ld.so.conf, /etc/sysconfig/rc.site, /etc/sysconfig/network, and /etc/sysconfig/ifconfig.eth0.
