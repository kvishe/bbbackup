#!/bin/bash
work_dir=/home/ec2-user/bbbackup

mount -a
cfg_file=$work_dir/bbbackup.cfg
backup_path=`cat $cfg_file |grep "filepath =" |cut -d= -f2 |tr -d ' '`
backup_dir=BACKUP_`date --date="-1 day" +%Y%m%d`_UTC
new_backup_dir=BACKUP_`date +%Y%m%d`_UTC
archive_retaintion=7

if [ -d $backup_path/$new_backup_dir/ ];then
    cd $backup_path/$new_backup_dir
    for i in `ls |grep DONE |awk -F '.DONE' '{print $1}'`;
    do
        echo $i
        cd $i
        hub sync
        cd ..
    done
    bash $work_dir/bbbackup.sh

elif [ -d $backup_path/$backup_dir/ ];then
    cd $backup_path
    tar -czf $backup_dir.tar.gz $backup_dir
    [ -e BACKUP_`date --date="-$archive_retaintion day" +%Y%m%d`_UTC.tar.gz ] && rm -f BACKUP_`date --date="-$archive_retaintion day" +%Y%m%d`_UTC.tar.gz

    mv $backup_dir $new_backup_dir
    cd $new_backup_dir
    for i in `ls |grep DONE |awk -F '.DONE' '{print $1}'`;
    do
        echo $i
        cd $i
        hub sync
        cd ..
    done
    bash $work_dir/bbbackup.sh
else
    bash $work_dir/bbbackup.sh
fi