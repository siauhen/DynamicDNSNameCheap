#!/bin/bash

# Check if all three parameters are provided
if [ $# -ne 3 ]; then
    logger -t dynamic_dns_update "Usage: $0 <host> <domain> <password>"
    exit 1
fi

# Assign parameters to variables
host="$1"
domain="$2"
password="$3"
publicip=$(curl -s icanhazip.com)

# Construct the domain to compare
comparedomain="$host.$domain"

# Perform nslookup to resolve the IP address of comparedomain
lookupip=$(dig +short "$comparedomain")

if [ "$lookupip" = "$publicip" ]; then
     logger -t dynamic_dns_update "The IP address from nslookup matches the current external IP address."
    	exit 0 
else
    # API endpoint
    api_url="https://dynamicdns.park-your-domain.com/update?host=$host&domain=$domain&password=$password&ip=$publicip"

    # Send GET request
    response=$(curl -s "$api_url")

    # Validate response
    if [[ "$response" == *"success"* ]]; then
        logger -t dynamic_dns_update "Dynamic DNS update successful"
        exit 0
    elif [[ "$response" == *"error"* ]]; then
        logger -t dynamic_dns_update "Dynamic DNS update failed. Error message: $response"
        exit 1
    else
        logger -t dynamic_dns_update "Unexpected response from API: $response"
        exit 1
    fi
fi

