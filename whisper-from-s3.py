import boto3
import os
import openai
import json


def whisper_inference(media_file_path):
    API_KEY = '[openai_api_key]'
    model_id = 'whisper-1'

    media_file_path = '/tmp/audio.mp3'
    media_file = open(media_file_path, 'rb')

    response = openai.Audio.transcribe(
        api_key=API_KEY,
        model=model_id,
        file=media_file
    )

    responsetext = response["text"]    
    return responsetext

def lambda_handler(event, context):
    # Specify the AWS credentials and region
    aws_access_key_id = '[aws_key]'
    aws_secret_access_key = '[aws_secret]'
    aws_region = 'us-east-1'

    # Specify the bucket name and object key
    bucket_name = 'emoticonnect'
    object_key = 'audio/output/processed-audio.mp3'
    local_file_name = '/tmp/audio.mp3'  # Replace with the desired name and path

    # Create a Boto3 S3 client
    s3_client = boto3.client('s3', region_name=aws_region, aws_access_key_id=aws_access_key_id,
                             aws_secret_access_key=aws_secret_access_key)

    # Download the file from the S3 bucket
    s3_client.download_file(bucket_name, object_key, local_file_name)

    output = whisper_interface('/tmp/audio.mp3)

    # Perform further processing on the downloaded file
    # Example:
    # Process the audio file using your desired logic
    # ...

    
    return {
        'statusCode': 200,
        'output': output,
        'body': 'Processing completed successfully.'
    }        
