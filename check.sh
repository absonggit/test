#!/bin/bash
netstat_check () {
    data=($(netstat -ntlup | awk -F"[ :]+" 'NR>2&&$4=="0.0.0.0"&&$5!="68"&&$5!="123"{print $9":"$5}'|xargs))
    no_rules=""
    echo
    echo "【对外放开的服务端口及防火墙规则】"
    echo "------------------------------------"
    for i in ${data[@]}
    do
        serv=$(echo $i| cut -d":" -f1)
        port=$(echo $i| cut -d":" -f2)
        if iptables -nL INPUT | awk 'NR>2&&$7!=""{print $0}' | grep $port
        then
           :
        else
            no_rules="${no_rules}端口:${port}    未添加防火墙规则    $serv\n"
        fi
    done
    echo -e $no_rules
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
    echo "【tcp_wrappers】"
    echo "-----------------------"
    echo "hosts.allow"
    grep -v "^#" /etc/hosts.allow || {
        echo "none"
    }
    echo "hosts.deny"
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
services_check () {
    array=($(egrep -r "^[[:space:]]+listen" /usr/local/nginx/conf/vhost | awk -F"[ :;]+" '
    function basename(file) {
        sub(".*/", "", file)
        return file
     }
    $2!="#listen" {print basename($1)":"$3}'|xargs))
    echo
    echo "【虚拟主机】"
    echo "------------------------------------"
    printf "%-15s %-15s %-30s %-15s\n" 状态 端口 配置文件 Server_Name
    for i in ${array[@]}
    do
        port=$(echo $i | cut -d":" -f 2)
        conf=$(echo $i | cut -d":" -f 1)
        server_name=$(egrep "^[[:space:]]+server_name" /usr/local/nginx/conf/vhost/${conf} |awk -F"[ ;]+" '{for(i=3;i<NF;i++)printf("%s|",$i);print ""}')
        if netstat -ntlup | grep $port &> /dev/null
        then
            printf "%-15s %-10s %-30s %-15s\n" 已监听 ${port} ${conf} ${server_name}
        else
            printf "%-15s %-10s %-30s %-15s\n" 未监听 ${port} ${conf} ${server_name}
        fi
    done
}
items_check () {
    echo
    echo "【项目检测】"
    echo "------------------------------------"
    for path in $(find /home/wwwroot -mindepth 1 -maxdepth 1 -type d)
    do
        printf "%-15s %-30s\n" 文件数 项目目录
        file_count=$(find $path -path "$path/runtime" -prune -o -type f -print | wc -l)
        printf "%-10s %-30s\n" ${file_count} $path
        echo "24小时内修改过的文件"
        find $path ! -path "$path/data/Runtime/*" ! -path "$path/runtime/*" ! -path "$path/data/runtime/*" -mtime 0 -type f  ! -name "*.png" -print || {
            echo none
        }
        echo "------------------------------------"
    done
}
root_file_check () {
    echo
    echo "【文件系统24小时内的文件修改】"
    echo "------------------------------------"
    find / \
    ! -path "/home/wwwroot/*" \
    ! -path "/tmp/sess_*" \
    ! -path "/proc/*" \
    ! -path "/sys/*" \
    ! -path "/usr/local/aegis/*" \
    ! -path "/usr/local/share/aliyun-assist/*" \
    ! -path "/var/log/*" \
    ! -path "/var/lib/yum/*" \
    ! -path "/home/wwwlogs/*" \
    ! -path "/var/lib/rpm/*" \
    ! -path "/var/cache/yum/*" \
    ! -path "/var/lib/filebeat/*" \
    ! -path "/var/cache/man/*" \
    ! -path "/run/systemd/*" \
    -type f -mtime 0
}
shell_check () {
    echo
    echo "【shell进程检测】"
    echo "------------------------------------"
    ps aux | egrep -v "sshd|pts|filebeat|flush|mysql" | grep sh
}
code_check () {
    echo
    echo "【项目代码检测】"
    echo "------------------------------------"
    find /home/wwwroot -type f -name "*.php" -exec grep -Hn bash {} \; | egrep -v "foreach" || echo none
}
ip_check
netstat_check
hosts_check
audit_check
conn_check
services_check
items_check
root_file_check
shell_check
#code_check
