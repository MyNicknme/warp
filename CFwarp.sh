#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en_US.UTF-8
endpoint=
red='\033[0;31m'
bblue='\033[0;34m'
yellow='\033[0;33m'
green='\033[0;32m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
bblue(){ echo -e "\033[34m\033[01m$1\033[0m";}
rred(){ echo -e "\033[35m\033[01m$1\033[0m";}
readtp(){ read -t5 -n26 -p "$(yellow "$1")" $2;}
readp(){ read -p "$(yellow "$1")" $2;}
[[ $EUID -ne 0 ]] && yellow "Пожалуйста, запустите скрипт от root" && exit
#[[ -e /etc/hosts ]] && grep -qE '^ *172.65.251.78 gitlab.com' /etc/hosts || echo -e '\n172.65.251.78 gitlab.com' >> /etc/hosts
if [[ -f /etc/redhat-release ]]; then
release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
else 
red "Текущая система не поддерживается, используйте Ubuntu, Debian или Centos." && exit
fi
vsid=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)
op=$(cat /etc/redhat-release 2>/dev/null || cat /etc/os-release 2>/dev/null | grep -i pretty_name | cut -d \" -f2)
version=$(uname -r | cut -d "-" -f1)
main=$(uname -r | cut -d "." -f1)
minor=$(uname -r | cut -d "." -f2)
vi=$(systemd-detect-virt)
case "$release" in
"Centos") yumapt='yum -y';;
"Ubuntu"|"Debian") yumapt="apt-get -y";;
esac
cpujg(){
case $(uname -m) in
aarch64) cpu=arm64;;
x86_64) cpu=amd64;;
*) red "Скрипт пока не поддерживает архитектуру $(uname -m)" && exit;;
esac
}

cfwarpshow(){
insV=$(cat /root/warpip/v 2>/dev/null)
latestV=$(curl -sL https://raw.githubusercontent.com/yonggekkk/warp-yg/main/version | awk -F "更新内容" '{print $1}' | head -n 1)
if [[ -f /root/warpip/v ]]; then
if [ "$insV" = "$latestV" ]; then
echo -e " Текущая версия скрипта CFwarp-yg: ${bblue}${insV}${plain} уже является последней"
else
echo -e " Текущая версия скрипта CFwarp-yg: ${bblue}${insV}${plain}"
echo -e " Обнаружена новая версия скрипта CFwarp-yg: ${yellow}${latestV}${plain} (можно выбрать 8 для обновления)"
echo -e "${yellow}$(curl -sL https://raw.githubusercontent.com/yonggekkk/warp-yg/main/version)${plain}"
fi
else
echo -e " Текущая версия скрипта CFwarp-yg: ${bblue}${latestV}${plain}"
echo -e " Сначала выберите вариант (1, 2, 3), чтобы установить нужный режим warp"
fi
}

tun(){
if [[ $vi = openvz ]]; then
TUN=$(cat /dev/net/tun 2>&1)
if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then 
red "Обнаружено, что TUN не включен, сейчас будет попытка добавить поддержку TUN" && sleep 4
cd /dev && mkdir net && mknod net/tun c 10 200 && chmod 0666 net/tun
TUN=$(cat /dev/net/tun 2>&1)
if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then 
green "Не удалось добавить поддержку TUN, рекомендуется связаться с провайдером VPS или включить в панели управления" && exit
else
echo '#!/bin/bash' > /root/tun.sh && echo 'cd /dev && mkdir net && mknod net/tun c 10 200 && chmod 0666 net/tun' >> /root/tun.sh && chmod +x /root/tun.sh
grep -qE "^ *@reboot root bash /root/tun.sh >/dev/null 2>&1" /etc/crontab || echo "@reboot root bash /root/tun.sh >/dev/null 2>&1" >> /etc/crontab
green "Функция поддержания TUN уже запущена"
fi
fi
fi
}

nf4(){
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
result=$(curl -4fsL --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
if [[ "$result" == "404" ]]; then 
NF="К сожалению, текущий IP открывает только Netflix Originals"
elif [[ "$result" == "403" ]]; then
NF="Печально, текущий IP не может смотреть Netflix"
elif [[ "$result" == "200" ]]; then
NF="Поздравляем, текущий IP полностью открывает Netflix, включая неоригинальный контент"
else
NF="Смиритесь, Netflix не обслуживает регион текущего IP"
fi
}

nf6(){
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
result=$(curl -6fsL --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
if [[ "$result" == "404" ]]; then 
NF="К сожалению, текущий IP открывает только Netflix Originals"
elif [[ "$result" == "403" ]]; then
NF="Печально, текущий IP не может смотреть Netflix"
elif [[ "$result" == "200" ]]; then
NF="Поздравляем, текущий IP полностью открывает Netflix, включая неоригинальный контент"
else
NF="Смиритесь, Netflix не обслуживает регион текущего IP"
fi
}

nfs5() {
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
result=$(curl --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 -sx socks5h://localhost:$mport -4sL "https://www.netflix.com/title/70143836" 2>&1)
if [[ "$result" == "404" ]]; then 
NF="К сожалению, текущий IP открывает только Netflix Originals"
elif [[ "$result" == "403" ]]; then
NF="Печально, текущий IP не может смотреть Netflix"
elif [[ "$result" == "200" ]]; then
NF="Поздравляем, текущий IP полностью открывает Netflix, включая неоригинальный контент"
else
NF="Смиритесь, Netflix не обслуживает регион текущего IP"
fi
}

v4v6(){
v4=$(curl -s4m5 icanhazip.com -k)
v6=$(curl -s6m5 icanhazip.com -k)
}

checkwgcf(){
wgcfv6=$(curl -s6m5 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
wgcfv4=$(curl -s4m5 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
}

warpip(){
mkdir -p /root/warpip
v4v6
if [[ -z $v4 ]]; then
endpoint=[2606:4700:d0::a29f:c001]:2408
else
endpoint=162.159.192.1:2408
fi
}

dig9(){
if [[ -n $(grep 'DiG 9' /etc/hosts) ]]; then
echo -e "search blue.kundencontroller.de\noptions rotate\nnameserver 2a02:180:6:5::1c\nnameserver 2a02:180:6:5::4\nnameserver 2a02:180:6:5::1e\nnameserver 2a02:180:6:5::1d" > /etc/resolv.conf
fi
}

mtuwarp(){
v4v6
yellow "Начинается автоматическая настройка оптимального значения MTU для лучшей пропускной способности сети WARP!"
MTUy=1500
MTUc=10
if [[ -n $v6 && -z $v4 ]]; then
ping='ping6'
IP1='2606:4700:4700::1111'
IP2='2001:4860:4860::8888'
else
ping='ping'
IP1='1.1.1.1'
IP2='8.8.8.8'
fi
while true; do
if ${ping} -c1 -W1 -s$((${MTUy} - 28)) -Mdo ${IP1} >/dev/null 2>&1 || ${ping} -c1 -W1 -s$((${MTUy} - 28)) -Mdo ${IP2} >/dev/null 2>&1; then
MTUc=1
MTUy=$((${MTUy} + ${MTUc}))
else
MTUy=$((${MTUy} - ${MTUc}))
[[ ${MTUc} = 1 ]] && break
fi
[[ ${MTUy} -le 1360 ]] && MTUy='1360' && break
done
MTU=$((${MTUy} - 80))
green "Оптимальное значение MTU = $MTU установлено"
}

WGproxy(){
curl -sSL https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/acwarp.sh -o acwarp.sh && chmod +x acwarp.sh && bash acwarp.sh
}

xyz(){
if [[ -n $(screen -ls | grep '(Attached)' | awk '{print $1}' | awk -F "." '{print $1}') ]]; then
until [[ -z $(screen -ls | grep '(Attached)' | awk '{print $1}' | awk -F "." '{print $1}' | awk 'NR==1{print}') ]] 
do
Attached=`screen -ls | grep '(Attached)' | awk '{print $1}' | awk -F "." '{print $1}' | awk 'NR==1{print}'`
screen -d $Attached
done
fi
screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null
rm -rf /root/WARP-UP.sh
cat>/root/WARP-UP.sh<<-\EOF
#!/bin/bash
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
sleep 2
checkwgcf(){
wgcfv6=$(curl -s6m5 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
wgcfv4=$(curl -s4m5 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
}
warpclose(){
wg-quick down wgcf >/dev/null 2>&1;systemctl stop wg-quick@wgcf >/dev/null 2>&1;systemctl disable wg-quick@wgcf >/dev/null 2>&1;kill -15 $(pgrep warp-go) >/dev/null 2>&1;systemctl stop warp-go >/dev/null 2>&1;systemctl disable warp-go >/dev/null 2>&1
}
warpopen(){
wg-quick down wgcf >/dev/null 2>&1;systemctl enable wg-quick@wgcf >/dev/null 2>&1;systemctl start wg-quick@wgcf >/dev/null 2>&1;systemctl restart wg-quick@wgcf >/dev/null 2>&1;kill -15 $(pgrep warp-go) >/dev/null 2>&1;systemctl stop warp-go >/dev/null 2>&1;systemctl enable warp-go >/dev/null 2>&1;systemctl start warp-go >/dev/null 2>&1;systemctl restart warp-go >/dev/null 2>&1
}
warpre(){
i=0
while [ $i -le 4 ]; do let i++
warpopen
checkwgcf
if [[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]]; then
green "После сбоя попытка получить IP warp прошла успешно!" 
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] После сбоя попытка получить IP warp прошла успешно!" >> /root/warpip/warp_log.txt
break
else 
red "После сбоя попытка получить IP warp не удалась!"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] После сбоя попытка получить IP warp не удалась!" >> /root/warpip/warp_log.txt
fi
done
checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
warpclose
red "После 5 неудачных попыток получить IP warp выполняется остановка и отключение warp, VPS возвращается к исходному IP"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] После 5 неудачных попыток получить IP warp выполняется остановка и отключение warp, VPS возвращается к исходному IP" >> /root/warpip/warp_log.txt
fi
}
while true; do
green "Проверка, запущен ли warp…………"
wp=$(cat /root/warpip/wp.log)
if [[ $wp = w4 ]]; then
checkwgcf
if [[ $wgcfv4 =~ on|plus ]]; then
green "Поздравляем! WARP IPV4 работает! Следующая проверка будет автоматически выполнена через 600 секунд"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] Поздравляем! WARP IPV4 работает! Следующая проверка будет автоматически выполнена через 600 секунд" >> /root/warpip/warp_log.txt
sleep 600s
else
warpre ; green "Следующая проверка будет автоматически выполнена через 500 секунд"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] Следующая проверка будет автоматически выполнена через 500 секунд" >> /root/warpip/warp_log.txt
sleep 500s
fi
elif [[ $wp = w6 ]]; then
checkwgcf
if [[ $wgcfv6 =~ on|plus ]]; then
green "Поздравляем! WARP IPV6 работает! Следующая проверка будет автоматически выполнена через 600 секунд"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] Поздравляем! WARP IPV6 работает! Следующая проверка будет автоматически выполнена через 600 секунд" >> /root/warpip/warp_log.txt
sleep 600s
else
warpre ; green "Следующая проверка будет автоматически выполнена через 500 секунд"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] Следующая проверка будет автоматически выполнена через 500 секунд" >> /root/warpip/warp_log.txt
sleep 500s
fi
else
checkwgcf
if [[ $wgcfv4 =~ on|plus && $wgcfv6 =~ on|plus ]]; then
green "Поздравляем! WARP IPV4+IPV6 работает! Следующая проверка будет автоматически выполнена через 600 секунд"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] Поздравляем! WARP IPV4+IPV6 работает! Следующая проверка будет автоматически выполнена через 600 секунд" >> /root/warpip/warp_log.txt
sleep 600s
else
warpre ; green "Следующая проверка будет автоматически выполнена через 500 секунд"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] Следующая проверка будет автоматически выполнена через 500 секунд" >> /root/warpip/warp_log.txt
sleep 500s
fi
fi
done
EOF
[[ -e /root/WARP-UP.sh ]] && screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null ; screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh'
}

