#!/bin/bash

# Function to display the menu
display_menu() {
    clear  # Clear the screen
    echo "Select an option:"
    echo "1) Install MikroTik"
    echo "2) Uninstall MikroTik"
    echo "0) Exit"
}

# Function to check if MikroTik container is already running
is_mikrotik_installed() {
    if docker ps -a --format '{{.Names}}' | grep -q "^livekadeh_com_mikrotik7_7$"; then
        return 0  # MikroTik is already installed
    else
        return 1  # MikroTik is not installed
    fi
}

# Function to install MikroTik
install_mikrotik() {
    if is_mikrotik_installed; then
        echo "MikroTik is already installed."
    else
        # Update packages
        sudo apt-get update -y

        # Check if Docker is installed
        if ! command -v docker &> /dev/null; then
            # Docker is not installed, so install it
            sudo apt-get update -y
            echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
            sudo apt-get install curl -y
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo systemctl start docker
            sudo systemctl enable docker
        fi

        # Check if the Docker image file exists, and if not, download it
        if [ ! -f "Docker-image-Mikrotik-7.7-L6.7z" ]; then
            wget https://mirdehghan.ir/dl/Docker-image-Mikrotik-7.7-L6.7z
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
            docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 22:22 -p 8291:8291 -p 80:80 $port_mappings -ti livekadeh_com_mikrotik7_7
            docker attach livekadeh_com_mikrotik7_7
        else
            # If the user does not want to add additional ports, use the original docker run command
            docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 22:22 -p 8291:8291 -p 80:80 -ti livekadeh_com_mikrotik7_7
            docker attach livekadeh_com_mikrotik7_7
        fi
    fi
}

# Function to uninstall MikroTik
uninstall_mikrotik() {
    if is_mikrotik_installed; then
        # Check if the container is running
        if docker ps | grep -q livekadeh_com_mikrotik7_7; then
            docker stop livekadeh_com_mikrotik7_7
        fi
        docker rm livekadeh_com_mikrotik7_7
        docker rmi livekadeh_com_mikrotik7_7
        rm mikrotik7.7_docker_livekadeh.com
        echo "MikroTik has been uninstalled."
    else
        echo "MikroTik is not installed."
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
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac