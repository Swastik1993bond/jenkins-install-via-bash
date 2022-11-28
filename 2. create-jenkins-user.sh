id -u jenkins &>/dev/null || useradd jenkins
echo 'jenkins ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo
usermod -aG sudo jenkins
cd /opt/SW/Jenkins
