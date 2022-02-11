#!/bin/bash
work_dir=/home/ec2-user/bbbackup

# activate virtual environment for bitbucket backup script
cd $work_dir
source BitBucketBackup/bin/activate

# execute backup script to do a backup to the defined folder (see bbbackup.cfg which folder and which config the app will run with)
python bbbackup.py --configuration bbbackup.cfg --backup --notify

#stopping the instance
shutdown -h