first4(){
[[ -e /etc/gai.conf ]] && grep -qE '^ *precedence ::ffff:0:0/96  100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf 2>/dev/null
}

docker(){
if [[ -n $(ip a | grep docker) ]]; then
red "Обнаружено, что на VPS уже установлен docker. Убедитесь, что docker работает в режиме host, иначе docker перестанет работать" && sleep 3s
echo
yellow "Через 6 секунд продолжится установка WARP по варианту 1, для выхода нажмите Ctrl+c" && sleep 6s
fi
}

lncf(){
curl -sSL -o /usr/bin/cf -L https://raw.githubusercontent.com/yonggekkk/warp-yg/main/CFwarp.sh
chmod +x /usr/bin/cf
}

UPwpyg(){
if [[ ! -f '/usr/bin/cf' ]]; then
red "Скрипт CFwarp установлен некорректно!" && exit
fi
lncf
curl -sL https://raw.githubusercontent.com/yonggekkk/warp-yg/main/version | awk -F "更新内容" '{print $1}' | head -n 1 > /root/warpip/v
green "Скрипт CFwarp успешно обновлён" && cf
}

restwarpgo(){
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
systemctl restart warp-go >/dev/null 2>&1
systemctl enable warp-go >/dev/null 2>&1
systemctl start warp-go >/dev/null 2>&1
}

cso(){
warp-cli --accept-tos disconnect >/dev/null 2>&1
warp-cli --accept-tos disable-always-on >/dev/null 2>&1
warp-cli --accept-tos delete >/dev/null 2>&1
if [[ $release = Centos ]]; then
yum autoremove cloudflare-warp -y
else
apt purge cloudflare-warp -y
rm -f /etc/apt/sources.list.d/cloudflare-client.list /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
fi
$yumapt autoremove
}

WARPun(){
readp "1. Удалить только WARP из варианта 1\n2. Удалить только Socks5-WARP из варианта 2\n3. Полностью очистить и удалить все связанные с WARP варианты (1+2)\n Выберите:" cd
case "$cd" in
1 ) cwg && green "warp удалён";;
2 ) cso && green "socks5-warp удалён";;
3 ) cwg && cso && unreswarp && green "warp и socks5-warp полностью удалены" && rm -rf /usr/bin/cf warp_update
esac
}

WARPtools(){
wppluskey(){
if [[ $cpu = amd64 ]]; then
curl -sSL -o warpplus.sh --insecure https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/warp_plus.sh >/dev/null 2>&1
elif [[ $cpu = arm64 ]]; then
curl -sSL -o warpplus.sh --insecure https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/warpplusa.sh >/dev/null 2>&1
fi
chmod +x warpplus.sh
timeout 60s ./warpplus.sh
}
green "1. Просмотр онлайн-мониторинга WARP в реальном времени (перед входом учтите: выйти и оставить мониторинг работать: ctrl+a+d, выйти и остановить мониторинг: ctrl+c )"
green "2. Перезапустить функцию онлайн-мониторинга WARP"
green "3. Сбросить и настроить пользовательский интервал онлайн-мониторинга WARP"
green "4. Просмотреть сегодняшний журнал онлайн-мониторинга WARP"
echo "-----------------------------------------------"
green "5. Изменить порт Socks5+WARP"
echo "-----------------------------------------------"
green "6. Использовать свой warp-ключ для постепенного накручивания трафика warp+"
green "7. В один клик сгенерировать warp+ ключ с трафиком более 20 миллионов GB"
echo "-----------------------------------------------"
green "0. Выход"
readp "Выберите:" warptools
if [[ $warptools == 1 ]]; then
[[ -z $(type -P warp-go) && -z $(type -P wg-quick) ]] && red "Вариант 1 не установлен, скрипт завершает работу" && exit
name=`screen -ls | grep '(Detached)' | awk '{print $1}' | awk -F "." '{print $2}'`
if [[ $name =~ "up" ]]; then
screen -Ur up
else
red "Функция мониторинга WARP не запущена, выберите 2 для перезапуска" && WARPtools
fi
elif [[ $warptools == 2 ]]; then
[[ -z $(type -P warp-go) && -z $(type -P wg-quick) ]] && red "Вариант 1 не установлен, скрипт завершает работу" && exit
xyz
name=`screen -ls | grep '(Detached)' | awk '{print $1}' | awk -F "." '{print $2}'`
[[ $name =~ "up" ]] && green "Онлайн-мониторинг WARP успешно запущен" || red "Не удалось запустить онлайн-мониторинг WARP, проверьте, установлен ли screen"
elif [[ $warptools == 3 ]]; then
[[ -z $(type -P warp-go) && -z $(type -P wg-quick) ]] && red "Вариант 1 не установлен, скрипт завершает работу" && exit
xyz
readp "Когда warp работает, интервал повторной проверки состояния warp (Enter по умолчанию 600 секунд), введите интервал (например: 50 секунд, введите 50):" stop
[[ -n $stop ]] && sed -i "s/600s/${stop}s/g;s/600秒/${stop}秒/g" /root/WARP-UP.sh || green "Интервал по умолчанию 600 секунд"
readp "Когда warp прерван (после 5 подряд неудач warp автоматически отключается и VPS возвращается к исходному IP), интервал продолжения проверки состояния WARP (Enter по умолчанию 500 секунд), введите интервал (например: 50 секунд, введите 50):" goon
[[ -n $goon ]] && sed -i "s/500s/${goon}s/g;s/500秒/${goon}秒/g" /root/WARP-UP.sh || green "Интервал по умолчанию 500 секунд"
[[ -e /root/WARP-UP.sh ]] && screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null ; screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh'
green "Настройка завершена, интервал мониторинга можно посмотреть в пункте 1"
elif [[ $warptools == 4 ]]; then
[[ -z $(type -P warp-go) && -z $(type -P wg-quick) ]] && red "Вариант 1 не установлен, скрипт завершает работу" && exit
cat /root/warpip/warp_log.txt
# find /root/warpip/warp_log.txt -mtime -1 -exec cat {} \;
elif [[ $warptools == 6 ]]; then
green "Также можно накручивать через веб-страницу: https://replit.com/@ygkkkk/Warp" && sleep 2
wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/wp-plus.py 
sed -i "27 s/[(][^)]*[)]//g" wp-plus.py
readp "ID конфигурации клиента (36 символов):" ID
sed -i "27 s/input/'$ID'/" wp-plus.py
python3 wp-plus.py
elif [[ $warptools == 5 ]]; then
SOCKS5WARPPORT
elif [[ $warptools == 7 ]]; then
wppluskey && rm -rf warpplus.sh
green "Все warp+ ключи, сгенерированные этим скриптом, сохранены в файле /root/WARP+Keys.txt"
green "Каждый новый ключ при повторном запуске будет добавлен в конец файла (включая вариант 1 и вариант 2)"
blue "$(cat /root/WARP+Keys.txt)"
echo
else
cf
fi
}

