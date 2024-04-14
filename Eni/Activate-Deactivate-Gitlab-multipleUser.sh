#!/bin/bash

######################################
# FUNCTIONS
######################################
#Display the usage information for the script and exit with status 1.
function usage {
  echo "Usage:"
  echo "$0 <gitlab_token>"
  exit 1
}

#####################################
# GLOBAL VARIABLES
#####################################

gitlab_token=$1 #token used to authanticate in gitlab API (you need permission to do this kind of actions)

user_ids=("8,9,10") # Array containing user ids to activate/deactivate you can populate this variables with the id of the user that you want to activate/deactivate
choice="activate" # you can choose between activate/deactivate

####################################
# MAIN
####################################

#explain how to use this script
if [ "$#" -ne 1 ]; then
    usage
fi

# Loop through user ids array and perform action on each user id
for user in "${user_ids[@]}"; do
    if [[ "$choice" == "deactivate" ]]; then
        echo "Deactivate User: $user"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab-dgt.eni.com/api/v4/users/${user}/deactivate"
    fi
    if [[ "$choice" == "activate" ]]; then
        echo "Activate User: $user"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab-dgt.eni.com/api/v4/users/${user}/activate"
    fi
done



#chiamata post: POST /users/:id/deactivate
