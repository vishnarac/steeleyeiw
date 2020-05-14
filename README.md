####Steeleye Interview Provisioning Test - Vishnu ######


Important notes before running the terraform code:

- You obviously need to download terraform and place the binary in the cloned directory.
- You would need an AWS account. I have done all my testing in ap-south-1.
- Set up awscli and configure access using 'aws configure' which requires access and secret key that can be generated at the aws console. 
- A pre generated private key at the AWS console for ec2 ssh access and for terraform to do its thing.
- Make sure you replace the private key name and its location on your local machine in the variables.tf file.
- The 4 files that does the work are variables.tf, main.tf (the main terraform orchestration code), appuserdata.sh and webuserdata.sh, which are bootstrap scripts to bootstrap the 2 app servers and the 1 web server thats going to get deployed.
- the main.tf creates 2 security groups (app, web) for the 2 app and the 1 web instance respectively. The app sg exposes 8484 only for the web sg & the web sg exposes port 80 to the outside world.
- A total of 3 ec2 instances are created.
- I am using haproxy on the web node to do the round-robin duties.
- The app node gets the go source file which gets compiled into binary and runs in the background exposing the app on port 8484.
 
1) Initilize the terraform environment
$ ./terraform init

2) Plan before making changes to your environment (optional)
$ ./terraform plan

4) I personally like to turn on logging for debugging purposes.
$ export TF_LOG=TRACE
$ export TF_LOG_PATH="terraform.txt"

5) Start provisioning
$ ./terraform apply

6) Test round robin using curl to hit the web/haproxy ec2 instance at port 80 from the commandline, repeat until you see roundrobin behaviour.

for example:
$ curl ec2-13-233-186-255.ap-south-1.compute.amazonaws.com; printf "\n"



