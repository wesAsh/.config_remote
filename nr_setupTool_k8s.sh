 #!/usr/bin/env bash


################################################
# Place the script in /root/ on the OAM-Worker #
#----------------------------------------------
#Change log:
# 1.2: remove unnecessary printings, added version info
# 1.3: create soft link, added /var/logs/messeges to logs, add script to PATH.
# 1.4: tar logs, decode logs, fix wrong param will reboot pods.  change name of nr_stack dir in /root.
# 1.5 add ptp config, restart only if container is installed, reboot only if pod exist. fix log deletion
# 1.6 Amarisoft K1 value , added messages dir to logs, update DNS, delete only nrstack and not the whole dir when using -c, -c option will work also for nr-stack-* format
# 1.7 Add mtd pod attach, add option to prevent upload logs and cores to ACS
# 1.8 Add print of service state using -z, add parse and print ACTIVE State using -a 
# 1.9 collect PHY logs
# 1.10 Print also pw-setup version
# 1.11 Print type of installation: FOCOM or PW-SETUP and the version using different file
# 2.0 Multi cell support, Phy pod separation log collection, leaks summary file when pulling logs
# 2.1 fix decoding du02 in multi-cell setup, attach phynode fix, added phy output when printing configmap.
# 2.2 Add rrh info
# 2.3 Add log collection for profiling
# 2.4 Added function to capture FH pcap
# 2.5 -j to disable intraCU_HO flag
# 2.6 Added log collection for Faultlogs_*.csv from /var/log
# 2.7 Remove sudo from kubectl command to support AMD servers
# 2.8 Decoding support for amd+suse
# 2.9 Added option to collect x2 status
# 2.9.1 Bug fixes
# 2.10  Download and copy latest l1(gnb_app) for l1 sim to use with the srs_ue, general code improvements
# 2.11  Added option show counters sum for CU and DU using -k flag
# 2.12  Use -w flag to print all Faultlogs files of all pods
# 2.13  Automate srsue run with -m
# 2.14  Counters start/stop for CU and DU
################################################

version="2.14"

function Help()
{
	echo -e "-------------------${red}Usage:${clear}-------------------"
	echo -e "${orange}**Running without parameters will reboot CU&DU&PHY(multi cell - will reboot all du/phy pods), to reboot seperate componants use -r"
	echo -e "**To attach CU & DU or any other pod, run: nr_setupTool_k8s.sh cu/du/phy (in multi-cell setup use specific pod name i.e: du02/phy04..) "
	echo -e "**To watch the pods status run with "pods": nr_setupTool_k8s.sh pods${clear}"
	echo -e "-------------------${red}Flags: ${clear}-------------------"
	echo -e "		${green}-r : Use with pod prefix i.e {phynode04,bbu,netcon,ciph-app}, will reboot the specified pod"
	echo -e "		-c : Copying builds. optional options: {l1_artifactory, l1_local} - you will need to place nr_stack.tar.gz  in /root"
	echo -e "			l1_artifactory : Will do the same but also will download the latest l1 for srs_ue from artifactory and will copy it to phy pod "
	echo -e "			l1_local: Extract l1 sim from nr_stack.tar.gz. For this one you will need to use this rule scf.dist.l1sim in compilation"
	echo -e "		-l : Pull logs from CU/DU/PHY to /root/logs/."
	echo -e "		-d : Pull and decode logs from CU/DU/PHY to /root/logs/."
	echo -e "		-t : Same as -d and tar the logs into /root/logs-<time_stamp>.tar."
	echo -e "		-v : Pods version information."
	echo -e "		-o : Output configuration."
	echo -e "		-p : Create soft links, copy script to bin"
	echo -e "		-n : Configure ptp add run with ptp: -p ptp "
	echo -e "		-b : Amarisoft - config K1 and K2 Value"
	echo -e "		-s : Prevent upload logs and cores to ACS"
	echo -e "		-a : Validate cell service state"
	echo -e "		-z : Print cell service state"
	echo -e "		-i : Print RRHs information (S/N, iIP and intreface)"
	echo -e "		-e : Get statistics logs"
	echo -e "		-f : Get fh pcap"
	echo -e "		-j : To disable intraCU_HO flag"
	echo -e "		-g : Validate x2 State"
	echo -e "		-x : Print x2 State"
	echo -e "		-k : Print Counters sum for CU and DU usage: -k cu/du <cell-id> basic/nsa"
	echo -e "		-w : Print all Faultlogs files of all pods"
	echo -e "		-m : Run srsue - it receives the srsue ue config file name as parameter, if not supplied it will default to ue.conf."
	echo -e "				make sure the srsue&l1bp in phy pod, you can use '-c l1_artifactory' to download it from artifactory."
	echo -e "		-y : start/stop counters for CU and DU. usage: -y start/stop"
	echo -e "${clear}"
	exit
}

reboot_pod() 
{
    pod_pattern="$1"
    pod_name=$(kubectl get pods -n pw | grep "$pod_pattern" | awk '{print $1}')

    if [ -n "$pod_name" ]; then
        kubectl delete pod -n pw "$pod_name" > /dev/null 2>&1 &
        echo "Restarting pod: $pod_pattern"
    else
        echo "No pod matching '$pod_pattern' found."
    fi
}

