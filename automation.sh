\#!/bin/bash
#Variables
myname=shaik
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-shaik

echo "-------------------------------------------------------------------"
echo "Performing an update of the package details and the package list"
echo "-------------------------------------------------------------------"

sudo apt update -y

#Check if apache2 package is installed
dpkg -s apache2

echo "-------------------------------------------------------------------"

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


echo "-------------------------------------------------------------------"


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

echo "-------------------------------------------------------------------"

if [ $? -eq 0 ]; then
	echo "Archiving apache2 log files..."
	tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
	echo "log files archived..."

        echo "-------------------------------------------------------------------"

	echo "Copying archive files to S3 bucket..."
        aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
	echo "Copied archive files to S3 bucket successfully"
fi

echo "-------------------------------------------------------------------"
#----------------------------------------------------------------------------
# Book Keeping data
#----------------------------------------------------------------------------
file=/var/www/html/inventory.html
filesize=$(du -h "/tmp/${myname}-httpd-logs-${timestamp}.tar" | awk '{print $1}')

if [ -f "$file" ]; then
    	echo "$file exists. Appending book keeping data..."
	echo "<br>" >> $file
        echo "&emsp;&emsp;httpd-logs&emsp;&emsp;${timestamp}&emsp;&emsp;&emsp;tar&emsp;&emsp;$filesize" >> $file

else 
    	echo "$file does not exist."
    	echo "creating $file ..."
	echo "&emsp;&emsp;<b>Log Type</b>&emsp;&emsp;<b>Time Created</b>&emsp;&emsp;&emsp;&emsp;<b>Type</b>&emsp;&nbsp;<b>Size</b>" > $file
	echo "<br>" >> $file
	echo "Adding book keeping data to $file ..."
	echo "&emsp;&emsp;httpd-logs&emsp;&emsp;${timestamp}&emsp;&emsp;&emsp;tar&emsp;&emsp;$filesize" >> $file

fi

echo "Book keeping data added to $file"
echo "-------------------------------------------------------------------"

#check if cron job is scheduled or not
cronfile=/etc/cron.d/automation

if [ -f "$cronfile" ]; then
	echo "Cron job already scheduled"
else
	echo "Creating cron job..."
	echo "15 22 * * * root /root/Automation_Project/automation.sh" > $cronfile
	echo "Cron job created"
fi 
echo "-------------------------------------------------------------------"