chatgpt4(){
gpt1=$(curl -s4 https://chat.openai.com 2>&1)
gpt2=$(curl -s4 https://ios.chat.openai.com 2>&1)
}
chatgpt6(){
gpt1=$(curl -s6 https://chat.openai.com 2>&1)
gpt2=$(curl -s6 https://ios.chat.openai.com 2>&1)
}
checkgpt(){
#if [[ $gpt1 == *location* ]]; then
if [[ $gpt2 == *VPN* ]]; then
chat='К сожалению, текущий IP открывает только веб-версию ChatGPT, клиент не открыт'
elif [[ $gpt2 == *Request* ]]; then
chat='Поздравляем, текущий IP полностью открывает ChatGPT (веб + клиент)'
else
chat='Печально, текущий IP не может открыть сервис ChatGPT'
fi
#else
#chat='杯具，当前IP无法解锁ChatGPT服务'
#fi
}

ShowSOCKS5(){
if [[ $(systemctl is-active warp-svc) = active ]]; then
mport=`warp-cli --accept-tos settings 2>/dev/null | grep 'WarpProxy on port' | awk -F "port " '{print $2}'`
s5ip=`curl -sx socks5h://localhost:$mport icanhazip.com -k`
nfs5
gpt1=$(curl -sx socks5h://localhost:$mport https://chat.openai.com 2>&1)
gpt2=$(curl -sx socks5h://localhost:$mport https://android.chat.openai.com 2>&1)
checkgpt
#NF=$(./nf -proxy socks5h://localhost:$mport | awk '{print $1}' | sed -n '3p')
nonf=$(curl -sx socks5h://localhost:$mport --user-agent "${UA_Browser}" http://ip-api.com/json/$s5ip?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
#sunf=$(./nf | awk '{print $1}' | sed -n '4p')
#snnf=$(curl -sx socks5h://localhost:$mport ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
country=$nonf
socks5=$(curl -sx socks5h://localhost:$mport www.cloudflare.com/cdn-cgi/trace -k --connect-timeout 2 | grep warp | cut -d= -f2) 
case ${socks5} in 
plus) 
S5Status=$(white "Состояние Socks5 WARP+：\c" ; rred "работает, аккаунт WARP+ (остаток трафика WARP+: $((`warp-cli --accept-tos account | grep Quota | awk '{ print $(NF) }'`/1000000000)) GB)" ; white " Порт Socks5：\c" ; rred "$mport" ; white " Провайдер Cloudflare выдал IPv4-адрес：\c" ; rred "$s5ip  $country" ; white " Статус разблокировки Netflix NF：\c" ; rred "$NF" ; white " Статус разблокировки ChatGPT：\c" ; rred "$chat");;  
on) 
S5Status=$(white "Состояние Socks5 WARP：\c" ; green "работает, обычный аккаунт WARP (безлимитный трафик WARP)" ; white " Порт Socks5：\c" ; green "$mport" ; white " Провайдер Cloudflare выдал IPv4-адрес：\c" ; green "$s5ip  $country" ; white " Статус разблокировки Netflix NF：\c" ; green "$NF" ; white " Статус разблокировки ChatGPT：\c" ; green "$chat");;  
*) 
S5Status=$(white "Состояние Socks5 WARP：\c" ; yellow "Клиент Socks5-WARP установлен, но порт находится в закрытом состоянии")
esac 
else
S5Status=$(white "Состояние Socks5 WARP：\c" ; red "Клиент Socks5-WARP не установлен")
fi
}

SOCKS5ins(){
yellow "Проверка среды установки Socks5-WARP……"
if [[ $release = Centos ]]; then
[[ ! ${vsid} =~ 8 ]] && yellow "Текущая версия системы: Centos $vsid \nSocks5-WARP поддерживает только Centos 8 " && exit 
elif [[ $release = Ubuntu ]]; then
[[ ! ${vsid} =~ 20|22|24 ]] && yellow "Текущая версия системы: Ubuntu $vsid \nSocks5-WARP поддерживает только Ubuntu 20.04/22.04/24.04 " && exit 
elif [[ $release = Debian ]]; then
[[ ! ${vsid} =~ 10|11|12|13 ]] && yellow "Текущая версия системы: Debian $vsid \nSocks5-WARP поддерживает только Debian 10/11/12/13 " && exit 
fi
[[ $(warp-cli --accept-tos status 2>/dev/null) =~ 'Connected' ]] && red "Socks5-WARP уже запущен" && cf

systemctl stop wg-quick@wgcf >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
v4v6
if [[ -n $v6 && -z $v4 ]]; then
systemctl start wg-quick@wgcf >/dev/null 2>&1
restwarpgo
red "Установка Socks5-WARP пока не поддерживается на VPS только с IPV6" && sleep 2 && exit
else
systemctl start wg-quick@wgcf >/dev/null 2>&1
restwarpgo
#elif [[ -n $v4 && -z $v6 ]]; then
#systemctl start wg-quick@wgcf >/dev/null 2>&1
#checkwgcf
#[[ $wgcfv4 =~ on|plus ]] && red "纯IPV4的VPS已安装Wgcf-WARP-IPV4，不支持安装Socks5-WARP" && cf
#elif [[ -n $v4 && -n $v6 ]]; then
#systemctl start wg-quick@wgcf >/dev/null 2>&1
#checkwgcf
#[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && red "原生双栈VPS已安装Wgcf-WARP-IPV4/IPV6，请先卸载。然后安装Socks5-WARP，最后安装Wgcf-WARP-IPV4/IPV6" && cf
fi
#systemctl start wg-quick@wgcf >/dev/null 2>&1
#checkwgcf
#if [[ $wgcfv4 =~ on|plus && $wgcfv6 =~ on|plus ]]; then
#red "已安装Wgcf-WARP-IPV4+IPV6，不支持安装Socks5-WARP" && cf
#fi
if [[ $release = Centos ]]; then 
yum -y install epel-release && yum -y install net-tools
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo
yum update
#rpm -ivh https://pkg.cloudflareclient.com/cloudflare-release-el8.rpm
yum -y install cloudflare-warp
fi
if [[ $release = Debian ]]; then
[[ ! $(type -P gpg) ]] && apt update && apt install gnupg -y
[[ ! $(apt list 2>/dev/null | grep apt-transport-https | grep installed) ]] && apt update && apt install apt-transport-https -y
fi
if [[ $release != Centos ]]; then
apt install net-tools -y
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt-get update && sudo apt-get install cloudflare-warp
fi
warpip
echo y | warp-cli registration new
warp-cli mode proxy 
warp-cli proxy port 40000
warp-cli connect
#wppluskey >/dev/null 2>&1
#ID=$(tail -n1 /root/WARP+Keys.txt | cut -d' ' -f1 2>/dev/null)
#if [[ -n $ID ]]; then
#green "Использовать warp+ ключ"
#green "$(tail -n1 /root/WARP+Keys.txt | cut -d' ' -f1)"
#warp-cli --accept-tos set-license $ID >/dev/null 2>&1
#fi
#rm -rf warpplus.sh
#if [[ $(warp-cli --accept-tos account) =~ 'Limited' ]]; then
#green "Уже обновлено до аккаунта Socks5-WARP+\nОстаток трафика Socks5-WARP+: $((`warp-cli --accept-tos account | grep Quota | awk '{ print $(NF) }'`/1000000000)) GB"
#fi
green "Установка завершена, возврат в меню"
sleep 2 && lncf && reswarp && cf
}

SOCKS5WARPUP(){
[[ ! $(type -P warp-cli) ]] && red "Socks5-WARP не установлен, невозможно обновить до аккаунта Socks5-WARP+" && exit
[[ $(warp-cli --accept-tos account) =~ 'Limited' ]] && red "Сейчас уже используется аккаунт Socks5-WARP+, повторное обновление не требуется" && exit
readp "Лицензионный ключ (26 символов):" ID
[[ -n $ID ]] && warp-cli --accept-tos set-license $ID >/dev/null 2>&1 || (red "Лицензионный ключ не введён (26 символов)" && exit)
yellow "Если появится ошибка Error: Too many devices, возможно, к ключу уже привязано более 5 устройств или ключ введён неверно"
if [[ $(warp-cli --accept-tos account) =~ 'Limited' ]]; then
green "Уже обновлено до аккаунта Socks5-WARP+\nОстаток трафика Socks5-WARP+: $((`warp-cli --accept-tos account | grep Quota | awk '{ print $(NF) }'`/1000000000)) GB"
else
red "Не удалось обновить аккаунт до Socks5-WARP+" && exit
fi
sleep 2 && ShowSOCKS5 && S5menu
}

SOCKS5WARPPORT(){
[[ ! $(type -P warp-cli) ]] && red "Socks5-WARP(+) не установлен, невозможно изменить порт" && exit
readp "Введите пользовательский порт socks5 [2000～65535] (нажмите Enter для случайного порта в диапазоне 2000-65535):" port
if [[ -z $port ]]; then
port=$(shuf -i 2000-65535 -n 1)
until [[ -z $(ss -ntlp | awk '{print $4}' | sed 's/.*://g' | grep -w "$port") ]]
do
[[ -n $(ss -ntlp | awk '{print $4}' | sed 's/.*://g' | grep -w "$port") ]] && yellow "\nПорт занят, пожалуйста, введите другой порт" && readp "Пользовательский порт socks5:" port
done
else
until [[ -z $(ss -ntlp | awk '{print $4}' | sed 's/.*://g' | grep -w "$port") ]]
do
[[ -n $(ss -ntlp | awk '{print $4}' | sed 's/.*://g' | grep -w "$port") ]] && yellow "\nПорт занят, пожалуйста, введите другой порт" && readp "Пользовательский порт socks5:" port
done
fi
[[ -n $port ]] && warp-cli --accept-tos set-proxy-port $port >/dev/null 2>&1
green "Текущий порт socks5: $port"
sleep 2 && ShowSOCKS5 && S5menu
}

WGCFmenu(){
name=`screen -ls | grep '(Detached)' | awk '{print $1}' | awk -F "." '{print $2}'`
[[ $name =~ "up" ]] && keepup="Мониторинг WARP включён" || keepup="Мониторинг WARP отключён"
white "------------------------------------------------------------------------------------"
white " Вариант 1: текущая ситуация с исходящим трафиком VPS через IPV4 ($keepup)"
white " ${WARPIPv4Status}"
white "------------------------------------------------------------------------------------"
white " Вариант 1: текущая ситуация с исходящим трафиком VPS через IPV6 ($keepup)"
white " ${WARPIPv6Status}"
white "------------------------------------------------------------------------------------"
if [[ "$WARPIPv4Status" == *不存在* && "$WARPIPv6Status" == *不存在* ]]; then
yellow "И IPV4, и IPV6 отсутствуют, рекомендации:"
red "1. Если ранее был установлен wgcf, выберите 9 для переключения на warp-go и переустановки warp"
red "2. Если ранее был установлен warp-go, выберите 10 для переключения на wgcf и переустановки warp"
red "Важно: если ситуация не изменится, рекомендуется удалить всё, перезагрузить VPS и затем заново установить вариант 1"
fi
}
S5menu(){
white "------------------------------------------------------------------------------------------------"
white " Вариант 2: текущее состояние локального прокси официального клиента Socks5-WARP"
blue " ${S5Status}"
white "------------------------------------------------------------------------------------------------"
}

reswarp(){
unreswarp
crontab -l > /tmp/crontab.tmp
echo "0 4 * * * systemctl stop warp-go;systemctl restart warp-go;systemctl restart wg-quick@wgcf;systemctl restart warp-svc" >> /tmp/crontab.tmp
echo "@reboot screen -UdmS up /bin/bash /root/WARP-UP.sh" >> /tmp/crontab.tmp
echo "0 0 * * * rm -f /root/warpip/warp_log.txt" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}

unreswarp(){
crontab -l > /tmp/crontab.tmp
sed -i '/systemctl stop warp-go;systemctl restart warp-go;systemctl restart wg-quick@wgcf;systemctl restart warp-svc/d' /tmp/crontab.tmp
sed -i '/@reboot screen/d' /tmp/crontab.tmp
sed -i '/warp_log.txt/d' /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}

ONEWARPGO(){
if [[ $(echo "$op" | grep -i -E "arch|alpine") ]]; then
red "Скрипт не поддерживает текущую систему $op, используйте Ubuntu, Debian или Centos." && exit
fi
yellow "\n Подождите, сейчас используется режим установки на ядре warp-go, выполняется проверка IP узла и исходящего трафика……"
warpip

wgo1='sed -i "s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g" /usr/local/bin/warp.conf'
wgo2='sed -i "s#.*AllowedIPs.*#AllowedIPs = ::/0#g" /usr/local/bin/warp.conf'
wgo3='sed -i "s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g" /usr/local/bin/warp.conf'
wgo4='sed -i "/Endpoint6/d" /usr/local/bin/warp.conf && sed -i "/Endpoint/s/.*/Endpoint = '"$endpoint"'/" /usr/local/bin/warp.conf'
wgo5='sed -i "/Endpoint6/d" /usr/local/bin/warp.conf && sed -i "/Endpoint/s/.*/Endpoint = '"$endpoint"'/" /usr/local/bin/warp.conf'
wgo6='sed -i "/\[Script\]/a PostUp = ip -4 rule add from $(ip route get 162.159.192.1 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf && sed -i "/\[Script\]/a PostDown = ip -4 rule delete from $(ip route get 162.159.192.1 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf'
wgo7='sed -i "/\[Script\]/a PostUp = ip -6 rule add from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf && sed -i "/\[Script\]/a PostDown = ip -6 rule delete from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf'
wgo8='sed -i "/\[Script\]/a PostUp = ip -4 rule add from $(ip route get 162.159.192.1 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf && sed -i "/\[Script\]/a PostDown = ip -4 rule delete from $(ip route get 162.159.192.1 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf && sed -i "/\[Script\]/a PostUp = ip -6 rule add from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf && sed -i "/\[Script\]/a PostDown = ip -6 rule delete from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP "src \K\S+") lookup main\n" /usr/local/bin/warp.conf'

STOPwgcf(){
if [[ -n $(type -P warp-cli) ]]; then
red "Socks5-WARP уже установлен, выбранный вариант установки WARP не поддерживается" 
systemctl restart warp-go && cf
fi
}

ShowWGCF(){
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
v4v6
warppflow=$((`grep -oP '"quota":\K\d+' <<< $(curl -sm4 "https://api.cloudflareclient.com/v0a884/reg/$(grep 'Device' /usr/local/bin/warp.conf 2>/dev/null | cut -d= -f2 | sed 's# ##g')" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $(grep 'Token' /usr/local/bin/warp.conf 2>/dev/null | cut -d= -f2 | sed 's# ##g')")`))
flow=`echo "scale=2; $warppflow/1000000000" | bc`
[[ -e /usr/local/bin/warpplus.log ]] && cfplus="Аккаунт WARP+ (ограниченный трафик WARP+: $flow GB), имя устройства: $(sed -n 1p /usr/local/bin/warpplus.log)" || cfplus="Командный аккаунт WARP+ Teams (безлимитный трафик WARP+)"
if [[ -n $v4 ]]; then
nf4
chatgpt4
checkgpt
wgcfv4=$(curl -s4 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
isp4a=`curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f13 -d ":" | cut -f2 -d '"'`
isp4b=`curl -sm3 --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v4 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -n $isp4a ]] && isp4=$isp4a || isp4=$isp4b
nonf=$(curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
#sunf=$(./nf | awk '{print $1}' | sed -n '4p')
#snnf=$(curl -s4m6 ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
country=$nonf
case ${wgcfv4} in 
plus) 
WARPIPv4Status=$(white "Состояние WARP+：\c" ; rred "работает, $cfplus" ; white " Провайдер Cloudflare выдал IPv4-адрес：\c" ; rred "$v4  $country" ; white " Статус разблокировки Netflix NF：\c" ; rred "$NF" ; white " Статус разблокировки ChatGPT：\c" ; rred "$chat");;  
on) 
WARPIPv4Status=$(white "Состояние WARP：\c" ; green "работает, обычный аккаунт WARP (безлимитный трафик WARP)" ; white " Провайдер Cloudflare выдал IPv4-адрес：\c" ; green "$v4  $country" ; white " Статус разблокировки Netflix NF：\c" ; green "$NF" ; white " Статус разблокировки ChatGPT：\c" ; green "$chat");;
off) 
WARPIPv4Status=$(white "Состояние WARP：\c" ; yellow "отключён" ; white " Провайдер $isp4 выдал IPv4-адрес：\c" ; yellow "$v4  $country" ; white " Статус разблокировки Netflix NF：\c" ; yellow "$NF" ; white " Статус разблокировки ChatGPT：\c" ; yellow "$chat");; 
esac 
else
WARPIPv4Status=$(white "Состояние IPV4：\c" ; red "IPV4-адрес отсутствует ")
fi 
if [[ -n $v6 ]]; then
nf6
chatgpt6
checkgpt
wgcfv6=$(curl -s6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
isp6a=`curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f13 -d":" | cut -f2 -d '"'`
isp6b=`curl -sm3 --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v6 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -n $isp6a ]] && isp6=$isp6a || isp6=$isp6b
nonf=$(curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
#sunf=$(./nf | awk '{print $1}' | sed -n '8p')
#snnf=$(curl -s6m6 ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
country=$nonf
case ${wgcfv6} in 
plus) 
WARPIPv6Status=$(white "Состояние WARP+：\c" ; rred "работает, $cfplus" ; white " Провайдер Cloudflare выдал IPv6-адрес：\c" ; rred "$v6  $country" ; white " Статус разблокировки Netflix NF：\c" ; rred "$NF" ; white " Статус разблокировки ChatGPT：\c" ; rred "$chat");;  
on) 
WARPIPv6Status=$(white "Состояние WARP：\c" ; green "работает, обычный аккаунт WARP (безлимитный трафик WARP)" ; white " Провайдер Cloudflare выдал IPv6-адрес：\c" ; green "$v6  $country" ; white " Статус разблокировки Netflix NF：\c" ; green "$NF" ; white " Статус разблокировки ChatGPT：\c" ; green "$chat");;
off) 
WARPIPv6Status=$(white "Состояние WARP：\c" ; yellow "отключён" ; white " Провайдер $isp6 выдал IPv6-адрес：\c" ; yellow "$v6  $country" ; white " Статус разблокировки Netflix NF：\c" ; yellow "$NF" ; white " Статус разблокировки ChatGPT：\c" ; yellow "$chat");;
esac 
else
WARPIPv6Status=$(white "Состояние IPV6：\c" ; red "IPV6-адрес отсутствует ")
fi 
}

CheckWARP(){
i=0
while [ $i -le 9 ]; do let i++
yellow "Всего выполняется 10 попыток, сейчас $i-я попытка получить IP warp……"
restwarpgo
checkwgcf
if [[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]]; then
green "Поздравляем! IP warp получен успешно!" && dns
break
else
red "К сожалению, не удалось получить IP warp"
fi
done
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
red "Установка WARP не удалась, восстановление VPS и удаление WARP"
cwg
echo
[[ $release = Centos && ${vsid} -lt 7 ]] && yellow "Текущая версия системы: Centos $vsid \nРекомендуется использовать Centos 7 и выше " 
[[ $release = Ubuntu && ${vsid} -lt 18 ]] && yellow "Текущая версия системы: Ubuntu $vsid \nРекомендуется использовать Ubuntu 18 и выше " 
[[ $release = Debian && ${vsid} -lt 10 ]] && yellow "Текущая версия системы: Debian $vsid \nРекомендуется использовать Debian 10 и выше "
yellow "Подсказка:"
red "Возможно, вы можете использовать вариант 2 или вариант 3 для реализации WARP"
red "Также можно выбрать ядро WGCF для установки WARP по варианту 1"
exit
else 
green "ok" && systemctl restart warp-go
fi
}

nat4(){
[[ -n $(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+') ]] && wpgo4=$wgo6 || wpgo4=echo
}

WGCFv4(){
yellow "Подождите 3 секунды, выполняется проверка среды warp на VPS"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV4 (исходящий трафик: нативный IPV6 + WARP IPV4)" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo4 && wpgo3=$wgo8 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV4 (исходящий трафик: нативный IPV6 + WARP IPV4)" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV4 (исходящий трафик: только WARP IPV4)" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo4 && wpgo3=$wgo6 && WGCFins
fi
echo 'w4' > /root/warpip/wp.log && xyz && WGCFmenu
first4
else
kill -15 $(pgrep warp-go) >/dev/null 2>&1
sleep 2 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV4 (исходящий трафик: нативный IPV6 + WARP IPV4)" && sleep 2
wpgo1=$wgo1 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV4 (исходящий трафик: нативный IPV6 + WARP IPV4)" && sleep 2
wpgo1=$wgo1 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV4 (исходящий трафик: только WARP IPV4)" && sleep 2
wpgo1=$wgo1 && ABC
fi
echo 'w4' > /root/warpip/wp.log
cat /usr/local/bin/warp.conf && sleep 2
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv6(){
yellow "Подождите 3 секунды, выполняется проверка среды warp на VPS"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV6 (исходящий трафик: нативный IPV4 + WARP IPV6)" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo4 && wpgo3=$wgo8 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV6 (исходящий трафик: только WARP IPV6)" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV6 (исходящий трафик: нативный IPV4 + WARP IPV6)" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo4 && wpgo3=$wgo6 && WGCFins
fi
echo 'w6' > /root/warpip/wp.log && xyz && WGCFmenu
first4
else
kill -15 $(pgrep warp-go) >/dev/null 2>&1
sleep 2 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV6 (исходящий трафик: нативный IPV4 + WARP IPV6)" && sleep 2
wpgo1=$wgo2 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV6 (исходящий трафик: только WARP IPV6)" && sleep 2
wpgo1=$wgo2 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV6 (исходящий трафик: нативный IPV4 + WARP IPV6)" && sleep 2
wpgo1=$wgo2 && ABC
fi
echo 'w6' > /root/warpip/wp.log
cat /usr/local/bin/warp.conf && sleep 2
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv4v6(){
yellow "Подождите 3 секунды, выполняется проверка среды warp на VPS"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV4+IPV6 (исходящий трафик: WARP dual-stack IPV4 + IPV6)" && sleep 2
wpgo1=$wgo3 && wpgo2=$wgo4 && wpgo3=$wgo8 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV4+IPV6 (исходящий трафик: WARP dual-stack IPV4 + IPV6)" && sleep 2
wpgo1=$wgo3 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 впервые устанавливается warp-go\nСейчас будет добавлен WARP IPV4+IPV6 (исходящий трафик: WARP dual-stack IPV4 + IPV6)" && sleep 2
wpgo1=$wgo3 && wpgo2=$wgo4 && wpgo3=$wgo6 && WGCFins
fi
echo 'w64' > /root/warpip/wp.log && xyz && WGCFmenu
first4
else
kill -15 $(pgrep warp-go) >/dev/null 2>&1
sleep 2 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV4+IPV6 (исходящий трафик: WARP dual-stack IPV4 + IPV6)" && sleep 2
wpgo1=$wgo3 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV4+IPV6 (исходящий трафик: WARP dual-stack IPV4 + IPV6)" && sleep 2
wpgo1=$wgo3 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 уже установлен warp-go\nСейчас будет быстрое переключение на WARP IPV4+IPV6 (исходящий трафик: WARP dual-stack IPV4 + IPV6)" && sleep 2
wpgo1=$wgo3 && ABC
fi
echo 'w64' > /root/warpip/wp.log
cat /usr/local/bin/warp.conf && sleep 2
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

ABC(){
echo $wpgo1 | sh
echo $wpgo2 | sh
echo $wpgo3 | sh
echo $wpgo4 | sh
}

dns(){
if [[ ! -f /etc/resolv.conf.bak ]]; then
mv /etc/resolv.conf /etc/resolv.conf.bak
rm -rf /etc/resolv.conf
cp -f /etc/resolv.conf.bak /etc/resolv.conf
chattr +i /etc/resolv.conf >/dev/null 2>&1
else
chattr +i /etc/resolv.conf >/dev/null 2>&1
fi
}

WGCFins(){
if [[ $release = Centos ]]; then
yum install epel-release -y;yum install iproute iputils -y
elif [[ $release = Debian ]]; then
apt install lsb-release -y
echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt update -y;apt install iproute2 openresolv dnsutils iputils-ping -y
elif [[ $release = Ubuntu ]]; then
apt update -y;apt install iproute2 openresolv dnsutils iputils-ping -y
fi
wget -N https://gitlab.com/rwkgyg/CFwarp/-/raw/main/warp-go_1.0.8_linux_${cpu} -O /usr/local/bin/warp-go && chmod +x /usr/local/bin/warp-go
yellow "Выполняется запрос обычного аккаунта WARP, пожалуйста, подождите!"
if [[ ! -s /usr/local/bin/warp.conf ]]; then
cpujg
curl -L -o warpapi -# --retry 2 https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/cpu1/$cpu
chmod +x warpapi
output=$(./warpapi)
private_key=$(echo "$output" | awk -F ': ' '/private_key/{print $2}')
device_id=$(echo "$output" | awk -F ': ' '/device_id/{print $2}')
warp_token=$(echo "$output" | awk -F ': ' '/token/{print $2}')
rm -rf warpapi
cat > /usr/local/bin/warp.conf <<EOF
[Account]
Device = $device_id
PrivateKey = $private_key
Token = $warp_token
Type = free
Name = WARP
MTU  = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.192.1:2408
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0
KeepAlive = 30
EOF
fi
chmod +x /usr/local/bin/warp.conf
sed -i '0,/AllowedIPs/{/AllowedIPs/d;}' /usr/local/bin/warp.conf
sed -i '/KeepAlive/a [Script]' /usr/local/bin/warp.conf
mtuwarp
sed -i "s/MTU.*/MTU = $MTU/g" /usr/local/bin/warp.conf
cat > /lib/systemd/system/warp-go.service << EOF
[Unit]
Description=warp-go service
After=network.target
Documentation=https://gitlab.com/ProjectWARP/warp-go
[Service]
WorkingDirectory=/root/
ExecStart=/usr/local/bin/warp-go --config=/usr/local/bin/warp.conf
Environment="LOG_LEVEL=verbose"
RemainAfterExit=yes
Restart=always
[Install]
WantedBy=multi-user.target
EOF
ABC
systemctl daemon-reload
systemctl enable warp-go
systemctl start warp-go
restwarpgo
cat /usr/local/bin/warp.conf && sleep 2
checkwgcf
if [[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]]; then
green "Поздравляем! IP warp получен успешно!" && dns
else
CheckWARP
fi
ShowWGCF && lncf && reswarp
curl -sL https://raw.githubusercontent.com/yonggekkk/warp-yg/main/version | awk -F "更新内容" '{print $1}' | head -n 1 > /root/warpip/v
}

warpinscha(){
yellow "Подсказка: локальный исходящий IP VPS будет заменён выбранным вами IP warp; если у VPS нет такого локального исходящего IP, будет сгенерирован другой IP warp"
echo
green "1. Установить/переключить WARP single-stack IPV4 (по умолчанию Enter)"
green "2. Установить/переключить WARP single-stack IPV6"
green "3. Установить/переключить WARP dual-stack IPV4+IPV6"
readp "\nВыберите:" wgcfwarp
if [ -z "${wgcfwarp}" ] || [ $wgcfwarp == "1" ];then
WGCFv4
elif [ $wgcfwarp == "2" ];then
WGCFv6
elif [ $wgcfwarp == "3" ];then
WGCFv4v6
else 
red "Ошибка ввода, пожалуйста, выберите снова" && warpinscha
fi
echo
} 

WARPup(){
freewarp(){
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
v4v6
allowips=$(cat /usr/local/bin/warp.conf | grep AllowedIPs)
if [[ -n $v4 && -n $v6 ]]; then
endp=$wgo4
post=$wgo8
elif [[ -n $v6 && -z $v4 ]]; then
endp=$wgo5
[[ -n $(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+') ]] && post=$wgo8 || post=$wgo7
elif [[ -z $v6 && -n $v4 ]]; then
endp=$wgo4
post=$wgo6
fi
yellow "Текущее действие: запрос обычного аккаунта WARP"
echo
yellow "Выполняется запрос обычного аккаунта WARP, пожалуйста, подождите!"
rm -rf /usr/local/bin/warp.conf /usr/local/bin/warp.conf.bak /usr/local/bin/warpplus.log
curl -Ls -o /usr/local/bin/warp.conf --retry 2 https://api.zeroteam.top/warp?format=warp-go
if [[ ! -s /usr/local/bin/warp.conf ]]; then
cpujg
curl -Ls -o warpapi --retry 2 https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/cpu1/$cpu
chmod +x warpapi
output=$(./warpapi)
private_key=$(echo "$output" | awk -F ': ' '/private_key/{print $2}')
device_id=$(echo "$output" | awk -F ': ' '/device_id/{print $2}')
warp_token=$(echo "$output" | awk -F ': ' '/token/{print $2}')
rm -rf warpapi
cat > /usr/local/bin/warp.conf <<EOF
[Account]
Device = $device_id
PrivateKey = $private_key
Token = $warp_token
Type = free
Name = WARP
MTU  = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.192.1:2408
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0
KeepAlive = 30
EOF
fi
chmod +x /usr/local/bin/warp.conf
sed -i '0,/AllowedIPs/{/AllowedIPs/d;}' /usr/local/bin/warp.conf
sed -i '/KeepAlive/a [Script]' /usr/local/bin/warp.conf
mtuwarp
sed -i "s/MTU.*/MTU = $MTU/g" /usr/local/bin/warp.conf
sed -i "s#.*AllowedIPs.*#$allowips#g" /usr/local/bin/warp.conf
echo $endp | sh
echo $post | sh
CheckWARP && ShowWGCF &&  WGCFmenu
}

green "1. Обычный аккаунт WARP (безлимитный трафик)"
green "2. Аккаунт WARP+ (ограниченный трафик)"
green "3. Командный аккаунт WARP Teams (Zero Trust) (безлимитный трафик)"
green "4. Аккаунт Socks5+WARP+ (ограниченный трафик)"
readp "Выберите тип аккаунта, на который хотите переключиться:" warpup
if [[ $warpup == 1 ]]; then
freewarp
fi

if [[ $warpup == 4 ]]; then
SOCKS5WARPUP
fi

if [[ $warpup == 2 ]]; then
[[ ! $(type -P warp-go) ]] && red "warp-go не установлен" && exit
green "Скопируйте лицензионный ключ из мобильного клиента WARP в статусе WARP+ или ключ из сетевого шаринга (26 символов). Из-за бага WARP-GO обновление с высокой вероятностью может завершиться неудачей"
readp "Введите ключ для обновления до WARP+:" ID
if [[ -z $ID ]]; then
red "Ничего не введено" && WARPup
fi
readp "Задайте имя устройства, Enter — случайное:" dname
if [[ -z $dname ]]; then
dname=`date +%s%N |md5sum | cut -c 1-4`
fi
green "Имя устройства: $dname"
/usr/local/bin/warp-go --update --config=/usr/local/bin/warp.conf --license=$ID --device-name=$dname
i=0
while [ $i -le 9 ]; do let i++
yellow "Всего выполняется 10 попыток, сейчас $i-я попытка обновления аккаунта WARP+……" 
restwarpgo
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
rm -rf /usr/local/bin/warp.conf.bak /usr/local/bin/warpplus.log
echo "$dname" >> /usr/local/bin/warpplus.log && echo "$ID" >> /usr/local/bin/warpplus.log
green "Аккаунт WARP+ успешно обновлён!" && ShowWGCF && WGCFmenu && break
else
red "Не удалось обновить аккаунт WARP+!" && sleep 1
fi
done
if [[ ! $wgcfv4 = plus && ! $wgcfv6 = plus ]]; then
green "Рекомендации:"
yellow "1. Проверьте, есть ли трафик у аккаунта WARP+ в приложении 1.1.1.1 или у ключа из сетевого шаринга"
yellow "2. Проверьте, не привязано ли к текущему лицензионному ключу WARP более 5 устройств; удалите устройства в мобильном клиенте и попробуйте снова обновить аккаунт WARP+" && sleep 2
freewarp
fi
fi
    
if [[ $warpup == 3 ]]; then
[[ ! $(type -P warp-go) ]] && red "warp-go не установлен" && exit
green "Адрес для получения Token команды Zero Trust: https://web--public--warp-team-api--coia-mfs4.code.run/"
readp "Введите Token командного аккаунта: " token
curl -Ls -o /usr/local/bin/warp.conf.bak --retry 2 https://api.zeroteam.top/warp?format=warp-go
if [[ ! -s /usr/local/bin/warp.conf.bak ]]; then
cpujg
curl -Ls -o warpapi --retry 2 https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/cpu1/$cpu
chmod +x warpapi
output=$(./warpapi)
private_key=$(echo "$output" | awk -F ': ' '/private_key/{print $2}')
device_id=$(echo "$output" | awk -F ': ' '/device_id/{print $2}')
warp_token=$(echo "$output" | awk -F ': ' '/token/{print $2}')
rm -rf warpapi
cat > /usr/local/bin/warp.conf.bak <<EOF
[Account]
Device = $device_id
PrivateKey = $private_key
Token = $warp_token
Type = free
Name = WARP
MTU  = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.192.1:2408
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0
KeepAlive = 30
EOF
fi
/usr/local/bin/warp-go --register --config=/usr/local/bin/warp.conf.bak --team-config=$token --device-name=vps+warp+teams+$(date +%s%N |md5sum | cut -c 1-3)
sed -i "2s#.*#$(sed -ne 2p /usr/local/bin/warp.conf.bak)#;3s#.*#$(sed -ne 3p /usr/local/bin/warp.conf.bak)#" /usr/local/bin/warp.conf >/dev/null 2>&1
sed -i "4s#.*#$(sed -ne 4p /usr/local/bin/warp.conf.bak)#;5s#.*#$(sed -ne 5p /usr/local/bin/warp.conf.bak)#" /usr/local/bin/warp.conf >/dev/null 2>&1
i=0
while [ $i -le 9 ]; do let i++
yellow "Всего выполняется 10 попыток, сейчас $i-я попытка получения IP warp……"
restwarpgo
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
rm -rf /usr/local/bin/warp.conf.bak /usr/local/bin/warpplus.log
green "Аккаунт WARP Teams успешно обновлён!" && ShowWGCF && WGCFmenu && break
else
red "Не удалось обновить аккаунт WARP Teams!" && sleep 1
fi
done
if [[ ! $wgcfv4 = plus && ! $wgcfv6 = plus ]]; then
freewarp
fi
fi
}

WARPonoff(){
[[ ! $(type -P warp-go) ]] && red "WARP не установлен, рекомендуется установить заново" && exit
readp "1. Выключить WARP (выключить онлайн-мониторинг WARP)\n2. Включить/перезапустить WARP (запустить онлайн-мониторинг WARP)\n0. Вернуться на уровень выше\n Выберите:" unwp
if [ "$unwp" == "1" ]; then
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
systemctl disable warp-go
screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null
unreswarp
checkwgcf 
[[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]] && green "WARP успешно выключен" || red "Не удалось выключить WARP"
elif [ "$unwp" == "2" ]; then
CheckWARP
xyz
name=`screen -ls | grep '(Detached)' | awk '{print $1}' | awk -F "." '{print $2}'`
[[ $name =~ "up" ]] && green "Онлайн-мониторинг WARP успешно запущен" || red "Не удалось запустить онлайн-мониторинг WARP, проверьте, установлен ли screen"
reswarp
checkwgcf 
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "WARP успешно включён" || red "Не удалось включить WARP"
else
cf
fi
}

cwg(){
screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null
systemctl disable warp-go >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1 
chattr -i /etc/resolv.conf >/dev/null 2>&1
sed -i '/^precedence ::ffff:0:0\/96  100/d' /etc/gai.conf 2>/dev/null
rm -rf /usr/local/bin/warp-go /usr/local/bin/warpplus.log /usr/local/bin/warp.conf /usr/local/bin/wgwarp.conf /usr/local/bin/sbwarp.json /usr/bin/warp-go /lib/systemd/system/warp-go.service /root/WARP-UP.sh
rm -rf /root/warpip
}

changewarp(){
cwg && ONEWGCFWARP
}

upwarpgo(){
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
wget -N https://gitlab.com/rwkgyg/CFwarp/-/raw/main/warp-go_1.0.8_linux_${cpu} -O /usr/local/bin/warp-go && chmod +x /usr/local/bin/warp-go
restwarpgo
loVERSION="$(/usr/local/bin/warp-go -v | sed -n 1p | awk '{print $1}' | awk -F"/" '{print $NF}')"
green " Текущая установленная версия ядра WARP-GO: ${loVERSION}, уже является последней"
}

start_menu(){
ShowWGCF;ShowSOCKS5
clear
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"           
echo -e "${bblue} ░██     ░██      ░██ ██ ██         ░█${plain}█   ░██     ░██   ░██     ░█${red}█   ░██${plain}  "
echo -e "${bblue}  ░██   ░██      ░██    ░░██${plain}        ░██  ░██      ░██  ░██${red}      ░██  ░██${plain}   "
echo -e "${bblue}   ░██ ░██      ░██ ${plain}                ░██ ██        ░██ █${red}█        ░██ ██  ${plain}   "
echo -e "${bblue}     ░██        ░${plain}██    ░██ ██       ░██ ██        ░█${red}█ ██        ░██ ██  ${plain}  "
echo -e "${bblue}     ░██ ${plain}        ░██    ░░██        ░██ ░██       ░${red}██ ░██       ░██ ░██ ${plain}  "
echo -e "${bblue}     ░█${plain}█          ░██ ██ ██         ░██  ░░${red}██     ░██  ░░██     ░██  ░░██ ${plain}  "
echo
white "Проект Yongge на Github ：github.com/yonggekkk"
white "Блог Yongge на Blogger ：ygkkk.blogspot.com"
white "Канал Yongge на YouTube ：www.youtube.com/@ygkkk"
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yellow " Выберите подходящий для себя вариант реализации warp (пункты 1, 2, 3; можно выбрать один или несколько одновременно)"
yellow " Быстрый вход в скрипт：cf"
white " ================================================================="
green "  1. Вариант 1: установить/переключить WARP-GO"
green "  2. Вариант 2: установить Socks5-WARP"
green "  3. Вариант 3: сгенерировать файл конфигурации и QR-код WARP-Wireguard"
green "  4. Удалить WARP"
white " -----------------------------------------------------------------"
green "  5. Выключить, включить/перезапустить WARP"
green "  6. Другие опции WARP"
green "  7. Обновить/переключить три типа аккаунтов WARP"
green "  8. Обновить установочный скрипт CFwarp"
green "  9. Обновить ядро WARP-GO"
green " 10. Заменить текущее ядро WARP-GO на ядро WGCF-WARP"
green "  0. Выйти из скрипта "
red "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cfwarpshow
red "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
white " Информация о системе VPS:"
white " Операционная система: $(blue "$op") \c" && white " Версия ядра: $(blue "$version") \c" && white " Архитектура CPU : $(blue "$cpu") \c" && white " Тип виртуализации: $(blue "$vi")"
WGCFmenu
S5menu
echo
readp " Введите номер:" Input
case "$Input" in     
 1 ) warpinscha;;
 2 ) SOCKS5ins;;
 3 ) WGproxy;;
 4 ) WARPun;;
 5 ) WARPonoff;;
 6 ) WARPtools;;
 7 ) WARPup;;
 8 ) UPwpyg;;
 9 ) upwarpgo;;
 10 ) changewarp;;
 * ) exit
esac
}
if [ $# == 0 ]; then
bit=`uname -m`
[[ $bit = aarch64 ]] && cpu=arm64
if [[ $bit = x86_64 ]]; then
amdv=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2)
case "$amdv" in
*avx512*) cpu=amd64v4;;
*avx2*) cpu=amd64v3;;
*sse3*) cpu=amd64v2;;
*) cpu=amd64;;
esac
fi
start_menu
fi
}

