#!/bin/bash

iptables_check () {
    echo "【排查防火墙规则】"
    echo "-----------------------"
    if iptables -nL INPUT | awk 'NR>2&&$7!=""{print $0}' | egrep -v "RELATED|22|443|80|3306|icmp"
    then
        echo "请检查确认上述防火墙规则"
    else
        echo "防火墙无异常规则"
    fi
    echo
}
netstat_check () {
    echo "【对外开放的端口及服务】"
    echo "-----------------------"
    netstat -ntlup | awk -F"[ :]+" 'BEGIN{print "PID/Service\t\tPort"}NR>2&&$4=="0.0.0.0"&&$5!="68"&&$5!="123"{print $9"\t\t"$5}'
    echo
}
ip_check () {
    echo "外网IP:$(curl -s ip.sb)"
    if [[ $(awk -F"[ .]" '{print $4}' /etc/redhat-release) == 7 ]]
    then
        echo  "内网IP:$(ifconfig| grep inet | grep -v inet6 | awk '$2!="127.0.0.1"{print $2}')"
    else
        echo "内网IP:$(ifconfig| grep inet | grep -v inet6 | awk -F"[ :]+" '$4!="127.0.0.1"{print $4}')"
    fi
    echo "-----------------------"
}
hosts_check () {
    echo "【hosts.allow】"
    echo "-----------------------"
    grep -v "^#" /etc/hosts.allow || {
        echo "none"
    }
    echo "【hosts.deny】"
    echo "-----------------------"
    grep -v "^#" /etc/hosts.deny || {
        echo "none"
    }
    echo
}
audit_check () {
    echo "【审计检测】"
    echo "-----------------------"
    grep -v LOGIN /var/log/audit/audit.log |awk '{print $1,$5,$10,$NF}'| grep exe | sort |uniq
    echo
}
conn_check () {
    echo "【连接检测】"
    echo "-----------------------"
    netstat -ntlupa| awk -F"[ :/]+" '$8=="ESTABLISHED"&&$6!="127.0.0.1" &&$10!="php-fpm"&&$10!="filebeat"&&$10!="sshd"&&$10!="redis-server"&&$10!="AliYunDun"&&$10!="nginx"&&$7!=443&&$7!=3306&&$7!=6379{print $0}'
}
ip_check
iptables_check
netstat_check
hosts_check
audit_check
conn_check
