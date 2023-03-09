from urllib import request, parse
import urllib
import os
import json
import base64
import boto3
import uuid
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr
import random
import ast

tableName = os.environ['STORAGE_ZEROEXPIRATIONSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tableUserData = dynamodb.Table(tableName)

def handler(event, context):
    print('received event:')
    print(event)
    #print(event['body'])
    if 'GET' in event['httpMethod']:
        print(list(event['queryStringParameters'].keys())[list(event['queryStringParameters'].values()).index('')])
        response = getUserInfo(list(event['queryStringParameters'].keys())[list(event['queryStringParameters'].values()).index('')])
        if len(response['Items']):
            response['Items'][0]['warningDays'] = int(response['Items'][0]['warningDays'])
        print(response)
    if 'POST' in event['httpMethod']:
        body = json.loads(event['body'])
        if body['notifications'] == 'true':
            notifications = True 
        else:
            notifications = False
        response = addUserInfo(body['userId'], body['email'], body['sortType'], int(body['warningDays']), notifications, ast.literal_eval(body['categories']), ast.literal_eval(body['storage']))
    if 'PUT' in event['httpMethod']:
        body = json.loads(event['body'])
        if body['notifications'] == 'true':
            notifications = True 
        else:
            notifications = False
        response = updateUserInfo(body['userId'], body['email'], body['sortType'], int(body['warningDays']), notifications, ast.literal_eval(body['categories']), ast.literal_eval(body['storage']))
 

  
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(response)
    }

def addUserInfo(userId, email, sortType, warningDays, notifications, categories, storage):
    response = tableUserData.put_item(
        Item={
            'userId': userId,
            'email': email,
            'sortType': sortType,
            'warningDays': warningDays,
            'notifications': notifications,
            'categories': categories,
            'storage': storage
        }
    )
    return response

def updateUserInfo(userId, email, sortType, warningDays, notifications, categories, storage):
    response = tableUserData.delete_item(
        Key={
            'userId': userId,
        }
    )
    response = tableUserData.put_item(
        Item={
            'userId': userId,
            'email': email,
            'sortType': sortType,
            'warningDays': warningDays,
            'notifications': notifications,
            'categories': categories,
            'storage': storage
        }
    )
    return response

def getUserInfo(userId):
    response = tableUserData.query(KeyConditionExpression=Key('userId').eq(userId))
    return response

