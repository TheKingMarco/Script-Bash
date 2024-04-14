#!/bin/bash

################################################################################################################
# Script Name	: add-remove-users-from-group.sh
#		  
# Description	: 
#
# Usage         : 
# 
# Version       : 1.0
#
# Author        : Marco Oliva (m.oliva@avanade.com)
################################################################################################################


# ROLES GITLAB
# No access (0)
# Minimal access (5) (Introduced in GitLab 13.5.)
# Guest (10)
# Reporter (20)
# Developer (30)
# Maintainer (40)
# Owner (50). Valid for projects in GitLab 14.9 and later.

# ENI MAPPING GROUPS PEOPLE TO GITLAB ROLES
# Dev			            Developer
# Senior Dev	            Maintainer
# Architect		            Reporter
# Product Owner		        Reporter	
# Data Scientist	        Reporter
# Senior Data Scientist	    Reporter	
# Security		            Guest	

#################################################################
#  TO DO:
#
#  1) completa parte relativa all'aggiunta o rimozione di un utente da un gruppo
#  2) implementare una variabile che a seconda della valorizzazione (template_agile),
#     ad esempio va ad utilizzare una la struttura people e gruppi
#     pero dato che non tutti gli applicativi lo utilizzano,
#     devi prevedere l'inserimento di un utente con un ruolo specifico in un gruppo specifico,
#     come script di reply prendi spunto da li. Poi documenta il tutto perche comunque dovrai cambiare anche il file da passare allo script.
#
##################################################################

#####################################
# GLOBAL VARIABLES
#####################################

gitlab_token=$2
input_file=$3
group_people_id=$4
fqdn_gitlab="st-gitlab-dummy.eni.com"
DATE=$(date +'%d/%m/%Y %H:%M')

# To use on new version of script , only if we can create a SP on azure that have the permission on EntraID to get all the information of the users from azure using microsoft graph api.
# tenant_id="c16e514b-893e-4a01-9a30-b8fef514a650"
# client_id="06cf5060-a7eb-40b2-88ea-9d9eb475e9a0"
# client_secret="<secrets>"


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
On_IBlue='\033[0;104m'
On_IGreen='\033[0;102m'
BIWhite='\033[1;97m'
BICyan='\033[1;96m'  
NC='\033[0m' # No Color

#Mapping Group role with ID
no_access=0
minimal_access=5
guest=10
reporter=20
developer=30
maintainer=40
owner=50
######################################
# FUNCTIONS
######################################

############ LOG FUNCTIONS ################
log_message() {
    echo "$DATE $1"
}
# Function to log error messages with color
log_error() {
    echo -e "$DATE ${RED}Error:${NC} $1"
}

# Function to log error messages with color
log_warning() {
    echo -e "$DATE ${YELLOW}Warning:${NC} $1"
}

# Function to log success messages with color
log_success() {
    echo -e "$DATE ${GREEN}Success:${NC} $1"
}

log_evidence() {
    echo -e "$DATE ${On_IGreen}Success: $1${NC}"
}
###############################################

#Display the usage information for the script and exit with status 1.
function usage {
  log_error "Usage: $0 {check|add_revome|active_deactive} <gitlab_token> <user.json> <group_people_id>"
  exit 1
}

#####################################

