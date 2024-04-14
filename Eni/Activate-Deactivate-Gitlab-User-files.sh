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


####################################
# MAIN
####################################

if [ "$#" -ne 2 ]; then
    usage
fi

cat $input_file | while read line; do

    user_id=$(echo $line | cut -d' ' -f1)
    choice=$(echo $line | cut -d' ' -f2)

    echo "------ Processing user: $user_id ------"
    echo "Choice: $choice"

    if [[ "$choice" == "deactivate" ]]; then
        echo "Deactivate User: $user_id"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab-dgt.eni.com/api/v4/users/${user_id}/deactivate"
    fi

    if [[ "$choice" == "activate" ]]; then
        echo "Activate User: $user_id"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab-dgt.eni.com/api/v4/users/${user_id}/activate"
    fi
done

#chiamata post: POST /users/:id/deactivate
