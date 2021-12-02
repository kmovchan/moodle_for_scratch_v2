#!/bin/bash
if [ "$UID" == "0" ] && [ "$EUID" == "0" ];
 then
    echo "Please do not run this script as root;"
        exit 1;
fi
echo "Start building VPL AMI instance"
if packer build -machine-readable ./packer/vpl.json > vplout.txt
 then 
     echo "VPL AMI instance is created"
 else 
  echo "Packer can't compile ami for VPL" && exit 1
fi

#echo "Start building Moodle AMI ARM instance"
#if packer build -machine-readable ./packer/moodle_arm.json > outmod.txt
echo "Start building Moodle AMI Intel instance"
if packer build -machine-readable ./packer/moodle_intel.json > moodleout.txt
  then
      echo "Moodle AMI inctance is created"
  else
    echo "Packer can't compile ami for Moodle" && exit 1
fi

echo "Prepearing AWS environment by terraform"
cd ./prerequisites
terraform init
terraform apply -auto-approve

echo "Starting deploying AWS environment by terraform"
cd ../project
terraform init 
terraform apply -auto-approve
