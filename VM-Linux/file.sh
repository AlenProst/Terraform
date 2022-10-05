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

sudo apt-get update && sudo apt-get
sudo apt -y install nginx
echo "<h1>Hello from NGINX</h1>" > index.html
echo "<h1>Thank you for visiting my site!</h1>" >> index.html
sudo mv index.html /var/www/html
sudo systemctl restart nginx

yes 1 | sudo passwd adminuser