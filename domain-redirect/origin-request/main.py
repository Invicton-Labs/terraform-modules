import json
import random
from os import environ


def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    redirect_url = ${redirect_path == null ? "request['uri']": "${redirect_path}"}
    response = {
        'status': '${redirect_code}',
        'statusDescription': '${redirect_description}',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': request['origin']['custom']['protocol'] + '://${redirect_domain}' + redirect_url
            }]
        }
    }
    return response
