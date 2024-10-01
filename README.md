# SHELL SCRIPT FOR AWS IAM MANAGEMENT GUIDE 

## Table of Contents
- [SHELL SCRIPT FOR AWS IAM MANAGEMENT GUIDE](#shell-script-for-aws-iam-management-guide)
  - [Table of Contents](#table-of-contents)
  - [1. Project Overview](#1-project-overview)
  - [2. Prerequisites](#2-prerequisites)
  - [3. AWS Console Setup](#3-aws-console-setup)
    - [3.1 Create an EC2 Instance](#31-create-an-ec2-instance)
    - [3.2 Create an IAM User](#32-create-an-iam-user)
      - [Sample IAM Policy (JSON):](#sample-iam-policy-json)
  - [4. Shell Script Development](#4-shell-script-development)
  - [5. Conclusion](#5-conclusion)

## 1. Project Overview

Datawise Solutions needs to efficiently manage AWS Identity and Access Management (IAM) resources as they onboard five new employees. This project involves creating a shell script to automate IAM user and group management.

## 2. Prerequisites

- AWS account with appropriate permissions
- AWS CLI installed and configured
- Basic knowledge of shell scripting
- Completed Linux foundations with Shell Scripting mini projects

## 3. AWS Console Setup

### 3.1 Create an EC2 Instance

1. Log in to the AWS Management Console
2. Navigate to EC2 service
3. Click "Launch Instance"
4. Choose an Amazon Machine Image (AMI)
5. Select an instance type
6. Configure instance details
7. Add storage
8. Add tags
9. Configure security group
10. Review and launch

![Insert EC2 creation image here](/images/ec2_instance.png)

### 3.2 Create an IAM User

1. Navigate to IAM service in AWS Console
2. Click "Users" in the left sidebar
3. Click "Add user"
4. Set user details and access type
5. Attach policies directly (e.g., AdministratorAccess for this project)
6. Review and create user
7. Download or copy Access Key ID and Secret Access Key

I used a pre-existing IAM User, and added access key
![Insert IAM user creation image here](/images/cli.png)
![](/images/access-keys.png)
![](/images/iam-tag.png)

#### Sample IAM Policy (JSON):

```bash
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"iam:CreateGroup",
				"iam:AttachGroupPolicy",
				"iam:CreateUser",
				"iam:GetGroup",
				"iam:AddUserToGroup",
				"iam:ListGroups",
				"iam:ListUsers",
				"s3:*",
				"ec2:*"
			],
			"Resource": [
				"*"
			]
		}
	]
}
```
**CREATNG POLICIES AND ATTACHING POLICIES**
![Creating policy/attaching policy](/images/creating-policy.png)
![Creating policy/attaching policy](/images/attaching-policy.png)

## 4. Shell Script Development
SSH into the public instance webserver

**SSH INTO PUBLIC EC2 INSTANCE**
![SSH into the public instance webserver](/images/ssh-into-public-ec2-instance.png)

1. Create a new file named aws_cloud_manager.sh:
   
```bash
touch aws_cloud_manager.sh
chmod +x aws_cloud_manager.sh
```
**CREATING AWS CLOUD MANAGER FILE**
![create aws_cloud_manager.sh file](/images/create-aws_cloud_manager_file.png)

2. open the file in any file editorof your choice
   
```bash
#!/bin/bash
# purpose of the project is to onboard five new employees to access AWS resources securelyby creating IAM User Names Array, IAM Users, IAM Group, Attach administrative policy to Group, and assign Users to Group

# Check for CLI Installation and configuration

check_aws_cli(){
	if ! command -v aws &> /dev/null; then
		echo "Error: AWS CLI is not installed. please install it and try again."
		exit 1
	fi

	if ! aws sts get-caller-identity &> /dev/null; then 
		echo "Error: AWS CLI is not configured."
		exit 1
	fi
}


#Defining an array of IAM user names (5 EMPLOYEES) in this scenario.
IAM_users=("employee1" "employee2" "employee3" "employee4" "employee5")

#Defining the Policy
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

#Defining the IAM_Group
IAM_Group="admin"

#Function to Create IAM users


create_iam_users() {
    for user in "${IAM_users[@]}"; do

	    #check if user already exits. 
        if aws iam get-user --user-name "$user" &> /dev/null; then
            echo "User $user already exists. Skipping creation."
        else
		#create IAM user
		echo "Creating IAM User '$user'*****"

            if aws iam create-user --user-name "$user" &> /dev/null; then
                echo "Created IAM user: $user"
            else
                echo "Failed to create IAM user: $user"
		exit 1
            fi
        fi
    done
}


#Create IAM group

create_iam_group() {
	#Check if IAM Group exit
    if aws iam get-group --group-name "$IAM_Group" &> /dev/null; then
        echo "Group $IAM_Group already exists. Skipping creation."
    else
	    #Create IAM Group
	    echo "creating IAM GROUP '$IAM_Group'*****"
        if aws iam create-group --group-name "$IAM_Group" &> /dev/null; then
            echo "Created IAM group: $IAM_Group"
        else
            echo "Failed to create IAM group: $IAM_Group"
            exit 1
        fi
    fi
}

# Function to attach administrative policy to group

attach_admin_policy() {
    if aws iam get-group-policy --group-name "$IAM_Group" --policy-name AdministratorAccess &> /dev/null; then
        echo "Policy already attached to group $IAM_Group. Skipping attachment."
    else
        if aws iam attach-group-policy --group-name "$IAM_Group" --policy-arn "$POLICY_ARN" &> /dev/null; then
            echo "Attached AdministratorAccess policy to $IAM_Group group"
        else
            echo "Failed to attach AdministratorAccess policy to $IAM_Group group"
            exit 1
        fi
    fi
}

# Function to assign users to group
assign_users_to_group() {
    for user in "${IAM_users[@]}"; do
        if aws iam get-group --group-name "$IAM_Group" | grep -q "$user"; then
            echo "User $user is already in group $IAM_Group. Skipping assignment."
        else
            if aws iam add-user-to-group --user-name "$user" --group-name "$IAM_Group" &> /dev/null; then
                echo "Assigned $user to $IAM_Group group"
            else
                echo "Failed to assign $user to $IAM_Group group"
            fi
        fi
    done
}

# Main function to manage IAM resource
main_resources() {
    echo "Checking AWS CLI installation and configuration..."
    check_aws_cli

    echo "Creating IAM users..."
    create_iam_users

    echo "Creating IAM group..."
    create_iam_group

    echo "Attaching administrative policy to group..."
    attach_admin_policy

    echo "Assigning users to group..."
    assign_users_to_group

    echo "IAM resource management completed."
}

# Run the main function
main_resources


ud_manager.sh" 124L, 3513B                                                                        20,43         Top

```
3. type in this command in your gitbash
```bash
aws configure
```
**HOW TO USE THE AWS CONFIGURATION**
![aws configuration](/images/aws-config.png)

4. typein the command to run the shell script
```bash
./aws_cloud_manager.sh

```
5. verify the configuration
```bash
aws iam list-users --output json
aws iam list-groups --output json
```

## 5. Conclusion
This READme file, provides a comprehensive description of how the project was carried out. which includes, creating an IAM user adding policy to user, Defined the IAM user names array, created iam group, attached administrative policy to group and assigned users to group all by using AWS CLI. 