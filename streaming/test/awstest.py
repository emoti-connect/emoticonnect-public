import json
import os
import boto3

def lambda_handler(event, context):
    if "key" in event and event["key"] == "0987654321":
        # Your existing code to process the input and generate the response
        
        # Example response data
        emotions = ["Happiness", "Sadness", "Anger", "Fear", "Neutral"]
        intensity = [0.8, 0.6, 0.9, 0.7, 0.5]
        confidence = [0.9, 0.8, 0.95, 0.85, 0.7]
        
        # Create a dictionary with the response data
        response_dict = {
            "emotions": emotions,
            "intensity": intensity,
            "confidence": confidence
        }
        
        # Convert the response dictionary to JSON
        response_json = json.dumps(response_dict)
        
        # Send the JSON response to WatchOS via SNS
        sns = boto3.client('sns')
        topic_arn = 'YOUR_SNS_TOPIC_ARN'  # Replace with your SNS topic ARN
        sns.publish(TopicArn=topic_arn, Message=response_json)
        
        return {
            'statusCode': 200,
            'body': 'Success'
        }
    else:
        return {
            'statusCode': 401,
            'body': 'Unauthorized'
        }
