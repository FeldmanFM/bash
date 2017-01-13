#!/bin/bash
##GLOBAL VARIABLES

IP_ADDRESSES=("10.8.8.11" "10.8.8.12" "10.8.8.13" "10.8.8.14" "10.8.8.15")
HOSTNAME_PREFIX="node"
DOMAIN="gtest.ru"
CEPH_STORAGES=("ceph_storage" "ovirt")
SERVER_DIRECTORY="/usr/share/sintez_shd"
amountStorages=${#CEPH_STORAGES[@]}
amountNodes=${#IP_ADDRESSES[@]}

##FUNCTIONS

function createNetwork {
cat > $directoryOutput/ifcfg-br0 << EOF
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=$address
PREFIX=24
IPV4_FAILURE_FATAL=yes
NAME="System br0"
STP=on
DELAY=4
AGEING=4
/usr/sbin/brctl sethello br0 1
EOF
}

function createHosts {
cat > $directoryOutput/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF
n=0
for  (( j=0; j<${amountNodes}; j++ ))
	do
		n=$(( $j+1 ))
		cat >> $directoryOutput/hosts << EOF
${IP_ADDRESSES[$j]}	$HOSTNAME_PREFIX$n.$DOMAIN	$HOSTNAME_PREFIX$n
EOF

	done
}

function createRbdmap {
cat > $directoryOutput/rbdmap << EOF
### put me in /etc/ceph/
# RbdDevice		Parameters
#poolname/imagename	id=client,keyring=/etc/ceph/ceph.client.keyring
EOF
	for (( k=0; k<${amountStorages}; k++ ))
		do
			cat >> $directoryOutput/rbdmap << EOF
${CEPH_STORAGES[$k]}	
EOF
		done

}

function createScript {
cat > $directoryOutput/deploy.sh << EOF
#!/bin/bash
ssh \$1 mkdir $SERVER_DIRECTORY
ssh \$1 mkdir /usr/share/scripts/
scp \`dirname \$0\`/* \$1:$SERVER_DIRECTORY
ssh \$1 cp $SERVER_DIRECTORY/ifcfg-br0 /etc/sysconfig/network-scripts/
ssh \$1 cp $SERVER_DIRECTORY/hosts /etc/hosts
ssh \$1 ln -s $SERVER_DIRECTORY/onboot_rbd.sh /usr/share/scripts/
ssh \$1 ln -s $SERVER_DIRECTORY/onboot.py /usr/share/scripts/

EOF
chmod +x $directoryOutput/deploy.sh

}


##MAINSCRIPT

for (( i=0; i<${amountNodes}; i++  ))
	do
		address=${IP_ADDRESSES[$i]}
		directoryOutput=../output/$address
		mkdir $directoryOutput
		createNetwork
		createHosts
		createRbdmap
		createScript
	done
