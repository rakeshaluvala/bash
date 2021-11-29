#!/bin/bash
pem_file="/c/Users/rakh0/Jobiak/keys/jobusa-test-env-key.pem"
for i in `cat ip.txt`;
do
        ip=$i
        echo $ip
        #scp -i "P1P2P3.pem" mkdir_store.sh rm_marketing_tool.sh extract_marketing_tool.sh ubuntu@"$ip":/home/ubuntu
        ssh -o "StrictHostKeyChecking no" -i $pem_file ubuntu@"$ip" " sudo apt-get install -y docker.io;sudo service docker start;sudo systemctl start docker;sudo systemctl enable docker;sudo docker run -d --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter:latest --path.rootfs=/host;sleep 5;exit;"
scp -i $pem_file -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null "/c/Users/rakh0/Jobiak/workspace/bash/run_script.sh" ubuntu@$ip:/home/ubuntu
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null  -i $pem_file ubuntu@$ip sudo chmod 777 /var/run/docker.sock
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i $pem_file ubuntu@$ip chmod 755 /home/ubuntu/run_script.sh
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i $pem_file ubuntu@$ip /home/ubuntu/run_script.sh
echo "completed $i"
done
echo "Total Servers $s"
cnt=$(cat ip.txt | wc -l)
