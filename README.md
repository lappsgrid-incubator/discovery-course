# Discovery 2020
Scripts needed to configure EC2 for the analyst's discovery course.

## Creating an Amazon (EC2) Instance

This is a process that you start from the EC2 Dashboard in the AWS console by clicking the "Launch Instance" button.

### Step 1: Choose an Amazon Machine Image (AMI)

Select the Ubuntu server.

### Step 2: Choose an Instance Type

For testing we have used:

Family: General purpose<br/>
Type: m4.2xlarge<br/>
CPUs: 8<br/>
Memory: 32GB

Click the Next button.

### Step 3: Configure Instance Details

Change IAM role to ecsInstanceRole and in Advanced Details paste in first 9 lines of aws-setup.sh (available in this repository at https://github.com/lappsgrid-incubator/discovery-course/blob/master/aws-setup.sh)

### Step 4: Add Storage

Use 32 GB.

### Step 5: Tag Instance

Skip this step.

### Step 6: Configure Security Group

Use "Select an existing security group" and select the "Lappsgrid Appliance Ports" security group.

### Step 7: Launch

In Step 6 you can select "Review and Launch" and then "Launch". At that point you will get a pop-up that asks for a key pair, select "Choose and existing key pair" and use "aws-public".

After launching you can then go back to the instances list where you will see a new instance with a rotating beach ball. The instance you just created has no name yet so give it one. It will take a couple of minutes for the instance to be up. You then ssh into the instance and start the LAPPS Grid with:

$ sudo lappsgrid run

Before you can ssh in and connect to the LAPPS/Galaxy site you may have to edit the security group depending on what IP address you are. Select the instance and in the description find the Lappgrid Alliance Ports security group link. Select the "Inbound" tab and add three new rules for your IP address: 

For Galaxy access: Type "HTTP" o port 80<br/>
For SSH access: Type "SSH" on port 22<br/>
For Tomcat access: Type "Custom TCP Rule" with the 8000-8999 port range
