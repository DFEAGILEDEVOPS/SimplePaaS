export MINISHIFT_USERNAME="simon@simonmassey.org"
echo "Please enter your RHDS Password: "
read -sr MINISHIFT_PASSWORD_INPUT
export MINISHIFT_PASSWORD=$MINISHIFT_PASSWORD_INPUT

#minishift setup-cdk --default-vm-driver virtualbox
minishift start --vm-driver virtualbox