function add_remove_users () {

while read -r line; do

    user=$(echo "$line" | jq -r '.user')
    group=$(echo "$line" | jq -r '.group')
    action=$(echo "$line" | jq -r '.action')
    echo -e "--------Processin User: ${On_IBlue}$user${NC} ------------------"

    check_user $user

    echo "--------Starting Add or Remove User: $user------------"

    if [[ "$group" == "Devs" ]]; then
        role=$developer
        group_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/groups/$group_people_id/subgroups?search=devs" | jq '.[] | select(.name == "Devs") | .id')
    elif [[ "$group" == "Senior Devs" ]]; then
        role=$maintainer
        group_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/groups/$group_people_id/subgroups?search=senior-devs | jq '.[].id')
    elif [[ "$group" == "Architects" ]]; then
        role=$reporter
        group_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/groups/$group_people_id/subgroups?search=platform-admins | jq '.[].id')
    elif [[ "$group" == "Product Owners" ]]; then
        role=$reporter
        group_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/groups/$group_people_id/subgroups?search=product-owners | jq '.[].id')
    elif [[ "$group" == "Security" ]]; then
        role=$reporter
        group_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/groups/$group_people_id/subgroups?search=security | jq '.[].id')
    else
        log_error "group insert on file not supported: $group"
        exit 
    fi

    path_project=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/groups/$group_people_id | jq '.web_url')
    
    if [[ "$action" == "add" ]]; then
        log_warning "action chosen is: ${BICyan}$action${NC} user:  ${BICyan}$user${NC} in group: ${BICyan}$group${NC} in project:  ${BICyan}$path_project${NC}"
        #echo "TEST VAR: curl -kSsL --request POST --header PRIVATE-TOKEN: ${gitlab_token} --data user_id=$get_user_id&access_level=$role https://$fqdn_gitlab/api/v4/groups/$group_id/members"
        curl -kSsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" --data "user_id=$get_user_id&access_level=$role" "https://$fqdn_gitlab/api/v4/groups/$group_id/members"
        echo ""
        members_check=$(curl -kSsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/groups/$group_id/members?user_ids=$get_user_id" | jq '.[].id')
        members_access_level=$(curl -kSsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/groups/$group_id/members?user_ids=$get_user_id" | jq '.[].access_level')
        if [[ -n "$members_check" ]]; then
            log_success "User: $user, is present on Group: $group , of the project: $path_project, with access_level: $members_access_level"
        else
            log_error "User: $user , not added or not present"
        fi
    fi
    if [[ "$action" == "remove" ]]; then
        log_warning "action chosen is: ${BICyan}$action${NC} user:  ${BICyan}$user${NC} in group: ${BICyan}$group${NC} in project:  ${BICyan}$path_project${NC}"
        curl -kSsL --request DELETE --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/groups/$group_id/members/$get_user_id"
        echo ""
        members_check=$(curl -kSsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/groups/$group_id/members?user_ids=$get_user_id" | jq '.[].id')
        members_access_level=$(curl -kSsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/groups/$group_id/members?user_ids=$get_user_id" | jq '.[].access_level')
        if [[ -z "$members_check" ]]; then
            log_success "User: $user, is not present on Group: $group , of the project: $path_project, with access_level: $members_access_level"
        else
            log_error "User: $user , not removed or still present"
        fi
    fi
    
done < <(jq -c '.[]' $input_file)

}

function check_user () {

local user=$1

get_user_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].id')

if [[ -z "$get_user_id" ]]; then
    log_warning "User: $user dosen't exist on Gitlab"
    log_warning "Do you want to create it? (Y/N)"
    read answare < /dev/tty
    echo ""
    if [[ $answare =~ ^[Yy]$ ]]; then
        log_message "---------Starting User Creation----------"
        echo ""
        create_user $user
    fi
else
    get_name_user=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].name')
    get_email_user=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].email')
    get_created_at_user=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].created_at')
    get_state_user=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].state')

    log_message "User: $user already exist on Gitlab with this information: "
    log_message "ID: $get_user_id, NAME: $get_name_user, EMAIL: $get_email_user, STATE: $get_state_user, CREATE_DATE: $get_created_at_user"

    if [[ "$get_state_user" == "\"deactivated\"" ]]; then
        log_warning "The status of the User: $user is $get_state_user"
        log_warning "We are activating the status..."
        curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/activate"
        echo ""
        log_message "ID: $get_user_id, NAME: $get_name_user, EMAIL: $get_email_user, STATE: $get_state_user, CREATE_DATE: $get_created_at_user"
    fi
fi
}

