#!/bin/bash
report_loc=/home/ec2-user/snapshot/ins_snap_out.txt
cat /dev/null > $report_loc
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
aws_profile="default devops-automation-hotcareers Jobiakllc-251025265681 Medichire-446628487863 MedichireNew-436211673009"
region="us-east-1 us-east-2 eu-central-1"
cur_date=$(date +%Y-%m-%d)

for profile in $aws_profile;do
for reg in $region;do
#volumeids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[?!contains(Tags[].Key,  'aws:ec2launchtemplate:id')]"  --output json --profile $profile --region $reg |grep VolumeId|awk '{print $2}'|tr -d \")
volumeids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[?InstanceLifecycle!=`spot`]' --output json --profile $profile --region $reg|grep VolumeId|awk '{print $2}'|tr -d '""')
echo "Instance name and created snapshot for profile=$profile and region=$reg for $cur_date">>$report_loc
for vol in $volumeids;do
inst_name=$(aws ec2 describe-instances --filters "Name=block-device-mapping.volume-id,Values=$vol" --query "Reservations[*].Instances[?!contains(Tags[].Key,  'aws:ec2launchtemplate:id')][].[Tags[?Key=='Name'].Value]"  --output text --profile $profile --region $reg)
snap_name=$(aws ec2 describe-snapshots --filters Name=volume-id,Values=$vol --query "Snapshots[?(StartTime>='$cur_date')].[SnapshotId]" --profile $profile --region $reg|grep snap|tr -d \"|tr -d ' ')
echo "$inst_name=$snap_name"
echo "$inst_name=$snap_name">>$report_loc
done
echo "---------------------------------------------">>$report_loc
done
done
aws sns publish --topic-arn "arn:aws:sns:us-east-2:206760334398:snapshot-creation-report" --message file://$report_loc --region us-east-2
