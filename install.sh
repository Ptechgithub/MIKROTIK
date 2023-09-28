#!/bin/bash

# Function to check if MikroTik container is already running
is_mikrotik_installed() {
    if docker ps -a --format "{{.Names}}" | grep -q "livekadeh_com_mikrotik7_7"; then
        echo "MikroTik is installed."
    else
        echo "MikroTik is not installed."
        install_mikrotik_docker
    fi
}

check_and_install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Installing docker..."
        # Docker is not installed, so install it
        sudo apt-get update -y
        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        sudo apt-get install curl -y
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "Docker is already installed."
    fi
}

# MikroTik and docker installation function
install_mikrotik() {
    check_and_install_docker
    is_mikrotik_installed
}

# install MikroTik
install_mikrotik_docker() {
    # Update packages
    sudo apt-get update -y

    # Check if the Docker image file exists, and if not, download it
    if [ ! -f "Docker-image-Mikrotik-7.7-L6.7z" ]; then
        wget https://github.com/Ptechgithub/MIKROTIK/releases/download/L6/Docker-image-Mikrotik-7.7-L6.7z
    fi

    # Ask the user if they want to add additional ports
    read -p "Do you want to add additional ports to the MikroTik container? (y/n): " add_ports

    if [ "$add_ports" == "y" ]; then
        # Ask the user to enter a comma-separated list of additional ports
        read -p "Enter a comma-separated list of additional ports (example: 443,2087,9543 ): " additional_ports
        sudo apt-get install p7zip-full
        7z e Docker-image-Mikrotik-7.7-L6.7z
        docker load --input mikrotik7.7_docker_livekadeh.com

        # Split the comma-separated ports into an array
        IFS=',' read -ra ports_array <<< "$additional_ports"

        # Create a string to hold the port mappings
        port_mappings=""

        # Iterate over the ports and add them to the port mappings string
        for port in "${ports_array[@]}"; do
            port_mappings+=" -p $port:$port"
        done

        # Run the MikroTik container with all the port mappings
        docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291 -p 80:80 $port_mappings -ti livekadeh_com_mikrotik7_7
        docker attach livekadeh_com_mikrotik7_7
    else
        # If the user does not want to add additional ports, use the original docker run command
        docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291 -p 80:80 -ti livekadeh_com_mikrotik7_7
        docker attach livekadeh_com_mikrotik7_7
    fi
}



# Function to display the menu
display_menu() {
    clear  # Clear the screen
    echo "Select an option:"
    echo "1) Install MikroTik"
    echo "2) Uninstall MikroTik"
    echo "0) Exit"
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

# Display the menu and read user choice
display_menu
read -p "Enter your choice: " choice

case $choice in
    1)
        install_mikrotik
        ;;
    2)
        uninstall_mikrotik
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
