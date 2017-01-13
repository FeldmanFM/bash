#!/bin/bash
ssh $1 mkdir /usr/share/sintez_shd
ssh $1 mkdir /usr/share/scripts/
scp `dirname $0`/* $1:/usr/share/sintez_shd
ssh $1 cp /usr/share/sintez_shd/ifcfg-br0 /etc/sysconfig/network-scripts/
ssh $1 cp /usr/share/sintez_shd/hosts /etc/hosts
ssh $1 ln -s /usr/share/sintez_shd/onboot_rbd.sh /usr/share/scripts/
ssh $1 ln -s /usr/share/sintez_shd/onboot.py /usr/share/scripts/

