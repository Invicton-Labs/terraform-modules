import boto3
import sys
from io import StringIO
import contextlib
import json


@contextlib.contextmanager
def stdoutIO(stdout=None):
    old = sys.stdout
    if stdout is None:
        stdout = StringIO()
    sys.stdout = stdout
    yield stdout
    sys.stdout = old


def lambda_handler(event, context):
    with stdoutIO() as s:
        exec(event['code'])
    return(s.getvalue())
