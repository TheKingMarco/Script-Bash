#!/bin/bash

######################################
# FUNCTIONS
######################################
#Display the usage information for the script and exit with status 1.
function usage {
  echo "Usage:"
  echo "$0 <gitlab_token> <user_id> <activate/deactivate>"
  exit 1
}

#####################################
# GLOBAL VARIABLES
#####################################

gitlab_token=$1
user_id=$2
choice=$3

####################################
# MAIN
####################################

if [ "$#" -ne 3 ]; then
    usage
fi

if [[ "$choice" == "deactivate" ]]; then
    echo "Deactivate User: $user_id"
    curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab-dgt.eni.com/api/v4/users/${user_id}/deactivate"
fi

if [[ "$choice" == "activate" ]]; then
    echo "Activate User: $user_id"
    curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab-dgt.eni.com/api/v4/users/${user_id}/activate"
fi

#chiamata post: POST /users/:id/deactivate
