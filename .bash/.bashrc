# === para#bash#.shared_bash#.bashrc ===
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
__append_block_to_file() {
    local file="$1"
    shift
    local block="$*"
    local first_line=$(printf '%s\n' "$block" | head -n 1)
    touch "$file"
    echo "in file: $file"
    if ! grep -Fxq "$first_line" "$file"; then
        echo -e "\n$block" >> "$file"
        echo "Appended block with first line: $first_line"
    else
        echo "Already exists by first line: $first_line"
    fi
}
ww_prepare_bash() {
__append_block_to_file "$HOME/.vimrc" \
'if (filereadable("/root/.config/.vimrc"))
    source /root/.config/.vimrc
endif'
__append_block_to_file "$HOME/.bashrc" \
'# ∙ww
alias src,,="source ~/.config/.ww/.bash/.bashrc"
HISTIGNORE=":  *:src,,:h:history:lfr*"
'
    cd ~
    if [ -f ~/lfrc_linux ]; then
        mv lfrc_linux lfrc && chmod 666 lfrc && mkdir --parents .config/lf/ && mv lfrc .config/lf/
        echo "moved lfrc_linux to ~/.config/lf/"
    fi
    cd ~
    printf "${BGreen}cp configs:${NC}\n"
    if [ -d .config/.ww/ ] && [ -f .config/.ww/.tmux.conf ]; then
        mkdir --parents .config/tmux/ && cp .config/.ww/.tmux.conf .config/tmux/
        echo "    cp ~/.config/.ww/.tmux.conf  ~/.config/tmux/"
    fi
    if [ -d .config/.ww/ ] && [ -f .config/.ww/lfrc_linux ]; then
        mkdir --parents .config/lf/ && cp .config/.ww/lfrc_linux .config/lf/lfrc
        echo "    cp ~/.config/.ww/lfrc_linux  ~/.config/lf/lfrc"
    fi
    if [ -d .config/.ww/ ] && [ -f .config/.ww/.vimrc ]; then
        cp .config/.ww/.vimrc  .config/
        echo "    cp ~/.config/.ww/.vimrc      ~/.config/.vimrc"
    fi
    printf "${BGreen}Downlowd lf and fzf:${NC}\n"
    echo "    wget https://github.com/gokcehan/lf/releases/download/r36/lf-linux-amd64.tar.gz"
	echo "    wget https://github.com/junegunn/fzf/releases/download/v0.65.1/fzf-0.65.1-linux_amd64.tar.gz"
    MY_FILE=~/lfrc_r33_linux_amd64
    if [ -f $MY_FILE ]; then
        if ! mv $MY_FILE /usr/bin/; then
            if mv $MY_FILE ~/.config/; then
                alias lfrc_r33_linux="~/.config/lfrc_r33_linux_amd64"
                echo "created alias for lfrc:"
                alias lfrc_r33_linux
            else
                echo "cant even move $FILE to ~/.config ???"
            fi
        else
            echo "moved $MY_FILE to /usr/bin/"
        fi
    fi
    MY_FILE=~/fzf-0.55.0-linux_amd64
    if [ -f $MY_FILE ]; then
        if ! mv $MY_FILE /usr/bin/fzf; then
            if mv $MY_FILE ~/.config/; then
                alias fzf="~/.config/fzf-0.55.0-linux_amd64"
                echo "created alias for fzf:"
                alias fzf
            else
                echo "cant even move $FILE to ~/.config ???"
            fi
        else
            echo "moved fzf to /usr/bin/"
        fi
    fi
}
get_git_branch() {
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "($branch)"
    else
        echo "(no git)"
    fi
}
__check_command() {
    if $@; then
        echo "Success: $@"
    else
        echo "FAIL: $@"
    fi
}
__copy_bashrc_to_cu_du() {
    __check_command cp /usr/bin/lfrc*  ~/cu/
    __check_command cp /usr/bin/lfrc*  ~/du/   
    __check_command cp /usr/bin/fzf  ~/cu/
    __check_command cp /usr/bin/fzf  ~/du/
    __check_command cp -pr ~/.config/ ~/cu/
    __check_command cp -pr ~/.config/ ~/du/
}
__copy_bashrc_to_du() {
    mkdir /var/log/pw-share/pods/stack/dunode02/.config/
    __check_command cp -pr ~/.config/ /var/log/pw-share/pods/stack/dunode02/
    __check_command cp /usr/bin/lfrc*  /var/log/pw-share/pods/stack/dunode02/.config/
    __check_command cp -pr ~/.config/lf/  /var/log/pw-share/pods/stack/dunode02/.config/
    __check_command cp /usr/bin/fzf  /var/log/pw-share/pods/stack/dunode02/.config/
    __check_command cp ~/.config/fzf*  /var/log/pw-share/pods/stack/dunode02/.config/
}
__copy_bashrc_to_cu() {
    __check_command cp /usr/bin/lfrc*  /var/log/pw-share/pods/stack/cunode01/
    __check_command cp ~/.config/lfrc*  /var/log/pw-share/pods/stack/cunode01/
    __check_command cp /usr/bin/fzf  /var/log/pw-share/pods/stack/cunode01/
    __check_command cp ~/.config/fzf*  /var/log/pw-share/pods/stack/cunode01/
    __check_command cp -pr ~/.config/ /var/log/pw-share/pods/stack/cunode01/
}
is_inside_pod() {
    if [ -n "$KUBERNETES_SERVICE_HOST" ] || [ -f "/var/run/secrets/kubernetes.io/serviceaccount/token" ]; then
        echo "You are inside a Kubernetes pod."
        return 0
    else
        echo "You are NOT inside a Kubernetes pod."
        return -1
    fi
}
move_files() {
    local file="$1"
    local dest_dir="$2"
    if [ ! -d "$dest_dir" ]; then
        echo "destination not exist: $dest_dir"
        return -1
    fi
    if [ -f "$file" ] || [ -d "$file" ]; then
        mv "$file" "$dest_dir"
        echo "Moved $file to $dest_dir"
    else
        echo "Skipping: $file (not a file or directory)"
    fi
}
if is_inside_pod; then
    if [ -d /var/log/.config/ ]; then
        cd /var/log/
        mv .config 
        move_files .config/   ~/
    fi
    if [ -d ~/.config/ ]; then
        cd ~/.config/
        move_files "lfrc_r33_linux_amd64"  "/usr/bin/"
        move_files "fzf"             "/usr/bin/"
    fi
fi
export VIMINIT='source $HOME/.config/.ww/.vimrc'
export IS_MY_VI_ENV=1  # for my vi
__source_file() {
    if [ -f $1 ]; then
        echo "source $1"
        . $1
    fi
}
    __source_file  ~/.config/.bash/.history
    __source_file  ~/.config/.bash/.vars
    __source_file  ~/.config/.bash/.commonFuncs.sh
    __source_file  ~/.config/.bash/.funcs01
    __source_file  ~/.config/.bash/.elapsed_time
    __source_file  ~/.config/.bash/threads_affinity.sh
    __source_file  ~/.config/.bash/ls_options.sh
        alias psef='__ls_grep "ps -ef"'
    __source_file  ~/.config/.bash/fzf01.sh
    __source_file  ~/.config/.bash/.PS1
    __source_file  ~/.config/.bash/.git_funcs
alias echo,,='printf "\n\n\n\n\n\n\n\n\n\n"'
alias nn='/root/.config/.ww/nr_setupTool_k8s.sh'

