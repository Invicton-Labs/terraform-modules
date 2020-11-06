import boto3
import logging
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')
route53 = boto3.client('route53')

client_vpn_endpoint_id = environ.get('CLIENT_VPN_ENDPOINT_ID')
if client_vpn_endpoint_id == None:
    logger.error('Environment variable "CLIENT_VPN_ENDPOINT_ID" must be set')
    raise Exception(
        'Environment variable "CLIENT_VPN_ENDPOINT_ID" must be set')

hosted_zone_id = environ.get('HOSTED_ZONE_ID')
if hosted_zone_id == None:
    logger.error('Environment variable "HOSTED_ZONE_ID" must be set')
    raise Exception(
        'Environment variable "HOSTED_ZONE_ID" must be set')

hosted_zone_name = environ.get('HOSTED_ZONE_NAME')
if hosted_zone_name == None:
    logger.error('Environment variable "HOSTED_ZONE_NAME" must be set')
    raise Exception(
        'Environment variable "HOSTED_ZONE_NAME" must be set')


def lambda_handler(event, context):
    paginator = ec2.get_paginator('describe_client_vpn_connections')
    page_iterator = paginator.paginate(
        ClientVpnEndpointId=client_vpn_endpoint_id
    )
    connections = []
    for page in page_iterator:
        connections += page['Connections']

    clients = {}
    for connection in connections:
        # Ignore connections that aren't in active status
        if connection['Status']['Code'] != 'active':
            continue
        common_name = connection['CommonName']
        dns_name = "{}.{}.".format(common_name, hosted_zone_name).lower()
        # If a connection with this Common Name already exists, overwrite it if this one started earlier
        if dns_name in clients:
            if connection['ConnectionEstablishedTime'] < clients[dns_name]['ConnectionEstablishedTime']:
                clients[dns_name] = connection
        else:
            clients[dns_name] = connection

    logger.debug(clients)

    paginator = route53.get_paginator('list_resource_record_sets')
    page_iterator = paginator.paginate(
        HostedZoneId=hosted_zone_id
    )
    record_sets = []
    for page in page_iterator:
        record_sets += page['ResourceRecordSets']

    logger.debug(record_sets)

    # Find all existing record sets that don't have a corresponding client
    sets_to_delete = []
    for record_set in record_sets:
        if record_set['Name'] not in clients and record_set['Type'] == 'A':
            sets_to_delete.append({
                'Action': 'DELETE',
                'ResourceRecordSet': record_set
            })

    existing_clients = {record_set['Name']: record_set for record_set in record_sets}

    sets_to_upsert = []
    # Loop through all connected clients
    for dns_name in clients:
        # Every client gets an upserted record if there isn't already a record or the existing record doesn't match the IP
        if dns_name not in existing_clients or existing_clients[dns_name]['ResourceRecords'][0]['Value'] != clients[dns_name]['ClientIp']:
            sets_to_upsert.append({
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': dns_name,
                    'Type': 'A',
                    'TTL': 0,
                    'ResourceRecords': [
                        {
                            'Value': clients[dns_name]['ClientIp']
                        },
                    ]
                }
            })

    sets_to_change = sets_to_delete + sets_to_upsert

    if len(sets_to_change) > 0:
        logger.info("Changing sets: {}".format(sets_to_change))
        response = route53.change_resource_record_sets(
            HostedZoneId=hosted_zone_id,
            ChangeBatch={
                'Changes': sets_to_change
            }
        )
        logging.info(response)
