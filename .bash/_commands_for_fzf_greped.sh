 __update_ugrep_indexes  ▪ safe ugrep
 source /$TERM_ROOT/c/ws/cygwin64/home/bashrc_s/git_stuff/git_prompt_03.sh
 git fetch && git reset --hard @{u}   ▪ reset to following branch
 git reset --hard @{u}                ▪ reset to following branch
 git reset --hard origin/$BRANCH      ▪ reset to 
 git fetch --prune && git rebase origin/develop  ▪
 git merge origin/develop                        ▪
 git fetch --prune                               ▪
 ww_git_delete_current_local_branch              ▪ git branch delete
 git stash  ▪ TODO!
 git reset file  ▪ revert git add (if modified will stay modified)
 git_touch_last_commit_and_modified  ▪ safe with prompt
 git ls-tree COMMIT PATH  ▪ get <mode> <type> <object-sha> <file-name>
 git hash-object PATH     ▪ get <mode> <type> <object-sha> <file-name>
 git cherry-pick abc123^..def456     ▪ from parent of abc123 up to def456 changes
 git difftool --tool=vimdiff  ▪ side by side in terminal
 git checkout -b $BRANCH origin/$BRANCH      ▪ 
 git status && git branch                    ▪ 
 git status | grep -v ._UG#_Store            ▪ 
 git branch -vv                              ▪ 
 git status --untracked-files=all | grep -v ._UG#_Store  ▪ #
 git add -u  ▪ # --update -> all tracked files (not new files) ▪   
 git ls-files -o --exclude-standard ▪ # list files that will be added (untracked)  
	git show abc1234:src/main.cpp > main.cpp         ▪  show file content from some commit
	                                                       ▪ 
