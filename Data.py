import os

class Data(object):
    def __init__(self):
        self.resp = ''
    @staticmethod
    def data(filePath):
        text = textract.process(filePath)
        return text