ONEWGCFWARP(){
if [[ $(echo "$op" | grep -i -E "arch|alpine") ]]; then
red "Скрипт не поддерживает текущую систему $op, используйте Ubuntu, Debian или Centos." && exit
fi
yellow "\n Подождите, сейчас используется режим установки на ядре wgcf, выполняется проверка IP узла и исходящего трафика……"
warpip

ud4='sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -4 rule delete from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf'
ud6='sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -6 rule delete from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf'
ud4ud6='sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -4 rule delete from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -6 rule delete from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf'
c1="sed -i '/0\.0\.0\.0\/0/d' /etc/wireguard/wgcf.conf"
c2="sed -i '/\:\:\/0/d' /etc/wireguard/wgcf.conf"
c3="sed -i "s/engage.cloudflareclient.com:2408/$endpoint/g" /etc/wireguard/wgcf.conf"
c4="sed -i "s/engage.cloudflareclient.com:2408/$endpoint/g" /etc/wireguard/wgcf.conf"
c5="sed -i 's/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g' /etc/wireguard/wgcf.conf"
c6="sed -i 's/1.1.1.1/2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4/g' /etc/wireguard/wgcf.conf"

ShowWGCF(){
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
v4v6
warppflow=$((`grep -oP '"quota":\K\d+' <<< $(curl -sm4 "https://api.cloudflareclient.com/v0a884/reg/$(grep 'device_id' /etc/wireguard/wgcf-account.toml 2>/dev/null | cut -d \' -f2)" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $(grep 'access_token' /etc/wireguard/wgcf-account.toml 2>/dev/null | cut -d \' -f2)")`))
flow=`echo "scale=2; $warppflow/1000000000" | bc`
[[ -e /etc/wireguard/wgcf+p.log ]] && cfplus="Аккаунт WARP+ (ограниченный трафик WARP+: $flow GB), имя устройства: $(grep -s 'Device name' /etc/wireguard/wgcf+p.log | awk '{ print $NF }')" || cfplus="Командный аккаунт WARP+ Teams (безлимитный трафик WARP+)"
if [[ -n $v4 ]]; then
nf4
chatgpt4
checkgpt
wgcfv4=$(curl -s4 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
isp4a=`curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f13 -d ":" | cut -f2 -d '"'`
isp4b=`curl -sm3 --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v4 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -n $isp4a ]] && isp4=$isp4a || isp4=$isp4b
nonf=$(curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
#sunf=$(./nf | awk '{print $1}' | sed -n '4p')
#snnf=$(curl -s4m6 ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
country=$nonf
case ${wgcfv4} in 
plus) 
WARPIPv4Status=$(white "Состояние WARP+：\c" ; rred "работает, $cfplus" ; white " Провайдер Cloudflare выдал IPv4-адрес：\c" ; rred "$v4  $country" ; white " Статус разблокировки Netflix NF：\c" ; rred "$NF" ; white " Статус разблокировки ChatGPT：\c" ; rred "$chat");;  
on) 
WARPIPv4Status=$(white "Состояние WARP：\c" ; green "работает, обычный аккаунт WARP (безлимитный трафик WARP)" ; white " Провайдер Cloudflare выдал IPv4-адрес：\c" ; green "$v4  $country" ; white " Статус разблокировки Netflix NF：\c" ; green "$NF" ; white " Статус разблокировки ChatGPT：\c" ; green "$chat");;
off) 
WARPIPv4Status=$(white "Состояние WARP：\c" ; yellow "отключён" ; white " Провайдер $isp4 выдал IPv4-адрес：\c" ; yellow "$v4  $country" ; white " Статус разблокировки Netflix NF：\c" ; yellow "$NF" ; white " Статус разблокировки ChatGPT：\c" ; yellow "$chat");; 
esac 
else
WARPIPv4Status=$(white "Состояние IPV4：\c" ; red "IPV4-адрес отсутствует ")
fi 
if [[ -n $v6 ]]; then
nf6
chatgpt6
checkgpt
wgcfv6=$(curl -s6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
isp6a=`curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f13 -d":" | cut -f2 -d '"'`
isp6b=`curl -sm3 --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v6 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -n $isp6a ]] && isp6=$isp6a || isp6=$isp6b
nonf=$(curl -sm3 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
#sunf=$(./nf | awk '{print $1}' | sed -n '8p')
#snnf=$(curl -s6m6 ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
country=$nonf
case ${wgcfv6} in 
plus) 
WARPIPv6Status=$(white "Состояние WARP+：\c" ; rred "работает, $cfplus" ; white " Провайдер Cloudflare выдал IPv6-адрес：\c" ; rred "$v6  $country" ; white " Статус разблокировки Netflix NF：\c" ; rred "$NF" ; white " Статус разблокировки ChatGPT：\c" ; rred "$chat");;  
on) 
WARPIPv6Status=$(white "Состояние WARP：\c" ; green "работает, обычный аккаунт WARP (безлимитный трафик WARP)" ; white " Провайдер Cloudflare выдал IPv6-адрес：\c" ; green "$v6  $country" ; white " Статус разблокировки Netflix NF：\c" ; green "$NF" ; white " Статус разблокировки ChatGPT：\c" ; green "$chat");;
off) 
WARPIPv6Status=$(white "Состояние WARP：\c" ; yellow "отключён" ; white " Провайдер $isp6 выдал IPv6-адрес：\c" ; yellow "$v6  $country" ; white " Статус разблокировки Netflix NF：\c" ; yellow "$NF" ; white " Статус разблокировки ChatGPT：\c" ; yellow "$chat");;
esac 
else
WARPIPv6Status=$(white "Состояние IPV6：\c" ; red "IPV6-адрес отсутствует ")
fi 
}

