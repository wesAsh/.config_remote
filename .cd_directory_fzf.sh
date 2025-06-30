cd ~/.config/.bash/
cd /var/log/pw-share/pods/stack/
cd /var/log/pw-share/pods/stack/cunode01/         # from oam to cu shared
cd /var/log/pw-share/pods/stack/cunode01/nrlogs/  # from oam to cu shared
cd /var/log/pw-share/pods/stack/cunode01/prvt/    # from oam to cu shared
cd /var/log/pw-share/pods/stack/dunode02/         # from oam to du shared
cd /var/log/pw-share/pods/stack/dunode02/nrlogs/  # from oam to du shared
cd /var/log/pw-share/pods/stack/dunode02/prvt/    # from oam to du shared
echo "DUCU" && cd /var/log/
echo "DUCU" && cd /var/log/nrlogs/
echo "DUCU" && cd /var/log/prvt/
echo "DU" && cd /opt/pw/nrstack/exec/gNB_DU/cfg/  # Thread_config_DU.xml Proprietary_gNodeB_DU_Data_Model.xml etc
echo "DU" && cd /opt/pw/nrstack/exec/gNB_DU/bin   # executables
cd /opt/pw-share/pods/stack/cunode01/   # empty?
cd /opt/pw-share/pods/stack/dunode02/   # empty?
cd /staging/crashes/      # pod core crashes
PROCESS='gnb_cu_oam'    && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_cu_pdcp'   && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_cu_son'    && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_cu_rrm'    && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_cu_l3'     && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_cu_e2cu'   && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='duoam'         && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='dumgr'         && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_du_e2du'   && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_du_layer2' && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='phymgr'        && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='gnb_app'       && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
PROCESS='oammgr'        && if pidof $PROCESS; then lfrc_r31_linux /proc/$(pidof $PROCESS); fi
cd /opt/pw/nrstack/exec/gNB_DU/bin/   # DU pod: duoam      | dumgr     | gnb_du_e2du | gnb_du_layer2
cd /opt/pw/nrstack/exec/gNB_CU/bin/   # CU pod: gnb_cu_oam | gnb_cu_l3 | gnb_cu_e2cu | gnb_cu_pdcp   | gnb_cu_rrm | gnb_cu_son
cd /opt/pw/nrstack/exec/gNB_DU/cfg/     # DU pod: Thread_config_DU.xml, Thread_config.xsd
cd /opt/pw/nrstack/exec/gNB_CU/cfg/     # CU pod: Thread_config_CU.xml, Thread_config.xsd
