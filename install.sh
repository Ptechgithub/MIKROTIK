#!/bin/bash

detect_distribution() {
    # Detect the Linux distribution
    local supported_distributions=("ubuntu" "debian" "centos" "fedora")
    
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "${ID}" = "ubuntu" || "${ID}" = "debian" || "${ID}" = "centos" || "${ID}" = "fedora" ]]; then
            PM="apt-get"
            [ "${ID}" = "centos" ] && PM="yum"
            [ "${ID}" = "fedora" ] && PM="dnf"
        else
            echo "Unsupported distribution!"
            exit 1
        fi
    else
        echo "Unsupported distribution!"
        exit 1
    fi
}

check_dependencies() {
    detect_distribution

    local dependencies=("wget" "curl" "p7zip-full" "coreutils" "unzip")
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            echo "${dep} is not installed. Installing..."
            sudo "$PM" update -y
            sudo "${PM}" install "${dep}" -y
        fi
    done
}

# install chr_image
install_chr_image() {
    check_dependencies
    
    ROOT_PARTITION=$(sudo mount | grep 'on / type' | awk '{ print $1 }' | sed 's/[0-9]*$//')
    # Download and install CHR image on disk
    sudo wget https://download.mikrotik.com/routeros/7.15.2/chr-7.15.2.img.zip -O chr.img.zip
    unzip chr.img.zip -d chr.img
    echo 1 > /proc/sys/kernel/sysrq
    echo u > /proc/sysrq-trigger
    dd if=chr.img/chr-7.15.2.img bs=1024 of="$ROOT_PARTITION"
    sync
    echo s > /proc/sysrq-trigger
    sleep 5
    echo "sync disk please wait..."
    echo b > /proc/sysrq-trigger
    echo "Installed, rebooting..."
}

# check docker
check_and_install_docker() {
    check_dependencies
    if ! command -v docker &> /dev/null; then
        echo "Installing docker..."
        # Docker is not installed, so install it
        sudo "${PM}" update -y
        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "Docker is already installed."
    fi
}

# Function to check if MikroTik container is already running
is_mikrotik_installed() {
    if docker ps -a --format "{{.Names}}" | grep -q "livekadeh_com_mikrotik7_7"; then
        echo "MikroTik is installed."
    else
        echo "MikroTik is not installed."
        install_mikrotik_docker
    fi
}

# install MikroTik
install_mikrotik_docker() {
    check_dependencies

    # Check if the Docker image file exists, and if not, download it
    if [ ! -f "Docker-image-Mikrotik-7.7-L6.7z" ]; then
        wget https://github.com/Ptechgithub/MIKROTIK/releases/download/L6/Docker-image-Mikrotik-7.7-L6.7z
    fi
    
    7z e Docker-image-Mikrotik-7.7-L6.7z
    docker load --input mikrotik7.7_docker_livekadeh.com
    # Ask the user if they want to add additional ports
    read -p "Do you want to add additional ports to the MikroTik container? (y/n): " add_ports

    if [ "$add_ports" == "y" ]; then
        # Ask the user to enter a range of additional ports
        read -p "Enter the starting port: " start_port
        read -p "Enter the ending port: " end_port
        
        # Create a string to hold the port mappings
        port_mappings=""
        for ((port=start_port; port<=end_port; port++)); do
            # Skip ports 80 and 8291
            if [[ "$port" == "80" || "$port" == "8291" ]]; then
                continue
            fi
            port_mappings+=" -p $port:$port"
        done

        # Run the MikroTik container with all the port mappings
        docker run --restart unless-stopped --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291 -p 80:80 $port_mappings -ti livekadeh_com_mikrotik7_7
        docker attach livekadeh_com_mikrotik7_7
    else
        # If the user does not want to add additional ports, use the original docker run command
        docker run --restart unless-stopped --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291 -p 80:80 -ti livekadeh_com_mikrotik7_7
        docker attach livekadeh_com_mikrotik7_7
    fi
}

# MikroTik and docker installation function
install_mikrotik() {
    check_and_install_docker
    is_mikrotik_installed
}

uninstall_mikrotik() {
    # Stop and remove the MikroTik container if it exists
    if docker ps -a --format "{{.Names}}" | grep -q "livekadeh_com_mikrotik7_7"; then
        docker stop livekadeh_com_mikrotik7_7
        docker rm livekadeh_com_mikrotik7_7
        echo "MikroTik container has been stopped and removed."
    else
        echo "MikroTik container is not found."
    fi

    # Remove the Docker image if it exists
    if docker images -a | grep -q "livekadeh_com_mikrotik7_7"; then
        docker rmi livekadeh_com_mikrotik7_7
        echo "MikroTik Docker image has been removed."
    else
        echo "MikroTik Docker image is not found."
    fi
}

# Function to display the menu
menu() {
    clear
    echo "By --> Peyman * Github.com/Ptechgithub * "
    echo ""
    echo "-------MikroTik Installer-------"
    echo "Select an option:"
    echo "1) Install MikroTik CHR"
    echo "----------------------------"
    echo "2) Install MikroTik via Docker"
    echo "3) Uninstall MikroTik via Docker"
    echo "----------------------------"
    echo "0) Exit"
}
menu
read -p "Enter your choice: " choice

case $choice in
    1)
        install_chr_image
        ;;
    2)
        install_mikrotik
        ;;
    3)
        uninstall_mikrotik
      ;;
    0)
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
