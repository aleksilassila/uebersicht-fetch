get_os() {
    IFS=$'\n' read -d "" -ra sw_vers <<< "$(awk -F'<|>' '/key|string/ {print $3}' \
                        "/System/Library/CoreServices/SystemVersion.plist")"
    for ((i=0;i<${#sw_vers[@]};i+=2)) {
        case ${sw_vers[i]} in
            ProductName)          darwin_name=${sw_vers[i+1]} ;;
            ProductVersion)       osx_version=${sw_vers[i+1]} ;;
            ProductBuildVersion)  osx_build=${sw_vers[i+1]}   ;;
        esac
    }

    case $osx_version in
        10.4*)  codename="Mac OS X Tiger" ;;
        10.5*)  codename="Mac OS X Leopard" ;;
        10.6*)  codename="Mac OS X Snow Leopard" ;;
        10.7*)  codename="Mac OS X Lion" ;;
        10.8*)  codename="OS X Mountain Lion" ;;
        10.9*)  codename="OS X Mavericks" ;;
        10.10*) codename="OS X Yosemite" ;;
        10.11*) codename="OS X El Capitan" ;;
        10.12*) codename="macOS Sierra" ;;
        10.13*) codename="macOS High Sierra" ;;
        10.14*) codename="macOS Mojave" ;;
        10.15*) codename="macOS Catalina" ;;
        10.16*) codename="macOS Big Sur" ;;
        11.0*)  codename="macOS Big Sur" ;;
        *)      codename=macOS ;;
    esac

    arch_name="$(uname -m)"
    if [ "${arch_name}" = "x86_64" ]; then
        if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
            arch="arm64 (Rosetta 2)"
        else
            arch="x86_64 (Native)"
        fi 
    elif [ "${arch_name}" = "arm64" ]; then
        arch="arm64"
    else
        arch="Unknown Arch: ${arch_name}"
    fi

    distro="$codename $osx_version $osx_build $arch"
    echo $distro
}

get_gpu() {
    gpu="$(system_profiler SPDisplaysDataType |\
           awk -F': ' '/^\ *Chipset Model:/ {printf $2 ", "}')"
    gpu="${gpu//\/ \$}"
    gpu="${gpu%,*}"

    echo $gpu
}


# Hostname
echo $(whoami)@$(hostname)

# Get OS
get_os

# Get model
sysctl -n hw.model

# Kernel
echo Darwin $(uname -r)

# CPU
sysctl -n machdep.cpu.brand_string

# GPU
get_gpu

# Mac
ifconfig en0 | grep -w ether | awk '{ print $2 }'