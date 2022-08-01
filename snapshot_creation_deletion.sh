#!/bin/bash
aws_profile="default devops-automation-hotcareers Jobiakllc-251025265681 Medichire-446628487863 MedichireNew-436211673009"
region="us-east-1 us-east-2 eu-central-1"
cur_date=$(date +%Y-%m-%d)
past_date=$(date --date="-5 days" +%Y-%m-%d)
snap_loc=/home/ec2-user/snapshot/snapshots.txt

for profile in $aws_profile;do
for reg in $region;do
#volumeids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[?!contains(Tags[].Key,  'aws:ec2launchtemplate:id')]"  --output json --profile $profile --region $reg |grep VolumeId|awk '{print $2}'|tr -d \")
volumeids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[?InstanceLifecycle!=`spot`]' --output json --profile $profile --region $reg|grep VolumeId|awk '{print $2}'|tr -d '""')
for vol in $volumeids;do
ins_id=$(aws ec2 describe-volumes   --volume-ids $vol --profile $profile --region $reg|grep InstanceId |awk '{print$2}'| sed 's/\"//g'|sed 's/\,//g')
snap_name=$vol-$ins_id-$cur_date
echo snap_name=$snap_name
echo "Creating snapshots for $vol"
volume_snap=$(aws ec2 create-snapshot --volume-id $vol --description "$snap_name" --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value='$snap_name'}]' --profile $profile --region $reg)
echo "Deleting snapshot 3 days before snapshot for volume $vol"
aws ec2 describe-snapshots --filters Name=volume-id,Values=$vol --query 'Snapshots[?StartTime <= `'$past_date'`].{id:SnapshotId}' --output text --profile $profile --region $reg >  $snap_loc
for d in `cat $snap_loc`;do
echo "deleting snapshot $d"
sleep 2
aws ec2 delete-snapshot --snapshot-id $d  --profile $profile --region $reg
done
done
echo "---------------------------------------------"
done
done