glo_oneline_formated --author='Wesley'	                       ▪ 
 git diff --stat         ▪ how many lines added/removed  ++++++++-----
 git diff --numstat      ▪ how many lines added/removed  7  1 (left is added, right is removed)
 git diff --name-status  ▪ M, A, D?
 git diff $COMMIT~ $COMMIT   ▪
	alias glg="git log --all --decorate --oneline --graph" ▪  A DOG: all decorate oneline graph
	git log --pretty=oneline -5      ▪ 
	git log --oneline -10                                  ▪ 
	git reflog show HEAD                                   ▪ 
	git log --format="" --numstat -3                       ▪  # files can repeat (if you changed same recently in 2 commits etc)
	git log --format="" --stat -5                          ▪  #
	gl1 --numstat -4                                       ▪  # same as regular + number of lines added/deleted
	gl1 --numstat -- SDNVMe/ -- SDTools/SdDL/ -50          ▪   # to show only files changed in our directoris:
 git log -L :FUNC:FILE          ▪ func changes 
	git log -p FILE              ▪ git diff file history
	git log -p DIR               ▪ git diff directory history
	git show                     ▪ last commit changes
	git show $COMMIT             ▪ same as git diff with it's parent when there is 1 parent 
	git diff $COMMIT~ $COMMIT    ▪ 
	git diff -w --ignore-blank-lines      ▪ 
 { git diff --no-color --numstat; git diff --no-color; } >> /$TERM_ROOT/c/ws/para/Git/
 { glo_oneline_formated --no-color -10; git diff --no-color --numstat; git diff --no-color; } >> /$TERM_ROOT/c/ws/para/Git/
	git checkout -b Gen5_Phase3.2_Integration_Tmp          ▪ 
 git rev-parse --short FullHashCommit     ▪ print short version of commit hash 
	eval $(ssh-agent -s)                     ▪ for my git push...
	ssh-add /home/wshabso/.ssh/id_2023_12_06 ▪ for git in PW
 git --help ▪ #                      
	          ▪ 
  ▪
 sort filename | uniq -c  ▪ count the number of times each unique line appears
 uniq -c file             ▪ count the number of times each unique line appears (file should be sorted)
 EDIT_COMMAND_RENDER="add_to_history" ▪ then populate with up arrow key
 EDIT_COMMAND_RENDER="edit_command"   ▪ edit the command but not with completion etc
 EDIT_COMMAND_RENDER="execute_as_is"  ▪ 
 vim --servername GVIM --remote-send  '<C-W>:e C:/ws/cygwin64/home/bashrc_s/learn/awk/ex01.sh' ▪ 
 awk '{print $1, $2}' file01.txt  ▪ print certain words with comma seperated
 awk '/^cpu/ {print $1, $2}' file01.txt   ▪ grep + print words..
   ▪ 
 echo "$PWD" | sed 's/\/cygdrive\/c/C:/; s/\/drives\/c/C:/'  ▪ 
 sed -i '/^\s*$/d' file  ▪ --in-place, delete black lines from file
 sed -i '/^Discarding log.*$/d; /^\s*$/d; /^No space available:.*$/d' gnb_cu_e2cu.log   ▪ --in-place, delete multiple lines by patterns
 perl -pe 's/pattern/replacement/'   ▪ -p: processes each line of input, -e: executes the given Perl code.
 tar --exclude="unwanted_file.txt" -xzvf zipFile.tar.gz  ▪ Exclude While Extracting 
 tar --exclude="unwanted_file.txt" -czvf new.tar.gz      ▪ Exclude While Creating   
 tar -tvf myZip.tar.gz | awk '{print $3, $6}' | sort -nr | head -n 50   ▪ list 50 biggest files   
 tar -tvf myZip.tar.gz | sort -k3,3nr | head -n 50   ▪ list 50 biggest files   
  date +"%Y_%m_%d %H:%M:%S"    ▪ print date   
 ln -s  /home/user/my_directory my_link  ▪ create soft link   
 ln -sf /home/user/my_directory my_link  ▪ overwrite an existing soft link   
 tar -czvf  ▪ to tar,   args: zipFile.tar.gz file1 file1  , to zip
 tar -xzvf  ▪ to untar, args: zipFile.tar.gz file1
 tar -xzvf zipFile.tar.gz file1                 ▪ # to untar
 tar -xzvf zipFile.tar.gz file1 --directory DIR ▪ # to untar to specific directory
 tar -czvf zipFile.tar.gz file1 file2 ▪ # to tar, to zip
 tar -tvf  zipFile.tar.gz 'search-pattern' ▪ # list with optional search pattern
 wget URL ▪ download
 for f in *\ *; do mv "$f" "${f// /_}"; done ▪ # rename by replace space to dash
 for f in *\ *; do echo $f; done # just echo example  rename
 find_files_changed_last_X_minutes -60  ▪ files modified last 60min (hour)
 find_files_changed_last_X_day     -0.8 ▪ files modified last 0.8 day (0.8 * 24 * 60 minutes)
  ▪
 find . -type f -exec du -hk {} \; | sort -nr ▪ files by size, reverse the sort
 find . -type f -mtime -0.8 -exec bash -c 'timeSinceLastUpdate "$0"' {} \;  ▪
 find2 -type f -mtime -1.5  ▪   in days (24 hours)  
 find2 -type f -mtime -1.5  ▪   in days (24 hours)  
 find . -type f -mtime -0.1  ▪ in days (24 hours) ∙∙! -path "*\.git\/*"∙∙  
 find . -type f -mtime -0.1  ▪\n in days (24 hours) ∙∙! -path "*\.git\/*"∙∙  
 find . -type f -mmin -60 ! -path "*\.git\/*"    ▪ in minutes  find 
 find . -type f -mtime -0.1 ! -path "*\.git\/*"  ▪ in days (24 hours)    find 
 find . -type f -not -path "*\.git\/*"           ▪ find no git 
 find . \( -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.hpp" \) -type f >> __ALL_FILES      ▪
  ▪
  find . -type f -empty           ▪# check for empty files (no delete) 
  find . -type f -empty -delete   ▪# delete empty files                
  ▪
  ▪
 ugrep_01                              -rl "" ▪ Show which files it will search
 ugrep_01 --ignore-files=.ugrep_ignore -rl "" ▪ Show which files it will search respecting ignore file
 ugrep_indexer_HIV                              --check  ▪# only report
 ugrep_indexer_HIV --ignore-files=.ugrep_ignore --check  ▪# only report
 ugrep_indexer_HIV --ignore-files=.ugrep_ignore          ▪# update indexes
  ▪
  export PYTHONPATH="C:/ws/src/cpuCom/docker01/stack-tools/cpu_and_tpt_analysis/"   ▪   
  less +G
  ps axo stat,tty,tpgid,sess,pgrp,ppid,pid,pcpu,comm,cmd --sort=-start_time | head -n 23   ▪ show last processes  
  source /root/.config/_bash/..bashrc     ▪  -- basrc
  kg                           ▪  -- show pods ~
  kubectl get pods -n pw       ▪  -- alias kg is that
  watch kubectl get pods -n pw ▪  --
  ./nr_setupTool_k8s.sh du     ▪  -- switch to du
  ./nr_setupTool_k8s.sh cu     ▪  -- switch to cu
  cd /var/log/prvt             ▪  -- in DU/CU pod
  cd /root && ./nr_setupTool_k8s.sh -c && ./nr_setupTool_k8s.sh && ./nr_setupTool_k8s.sh pods  ▪  -- copy and restart
  tail -f cu/cleanExit.log   ▪  --
  make run ARGS='' ▪ ARGS='first_arg  second_arg'
  ./docker-create.sh && ./docker-run.sh  ▪  --
  time make -sj scf.dist                 ▪  -- # takes 3:00
  your_command 2>&1 | tee -a output.log  ▪  -- redirect both stdout and stderr to file while still printing to console
	chown -R Administrators:None ./  ▪ 
    du -sh .??* *    ▪ in current dir (also hidden files with at least 2 characters   
    du -sh .*   *    ▪ in current dir (also hidden + total current (.) and total parent (..) 
    du -hs */        ▪ directories in current    
    du -hs /*/       ▪ directories in root maybe 
	stat file.txt                    ▪ 
	perl -e 'for(<applog_0*>){((stat)[9]<(unlink))}'               ▪  # one of best ways to remove huge amount of files (even when rm don't work)
	rsync --relative  Alpha/Lib/yourFile.cpp dir1/dir1son/         ▪  # like cp --parents   - works on solaris sparc
 time ctags --options=.ctags -R . && dos2unix tags && wc -l tags          ▪ ctags working
 wc -l tags && time ctags --exclude=*.json -R . && dos2unix tags && wc -l tags          ▪ ctags working
 time ctags -R . && dos2unix tags && wc -l tags          ▪ ctags working
 ctags -R -f tags asn_enc_dec/ orane2/ security/          ▪ ctags working
 ctags.exe  -R --fields=+l --c-kinds=+lp --c++-kinds=+lp ./*                        ▪ ctags  # generate tags for cpp file
 ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --exclude=\./QAFramework/  ./     ▪ ctags
 dos2unix tags && wc -l tags  ▪ after ctags
 scp wshabso@ilks-dockerpool:/work/wshabso/BBBBB/unitTest/e2cu_ut_frwk/logs/* ./  ▪ # 
 scp wshabso@ilks-dockerpool:/work/wshabso/devWA/diff_2025_09_docker ./  ▪ # 
	grep -i "signal" iprs_pstack_*                                 ▪ 
 echo $PATH | sed 's/:/\n/g'    ▪ show PATH line by line
 $env:path -replace ';', "`n"   ▪ print $PATH in powershell line by line
 tmux ls ▪ # 
 tmux -u new-session -s ssy_git  ▪ -u for utf-8 
 python C:/ws/para/bash/.shared_bash/clean_files.py  ▪ clean bash 
 a  ▪ # 
 printf "len of variable str is ${#str} \n"  ▪ learn: len of variable
 a  ▪ # 
 rm bin_reader duoam      dumgr     gnb_du_e2du gnb_du_layer2
 rm bin_reader gnb_cu_oam gnb_cu_l3 gnb_cu_e2cu gnb_cu_pdcp   gnb_cu_rrm gnb_cu_son
 __my_tshark_yman     controlplane_cu.pcap0  pcap_cu_0
 __my_tshark_yman_all controlplane_cu.pcap0  pcap_cu_0_full
 ▪ 
 tasklist | grep -E "cmd|bash" ▪ works with cygwin, process list
 tasklist | wc -l  ▪ process list
 taskkill /F /PID PID ▪ kill process
 wmic process get parentprocessid,processid,executablepath ▪ process list
 wmic process get parentprocessid,processid,executablepath,WorkingSetSize | grep -E "chrome\.exe"  ▪ process list
 ▪ 
 ▪ 
	PID_IPRSD=$(GetIprsPID_from_file) && echo $PID_IPRSD    ▪  kill
	cd /var/iprs/log/iprsd/ && lag $PID_IPRSD               ▪ 
	PID_IPRSD=$(GetIprsPID_from_file) && echo $PID_IPRSD && kill -USR1 $PID_IPRSD   # to reload iprsd.ini   ▪ 
	echo " 1571 V53 official 1 started ================================" >> /usr/local/iprs/bin/prstat_output  ▪ 
	tail -f /var/log/ha_scripts.log                                ▪ 
	iprslog | egrep \"====|active\""                               ▪ 
	iprslog | egrep ": SendRemotePacketToOrg |: branding type "    ▪ 
	iprslog | grep -i "Sent statistic update success for org 5056" ▪ 
	cat /usr/local/iprs/bin/prstat_output                          ▪ 
	tail /usr/local/iprs/bin/prstat_output                         ▪ 
	tail -f /usr/local/iprs/bin/vrrpFile                           ▪ 
	tail -f /usr/local/iprs/bin/vrrpCur                            ▪ 
	tail -f /var/iprs/log/iprsd/monitor_applog_current.log | egrep "avg time"   ▪ 
	WW_iprsd_memory_leak                                           ▪ 
	node-show                                                      ▪ 