# === cygwin64#home#bashrc_s#.config#syntax_and_maps#lf_and_vim_mode.sh ===
set -o vi
export EDITOR=vim
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[47m\e[30m\2[I]\1\e[0m\2 '  # [I]
bind 'set vi-cmd-mode-string \1\e[43m\e[30m\2[N]\1\e[0m\2 '  # [N]
export LS_COLORS=$(echo "$LS_COLORS" | sed 's/tw=[^:]*://; s/ow=[^:]*://')

# === para#bash#.shared_bash#.PS1 ===
HOSTNAME_SHORT=$(hostname --short 2>/dev/null)
if [ -z "$HOSTNAME_SHORT" ]; then
    HOSTNAME_SHORT="??"
fi
SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "IP??")
    if [ -f /.dockerenv ]; then IS_DOCKER="DOCKER"; else IS_DOCKER=""; fi
    if [ -n "$TMUX" ]; then IS_TMUX=" tmux"; else IS_TMUX=""; fi
if [[ $HOSTNAME_SHORT == ildevdocker* ]]; then
    echo "hostname --short starts with 'ildevdocker'"
    PS1='\[\e[1;30;47m\] $SERVER_IP ● $(get_git_branch) ● #\#: $? ● \D{%H:%M:%S}'
    if [ -f /.dockerenv ]; then
        PS1+='\[\e[0m\]\n\[\e[1;100;40m\]\u@\h_DOCKER \[\e[0m\] \w/ →→'
    else
        PS1+='\[\e[0m\]\n\[\e[1;100;40m\]\u@\h \[\e[0m\] \w/ →→'
        PS1+='\[\e[0m\]\n\[\033[01;32m\]\u@\h \[\e[0m\] \w/ →→'
    fi
    PS1=''
    PS1+='● \[\e[1;30;46m\]$(get_git_branch) \[\e[1;100;40m\]\u@\h_DOCKER \[\e[1;30;47m\]\D{%Y-%m-%d  %H:%M:%S}\[\e[0m\] ● \[\e[1;30;46m\]● \h $SERVER_IP \[\e[0m\]\n'
    PS1+='● \w/ →→ '
    PS1='\[\033[01;32m\]\u@\h_DOCKER \[\e[1;30;47m\] $SERVER_IP ● $(get_git_branch) ● #\#: $? ● \D{%H:%M:%S} \[\e[0m\]\n'
    PS1='\[\033[01;32m\]\u@\h \[\e[1;30;47m\] $SERVER_IP ● $(get_git_branch) ● #\#: $? ● \D{%H:%M:%S} \[\e[0m\]\n'
    PS1+='$PWD/ →→'
else
    PS1='\[\e[1;34;46m\] $SERVER_IP \[\e[1;33;45m\] $(get_git_branch) \[\e[1;31;43m\] #\#: $? \[\e[1;34;46m\] \D{%H:%M:%S}'
    PS1='\[\e[1;30;46m\] $SERVER_IP \[\e[1;33;45m\] $(get_git_branch) \[\e[1;31;43m\] #\#: $? \[\e[1;30;46m\] \D{%H:%M:%S}'
    PS1+='\[\e[0m\]\n\[\e[1;100;43m\] \h \[\e[0m\] \w/ →→'
    PS1='\[\e[1;30;46m\] $SERVER_IP ● \D{%H:%M:%S} \[\e[1;33;45m\] $(get_git_branch) \[\e[1;31;43m\] #\#: $? '
    PS1+='\[\e[0m\]\n\[\e[1;100;43m\] \h \[\e[0m\] \w/ →→'
    PS1='● \h \[\e[1;30;47m\]● $SERVER_IP ● $(get_git_branch) ● #\#: $? ● \D{%H:%M:%S}'
    PS1+='\[\e[0m\]\n● \w/ →→'
    PS1='\[\e[1;30;46m\]● \h $SERVER_IP \[\e[1;30;47m\]● #\#: $? ● \D{%H:%M:%S}'
    PS1+='\[\e[0m\] \w/\n● →→'
fi
ps1_counter=2
ps1_toggle()
{
    PS1=''
    let "ps1_counter++"
    if (( 1 == ps1_counter )); then
        PS1+='\[\e[1;30;47m\]● \D{%Y-%m-%d  %H:%M:%S} ● #\#: [$?] ●\[\e[0m\]        \[\e[1;30;46m\]● \h $STY $SERVER_IP \[\e[0m\]'
        PS1+='\n● \w/ →→→'
    elif (( 2 == ps1_counter )); then
        PS1='\[\e[0;32m\]\w/ \[\e[0;31m\]($?) $IS_TMUX $IS_DOCKER \[\e[1;30;46m\] \h $STY $SERVER_IP \[\e[1;30;47m\] \D{%H:%M:%S}'
        PS1+='\[\e[0m\]\n#\#● →→→'
    elif (( 3 == ps1_counter )); then
        PS1='\[\e[0;33m\]\h $SERVER_IP \[\e[0;32m\]$PWD \[\e[0m\]\n'
        PS1+='\[\e[0;47;34m\]$IS_TMUX $IS_DOCKER →→→\[\e[0m\] '
    elif (( 4 == ps1_counter )); then
        PS1='\[\e[0;47;31m\]∟($?) \D{%H:%M:%S}\[\e[34m\] $IS_TMUX $IS_DOCKER\[\e[0;33m\] \h $SERVER_IP'
        PS1+='\n#\#● \[\e[0;32m\]$PWD \[\e[0m\]→→→'
    elif (( 5 == ps1_counter )); then
        PS1='\[\e[2;31m\]∟($?) \D{%H:%M:%S}\[\e[0;34m\] $IS_TMUX $IS_DOCKER\[\e[2;33m\] \h $SERVER_IP'
        PS1+='\n#\#● \[\e[0;32m\]$PWD \[\e[0m\]→→→'
    else
        PS1='\n#\#● →→→'
        let "ps1_counter=0"
    fi
    printf "\n    Current ps1_counter = $ps1_counter\n\n"
}
ps1_toggle_all_examples_not_working_of_course() {
    local start=$ps1_counter
    ps1_toggle
    sleep 0.3
    while (( ps1_counter != start )); do
        ps1_toggle
        sleep 0.3
    done
}
ps1_toggle && echo "ps1_toggle to change PS1"

# === para#bash#.shared_bash#.history ===
alias clr='clear -x'
alias h='history 10'
alias version='head /etc/os-release'
export TIME_STYLE=long-iso
HISTIGNORE=":  *:src,,:psef *:h:hh:history:[ ]*ls[ ]*:ls:ll:clear -x:clear:clr:pwd:version:date:[ ]*vim *:[ ]*alias *:alias:"
export HISTIGNORE
export HISTIGNORE="$HISTIGNORE:[a-zA-Z0-9][a-zA-Z0-9]:" # ignore 2-char commands
export HISTCONTROL=ignoredups:erasedups:ignorespace
unset PROMPT_COMMAND  # Disable immediate history writes: Then Bash only writes when the session exits → no interference.
shopt -s histappend  # So history appends instead of overwriting when multiple shells exit.
PROMPT_COMMAND='history -a; history -n'  # save/load history in prompt cycle
WW_HIST_DIR="$HOME/.config/.ww/.bash"
WW_HIST_MAIN="$WW_HIST_DIR/.bash_history"
WW_HIST_SESSION="$WW_HIST_DIR/.bash_history.$$.$(date +%s)"
mkdir -p "$WW_HIST_DIR"
touch "$WW_HIST_MAIN"
export HISTFILE="$WW_HIST_MAIN"
history -r
export HISTFILE="$WW_HIST_SESSION"
ww_history_merge() {
    history -a
    cat "$WW_HIST_SESSION" >> "$WW_HIST_MAIN"
    rm -f "$WW_HIST_SESSION"
}
trap ww_history_merge EXIT
pushd .
cd ~
echo "export HISTFILE=$WW_HIST_SESSION"
popd

# === para#bash#.shared_bash#.funcs01 ===
#!/bin/bash
PIDS=''
__show_proc_info()
{ #
    PATH_TO_FILE=$2
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return
    fi
    for PID in $PIDS; do
        RES=$(cat /proc/$PID/$PATH_TO_FILE)
        printf "$1:\n$RES\n"
        printf "======================\n"
    done
} #
show_proc_info()
{ #
    printf "$BGreen ___ DU ___\n$NC"
    PATH_TO_FILE=$1
    __show_proc_info "duoam"          $PATH_TO_FILE
    __show_proc_info "dumgr"          $PATH_TO_FILE
    __show_proc_info "gnb_du_e2du"    $PATH_TO_FILE
    __show_proc_info "gnb_du_layer2"  $PATH_TO_FILE
} #
check_process_sockets()
{ #
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return
    fi
    for PID in $PIDS; do
        socket_inodes=$(ls -l /proc/$PID/fd/ | grep socket | awk -F'[][]' '{print $2}')
        if [ -z "$socket_inodes" ]; then
            echo "No socket inodes found for PID $PID"
            continue
        fi
        echo "Found socket inodes for PID $PID:"
        echo "$socket_inodes"
        cd /proc/$PID/net/
        for inode in $socket_inodes; do
            egrep -rw "$inode" ./
            continue
            echo "Searching for inode: $inode"
            if grep -qw "$inode" /proc/$PID/net/tcp; then
                echo "TCP socket found for inode $inode"
            fi
            if grep -qw "$inode" /proc/$PID/net/udp; then
                echo "UDP socket found for inode $inode"
            fi
            if [ -f /proc/$PID/net/sctp ]; then
                if grep -qw "$inode" /proc/$PID/net/sctp; then
                    echo "SCTP socket found for inode $inode"
                fi
            fi
            if [ -d /proc/$PID/net/sctp ]; then
                if grep -rqw "$inode" /proc/$PID/net/sctp; then
                    echo "SCTP socket found for inode $inode"
                fi
            fi
        done
    done
} #
check_process_sockets()
{ #
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return
    fi
    for PID in $PIDS; do
        socket_inodes=$(ls -l /proc/$PID/fd/ | grep socket | awk -F'[][]' '{print $2}')
        if [ -z "$socket_inodes" ]; then
            echo "No socket inodes found for PID $PID"
            continue
        fi
        count=$(echo $socket_inodes | wc -w)
        echo "$1 -> Found $count sockets inodes for PID $PID:"
        for inode in $socket_inodes; do printf "$inode "; done
        printf "\n"
        cd /proc/$PID/net/
        for inode in $socket_inodes; do
            egrep -rw "$inode" ./
        done
    done
} #
check_process_sockets()
{ #
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return
    fi
    for PID in $PIDS; do
        socket_inodes=$(ls -l /proc/$PID/fd/ | grep socket | awk -F'[][]' '{print $2}')
        if [ -z "$socket_inodes" ]; then
            echo "No socket inodes found for PID $PID"
            continue
        fi
        count=$(echo $socket_inodes | wc -w)
        echo "$1 -> Found $count sockets for PID $PID:"
        cd /proc/$PID/net/
        for inode in $socket_inodes; do
            socket_info=$(egrep -rw "$inode" ./)
            if [ -n "$socket_info" ]; then
                protocol=$(echo "$socket_info" | cut -d: -f1)
                socket_number=$(echo "$socket_info" | awk '{print $9}')  # The socket number is in the 9th column for some files
                printf "  Socket inode: %-10s | Protocol: %-5s | Socket number: %-10s\n" "$inode" "$protocol" "$socket_number"
            fi
        done
    done
} #
check_process_sockets_2()  # only works inside pod?
{ #
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return
    fi
    for PID in $PIDS; do
        socket_info=$(ls -l /proc/$PID/fd/ | grep socket)
        if [ -z "$socket_info" ]; then
            echo "No socket inodes found for PID $PID"
            continue
        fi
        count=$(echo "$socket_info" | wc -l)
        echo "$1 -> Found $count sockets for PID $PID:"
        cd /proc/$PID/net/
        echo "$socket_info" | while read -r line; do
            fd=$(echo "$line" | awk '{print $9}' | cut -d'/' -f1)  # FD is the file descriptor
            inode=$(echo "$line" | awk -F'[][]' '{print $2}')  # Inode is inside the brackets
            socket_match=$(egrep -rw "$inode" ./)
            if [ -n "$socket_match" ]; then
                protocol=$(echo "$socket_match" | cut -d: -f1)
                socket_number=$(echo "$socket_match" | awk '{print $9}')  # Socket number (e.g., port)
                printf "  FD: %-5s | Socket inode: %-10s | Protocol: %-5s | Socket number: %-10s\n" "$fd" "$inode" "$protocol" "$socket_number"
            fi
        done
    done
} #
check_process_sockets_du()
{ #
    printf "\n${BGreen}===== PHY =====${NC}\n"
    check_process_sockets phymgr
    check_process_sockets gnb_app
    printf "\n${BGreen}===== DU =====${NC}\n"
    check_process_sockets duoam
    check_process_sockets dumgr
    check_process_sockets gnb_du_e2du
    check_process_sockets gnb_du_layer2
} #
check_process_sockets_cu()
{ #
    printf "\n${BGreen}===== CU =====${NC}\n"
    check_process_sockets gnb_cu_oam
    check_process_sockets gnb_cu_son
    check_process_sockets gnb_cu_rrm
    check_process_sockets gnb_cu_l3   # 2 sctp
    check_process_sockets gnb_cu_e2cu
    check_process_sockets gnb_cu_pdcp
} #
function __wait_until_file_exist()
{ #
    while true; do if [ -f "$1" ]; then echo "file exists"; break; else printf "Wait.. "; fi; sleep 1; done;
} #
function __wait_until_process_exist()
{ #
    PROCESS_NAME=$1
    while ! pidof "$PROCESS_NAME" > /dev/null; do
        printf "."
    done
    PIDS=$(pidof "$PROCESS_NAME")
    echo "$PROCESS_NAME is running! : $PIDS"
} #
get_cumulative_times()
{ #
    local stat_file="/proc/stat"
    local cpu_line=$(grep '^cpu ' "$stat_file")
    local utime=$(echo "$cpu_line" | awk '{print $2}')
    local stime=$(echo "$cpu_line" | awk '{print $4}')
    echo "$utime $stime"
} #
get_process_times()
{ #
    local pid=$1
    local stat_file="/proc/$pid/stat"
    if [[ ! -f $stat_file ]]; then
        echo "0 0"
    fi
    local stat_info
    stat_info=$(<"$stat_file")
    local utime=$(echo "$stat_info" | awk '{print $14}')
    local stime=$(echo "$stat_info" | awk '{print $15}')
    echo "$utime $stime"
} #
function get_cpu_percentage()
{ #
    if [[ -z "$1" ]]; then
        echo "Usage: $0 <PID>"
        return 1
    fi
    PID=$1
    if [ ! -d "/proc/$PID" ]; then
        echo "Process with PID $PID does not exist."
        return 1
    fi
    initial_cumulative_times=$(get_cumulative_times)
    initial_cumulative_utime=$(echo $initial_cumulative_times | awk '{print $1}')
    initial_cumulative_stime=$(echo $initial_cumulative_times | awk '{print $2}')
    initial_process_times=$(get_process_times $PID)
    initial_process_utime=$(echo $initial_process_times | awk '{print $1}')
    initial_process_stime=$(echo $initial_process_times | awk '{print $2}')
    sleep 10
    final_cumulative_times=$(get_cumulative_times)
    final_cumulative_utime=$(echo $final_cumulative_times | awk '{print $1}')
    final_cumulative_stime=$(echo $final_cumulative_times | awk '{print $2}')
    final_process_times=$(get_process_times $PID)
    final_process_utime=$(echo $final_process_times | awk '{print $1}')
    final_process_stime=$(echo $final_process_times | awk '{print $2}')
    diff_cumulative_utime=$((final_cumulative_utime - initial_cumulative_utime))
    diff_cumulative_stime=$((final_cumulative_stime - initial_cumulative_stime))
    diff_process_utime=$((final_process_utime - initial_process_utime))
    diff_process_stime=$((final_process_stime - initial_process_stime))
    total_cumulative_time=$((diff_cumulative_utime + diff_cumulative_stime))
    total_process_time=$((diff_process_utime + diff_process_stime))
    echo "total process utime+stime = $total_process_time"
    echo "total system  utime+stime = $total_cumulative_time"
    if [[ $total_cumulative_time -gt 0 ]]; then
        cpu_usage_percentage=$(echo "scale=2; 100 * $total_process_time / $total_cumulative_time" | bc)
        echo "CPU usage percentage of process $PID: $cpu_usage_percentage%"
    else
        echo "Error: Total cumulative time is zero."
    fi
} #
function __stats_utime_stime()
{ #
    __get_PIDS_by_process_name $1
    printf "|  pid  | utime  | stime\n"
    for PID in $PIDS; do
        UTIME_STIME=$(cat /proc/$PID/stat | awk '{print $14 " | " $15}')
        printf "| $PID | $UTIME_STIME |\n"
    done
    printf "\nAddress           Kbytes     RSS   Dirty Mode  Mapping\n"
    for PID in $PIDS; do
        pmap -x $PID | egrep "total"
    done
} #
____print_thread_name_utime_stime() {
    TID_DIR="$1"
    THREAD_ID=$(basename "$TID_DIR")
    if [ -f "$TID_DIR/stat" ]; then
        UTIME_STIME=$(cat $TID_DIR/stat | awk '{print $14, $15}')
        THREAD_NAME=$(cat $TID_DIR/stat | awk '{print $2}')
        printf "%-20s | %8s | %10s | %10s\n" $THREAD_NAME $THREAD_ID $UTIME_STIME
    fi
}
function __stats_utime_stime_include_threads()
{ #
   __get_PIDS_by_process_name $1
    printf "%-20s | %8s | %10s | %10s\n" 'threadName' 'pid' 'utime' 'stime'
    for PID in $PIDS; do
        ____print_thread_name_utime_stime "/proc/$PID"
        for TID in /proc/$PID/task/*; do
            ____print_thread_name_utime_stime "$TID"
            continue
            if [ -f "$TID/status" ]; then
                echo "Thread ID: $THREAD_ID"
                grep -E 'Name|State|Tgid|Pid|PPid|Uid|Gid' "$TID/status"
                echo
            else
                echo "Could not read status for thread ID: $THREAD_ID"
            fi
        done
    done
    printf "\nAddress           Kbytes     RSS   Dirty Mode  Mapping\n"
    for PID in $PIDS; do
        pmap -x $PID | egrep "total"
    done
} #
get_times()
{ #
  local pid=$1
  local stat_file="/proc/$pid/stat"
  if [[ -f $stat_file ]]; then
    local stat_info
    stat_info=$(<"$stat_file")
    local utime=$(echo "$stat_info" | awk '{print $14}')
    local stime=$(echo "$stat_info" | awk '{print $15}')
    echo "$utime $stime"
  else
    echo "0 0"
  fi
} #
__stime_utime_percentage()  # can also be done with ps -p PID -o %cpu (but it's not from start)
{ #
    PID=$1
    if [ -z "$PID" ]; then
        echo "Usage: $0 <PID>"
        exit 1
    fi
    HERTZ=$(getconf CLK_TCK)
    UPTIME=$(awk '{print $1}' /proc/uptime)
    read -r _ _ _ _ _ _ _ _ _ _ _ _ _ UTIME STIME _ _ STARTTIME _ < "/proc/$PID/stat"
    TOTAL_TIME=$(( (UTIME + STIME) / HERTZ ))
    START_TIME=$(( STARTTIME / HERTZ ))
    ELAPSED_TIME=$(awk "BEGIN {print $UPTIME - $START_TIME}")
    CPU_USAGE=$(awk "BEGIN {print ($TOTAL_TIME / $ELAPSED_TIME) * 100}")
    echo "CPU Usage: $CPU_USAGE%"
} #
function __track_utime_stime()
{ #
    PID=$(pidof $1)
    if [ ! -n "$PID" ]; then
        printf "  %-15s -> No process found, waiting.." $1
        while ! pidof $1 >/dev/null; do
            printf "."
            sleep 1
        done
        PID=$(pidof $1)
    fi
    local pid_count=$(echo $PID | wc -w)
    if [[ $pid_count -gt 1 ]]; then
        echo "Multiple PIDs found for $1: $PID"
        return
    fi
    echo "found process..."
    prev_times=$(get_times $PID)
    prev_utime=$(echo $prev_times | awk '{print $1}')
    prev_stime=$(echo $prev_times | awk '{print $2}')
    echo "utime: $prev_utime, stime: $prev_stime"
    while true; do
      sleep 1
      current_times=$(get_times $PID)
      current_utime=$(echo $current_times | awk '{print $1}')
      current_stime=$(echo $current_times | awk '{print $2}')
      if [[ "$current_utime" != "$prev_utime" ]] || [[ "$current_stime" != "$prev_stime" ]]; then
        echo "utime: $current_utime, stime: $current_stime"
        prev_utime=$current_utime
        prev_stime=$current_stime
      fi
    done
} #
function ww_show_file_descriptors()
{ #
printf "${BGreen}file descriptors info with: ${NC} ls -lv /proc/PID/fd/\n"
    for BINARY_FILE in "${BINS_DU[@]}"; do
        printf "${BGreen}$BINARY_FILE:${NC}\n"
        ls -lv /proc/$(pidof $BINARY_FILE)/fd/
    done
    for BINARY_FILE in "${BINS_CU[@]}"; do
        printf "${BGreen}$BINARY_FILE:${NC}\n"
        ls -lv /proc/$(pidof $BINARY_FILE)/fd/
    done
} #
function __show_stats()
{ #
    PID=$(pidof $1)
    if [ ! -n "$PID" ]; then
        echo "$1 -> No process found"
        return
    fi
    RES=$(ps -p $PID -o etime)
    RES="${RES//$'\n'/}"
    printf "%-15s -> $RES\n" $1
    cat /proc/$PID/stat
    cat /proc/$PID/status
    cat /proc/$PID/cmdline
    cat /proc/$PID/comm
    cat /proc/$PID/status | grep Threads
    ls -lv /proc/$PID/fd/
    MYDIR=/proc/$PID/fd/ && ls -all "$MYDIR"
    readlink /proc/$PID/exe
} #
function ww_show_stats()
{ #
    echo "cu du elapsed time of processes:"
    __show_stats "gnb_cu_oam"
} #
function ww_fault()
{ #
    printf "$BGreen CU FaultLog aligned:\n"
    printf        " ====================\n$NC"
    tail -n +2  $CU_LOGS/FaultLog_* | column -t -s ','
    printf "\n$BGreen DU FaultLog aligned:\n"
    printf          " ====================\n$NC"
    tail -n +2  $DU_LOGS/FaultLog_* | column -t -s ','
    printf  "\n\n"
    printf "$BGreen CU FaultLog:\n"
    printf        " ============\n$NC"
    cat $CU_LOGS//FaultLog_*
    printf "\n$BGreen DU FaultLog:\n"
    printf          " ============\n$NC"
    cat $DU_LOGS/FaultLog_*
} #
function __show_tail_messages()
{ #
    if [ -f $1 ]; then
        printf "$BGreen tail $1:\n"
        printf "====================\n$NC"
        tail -40 $1
    else
        printf "$BIRed no $1:\n"
        printf "====================\n$NC"
    fi
    echo ""
} #
function ww_messages()
{ #
    __show_tail_messages ~/phy/messages
    __show_tail_messages ~/cu/messages
    __show_tail_messages ~/du/messages
} #
function ww_signal()
{ #
    local CURTIME=$(date +"%Y-%m-%d %H:%M:%S")
    printf "\n$CURTIME\n=======================" >> ~/cu/cleanExit.log
    printf "\n$CURTIME\n=======================" >> ~/du/cleanExit.log
} #
__type_du__is_no_pie()  # should be from du pod ᛀ
{ #
    if ! is_inside_pod; then
        echo "this function should be executed inside pod"
        return -1
    fi
    echo "Type: EXEC (Executable file)                     --> -no-pie"
    echo "Type: DYN (Position-Independent Executable file) --> can't backtrace"
    for BINARY_FILE in "${BINS_DU[@]}"; do
        echo $BINARY_FILE
        readelf -h $BINARY_FILE | grep Type
    done
for BINARY_FILE in "${BINS_DU[@]}"; do
        cksum $BINARY_FILE
    done
} #
__perf_strace()
{ #
    perf record -e malloc:malloc -e malloc:free -g -p $(pidof gnb_cu_l3)
    strace -f -e trace=mmap,munmap,brk -tt -T -p $(pidof gnb_cu_l3)
} #
if [ "$#" -gt 0 ]; then
    if [ "$1" = "elapsed_time" ]; then
        ww_elapsed_time_
    elif [ "$1" = "elapsed_time_extend" ]; then
        ww_elapsed_time_extend
    fi
fi
alias ww_watch_elapsed_time_2='watch -n 1.8 --color ~/.config/.bash/.funcs01 elapsed_time'
alias ww_watch_elapsed_time_4='watch -n 3.8 --color ~/.config/.bash/.funcs01 elapsed_time'
alias ww_elapsed_time_extend_2='watch -n 1.8 --color ~/.config/.bash/.funcs01 elapsed_time_extend'
alias ww_watch_elapsed_time_extend_4='watch -n 3.8 --color ~/.config/.bash/.funcs01 elapsed_time_extend'

# === para#bash#.shared_bash#.funcs02 ===
#!/bin/bash
PROCESS_NAMES=(
    "gnb_cu_pdcp"
    "gnb_du_layer2"
    "phymgr"
    "gnb_app"
    "duoam"
    "dumgr"
    "gnb_du_e2du"
    "gnb_du_e2du"
    "gnb_cu_oam"
    "gnb_cu_son"
    "gnb_cu_rrm"
    "gnb_cu_l3"
    "gnb_cu_e2cu"
)
__tar_remove_files() {
    zipfile='cu_nrlogs.tgz.3'
    newDir='tmp3'
    if [ ! -f $zipfile ]; then
        echo "ERROR no file: $zipfile"
        return -1
    fi
    if [ -d $newDir ]; then
        echo "ERROR dir already exist: $newDir"
        return -1
    fi
    mkdir $newDir
    mv $zipfile $newDir
    cd $newDir
    tar -xzvf cu_nrlogs.tgz.3
    du -hk cu_nrlogs.tgz.3
    rm cu_nrlogs.tgz.3
    rm gnb_cu_pdcp bin_reader
    rm *.bin
    tar -czvf cu_nrlogs.tgz.3 *
    du -hk $zipfile
    mv $zipfile ../
    cd ../
    rm -r $newDir
}
___check_cksum() {
    if [ ! -f $1 ]; then 
        echo "no file: $1"
    else
        cksum $1
    fi
}
___cp_arg1_to_arg2_dir() {
    if [ ! -f $1 ]; then echo "no file $1"; return; fi
    if [ ! -d $2 ]; then echo "no dir: $2"; return; fi
    echo "copy $1 to $2"
    cp $1 $2
}
__check_univrunode_oammgr_binary_cksum() {
    ___check_cksum /root/univrunode
    ___check_cksum /var/log/pw-share/pods/stack/cunode01/prvt/univrunode
    ___check_cksum /var/log/pw-share/pods/stack/dunode02/prvt/univrunode
}
    ____is_prvt_folder_exists() {
        local dir_path="$1"
        if [ ! -d "$dir_path" ]; then return -1; fi
        if [ ! -d "$dir_path/prvt/" ]; then 
            echo "no prvt dir: $dir_path/prvt/"
            return -1
        fi
        return 0
    }
    ____cksum_nrstack_prvt() {
        local dir_path="$1"
        if ! ____is_prvt_folder_exists "$dir_path"; then return -1; fi
        local tar_files=("$dir_path/prvt/"*.tar.gz)
        if [ ! -e "${tar_files[0]}" ]; then
            echo "no tar.gz files in: $dir_path/prvt/"
            return
        fi
        for tar_file in "${tar_files[@]}"; do
            if [ -f "$tar_file" ]; then
                cksum "$tar_file"
            fi
        done
    }
ww_cksum_nrstack_prvt() {
    ____cksum_nrstack_prvt /var/log/pw-share/pods/stack/cunode01
    ____cksum_nrstack_prvt /var/log/pw-share/pods/stack/dunode02
    ____cksum_nrstack_prvt /var/log/pw-share/pods/stack/dunode03
    ____cksum_nrstack_prvt /var/log/pw-share/pods/stack/dunode04
}
    ____cp_nrstack() {
        local nr_stack_file="$1"
        local dir_path="$2"
        if ! ____is_prvt_folder_exists "$dir_path"; then return -1; fi
        ___cp_arg1_to_arg2_dir "$nr_stack_file"  "$dir_path/prvt/"
    }
ww_cp_nrstack() {
    if [ ! -f $1 ]; then echo "no file $1"; return; fi
    ____cp_nrstack  $1  /var/log/pw-share/pods/stack/cunode01
    ____cp_nrstack  $1  /var/log/pw-share/pods/stack/dunode02
    ____cp_nrstack  $1  /var/log/pw-share/pods/stack/dunode03
    ____cp_nrstack  $1  /var/log/pw-share/pods/stack/dunode04
}
ww_wdg_mdg_more() {
    if [ -f /root/cu/nrlogs/gnb_cu_pdcp.log ]; then
        tail -n 100 /root/cu/nrlogs/gnb_cu_pdcp.log | grep "DL IN\|UL IN"
    fi
}
___check_dir()
{
    if [ ! -d $1 ]; then printf "    ${RED}No Dir:${NC} $1\n"   ; return -1; fi
    printf "    ${GREEN}Found:${NC} $1\n"
    return 0
}
___do_command_on_files_in_directory() {
    local cmd="$1"
    local dir="$2"
    local file_pattern="$3"      # might be nr*
    if [[ ! -d $dir ]]; then return; fi
    for f in $dir/$file_pattern; do
        if [[ -f $f ]]; then
            if $cmd $f; then printf "    SUCCESS:  $cmd $f\n"
            else             printf "    FAILED:   $cmd $f\n"
            fi
        fi
    done
}
ww_nrstack()
{
    ___check_dir  /var/log/pw-share/pods/stack/cunode01/prvt/
    ___check_dir  /var/log/pw-share/pods/stack/dunode02/prvt/
    ___check_dir  /var/log/pw-share/pods/stack/dunode03/prvt/
    ___check_dir  /var/log/pw-share/pods/stack/dunode04/prvt/
    printf "${GREEN}Rr)${NC}   remove nr_stack prvt\n"
    printf "${GREEN}Dd)${NC}   delete prvt folder\n"
    printf "${GREEN}Cc)${NC}   cksum nr_stack prvt\n"
    printf "${GREEN}MmKk)${NC} mkdir prvt\n"
    read -p "Choose Option: " keys
    case "$keys" in
    [Dd]* )
        echo "deleting folders cunode01/prvt/ dunode02/prvt/ dunode03/prvt/"
        rm -r /var/log/pw-share/pods/stack/cunode01/prvt/
        rm -r /var/log/pw-share/pods/stack/dunode02/prvt/
        rm -r /var/log/pw-share/pods/stack/dunode03/prvt/
        ;;
    [Rr]* )
        echo "removing nr_stack.tar.gz from cunode01/prvt/ dunode02/prvt/ dunode03/prvt/"
        ___do_command_on_files_in_directory rm /var/log/pw-share/pods/stack/cunode01/prvt "nr*"
        ___do_command_on_files_in_directory rm /var/log/pw-share/pods/stack/dunode02/prvt "nr*"
        ___do_command_on_files_in_directory rm /var/log/pw-share/pods/stack/dunode03/prvt "nr*"
        ;;
    [Cc]* )
        ww_cksum_nrstack_prvt
        ;;
    [MmKk]* )
        echo "mkdir prvt"
        mkdir  /var/log/pw-share/pods/stack/cunode01/prvt/
        mkdir  /var/log/pw-share/pods/stack/dunode02/prvt/
        mkdir  /var/log/pw-share/pods/stack/dunode03/prvt/
        ;;
    * )
        echo "skipping..."
    esac;
}
ww_choose_version()
{
    pushd .
    files=()
    for f in *; do
        [[ -f "$f" ]] && files+=("$f")
    done
    for file in "${files[@]}"; do
      echo "Processing: $file"
    done
    popd
}
ww_choose_version()
{
    declare -A file_dict
    files=()
    for f in *; do
        [[ -f "$f" ]] && files+=("$f")
    done
    IFS=$'\n' sorted=($(sort <<<"${files[*]}"))
    unset IFS
    ascii=97  # ASCII for 'a'
    for file in "${sorted[@]}"; do
        key=$(printf "\\$(printf '%03o' "$ascii")")
        file_dict[$key]="$file"
        ((ascii++))
    done
    for k in "${!file_dict[@]}"; do
        echo "$k) ${file_dict[$k]}"
    done
    printf "\n Choose an option: "
    read -n 1 key
    if [[ -n "${file_dict[$key]}" ]]; then
        printf "\n\nfound: ${file_dict[$key]}\n"
    fi
}
get_logs_e2cu_with_zip() {
    pushd .
    if cd /var/log/pw-share/pods/stack/cunode01/nrlogs/; then
        FILE="/root/.config/nr/logs/cu_zip.tar.gz"
        tar -czvf $FILE *.log* *pcap* && tar -tvf $FILE
    fi
    if cd /var/log/pw-share/pods/stack/dunode02/nrlogs/; then
        FILE="/root/.config/nr/logs/du2_zip.tar.gz"
        tar -czvf $FILE *.log* *pcap* && tar -tvf $FILE
    fi
    if cd /var/log/pw-share/pods/stack/dunode03/nrlogs/; then
        FILE="/root/.config/nr/logs/du3_zip.tar.gz"
        tar -czvf $FILE *.log* *pcap* && tar -tvf $FILE
    fi
    popd
}
___grep_tail_prev()
{
    matches=$(tail -n 1000 "$1" | grep -w "RIC Indication sent to RIC" | tail -n 3)
    if [ -n "$matches" ]; then
        printf "\nFile: $1\n"
        echo "$matches" | sed -E 's/  CPU:.*  VTID:[0-9]*//'
    fi
}
ww_ric_indication_show_prev()
{
    for f in /root/du02/nrlogs/*.log; do
        ___grep_tail "$f"
    done
    for f in /root/du03/nrlogs/*.log; do
        ___grep_tail "$f"
    done
    for f in /root/cu/nrlogs/*.log; do
        ___grep_tail "$f"
    done
}
___grep_tail()
{
    file_path="$1"
    search_pattern="$2"
    local num_of_records="$3"
    if ! [[ $num_of_records =~ ^[0-9]+$ ]]; then
        num_of_records=6
    fi
    if [ ! -f "$file_path" ]; then echo "no file: $file_path"; return -1; fi
    matches=$(tail -n 1000 "$file_path" | grep -w "$search_pattern" | tail -n $num_of_records)
    count=$(echo "$matches" | wc -l)
    if [ "$count" -lt $num_of_records ]; then
        matches=$(grep -w "$search_pattern" "$file_path" | tail -n $num_of_records)
    fi
    if [ -n "$matches" ]; then
        printf "\nFile: $file_path\n"
        echo "$matches" | sed -E 's/  CPU:.*  VTID:[0-9]*//'
    fi
}
ww_ric_indication_show_prev()
{
    local pattern="RIC Indication sent to RIC\|RIC Indication sequence number"
    ___grep_tail "/var/log/pw-share/pods/stack/dunode02/nrlogs/gnb_du_e2du.log"    "$pattern"
    ___grep_tail "/var/log/pw-share/pods/stack/dunode03/nrlogs/gnb_du_e2du.log"    "$pattern"
    ___grep_tail "/var/log/pw-share/pods/stack/cunode01/nrlogs/gnb_cu_e2cu.log"    "$pattern"
    ___grep_tail "/var/log/pw-share/pods/stack/cunode01/nrlogs/gnb_cu_e2cu.1.log"  "$pattern"
    ww_ric_indication_show
}
ww_ric_indication_show()
{
    local pattern="RIC Indication sent to RIC"
    local num_of_records="$1"
    if ! [[ $num_of_records =~ ^[0-9]+$ ]]; then
        num_of_records=6
    fi
    latest_file=$(ls -t /var/log/pw-share/pods/stack/dunode03/nrlogs/e2du_main.* 2>/dev/null | head -n 1)
    if [[ -n $latest_file ]]; then
        ___grep_tail $latest_file "$pattern" "$num_of_records"
    fi
    latest_file=$(ls -t /var/log/pw-share/pods/stack/dunode02/nrlogs/e2du_main.* 2>/dev/null | head -n 1)
    if [[ -n $latest_file ]]; then
        ___grep_tail $latest_file "$pattern" "$num_of_records"
    fi
    latest_file=$(ls -t /var/log/pw-share/pods/stack/cunode01/nrlogs/e2cu_main.* 2>/dev/null | head -n 1)
    if [[ -n $latest_file ]]; then
        ___grep_tail $latest_file "$pattern" "$num_of_records"
    fi
    latest_file=$(ls -t /var/log/pw-share/pods/stack/cunode01/nrlogs/gnb_cu_e2cu.log* 2>/dev/null | head -n 1)
    if [[ -n $latest_file ]]; then
        ___grep_tail $latest_file "$pattern" "$num_of_records"
    fi
}

# === cygwin64#home#bashrc_s#.config#common_01.sh ===
#!/bin/bash
STRING='\d*\.\d*\.\d*\.\d*'
STRING='\d*\.\d*\.\d*\.\d*\S*'
FILE='C:/ws/para/zzz/ptp_rrh/vnodeStartup.txt'
get_unique_appearances() {
    echo "File: $FILE"
    rg $STRING -o --vimgrep --no-column --no-line-number \
        --no-filename  $FILE | sort -u
}
___not_has_fzf() {
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed."
        return 0
    fi
    return 1
}
__render_selected() {
    printf '\033[2J\033[H'
    local cmd="$1"
    local edit_command="$2"
    local command="$1"      # in case we don't edit command
    if [[ "add_to_history" == $edit_command ]]; then
        history -s "$cmd"
        printf "$BGreen Added to history:$NC $cmd\n"
        return
    fi
    if [[ "edit_command" == $edit_command ]]; then
        read -er -i "$cmd" -p '▶ ' command
        if [ -d /root/.config/.bash/ ]; then
            tmp_script="/root/.config/.bash/_tmp_sh.sh"
            echo "#!/bin/bash" > "$tmp_script"
            echo "$command" >> "$tmp_script"
            chmod +x "$tmp_script"
source "$tmp_script"
            return
        fi
    fi
    if [[ "READLINE_RENDER" == $edit_command ]]; then
        READLINE_LINE="$cmd"
        READLINE_POINT=${#READLINE_LINE}
        return
    fi
    eval "$command"
}
__fzf_final() {
    clear -x
    local selected
    selected=$(echo "$__g_output_for_fzf" | fzf --height 60% --border --prompt="Select ww_ function: ")
    __render_selected "$selected" "edit_command"
}
try_this() {
    local cmd="$1"
    read -e -i "$cmd" -p '▶ ' command
    echo "original: $cmd"
    echo "edited:   $command"
    eval "$command"
}

# === cygwin64#home#bashrc_s#.config#global_vars.sh ===
__g_output_for_fzf=""

# === cygwin64#home#bashrc_s#.config#tmux_screen#tmux_01.sh ===
TMUX_CONF_PATH=""
__tmux_create_or_attach_to_session_prev() {
    local SESSION_NAME="$1"
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux -u new-session -d -s "$SESSION_NAME"
        if [ -f /root/.config/tmux/.tmux.conf ]; then
            tmux source-file /root/.config/tmux/.tmux.conf
        elif [ -f C:/ws/cygwin64/home/wshabso/.tmux.conf ]; then
            tmux source-file C:/ws/cygwin64/home/wshabso/.tmux.conf
        fi
    fi
    tmux attach -t "$SESSION_NAME"
}
____get_tmux_conf_path() {
    local file_path="/root/.config/tmux/.tmux.conf"
    if [ -f "$file_path" ]; then 
        TMUX_CONF_PATH="$file_path"
        return
    fi
    file_path="C:/ws/cygwin64/home/wshabso/.tmux.conf"
    if [ -f "$file_path" ]; then 
        TMUX_CONF_PATH="$file_path"
        return
    fi
    file_path="/home/wshabso/.config/tmux/.tmux.conf"
    if [ -f "$file_path" ]; then 
        TMUX_CONF_PATH="$file_path"
        return
    fi
    return -1
}
__tmux_create_or_attach_to_session() {
    local SESSION_NAME="$1"
    tmux ls
    local sessions=$(tmux list-sessions -F '#S' 2>/dev/null)
    if [ -z "$sessions" ]; then
        echo "No tmux sessions found"
        if ! ____get_tmux_conf_path; then
            echo "didnt found .tmux.conf !!!"
            return -1
        fi
        echo "found .tmux.conf:  $TMUX_CONF_PATH"
        read -n1 -p "Hit any key..." keys
        tmux -f "$TMUX_CONF_PATH" -u  new-session -s "$SESSION_NAME"
        return
    fi
    if [ "$(echo "$sessions" | wc -l)" -eq 1 ]; then
        echo "found 1 session: $sessions"
        read -n1 -p "Hit any key..." keys
        tmux attach-session -t "$sessions"
        return
    fi
    echo "found multiple sessions !!"
}
__tmux_kill_session() {
    local SESSION_NAME="$1"
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        if tmux kill-session -t "$SESSION_NAME"; then
            echo "kill success"
        else
            echo "kill FAIL"
        fi
    else
        echo "No tmux session named: $SESSION_NAME"
    fi
    w
    tmux ls
}
ww_tmux_session_prepare() {   # add: pods_start or BUILD
    if [ ! -n "$TMUX" ]; then echo "Not inside tmux"; return; fi
    local HOSTNAME_SHORT=$(hostname --short 2>/dev/null || echo "??")
    local SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "IP??")
    local NAME=""
    echo "a) pods_start"
    echo "c) pods_start classic"
    echo "b) BUILD"
    read -n1 -p "Choose Option: " keys
    echo ""
    case "$keys" in
        [Aa]* )
            NAME="pods_start"
            tmux rename-window Git
            ;;
        [Cc]* )
            NAME="pods_start"
            tmux rename-window VIEW
            tmux split-window -v
            tmux select-pane -t +
            tmux split-window -h
            tmux new-window -n tcpdum
            tmux next-window
            ;;
        [Bb]* )
            NAME="BUILD"
            tmux rename-window Git
            tmux new-window -n DOCKER_BUILD
            ;;
        * )
            echo "skipping..."
            return
    esac
    tmux rename-session "${NAME}  ${HOSTNAME_SHORT}  ${SERVER_IP}"
}

