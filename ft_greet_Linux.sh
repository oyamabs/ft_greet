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

APP_ID="YOUR TOKEN"
APP_SECRET="YOUR TOKEN"

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

TOKEN_RESP=$(curl -s -X POST --data "grant_type=client_credentials&client_id=$APP_ID&client_secret=$APP_SECRET" https://api.intra.42.fr/oauth/token)
TOKEN=$(echo "$TOKEN_RESP" | jq -r '.access_token')
if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
	echo "Failed to get an access token from the 42 API: $(echo "$TOKEN_RESP" | jq -r '.error_description // .error // .message // "unknown error"')" >&2
	exit 1
fi

RAW_HTTP=$(curl -s -w "HTTP_CODE:%{http_code}" -H "Authorization: Bearer $TOKEN" https://api.intra.42.fr/v2/users/$USER)
HTTP_CODE=${RAW_HTTP##*HTTP_CODE:}
RAW_JSON=${RAW_HTTP%HTTP_CODE:*}
if ! echo "$RAW_JSON" | jq -e '.login' >/dev/null 2>&1; then
	MSG=$(echo "$RAW_JSON" | jq -r '.error_description // .message // .error')
	[[ -z "$MSG" || "$MSG" == "null" ]] && MSG="unexpected response (HTTP $HTTP_CODE)"
	echo "42 API error: $MSG" >&2
	exit 1
fi

LOGIN=$(echo "$RAW_JSON" | jq -r '.login')
CORREC_POINTS=$(echo "$RAW_JSON" | jq '.correction_point')
WALLET=$(echo "$RAW_JSON" | jq '.wallet')
LOCATION=$(echo "$RAW_JSON" | jq -r '.location // "off campus"')
CAMPUS=$(echo "$RAW_JSON" | jq -r '.campus[0].name // "unknown campus"')
FINISHED_PROJ=$(echo "$RAW_JSON" | jq '.projects_users | length')
LOGTIMES=$(curl -s -G -H "Authorization: Bearer $TOKEN" "https://api.intra.42.fr/v2/users/$USER/locations" --data-urlencode "range[begin_at]=$(date -I),$(date -I -d "+1 days")")
TOTAL_SECONDS=$(echo "$LOGTIMES" | jq '
  if type != "array" then 0 else
    def parse_date: sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601;
    [ .[]? |
      ((.end_at? // (now | todate)) | parse_date) -
      ((.begin_at? // (now | todate)) | parse_date)
    ] | add // 0 | floor
  end
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
