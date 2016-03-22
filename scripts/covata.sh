#!/bin/sh -vx
#date > /etc/box_build_time
#OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

# Set computer/hostname
#COMPNAME=osx-10_${OSX_VERS}
#scutil --set ComputerName ${COMPNAME}
#scutil --set HostName ${COMPNAME}.build.covata.com

# Install the covata_dc public key on the root user's ssh
PATH=/usr/local/bin:$PATH
mkdir "/var/root/.ssh"
chmod 700 "/var/root/.ssh"
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJLRA0vC6ytjhkK5Z/o8O4Bjw1+K1lavWHdcKCeAnTWp7rrO3AUpkxrAjC3jSFDPyBOUL0o/zZEK14Jgz1z4PGLyqCefUIGVHqgppHbITprbAFYGAUdO0ARsfcV54l+BYptLwjt2sp2QJZ1GxBj7wtO6BEG4BOLMsb2oUtTeQUZRt6D8uJVMHezEziLYEcmupbtH6WlxRtFff6XJ++EYNPL4qRZ23zwJYOYTk3XFoBFjPs+lawMV0+g4VW+70YxY9W/oG0eUgy6SDh78JJQ8SMECqOkJ4ni1BlIOCRmHTfeznbpAIUg9OFxtMVq/6E7ENUNcubJQz/LKnxcybea7Q6lpbSX2ESh7eFZpsBB4ou0dKb5TfJ2B8WFxbx7KX/yK5buOrcv4yKHLykQH/vCb2a86WZGvWMoCTm43w4qYwehUPHhCTrFXqr/d+e1aHZLioHEk87+WEFf/wCbvJfj3JBELUx50siYwJp7HuRT8/Ql0g2JwrDWBMPtHiOSavSmPCWwsgieyouylYpzflT0hdGXsc0fl6sPfK0ekoKr++oQ2nGepvaWAaQBd4Mado0mZnH4Ka2RA77uP0uHyRQxTHmT05exfWZl84MxCKYYE9GeQKIc+lDHSJgrbT94+L9LgYRWZIXdbOfgZhztgwNFhAIvbQeyHrcM4t9X0KtU36YKQ==' > "/var/root/.ssh/authorized_keys"
chmod 600 "/var/root/.ssh/authorized_keys"
chown -R "root:wheel" "/var/root/.ssh"

# Disable screensaver (it's just a waste of resources on virtual machines)
defaults write com.apple.screensaver idleTime 0

# Increase Git buffer size, trying to overcome network slowness and timeouts
#git config --global http.postBuffer 2M

# Create a dedicated hidden user for Homebrew
dscl . -create /Users/homebrew IsHidden 1
dscl . -create /Users/homebrew UniqueID 502
dscl . -create /Users/homebrew PrimaryGroupID 20
dscl . -create /Users/homebrew NFSHomeDirectory /Users/homebrew
dscl . -create /Users/homebrew UserShell /bin/bash
dscl . -create /Users/homebrew RealName "Hombrew"
dscl . -passwd /Users/homebrew $(/usr/bin/openssl rand -base64 30) # TODO: set to something uncrackable, preferably invalid
mkdir -p /Users/homebrew
chown -R homebrew:staff /Users/homebrew

# Install HomeBrew (can't install as root, so we use user "vagrant" for now)
#sudo -u vagrant GIT_CURL_VERBOSE=1 GIT_TRACE=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
chmod 0755 /private/tmp/homebrew-install
sudo -u vagrant /private/tmp/homebrew-install

# Install gnupg
sudo -u vagrant brew install gnupg

# Install hiera-eyaml and dependencies
# We need Xcode CLI tools installed (for ruby.h)
gem install --no-ri --no-rdoc hiera hiera-eyaml hiera-eyaml-gpg gpgme