# === cygwin64#home#bashrc_s#.config#utils#guards.sh ===
__BashFunc1Impl() {
    echo "Function 1: $@"
    sleep 4
}
__BashFunc2Impl() {
    echo "Function 2: $@"
    sleep 2
}
__BashFunc3Impl() {
    echo "Function 3: $@"
    sleep 3
}
__guardFunc() {
    local func_name="$1"
    shift  # Remove function name from args
    local last_exit_file="/tmp/guard_${func_name}_last_exit"
    local min_interval=500  # Minimum milliseconds between executions
    local current_time=$(date +%s%3N)  # can be something like: 1765343749253
    local last_exit=0
    if [[ -f "$last_exit_file" ]]; then
        last_exit=$(cat "$last_exit_file")
    fi
    local time_diff=$((current_time - last_exit))
    if [[ $time_diff -lt $min_interval ]]; then
        echo "[$func_name] Too soon after last execution (${time_diff}ms), skipping"
        return
    fi
    trap "date +%s%3N > '$last_exit_file'" RETURN
    "$func_name" "$@"
}
export -f __BashFunc1Impl
export -f __BashFunc2Impl
export -f __BashFunc3Impl
export -f __guardFunc
bind -x '"ii1": __guardFunc __BashFunc1Impl arg1 arg2'
bind -x '"ii2": __guardFunc __BashFunc2Impl arg1 arg2'
bind -x '"ii3": __guardFunc __BashFunc3Impl arg1 arg2'

