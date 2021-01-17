from Dependencies import *
from Data import *
import os
def handler(event, context): 
    print(event, context)
    filePath = event["key"]
    extractData = Data.data(filePath)

    return {'response':extractData}

# print(handler('ok','ok'))