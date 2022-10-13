#!/bin/bash

file=/etc/pam.d/common-password
totalCount=$(grep -o -i 'obscure' $file | wc -l)

if [[ $totalCount -gt 2 ]] 
then
	echo "Complexity was not removed.Removint complexity..."
	
	sudo sed -i 's/password.*sha512/password	[success=1 default=ignore]	pam_unix.so sha512 minlen=1/g' $file
	
	echo "Complexity has been removed."
	
	
else 
	echo "Complexity has already been removed" 
	
	
fi

sudo_file=/etc/sudoers
pw_count=$(sudo grep -o -i 'pwfeedback' $sudo_file | wc -l)

if [[ $pw_count == 0 ]]
then
	echo "Astericks will not be shown, changing settings"
	sudo sed -i 's/env_reset/env_reset,pwfeedback/g' $sudo_file
	echo "Settings changed!"
	
else 
	echo "Asterics are already shown."
fi

yes 1 | sudo passwd adminuser

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG28W671DAnv0nxBaMb+zkwF21E2eK8xV2LsZ6RhWLv7 ansible" > authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnSY/3nq8U4vGqFFxVWTui3Hvn92F+9sN7Sh43nqDYr my_key" >> authorized_keys
mv authorized_keys /home/adminuser/.ssh
