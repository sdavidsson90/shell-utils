# Unser conversation id - to bind cid to shell session
unset previous_response_id

chat_clear() {
  unset previous_response_id
}

chat() {
  local model="gpt-5.6-luna"
  local state_dir="${HOME}/.local/state/chat"
  local input
  local output
  mkdir -p "$state_dir"

  # --------------
  tput bold
  tput setaf 4
  echo "Sighvatur:"
  tput sgr0
  vared input
  echo ""

  # --------------

  # Build prompt call
  json="$(
    jq -n \
      --arg model "$model" \
      --arg input "$input" \
      --arg previous_response_id "$previous_response_id" \
      '{
          model: $model,
          input: $input
        }
        + if $previous_response_id != ""
        then { previous_response_id: $previous_response_id }
        else {}
        end'
  )"

  # Call API and retrieve output
  output="$(
    curl -sS "https://api.openai.com/v1/responses" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "$json"
  )"

  # --------------
  tput bold
  tput setaf 2
  echo "${model}:"
  tput sgr0
  previous_response_id=$(jq -r '.id' <<<"$output")
  jq -r '.output[]?.content[]? | select(.type == "output_text") | .text' <<<"$output" | glow -w 0
}