function create_user () {

############################################################################
# Section to get information from Azure , in automatic way,
# at the moment we cant do this because we need a SP that have permission
# to generate a token that have grant to get all the user information
############################################################################

## Request access token using client credentials grant flow
# token_response=$(curl -s -X POST "https://login.microsoftonline.com/$tenant_id/oauth2/v2.0/token" \
#      -d "client_id=$client_id" \
#      -d "scope=https://graph.microsoft.com/.default" \
#      -d "client_secret=$client_secret" \
#      -d "grant_type=client_credentials")

# if [[ -z "$token_response" ]]; then
#     log_error "Token empty: $token_response"
#     log_warning "Skip User Creation"
# else
#     access_token=$(echo $token_response | jq -r '.access_token')
#     echo ""
#     log_success "Access Token: $access_token"
#     echo ""
#     get_user_principal_name=$(curl -s -H "Authorization: Bearer $access_token" https://graph.microsoft.com/v1.0/users?search="displayName:Oliva Marco")
#     graph_endpoint="https://graph.microsoft.com/v1.0/users/$user_principal_name/contacts"
#     contacts=$(curl -s -H "Authorization: Bearer $access_token" $graph_endpoint)
#     echo "Contacts:"
#     echo $contacts | jq .
# fi

local user=$1
echo "[NOT accepted domain]: (@external.identity.eni.com)"
log_message "Insert email for User, $user: "
read email < /dev/tty
echo ""
log_message "Insert name (ex: Mario Rossi): "
read name < /dev/tty
echo ""
curl -kSsL --request POST --header 'Authorization: Bearer '$gitlab_token'' --data "email=$email&name=$name&username=$user&reset_password=true" "https://$fqdn_gitlab/api/v4/users"
get_user_id=$(curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://$fqdn_gitlab/api/v4/users?search=$user | jq '.[].id')
if [[ -z "$get_user_id" ]]; then
    echo ""
    log_error "User: $user, not created"
else
    echo ""
    log_success "User: $user, created with UserID: $get_user_id"
fi
}

# active_deactive () {
#     if [[ "$choice" == "deactivate" ]]; then
#         echo "Deactivate User: $user"
#         curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/deactivate"
# 	echo ""
#     fi

#     if [[ "$choice" == "activate" ]]; then
#         echo "Activate User: $user"
#         curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/activate"
#         echo ""
#     fi
# }


####################################
# MAIN
####################################

if [ "$#" -ne 4 ]; then
    usage
fi

case "$1" in
    check)
    # STARTING CHEK
    echo "$1"
    ;;
    add_remove)
    # STARTING ADDING AND RMOVING
    echo "----------Start script to add and remove user from gitlab group------------"
    echo ""
    add_remove_users 
    ;;
    active_deactive)
    # STARTING active AND deactive
    echo "$1"
    ;;
    *)
    usage
    ;;
esac



# cat $input_file | while read line; do
#  echo $line
# done


# cat $input_file | while read line; do

#     user=$(echo $line | cut -d' ' -f1)
#     choice=$(echo $line | cut -d' ' -f2)
#     check_user

#     echo "------ Processing user: $user with User ID: $get_user_id ------"
#     echo "Choice: $choice"

#     if [[ "$choice" == "deactivate" ]]; then
#         echo "Deactivate User: $user"
#         curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/deactivate"
#         echo ""
#     fi

#     if [[ "$choice" == "activate" ]]; then
#         echo "Activate User: $user"
#         curl -k -SsL --request POST --header "PRIVATE-TOKEN: ${gitlab_token}" "https://$fqdn_gitlab/api/v4/users/${get_user_id}/activate"
#         echo ""
#     fi
# done

#curl -k -SsL --request GET --header "PRIVATE-TOKEN: ${gitlab_token}" https://st-gitlab-dummy.eni.com/api/v4/users?username=EXT2048100 | sed -e 's/{/,/g' -e 's/}/,/g' | tr ',' '\n' | sed -e '/^$/d' | sed '1d' | sed '$d' | grep -v "\"id\":1" | grep -w "id" | awk -F':' '{print $2}'
#chiamata post: POST /users/:id/deactivate
# curl -kSsL --request POST --header 'Authorization: Bearer '$token'' --data "email=$email&name=$name&username=$usr&reset_password=true" 'https://st-gitlab-dummy.eni.com/api/v4/users'
