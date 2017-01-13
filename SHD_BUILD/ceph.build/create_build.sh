function mount_repo {
mount shd.iso /mnt -o loop
}

function add_shd_repo {
cat > /etc/yum.repos.d/shd.repo << EOF
[shd]
name=shd
baseurl=file:///mnt
gpgcheck=0
enabled=1
EOF
}

function add_builder {
useradd -d /home/builder -m builder
echo "builder ALL = (root) NOPASSWD:ALL" > /etc/sudoers.d/builder
chmod 0440 /etc/sudoers.d/builder
passwd builder
}

function untar_src {
mkdir /home/builder/pkgs
tar -xvf /root/src.tar -C /home/builder/pkgs
}

function install_rpmdevtools {
yum clean all
yum install -y rpmdevtools
}

function setup_rpmdev {
sudo -u builder rpmdev-setuptree
sudo -u builder rpm -ivh /home/builder/pkgs/*.rpm
}

function build_dep {
yum-builddep -y /home/builder/rpmbuild/SPECS/*
}

function build {
{ time sudo -u builder rpmbuild -bb /home/builder/rpmbuild/SPECS/*.spec ; } 2> build_time.txt
}

function install_createrepo {
cat > /etc/yum.repos.d/shd.repo << EOF
[shd]
name=shd
baseurl=http://10.10.1.4/public/channels/x86_64/7x/sintez-os/
gpgcheck=0
enabled=1
EOF
yum clean all
yum install -y createrepo
}

function make_repo_tar {
mkdir /root/build_pkgs
mkdir /root/build_pkgs/Packages
cp -v /home/builder/rpmbuild/RPMS/{noarch,x86_64}/* /root/build_pkgs/Packages
cd /root/build_pkgs && createrepo . && tar -cvf /root/rpm.tar ./* && cd -
}


function init {
mount_repo
add_shd_repo
add_builder
untar_src
install_rpmdevtools
setup_rpmdev
build_dep
build
install_createrepo
make_repo_tar
}

init
