get_uptime() {
    boot=$(sysctl -n kern.boottime)
    boot=${boot/\{ sec = }
    boot=${boot/,*}

    # Get current date in seconds.
    now=$(date +%s)
    s=$((now - boot))

    d="$((s / 60 / 60 / 24)) days"
    h="$((s / 60 / 60 % 24)) hours"
    m="$((s / 60 % 60)) minutes"

    # Remove plural if < 2.
    ((${d/ *} == 1)) && d=${d/s}
    ((${h/ *} == 1)) && h=${h/s}
    ((${m/ *} == 1)) && m=${m/s}

    # Hide empty fields.
    ((${d/ *} == 0)) && unset d
    ((${h/ *} == 0)) && unset h
    ((${m/ *} == 0)) && unset m

    uptime=${d:+$d, }${h:+$h, }$m
    uptime=${uptime%', '}
    uptime=${uptime:-$s seconds}

    echo $uptime
}

get_memory() {
    mem_total="$(($(sysctl -n hw.memsize) / 1024 / 1024))"
    mem_wired="$(vm_stat | awk '/ wired/ { print $4 }')"
    mem_active="$(vm_stat | awk '/ active/ { printf $3 }')"
    mem_compressed="$(vm_stat | awk '/ occupied/ { printf $5 }')"
    mem_compressed="${mem_compressed:-0}"
    mem_used="$(((${mem_wired//.} + ${mem_active//.} + ${mem_compressed//.}) * 4 / 1024))"

    echo ${mem_used}${mem_label:-MiB} / ${mem_total}${mem_label:-MiB} ${mem_perc:+(${mem_perc}%)}
}

get_battery() {
    battery="$(pmset -g batt | grep -o '[0-9]*%')"

    if [[ "${#battery}" -gt 3 ]] ; then
        battery="$battery | tr -d '%'"
    fi

    if pmset -g batt | grep AC &> /dev/null; then
        battery="$battery (charging)"
    else
        battery="$battery ($(pmset -g batt | grep -o '[0-9]:[0-9]* remaining'))"
    fi

    echo $battery
}

# Uptime
get_uptime

# Memory
get_memory

# Battery
get_battery

# Date
date +'%a %d. %b'

# Local ip
ifconfig en0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'

# Router ip
netstat -rn | grep default | grep en0 | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]'

# Wifi name
/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | awk -F' SSID: '  '/ SSID: / {print $2}'
