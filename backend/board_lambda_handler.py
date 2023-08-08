import json
import boto3
from decimal import Decimal

# DynamoDB 테이블의 이름과 파티션 키를 지정합니다.
partition_key = 'boardId'
boardList = 'BoardList'
indiviBoard = 'IndiviBoard'
commentTable = 'Comment'

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

# ================ Board CRUD & Get Board Data ================
def lambda_handler(event, context):
    
    method = event["Method"]
    # 게시글 생성
    if method == "CreateBoard":
        db_access = DatabaseAccess(indiviBoard)
        items,count, boardId = db_access.get_totalData()
        print("boardId = ",boardId)
        createBoard(boardId=boardId, event=event)
    
    # 게시글 리스트 Get
    elif method == "GetBoardList":
        db_access = DatabaseAccess(boardList)
        items,count, boardId = db_access.get_totalData()
        # Decimal 타입을 float 타입으로 변환
        items = convert_decimal_to_float(items)
        print(items)
        return {
                'statusCode': 200,
                'body': json.dumps(items, ensure_ascii=False).encode("UTF-8")
            }
    
    # 개별 게시글 Get
    elif method == "GetIndiviBoard":
        db_access = DatabaseAccess(indiviBoard)
        items = readBoardData(event)
        print(items)
    
    # 게시글 수정
    elif method == "ModifyBoard":
        db_access = DatabaseAccess(indiviBoard)
        modifyBoard(event)
    
    # 게시글 삭제
    elif method == "DeleteBoard":
        deleteBoard(event)
    
    return {
        'statusCode': 200,
        'body': "Success"
    }

def createBoard(boardId, event):
    table_name = indiviBoard

    dynamodb = boto3.client('dynamodb')

    addboardId = int(boardId)+1
    rate = int(rate)

    item = {
        'boardId': {'N': str(addboardId)},
        'userId': {'S': userId},
        'image': {'S': image},
        'boardContent': {'S': boardContent},
        'boardTitle': {'S': boardTitle},
        'boardCategory': {'S': boardCategory},
        'rate': {'N': str(rate)}
    }

    dynamodb.put_item(TableName=table_name, Item=item)
    return 'Data saved successfully!'

def readBoardData(event):
    table_name = indiviBoard

    dynamodb = boto3.client('dynamodb')

    response = dynamodb.get_item(
        TableName=table_name,
        Key={
            'boardId': {'N': str(event["boardId"])},
            'userId': {'S': event["userId"]}
        }
    )

    item = response.get('Item', {})
    converted_item = convert_dynamodb_item(item)
    
    return converted_item
    
    return item

def modifyBoard(event):
    table_name = indiviBoard

    dynamodb = boto3.client('dynamodb')

    dynamodb.update_item(
        TableName=table_name,
        Key={
            'boardId': {'N': str(event["boardId"])},
            'userId': {'S': event["userId"]}
        },
        UpdateExpression='SET image = :image, boardContent = :boardContent, boardTitle = :boardTitle, boardCategory = :boardCategory, #rt = :rate',
        ExpressionAttributeNames={'#rt': 'rate'},
        ExpressionAttributeValues={
            ':image': {'SS': event["image"]},
            ':boardContent': {'S': event["boardContent"]},
            ':boardTitle': {'S': event["boardTitle"]},
            ':boardCategory': {'S': event["boardCategory"]},
            ':rate': {'N': str(event["rate"])}
        }
    )
    return 'Data saved successfully!'

def deleteBoard(event):
    table_name = indiviBoard 

    dynamodb = boto3.client('dynamodb')

    response = dynamodb.delete_item(
        TableName=table_name,
        Key={
            'boardId': {'N': str(event["boardId"])},
            'userId': {'S': event["userId"]}
        }
    )

    return 'Data deleted successfully!'

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

def convert_dynamodb_item(item):
    converted_item = {}
    for key, value in item.items():
        data_type = list(value.keys())[0]
        if data_type == 'N':
            converted_item[key] = int(value[data_type])
        elif data_type == 'S':
            converted_item[key] = value[data_type]
    return converted_item