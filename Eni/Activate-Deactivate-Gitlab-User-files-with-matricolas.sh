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

    matricola=$(echo $line | cut -d' ' -f1)
    choice=$(echo $line | cut -d' ' -f2)
    get_user_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?username=$matricola | sed -e 's/{/,/g' -e 's/}/,/g' | tr ',' '\n' | sed -e '/^$/d' | sed '1d' | sed '$d' | grep -v "\"id\":1" | grep -w "id" | awk -F':' '{print $2}') #parsing the json obtained from the get api , to get only the user id corrispondente to the mastricola passed on file input.txt

    echo "------ Processing user: $matricola with User ID: $get_user_id ------"
    echo "Choice: $choice"

    if [[ "$choice" == "deactivate" ]]; then
        echo "Deactivate User: $matricola"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/deactivate"
    fi

    if [[ "$choice" == "activate" ]]; then
        echo "Activate User: $matricola"
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/activate"
    fi
done

#curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://st-gitlab-dummy.eni.com/api/v4/users?username=EXT2048100 | sed -e 's/{/,/g' -e 's/}/,/g' | tr ',' '\n' | sed -e '/^$/d' | sed '1d' | sed '$d' | grep -v "\"id\":1" | grep -w "id" | awk -F':' '{print $2}'
#chiamata post: POST /users/:id/deactivate
