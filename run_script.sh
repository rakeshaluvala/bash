#! /bin/bash
sudo docker update --restart unless-stopped $(docker ps -q)