restart_pods() {
    if [ $# -eq 0 ]; then
        echo "Restarting all CU, DU & PHY Pods. Please wait..."

		# Reboot all CU nodes
		for cunode in "${cunode_arr[@]}"; do
			reboot_pod "$cunode"
		done
		# Reboot all DU nodes
		for dunode in "${dunode_arr[@]}"; do
			reboot_pod "$dunode"
		done
		# Reboot all PHY nodes
		for phynode in "${phynode_arr[@]}"; do
			reboot_pod "$phynode"
		done
    elif [ "$1" = "cu" ]; then
        reboot_pod "cunode01"
    elif [ "$1" = "du" ]; then
		for dunode in "${dunode_arr[@]}"; do
			reboot_pod "$dunode"
		done
    elif [ "$1" = "phy" ]; then
		for phynode in "${phynode_arr[@]}"; do
			reboot_pod "$phynode"
		done
    elif [[ "$1" =~ ^(dunode01|dunode02|dunode03|dunode04|phynode02|phynode01|phynode03|phynode04|bbu|ptp|fhsrv|icc|mdt-deployment|netcon|ciph-app|rscmgr|xdbsrvr-deployment)$ ]]; then
        reboot_pod "$1"
    else
        echo "Invalid argument: $1. Valid options are 'cu', 'du', 'phy', 'bbu', 'ptp' or specific pod names like 'du02', 'du03', etc."
        exit 1
    fi
}

# $1 pod_name ,$2 command to pod, $3 pod_type
function command_to_pod()
 {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Missing arguments. Usage: command_to_pod <pod_name> <command>"
        return
    fi

    pod_str="$1"
    command="$2"
	if [ -n "$3" ]; then
		pod_type=$3
	else
		pod_type="stack"
	fi

    # Find the pod name
    pod_name=$(kubectl get pods -n pw | grep "$pod_str" | awk '{print $1}')
    
    if [ -z "$pod_name" ]; then
        echo "Error: No pod found matching substring '$pod_str' in namespace 'pw'."
        return
    fi

    # Execute the command in the pod
    kubectl exec -c $pod_type -it "$pod_name" -n pw -- /bin/bash -c "$command"
}

function get_fhas_pcap()
{
	line=$(grep -m 1 "RRH\[* " /var/log/pw-share/pods/fhsrv/fhsrv01/messages)
	number=$(echo "$line" | tr -cd "[:digit:]. ")
	rrh_id=$(echo "$number" | cut -d" " -f4) #get the rrh id
	if [ -z "$rrh_id" ]; then
		echo "we cant find the rrh id :( please write id:"
		read rrh_id 
	fi
    echo $rrh_id >/var/log/pw-share/pods/fhsrv/fhsrv01/temp.txt
    POD_NAME=$(kubectl get pods -n pw | grep fhs | awk '{print $1}')
    kubectl exec -n pw $POD_NAME -- bash -c '  
    rrh_id=$(head -n 1 /var/log/temp.txt)
    echo set tcpdump_max_len=300000 > /var/run/fhs_f800_cli/rx/c #set the max size of the pcap
    echo tcpdump $rrh_id 100000 fhpcap123 >/var/run/fhs_f800_cli/rx/c
 
    ##################################wait for capture to be done
    
    while [ ! -f "fhpcap123" ]; do 
      sleep 1
    done &&
    
    cp fhpcap123 /var/log/fhPcap.pcap #copy the pcap to the share folder
    rm fhpcap123'
	echo "path to the pcap:/var/log/fhPcap.pcap"
}

function get_logs()
{
	EXEC_DIR=/staging/nrstack/exec/
	CU_BIN=/staging/nrstack/exec/gNB_CU/bin/
	DU_BIN=/staging/nrstack/exec/gNB_DU/bin/
	LOGS=/var/log/temp_logs/
	LOGS_WORKER=/root/logs/

	CU_LOGS=/var/log/pw-share/pods/stack/cunode01/temp_logs/
	DU02_LOGS=/var/log/pw-share/pods/stack/dunode02/temp_logs/
	DU03_LOGS=/var/log/pw-share/pods/stack/dunode03/temp_logs/
	DU04_LOGS=/var/log/pw-share/pods/stack/dunode04/temp_logs/
	PHY02_LOGS=/var/log/pw-share/pods/phy/phynode02/
	PHY03_LOGS=/var/log/pw-share/pods/phy/phynode03/
	PHY04_LOGS=/var/log/pw-share/pods/phy/phynode04/

	MESSEGES="/var/log/messages*"
	FAULTLOGS="/var/log/FaultLog_*.csv"
	DU_CELL_STATS=/staging/nrstack/layer1/bin/nr5g/gnb/l1/CellStats.log

	# Extract 1st line from the file
	line=$(sed -n '1p' "/etc/os-release")
	suse=0
	if [[ $line =~ 'SLE Micro' ]]; then
        	suse=1
	fi

	echo "Collecting and copying logs to Worker"
	
	# Delete old logs
	if [ -d "${LOGS_WORKER}" ]; then
		rm -rf "${LOGS_WORKER}"
	fi
	
	# CU
	command_cu="cd /var/log ;if [ -d temp_logs ] ; then rm -rf temp_logs/*; else mkdir temp_logs; fi; mkdir $LOGS/Messages; mkdir $LOGS/Faultlogs; cp /run/nrlogs/* "$LOGS"; cp $EXEC_DIR/version.txt "$LOGS" > /dev/null 2>&1 ; cp "${CU_BIN}{gnb_cu_pdcp,bin_reader,decode_bin_files_cu.sh,gnb_cu_e2cu,gnb_cu_l3,gnb_cu_oam,gnb_cu_rrm,gnb_cu_son}" "${LOGS}" ; cp -r "${CU_BIN}../cfg/" "${LOGS}";cp "$MESSEGES" "${LOGS}Messages" > /dev/null 2>&1; cp "$FAULTLOGS" "${LOGS}Faultlogs" > /dev/null 2>&1;"

	# For AMD+suse	
	if [ $decode_logs -eq 1 ] && [ $suse -eq 1 ]; then
        	echo "Decoding CU logs"
        	command_cu+="cd "${LOGS}"; ./decode_bin_files_cu.sh > /dev/null 2>&1; rm -f *.bin;"
	fi

	command_to_pod "cunode01" "$command_cu"
	
	mkdir -p "${LOGS_WORKER}"CU
	cp -r "${CU_LOGS}"* "${LOGS_WORKER}"CU/ ;
	
	# DU + PHY
	command_du="cd /var/log ;if [ -d temp_logs ] ; then rm -rf temp_logs/*; else mkdir temp_logs; fi;mkdir $LOGS/Messages; mkdir $LOGS/Faultlogs; cp /run/nrlogs/* "$LOGS"; cp $EXEC_DIR/version.txt "$LOGS" > /dev/null 2>&1; cp "${DU_BIN}{gnb_du_layer2,dumgr,duoam,gnb_du_e2du,bin_reader,decode_bin_files_du.sh,qos_scheduler_output.py,generate_allocator_output.py}" "${LOGS}" ;cp -r "${DU_BIN}../cfg/" "${LOGS}";cp "$MESSEGES" "${LOGS}Messages";cp "$DU_CELL_STATS" "${LOGS}" > /dev/null 2>&1; cp "$FAULTLOGS" "${LOGS}Faultlogs" > /dev/null 2>&1;"
	
	# For AMD+suse	
	if [ $decode_logs -eq 1 ] && [ $suse -eq 1 ]; then
        	echo "Decoding DU logs"
        	command_du+="cd "${LOGS}"; ./decode_bin_files_du.sh > /dev/null 2>&1; rm -f *.bin;"
	fi
	
	case $cell_num in
		1)
			mkdir -p "${LOGS_WORKER}"{DU02,PHY02}
			
			command_to_pod "dunode02" "$command_du"
			cp -r "${DU02_LOGS}"* "${LOGS_WORKER}"DU02/ ;
			cp -r "${PHY02_LOGS}"* "${LOGS_WORKER}"PHY02/ > /dev/null 2>&1 ;

			;;
		2)
			mkdir -p "${LOGS_WORKER}"{DU02,DU03,PHY02,PHY03}
			
			# 02
			command_to_pod "dunode02" "$command_du"
			cp -r "${DU02_LOGS}"* "${LOGS_WORKER}"DU02/ ;
			cp -r "${PHY02_LOGS}"* "${LOGS_WORKER}"PHY02/ > /dev/null 2>&1 ;
			
			#03
			command_to_pod "dunode03" "$command_du"
			cp -r "${DU03_LOGS}"* "${LOGS_WORKER}"DU03/ ;
			cp -r "${PHY03_LOGS}"* "${LOGS_WORKER}"PHY03/ > /dev/null 2>&1 ;
			;;
		3)
			mkdir -p "${LOGS_WORKER}"{DU02,DU03,DU04,PHY02,PHY03,PHY04}
			
			#02
			command_to_pod "dunode02" "$command_du"
			cp -r "${DU02_LOGS}"* "${LOGS_WORKER}"DU02/ ;
			cp -r "${PHY02_LOGS}"* "${LOGS_WORKER}"PHY02/ > /dev/null 2>&1 ;
			
			#03
			command_to_pod "dunode03" "$command_du"
			cp -r "${DU03_LOGS}"* "${LOGS_WORKER}"DU03/ ;
			cp -r "${PHY03_LOGS}"* "${LOGS_WORKER}"PHY03/ > /dev/null 2>&1 ;
			
			#04
			command_to_pod "dunode04" "$command_du"
			cp -r "${DU04_LOGS}"* "${LOGS_WORKER}"DU04/ ;
			cp -r "${PHY04_LOGS}"* "${LOGS_WORKER}"PHY04/ > /dev/null 2>&1 ;
			;;
	esac
	
	# Put timestamp
	touch $LOGS_WORKER$date_now
	
	#Create mem leak file
	cd $LOGS_WORKER
	grep -r "LEAK D" > leaks.log 2>/dev/null
	sed -i '/Bin/d' leaks.log # Remove non relevant lines

	if [ $decode_logs -eq 1 ] && [ $suse -eq 0 ]; then
		decode_logs_func
	fi
	
	if [ $tar_logs -eq 1 ]; then
		tar_logs_func
	fi
	
	echo "Done"
}