# === cygwin64#home#bashrc_s#.config#.menu ===
#!/bin/bash
___loop_example() {
    clear -x
    declare -A cmd_map
    cmd_map["x"]="x option"
    cmd_map["a"]="a option"
    cmd_map["b"]="b option"
    cmd_map["m"]="m option"
    echo "Print command options dynamically from the array:"
    for key in "${!cmd_map[@]}"; do
        printf "  %s) %-40s ■ %s\n" "$key" "${cmd_map[$key]}" "${exp_map[$key]}"
    done
    printf "══════════════════════\n\n"
    echo "sorted by key:"
    for key in $(printf '%s\n' "${!cmd_map[@]}" | sort); do
        printf "  %s) %-40s ■ %s\n" "$key" "${cmd_map[$key]}" "${exp_map[$key]}"
    done
    printf "══════════════════════\n\n"
}
__inject_cmd_exec() {  # Print and execute version - will show command for editing before execution
    local cmd="$*"
    if [ -z "$cmd" ]; then
        cmd="ls -all" # Default command if none provided
    fi
    echo "$cmd"
    read -e -i "$cmd" -p '$ ' command
    eval "$command"
}
___example01() {
    echo "a) tcpdump -i any sctp"
    echo "b) tcpdump -i any sctp | grep DATA"
    printf "\nchoose: "
    read -n 1 key
    echo ""
    case "$key" in
        [a]) cmd="tcpdump -i any sctp" ;;
        [b]) cmd="tcpdump -i any sctp | grep DATA" ;;
    *) echo "Invalid key"; return ;;
    esac
    read -e -i "$cmd" -p '▶ ' command
    eval "$command"
}
___example_initial() {
    declare -A cmd_map
    declare -A exp_map
    cmd_map["a"]="tcpdump -i any sctp";             exp_map["a"]="  aaaaaaaa"
    cmd_map["b"]="tcpdump -i any sctp | grep DATA"; exp_map["b"]="  bbbbbbbb"
    cmd_map["c"]="netstat -tuln";                   exp_map["b"]="  cccccccc"
    cmd_map["d"]="ss -s";                           exp_map["b"]="  ssssssss"
    echo "╔═══════════════════════════════════════════╗"
    echo "║           NETWORK COMMAND MENU            ║"
    echo "╚═══════════════════════════════════════════╝"
    for key in $(printf '%s\n' "${!cmd_map[@]}" | sort); do
        [[ "$key" == "q" ]] && continue
        printf "  %s) %s\n" "$key" "${cmd_map[$key]}"
    done
    echo "  q) Quit"
    __choose_option cmd_map exp_map "dont_edit_command"
}
_tmux() {
    declare -A cmd_map
    declare -A exp_map
    cmd_map["a"]="__tmux_create_or_attach_to_session pods_start"
    exp_map["a"]="safely create or attach to already runnint tmux session named 'pods_start'"
    cmd_map["k"]="__tmux_kill_session pods_start"
    exp_map["k"]="kill session names 'pods_start' if exists"
    clear -x
    echo "╔═══════════════════════════════════════════╗"
    echo "║           tmux simple commands            ║"
    echo "╚═══════════════════════════════════════════╝"
    __choose_option cmd_map exp_map "dont_edit_command"
}
__choose_option() {
    local -n cmd_map_ref=$1
    local -n exp_map_ref=$2
    local edit_command="$3"
    for key in $(printf '%s\n' "${!cmd_map[@]}" | sort); do
        printf "  %s) %-40s ■ %s\n" "$key" "${cmd_map[$key]}" "${exp_map[$key]}"
    done
    printf "\n Choose an option: "
    read -n 1 key
    if [ "," == $key ]; then  # TODO: currently just go back to main menu, later to parent
        ww_big_menu
        return
    fi
    if [[ -n "${cmd_map[$key]}" ]]; then
        printf "\n\n${exp_map[$key]}\n"
        cmd="${cmd_map[$key]}"
        __render_selected "$cmd" "$edit_command"
    else
        printf "\nInvalid option: $key\n"
        return 1
    fi
}
_tcpdump_options() {
    declare -A cmd_map
    declare -A desc_map
    cmd_map["a"]="tcpdump -i any sctp"
    desc_map["a"]="Capture all SCTP packets on any interface"
    cmd_map["b"]="tcpdump -i any sctp | grep DATA"
    desc_map["b"]="Capture SCTP DATA packets only"
    cmd_map["c"]='tcpdump -i any sctp -v | grep -E "length 2[0-9][0-9]"'
    desc_map["c"]="capture ric indication"
    cmd_map["d"]="ls -all"
    desc_map["d"]="Display socket statistics"
    cmd_map["h"]="tcpdump -i any sctp    | grep -v HB"
    desc_map["h"]=""
    clear -x
    echo "╔═══════════════════════════════════════════╗"
    echo "║           NETWORK COMMAND MENU            ║"
    echo "╚═══════════════════════════════════════════╝"
    __choose_option cmd_map exp_map "edit_command"
}
ww_big_menu() {
    declare -A cmd_map
    declare -A exp_map  # explanation
    if [ "MobaX" == "$TERM_NAME" ]; then
        cmd_map["r"]="__remote_menu"
        exp_map["r"]="REMOTE ssh, set, etc"
        cmd_map["w"]="my_ww_functions_search"
        exp_map["w"]="all functions that start in ww_"
        cmd_map["j"]="MyCommandsBetter"
        exp_map["j"]="fzf on my files"
        cmd_map["g"]="_git_commands"
        exp_map["g"]="wdgmdg git commands"
        cmd_map["d"]="__declare_p"
        exp_map["d"]="yman"
    elif [ "cygwin" == "$TERM_NAME" ]; then
        cmd_map["g"]="_git_commands"
        exp_map["g"]="wdgmdg git commands"
        cmd_map["d"]="__declare_p"
        exp_map["d"]="yman"
        cmd_map["a"]="cs"
        exp_map["a"]="yman"
    else
        cmd_map["a"]="_tcpdump_options"
        exp_map["a"]="tcpdump options menu"
        if [ -z "$TMUX" ]; then # Not inside tmux
            cmd_map["t"]="_tmux"
            exp_map["t"]="tmux create, attach, kill"
        fi
        cmd_map["j"]="my_functions_search"
        exp_map["j"]="all functions"
        cmd_map["w"]="my_ww_functions_search"
        exp_map["w"]="all functions that start in ww_"
    fi
    clear -x
    echo "██████████████████████████████"
    echo "█▄─▀█▀─▄█▄─▄▄─█▄─▀█▄─▄█▄─██─▄█"
    echo "██─█▄█─███─▄█▀██─█▄▀─███─██─██"
    echo "▀▄▄▄▀▄▄▄▀▄▄▄▄▄▀▄▄▄▀▀▄▄▀▀▄▄▄▄▀▀"
    echo ""
    __choose_option cmd_map exp_map "dont_edit_command"
}
printf "$BGreen Use 🔗🔗 jj 🔗🔗\n$NC"
bind '"jj":"__guardFunc ww_big_menu\n"'

