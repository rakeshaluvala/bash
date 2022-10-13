#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
aws_profile='default devops-automation-hotcareers Jobiakllc-251025265681'
cur_date=$(date +%Y-%m-%d)
cur_month=$(date +%m)
cur_day=$(date +%d)

echo "current month and year is $cur_month"
echo "$cur_date"
if [[ cur_day -ge 01 ]];
then
        start_date=$(date +'%Y-%m-01')
        echo "$start_date"

for profile in $aws_profile;do
        aws ce get-cost-and-usage --time-period Start=$start_date,End="$cur_date"  --granularity=MONTHLY --metrics=BlendedCost --profile $profile|grep Amount|awk '{print $2}'|tr -d '",'|sed 's/\.[^[:blank:]]*//'>$profile-cost
done

p1p2p3=$(cat '/home/ec2-user/scripts/costbyaccount/default-cost')
hotcareers=$(cat '/home/ec2-user/scripts/costbyaccount/devops-automation-hotcareers-cost')
jobiakllc=$(cat '/home/ec2-user/scripts/costbyaccount/Jobiakllc-251025265681-cost')
#emailcount=$(cat '/home/ec2-user/scripts/costbyaccount/emailcount')

total=$(($p1p2p3+$hotcareers+$jobiakllc ))
echo "Total cost of allaccounts excludes medichire is $total exceeded the value of 27000">/home/ec2-user/scripts/costbyaccount/coststatus
if [[ $total -lt 27000 ]]
then
        echo "0">/home/ec2-user/scripts/costbyaccount/emailcount
elif [[ `cat /home/ec2-user/scripts/costbyaccount/emailcount` -eq 0 ]]
then
        aws sns publish --topic-arn "arn:aws:sns:us-east-2:206760334398:AWS-Cost" --message file:///home/ec2-user/scripts/costbyaccount/coststatus --region us-east-2
        echo "1">/home/ec2-user/scripts/costbyaccount/emailcount
else
        echo "Ignoring the script"
fi
fi
