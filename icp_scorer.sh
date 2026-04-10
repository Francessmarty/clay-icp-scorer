#!/bin/bash



CSV_FILE="$1"

if [[ -z "$CSV_FILE" ]]; then
  echo "Usage: bash icp_scorer.sh <csv_file>"
  exit 1
fi

if [[ ! -f "$CSV_FILE" ]]; then
  echo "File not found: $CSV_FILE"
  exit 1
fi

if [[ -f ".env" ]]; then
  source .env
fi

if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
  echo "Error: SLACK_WEBHOOK_URL not set in .env"
  exit 1
fi

parse_csv_line() {
  local line="${1%$'\r'}"  # strip carriage return for CRLF files
  local field=""
  local in_quotes=false
  local i=0
  local char
  _CSV_FIELDS=()

  while [[ $i -lt ${#line} ]]; do
    char="${line:$i:1}"
    if [[ "$in_quotes" == true ]]; then
      if [[ "$char" == '"' ]]; then
        if [[ "${line:$((i+1)):1}" == '"' ]]; then
          # escaped quote ("") — append one literal quote
          field+="$char"
          ((i++))
        else
          in_quotes=false
        fi
      else
        field+="$char"
      fi
    else
      if [[ "$char" == '"' ]]; then
        in_quotes=true
      elif [[ "$char" == ',' ]]; then
        _CSV_FIELDS+=("$field")
        field=""
      else
        field+="$char"
      fi
    fi
    ((i++))
  done
  _CSV_FIELDS+=("$field")
}

HEADER=true
declare -A COL
HOT_COUNT=0

while IFS= read -r line; do
  parse_csv_line "$line"
  fields=("${_CSV_FIELDS[@]}")

  if [[ "$HEADER" == true ]]; then
    HEADER=false
    for i in "${!fields[@]}"; do
      COL["${fields[$i]}"]=$i
    done
    continue
  fi

  NAME="${fields[${COL["Full Name"]}]}"
  TITLE="${fields[${COL["Job Title"]}]}"
  COMPANY="${fields[${COL["Company Name"]}]}"
  LOCATION="${fields[${COL["Location"]}]}"
  EMPLOYEES="${fields[${COL["Employee Count"]}]}"
  INDUSTRY="${fields[${COL["Industry"]}]}"
  FUNDING="${fields[${COL["Funding Stage"]}]}"
  LINKEDIN="${fields[${COL["LinkedIn Profile"]}]}"

  SCORE=0

  if echo "$TITLE" | grep -iqE "founder|ceo|vp|director|head|gtm|revops|revenue|growth|coo|cto"; then
    SCORE=$((SCORE + 2))
  fi

  if echo "$LOCATION" | grep -iqE "united kingdom|united states|canada|england|london|toronto"; then
    SCORE=$((SCORE + 1))
  fi

  EMP_NUM=$(echo "$EMPLOYEES" | tr -dc '0-9')
  if [[ -n "$EMP_NUM" ]] && [[ "$EMP_NUM" -ge 10 ]] && [[ "$EMP_NUM" -le 500 ]]; then
    SCORE=$((SCORE + 1))
  fi

  if echo "$INDUSTRY" | grep -iqE "saas|software|tech|ai|b2b|digital"; then
    SCORE=$((SCORE + 2))
  fi

  if echo "$FUNDING" | grep -iqE "seed|series a|series b|series c|bootstrapped"; then
    SCORE=$((SCORE + 1))
  fi

  if [[ -n "$LINKEDIN" ]]; then
    SCORE=$((SCORE + 1))
  fi

  echo "Name: $NAME | Score: $SCORE / 7"

  if [[ "$SCORE" -ge 5 ]]; then

    HOT_COUNT=$((HOT_COUNT + 1))

    SLACK_MESSAGE="{
      \"text\": \"🔥 Hot Lead Detected\",
      \"blocks\": [
        {
          \"type\": \"section\",
          \"text\": {
            \"type\": \"mrkdwn\",
            \"text\": \"*🔥 Hot Lead: $NAME*\n*Title:* $TITLE\n*Company:* $COMPANY\n*Location:* $LOCATION\n*Industry:* $INDUSTRY\n*Funding:* $FUNDING\n*Score:* $SCORE / 7\n*LinkedIn:* $LINKEDIN\"
          }
        }
      ]
    }"

    curl -s -X POST -H 'Content-type: application/json' \
      --data "$SLACK_MESSAGE" \
      "$SLACK_WEBHOOK_URL"

    echo " --> Sent to Slack"
  fi

done < "$CSV_FILE"

echo ""
echo "Done. $HOT_COUNT hot lead(s) sent to Slack."