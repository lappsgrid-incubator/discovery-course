# Discovery 2020

Scripts needed to configure EC2 for the analyst's discovery course. 

The rest of this file has note on the following:

1. Creating an Amazon EC2 Instance
2. Creating a Load Balancer.
3. Starting and stopping instances with the LAPPS Grid running
4. Galaxy data in /var/local/galaxy


## 1. Creating an Amazon (EC2) Instance

This is a process that you start from the EC2 Dashboard in the AWS console by clicking the "Launch Instance" button.

### Step 1: Choose an Amazon Machine Image (AMI)

Select the Ubuntu server.

### Step 2: Choose an Instance Type

For testing we have used:

| variable   | value           |
| ---------- | --------------- |
| Family     | General purpose |
| Type       | m4.2xlarge      |
| CPUs       | 8               |
| Memory     | 32GB            |

But for the production instances for the course we used m4.4xlarge, 16 CPUs and 128GB memory or larger.

### Step 3: Configure Instance Details

Change IAM role to ecsInstanceRole and in Advanced Details paste in the first part of aws-setup.sh (available in this repository at https://github.com/lappsgrid-incubator/discovery-course/blob/master/aws-setup.sh), all lines before the "docker run" command need to be pasted.

### Step 4: Add Storage

Use 32 GB (for the production image we used 128GB.

### Step 5: Tag Instance

Skip this step.

### Step 6: Configure Security Group

Use "Select an existing security group" and select the "Lappsgrid Appliance Ports" security group.

### Step 7: Launch

In Step 6 you can select "Review and Launch" and then "Launch". At that point you will get a pop-up that asks for a key pair, select "Choose and existing key pair" and use "aws-public".

After launching you can then go back to the instances list where you will see a new instance with a rotating beach ball. The instance you just created has no name yet so give it one. It will take a couple of minutes for the instance to be up. You then ssh into the instance and start the LAPPS Grid with:

$ sudo lappsgrid run

Before you can ssh in and connect to the LAPPS/Galaxy site you may have to edit the security group depending on what IP address you are. Select the instance and in the description find the Lappgrid Alliance Ports security group link. Select the "Inbound" tab and add three new rules for your IP address: 

For Galaxy access: Type "HTTP" on port 80<br/>
For SSH access: Type "SSH" on port 22<br/>
For Tomcat access: Type "Custom TCP Rule" with the 8000-8999 port range


## 2. Creating a Load Balancer

From the EC2 Dashboard click "Load Balancers" and then the "Create Load Balancer" button. Use the classic load balancer (the default).

### Step 1: Define Load Balancer

Give it a name and add five listeners for the following ports: 8001, 8002, 8003, 8004 and 8080. These values are for both the load balancer port and the instance ports, the protocol is always HTTP.

### Step 2: Assign Security Groups

Add Lappsgrid Appliance Ports.

### Step 3: Configure Security Settings

Skip.

### Step 4: Configure Health Check

Use the following settings:

| variable            | value |
| ------------------- | ----  |
| Ping path           | "/"   |
| Reponse timeout     | 2     |
| Unhealthy threshold | 5     |
| Healthy threshold   | 2     |

If the Ping path is a non existing path on the instance than the health check will fail.

### Step 5: Add EC2 Instances

Select the instances you want. Not all instances show up, which is a bit of a mystery to me (Marc). You can always add/remove instances later.

### Step 6: Add Tags

Skip and just click "Review and Create" and then "Create".


## 3. Starting and stopping instances

Do not simply spin down an instance since Galaxy really does not like that and restart may be harder. First go into the instance and do:

```$ lappsgrid stop```

Then spin down. After spinning up again you should be able to simply do a

```$ lappsgrid start```

and the images that were stopped will be started again.


## 4. Galaxy data in /var/local/galaxy

This is where all galaxy data are stored, including workflows, histories, login credentials etcetera. When we deploy a new instance and have discovery.lappsgrid.org point at it, users will not have access to their data anymore, so we need to update the new image with the contents of /var/local/galaxy of the old image. The steps invloved are:

There are three scripts that help with this, galaxy-put, galaxy-get and galaxy-update, that are not as smooth as they could be, but which basically do the following:

1. On the old instance, create an archive of /local/var/galaxy of the old instance and put it on a non-AWS server. The script galaxy-put helps with this. Note that this script, and galaxy-put as well, are tailored to work with putting the archive on a Brandeis server.
2. On the new instance, kill the LAPPS Server (lappsgrid kill). 
3. On the new instance, get the archive from the server with galaxy-get. 
4. On the new instance, backup the current /var/local/galaxy and unpack the archive from the old instance, then replace galaxy/galaxy-central/config/tool_conf.xml (copied from the old instance) with the one in the backup. This can be done with galaxy-update.

The tool_conf.xml overwrite in the last step is needed because otherwise the tool menu in galaxy on the new instance will be the tool menu that was in the old instance, which is not always right.

One thing to be careful with is what to do when the Galaxy menu in the Docker images has changed. In this case a simple update will not have the desired effect because when Galaxy starts up it will first look in /var/local/galaxy for tool settings. Not sure yet what the best way to deal with this is. Simply wiping /var/local/galaxy is not an option.
