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
import datetime

tableName = os.environ['STORAGE_ZEROEXPIRATIONSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tableUserData = dynamodb.Table(tableName)

def handler(event, context):
    print('received event:')
    print(event)

    #body = json.loads(event['body'])
    #verifyEmailIdentity(body['email'])
    #sendEmail([body['email']], body['body'], body['subject'])

    print('USER INFO: ')
    userInfo = getAllUserInfo()
    print(userInfo)

    for account in userInfo['Items']:
        emailBody1 = ""
        emailBody2 = ""
        if len(account['storage'][0]) != 0 and account['notifications']:
            if len(account['storage'][4]) != 0:
                for i in range(len(account['storage'][0])):
                    expDate = account['storage'][1][i].split("/")
                    print(expDate)
                    print(datetime.datetime(int(expDate[2]), int(expDate[0]), int(expDate[1])))
                    print(datetime.datetime.now())
                    newHour = datetime.datetime.now().hour-4
                    newDay = datetime.datetime.now().day
                    if newHour < 0:
                        newHour = newHour+24
                        newDay = newDay-1
                    print(datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, newDay, newHour, datetime.datetime.now().minute, datetime.datetime.now().second))
                    now = datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, newDay, newHour, datetime.datetime.now().minute, datetime.datetime.now().second)
                    print(datetime.datetime(int(expDate[2]), int(expDate[0]), int(expDate[1])))
                    print((datetime.datetime(int(expDate[2]), int(expDate[0]), int(expDate[1]))-now).days)
                    if (datetime.datetime(int(expDate[2]), int(expDate[0]), int(expDate[1]))-now).days < int(account['warningDays']) and account['storage'][2][i] <= '0':
                        account['storage'][2][i] = '1'
                        updateUserInfo(account['userId'], account['email'], account['sortType'], int(account['warningDays']), account['notifications'], account['categories'], ast.literal_eval(str(account['storage'])))
                    if (datetime.datetime(int(expDate[2]), int(expDate[0]), int(expDate[1]))-now).days < 0 and account['storage'][2][i] <= '2':
                        account['storage'][2][i] = '3'
                        updateUserInfo(account['userId'], account['email'], account['sortType'], int(account['warningDays']), account['notifications'], account['categories'], ast.literal_eval(str(account['storage'])))

                    if int(account['storage'][2][i]) == 1:
                        emailBody1 = emailBody1+account['storage'][0][i]+" will expire on "+account['storage'][1][i]+".\n"
                        account['storage'][2][i] = '2'
                        updateUserInfo(account['userId'], account['email'], account['sortType'], int(account['warningDays']), account['notifications'], account['categories'], ast.literal_eval(str(account['storage'])))
                    elif int(account['storage'][2][i]) == 3:
                        emailBody2 = emailBody2+account['storage'][0][i]+" has expired.\n"
                        account['storage'][2][i] = '4'
                        updateUserInfo(account['userId'], account['email'], account['sortType'], int(account['warningDays']), account['notifications'], account['categories'], ast.literal_eval(str(account['storage'])))
        if emailBody1 != "":
            sendEmail([account['email']], emailBody1, 'EXPIRATION IMMINENT!!!')
        if emailBody2 != "":
            sendEmail([account['email']], emailBody2, 'ITEM EXPIRED!!!')
        
                
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps('Hello from your new Amplify Python lambda!')
    }

def verifyEmailIdentity(varify):
    ses_client = boto3.client("ses", region_name="us-east-1")
    response = ses_client.verify_email_identity(
        EmailAddress=varify
    )
    print(response)

def sendEmail(toAddresses, body, subject):
    ses_client = boto3.client("ses", region_name="us-east-1")
    CHARSET = "UTF-8"

    response = ses_client.send_email(
        Destination={
            "ToAddresses": toAddresses,
        },
        Message={
            "Body": {
                "Text": {
                    "Charset": CHARSET,
                    "Data": body,
                }
            },
            "Subject": {
                "Charset": CHARSET,
                "Data": subject,
            },
        },
        Source="support@zeroexpiration.com",
    )
    print(response)

def getAllUserInfo():
    response = tableUserData.scan()
    data = response['Items']
    while 'LastEvaluatedKey' in response:   
        response = tableUserData.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
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