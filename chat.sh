command -v zmodload > /dev/null 2>&1 || return 0

unset previous_response_id
alias c=chat

# ---------------------------------------------- #

# Put this in a trap if we have an error!

# Save responses differently:
# Each conversation: dir
# each iteration: file

chat() {

  # Settings
  local user="$USER"
  local state_dir="${HOME}/.local/state/chat"
  local model=$(<"${HOME}/.local/state/chat/.model")

  # Text formatting
  bold="$(tput bold)"
  blue="$(tput setaf 4)"
  green="$(tput setaf 2)"
  reset="$(tput sgr0)"

  model_selector() {
    local model=$(
      curl -fsS https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY" |\
        jq -r '(["id","created"] | @tsv), (.data | sort_by(.created) | reverse[] | [.id, (.created | gmtime | strftime("%Y-%m-%d"))] | @tsv)' |\
        column -t -s $'\t' |\
        fzf --delimiter='[[:space:]]+' --accept-nth=1 --header-lines=1 --header='Select model'
      )
      printf '%s\n' "$model" > "$state_dir/.model"
      printf 'Now using: %s\n' "$model"
  }

  new_conversation() {
    # ----
    # Clear session variables to prepare a new conversation
    # ----
    unset conversation_id
    unset response_id
    echo "Ready for new conversation!"
  
  }

  read_user_input() {
    printf '%s%s%s%s\n' ${bold} ${blue} "${user}" ${reset}
    vared user_input
  }

  init_conversation() {
    # Put sections here:
    # INIT_PROMPT=
  }

  chat_call() {

    local INIT_PROMPT
    INIT_PROMPT+="My name is ${user}."
    INIT_PROMPT+="I live in Aalborg, Denmark."
    INIT_PROMPT+="Today's date is $(date)."

    INIT_PROMPT+="You will answer as concisely and precicesly as possible."
    INIT_PROMPT+="If I ask a simple question. Provide a simple answer."
    INIT_PROMPT+="My OS is $(uname)"

    # Read user input
    local user_input
    read_user_input

    # Temporary request marker (... the API is being called)
    printf '%s%s\n%s%s\n' "${bold}" "${green}" "🤖 ..." "${reset}"

    if [[ -z $conversation_id ]]; then
      local conversation_json="$(
        curl -sS "https://api.openai.com/v1/conversations" \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer $OPENAI_API_KEY" \
          -d '{}'
      )"
      [[ $? -ne 0 ]] && return 1
      export conversation_id="$(jq -r '.id' <<<$conversation_json)"
    fi

    local chat_request="$(
      jq -n \
        --arg model "$model" \
        --arg input "$user_input" \
        --arg instructions "$INIT_PROMPT" \
        --arg conversation "$conversation_id" \
        '{
          model: $model,
          input: $input,
          instructions: $instructions,
          conversation: $conversation,
        }'
    )"

    local chat_response="$(
      curl -sS "https://api.openai.com/v1/responses" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$chat_request"
    )"
    [[ $? -ne 0 ]] && return 1

    # Print response output
    local glow_stylesheet="${HOME}/Dropbox/it/ssd_env/config/shell/custom/chat/glow-stylesheet.json"
    local chat_response_id=$(jq -r '.id' <<<"$chat_response")
    local chat_response_output=$(jq -r '.output[]?.content[]? | select(.type == "output_text") | .text' <<<"$chat_response")

    printf '%s%s%s' "$(tput cuu1)" "$(tput cr)" "$(tput el)"                      # Remove temporary request marker
    printf '%s%s%s%s' ${bold} ${green} "🤖 ${model} [$(date +%H:%M:%S)]" ${reset} # AI response header
    printf '%s' "$chat_response_output" | glow -w 0 -s "$glow_stylesheet"              # AI response output

    # ----------------------
    # Log conversation

    log_conversation() {

      # First we need to determine if we are initiating a conversation,
      # or if if we are in the middle of one:
      conversation_dir=$(fd -t f -Hg ".${conversation_id}" -ax dirname)
      if [[ -z "$conversation_dir" ]]; then

        local summary_request="$(
          jq -n \
            --arg model "$model" \
            --arg previous_response_id "$chat_response_id" \
            '{
              model: $model,
              previous_response_id: $previous_response_id,
              input: "
              Summarize what you are trying to explain concicely as possible.
              Do not use markdown formatting - only plain text.
              You may not use newline characters.
              You may use 60 characters.

              You will first decide on a header (1-4 words).
              The purpose of the header is to give a hint on what the topic is about.
              This means that the chosen words should be as specific as possible - rather than generic.
              Header should end in a colon.

              After header, we will have a subheader.
              This should accurately and concisely recap the topic of the conversation.
              It should complement the previous header - ie provide more details, while being concise and not repeating the previous header.
              "
            }'
        )"

        local summary_json=$(
          curl -sS "https://api.openai.com/v1/responses" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d "$summary_request"
        )
        [[ $? -ne 0 ]] && return 1

        local summary=$(
          jq -r '.output[]?.content[]? | select(.type == "output_text") | .text' <<<"${summary_json}"
        )
        
        local conversation_dir="${state_dir}/${summary}"

      fi

      mkdir -p "$conversation_dir"
      
      # Log the entry
      logfile="${conversation_dir}/$(date '+%Y-%m-%d_%H:%M:%S').md"
      printf '%s\n' "# $user:" >>"$logfile"
      printf '%s\n\n' "$user_input" >>"$logfile"
      printf '%s\n' "# ${model}:" >>"$logfile"
      printf '%s\n' "$chat_response_output" >>"$logfile"

      # Metadata
      printf "%s\n" "$conversation_id" >"${conversation_dir}/.${conversation_id}"

    }

    [[ -z ${chat_response+x} ]] && return 1
    [[ -z ${conversation_id+x} ]] && return 1
    log_conversation &!
    printf '%s%s%s' "$(tput cuu1)" "$(tput cr)" "$(tput el)" # Remove superfluous newline

  }


  continue_conversation() {

    local preview='conversation=$(printf "%s\n" {} | cut -c 22-); fd --hidden --type f --max-depth 1 --extension md . "$state_dir/$conversation" --exec glow --width "$FZF_PREVIEW_COLUMNS"'
    local selected_conversation=$(
      fd --base-directory "$state_dir" \
        --type d \
        --max-depth 1 \
        --strip-cwd-prefix . \
        --exec-batch stat -f '%Sm  %N' -t '%Y-%m-%d %H:%M:%S' |\
        sort -r |\
        state_dir="$state_dir" fzf --no-sort --preview-window=follow --preview $preview|
        cut -c 22-
    )

    [[ -n "$selected_conversation" ]] || return 1
    printf '%s%s%s\n' "$bold" "Continuing the following conversation:" "$reset"
    echo "$selected_conversation"
    conversation_id=$(fd --hidden --type f --max-depth 1 --format '{/}' '^\.conv_' "$state_dir/$selected_conversation"|sed 's/^\.//')
  }

  # -------------------------------------------------#
  case "${1-}" in
  "")
    chat_call
    ;;
  -c)
    continue_conversation
    ;;
  -m)
    model_selector
    ;;
  -n)
    new_conversation
    ;;
  esac

}