STOPwgcf(){
if [[ $(type -P warp-cli) ]]; then
red "Socks5-WARP уже установлен, выбранный вариант установки wgcf-warp не поддерживается" 
systemctl restart wg-quick@wgcf && cf
fi
}

fawgcf(){
rm -f /etc/wireguard/wgcf+p.log
ID=$(cat /etc/wireguard/buckup-account.toml | grep license_key | awk '{print $3}')
sed -i "s/license_key.*/license_key = $ID/g" /etc/wireguard/wgcf-account.toml
cd /etc/wireguard && wgcf update >/dev/null 2>&1
wgcf generate >/dev/null 2>&1 && cd
sed -i "2s#.*#$(sed -ne 2p /etc/wireguard/wgcf-profile.conf)#;4s#.*#$(sed -ne 4p /etc/wireguard/wgcf-profile.conf)#" /etc/wireguard/wgcf.conf
CheckWARP && ShowWGCF &&  WGCFmenu
}

ABC(){
echo $ABC1 | sh
echo $ABC2 | sh
echo $ABC3 | sh
echo $ABC4 | sh
echo $ABC5 | sh
}

conf(){
rm -rf /etc/wireguard/wgcf.conf
cp -f /etc/wireguard/buckup-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1
cp -f /etc/wireguard/wgcf-profile.conf /etc/wireguard/buckup-profile.conf >/dev/null 2>&1
}