function decode_logs_func()
{
	CU_LOGS=/root/logs/CU/
	DU02_LOGS=/root/logs/DU02/
	DU03_LOGS=/root/logs/DU03/
	DU04_LOGS=/root/logs/DU04/

	green='\033[0;32m'
	clear='\033[0m'

	echo -e "${green}Decoding logs can take some time !${clear}"
	echo "Decoding CU logs"
	cd "$CU_LOGS"
	./decode_bin_files_cu.sh > /dev/null 2>&1 ;

	# Clean 
	rm -rf *.bin

	case $cell_num in
		1)
			echo "Decoding DU02 logs"
			cd "$DU02_LOGS"
			./decode_bin_files_du.sh > /dev/null 2>&1 ;
			rm -rf *.bin
			;;
		2)
			echo "Decoding DU02 logs"
			cd "$DU02_LOGS"
			./decode_bin_files_du.sh > /dev/null 2>&1 ;
			rm -rf *.bin
			echo "Decoding DU03 logs"
			cd "$DU03_LOGS"
			./decode_bin_files_du.sh > /dev/null 2>&1 ;
			rm -rf *.bin
			;;
		3)
			echo "Decoding DU02 logs"
			cd "$DU02_LOGS"
			./decode_bin_files_du.sh > /dev/null 2>&1 ;
			rm -rf *.bin
			echo "Decoding DU03 logs"
			cd "$DU03_LOGS"
			./decode_bin_files_du.sh > /dev/null 2>&1 ;
			rm -rf *.bin
			echo "Decoding DU04 logs"
			cd "$DU04_LOGS"
			./decode_bin_files_du.sh > /dev/null 2>&1 ;
			rm -rf *.bin
			;;
	esac
	
	# Combine logs
	#find . -name "MAC_TX_CTRL_DATA_THD_REGION*.txt" -print0 | sort -z | xargs -0 cat | tee MAC_TX_CTRL_DATA_THD_REGION_COMBINED.txt >/dev/null
	#find . -name "MAC_LP_THD_REGION_*.txt" -print0 | sort -z | xargs -0 cat | tee MAC_LP_THD_REGION_COMBINED.txt >/dev/null
	#rm -rf MAC_TX_CTRL_DATA_THD_REGION_T0_*.bin.txt
	#rm -rf MAC_LP_THD_REGION_T0_*.bin.txt
	
}

function tar_logs_func()
{
	cd /root
  
	echo "Compressing logs"
	tar czvf logs-$date_now.tar.gz logs/ >/dev/null
	echo "logs-$date_now.tar.gz"
	echo "Done"
}

function get_logs_statistics()
{
	LOGS=/var/log/temp_logs/
	NRLOGS=/var/log/nrlogs/
	LOGS_WORKER=/root/statistics-logs/

	CU_LOGS=/var/log/pw-share/pods/stack/cunode01/temp_logs/
	DU02_LOGS=/var/log/pw-share/pods/stack/dunode02/temp_logs/
	DU03_LOGS=/var/log/pw-share/pods/stack/dunode03/temp_logs/
	DU04_LOGS=/var/log/pw-share/pods/stack/dunode04/temp_logs/

	MESSEGES="/var/log/messages"
	FAULTLOGS="/var/log/FaultLog_*.csv"
	
	echo "Collecting and copying Statistics logs to Worker"
	
	# Delete old logs
	if [ -d "${LOGS_WORKER}" ]; then
		rm -rf "${LOGS_WORKER}"
	fi
	
	# CU
	command_cu="cd /var/log ;if [ -d temp_logs ] ; then rm -rf temp_logs/*; else mkdir temp_logs; fi; cp "${NRLOGS}"/gnb_cu_pdcp.log "$LOGS" > /dev/null 2>&1 ; cp "$MESSEGES" "${LOGS}" > /dev/null 2>&1 ; cp \$(ls -t "${NRLOGS}"/csv_summry_counter_cu_* | head -1) "${LOGS}" > /dev/null 2>&1 ; cp \$(ls -t "${NRLOGS}"/mempool_summary_cu_* | head -1) "${LOGS}" > /dev/null 2>&1; cp "$FAULTLOGS" "${LOGS}" > /dev/null 2>&1"
	command_to_pod "cunode01" "$command_cu"
	
	mkdir -p "${LOGS_WORKER}"CU
	cp -r "${CU_LOGS}"* "${LOGS_WORKER}"CU/ ;
	
	# DU
	command_du="cd /var/log ;if [ -d temp_logs ] ; then rm -rf temp_logs/*; else mkdir temp_logs; fi; cp "${NRLOGS}"/gnb_du_layer2.log "$LOGS" > /dev/null 2>&1; cp "$MESSEGES" "${LOGS}" > /dev/null 2>&1 ; cp \$(ls -t "${NRLOGS}"/csv_summry_counter_du_* | head -1) "${LOGS}" > /dev/null 2>&1 ; cp \$(ls -t "${NRLOGS}"/mempool_summary_du_* | head -1) "${LOGS}" > /dev/null 2>&1; cp "$FAULTLOGS" "${LOGS}" > /dev/null 2>&1"
	
	case $cell_num in
		1)
			mkdir -p "${LOGS_WORKER}/DU02"
			
			command_to_pod "dunode02" "$command_du"
			cp -r "${DU02_LOGS}"* "${LOGS_WORKER}"DU02/ ;

			;;
		2)
			mkdir -p "${LOGS_WORKER}"{DU02,DU03}
			
			# 02
			command_to_pod "dunode02" "$command_du"
			cp -r "${DU02_LOGS}"* "${LOGS_WORKER}"DU02/ ;
			
			#03
			command_to_pod "dunode03" "$command_du"
			cp -r "${DU03_LOGS}"* "${LOGS_WORKER}"DU03/ ;
			;;
		3)
			mkdir -p "${LOGS_WORKER}"{DU02,DU03,DU04}
			
			#02
			command_to_pod "dunode02" "$command_du"
			cp -r "${DU02_LOGS}"* "${LOGS_WORKER}"DU02/ ;
			
			#03
			command_to_pod "dunode03" "$command_du"
			cp -r "${DU03_LOGS}"* "${LOGS_WORKER}"DU03/ ;
			
			#04
			command_to_pod "dunode04" "$command_du"
			cp -r "${DU04_LOGS}"* "${LOGS_WORKER}"DU04/ ;
			;;
	esac
	
	# Put timestamp
	touch $LOGS_WORKER$date_now
    
    for dir in "${LOGS_WORKER}"/*/; do
        tar -czvf "${dir%/}.tar.gz" -C "${LOGS_WORKER}" "$(basename "$dir")"
    done

	echo "Done"
}

function create_prvt()
{
	if [[ $1 == cunode* ||  $1 == dunode* ]]; then
		if [ ! -d "/var/log/pw-share/pods/stack/$1/prvt" ]; then
			mkdir /var/log/pw-share/pods/stack/$1/prvt/
		fi
	elif [[ $1 == phy* ]]; then
		if [ ! -d "/var/log/pw-share/pods/phy/$1/private" ]; then
			mkdir /var/log/pw-share/pods/phy/$1/private/
		fi
	fi
}

function extract_l1bp()
{
	echo "extracting l1 in phy0$2"

	cd /root/phy0$2/private
	
	if [ "$1" = "l1_artifactory" ]; then
		tar --strip-components=2 -xzvf /root/nr-stack-l1sim-ubuntu-x86*.tar.gz --wildcards '*/gnb_app' > /dev/null 2>&1
	elif [ "$1" = "l1_local" ]; then
		tar --strip-components=3 -xzvf /root/nr-stack.tar.gz --wildcards '*/gnb_app' > /dev/null 2>&1 || echo -e "${red} This build not contains the gnb_app ${clear}"
	fi
}