# === cygwin64#home#bashrc_s#.config#fzf#fzf_my_funcs.sh ===
IS_FUNCTIONS_LIST_INITIALIZED=0
FUNCTIONS_WW_LIST=()
FUNCTIONS_LIST=()
___initialize_functions() {
    IS_FUNCTIONS_LIST_INITIALIZED=1
    FUNCTIONS_WW_LIST=$(declare -F | awk '$3 ~ /^ww_/ {print $3}')
    FUNCTIONS_LIST=$(declare -F | awk '{print $3}')
}
__fzf_search_on_arg() {
    local LINES_LIST="$1"
    local explanation="$2"
    if [ -z "$LINES_LIST" ]; then
        echo "No $explanation were found."
        return 1
    fi
    clear -x
    local selected
    selected=$(echo "$LINES_LIST" | fzf --height 60% --border --prompt="Select function: ")
    __render_selected "$selected" "edit_command"
}
my_ww_functions_search() {  # search for ww_ funcs
    if ___not_has_fzf; then return 1; fi
    if [ 0 -eq $IS_FUNCTIONS_LIST_INITIALIZED ]; then ___initialize_functions; fi
    __fzf_search_on_arg "$FUNCTIONS_WW_LIST" "ww_ functions"
}
my_functions_search() {  # search for ww_ funcs
    if ___not_has_fzf; then return 1; fi
    if [ 0 -eq $IS_FUNCTIONS_LIST_INITIALIZED ]; then ___initialize_functions; fi
    __fzf_search_on_arg "$FUNCTIONS_LIST" "all functions"
}
___initialize_list_variables() {
    declare -p  # To list all variables:
    compgen -v # To list only names of variables (scalars + arrays):
    declare -p | awk '{print $3}' | sed 's/=.*//'   # To extract just variable names using declare
    declare -x   # For exported variables (like env vars)
    declare -A   # For associative arrays
    declare -a   # For indexed arrays
}

# === cygwin64#home#bashrc_s#.config#completion#complete_02.sh ===
__generic_completion_multi_word() {
    local cur=${COMP_WORDS[COMP_CWORD]}  # Current word being typed
    local cmd=${COMP_WORDS[0]}           # Command name
    local options_var="${cmd}_options"   # Options array name (e.g., my_command_options)
    local options
    eval "options=(\"\${${options_var}[@]}\")"
    COMPREPLY=()
    for opt in "${options[@]}"; do
        if [[ $opt == $cur* ]]; then
            COMPREPLY+=("$opt")
        fi
    done
}
register_completion() {
    local cmd=$1
    complete -F __generic_completion_multi_word "$cmd"
}

