#!/bin/bash
work_dir=/home/ec2-user/bbbackup

if [ $# -eq 0 ];then
        echo "Please provide repo name which need to be restored"
        exit
fi

restore_repo=$1
cfg_file=$work_dir/bbbackup.cfg
username=`cat $cfg_file |grep "userid =" |cut -d= -f2 |tr -d ' '`
password=`cat $cfg_file |grep "password =" |cut -d= -f2 |tr -d ' '`
backup_path=`cat $cfg_file |grep "filepath =" |cut -d= -f2 |tr -d ' '`
neworigin="git@bitbucket.org:$username/$restore_repo-restored"
backup_dir=BACKUP_`date +%Y%m%d`_UTC

if [ ! -d $backup_path/$backup_dir/ ];then
        backup_dir=BACKUP_`date --date="-1 day" +%Y%m%d`_UTC
fi

if [ -d $backup_path/$backup_dir/$restore_repo ];then
        cd $backup_path/$backup_dir/$restore_repo
        echo "Creating new blank repo $restore_repo-restored on Bitbucket cloud"
        response=`curl -X POST -u $username:$password "https://api.bitbucket.org/2.0/repositories/$username/$restore_repo-restored" -H "Content-Type: application/json" -d '{"is_private": true}' -sw ",%{http_code}"|grep -o '[^,]*$'`

        if [ $response -eq 200 ];then
                echo "Checking out all branches locally"
                for i in `git branch -r | cut -d/ -f2 |grep -v HEAD`;
                do
                        git checkout $i
                done
                echo "Pushing all branches and tags to new repo $restore_repo-restored"
                git push --all $neworigin
                if [ $? -eq 0 ];then
                        git push --tag $neworigin
                        echo "Success - The $restore_repo restored successfully and pushed to $restore_repo-restored"
                else
                        echo "Error - Not able to push the code to new repo $restore_repo-restored"
                fi
        else
                echo "Error - Not able to create new repo $restore_repo-restored on bitbucket cloud, please check the name of repo or your priviledges on bitbucket cloud to create the repo"
        fi
else
        echo "Given repo is not found in the backup please check the repo name."
fi

shutdown -h
