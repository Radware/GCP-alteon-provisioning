{
  "UserCredentials": {
    "name": "${admin_user}",
    "password": "${admin_password}",
    "cos": "admin"
  },
  %{ if gel_enabled }
  "GEL": {
    "status": "ena",
    "primaryURL": "${gel_url_primary}",
    %{ if cc_remote_ip != "0.0.0.0" }
    "secondaryURL": "${gel_url_secondary}",
    %{ endif }
    "devicename": "${vm_name}",
    "interval": "300",
    "retryInt": "60",
    "retries": "3",
    "entID": "${gel_ent_id}",
    "throughput": "${gel_throughput_mb}",
    "addon": "2",
    "dnspri": "${gel_dns_pri}"
  },
  %{ endif }
  "RawConfig": {
    "Config": "",
    "ConfigArray": [
      "/c/sys/access/snmp w",
      "/cfg/sys/ntp/on/prisrv ${ntp_primary_server}/tzone ${ntp_tzone}",
      "/c/sys/ssnmp/auth ena",
      "/c/sys/ssnmp/snmpv3/taddr 1/name v1v2trap1/addr ${cc_local_ip}/taglist v1v2param1/pname v1v2param1",
      "/c/sys/ssnmp/snmpv3/tparam 1/name v1v2param1/mpmodel snmpv1/uname v1v2only/model snmpv1",
      "/c/sys/ssnmp/snmpv3/notify 1/name v1v2Trap1/tag v1v2param1",
      "/c/sys/ssnmp/snmpv3/comm 1/index trapComm1/name public/uname v1v2only",
      %{ if cc_remote_ip != "0.0.0.0" }
      "/c/sys/ssnmp/snmpv3/taddr 2/name v1v2trap2/addr ${cc_remote_ip}/taglist v1v2param2/pname v1v2param2",
      "/c/sys/ssnmp/snmpv3/tparam 2/name v1v2param2/mpmodel snmpv1/uname v1v2only/model snmpv1",
      "/c/sys/ssnmp/snmpv3/notify 2/name v1v2Trap2/tag v1v2param2",
      "/c/sys/ssnmp/snmpv3/comm 2/index trapComm2/name public/uname v1v2only",
      "/c/slb/real backup_loggerReal/ena/ipver v4/rip ${cc_remote_ip}",
      "/c/slb/real loggerReal/backup backup_loggerReal",
      %{ endif }
      "/c/sys/ssnmp/name ${vm_name}",
      "/c/slb/real loggerReal/ena/ipver v4/rip ${cc_local_ip}",
      "/c/slb/group loggerGroup/ipver v4/add loggerReal",
      "/c/slb/rlogging logger1/ena/proto tcp/port 5140/group loggerGroup/path mgmt",
      "/c/l3/if 1/ena/ipver v4/addr ${adc_clients_private_ip}/mask 255.255.255.0",
      "/c/l3/if 2/ena/ipver v4/addr ${adc_servers_private_ip}/mask 255.255.255.0/vlan 2",
      "/c/slb/pip/add ${adc_servers_private_ip_pip} 2",
      
      "/c/sys/syslog/hst1 ${hst1_ip} ${hst1_severity} ${hst1_facility} ${hst1_module} ${hst1_port}",
      "/c/sys/syslog/hst2 ${hst2_ip} ${hst2_severity} ${hst2_facility} ${hst2_module} ${hst2_port}"
    ]
  }
}