nat4(){
[[ -n $(ip route get 162.159.192.1 2>/dev/null | grep -oP 'src \K\S+') ]] && ABC4=$ud4 || ABC4=echo
}

WGCFv4(){
yellow "Подождите 3 секунды, выполняется проверка среды warp на VPS"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp single-stack IPV4" && sleep 2
ABC1=$c5 && ABC2=$c2 && ABC3=$ud4 && ABC4=$c3 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp single-stack IPV4" && sleep 2
ABC1=$c5 && ABC2=$c4 && ABC3=$c2 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp single-stack IPV4" && sleep 2
ABC1=$c5 && ABC2=$c2 && ABC3=$c3 && ABC4=$ud4 && WGCFins
fi
echo 'w4' > /root/warpip/wp.log && xyz && WGCFmenu
first4
else
wg-quick down wgcf >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp single-stack IPV4" && sleep 2
conf && ABC1=$c5 && ABC2=$c2 && ABC3=$ud4 && ABC4=$c3 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp single-stack IPV4" && sleep 2
conf && ABC1=$c5 && ABC2=$c4 && ABC3=$c2 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp single-stack IPV4" && sleep 2
conf && ABC1=$c5 && ABC2=$c2 && ABC3=$c3 && ABC4=$ud4 && ABC
fi
echo 'w4' > /root/warpip/wp.log
cat /etc/wireguard/wgcf.conf && sleep 2
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv6(){
yellow "Подождите 3 секунды, выполняется проверка среды warp на VPS"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp single-stack IPV6" && sleep 2
ABC1=$c5 && ABC2=$c1 && ABC3=$ud6 && ABC4=$c3 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp single-stack IPV6 (без IPV4!!!)" && sleep 2
ABC1=$c6 && ABC2=$c1 && ABC3=$c4 && nat4 && ABC5=$ud6 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp single-stack IPV6" && sleep 2
ABC1=$c5 && ABC2=$c3 && ABC3=$c1 && WGCFins
fi
echo 'w6' > /root/warpip/wp.log && xyz && WGCFmenu
first4
else
wg-quick down wgcf >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp single-stack IPV6" && sleep 2
conf && ABC1=$c5 && ABC2=$c1 && ABC3=$ud6 && ABC4=$c3 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp single-stack IPV6 (без IPV4!!!)" && sleep 2
conf && ABC1=$c6 && ABC2=$c1 && ABC3=$c4 && nat4 && ABC5=$ud6 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp single-stack IPV6" && sleep 2
conf && ABC1=$c5 && ABC2=$c3 && ABC3=$c1 && ABC
fi
echo 'w6' > /root/warpip/wp.log
cat /etc/wireguard/wgcf.conf && sleep 2
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv4v6(){
yellow "Подождите 3 секунды, выполняется проверка среды warp на VPS"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp dual-stack IPV4+IPV6" && sleep 2
ABC1=$c5 && ABC2=$ud4ud6 && ABC3=$c3 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp dual-stack IPV4+IPV6" && sleep 2
ABC1=$c5 && ABC2=$c4 && ABC3=$ud6 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 впервые устанавливается wgcf-warp\nСейчас будет добавлен режим wgcf-warp dual-stack IPV4+IPV6" && sleep 2
ABC1=$c5 && ABC2=$c3 && ABC3=$ud4 && WGCFins
fi
echo 'w64' > /root/warpip/wp.log && xyz && WGCFmenu
first4
else
wg-quick down wgcf >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "На текущем VPS с нативным dual-stack v4+v6 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp dual-stack IPV4+IPV6" && sleep 2
conf && ABC1=$c5 && ABC2=$ud4ud6 && ABC3=$c3 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "На текущем VPS только с нативным v6 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp dual-stack IPV4+IPV6" && sleep 2
conf && ABC1=$c5 && ABC2=$c4 && ABC3=$ud6 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "На текущем VPS только с нативным v4 уже установлен wgcf-warp\nСейчас будет быстрое переключение на режим wgcf-warp dual-stack IPV4+IPV6" && sleep 2
conf && ABC1=$c5 && ABC2=$c3 && ABC3=$ud4 && ABC
fi
echo 'w64' > /root/warpip/wp.log
cat /etc/wireguard/wgcf.conf && sleep 2
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

CheckWARP(){
i=0
wg-quick down wgcf >/dev/null 2>&1
while [ $i -le 9 ]; do let i++
yellow "Всего выполняется 10 попыток, сейчас $i-я попытка получения IP warp……"
systemctl restart wg-quick@wgcf >/dev/null 2>&1
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "Поздравляем! IP warp получен успешно!" && break || red "К сожалению, не удалось получить IP warp"
done
checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
red "Установка WARP не удалась, восстановление VPS и удаление компонентов Wgcf-WARP……"
cwg
echo
[[ $release = Centos && ${vsid} -lt 7 ]] && yellow "Текущая версия системы: Centos $vsid \nРекомендуется использовать Centos 7 и выше " 
[[ $release = Ubuntu && ${vsid} -lt 18 ]] && yellow "Текущая версия системы: Ubuntu $vsid \nРекомендуется использовать Ubuntu 18 и выше " 
[[ $release = Debian && ${vsid} -lt 10 ]] && yellow "Текущая версия системы: Debian $vsid \nРекомендуется использовать Debian 10 и выше "
yellow "Подсказка:"
red "Возможно, вы можете использовать вариант 2 или вариант 3 для реализации WARP"
red "Также можно выбрать ядро WARP-GO для установки WARP по варианту 1"
exit
else 
green "ok"
fi
}

WGCFins(){
rm -rf /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf-account.toml /etc/wireguard/wgcf+p.log /etc/wireguard/ID /usr/bin/wireguard-go /usr/bin/wgcf wgcf-account.toml wgcf-profile.conf /etc/wireguard/buckup-profile.conf
if [[ $release = Centos ]]; then
yum install epel-release -y;yum install iproute iptables wireguard-tools -y
elif [[ $release = Debian ]]; then
apt install lsb-release -y
echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt update -y;apt install iproute2 openresolv dnsutils iptables iputils-ping -y;apt install wireguard-tools --no-install-recommends -y      		
elif [[ $release = Ubuntu ]]; then
apt update -y;apt install iproute2 openresolv dnsutils iptables iputils-ping -y;apt install wireguard-tools --no-install-recommends -y			
fi
wget -N https://gitlab.com/rwkgyg/cfwarp/raw/main/wgcf_2.2.22_$cpu -O /usr/local/bin/wgcf && chmod +x /usr/local/bin/wgcf         
if [[ $main -lt 5 || $minor -lt 6 ]] || [[ $vi =~ lxc|openvz ]]; then
[[ -e /usr/bin/wireguard-go ]] || wget -N https://gitlab.com/rwkgyg/cfwarp/raw/main/wireguard-go -O /usr/bin/wireguard-go && chmod +x /usr/bin/wireguard-go
fi
echo | wgcf register
until [[ -e wgcf-account.toml ]]
do
yellow "Во время запроса обычного аккаунта warp может несколько раз появиться сообщение: 429 Too Many Requests, пожалуйста, подождите 30 секунд" && sleep 1
echo | wgcf register --accept-tos
done
wgcf generate
mtuwarp

#blue "Проверка возможности автоматически сгенерировать и использовать аккаунт warp+, пожалуйста, подождите 10 секунд"
#wppluskey >/dev/null 2>&1
sed -i "s/MTU.*/MTU = $MTU/g" wgcf-profile.conf
cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1
cp -f wgcf-account.toml /etc/wireguard/buckup-account.toml  >/dev/null 2>&1
cp -f wgcf-profile.conf /etc/wireguard/buckup-profile.conf  >/dev/null 2>&1
ABC
mv -f wgcf-profile.conf /etc/wireguard >/dev/null 2>&1
mv -f wgcf-account.toml /etc/wireguard >/dev/null 2>&1
#ID=$(tail -n1 /root/WARP+Keys.txt | cut -d' ' -f1 2>/dev/null)
#if [[ -n $ID ]]; then
#green "Использовать warp+ ключ"
#green "$(tail -n1 /root/WARP+Keys.txt | cut -d' ' -f1 2>/dev/null)"
#sed -i "s/license_key.*/license_key = '$ID'/g" /etc/wireguard/wgcf-account.toml
#sbmc=warp+$(date +%s%N |md5sum | cut -c 1-3)
#SBID="--name $(echo $sbmc | sed s/[[:space:]]/_/g)"
#rm -rf warpplus.sh
#cd /etc/wireguard && wgcf update $SBID > /etc/wireguard/wgcf+p.log 2>&1
#wgcf generate && cd
#sed -i "2s#.*#$(sed -ne 2p /etc/wireguard/wgcf-profile.conf)#;4s#.*#$(sed -ne 4p /etc/wireguard/wgcf-profile.conf)#" /etc/wireguard/wgcf.conf
#sed -i "2s#.*#$(sed -ne 2p /etc/wireguard/wgcf-profile.conf)#;4s#.*#$(sed -ne 4p /etc/wireguard/wgcf-profile.conf)#" /etc/wireguard/buckup-profile.conf
#else
#yellow "Не удалось автоматически сгенерировать warp+, будет создан обычный аккаунт warp"
#fi
systemctl enable wg-quick@wgcf
cat /etc/wireguard/wgcf.conf && sleep 2
CheckWARP && ShowWGCF && lncf && reswarp
curl -sL https://raw.githubusercontent.com/yonggekkk/warp-yg/main/version | awk -F "更新内容" '{print $1}' | head -n 1 > /root/warpip/v
}

WARPup(){
backconf(){
red "Обновление не удалось, автоматически восстанавливается обычный аккаунт warp"
sed -i "2s#.*#$(sed -ne 2p /etc/wireguard/wgcf-profile.conf)#;4s#.*#$(sed -ne 4p /etc/wireguard/wgcf-profile.conf)#" /etc/wireguard/wgcf.conf
CheckWARP && ShowWGCF && WGCFmenu
}
readp "1. Командный аккаунт Teams\n2. Аккаунт warp+\n3. Обычный аккаунт warp\n4. Socks5+WARP+ аккаунт\n0. Вернуться на уровень выше\n Выберите:" cd
case "$cd" in 
1 )
result(){
sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*128#Address = $ADDRESS6/128#g" /etc/wireguard/wgcf.conf
sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*128#Address = $ADDRESS6/128#g" /etc/wireguard/buckup-profile.conf
CheckWARP
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
rm -rf /etc/wireguard/wgcf+p.log && green "Аккаунт wgcf-warp+Teams уже активирован" && ShowWGCF && WGCFmenu
else
backconf
fi
}
[[ ! $(type -P wg-quick) ]] && red "wgcf-warp не установлен, сначала установите wgcf-warp" && exit
green "1. Использовать Token для получения командного аккаунта Teams, адрес для получения Token: https://web--public--warp-team-api--coia-mfs4.code.run/"
green "2. Вручную скопировать приватный ключ и IPV6-адрес"
green "0. Выход"
readp "Выберите:" up
if [[ $up == 1 ]]; then
readp " Скопируйте Token командного аккаунта: " TEAM_TOKEN
PRIVATEKEY=$(wg genkey)
PUBLICKEY=$(wg pubkey <<< "$PRIVATEKEY")
INSTALL_ID=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 22)
FCM_TOKEN="${INSTALL_ID}:APA91b$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 134)"
ERROR_TIMES=0
while [ "$ERROR_TIMES" -le 3 ]; do
(( ERROR_TIMES++ ))
if [[ "$TEAMS" =~ 'token is expired' ]]; then
read -p " Обновите token и вставьте заново " TEAM_TOKEN
elif [[ "$TEAMS" =~ 'error' ]]; then
read -p " Обновите token и вставьте заново " TEAM_TOKEN
elif [[ "$TEAMS" =~ 'organization' ]]; then
break
fi
TEAMS=$(curl --silent --location --tlsv1.3 --request POST 'https://api.cloudflareclient.com/v0a2158/reg' \
--header 'User-Agent: okhttp/3.12.1' \
--header 'CF-Client-Version: a-6.10-2158' \
--header 'Content-Type: application/json' \
--header "Cf-Access-Jwt-Assertion: ${TEAM_TOKEN}" \
--data '{"key":"'${PUBLICKEY}'","install_id":"'${INSTALL_ID}'","fcm_token":"'${FCM_TOKEN}'","tos":"'$(date +"%Y-%m-%dT%H:%M:%S.%3NZ")'","model":"Linux","serial_number":"'${INSTALL_ID}'","locale":"zh_CN"}')
ADDRESS6=$(expr "$TEAMS" : '.*"v6":[ ]*"\([^"]*\).*')
done
result
elif [[ $up == 2 ]]; then
readp "Скопируйте privateKey (44 символа):" PRIVATEKEY
readp "Скопируйте IPV6 Address:" ADDRESS6
result
else
exit
fi
;;
2 )
result(){
sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*128#Address = $ADDRESS6/128#g" /etc/wireguard/wgcf.conf
sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*128#Address = $ADDRESS6/128#g" /etc/wireguard/buckup-profile.conf
CheckWARP
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
echo "Неизвестно" > /etc/wireguard/wgcf+p.log && green "Аккаунт wgcf-warp+ уже активирован" && ShowWGCF && WGCFmenu
else
fawgcf
fi
}
[[ ! $(type -P wg-quick) ]] && red "wgcf-warp не установлен, сначала установите wgcf-warp" && exit
green "1. Ввести ключ"
green "2. Вручную скопировать приватный ключ и IPV6-адрес"
green "0. Выход"
readp "Выберите:" up
if [[ $up == 1 ]]; then
readp "Скопируйте лицензионный ключ из мобильного клиента WARP в статусе WARP+ или ключ из сетевого шаринга (26 символов):" ID
[[ -n $ID ]] && sed -i "s/license_key.*/license_key = '$ID'/g" /etc/wireguard/wgcf-account.toml && readp "Переименовать устройство (Enter — случайное имя):" sbmc || (red "Лицензионный ключ не введён (26 символов)" && cf)
[[ -n $sbmc ]] && SBID="--name $(echo $sbmc | sed s/[[:space:]]/_/g)"
cd /etc/wireguard && wgcf update $SBID > /etc/wireguard/wgcf+p.log 2>&1
wgcf generate && cd
sed -i "2s#.*#$(sed -ne 2p /etc/wireguard/wgcf-profile.conf)#;4s#.*#$(sed -ne 4p /etc/wireguard/wgcf-profile.conf)#" /etc/wireguard/wgcf.conf
sed -i "2s#.*#$(sed -ne 2p /etc/wireguard/wgcf-profile.conf)#;4s#.*#$(sed -ne 4p /etc/wireguard/wgcf-profile.conf)#" /etc/wireguard/buckup-profile.conf
CheckWARP && checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
warppflow=$((`grep -oP '"quota":\K\d+' <<< $(curl -s "https://api.cloudflareclient.com/v0a884/reg/$(grep 'device_id' /etc/wireguard/wgcf-account.toml 2>/dev/null | cut -d \' -f2)" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $(grep 'access_token' /etc/wireguard/wgcf-account.toml 2>/dev/null | cut -d \' -f2)")`))
flow=`echo "scale=2; $warppflow/1000000000" | bc`
green "Уже обновлено до аккаунта wgcf-warp+\nИмя устройства аккаунта wgcf-warp+: $(grep -s 'Device name' /etc/wireguard/wgcf+p.log | awk '{ print $NF }')\nОстаток трафика wgcf-warp+: $flow GB"
ShowWGCF && WGCFmenu 
else
red "По результатам проверки IP обновление до warp+ не удалось. Убедитесь, что с этим ключом используется не более 5 устройств; рекомендуется заменить ключ и попробовать снова. Скрипт завершает работу" && exit
fi
elif [[ $up == 2 ]]; then
readp "Скопируйте privateKey (44 символа):" PRIVATEKEY
readp "Скопируйте IPV6 Address:" ADDRESS6
result
else
exit
fi
;;
3 )
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
fawgcf
else
yellow "Сейчас уже используется обычный аккаунт wgcf-warp"
ShowWGCF && WGCFmenu
fi;;
4 )
SOCKS5WARPUP;;
0 ) cf
esac
}

