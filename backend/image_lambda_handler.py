import json
import boto3
from decimal import Decimal
from urllib.parse import unquote_plus

# DynamoDB 테이블의 이름과 파티션 키를 지정합니다.
partition_key = 'boardId'
boardList = 'BoardList'
indiviBoard = 'IndiviBoard'
commentTable = 'Comment'
bucketName = 'reviewapp-team-project-test'

# ================ DataBase Access ================
class DatabaseAccess():
    def __init__(self, table_name):
        # DynamoDB 세팅
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def get_totalData(self):
        res = self.table.scan()
        items = res['Items']  # 모든 item
        count = res['Count']  # item 개수
        print("items = ", items)
        convertItems = convert_decimal_to_int(items)
        print("convertItems = ", convertItems)
    
        # items 리스트가 비어있으면, 즉 테이블에 데이터가 없으면 초기값 0으로 설정
        if not convertItems:
            boardId = 0
        else:
            # items 리스트가 비어있지 않으면, boardId 값을 정수로 변환하고 가장 큰 값을 구함
            boardId = max(int(item['boardId']) for item in convertItems)
        return items, count, boardId

    def put_data(self, input_data):
        self.table.put_item(
            Item =  input_data
        )
        print("Putting data is completed!")
# ================ DataBase Access ================

def lambda_handler(event, context):
    try:
        # 이벤트에서 멀티파트 데이터 추출
        content_type = event['headers']['Content-Type']
        if content_type.startswith('multipart/form-data'):
            boundary = content_type.split('; ')[1].split('=')[1]
            body = event['body']
            body_decoded = unquote_plus(body)
            files = body_decoded.split(f'--{boundary}')
            image_list = [file for file in files if 'filename' in file]
        else:
            body = json.loads(event["body"])
            image_list = body['imageList']

        body_json = event["body-json"]
        method = body_json["Method"]
        
        if method == "sendImagesToS3":
            return sendImagesToS3(body, image_list)
        else:
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid method'),
            }
    except KeyError:
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid request body'),
        }

def sendImagesToS3(event, image_list):
    s3 = boto3.resource('s3')
    bucket_name = bucketName  
    
    db_access = DatabaseAccess(indiviBoard)
    items, count, boardId = db_access.get_totalData()
    boardId = int(boardId)

    image_urls = []

    for idx, file_data in enumerate(image_list):
        image_data = file_data.encode('utf-8')
        file_name = f"{boardId+1}_{event['userId']}_{idx+1}.png"
        bucket_key = f"images/{file_name}"

        s3.Bucket(bucket_name).put_object(Key=bucket_key, Body=image_data)

        image_url = f"https://{bucket_name}.s3.amazonaws.com/{bucket_key}"
        image_urls.append(image_url)

    return {
        'statusCode': 200,
        'body': json.dumps(image_urls),
    }

def convert_decimal_to_float(data):
    if isinstance(data, list):
        return [convert_decimal_to_float(item) for item in data]
    elif isinstance(data, dict):
        return {key: convert_decimal_to_float(value) if key != 'boardId' else value for key, value in data.items()}
    elif isinstance(data, Decimal):
        return float(data)
    else:
        return data

def convert_decimal_to_int(data):
    if isinstance(data, list):
        return [convert_decimal_to_int(item) for item in data]
    elif isinstance(data, dict):
        return {key: convert_decimal_to_int(value) if key != 'boardId' else value for key, value in data.items()}
    elif isinstance(data, Decimal):
        return int(data)
    else:
        return data