# === para#bash#.shared_bash#.memstat ===
#!/bin/bash
function __memory_map()  #  alias ww_memory_gnb_du_layer2="__memory_map gnb_du_layer2"
{ #
    PID=$(pidof $1)
    if [ ! -n "$PID" ]; then
        echo "$1 -> No process found"
        return
    fi
    cat /proc/$PID/maps | while read line; do
        start=$(echo "$line" | awk '{print $1}' | cut -d'-' -f1)
        end=$(echo "$line" | awk '{print $1}' | cut -d'-' -f2)
        size=$((16#$end - 16#$start))
        printf "%011d | %09x | %012s-%012s | XXX%s\n" "$size" "$size" "$start" "$end" "$line"
    done | sort -nr | less
} #
PREV_RSS_L3=0
__memory_rss_track() {
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        return
    fi
    for PID in $PIDS; do
        RSS=$(awk '/VmRSS/{print $2}' /proc/$PID/status) # Resident Set Size in KB
        RSS_MB=$(awk "BEGIN {printf \"%.2f\", $RSS/1024}") 
        if [[ $RSS -ne $PREV_RSS_L3 ]]; then
            echo "$1 | $PID | $(date '+%Y-%m-%d %H:%M:%S') | RSS: $RSS_MB MB | $RSS kB"
            PREV_RSS_L3="$RSS"
         fi
    done
}
ww_memory_rss_track() {
    local process_name="$1"
    if [[ -z "$process_name" ]]; then
        echo "You need to provide process name"
        return -1
    fi
    while true; do
        __memory_rss_track "$process_name"
        sleep 4
    done
}
ww_memory_rss_track_options=("gnb_cu_oam" "gnb_cu_l3" "gnb_cu_e2cu" "gnb_cu_pdcp"  "gnb_cu_rrm" "gnb_cu_son")
register_completion ww_memory_rss_track

# === para#bash#.shared_bash#.elapsed_time ===
#!/bin/bash
____elapset_time_prev()
{ #
    PID=$(pidof $1)
    EXPECTED_NUM_OF_THREADS=$2
    if [ -n "$PID" ]; then
        RES=$(ps -p $PID -o etime)
        RES="${RES//$'\n'/}"
        NUM_OF_THREADS=$(awk '/Threads/{print $2}' /proc/$PID/status)
        printf "  %-15s -> $RES   PID $PID  THREADS: $NUM_OF_THREADS / $EXPECTED_NUM_OF_THREADS\n" $1
    else
        printf "  %-15s -> No process found\n" $1
    fi
} #
____elapset_time_prev2()
{ #
    PIDS=$(pidof $1)
    EXPECTED_NUM_OF_THREADS=$2
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return
    fi
    for PID in $PIDS; do
        RES=$(ps -p $PID -o etime)
        USERNAME=$(ps -p $PID -o user=)
        RES="${RES//$'\n'/}"
        NUM_OF_THREADS=$(awk '/Threads/{print $2}' /proc/$PID/status)
        printf "  %-15s -> $RES   PID $PID  THREADS: $NUM_OF_THREADS / $EXPECTED_NUM_OF_THREADS\n" $1
    done
} #
___get_elapsed_time_of_process()
{ #
    PID=$1
    ELAPSED_TIME=$(ps -p $PID -o etime --no-header)  # withoue ELAPSED part
    echo "$ELAPSED_TIME" | tr -d '\n'   # Remove newlines
} #
___get_pids_and_set_processName_and_numberOfThreads()
{ #
    PROCESS_NAME=$1
    PIDS=$(pidof $1)
    EXPECTED_NUM_OF_THREADS=$2
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found\n" $1
        return -1
    fi
    return 0
} #
___get_numOfThreads_and_elapsedTime()
{ #
    PID=$1
    NUM_OF_THREADS=$(awk '/Threads/{print $2}' /proc/$PID/status)
    ELAPSED_TIME=$(___get_elapsed_time_of_process $PID)
} #
__elapset_time_()
{ #
    if ! ___get_pids_and_set_processName_and_numberOfThreads "$@"; then return 1; fi
    for PID in $PIDS; do
        ___get_numOfThreads_and_elapsedTime $PID  # set NUM_OF_THREADS + ELAPSED_TIME
        printf "| %-15s | %10s | %7s | %2s/%2s |\n"   $PROCESS_NAME $ELAPSED_TIME $PID $NUM_OF_THREADS $EXPECTED_NUM_OF_THREADS
    done
} #
__elapset_time_with_username()
{ #
    if ! ___get_pids_and_set_processName_and_numberOfThreads "$@"; then return 1; fi
    for PID in $PIDS; do
        ___get_numOfThreads_and_elapsedTime $PID  # set NUM_OF_THREADS + ELAPSED_TIME
        USERNAME=$(ps -p "$PID" -o user=)
        printf "| %-10s | %-15s | %10s | %7s | %2s/%2s |\n"   $USERNAME $PROCESS_NAME $ELAPSED_TIME $PID $NUM_OF_THREADS $EXPECTED_NUM_OF_THREADS
    done
} #
__elapset_time_with_mem()
{ #
    if ! ___get_pids_and_set_processName_and_numberOfThreads "$@"; then return 1; fi
    for PID in $PIDS; do
        ___get_numOfThreads_and_elapsedTime $PID  # set NUM_OF_THREADS + ELAPSED_TIME
        RSS=$(awk '/VmRSS/{print $2}' /proc/$PID/status) # Resident Set Size in KB
        VM=$(awk '/VmSize/{print $2}' /proc/$PID/status) # Virtual Memory Size in KB
        RSS_MB=$(awk "BEGIN {printf \"%.2f\", $RSS/1024}")
        VM_MB=$(awk "BEGIN {printf \"%.2f\", $VM/1024}")
        printf "| %-15s | %10s | %7s | %2s/%2s | %8sMB | %8sMB |\n"   $PROCESS_NAME $ELAPSED_TIME $PID $NUM_OF_THREADS $EXPECTED_NUM_OF_THREADS $RSS_MB $VM_MB
    done
} #
____print_hugepages()
{ #
printf "${BGreen}hugepages ${NC}(Total, Free, Rsvd, Surp): "
    awk '/HugePages_Total/ {t=$2}
         /HugePages_Free/  {f=$2}
         /HugePages_Rsvd/  {r=$2}
         /HugePages_Surp/  {s=$2}
         END {print t", "f", "r", "s}' /proc/meminfo
} #
ww_elapsed_time_()
{ #
    ORIGINAL_DIR=$(pwd)   # Save the current directory
    local is_print_largefile=
    local is_print_ricIndication=
    if [[ "show_large_files" == $1 ]]; then
        is_print_largefile="yes"
    fi
    if [[ "show_ric_indication" == $2 ]]; then
        is_print_ricIndication="yes"
    fi
    printf "${BGreen}| ____________________ time | pid | threads | Memory (RSS & VM)\n$NC"
    printf "${BGreen}| ___ OAMMGR'S ___\n$NC"
    __elapset_time_with_mem "oammgr"          3
    printf "${BGreen}| ___ PHY ___$NC without faultmgr\n"
    __elapset_time_with_mem "phymgr"    3
    __elapset_time_with_mem "gnb_app"  83
    printf "${BGreen}| ___ DU ___\n$NC"
    __elapset_time_with_mem "duoam"          4
    __elapset_time_with_mem "dumgr"          2
    __elapset_time_with_mem "gnb_du_e2du"    4
    __elapset_time_with_mem "gnb_du_layer2" 18
    printf "${BGreen}| ___ CU ____\n$NC"
    __elapset_time_with_mem "gnb_cu_oam"   9
    __elapset_time_with_mem "gnb_cu_pdcp" 14
    __elapset_time_with_mem "gnb_cu_son"   2
    __elapset_time_with_mem "gnb_cu_rrm"   2
    __elapset_time_with_mem "gnb_cu_l3"    4
    __elapset_time_with_mem "gnb_cu_e2cu"  3
   ____print_hugepages
if [[ -n $is_print_largefile ]]; then
        printf "Files larger than ${RED}20MB in ${BGreen}CU/DU${NC}\n"
        cd /var/log/pw-share/pods/stack/cunode01/ && find . -type f -size +20M -printf "%s %p\n" | awk '{printf "CU1: %6dMB | %s\n", ($1/1024/1024), $2}'
        cd /var/log/pw-share/pods/stack/dunode02/ && find . -type f -size +20M -printf "%s %p\n" | awk '{printf "DU2: %6dMB | %s\n", ($1/1024/1024), $2}'
    fi
    if [[ -n $is_print_ricIndication ]]; then
        ww_ric_indication_show 2
    fi
    cd "$ORIGINAL_DIR"    # Return to the original directory
} #
ww_elapsed_time_extend()
{ #
    kubectl get pods -n pw
    ww_elapsed_time_
} #
___elapsed_time_watch()
{ #
    my_dict=$1
    local sleepTime=${my_dict["sleep"]}
    local repeat=${my_dict["repeat"]}
    if [[ -z $sleepTime ]]; then
        sleepTime=10
    fi
    if [[ -z $repeat ]]; then
        repeat=10
    fi
    for ((i = 0 ; i < repeat ; i++ )); do
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        local output=$(ww_elapsed_time_)
        tput clear # to clear the screen
        printf "$timestamp   sleep for $sleepTime ($i/$repeat)\n"
        echo "$output"
        sleep "$sleepTime"
    done
} #
ww_elapsed_time_watch_try()
{ #
    if [ "$#" -eq 0 ]; then    # works better in Athena?
    	echo "function with no arguments"
    	return
    fi
    clear -x
    local sleepTime=$1
    local is_print_largefile=$2
    local is_print_ricIndication=$3
    local repeat=300
    if [[ -z $sleepTime ]]; then
        sleepTime=10
    fi
    while true ; do
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        local output=$(ww_elapsed_time_ $is_print_largefile $is_print_ricIndication)
        tput clear # to clear the screen
        printf "$timestamp   sleep for $sleepTime ($repeat)\n"
        echo "$output"
        read -t $sleepTime -n 1 key
        case "$key" in
        [r]* )
            tput clear
            repeat=300
            sleepTime=5
            printf "New sleepTime: $sleepTime .. "
            ;;
        [ik]* )
            printf "\b \b"  # Erase key from screen
            repeat=300
            printf "New sleepTime: $sleepTime .. "
            while read -t 1 -n 1 key; do
                case "$key" in
                [i]* )
                    printf "\b \b"  # Erase key from screen
                    sleepTime=$((sleepTime+1))
                    printf "$sleepTime .. "
                    ;;
                [k]* )
                    printf "\b \b"  # Erase key from screen
                    if [ "$sleepTime" -ge 2 ]; then
                        sleepTime=$((sleepTime-1))
                        printf "$sleepTime .. "
                    fi
                    ;;
                * )
                    ;;
                esac
            done
            ;;
        * )
            ;;
        esac
        repeat=$((repeat-1))
        if [ "$repeat" -eq 3 ]; then
            repeat=100000
            sleepTime=30
        fi
    done
} #
ww_elapsed_time_4G()
{ #
    __elapset_time_ uniplatform 3
    __elapset_time_ univrunode 1
    __elapset_time_ sysmgr 3
    __elapset_time_ faultmgr 3
    __elapset_time_ configmgr 3
    __elapset_time_ tcpdump 1
    __elapset_time_ hwmgr 0
    __elapset_time_ resmon      3
    __elapset_time_ dhcpmgr     3
    __elapset_time_ certmgr     3
    __elapset_time_ uniftpmgr   0
    __elapset_time_ trafficmon  0
    __elapset_time_ hnbmgr      0
    __elapset_time_ oammgr      0
    __elapset_time_ routingmgr  0
} #

# === para#bash#.shared_bash#.vars ===
#!/bin/bash
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BIRed='\033[1;91m'
BGreen='\033[1;32m'
CU_LOGS='/var/log/pw-share/pods/stack/cunode01'     # oam
DU_LOGS='/var/log/pw-share/pods/stack/dunode02'     # oam
BINARY_FILE=$BINARY_DUOAM
BINARY_DUOAM="/opt/pw/nrstack/exec/gNB_DU/bin/duoam"           # DU pod
BINARY_DUMGR="/opt/pw/nrstack/exec/gNB_DU/bin/dumgr"           # DU pod
BINARY_E2DU="/opt/pw/nrstack/exec/gNB_DU/bin/gnb_du_e2du"      # DU pod
BINARY_L2="/opt/pw/nrstack/exec/gNB_DU/bin/gnb_du_layer2"      # DU pod
BINARY_CU_OAM="/opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_oam"     # CU pod
BINARY_CU_E2CU="/opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_e2cu"   # CU pod
BINARY_CU_L3="/opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_l3"       # CU pod
BINARY_CU_PDCP="/opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_pdcp"   # CU pod
BINARY_CU_RRM="/opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_rrm"     # CU pod
BINARY_CU_SON="/opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_son"     # CU pod
BINS_DU=( $BINARY_DUOAM $BINARY_DUMGR $BINARY_E2DU $BINARY_L2)
BINS_CU=( $BINARY_CU_OAM $BINARY_CU_PDCP $BINARY_CU_SON $BINARY_CU_RRM $BINARY_CU_L3 $BINARY_CU_E2CU)

