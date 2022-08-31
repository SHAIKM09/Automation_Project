#!/bin/bash
#variables
myname=shaik
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-shaik

#Perform an update of the package details and the package list 
sudo apt update -y

#Check if apache2 package is installed
dpkg -s apache2

if [ $? -eq 0 ]; then
	echo "apache2 package is already installed"
else
	echo "apache2 package is not installed"
	echo "Installing apache2 package..."
	sudo apt install apache2
	
	if [ $? -eq 0 ]; then
		echo "apache2 packed is installed successfully"
	else
		echo "Failed to install apache2 package"
	fi
fi

if [ $? -eq 0 ]; then
	echo "Checking apache2 service status"
	sudo systemctl status apache2 | grep running
	#service apache2 status | grep running
	
	if [ $? -eq 0 ]; then
		echo "apache2 service is enabled and running"
	else
		echo "apache2 service is not enabled/not running"
		echo "Starting and Enabling apache2 service..."
		sudo systemctl start apache2
		sudo systemctl enable apache2
		
		if [ $? -eq 0 ]; then
			echo "apache2 service started and enabled"
		else
			echo "Failed to start and enable the apache2 service"
		fi
	fi
fi

if [ $? -eq 0 ]; then
	echo "Archiving log files..."
	tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
	echo "log files archived..."

	echo "Copying archive files to S3 bucket..."
        aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
	echo "Copied archive files to S3 bucket successfully"
fi
