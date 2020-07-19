#!/bin/bash
cd /root/downloads
      cd openssl-*/
      make install
      echo 'pathmunge /usr/local/openssl/bin' > /etc/profile.d/openssl.sh
      echo '/usr/local/openssl/lib' > /etc/ld.so.conf.d/openssl.conf
      ldconfig -v
    pushd "/root/downloads/openssh"
      tar -xjf openssh-compiled-*.tbz
      cd openssh-*
      make install
      if ! [ -f /etc/ssh/ssh_host_ed25519_key ]; then
        ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
      fi
      unlink /etc/ssh_config
      unlink /etc/sshd_config
      for i in /etc/ssh/ssh_host_*_key /etc/ssh/ssh_config /etc/ssh/sshd_config ; do
        ln -f -s $i /etc/
      done
      sed -i '/UsePAM/d' /etc/ssh/sshd_config /etc/ssh/sshd_config.hpn
      sed -i '/RSAAuthentication/d' /etc/ssh/sshd_config /etc/ssh/sshd_config.hpn # 16337
      grep ec2-user:\!\!: /etc/shadow && usermod -p "*" ec2-user # 16337 - ec2-user is locked by default, set password field to '*' to bypass PAM restriction
      # update CipherSpec defaults
      if [ -f /var/www/softnas/config/snapreplicate.ini ]; then
        SEARCH_CIPHERSPEC=$(grep CipherSpec /var/www/softnas/config/snapreplicate.ini | grep "aes128-cbc,blowfish-cbc")
        if ! [ "$SEARCH_CIPHERSPEC" == "" ]; then
          crudini --set /var/www/softnas/config/snapreplicate.ini Relationship1 CipherSpec \"aes128-gcm@openssh.com\"
        fi
      fi
