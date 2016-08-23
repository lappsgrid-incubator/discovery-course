# Discovery 2020

Scripts needed to configure EC2 for the analyst's discovery course. 

The rest of this file has note on the following:

1. Creating an Amazon EC2 Instance
2. Creating a Load Balancer.
3. Starting and stopping instances with the LAPPS Grid running


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

But for the production instances for the course we used m4.4xlarge, 16 CPUs and 128GB memory. Click the Next button.

### Step 3: Configure Instance Details

Change IAM role to ecsInstanceRole and in Advanced Details paste in first 9 lines of aws-setup.sh (available in this repository at https://github.com/lappsgrid-incubator/discovery-course/blob/master/aws-setup.sh)

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


<a name="restart"></a>
## 3. Starting and stopping instances

Do not simply spin down an instance since Galaxy really does not like that and restart may be harder. First go into the instance and do:

```$ lappsgrid stop```

Then spin down. After spinning up again you should be able to simply do a

```$ lappsgrid start```

and the images that were stopped will be started again.
