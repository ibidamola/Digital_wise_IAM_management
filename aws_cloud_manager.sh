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