WARPonoff(){
[[ ! $(type -P wg-quick) ]] && red "WARP не установлен, рекомендуется установить заново" && exit
readp "1. Выключить WARP (выключить онлайн-мониторинг WARP)\n2. Включить/перезапустить WARP (запустить онлайн-мониторинг WARP)\n0. Вернуться на уровень выше\n Выберите:" unwp
if [ "$unwp" == "1" ]; then
wg-quick down wgcf >/dev/null 2>&1
systemctl stop wg-quick@wgcf >/dev/null 2>&1
systemctl disable wg-quick@wgcf >/dev/null 2>&1
screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null
unreswarp
checkwgcf 
[[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]] && green "WARP успешно выключен" || red "Не удалось выключить WARP"
elif [ "$unwp" == "2" ]; then
wg-quick down wgcf >/dev/null 2>&1
systemctl restart wg-quick@wgcf >/dev/null 2>&1
xyz
name=`screen -ls | grep '(Detached)' | awk '{print $1}' | awk -F "." '{print $2}'`
[[ $name =~ "up" ]] && green "Онлайн-мониторинг WARP успешно запущен" || red "Не удалось запустить онлайн-мониторинг WARP, проверьте, установлен ли screen"
reswarp
checkwgcf 
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "WARP успешно включён" || red "Не удалось включить WARP"
else
cf
fi
}

