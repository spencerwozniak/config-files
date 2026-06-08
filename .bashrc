# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Prompt: every non-printing sequence must be in \[ \] so readline/history length is correct.
# Using \033 (not \e) for portability. Prevents up-arrow history display bugs.
export PS1='[ \[\033[0;32m\]\u \[\033[0;34m\]\W \[\033[0m\]]\[\033[0m\]$ '

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# # If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Prevent PROMPT_COMMAND from corrupting readline/history (e.g. dynamic prompts that echo).
# Must run last so it clears any PROMPT_COMMAND set by completion or other sourced files.
unset PROMPT_COMMAND 2>/dev/null
export PATH="$HOME/.npm-global/bin:$PATH"

# OpenClaw completion
[ -f "$HOME/.openclaw/completions/openclaw.bash" ] && source "$HOME/.openclaw/completions/openclaw.bash"

# opencode
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Google Cloud / Vertex AI (fill in your own values)
# export GOOGLE_CLOUD_PROJECT="<your-gcp-project-id>"
# export VERTEX_REGION="<your-region>"

# --- AWS MFA helpers ---------------------------------------------------------
# Set these to your own values (e.g. in ~/.bash_aliases or a local, untracked file):
#   export AWS_MFA_SERIAL="arn:aws:iam::<account-id>:mfa/<device-name>"

# Trade an MFA token for temporary session credentials and cache them.
# Usage: mfa <mfa-token>
mfa() {
  local token=$1
  : "${AWS_MFA_SERIAL:?set AWS_MFA_SERIAL to your MFA device ARN}"

  local output
  output=$(aws sts get-session-token \
    --serial-number "$AWS_MFA_SERIAL" \
    --token-code "$token") || { echo "get-session-token failed"; return 1; }

  export AWS_ACCESS_KEY_ID=$(echo "$output" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "$output" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "$output" | jq -r '.Credentials.SessionToken')
  local expiration
  expiration=$(echo "$output" | jq -r '.Credentials.Expiration')

  local account_id
  account_id=$(echo "$AWS_MFA_SERIAL" | cut -d: -f5)
  local cache_dir="$HOME/.aws-mfa-cache"
  mkdir -p "$cache_dir"
  cat > "$cache_dir/$account_id" <<EOF
# AWS MFA session for account $account_id; do not commit.
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
# expires:${expiration}
EOF
  chmod 600 "$cache_dir/$account_id"

  echo "MFA session active until $expiration"
}

# Log into another AWS account using a role + MFA in one step.
# Usage: assume-role <account-id> <role-name> <mfa-token> [session-name]
assume-role() {
  local account_id=$1
  local role_name=$2
  local token=$3
  local session_name=${4:-cli-session}
  : "${AWS_MFA_SERIAL:?set AWS_MFA_SERIAL to your MFA device ARN}"

  local role_arn="arn:aws:iam::${account_id}:role/${role_name}"

  # Clear any stale session vars so the base IAM user creds are used for the call
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

  local creds
  creds=$(aws sts assume-role \
    --role-arn "$role_arn" \
    --role-session-name "$session_name" \
    --serial-number "$AWS_MFA_SERIAL" \
    --token-code "$token" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]' \
    --output text) || { echo "assume-role failed"; return 1; }

  export AWS_ACCESS_KEY_ID=$(echo "$creds" | awk '{print $1}')
  export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | awk '{print $2}')
  export AWS_SESSION_TOKEN=$(echo "$creds" | awk '{print $3}')
  echo "Assumed ${role_arn} until $(echo "$creds" | awk '{print $4}')"
}
# -----------------------------------------------------------------------------

# Rust / cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Java 17 (added for Synthea/Gradle)
if [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
  export PATH="$JAVA_HOME/bin:$PATH"
fi