# === para#bash#.shared_bash#threads_affinity.sh ===
#!/bin/bash
__get_threads_cpu_policy_go()
{ #
    PID=$1
    for TID in /proc/$PID/task/*; do
        STATUS_FILE="$TID/status"
        THREAD_NAME=$(grep "^Name:" $STATUS_FILE)
        CPUS_ALLOWED=$(grep "^Cpus_allowed:" $STATUS_FILE)
        CPUS_ALLOWED_LIST=$(grep "^Cpus_allowed_list:" $STATUS_FILE)
        echo "Thread ID: $(basename $TID)"
        echo "$THREAD_NAME"
        echo "$CPUS_ALLOWED"
        echo "$CPUS_ALLOWED_LIST"
        echo ""
        SCHED_POLICY=$(chrt -p $(basename $TID) | grep "policy" | cut -d: -f2)
        echo "Scheduling Policy: $SCHED_POLICY"
        echo "------------------------------------"
    done
} #
_get_threads_cpu_policy_go_compact()
{ #
    PID=$1
    for TID in /proc/$PID/task/*; do
        STATUS_FILE="$TID/status"
        THREAD_NAME=$(grep "^Name:" $STATUS_FILE | awk '{print $2}')
        CPUS_ALLOWED=$(grep "^Cpus_allowed:" $STATUS_FILE | awk '{print $2}')
        CPUS_ALLOWED_LIST=$(grep "^Cpus_allowed_list:" $STATUS_FILE | awk '{print $2}')
        TID=$(basename $TID)
        SCHED_POLICY=$(chrt -p $TID | grep "policy" | cut -d: -f2 | xargs)
        SCHED_PRIORITY=$(chrt -p $TID | grep "priority" | cut -d: -f2 | xargs)
        printf "| %9s | %15s | %11s | %8s | %12s | %15s |\n" $(basename $TID)  $THREAD_NAME  $SCHED_POLICY  $SCHED_PRIORITY  $CPUS_ALLOWED_LIST  $CPUS_ALLOWED
    done
} #
get_threads_cpu_policy()
{ #
    __get_PIDS_by_process_name $1
    printf "\nProcess: $1\n"
    printf "| %9s | %15s | %11s | %8s | %12s | %15s |\n"  "Thread ID" "Name" "Policy" "Priority" "Cpus_allowed" "Cpus_bitmap"
    for PID in $PIDS; do
        _get_threads_cpu_policy_go_compact $PID
    done
    echo '-------'
} #
get_threads_cpu_policy_DU()
{ #
    get_threads_cpu_policy dumgr
    get_threads_cpu_policy duoam
    get_threads_cpu_policy gnb_du_e2du
    get_threads_cpu_policy gnb_du_layer2
    get_threads_cpu_policy bin_reader
} #
get_threads_cpu_policy_CU()
{ #
    get_threads_cpu_policy gnb_cu_oam
    get_threads_cpu_policy gnb_cu_pdcp
    get_threads_cpu_policy gnb_cu_son
    get_threads_cpu_policy gnb_cu_rrm
    get_threads_cpu_policy gnb_cu_l3
    get_threads_cpu_policy gnb_cu_e2cu
} #

# === para#bash#.shared_bash#.commonFuncs.sh ===
#!/bin/bash
    if command -v pidof >/dev/null 2>&1; then
        PIDOF=pidof
    elif command -v pgrep >/dev/null 2>&1; then
        PIDOF=pgrep
    else
        echo "error: no pidof no pgrep!!"
        sleep 5
    fi
__get_PIDS_by_process_name_org()
{ #
    PIDS=$(pidof $1)
    if [ ! -n "$PIDS" ]; then
        printf "  %-15s -> No process found, waiting... \n" $1
        while ! pidof $1 >/dev/null; do
            printf "."
            sleep 1
        done
        PIDS=$(pidof $1)
    fi
} #
__get_PIDS_by_process_name()
{ #
    local process_name=$1
    PIDS=$($PIDOF "$process_name" 2>/dev/null)  # Capture output and suppress errors
    if [ -z "$PIDS" ]; then
        printf "  %-15s -> No process found, waiting... \n" "$process_name"
        while ! $PIDOF "$process_name" >/dev/null 2>&1; do
            printf "."
            sleep 1
        done
        PIDS=$($PIDOF "$process_name" 2>/dev/null)
    fi
    echo "$PIDS"
} #
____remove_files_with_prompt() {
    local files=("$@")  # Accepts a list of files as arguments
    printf "$RED REMOVE?$NC (y/SPACE = yes, any other key = no)\n"
    for file in "${files[@]}"; do
        if [[ -e "$file" ]]; then
            printf "${RED}REMOVE${NC} ${BGreen}'$file' ${NC}?: "
            read -n 1 -s response  # -n 1: One keypress, -s: Silent (no echo)
            case "$response" in
                [Yy]|" "|"")  # Accept 'y', 'Y', or SPACE as yes
                    rm "$file"
                    printf ">>> ${RED} Removed! ${NC}\n"
                    ;;
                * )
                    printf ">>> Skipped\n"
                    ;;
            esac
        else
            printf "File ${BGreen}'$file' ${NC}does not exist\n"
        fi
    done
}
__remove_prvt_files() {
    ____remove_files_with_prompt /var/log/pw-share/pods/stack/cunode01/prvt/*
    ____remove_files_with_prompt /var/log/pw-share/pods/stack/dunode02/prvt/*
}

# === cygwin64#home#bashrc_s#functions#ls_options.sh ===
function __ls_only()
{ #↓
	if ($# != 0) then
		printf " >> ls $@\n"
		ls $@
	fi
} #↑
function __lsa_grep()
{ #↓
	local cmd="ls -la"
	if ($# == 0)
	then
		printf " >> $cmd\n"
		eval $cmd
		return
	fi
	STRING1="$1"
	for var in "$@"
	do
		if [ $var != $1 ] ; then
			STRING1="$STRING1|$var"
		fi
	done
	printf " >> $cmd | egrep \"$STRING1\"  \n\n"
	eval $cmd | egrep "$STRING1"
	echo ""
} #↑
function __ls_grep()
{ #↓
	if (($# == 0)); then
		echo "function needs arguments"
		return
	fi
	local cmd=$1
	if [ "$#" -eq 1 ]    # works better in Athena...
	then
		printf " >> $cmd\n"
		eval $cmd
		return
	fi
	STRING1="$2"
	for var in "${@:3}"
	do
		STRING1="$STRING1|$var"
	done
	printf " >> $cmd | egrep -i --color \"$STRING1\"  \n\n"
	eval $cmd | egrep -i --color "$STRING1"
	echo ""
} #↑
alias lst='ls -allt --block-size=K --sort=size --reverse'
alias lst='ls -allt --block-size 1024 --sort=size -r'     # Moba
alias lsa='__ls_only -alt'
alias lsag='__lsa_grep'
alias lsa='__ls_grep "ls -alt"'
alias lsat='__ls_grep "ls -alt"'
alias ll='__ls_grep "ls -la"'
alias llt='__ls_grep "ls -lat"'
alias lltr='__ls_grep "ls -latr"'
alias ld='__ls_grep "ls -la | grep '^d'"'
alias ld='__ls_grep "ls -la | grep \"^d\""'
alias la='__ls_grep "ls -la"'

# === cygwin64#home#bashrc_s#cd_location#fzf01.sh ===
RED='\033[0;31m'
NC='\033[0m'
BIRed='\033[1;91m'
BGreen='\033[1;32m'
CHOSEN_FZF=""
____create_files_if_not_exist() {
    local arr=($@)   # strings to array
    for _file in "${arr[@]}"; do
        if [ ! -f "$_file" ]; then
            echo "touch $_file"
            touch "$_file"
            chmod 666 "$_file"
        fi
    done
}
____create_second_file_if_not_exist_and_touch_first() {
    local FILE1="$1"
    local FILE2="$2"
    if [ ! -f "$FILE2" ]; then
        echo "touch $FILE2 && sleep 2"
        touch "$FILE2"
        if [ ! -f "$FILE1" ]; then
            echo "WHY $FILE1 not exist??"
        fi
        sleep 2
        touch "$FILE1"
    fi
}
if [[ $TERM_NAME == "cygwin" || "MobaX" == $TERM_NAME ]]; then
    GREP_DIR="/$TERM_ROOT/c/ws/cygwin64/home/bashrc_s/cd_location/.grepDir"
    FUNCS_FILE____ORG="/$TERM_ROOT/c/ws/para/bash/.shared_bash/.funcs01"
    FUNCS_FILE_GREPED="$GREP_DIR/.funcs01_greped"
    COMMANDS_FILE__BKMRK="/$TERM_ROOT/c/gV82a/P/vimfilerBookmarksWsEdit"
    COMMANDS_FILE____ORG="/$TERM_ROOT/c/ws/cygwin64/home/bashrc_s/cd_location/_commands_for_fzf.sh"
    COMMANDS_FILE_GREPED="$GREP_DIR/_commands_for_fzf_greped.sh"
    MOBA_SSH_SETUPS____ORG="/$TERM_ROOT/c/Users/wshabso/AppData/Roaming/MobaXterm/home/moba_ssh_setups.sh"
    MOBA_SSH_SETUPS_GREPED="$GREP_DIR/moba_ssh_setups_greped"
    CD_DIR_FILE="/$TERM_ROOT/c/ws/cygwin64/home/bashrc_s/cd_location/_cd_directory_fzf.sh"
    OTHER_FILES=(C:/ws/para/tags C:/ws/para/bash/.shared_bash/.vars $MOBA_SSH_SETUPS_GREPED)
else
    GREP_DIR="$HOME/.config/.ww/.bash"
    FUNCS_FILE____ORG="$GREP_DIR/.bashrc"
    FUNCS_FILE_GREPED="$GREP_DIR/.funcs01_greped"
    COMMANDS_FILE_GREPED="$GREP_DIR/_commands_for_fzf_greped.sh"
    COMMANDS_FILE_REMOTE____ORG="$GREP_DIR/.commands_for_fzf.sh"
    COMMANDS_FILE_REMOTE_GREPED="$GREP_DIR/.commands_for_fzf_greped.sh"
    CD_DIR_FILE="$GREP_DIR/.cd_directory_fzf.sh"
    OTHER_FILES=($GREP_DIR/.vars)
    ____create_second_file_if_not_exist_and_touch_first "$COMMANDS_FILE_REMOTE____ORG" "$COMMANDS_FILE_REMOTE_GREPED"
    ____create_second_file_if_not_exist_and_touch_first "$FUNCS_FILE____ORG"           "$FUNCS_FILE_GREPED"
fi
EDIT_COMMAND_RENDER="READLINE_RENDER"
EDIT_COMMAND_RENDER="edit_command"
EDIT_COMMAND_RENDER="add_to_history"
FZF_ARGS=""
FZF_ARGS+=" --layout=reverse"
FZF_ARGS+=" --cycle"
FZF_ARGS+=" --tiebreak=index"
FZF_ARGS+=" --no-mouse"          # Claude: --no-mouse prevents some terminal issues
FZF_ARGS+=" --height=90%"
export FZF_DEFAULT_OPTS='
  --ansi
  --color=hl:underline,hl+:reverse
  --pointer=">"
  --marker="●"
'
if hash bat; then
    FZF_WITH_BAT="--preview 'bat --color=always --style=numbers {}'"
    FZF_WITH_BAT=(
      --preview
      "bat --color=always --style=numbers {}"
    )
else
    FZF_WITH_BAT=()
fi
FZF_WITH_BAT=()
___is_file1_newer_than_file2() {
    if [[ ! -f "$1" || ! -f "$2" ]]; then return -1; fi
    if [ "$1" -nt "$2" ]; then return 0; fi
    return -1
}
__Refresh_Files_Commands() {
    local FILE1="$1"
    local FILE2="$2"
    if ___is_file1_newer_than_file2 "$FILE1" "$FILE2"; then
        echo "grep again on $FILE1"
        sed 's/^@ bash@//g; s/\s*@ bash@//g' "$FILE1" > "$FILE2"
        return 0
    fi
    return -1
}
__Refresh_Files() {
    local is_refreshed=""
    local FILE1="$COMMANDS_FILE__BKMRK"
    local FILE2="$COMMANDS_FILE____ORG"
    if ___is_file1_newer_than_file2 "$FILE1" "$FILE2"; then
        echo "grep again on $FILE1"
        grep "@ bash@"  "$FILE1" | sed 's/@ bash@//' > "$FILE2"
        is_refreshed="Y"
    fi
    if [ "$FUNCS_FILE____ORG" -nt "$FUNCS_FILE_GREPED" ]; then
        echo "grep again on funcs file (try grep on functions)"
        grep -E "^[a-z,A-Z,_]{4,}()" "$FUNCS_FILE____ORG" > "$FUNCS_FILE_GREPED"
        sed -i 's/()//g; s/^function //g' "$FUNCS_FILE_GREPED"
        is_refreshed="Y"
    fi
    if __Refresh_Files_Commands "$COMMANDS_FILE____ORG"        "$COMMANDS_FILE_GREPED";        then is_refreshed="Y"; fi
    if __Refresh_Files_Commands "$COMMANDS_FILE_REMOTE____ORG" "$COMMANDS_FILE_REMOTE_GREPED"; then is_refreshed="Y"; fi
if [ "$MOBA_SSH_SETUPS____ORG" -nt "$MOBA_SSH_SETUPS_GREPED" ]; then
        echo "grep again on MOBA_SSH_SETUPS file"
        grep -E "^\s*REMOTE" "$MOBA_SSH_SETUPS____ORG" > "$MOBA_SSH_SETUPS_GREPED"
        is_refreshed="Y"
    fi
    if [[ $is_refreshed == "Y" ]]; then echo "sleep..."; sleep 2; fi
}
__get_combined_content() {
    if [ -f "$COMMANDS_FILE_GREPED" ]; then
        cat "$COMMANDS_FILE_GREPED"
    fi
    if [ -f "$COMMANDS_FILE_REMOTE_GREPED" ]; then
        cat "$COMMANDS_FILE_REMOTE_GREPED"
    fi
    if [ -f "$FUNCS_FILE_GREPED" ]; then
        cat "$FUNCS_FILE_GREPED"
    fi
}
function MyCommandsBetter() {
    local edit_command="$EDIT_COMMAND_RENDER"
    if [[ "--edit_commad" == "$1" ]]; then
        edit_command="$2"
        shift 2
    fi
    __Refresh_Files 
    local current_input="${READLINE_LINE}"
    local MYGREP=""
    if [ "$#" -gt 0 ]; then    # works better in Athena?
    	MYGREP='| grep -E \"$@\"'
    fi
    if [ "$#" -gt 0 ]; then
        CHOSEN_FZF=$(__get_combined_content | grep -E "$@" | fzf $FZF_ARGS "${FZF_WITH_BAT[@]}")
    else
        CHOSEN_FZF=$(__get_combined_content                | fzf $FZF_ARGS "${FZF_WITH_BAT[@]}")
    fi
    ____RemoveTrailing
    __render_selected "$CHOSEN_FZF" "$edit_command"
}
function MyCD_Directory() {
    local edit_command="$1"
    clear -x
    __Refresh_Files
    CHOSEN_FZF=$(
        {
            cat $CD_DIR_FILE
            for _file in "${OTHER_FILES[@]}"; do
                if [ -f $_file ]; then
                    cat $_file
                fi
            done
        } | fzf $FZF_ARGS "${FZF_WITH_BAT[@]}"
    )
    if ! [[ $? -eq 0 && -n "$CHOSEN_FZF" ]]; then
        return
    fi
    CHOSEN_FZF=${CHOSEN_FZF/ C:\// \/$TERM_ROOT\/c\/}
    ____RemoveTrailing
    __render_selected "$CHOSEN_FZF"  "$edit_command"
}
function MyHistory() {
    local CHOSEN_FZF=$(history | fzf $FZF_ARGS "${FZF_WITH_BAT[@]}")
    READLINE_LINE=${CHOSEN_FZF#*$'\t'}
}
____RemoveTrailing() {
    CHOSEN_FZF="${CHOSEN_FZF%%▪*}"
    CHOSEN_FZF="${CHOSEN_FZF%%   #*}"
    CHOSEN_FZF=$(echo "$CHOSEN_FZF" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
}
function MyOpenFiles()
{ #[
    COMMANDO=$(fzf)
    echo "chosen: $COMMANDO"
    COMMANDO="vi $COMMANDO"
    COMMANDO=$(echo $COMMANDO | cut -f1 -d"#")
    echo "will do: $COMMANDO"
    sleep 2
    if $COMMANDO; then
        printf "$BGreen SUCCESS $NC\n"
    else
        printf "$BIRed COMAND FAILED $NC\n"
    fi
} #]
bind '"\C-g":"MyCommandsBetter\n"'
bind '"\C-r":"MyCD_Directory\n"'
alias rr='MyCD_Directory "edit_command"'
bind -x '"jl": __guardFunc MyCommandsBetter --edit_commad READLINE_RENDER'
printf "$BGreen Use Ctr-r + Ctrl-g / jl with fzf + rr\n$NC"

# === para#bash#.shared_bash#.git_funcs ===
#!/bin/bash
git_clean_dfx_with_prompt()
{ #
    git clean -n -dfx
    printf "the above was:${BGreen} git clean -n -dfx ${NC}\n\n"
    printf "${BGreen} this one should be empty: ${NC}\n"
    echo ' git clean -n -dfx  -e ".help/" -e "gnbstack/common/porting/inc/"  | grep "help\|wlgr" '
    git clean -n -dfx  -e ".help/" -e "gnbstack/common/porting/inc/"  | grep "help\|wlgr"
    printf "${BIRed} Do you want to clean -dfx ??? [yn]... ${NC}"
    read  keys
    case "$keys" in
        [Yy]* )
            echo 'git clean    -dfx  -e ".help/" -e "gnbstack/common/porting/inc/"'
            git clean    -dfx  -e ".help/" -e "gnbstack/common/porting/inc/"
            ;;
        * )
            echo "skipping..."
    esac
} #
git_reset_hard()
{ #
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)
    if [[ -z "$upstream_branch" ]]; then
        echo "No upstream branch is set for '$current_branch'."
        exit 1
    fi
    echo "Current branch:    $current_branch"
    echo "Tracking upstream: $upstream_branch"
    if [[ -n $(git status --untracked-files=no --porcelain) ]]; then
        echo "Warning: You have local modified changes!!!!!!!!!!!!!!"
        git status --short
    elif [[ -n $(git status --porcelain) ]]; then
        echo "Warning: You have local untracked files..."
        git status --short
    else
        echo "no changed files"
    fi
    read -p "Are you sure you want to reset hard to '$upstream_branch'? (y/N) " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git reset --hard "$upstream_branch"
        echo "Branch '$current_branch' has been reset to match '$upstream_branch'."
    else
        echo "Reset aborted."
    fi
} #
ww_git_update_config()
{ #
    if [ ! -d $HOME/.config/.ww/ ]; then 
        echo "no Dir: $HOME/.config/.ww/"
        return -1
    fi
    cd $HOME/.config/.ww/
    if [[ -n $(git status --porcelain) ]]; then
        echo "❌ Working directory not clean. Commit, stash or discard changes before pulling."
        return -1
    else
        echo "✅ Working directory clean. Pulling latest changes..."
        git pull
    fi
} #

# === cygwin64#home#bashrc_s#git_stuff#git_aliases.sh ===
#!/bin/bash
function githelp() {
    echo "git branch -a   # will show remote and local"
    echo "git branch -vv  # will show remote and local"
}
function gitLogOptions() {
	if [ $1 == "-h" ]; then
		printf "    gsm  --> git status --untracked-files=no\n"
		printf "    glo  --> git status --untracked-files=no\n"
		printf "    glfh --> git log -p <filename>#  file diff history \n"
		printf "    gfp  --> git fetch --prune \n"
	elif [ $1 == "gsm" ]; then
		git status --untracked-files=no
		printf "  →→$GREEN git status --untracked-files=no $NC\n"
		printf "$YELLOW  (------------ WA: without listing untracked files ------------)$NC\n"
	fi
}
glo_oneline_formated_func() {
    clear -x
    if [ "$#" -eq 0 ]; then
        printf "git log --format... ${GREEN}use '-a' to show all, '-4' for 4 etc ${NC}\n"
        num_of_records="-10"
    elif [ "$1" == "-a" ]; then
        num_of_records=""
    fi
    git log --date=format:'%Y_%m_%d %H:%M'   \
        --format='%C(yellow)%ad  %C(red) %<(23)%p %C(cyan)%h %C(blue)| %<(23)%an |%C(reset) %s'   \
        $num_of_records   \
        "$@"
}
function gsm() {
    echo -e "\033[1;33m------------ git status --untracked-files=no ------------\033[0m"
    echo -e "\033[1;33m------------ WA: without listing untracked files ------------\033[0m"
    git status --untracked-files=no "$@"
}
ww_git_pull_if_no_change() {
    if ! git diff --quiet && ! git diff --cached --quiet; then
        echo "❌ Tracked files are modified or staged. Commit or stash them before pulling."
        exit 1
    fi
    echo "✅ No changes to tracked files. Pulling latest changes..."
    git pull
    return
    if [[ -n $(git status --porcelain) ]]; then
        echo "❌ Working directory not clean. Commit, stash or discard changes before pulling."
        return 1
    fi
    echo "✅ Working directory clean. Pulling latest changes..."
    git pull
}
__git_status_filtered() {
    clear -x
    printf "$PURPLE function __git_status_filtered() $NC\n"
    printf "$BGreen     git status | grep -v "_UG#_Store" $NC\n\n"
    git status | grep -v "_UG#_Store"
}
alias gba='git branch -a -vv'
alias gb='git branch -vv | cat'
alias gs='git status'
alias gbw='git branch -vv | grep -i "wa" | bat -S'
alias gbc='git branch -vv --color | grep --color "\*"'
alias gsf='__git_status_filtered'
alias gdw="git diff -w --ignore-blank-lines"
alias gitdiff='git diff $COMMIT~ $COMMIT'  # first is Previous and later current
alias | egrep "git "

# === cygwin64#home#bashrc_s#git_funcs#git_funcs_2025_12.sh ===
ww_git_delete_current_local_branch() { # added with claude in 2025_12_11
    clear -x
    local current_branch=$(git branch --show-current)
    if [ -z "$current_branch" ]; then
        echo "Error: Not currently on a branch (already detached?)"
        return 1
    fi
    echo "Current branch: $current_branch"
    echo "Fetching and pruning remote refs..."
    git fetch --prune || echo "Warning: fetch failed, continuing anyway..."
    local remote_tracking=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$remote_tracking" ] && [ "$remote_tracking" != "@{u}" ]; then
        echo "Warning: Remote tracking branch '$remote_tracking' still exists"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            return 1
        fi
    else
        echo "✓ No remote tracking branch (safe to delete)"
    fi
    if ! git diff-index --quiet HEAD --; then
        echo "Warning: You have uncommitted changes"
        read -p "Checkout and lose changes? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            return 1
        fi
    fi
    echo "Detaching HEAD..."
    git checkout --detach || return 1
    echo "Attempting to delete branch '$current_branch'..."
    if git branch -d "$current_branch" 2>/dev/null; then
        echo "✓ Branch '$current_branch' deleted successfully"
    else
        echo "Branch has unmerged commits."
        read -p "Force delete? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git branch -D "$current_branch"
            echo "✓ Branch '$current_branch' force deleted"
        else
            echo "Aborted. Staying in detached HEAD state."
            return 1
        fi
    fi
}
ww_git_show_pr_commits() {
    clear -x
    local merge_sha=$1
    git show $1
    echo "Merge commit:"
    git show --format="%ad   %p   %h | %s" --date=format:'%Y_%m_%d %H:%M' -s "$merge_sha"
    echo -e "\nPR commits:"
    git log --format="%ad   %p   %h | %s" --date=format:'%Y_%m_%d %H:%M' "${merge_sha}^1..${merge_sha}^2"
}
if false; then
    git log --merges --oneline --ancestry-path <commit-sha>..develop
    git log --merges --oneline --ancestry-path e2cf8b68c1..develop
fi

# === para#bash#.shared_bash#_kubectl ===
#!/bin/bash
__restart_pod() {
    if [ "$#" -gt 0 ]; then
        pod_str="$1"
    else
        printf "${GREEN}cu)${NC}   restart CU\n"
        printf "${GREEN}du02)${NC} restart dunode02\n"
        printf "${GREEN}du03)${NC} restart dunode02\n"
        read -p "Choose Option: " keys
        case "$keys" in
        [c]* )
            pod_str="cunode"
            ;;
        du )
            pod_str="dunode02"
            ;;
        du2 )
            pod_str="dunode02"
            ;;
        du02* )
            pod_str="dunode02"
            ;;
        du03* )
            pod_str="dunode03"
            ;;
        * )
            echo "skipping..."
            return
            ;;
        esac;
    fi
    pod_name=$(kubectl get pods -n pw | grep $pod_str | awk '{print $1}');
    if [ -n "$pod_name" ]; then
        kubectl delete pod -n pw $pod_name > /dev/null 2>&1 &
        echo Restarting $pod_str
    else
        echo -e "No $pod_str POD installed"
    fi
}
ww_get_manifest_list_from_smo_nr_dev() {
    curl -s --location https://10.194.63.10:443/api/v1/artifact/manifest/all  -H "Authorization: Basic cGFyYWxsZWw6R29yZTJJS2o3cVJFT25ueVlzRXU4d1c5" -k | jq -r '.[].ID' | sort -r
}

# === para#bash#.shared_bash#os_info.sh ===
ww_show_os_info_release_etc() {
    cat /etc/os-release    # Shows OS name and version
    uname -a        # –  Displays kernel name, version, architecture, and more.
    hostnamectl     # –  Displays information about the hostname and OS version.
    lsb_release -a  # –  Displays Linux Standard Base (LSB) version information.
    uptime          # –  Shows how long the system has been running + number of users + system load.
    w
    dmesg | head    # –  Displays boot messages and hardware information.
}
ww_show_os_amd_arm_intel() {
    lscpu | grep 'Architecture:\|Vendor ID:'
}
ww_show_os_info_hardware_etc() {
    lscpu    #–  Provides detailed CPU architecture information.
    lshw     #–  Displays comprehensive information about all hardware.
    lsblk    #–  Lists information about all block devices (disks and partitions).
    free -h  #–  Shows memory usage in a human-readable format.
    df -h    #–  Displays disk space usage in a human-readable format.
    lspci    #–  Lists PCI devices (e.g., GPUs, network cards).
    lsusb    #–  Lists USB devices connected to the system.
    ip addr show       #–  Shows IP addresses and network interfaces.
    nmcli device show  #–  Shows network connection information.
    ss -tuln           #–  Displays listening ports (TCP/UDP).
    ifconfig or ip a   #–  Shows detailed network interface information.
    mount                #–  Lists all mounted filesystems.
    cat /proc/mounts     #–  Displays mounted filesystems (similar to mount).
    du -sh /             #–  Shows disk usage for a specific directory.
}

