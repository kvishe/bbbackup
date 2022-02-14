import boto3
import time
import os
instanceid = os.environ['InstanceID'] 
ec2 = boto3.client("ec2")
ssm = boto3.client("ssm")

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=[instanceid])
    waiter = ec2.get_waiter("instance_running")
    waiter.wait(InstanceIds=[instanceid])
    print("Instance " + instanceid + " is started and running")
    time.sleep(60)
    repo_name = event["repo_name"]
    
    response = ssm.send_command(
        InstanceIds = [instanceid],
        DocumentName = "AWS-RunShellScript",
        Parameters = {
            "commands": ["/home/ec2-user/bbbackup/bbrestore.sh " + repo_name ]
        },
    )
    command_id = response["Command"]["CommandId"]
    time.sleep(30)
    output = ssm.get_command_invocation(CommandId=command_id, InstanceId=instanceid)
    print(output)
    
