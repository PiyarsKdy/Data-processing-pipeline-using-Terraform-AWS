import boto3
import time

def lambda_handler(event, context):
    athena_client = boto3.client('athena')
    query = """
    CREATE TABLE ctas_table WITH (
        format = 'PARQUET',
        external_location = 's3://piyars-bucket/ctas_table2/'
    ) AS
    SELECT * FROM "tier2-table"
    """
    response = athena_client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={
            'Database': 'piyars-db'
        },
        ResultConfiguration={
            'OutputLocation': 's3://piyars-bucket/query/'
        }
    )
    query_execution_id = response['QueryExecutionId']
    while True:
        query_status = athena_client.get_query_execution(QueryExecutionId=query_execution_id)['QueryExecution']['Status']['State']
        if query_status == 'SUCCEEDED':
            print("Query execution succeeded!")
            break
        elif query_status == 'FAILED':
            print("Query execution failed!")
            break
        else:
            print(f"Query is still running... Current status: {query_status}")
            time.sleep(5)

    return {
        'statusCode': 200,
        'body': 'Lambda function executed successfully'
    }
