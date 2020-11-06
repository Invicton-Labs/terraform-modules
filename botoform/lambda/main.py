import json
import subprocess
import uuid
import os

import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(event)
    responses = []
    # Loop through each script to run
    for script in event:
        # Create a unique file for the script to be temporarily stored in
        scriptpath = "/tmp/botoform-{}".format(uuid.uuid1())
        f = open(scriptpath, "x")
        # Write the code to the file
        f.write(script['code'])
        f.close()
        # Run the file as a subprocess
        logger.info("Running command: {}".format(
            "{} {}".format(script['interpreter'], scriptpath)))
        result = subprocess.run(
            "{} {}".format(script['interpreter'], scriptpath), shell=True, capture_output=True)
        logger.info("Result: {}".format(result))
        os.remove(scriptpath)
        stdout = result.stdout.decode('utf-8')
        stderr = result.stderr.decode('utf-8')
        if result.returncode != 0 and not script['allow_nonzero_exit']:
            raise subprocess.SubprocessError(
                "Command returned non-zero exit code ({}) with stdout '{}' and stderr '{}'".format(result.returncode, stdout, stderr))
        responses.append({
            'return_code': result.returncode,
            'stdout': stdout,
            'stderr': stderr
        })
    return responses
