KEY="1-101"
sed -i "s/enabled=1/enabled=0/g" /etc/yum.repos.d/* 
cat > /etc/yum.repos.d/sw.repo << EOF
[sw]
name=sw
baseurl=http://10.10.1.4/public/channels/x86_64/7x/spacewalk-client/
gpgcheck=0
enabled=1
EOF
yum install yum-rhn-plugin -y
sed -i "s/enabled=1/enabled=0/g" /etc/yum.repos.d/* 
cat >> /etc/hosts << EOF
10.10.1.249 spacewalk.gtest.ru
EOF
cd /usr/share/rhn/ && wget http://10.10.1.249/pub/RHN-ORG-TRUSTED-SSL-CERT && cd -
sed -i "s/^gpgcheck = 1/gpgcheck = 0/g" /etc/yum/pluginconf.d/rhnplugin.conf 
rhnreg_ks --activationkey=$KEY --serverUrl=https://spacewalk.gtest.ru/XMLRPC
printf "*/15 * * * *\t/usr/sbin/rhn_check\n"|crontab - && systemctl crond restart
#TEST123
#TESTING
