import boto3 #setting up an S3 bucket to interact with get-emotions lambda function

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Read the audio data from the HTTP POST request
    audio_data = event['body']
    
    # Process the audio data as needed
    # For example, you can store the data in S3
    bucket_name = '<S3_BUCKET_NAME>'
    object_key = '<S3_OBJECT_KEY>'
    s3_client.put_object(Body=audio_data, Bucket=bucket_name, Key=object_key)
    
    # Perform additional processing or trigger actions based on the audio data
    
    return {
        'statusCode': 200,
        'body': 'Audio data received and processed successfully'
    }
