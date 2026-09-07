#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    greet.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tchampio <tchampio@student.42lehavre.fr>   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/09/05 20:36:59 by tchampio          #+#    #+#              #
#    Updated: 2026/09/05 20:44:35 by tchampio         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

APP_ID=
APP_SECRET=

function check_bin()
{
	which $1 >/dev/null 2>&1

	if [[ $? != 0 ]]; then
		echo "$1 not found, exitting"
		exit 1
	fi
}

check_bin curl
check_bin jq

TOKEN=$(curl -s -X POST --data "grant_type=client_credentials&client_id=$APP_ID&client_secret=$APP_SECRET" https://api.intra.42.fr/oauth/token | jq .access_token | sed s/\"//g)
RAW_JSON=$(curl -s -H "Authorization: Bearer $TOKEN" https://api.intra.42.fr/v2/users/$USER)
LOGIN=$(echo $RAW_JSON | jq .login | sed s/\"//g)
CORREC_POINTS=$(echo $RAW_JSON | jq .correction_point)
WALLET=$(echo $RAW_JSON | jq .wallet)
LOCATION=$(echo $RAW_JSON | jq .location | sed s/\"//g)
CAMPUS=$(echo $RAW_JSON | jq '.campus | .[] | .name' | sed s/\"//g)
FINISHED_PROJ=$(echo $RAW_JSON | jq '.projects_users | length')
LOGTIMES=$(curl -s -G -H "Authorization: Bearer $TOKEN" "https://api.intra.42.fr/v2/users/$USER/locations" --data-urlencode "range[begin_at]=$(date -u -Idate),$(date -u -Idate -v+1d)")
TOTAL_SECONDS=$(echo "$LOGTIMES" | jq '
  def parse_date: sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601;
  [ .[] | 
    ((.end_at // (now | todate) | parse_date) - (.begin_at | parse_date))
  ] | add // 0 | floor
  ')
HOURS=$((TOTAL_SECONDS / 3600))
MINUTES=$(( (TOTAL_SECONDS % 3600) / 60 ))
SECONDS=$((TOTAL_SECONDS % 60))
RANDOM_COLOR=$((31 + $RANDOM % 6))

printf "[ WELCOME $LOGIN ]\n"
printf "\033[0;${RANDOM_COLOR}m        :::      ::::::::\033[0m               \n"
printf "\033[0;${RANDOM_COLOR}m      :+:      :+:    :+:\033[0m               Evaluation points: $CORREC_POINTS\n"
printf "\033[0;${RANDOM_COLOR}m    +:+ +:+         +:+\033[0m                            Wallet: $WALLET\n"
printf "\033[0;${RANDOM_COLOR}m  +#+  +:+       +#+\033[0m                             Location: $LOCATION\n"
printf "\033[0;${RANDOM_COLOR}m+#+#+#+#+#+   +#+\033[0m                       Finished projects: $FINISHED_PROJ\n"
printf "\033[0;${RANDOM_COLOR}m     #+#    #+#\033[0m                        Logtime of the day: %02dh %02dm %02ds\n" $HOURS $MINUTES $SECONDS
printf "\033[0;${RANDOM_COLOR}m    ###   ########\033[0m $CAMPUS      \n"