function download_latest_l1bp()
{
	cd /root
	source_files=$(compgen -G "nr-stack-l1sim-ubuntu-x86*.tar.gz")

	# Fetch last modifed file to check what is the latest version URL
	jsonData=$(curl -s https://pwartifactory.parallelwireless.net/artifactory/api/storage/pw-products/nr-stack/develop/?lastModified)

	# Extract the URL from the JSON response
	url=$(echo "$jsonData" | jq -r '.uri')

	# Extract the versoin number from URL
	version_ts=$(echo "$url" | grep -oP '\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-[a-f0-9]{10}' | head -n 1)
	latest_ver_tgz_name="nr-stack-l1sim-ubuntu-x86-${version_ts}.tar.gz"
	base_url="https://pwartifactory.parallelwireless.net/artifactory/pw-products/nr-stack/develop/"
	version_url="${base_url}${version_ts}/nr-stack-l1sim-ubuntu-x86-${version_ts}.tar.gz"

	if [ "$latest_ver_tgz_name" = "$source_files" ]; then
		echo "latest l1 version present: /root/$source_files"
	else
		echo "Downloading latest l1 version"

		# Delete old versions if exist
		rm -f nr-stack-l1sim-ubuntu-x86*.tar.gz
		
		wget --quiet --show-progress $version_url;
	fi
}

function download_latest_srsue()
{
	cd /root
	source_files="srsue-ubuntu.tar.gz"

	if [ -e "$source_files" ]; then
		echo "srsue tgz present: /root/$source_files"
		echo "Not downloading latest from artifactory, if you want the latest, remove the srsue-ubuntu.tar.gz from /root"

	else
		echo "Downloading latest srsue version"

		# Fetch last modifed file to check what is the latest version URL
		jsonData=$(curl -s https://pwartifactory.parallelwireless.net/artifactory/pw-products/softwareue/develop/?lastModified)

		# Extract the URL from the JSON response
		url=$(echo "$jsonData" | grep href | tail -n 1)
		# Extract the versoin number from URL
		version_ts=$(echo "$url" | sed -n 's/.*<a href="\([^/]*\)\/.*/\1/p')
		base_url="https://pwartifactory.parallelwireless.net/artifactory/pw-products/softwareue/develop/"
		version_url="${base_url}${version_ts}/packages/srsue-ubuntu.tar.gz"

		#ue_config_tdd="${base_url}${version_ts}/packages/automation/ue-5G_L1BP_K8S_DEVELOP.conf"
		#ue_config_fdd="${base_url}${version_ts}/packages/automation/ue-NETCON_L1BP_FDD_K8S_DEVELOP.conf"

		wget --quiet --show-progress $version_url;
		#wget --quiet --show-progress $ue_config_tdd;
		#wget --quiet --show-progress $ue_config_fdd;
	fi
}

function extract_srsue()
{
	cd /root/phy0$1/private
	if [ ! -d "srsue" ]; then
		mkdir srsue
	else
		rm -rf srsue/
	fi
	
	tar -xzvf /root/srsue-ubuntu.tar.gz -C srsue > /dev/null 2>&1
	cp /root/ue-5G_L1BP_K8S_DEVELOP.conf /root/phy0$1/private/srsue/ > /dev/null 2>&1
	cp /root/ue-NETCON_L1BP_FDD_K8S_DEVELOP.conf /root/phy0$1/private/srsue/ > /dev/null 2>&1
}

function download_and_extract_l1bp_and_srsue()
{
	
	if [ ! -d "/root/phy0$2" ]; then
		create_links
	fi

	create_prvt "phynode0$2";

	echo -e "${orange}********* l1bp ********* ${clear}"
	download_latest_l1bp
	extract_l1bp $1 $2

	echo -e "${orange}********* srsue ********* ${clear}"
	download_latest_srsue 
	extract_srsue $2
}

function copy() {

	#TODO - support multicell for srsue - make it in a loop instaed passing 2
	if [ "$1" = "l1_artifactory" ]; then
		download_and_extract_l1bp_and_srsue l1_artifactory 2 
		return
	elif [ "$1" = "l1_local" ]; then
		download_and_extract_l1bp_and_srsue l1_local 2
		return
	fi

    source_files=$(compgen -G "nr_stack.tar.gz")
    if [ -z "$source_files" ]; then
        echo "No version files found in /root/"
        return
    fi

    echo "Copying files to cunode01..."
    create_prvt "cunode01"
    cp nr_stack*.tar.gz /var/log/pw-share/pods/stack/cunode01/prvt/
    
    for i in $(seq 2 $((cell_num + 1))); do
        du_node="dunode0$i"
		phy_node="phynode0$i"

        echo "Copying files to $du_node..."
        create_prvt "$du_node"
        cp /root/nr_stack*.tar.gz /var/log/pw-share/pods/stack/$du_node/prvt/
    done

	echo "Done copying files"
}

function print_header_for_configuration() {
	local header=$1
	echo -e "${green}######################################## ${clear}"
	echo -e "${green}################ $header ############### ${clear}"
	echo -e "${green}######################################## ${clear}"
}

function configuration_output() {

    # Print CU configuration
    print_header_for_configuration "CU"
    kubectl describe configmap stack-configmap-cunode01 -n pw

    # Print DU and PHY configurations dynamically based on cell_num
    for i in $(seq 2 $((cell_num + 1))); do
        print_header_for_configuration "DU0$i"
        kubectl describe configmap stack-configmap-dunode0$i -n pw

        print_header_for_configuration "PHY0$i"
        kubectl describe configmap phy-configmap-phynode0$i -n pw
    done
}

# Helper function to fetch version info
function fetch_version_info() {
    local pod_type=$1
    local pod_name=$2
    local pod_version="Not installed"
    local stack_version="Not installed"

    # Get pod name
    local pod=$(kubectl get pods -n pw | grep "$pod_name" | awk '{print $1}') > /dev/null 2>&1
    if [ -n "$pod" ]; then
        # Get pod version
        pod_version=$(kubectl describe pod -n pw "$pod" | grep Image | head -n 1 | cut -d ":" -f 4) > /dev/null 2>&1
        # Get stack version
        stack_version=$(kubectl exec -c stack -it "$pod" -n pw -- /bin/bash -c "if [ -f /staging/nrstack/exec/version.txt ]; then cat /staging/nrstack/exec/version.txt; fi") > /dev/null 2>&1
    fi

    # Print version information
    echo -e "${red}*************************** $pod_type ***************************${clear}"
    echo -e "${red}--------------------------------------------------------------${clear}"
    echo -e "${green}POD Version:${clear} ${orange}$pod_version${clear}"
    echo -e "${green}Stack Version:${clear}"
    echo -e "${orange}$stack_version${clear}"
}

function print_cu_version_info() {
    fetch_version_info "CU" "cu"
}

function print_du_version_info() {
    fetch_version_info "DU" "$1"
}

function version_info()
{
	# Extract 3rd line from the file
	line=$(sed -n '3p' "/usr/local/bin/pw-worker.sh")
	# Check if "FOCOM" exists and set the prefix accordingly
	if [[ $line =~ FOCOM ]]; then
        prefix="FOCOM "
    else
        prefix="PW-SETUP "
	fi
	# Extract version number from the end of the line
	pw_worker_version=$(echo "$line" | awk '{print $NF}')


	echo -e "${red}*****************************INFO***************************** ${clear}"
	echo -e "${green}${prefix}Version ${clear}: ${orange}$pw_worker_version${clear}"
	echo -e "${green}Script Version ${clear}: ${orange}$version${clear}"
	
	print_cu_version_info
	
	case $cell_num in
		1|2|3)
			for i in $(seq 2 $((cell_num + 1))); do
				print_du_version_info "dunode0$i"
			done
			;;
	esac
}

function create_links() {
    echo -e "Creating links to CU/DU/PHY in /root/"

    # Base directories
    cu_dir="/var/log/pw-share/pods/stack/cunode01/"
    du_base_dir="/var/log/pw-share/pods/stack/dunode"
    phy_base_dir="/var/log/pw-share/pods/phy/phynode"

    # Create CU link
    ln -sf "$cu_dir" /root/cu > /dev/null 2>&1

    # Create DU and PHY links based on the cell number
    for i in $(seq 2 $((cell_num + 1))); do
        ln -sf "${du_base_dir}0$i/" "/root/du0$i" > /dev/null 2>&1
        ln -sf "${phy_base_dir}0$i/" "/root/phy0$i" > /dev/null 2>&1
    done
}

function copy_script_to_bin()
{
	echo "Copying nr_setupTool_k8s.sh to /usr/local/bin"
	cp /root/nr_setupTool_k8s.sh /usr/local/bin > /dev/null 2>&1
}

function ptp()
{
	if [ -f /opt/pw-share/pods/ptpmanager/config ]; then
	
		# Check if we have master already installed
		ptp_master_config=$(awk '/\[master]/, EOF {print $0}' /opt/pw-share/pods/ptpmanager/config)
		
		if [ -z "$ptp_master_config" ]; then
			fh_port=$(cat /opt/pw-share/pods/ptpmanager/config | grep port | cut -d "=" -f 2)
			if [ -n "$fh_port" ]; then 
				if [ $(echo "${fh_port: -1}") -eq 0 ]; then
					ptp_port=${fh_port::-1}"3"
				elif [ $(echo "${fh_port: -1}") -eq 3 ]; then
					ptp_port=${fh_port::-1}"0"
				fi
			else
				echo "There is no slave configured.."
				return
			fi
		else
			echo "PTP master already configured"
			return
		fi

		# Add ptp master section
		echo  >>  /opt/pw-share/pods/ptpmanager/config
		echo "[master]" >>  /opt/pw-share/pods/ptpmanager/config
		echo "state=ena" >>  /opt/pw-share/pods/ptpmanager/config
		echo "port=$ptp_port" >>  /opt/pw-share/pods/ptpmanager/config
		echo "hardwareSync=ena" >>  /opt/pw-share/pods/ptpmanager/config
		echo "affinity=46" >>  /opt/pw-share/pods/ptpmanager/config
		echo  >>  /opt/pw-share/pods/ptpmanager/config
		
		# Restart the pod if needed
		pod_str="ptpmgr";pod_name=$(kubectl get pods -n pw | grep $pod_str | awk '{print $1}')
		if [ ! -z "$pod_str" ]; then
			pod_str="ptpmgr";pod_name=$(kubectl get pods -n pw | grep $pod_str | awk '{print $1}'); kubectl delete pod -n pw $pod_name 2>&1 ; > /dev/null 2>&1 &
		fi
		echo "PTP master configured"
	else
		echo "No PTP config file.."
	fi
}

function disable_intraCU_HO()
{
	# Check if CU exist
	cu_pod_name=$(kubectl get pods -n pw | grep cunode01 | awk '{print $1}') > /dev/null 2>&1
	if [ -n "$cu_pod_name" ]; then
		if [ ! -d "/var/log/pw-share/pods/stack/cunode01/prvt" ]; then
			mkdir /var/log/pw-share/pods/stack/cunode01/prvt > /dev/null 2>&1
		fi

		# intraCU_HO - Proprietary_gNodeB_CU_Data_Model
		command_cu='cp /staging/nrstack/exec/gNB_CU/cfg/cu_rrm_cfg.xml /var/log/prvt/ ; sed -i "s/<enable_intraCU_HO>1<\/enable_intraCU_HO>/<enable_intraCU_HO>0<\/enable_intraCU_HO>/g"  /var/log/prvt/cu_rrm_cfg.xml;> /dev/null 2>&1'
		command_to_pod $cu_pod_name "$command_cu"
	fi
}

function amarisoft_k1k2()
{
	# Check if DU exist
	du_pod_name=$(kubectl get pods -n pw | grep $1 | awk '{print $1}') > /dev/null 2>&1
	if [ -n "$du_pod_name" ]; then
	
		if [ ! -d "/var/log/pw-share/pods/stack/$1/prvt" ]; then
			mkdir /var/log/pw-share/pods/stack/$1/prvt > /dev/null 2>&1
		fi

		# K1Value - Proprietary_gNodeB_DU_Data_Model
		command_du='cp /staging/nrstack/exec/gNB_DU/cfg/Proprietary_gNodeB_DU_Data_Model_default.xml /var/log/prvt/ ; sed -i "s/<K1Value>0<\/K1Value>/<K1Value>4<\/K1Value>/g"  /var/log/prvt/Proprietary_gNodeB_DU_Data_Model_default.xml;> /dev/null 2>&1'
		command_to_pod $du_pod_name "$command_du"
		# K2Min - TR196_gNodeB_DU_Data_Model
		command_du='cp /staging/nrstack/exec/gNB_DU/cfg/TR196_gNodeB_DU_Data_Model_default.xml /var/log/prvt/ ; sed -i "s/<K2Min>2<\/K2Min>/<K2Min>4<\/K2Min>/g" /var/log/prvt/TR196_gNodeB_DU_Data_Model_default.xml;> /dev/null 2>&1'
		command_to_pod $du_pod_name "$command_du"

		echo "$1 Done"
	else
		echo "Yo! No DU pod deployed.."
	fi
}

function amarisoft_values_update()
{
	echo "Updating K1/K2 values.."

	for dunode in "${dunode_arr[@]}"; do
		amarisoft_k1k2 "$dunode"
	done
}

function prevent_upload_logs_and_core()
{
        # Check if mdt exist
        mdt_pod_name=$(kubectl get pods -n pw | grep mdt | awk '{print $1}') > /dev/null 2>&1
        if [ -n "$mdt_pod_name" ]; then
                command_mdt='touch /opt/pw/didir/di-files/uploadstop'
				command_to_pod $mdt_pod_name $command_mdt "mdt"
                echo "Done"
        else
                echo "Yo! No MDT pod deployed.."
        fi
}

function validate_cell_state()
{
	#Before running the gnb_cu_oamCli , I want to verify if gnb_cu_l3 process is running on cu, if not - there is no need to run gnb_cu_oamCli as it cause the setup to stop
	cell_state_initial_check=$(ps -ef | grep gnb_cu_l3 | awk '{print $8}' | grep cu)
	if [ "$cell_state_initial_check" != "./gnb_cu_l3" ]; then	
		echo "INACTIVE"
		$(pkill gnb_cu_oamCli)
		echo "gnb_cu_l3 is not running yet, hence won't run gnb_cu_oamCli" > /var/log/pw-share/pods/stack/cunode01/nrlogs/service_state.log
		return 1
	fi
	
	#Probably all cu processes are running now we can run gnb_cu_oamCli
	cell_state_full=$(kubectl exec --quiet -it $(kubectl get pods -n pw | grep cu | awk '{print $1}') -n pw -- /bin/bash -c 'cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./gnb_cu_oamCli 1 show CellStatus' ) > /dev/null 2>&1
	echo "Full service state output is:" > /var/log/pw-share/pods/stack/cunode01/nrlogs/service_state.log
	echo "$cell_state_full" >> /var/log/pw-share/pods/stack/cunode01/nrlogs/service_state.log
	du_pod_num=$(kubectl get pods -n pw | grep dunode | wc -l)
	cells_state=$(kubectl exec --quiet -it $(kubectl get pods -n pw | grep cu | awk '{print $1}') -n pw -- /bin/bash -c 'cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./gnb_cu_oamCli 1 show CellStatus' | head -n -1 | tail -n $du_pod_num ) > /dev/null 2>&1
 	while IFS= read -r line || [[ -n "$line" ]]; do
		cell_state=$(echo "$line" | awk '{print $7}')
		operational_state=$(echo "$line" | awk '{print $8}')
		if [ "$cell_state" != "ACTIVE" ] || [ "$operational_state" != "True" ]; then
			echo "INACTIVE"
			return 1
		fi
	done <<< "$cells_state"
	echo "ACTIVE"
}

function print_cell_state()
{
	kubectl exec --quiet -it $(kubectl get pods -n pw | grep cu | awk '{print $1}') -n pw -- /bin/bash -c 'cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./gnb_cu_oamCli 1 show CellStatus' > /var/log/pw-share/pods/stack/cunode01/nrlogs/CellStatus
	cat /var/log/pw-share/pods/stack/cunode01/nrlogs/CellStatus
}

function validate_x2_state()
{
	command_output="enb peer id ="  
	#Before running the runCuCli , I want to verify if gnb_cu_l3 process is running on cu, if not - there is no need to run runCuCli as it cause the setup to stop
	cell_state_initial_check=$(ps -ef | grep gnb_cu_l3 | awk '{print $8}' | grep cu)
	if [ "$cell_state_initial_check" != "./gnb_cu_l3" ]; then	
		echo "INACTIVE"
		$(pkill runCuCli)
		echo "gnb_cu_l3 is not running yet, hence won't run runCuCli" > /var/log/pw-share/pods/stack/cunode01/nrlogs/x2_state.log
		return 1
	fi
	
	# Run runCuCli and store the output in x2_state_full
    x2_state_full=$(sudo kubectl exec --quiet -it $(kubectl get pods -n pw | grep cu | awk '{print $1}') -n pw -- /bin/bash -c 'cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./runCuCli.sh Show NSA ListENBs' 2>/dev/null)
    
    # Log the full output of x2_state_full
    echo "Full X2 state output is:" > /var/log/pw-share/pods/stack/cunode01/nrlogs/x2_state.log
    echo "$x2_state_full" >> /var/log/pw-share/pods/stack/cunode01/nrlogs/x2_state.log
    
    # Check if "enb peer id =" is present in x2_state_full
    if echo "$x2_state_full" | grep -iq "$command_output"; then
        echo "ACTIVE"
    else
        echo "INACTIVE"
    fi
}

function print_x2_state()
{
	kubectl exec --quiet -it $(kubectl get pods -n pw | grep cu | awk '{print $1}') -n pw -- /bin/bash -c 'cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./runCuCli.sh Show NSA ListENBs' > /var/log/pw-share/pods/stack/cunode01/nrlogs/X2Status
	cat /var/log/pw-share/pods/stack/cunode01/nrlogs/X2Status
}

function pod_attach()
{
    local pod_str=$1  # Pod string to search for
    local container=$2  # Container name,
    local shell="/bin/bash" # Shell

    # Find the pod name matching the given string
    local pod_name=$(kubectl get pods -n pw | grep "$pod_str" | awk '{print $1}')

    if [[ -z $pod_name ]]; then
        echo "No pod found matching '$pod_str'"
        return 1
    fi

    kubectl exec -c "$container" -it "$pod_name" -n pw -- "$shell"
}

function get_counters_summary()
{
	local pod_str=$1
	if [ -z "$1" ]; then
		echo "Error: Missing pod argument."
		exit 1
	fi
	if [ -z "$2" ]; then
		echo "Error: Missing cell id argument."
		exit 1
	fi
	if [ -z "$3" ]; then
		echo "Error: Missing type argument."
		exit 1
	fi
	local cell_id=$2
	local type=$3
	local pod_name=$(kubectl get pods -n pw | grep "$pod_str" | awk '{print $1}')
	if [ -z "$pod_name" ]; then
		echo "No pod found matching '$pod_str'"
		return
	fi
	cell_id=$(printf "%05d" $cell_id)
	# get today's csv file of a given cell
	local found_csv=$(kubectl exec -c stack -it "$pod_name" -n pw -- find /var/log/nrlogs/ -name csv_summry_counter*"$cell_id"*.csv -newermt "$(date +%Y-%m-%d)" | sort -r)
	cell_csv=$(echo "$found_csv" | tail -n 1 | tr -d '\r')
	if [ -z "$cell_csv" ]; then
		echo "No CSV file found for cell ID $cell_id in pod $pod_str today."
		return
	fi
	if [[ "$pod_str" == *"du"* ]]; then
		pod_arg="du"
	else
		pod_arg="cu"
	fi
	kubectl exec -c stack -it "$pod_name" -n pw -- python3 /opt/pw/nrstack/exec/scripts/counters_sum.py -r "$pod_arg" -t "$type" "$cell_csv";
}

get_fault_logs(){
	pods=$(cd /var/log/pw-share/pods/stack/; find -mindepth 1 -maxdepth 1 -type d | sort)
	for pod in $pods; do
		echo -e "\033[0;34mPod: $(basename "$pod")\033[0m"
		log_files=$(find /var/log/pw-share/pods/stack/"$pod" -mindepth 1 -maxdepth 1 -name "FaultLog*.csv" -type f -exec ls -tr {} + )
		for log_file in $log_files; do
			echo -e "\033[0;33mLog file: $log_file\033[0m"
			cat $log_file
		done
	done

}
get_test_counters()
{

	local pod_str="cu"
	local command="$1"
	local set_counters_60000="cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./gnb_cu_oamCli 1 Counters Interval 6000"
	local set_counters_900="cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./gnb_cu_oamCli 1 Counters Interval 900"
	local counters_fetch="cd /staging/nrstack/exec/gNB_CU/bin/;export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./../lib:../lib:/usr/lib:../../gNB_CU/lib:../lib;./gnb_cu_oamCli 1 Counters Fetch"
	local du_set_counters_60000="cd /staging/nrstack/exec/gNB_DU/bin; ./execute_cli.sh 1 Counters Interval 60000"
	local du_set_counters_fetch="cd /staging/nrstack/exec/gNB_DU/bin; ./execute_cli.sh 1 Counters Fetch"
	local pod_name=$(kubectl get pods -n pw | grep "$pod_str" | awk '{print $1}')
	if [ -z "$pod_name" ]; then
		echo "No pod found matching '$pod_str'"
		return
	fi
	if [[ "$command" == *"start"* ]]; then
		echo "Starting counters"
		kubectl exec -c stack -it "$pod_name" -n pw -- /bin/bash -c "$set_counters_60000"
		kubectl exec -c stack -it "$pod_name" -n pw -- /bin/bash -c "$counters_fetch"
		local pod_str="du"
		local pod_names=$(kubectl get pods -n pw | grep "$pod_str" | awk '{print $1}')
		if [ -z "$pod_names" ]; then
			echo "No pod found matching '$pod_str'"
			return
		fi
		for du in $pod_names; do
			kubectl exec -c stack -it "$du" -n pw -- /bin/bash -c "$du_set_counters_60000"
			kubectl exec -c stack -it "$du" -n pw -- /bin/bash -c "$du_set_counters_fetch"
		done
	else
		echo "Stopping counters"
		kubectl exec -c stack -it "$pod_name" -n pw -- /bin/bash -c "$counters_fetch"
		kubectl exec -c stack -it "$pod_name" -n pw -- /bin/bash -c "$set_counters_900"
		local pod_str="du"
		local pod_names=$(kubectl get pods -n pw | grep "$pod_str" | awk '{print $1}')
		if [ -z "$pod_names" ]; then
			echo "No pod found matching '$pod_str'"
			return
		fi
		for du in $pod_names; do
			kubectl exec -c stack -it "$du" -n pw -- /bin/bash -c "$du_set_counters_fetch"
			kubectl exec -c stack -it "$du" -n pw -- /bin/bash -c "$du_set_counters_60000"
		done
	fi
	
}

extract_rrh_info() {

    # Print table header
    printf "${green}%-25s %-15s %-10s${clear}\n" "SerialNum" "MngIpAddr" "FhEthIface"
    printf "${green}%-25s %-15s %-10s${clear}\n" "---------" "---------" "----------"

    # Use awk to extract the relevant fields and format as table
    awk '
    /<Param ID="RRHs">/,/<\/Param>/ {
        if ($0 ~ /<Field ID="SerialNum"/) {
            match($0, /Val="([^"]*)"/, arr)
            serial_num = arr[1]
        }
        if ($0 ~ /<Field ID="MngIpAddr"/) {
            match($0, /Val="([^"]*)"/, arr)
            mng_ip_addr = arr[1]
        }
        if ($0 ~ /<Field ID="FhEthIface"/) {
            match($0, /Val="([^"]*)"/, arr)
            fh_eth_iface = arr[1]
        }
        if (serial_num && mng_ip_addr && fh_eth_iface) {
            # Print the collected values in table format
            printf "%-25s %-15s %-10s\n", serial_num, mng_ip_addr, fh_eth_iface
            # Reset variables for the next entry
            serial_num = ""
            mng_ip_addr = ""
            fh_eth_iface = ""
        }
    }
    ' "/opt/pw-config/xdbsrv/BBU-Val.xml"
}

