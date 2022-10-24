#!/bin/bash
# Create default user
useradd -rm -d /home/$USER -s /bin/bash -g root -G sudo -u 1010 $USER
echo -e "$USER_PWD\n$USER_PWD" | passwd $USER &> /dev/null

# Set up RStudio license
if [[ $RSTUDIO_LICENSE == "NULL" ]];
then
	echo "No RStudio Workbench license specified. Please specify a license in the RSTUDIO_LICENSE environment variable."
else 
	echo "Activating RStudio Workbench license..."
	rstudio-server license-manager activate $RSTUDIO_LICENSE
	if [[ $? -eq 0 ]];
	then
		echo "RStudio Workbench activated."
	else
		echo "RStudio Workbench license activation failed."
	fi
fi

# Define RStudio license deactivation function
rstudio_deactivate_license() {
	echo "Deactivating RStudio Workbench license..."
	rstudio-server license-manager deactivate
	if  [[ $? -eq 0 ]]; then
		echo "RStudio Workbench license deactivated."
		echo "Shutting down RStudio Workbench container..."
	else
		echo "RStudio Workbench license deactivation failed."
		echo "Shutting down RStudio Workbench container..."
	fi
}

# Create SIGTERM trap to deactivate RStudio license
trap 'true' SIGTERM

# Execute supervisor to start RStudio Workbench
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Wait for SIGTERM signal to shut down
wait $!

# Call RStudio license deactivation function after SIGTERM signal receival
rstudio_deactivate_license