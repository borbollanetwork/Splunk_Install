#!/bin/bash
#################################################################
# @author: Renato Basante Borbolla                              #
# @description: This script download the Splunk Enterprise file #
# and install in CentOS 7.                                      #
#################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'
## Validate Root

if [ "$(id -u)" != "0" ]; then
echo -e "${WHITE}"
echo -e "${NC}${RED}YOU MUST EXECUTE THIS SCRIPT AS A ROOT!! ${NC}${WHITE}:(${NC}${WHITE} \n"
echo -e "${WHITE}${NC}"
else

## Set of URL download ###

URL_download='https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.2.1&product=splunk&filename=splunk-7.2.1-be11b2c46e23-Linux-x86_64.tgz&wget=true'
URL_md5validation='https://download.splunk.com/products/splunk/releases/7.2.1/linux/splunk-7.2.1-be11b2c46e23-Linux-x86_64.tgz.md5'

# Set directory to downdload splunk and validate then #
mkdir /opt/SplunkEnterprise
SPLUNK_DIR='/opt/SplunkEnterprise'

## Start

echo -e "${NC}${GREEN}-> Initializing...${NC}${WHITE}\n"

sleep 5

# Validating if the wget command are installed ##
  echo -e "${NC}${YELLOW}########### validating if wget is installed #################${NC}${WHITE} \n"
if [ ! -x /usr/bin/wget ] ; then
	echo -e "${NC}${YELLOW}########### wget is not installed, installing ###############${NC}${WHITE} \n\n"
	# At this moment just Linux using yum package manager are ready to use
	sudo yum update
	sudo yum install tar wget -y
else
	echo -e "${NC}${YELLOW}########### wget is already, installed ######################${NC}${WHITE} \n\n"
fi

########################################################################
## Remote download of Splunk Enterprise from the specified repository ##
## This URL download can be set at URL_download                       ##
########################################################################
cd $SPLUNK_DIR
wget -O SplunkEnterprise.tgz $URL_download

# Remote download from the specified repository of md5 validation file
# This URL download can be set at URL_md5validation
wget -O SplunkEnterprise.tgz.md5 $URL_md5validation

# Validating the downloaded files of Splunk Enterprise #

md5sum SplunkEnterprise.tgz SplunkEnterprise.tgz.md5 > splunkhashvalidate.md5

if md5sum --status -c splunkhashvalidate.md5 ; then
	# The MD5 sum matched
	echo -e "${NC}${YELLOW}SplunkEnterprise.tgz md5 ${NC}${GREEN}matched${NC} \n"
else
	# The MD5 sum didn't match
	echo -e "{NC}${YELLOW}SplunkEnterprise.tgz md5 ${NC}${RED}didn't match${NC} \n"
fi

echo -e "${NC}${WHITE}Splunk enterprise downloaded and ready to install ${NC}${YELLOW}:)${NC}\n\n"

sleep 5

echo -e "${NC}${GREEN}-----> NOW, INSTALLING SPLUNK...${NC}${WHITE}\n"

sleep 3

# untar the validated splunk enterprise file
sudo tar -zxvf SplunkEnterprise.tgz -C $SPLUNK_DIR

# change the owner of installation directory
sudo chown -R root:root $SPLUNK_DIR

# setting the Splunk Home
SPLUNK_HOME='/opt/SplunkEnterprise/splunk'
export SPLUNK_HOME=/opt/SplunkEnterprise/splunk
echo SPLUNK_HOME=/opt/SplunkEnterprise/splunk >> ~/.bash_profile
source ~/.bash_profile

# puting the new user credentials at the user-seed.conf
cd $SPLUNK_HOME/etc/system/local
touch user-seed.conf
echo [user_info] > user-seed.conf
echo USERNAME=admin >> user-seed.conf
echo PASSWORD=changeit  >> user-seed.conf

# enable Splunk Web access via HTTPS
touch web.conf
echo [settings] > web.conf
echo 'httpport = 8000' >> web.conf
echo 'enableSplunkWebSSL = true'  >> web.conf

# starting the splunk without answer any questions
# the admin user will be created below at this script
cd $SPLUNK_HOME/bin
echo -e "${NC}${WHITE}\n\n  -- START SPLUNK -- ${NC} \n"
sudo ./splunk start --answer-yes --no-prompt --accept-license

# put the splunk in boot start
sudo ./splunk enable boot-start

# Reload the profile of user to get the environment variables
source ~/.bash_profile

echo -e "${NC}${GREEN}---------------------------------------${NC} \n"
echo -e "${NC}${YELLOW}--> Credentials for Splunk Web: ${NC}${WHITE}\n"
echo -e "${NC}${WHITE}--> ${NC}${YELLOW}admin ${NC}${WHITE}: ${NC}${YELLOW}changeit ${NC}${WHITE}\n"
echo -e "${NC}${GREEN}---------------------------------------${NC} \n\n"
sleep 10
fi
exit
