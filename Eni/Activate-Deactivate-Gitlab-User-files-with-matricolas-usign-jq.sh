#!/bin/bash

######################################
# FUNCTIONS
######################################
#Display the usage information for the script and exit with status 1.
function usage {
  echo "Usage:"
  echo "$0 <gitlab_token> <input.txt>"
  exit 1
}

#####################################
# GLOBAL VARIABLES
#####################################

gitlab_token=$1
input_file=$2
fqdn_gitlab="st-gitlab-dummy.eni.com"


####################################
# MAIN
####################################

if [ "$#" -ne 2 ]; then
    usage
fi

cat $input_file | while read line; do

    user=$(echo $line | cut -d' ' -f1)
    choice=$(echo $line | cut -d' ' -f2)
    get_user_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].id')

    echo "------ Processing user: $user with User ID: $get_user_id ------"
    echo "Choice: $choice"

    if [[ "$choice" == "deactivate" ]]; then
        echo "Deactivate User: $user"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/deactivate"
        echo ""
    fi

    if [[ "$choice" == "activate" ]]; then
        echo "Activate User: $user"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/activate"
        echo ""
    fi
done

#chiamata post: POST /users/:id/deactivate