cwg(){
screen -ls | awk '/\.up/ {print $1}' | cut -d "." -f 1 | xargs kill 2>/dev/null
wg-quick down wgcf >/dev/null 2>&1
systemctl disable wg-quick@wgcf >/dev/null 2>&1
$yumapt remove wireguard-tools
$yumapt autoremove
dig9
sed -i '/^precedence ::ffff:0:0\/96  100/d' /etc/gai.conf 2>/dev/null
rm -rf /usr/local/bin/wgcf /usr/bin/wg-quick /etc/wireguard/wgcf.conf /etc/wireguard/wgcf-profile.conf /etc/wireguard/buckup-account.toml /etc/wireguard/wgcf-account.toml /etc/wireguard/wgcf+p.log /etc/wireguard/ID /usr/bin/wireguard-go /usr/bin/wgcf wgcf-account.toml wgcf-profile.conf /etc/wireguard/buckup-profile.conf /root/WARP-UP.sh
rm -rf /root/warpip /root/WARP+Keys.txt
}

warpinscha(){
yellow "Подсказка: локальный исходящий IP VPS будет заменён выбранным вами IP warp; если у VPS нет такого локального исходящего IP, будет сгенерирован другой IP warp"
echo
green "1. Установить/переключить wgcf-warp single-stack IPV4 (по умолчанию Enter)"
green "2. Установить/переключить wgcf-warp single-stack IPV6"
green "3. Установить/переключить wgcf-warp dual-stack IPV4+IPV6"
readp "\nВыберите:" wgcfwarp
if [ -z "${wgcfwarp}" ] || [ $wgcfwarp == "1" ];then
WGCFv4
elif [ $wgcfwarp == "2" ];then
WGCFv6
elif [ $wgcfwarp == "3" ];then
WGCFv4v6
else 
red "Ошибка ввода, пожалуйста, выберите снова" && warpinscha
fi
echo
}  

changewarp(){
cwg && ONEWARPGO
}

start_menu(){
ShowWGCF;ShowSOCKS5
clear
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"           
echo -e "${bblue} ░██     ░██      ░██ ██ ██         ░█${plain}█   ░██     ░██   ░██     ░█${red}█   ░██${plain}  "
echo -e "${bblue}  ░██   ░██      ░██    ░░██${plain}        ░██  ░██      ░██  ░██${red}      ░██  ░██${plain}   "
echo -e "${bblue}   ░██ ░██      ░██ ${plain}                ░██ ██        ░██ █${red}█        ░██ ██  ${plain}   "
echo -e "${bblue}     ░██        ░${plain}██    ░██ ██       ░██ ██        ░█${red}█ ██        ░██ ██  ${plain}  "
echo -e "${bblue}     ░██ ${plain}        ░██    ░░██        ░██ ░██       ░${red}██ ░██       ░██ ░██ ${plain}  "
echo -e "${bblue}     ░█${plain}█          ░██ ██ ██         ░██  ░░${red}██     ░██  ░░██     ░██  ░░██ ${plain}  "
echo
white "Проект Yongge на Github ：github.com/yonggekkk"
white "Блог Yongge на Blogger ：ygkkk.blogspot.com"
white "Канал Yongge на YouTube ：www.youtube.com/@ygkkk"
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yellow " Выберите подходящий для себя вариант реализации warp (пункты 1, 2, 3; можно выбрать один или несколько одновременно)"
yellow " Быстрый вход в скрипт：cf"
white " ================================================================="
green "  1. Вариант 1: установить/переключить WGCF-WARP"
green "  2. Вариант 2: установить Socks5-WARP"
green "  3. Вариант 3: сгенерировать файл конфигурации и QR-код WARP-Wireguard"
green "  4. Удалить WARP"
white " -----------------------------------------------------------------"
green "  5. Выключить, включить/перезапустить WARP"
green "  6. Другие опции WARP"
green "  7. Обновить/переключить три типа аккаунтов WARP"
green "  8. Обновить установочный скрипт CFwarp" 
green "  9. Заменить текущее ядро WGCF-WARP на ядро WARP-GO"
green "  0. Выйти из скрипта "
red "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cfwarpshow
red "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
white " Информация о системе VPS:"
white " Операционная система: $(blue "$op") \c" && white " Версия ядра: $(blue "$version") \c" && white " Архитектура CPU : $(blue "$cpu") \c" && white " Тип виртуализации: $(blue "$vi")"
WGCFmenu
S5menu
echo
readp " Введите номер:" Input
case "$Input" in     
 1 ) warpinscha;;
 2 ) [[ $cpu = amd64 ]] && SOCKS5ins || exit;;
 3 ) WGproxy;;
 4 ) WARPun;;
 5 ) WARPonoff;;
 6 ) WARPtools;;
 7 ) WARPup;;
 8 ) UPwpyg;;
 9 ) changewarp;;
 * ) exit 
esac
}

if [ $# == 0 ]; then
cpujg
start_menu
fi
}

checkyl(){
if [ ! -f warp_update ]; then
green "Первый запуск скрипта CFwarp-yg, устанавливаются необходимые зависимости…… пожалуйста, подождите"
if [[ $release = Centos && ${vsid} =~ 8 ]]; then
cd /etc/yum.repos.d/ && mkdir backup && mv *repo backup/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e "s|mirrors.cloud.aliyuncs.com|mirrors.aliyun.com|g " /etc/yum.repos.d/CentOS-*
sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
yum clean all && yum makecache
cd
fi
if [ -x "$(command -v apt-get)" ]; then
apt update -y && apt install curl wget -y
elif [ -x "$(command -v yum)" ]; then
yum update && yum install epel-release -y && yum install curl wget -y
elif [ -x "$(command -v dnf)" ]; then
dnf update -y && dnf install curl wget -y
fi
if [ -x "$(command -v yum)" ] || [ -x "$(command -v dnf)" ]; then
if ! command -v "cronie" &> /dev/null; then
if [ -x "$(command -v yum)" ]; then
yum install -y cronie
elif [ -x "$(command -v dnf)" ]; then
dnf install -y cronie
fi
fi
fi
touch warp_update
tun
fi
}

warpyl(){
packages=("curl" "openssl" "bc" "python3" "screen" "qrencode" "wget")
inspackages=("curl" "openssl" "bc" "python3" "screen" "qrencode" "wget")
for i in "${!packages[@]}"; do
package="${packages[$i]}"
inspackage="${inspackages[$i]}"
if ! command -v "$package" &> /dev/null; then
if [ -x "$(command -v apt-get)" ]; then
apt-get install -y "$inspackage"
elif [ -x "$(command -v yum)" ]; then
yum install -y "$inspackage"
elif [ -x "$(command -v dnf)" ]; then
dnf install -y "$inspackage"
fi
fi
done
}

startCFwarp(){
checkyl
clear
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"           
echo -e "${bblue} ░██     ░██      ░██ ██ ██         ░█${plain}█   ░██     ░██   ░██     ░█${red}█   ░██${plain}  "
echo -e "${bblue}  ░██   ░██      ░██    ░░██${plain}        ░██  ░██      ░██  ░██${red}      ░██  ░██${plain}   "
echo -e "${bblue}   ░██ ░██      ░██ ${plain}                ░██ ██        ░██ █${red}█        ░██ ██  ${plain}   "
echo -e "${bblue}     ░██        ░${plain}██    ░██ ██       ░██ ██        ░█${red}█ ██        ░██ ██  ${plain}  "
echo -e "${bblue}     ░██ ${plain}        ░██    ░░██        ░██ ░██       ░${red}██ ░██       ░██ ░██ ${plain}  "
echo -e "${bblue}     ░█${plain}█          ░██ ██ ██         ░██  ░░${red}██     ░██  ░░██     ░██  ░░██ ${plain}  "
echo
white "Проект Yongge на Github ：github.com/yonggekkk"
white "Блог Yongge на Blogger ：ygkkk.blogspot.com"
white "Канал Yongge на YouTube ：www.youtube.com/@ygkkk"
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo
yellow "Подождите 5 секунд, выполняется проверка разблокировки Netflix и ChatGPT"
echo
echo
v4v6
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
if [[ -n $v6 ]]; then
nonf=$(curl -s6 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
nf6;chatgpt6;checkgpt
v6Status=$(white "IPV6-адрес：\c" ; blue "$v6   $nonf" ; white " Netflix： \c" ; blue "$NF" ; white " ChatGPT： \c" ; blue "$chat")
else
v6Status=$(white "IPV6-адрес：\c" ; red "IPV6-адрес отсутствует")
fi
if [[ -n $v4 ]]; then
nonf=$(curl -s4 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
nf4;chatgpt4;checkgpt
v4Status=$(white "IPV4-адрес：\c" ; blue "$v4   $nonf" ; white " Netflix： \c" ; blue "$NF" ; white " ChatGPT： \c" ; blue "$chat")
else
v4Status=$(white "IPV4-адрес：\c" ; red "IPV4-адрес отсутствует")
fi
echo "-----------------------------------------------------------------------"
white " ${v4Status}"
echo "-----------------------------------------------------------------------"
white " ${v6Status}"
echo "-----------------------------------------------------------------------"
echo
yellow "Выше показаны только результаты проверки разблокировки для локального IP, проверка разблокировки для маршрутизации WARP не выполняется"
echo
echo
white "=================================================================="
yellow " Инструкция по использованию warp-скрипта:"
yellow " 1. Безлимитная генерация конфигурации WARP-Wireguard (пункт 1)"
yellow " Можно использовать для смены исходящего аккаунта WARP-Wireguard в прокси-скриптах или для создания собственного узла"
echo
yellow " 2. Установка WARP-скрипта (пункты 2 и 3)"
yellow " Назначение: есть шанс глобально разблокировать Netflix и ChatGPT"
yellow " Подсказка: если вы используете прокси-скрипт с поддержкой исходящего трафика через WARP, дополнительно устанавливать warp-скрипт не рекомендуется"
yellow " Подсказка: можно выбирать wgcf или warp-go, устанавливайте то, что устанавливается"
echo "-------------------------------------------------------------------"
green " 1. Сгенерировать и извлечь файл конфигурации и QR-код узла WARP-Wireguard"
green " 2. Выбрать вариант wgcf и перейти в меню установки WARP"
green " 3. Выбрать вариант warp-go и перейти в меню установки WARP"
green " 0. Выйти из скрипта"
white "=================================================================="
echo
readp " Введите номер【0-3】:" Input
case "$Input" in
 1 ) WGproxy;;
 2 ) warpyl && ONEWGCFWARP;;
 3 ) warpyl && ONEWARPGO;;
 * ) exit
esac
}
if [ $# == 0 ]; then
if [[ -n $(type -P warp-go) && -z $(type -P wg-quick) ]] && [[ -f '/usr/bin/cf' ]]; then
ONEWARPGO
elif [[ -n $(type -P warp-go) && -n $(type -P warp-cli) && -z $(type -P wg-quick) ]] && [[ -f '/usr/bin/cf' ]]; then
ONEWARPGO
elif [[ -z $(type -P warp-go) && -z $(type -P wg-quick) && -n $(type -P warp-cli) ]] && [[ -f '/usr/bin/cf' ]]; then
ONEWARPGO
elif [[ -n $(type -P wg-quick) && -z $(type -P warp-go) ]] && [[ -f '/usr/bin/cf' ]]; then
ONEWGCFWARP
elif [[ -n $(type -P wg-quick) && -n $(type -P warp-cli) && -z $(type -P warp-go) ]] && [[ -f '/usr/bin/cf' ]]; then
ONEWGCFWARP
else
startCFwarp
fi
fi
