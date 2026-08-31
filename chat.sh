# Unset - to bind this id to shell session
unset previous_response_id
unset conv_id

chat() {

  chat_clear() {
    # --
    # Clear this variable, to allow for a new conversation
    # --
    unset previous_response_id
    unset conv_id
  }

  chat_list_models() {
    # --
    # Print a list of available models
    # --
    curl -sS https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY" | jq -r '(["id","created"] | @tsv), (.data[] | [.id, (.created | gmtime | strftime("%Y-%m-%d"))] | @tsv)' | column -t -s $'\t'
  }

  chat_call() {
    local model="gpt-5.6-luna"
    local user="Sighvatur"
    local input
    local response
    local state_dir="${HOME}/.local/state/chat"
    [[ -z $conv_id ]] && conv_id="$(date +%s)"
    conv_log="${state_dir}/${conv_id}"
    mkdir -p "$state_dir"

    # ---------------
    # Read user input
    tput bold
    tput setaf 4
    printf '%s\n' "${user}:"
    tput sgr0
    vared input

    # -----------------
    # Build prompt call
    request_payload="$(
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

    # ------------------------------
    # Call API and retrieve response
    response="$(
      curl -sS "https://api.openai.com/v1/responses" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$request_payload"
    )"

    # ---------------------
    # Parse response output
    tput bold
    tput setaf 2
    printf '\n%s\n' "${model}:"
    tput sgr0
    output=$(jq -r '.output[]?.content[]? | select(.type == "output_text") | .text' <<<"$response")
    printf '%s\n' "$output" | glow -w 0

    # Save the response_id as shell variable (to allow for continuing the conversation)
    previous_response_id=$(jq -r '.id' <<<"$response")

    # ----------------
    # Log conversation
    printf '# -- %s%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" ' --------------------' >>$conv_log
    printf '%s\n\n' "${user}:" >>"$conv_log"
    printf '%s\n\n' "$input" >>"$conv_log"
    printf '%s\n\n' "AI response (${model})" >>"$conv_log"
    printf '%s\n\n' "$output" >>"$conv_log"
  }

  # ------------------------------------------------------
  case "${1-}" in
  "")
    chat_call
    ;;
  -l)
    chat_list_models
    ;;
  -c)
    chat_clear
    ;;
  esac
}
