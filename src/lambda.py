import json
import boto3
def lambda_handler(event, context):
    client = boto3.client('glue')
    client.start_job_run(
        JobName = 'piyars-glue',
        Arguments = {}
        )
    print("lambda called")
    return {
        'statusCode': 200,
        'body': json.dumps('Glue job run successfully. ')
    }