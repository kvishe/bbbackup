import boto3
import time
instanceid = "i-08c9e55c1d460ca4c"
ec2 = boto3.client("ec2")
ssm = boto3.client("ssm")

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=[instanceid])
    waiter = ec2.get_waiter("instance_running")
    waiter.wait(InstanceIds=[instanceid])
    print("Instance " + instanceid + " is started and running")
    time.sleep(60)
    
    response = ssm.send_command(
        InstanceIds = [instanceid],
        DocumentName = "AWS-RunShellScript",
        Parameters = {
            "commands": ["/home/ec2-user/bbbackup/bbsync.sh"]
        },
    )
    command_id = response["Command"]["CommandId"]
    time.sleep(10)
    output = ssm.get_command_invocation(CommandId=command_id, InstanceId=instanceid)
    print(output)
    
