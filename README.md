# Linux-From-Scratch

Scripts for Linux From Scratch (LFS)

## Setting environment

`lfs-env`: Sets among others the `$LFS` variable. Is sourced by `10.run` and `20.run-as-lfs` etc.

## Host System Requirements

Check if requirements are met:

    ./00.host-system-requirements.sh


## Creating partitions

    ./01.create-partitions

## Mount LFS partition

    ./02.mount-lfs-partition

`02.mount-lfs-partition` is called by `./01.create-partitions`. So, immediatly afeter executing `./01.create-partitions`, there should be no need
to mount it explicitely. But this script might be used after rebooting the system, for example.

## copy script files etc

     ./03.copy-files-to-LFS

## Start executing the steps

     ./10.run

# TODO

## Deploying LFS on multiple systems

  <a href='http://www.linuxfromscratch.org/lfs/view/stable/chapter06/pkgmgt.html'>http://www.linuxfromscratch.org/lfs/view/stable/chapter06/pkgmgt.html</a>:  Configuration files that may need to be updated include: /etc/hosts, /etc/fstab, /etc/passwd, /etc/group, /etc/shadow, /etc/ld.so.conf, /etc/sysconfig/rc.site, /etc/sysconfig/network, and /etc/sysconfig/ifconfig.eth0.