function install_packeges_for_iperf_on_phynode()
{

	if dpkg -l | grep -qw "sshpass"; then 
		echo "sshpass is already installed.."
	else 
		echo "sshpass is not installed, installing now.."
		apt update 
		apt install -y sshpass
	fi

    phy_command='if dpkg -l | grep -qw "iperf3"; then \
                    echo "iperf3 is already installed.."; \
                 else \
                    echo "iperf3 is not installed, installing now.."; \
                    mkdir -p /var/cache/apt/archives/partial; \
                    chmod 755 /var/cache/apt/archives/partial; \
                    chown -R root:root /var/cache/apt/archives; \
                    apt clean; apt update; apt install -y -f iperf3; \
                 fi'
    
    command_to_pod "phynode02" "$phy_command" "phy"
}

function pre_run_sim()
{
	ue_conf_file_name=$1
	iperf_ip_file_name=$2
	cell_state=$(validate_cell_state)

	# If there is no phy private dir - nothing todo
	if [[ ! -d "/root/phy02/private" ]]; then
		echo "No phy private dir - use "-c l1_artifactory" to download srsue from articatory"
		return 1
	fi
	
	create_prvt "dunode02"
	cd /root/du02/prvt/

	# integ_config file - not overiding if exists
	if [ ! -f "integ_config.ini" ]; then
		echo -e "file:Proprietary_gNodeB_DU_Data_Model.xml\n.//systemParam/UeDataInactivityTimer=0" > integ_config.ini
	fi

	cd /root/phy02/private/
	if [[ ! -d "srsue" ]]; then
		echo "No srsue dir in private dir"
		return 1
	fi
	
	# Verify Cell state
	if [ "$cell_state" == "ACTIVE" ]; then
		echo "The cell is active, continue.."
	else
		echo "The cell is inactive, exiting.."
		return 1
	fi

	rm -f srsue/$srsue_logfile
	pkill srsue
	
	# UE Config file
	if [ ! -f "srsue/$ue_conf_file_name" ]; then
		echo "ERROR: No ue config file [$ue_conf_file_name] in private/srsue/ dir"
		return 1
	fi

	# Iperf IP address
	if [ ! -f "$iperf_ip_file_name" ]; then
		read -p "Enter the SSH IP address of the iperf server: " iperf_ssh_ip
		echo "$iperf_ssh_ip" > $iperf_ip_file_name

		read -p "Enter the IP address of the iperf content server data plane:" iperf_content_ip
		echo "$iperf_content_ip" >> $iperf_ip_file_name

		echo "IP addresses saved in $iperf_ip_file_name"
	fi

	# UE Config file - The file name can be default[ue.conf] or user input
	if [ ! -f "srsue/$ue_conf_file_name" ]; then
		echo "ERROR: No config file [$ue_conf_file_name], place your srsue conf file in srsue dir"
		return 1
	fi

	# Make sure l1bp in private dir
	gnb_app_path=$(find . -type f -name "$file_to_check" 2>/dev/null)
	if [[ -n "$gnb_app_path" ]]; then
		echo "ERROR: private gnb_app not present"
		return 1
	fi
	
	install_packeges_for_iperf_on_phynode

	return 0
}

