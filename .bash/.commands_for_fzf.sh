watch      kubectl get pods -n pw    # bcs 'watch kg' with alias won't work...
watch -n 4 kubectl get pods -n pw
uptime && who && w
ww_elapsed_time_watch_try 10 show_large_files show_ric_indication
ww_elapsed_time_watch  4
ww_watch_elapsed_time_2        # watch every 2 seconds
ww_watch_elapsed_time_4        # watch every 4 seconds
check_process_sockets_cu
check_process_sockets_du
ww_elapsed_time_          # 1 time
ww_elapsed_time_extend    # 1 time
ww_watch_elapsed_time_extend_4
ww_ric_indication_show
for f in /root/cu/nrlogs/*.log;   do tail -n 100 "$f" | grep -w "RIC Indication sent to RIC" && echo "Match in $f"; done
for f in /root/du02/nrlogs/*.log; do tail -n 100 "$f" | grep -w "RIC Indication sent to RIC";  done
grep -w "RIC Indication sent to RIC" /root/cu/nrlogs/*.log
tcpdump -i any sctp
tcpdump -i any "sctp and $ALL_RIC_IPS"
tcpdump -i any "sctp and $ALL_RIC_IPS" | grep -v HB
tcpdump -i any sctp    | grep DATA
tcpdump -i any sctp    | grep -v HB
tcpdump -i any sctp and host $RIC_IP   | grep DATA
tcpdump -i any sctp and host $RIC_IP   | grep -v HB
tcpdump -i any sctp -v | grep -E "length [1-2][0-9][0-9]"   # capture ric indication
alias ww_tcpdump_ric='tcpdump -i any sctp and \(host 10.166.11.179 or host 10.166.9.169\)'
tcpdump -i any sctp and \(host 10.166.11.179 or host 10.166.9.169\)                        # find RIC
tcpdump -i any sctp and \(host 10.166.11.179 or host 10.166.10.88 or host 10.166.9.169\)   # find RIC
tcpdump -i any 'sctp and (host 10.166.11.179 or host 10.166.10.88 or host 10.166.9.169)'   # find RIC
ALL_RIC_IPS="(host 10.166.11.81 or host 10.166.11.179 or host 10.166.10.88 or host 10.166.9.169)"
tcpdump -i any "sctp and $ALL_RIC_IPS"
RIC_IP="10.166.9.169"   # ric-109
RIC_IP="10.166.11.179"  # ric-103
RIC_IP="10.166.11.81"   # Evyatar's
RIC_IP="10.166.10.88"   # RickyGal
watch -n 1 'conntrack -L -p sctp'   # connection ESTABLISHED or CLOSED etc
lfrc_r33_linux_amd64 /proc/$(pidof gnb_du_e2du)
ps -o ppid= -p $(pidof dumgr)   # find PPID (the parent is oammgr)
vi       /root/du/nrlogs/gnb_du_layer2.log
tail -f /root/du/nrlogs/gnb_du_layer2.log
tail -f /var/log/pw-share/pods/stack/cunode01/nrlogs/e2cu_main
vi /root/.config/.bash/.commands_for_fzf.sh
vi /root/du/messages
tail -f /root/du/messages
mv /staging/crashes/core* /var/log/                     ▪ inside CU/DU pod @ gdb core crash @ bash@
gdb /opt/pw/nrstack/exec/gNB_CU/bin/gnb_cu_l3 core      ▪ inside CU/DU pod @ gdb core crash @ bash@
gdb /opt/pw/nrstack/exec/gNB_DU/bin/dumgr core          ▪ inside CU/DU pod @ gdb core crash @ bash@
strace -p $(pidof gnb_app)
gdb -p $(pidof gnb_app)
gdb $BINARY_FILE --batch -ex "attach $(pidof gnb_cu_oam)" -ex "thread apply all backtrace"
kubectl top pods -n pw              # memory and cpu usage
BINARY_FILE=$
cd /root && ./nr_setupTool_k8s.sh -c && ./nr_setupTool_k8s.sh j # -- copy and restart pods
./nr_setupTool_k8s.sh du
kubectl edit deployment dunode02 -n pw -o yaml  # maybe will work without '-o yaml'
kubectl get pods -n pw -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'  # get ip of all pods but it's the external...
PID=$(pidof dumgr)         && echo $PID
PID=$(pidof gnb_du_layer2) && echo $PID
PID=$(pidof oammgr)        && echo $PID    # should be 2 pids
top -p $(pidof gnb_du_layer2) -H -d 5  # show process threads, update every 5 second
top -p $(pidof gnb_cu_pdcp) -H -d 5  # show process threads, update every 5 second
__stats_utime_stime "oammgr"
pmap -x $PID | egrep total    # get memory usage
/root/nr_setupTool_k8s.sh du   # goto CU
/root/nr_setupTool_k8s.sh du   # goto DU
cksum /opt/pw/bin/univrunode   # inside DU/CU
ps H -o 'pid tid comm' -C PROCESS  # show threads
ps H -o 'pid tid comm' -C enodeb   # show threads 4G main process
watch "ps H -o 'pid tid comm' -C enodeb" # show threads 4G main process
kg | awk '/^vnode|^phynode/ {print $1}' | xargs kubectl delete pod -n pw # or 4G restart make alias kdel global
ps aux --forest
ps --forest -eo time,ppid,pid,nlwp,args
pstree
pstree -ps
gdb -p $(pidof oammgr)
(gdb) thread apply all backtrace
ls -all /proc/$(pidof dumgr)/fd/
ls -lv /proc/$(pidof gnb_cu_son)/fd/
ls -lv /proc/$(pidof PR)/fd/   # fd file descriptors info
ww_show_file_descriptors       # fd file descriptors info with: ls -lv /proc/PID/fd/
lsof cu/nrlogs/gnb_cu_oam.log
cat /proc/$PID/stat
cat /proc/$PID/stat | awk '{print $14, $15}'
cat /proc/$(pidof gnb_cu_son)/status
FILE="du/nrlogs/gnb_du_layer2.log"
kg
cat /opt/pw-share/pods/ptpmanager/config
cat /opt/pw-config/xdbsrv/BBU-Val.xml
kd vvu
kd bbu
./nr_setupTool_k8s.sh -v
./nr_setupTool_k8s.sh ptp
cat /opt/pw-config/xdbsrv/BBU-Val.xml
./nr_setupTool_k8s.sh ptp
./nr_setupTool_k8s.sh ptp
./nr_setupTool_k8s.sh cu
tail -f /root/du/messages | egrep "min, avg, max"
egrep "RAT_5G::printCpuLoads" /root/du/messages  | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}).*(- \{.*\})/\1 \2/'
egrep "RAT_5G::printCpuLoads" /root/cu/messages  | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}).*(- \{.*\})/\1 \2/'
echo '2024-08-25T12:14:26.968965+00:00 dunode02-5c96769b4-5gfp8 UniTask[227]: [024012 INF oammgr oammgr:1 RAT.cpp:927] RAT_5G::printCpuLoads - {CPU, min, avg, max}' | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}).*(- \{.*\})/\1 \2/'
echo '2024-08-25T12:14:26.968965+00:00 dunode02-5c96769b4-5gfp8 UniTask[227]: [024012 INF oammgr oammgr:1 RAT.cpp:927] RAT_5G::printCpuLoads - {CPU, min, avg, max}' | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}).*(- \{.*\})/\1 \2/'
cp /root/univrunode /var/log/pw-share/pods/stack/cunode01/prvt/   # for oammgr
cp /root/univrunode /var/log/pw-share/pods/stack/dunode02/prvt/   # for oammgr
cp /opt/pw/nrstack/exec/gNB_CU/cfg/Thread_config_CU.xml /var/log/prvt   # in CU pod, config, xml, ini
cp /opt/pw/nrstack/exec/gNB_DU/cfg/Thread_config_DU.xml /var/log/prvt   # in DU pod, config, xml, ini
cp /opt/pw/nrstack/exec/gNB_DU/cfg/Thread_config.xsd    /var/log/prvt   # in DU pod, config, xml, ini
cp /opt/pw/nrstack/exec/gNB_DU/cfg/Thread_config*       /var/log/prvt   # in DU pod, config, xml, ini
vi /var/log/prvt/Thread_config_DU.xml   # in DU pod, config, xml, ini
vi /var/log/prvt/Thread_config.xsd      # in DU pod, config, xml, ini
cd /opt/pw/nrstack/exec/configuration/
vi /opt/pw/nrstack/exec/configuration/debugConfig.txt   # in DU/CU pod, for oammgr config
tar -czvf zipOrg.tar.gz messages gnb_du_layer2.log 
tar -xzvf zipOrg.tar.gz   # to untar
tmux attach-session -t pods_start
tmux new-session -s pods_start
cp /root/nr_stack.tar.gz_kernel_sctpE2   du/prvt/nr_stack.tar.gz
cp /root/nr_stack.tar.gz_kernel_sctpE2   cu/prvt/nr_stack.tar.gz       
cp /root/nr_stack.tar.gz_kernel_sctp_10_10_1500  /root/du/prvt/nr_stack.tar.gz
cp /root/nr_stack.tar.gz_kernel_sctp_10_10_1500  /root/cu/prvt/nr_stack.tar.gz
cd ~ && nn
vim /root/.config/.bash/.bashrc1
source /root/.config/.bash/.bashrc1
vim /etc/modprobe.d/blacklist.conf      # kernel modules
lsmod | grep sctp                       # kernel modules
vim /opt/pw-share/pods/stack/cunode01/debug-entry.sh
vim /opt/pw-share/pods/stack/dunode02/debug-entry.sh
touch /opt/pw-share/pods/stack/dunode02/.debug
touch /opt/pw-share/pods/stack/cunode01/.debug
cp nr_stack.tar.gz /var/log/pw-share/pods/stack/cunode01/prvt/      # ww_cp
cksum /root/nr_stack.tar.gz /root/cu/prvt/nr_stack.tar.gz /root/du02/prvt/nr_stack.tar.gz
rm /var/log/pw-share/pods/stack/cunode01/prvt/nr_stack.tar.gz /var/log/pw-share/pods/stack/dunode02/prvt/nr_stack.tar.gz  # remove private remove prvt
__remove_prvt_files   # remove private remove prvt rm
cksum univrunode /var/log/pw-share/pods/stack/dunode02/prvt/univrunode /var/log/pw-share/pods/stack/cunode01/prvt/univrunode
your_command > output.txt 2>&1          # Save stdout + stderr to file WITHOUT printing to console
your_command 2>&1 | tee -a output.log   # redirect both stdout and stderr to file while still printing to console
pod_str="bbu";pod_name=$(kubectl get pods -n pw | grep $pod_str | awk '{print $1}');kubectl exec -c bbu-container -it $pod_name -n pw -- /bin/bash  ▪ enter bbu pod
pod_str="ptp";pod_name=$(kubectl get pods -n pw | grep $pod_str | awk '{print $1}');kubectl exec -it $pod_name -n pw -- /bin/bash   ▪ enter ptp pod
cd /work/wshabso/kernelSCTP/nr-stack/                         ▪ ildevdocker kernel sctp
cd /work/wshabso/BBBBB/nr-stack/                              ▪ ildevdocker user sctp
time ./docker-create.sh ubuntu && time ./docker-run.sh ubuntu ▪ ildevdocker
./.help/make_compile.sh user    ▪ ildevdocker compile user sctp
./.help/make_compile.sh kernel  ▪ ildevdocker compile kernel sctp
vim .help/make_compile.sh       ▪ ildevdocker
git_clean_dfx_with_prompt                       ▪ ildevdocker
make clean && git_clean_dfx_with_prompt         ▪ ildevdocker
scp nr_stack.tar.gz root@10.166.56.104:/root/.config/nr/   ▪ ildevdocker copy to Laso
scp nr_stack.tar.gz root@10.166.74.94:/root/.config/nr/    ▪ ildevdocker copy to Trophy
scp nr_stack.tar.gz root@10.166.74.80:/root/.config/nr/    ▪ ildevdocker copy to REMOTE_vacuum
grep "Data rate" /var/log/pw-share/pods/stack/dunode02/nrlogs/gnb_du_layer2.log
grep "Data rate" /var/log/pw-share/pods/stack/dunode02/nrlogs/gnb_du_layer2.log | grep -E -v "MAC\(0...\/0...\) RLC\(0...\/0...\)"
sudo dmidecode -s system-serial-number    # get vBBU serial not python..
cd /var/log/pw-share/pods/stack/ && mv cunode01/prvt cunode01/prvtTmp && mv dunode02/prvt/ dunode02/prvtTmp/ && mv dunode03/prvt/ dunode03/prvtTmp/ && mkdir cunode01/prvt dunode02/prvt/ dunode03/prvt/
tshark -r $PCAP  -Y '!(ip.src == 127.0.0.1 || ip.dst == 127.0.0.1)' |  awk '{printf "%5s | %s | %12s | %13s:%-5s >>> %13s:%-5s |", $1, $2, $3, $4, $5, $6, $7; for(i=8;i<=NF;++i) printf " %s", $i; printf "\n"}' > $OUTPCAP
kubectl edit configmap -n pw stack-configmap-cunode01   # deploy change in deploy time
kubectl edit configmap -n pw stack-configmap-cunode01   # check E2_LOCAL_ADDRESS
ww_big_menu
ww_choose_version
ww_cksum_nrstack_prvt
ww_cp_nrstack
ww_elapsed_time_
ww_elapsed_time_4G
ww_elapsed_time_extend
ww_elapsed_time_watch_try
ww_fault
ww_get_manifest_list_from_smo_nr_dev
ww_messages
ww_nrstack
ww_prepare_bash
ww_ric_indication_show
ww_show_file_descriptors
ww_show_os_amd_arm_intel
ww_show_os_info_hardware_etc
ww_show_os_info_release_etc
ww_show_stats
ww_signal
ww_wdg_mdg_more
