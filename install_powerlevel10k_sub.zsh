#!/usr/bin/env zsh
#!/bin/zsh

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "\n \033[01;7m*** 2 ERROR TRAP $THISSCRIPTNAME \n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \n ERR ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". exit  ${__trapped_error_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit ${__trapped_INT_num}
  }
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

    emulate -L zsh -o xtrace -o err_return
    ZDOTDIR=/no/such/dir command zsh -ic '[[ $ZDOTDIR == /no/such/dir ]]'
    command mkdir -p -- ~/zsh-backup
    local rc
    for rc in ~/.zshenv ~/.zprofile ~/.zshrc ~/.zlogin ~/.zlogout ~/.oh-my-zsh; do
      [[ -e $rc ]] || continue
      [[ ! -e ~/zsh-backup/${rc:t} ]] || {
        command rm -rf -- $rc
        continue
      }
      command rm -rf -- ~/zsh-backup/${rc:t}.tmp.$$
      command cp -r -- $rc ~/zsh-backup/${rc:t}.tmp.$$
      command mv -- ~/zsh-backup/${rc:t}.tmp.$$ ~/zsh-backup/${rc:t}
      command rm -rf -- $rc
    done
    command git clone -- https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    command git clone --depth=1 -- https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
    command git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
    command git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    command git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    command sed -- 's|robbyrussell|powerlevel10k/powerlevel10k|' ~/.oh-my-zsh/templates/zshrc.zsh-template >~/.zshrc
    ZDOTDIR=~ exec zsh -i
  # }