function run_sim()
{
	iperf_ip_file_name="srsue/iperf_ip.conf" # Line1[ssh_ip], Line2[data_ip] 
	srsue_logfile="srsue.log"
	ue_conf_file_name="$1"

	pre_run_sim $ue_conf_file_name $iperf_ip_file_name
	if [[ $? -ne 0 ]]; then
		exit
	fi

	# iperf server details
	REMOTE_USER="root"
	REMOTE_HOST=$(head -n 1 "$iperf_ip_file_name")
	REMOTE_PASSWORD="password"
	REMOTE_IPERF_PORT="6999"

	echo "Starting simulator run.."
	
	cd /root/phy02/private/srsue/

	echo "Starting srsue.."
	command_to_pod "phynode02" "cd /var/log/private/srsue/; ./srsue $ue_conf_file_name > $srsue_logfile 2>&1" "phy" &
	# Time for the UEs to attach
	sleep 7

	# Fetch UE IPs from srsue log
	grep "PDU Session Establishment successful. IP" srsue.log > ips.txt
	sleep 0.5

	# Store all IPs in srsue_ips array
	srsue_ips=()
	i=1
	while IFS= read -r line; do
		srsue_ips+=$(echo "$line" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
		echo "UE [$i] IPs: "${srsue_ips[i-1]}""
		i+=1
	done < "ips.txt"

	echo "Starting UE iperf.."
	command_to_pod "phynode02" "ip netns exec ue1 iperf3 -s -p 6999 > /dev/null 2>&1 &" "phy" 
	
	echo "Starting remote iperf.."
	# For multiple UEs we will need to prompt to user how many UEs to run and store it in a file, here we will need to create a loop to run 
	# multiple iperf instances and not forget to kill them.
	REMOTE_PID=$(sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" "
				iperf3 -u -t 30 -B 192.168.203.61 -p 6999 -l 1200 -b 1100M -c "${srsue_ips[0]}" > /dev/null 2>&1  &
				echo \$!
			")
	echo "Remote iperd pid: $REMOTE_PID "	
	echo "test is running, sleeping for 30 sec.."
	sleep 31 # to remove

	sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" "
			kill -9 $REMOTE_PID"
}

# For printing
green='\033[0;32m'
orange='\033[0;33m'
red='\033[1;31m'
clear='\033[0m'

# Globals
tar_logs=0
decode_logs=0
date_now=$(date "+%F-%H%M")
cunode_arr=()
dunode_arr=()
phynode_arr=()

du_pod_num=$(kubectl get pods -n pw | grep dunode | wc -l)
du_pod_uniq_num=$(kubectl get pods -n pw | grep dunode | awk '{print $1}' | cut -d "-" -f 1 | uniq | wc -l)

phy_pod_num=$(kubectl get pods -n pw | grep phynode | wc -l)
phy_pod_uniq_num=$(kubectl get pods -n pw | grep phynode | awk '{print $1}' | cut -d "-" -f 1 | uniq | wc -l)
cell_num=$du_pod_num

# Get the list of pods - for future enhancments
pods=$(kubectl get pods -n pw | awk '{print $1}' | grep -E 'cunode|dunode|phynode')

# Loop through the pods and populate arrays
for pod in $pods; do
	if [[ $pod == cunode* ]]; then
		cunode_arr+=("$(echo $pod | grep -o '^cunode[0-9]*')")
	elif [[ $pod == dunode* ]]; then
		dunode_arr+=("$(echo $pod | grep -o '^dunode[0-9]*')")
	elif [[ $pod == phynode* ]]; then
		phynode_arr+=("$(echo $pod | grep -o '^phynode[0-9]*')")
	fi
done

if [ ! $# -eq 0 ]; then
    if [ "$1" = "bbu" ]; then
        pod_attach bbu bbu-container
        exit
    elif [ "$1" = "cu" ]; then
        pod_attach cunode01 stack
        exit
    elif [ "$1" = "du" ] || [ "$1" = "dunode" ]; then
        pod_attach dunode02 stack
        exit
    elif [ "$1" = "du01" ] || [ "$1" = "dunode01" ]; then
        pod_attach dunode01 stack
        exit
    elif [ "$1" = "du02" ] || [ "$1" = "dunode02" ]; then
        pod_attach dunode02 stack
        exit
    elif [ "$1" = "du03" ] || [ "$1" = "dunode03" ]; then
        pod_attach dunode03 stack
        exit
    elif [ "$1" = "du04" ] || [ "$1" = "dunode04" ]; then
        pod_attach dunode04 stack
        exit
    elif [ "$1" = "phy" ] || [ "$1" = "phynode" ]; then
        pod_attach phynode02 phy
        exit
    elif [ "$1" = "phy01" ] || [ "$1" = "phynode01" ]; then
        pod_attach phynode02 phy
        exit
    elif [ "$1" = "phy02" ] || [ "$1" = "phynode02" ]; then
        pod_attach phynode02 phy
        exit
    elif [ "$1" = "phy03" ] || [ "$1" = "phynode03" ]; then
        pod_attach phynode03 phy
        exit
    elif [ "$1" = "phy04" ] || [ "$1" = "phynode04" ]; then
        pod_attach phynode04 phy
        exit
    elif [ "$1" = "mdt" ]; then
        pod_attach mdt mdt
        exit
    elif [ "$1" = "ptp" ]; then
        tail -f /var/log/pw-share/pods/ptpmgr/messages
        exit
    elif [ "$1" = "pods" ]; then
        watch kubectl get pods -n pw
        exit
    fi
else
    read -p "restart_pods? [yn]" keys
    case "$keys" in
        [Yy]* )
            restart_pods
            ;;
        * )
            echo "skipping..."
    esac
    exit
fi

# Continue only when all pods are up
if ! [ $du_pod_uniq_num -eq $phy_pod_uniq_num ] ||  ! [ $phy_pod_num -eq $phy_pod_uniq_num ] || ! [ $du_pod_num -eq $du_pod_uniq_num ] ; then
	echo "Check your pods status:"
	kubectl get pods -n pw
	exit
fi

while getopts ":hc:dtlvr:opnbsafziejgxk:wm:y" option; do
  case $option in
    h)
		Help
		exit
		;;
	m)
		run_sim "${OPTARG}"
		exit
		;;		
    c)
		copy "${OPTARG}"
		exit
		;;
	d)
		decode_logs=1
		get_logs
		exit
		;;
	t)
		decode_logs=1
		tar_logs=1
		get_logs
		exit
		;;
	r)
		restart_pods "${OPTARG}"
		exit
		;;
	l)
		get_logs
		exit
		;;
	v)
		version_info
		exit
		;;
	o)
		configuration_output
		exit
		;;
	p)
		create_links
		copy_script_to_bin
		#set_dns
		echo "Done"
		exit
		;;
	n)
		ptp
		exit
		;;
	b)
		amarisoft_values_update
		exit
		;;
	s)
		prevent_upload_logs_and_core
		exit
		;;
	a)
		validate_cell_state
		exit
		;;
	f)
		get_fhas_pcap
		exit
		;;
	z)
		print_cell_state
		exit
		;;
	i)
		extract_rrh_info
		exit
		;;
	e)
		get_logs_statistics
		exit
		;;
	j)
		disable_intraCU_HO
		exit
		;;
	g)
		validate_x2_state
		exit
		;;
	x)
		print_x2_state
		exit
		;;
	k)
		shift
		arg1=$1
		arg2=$2
		arg3=$3
		if [[ -z "$arg1" || -z "$arg2" || -z "$arg3" ]]; then
			echo "Error: -k option requires three arguments."
			exit 1
		fi
		get_counters_summary "$arg1" "$arg2" "$arg3"
		exit
		;;
	w)
		get_fault_logs
		exit
		;;
	y)
		arg1=$2
		if [[ -z "$arg1"  ]]; then
			echo "Error: -y option requires one argument."
			exit 1
		fi
		get_test_counters "$arg1"
		exit
		;;
    \:)
		#In case we use -c with no options
		if [[ "$OPTARG" == "c" ]]; then
            # Set default value for -c when no argument is provided
            OPTARG="stack"
            copy "${OPTARG}"
		elif [[ "$OPTARG" == "m" ]]; then
			# Set default value for -m when no argument is provided
            OPTARG="ue.conf"
			run_sim "${OPTARG}"
		else 
			Help
        fi
        exit
        ;;
    \?) # Invalid option
		Help
		exit
		;;
esac
done

Help
