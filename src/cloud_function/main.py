# Cloud Functinosのソースファイル
from google.cloud import pubsub_v1
import subprocess
import requests
import json
import os
import time

# get the access token for the API call
def get_access_token():

    # scope of the API access. Limit it to just cloud platform services
    scopes='https://www.googleapis.com/auth/cloud-platform'
    headers={'Metadata-Flavor': 'Google'}

    # build api with the scopes 
    api="http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token?scopes=" + scopes

    # make api call for the access token
    r = requests.get(api,headers=headers).json()

    #return the access token
    return r['access_token']

# make API calls
def run_job(data, context):

    # get environmental variables set in the inital configuraiton. assign them as local variables. 
    PROJECT_ID=os.environ.get('PROJECT_ID', 'Specified environment variable is not set.')
    # TOPIC_ID=os.environ.get('TOPIC_ID', 'Specified environment variable is not set.')
    PIPELINE_NAME=os.environ.get('PIPELINE_NAME', 'Specified environment variable is not set.')
    INSTANCE_ID=os.environ.get('INSTANCE_ID', 'Specified environment variable is not set.')
    REGION=os.environ.get('REGION', 'Specified environment variable is not set.')
    NAMESPACE_ID=os.environ.get('NAMESPACE_ID', 'Specified environment variable is not set.')
    CDAP_ENDPOINT=os.environ.get('CDAP_ENDPOINT', 'Specified environment variable is not set.')

    # get uploaded file name
    default_file_name = data['name']
    
    # gcs bucket were the file resides
    bucket_name = data['bucket']
    
    # setup pubsub client to send the data fusion job metadata
    # publisher = pubsub_v1.PublisherClient()
    # topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)
    
    # assign access token to local var by calling the definition
    auth_token=get_access_token()
    
    # assemble the api call
    post_endpoint = CDAP_ENDPOINT + "/v3/namespaces/" + NAMESPACE_ID + "/apps/" + PIPELINE_NAME + "/workflows/DataPipelineWorkflow/start"
    
    # If the pipeline has any macros that need to be set, you can pass them in with the API call as a data payload 
    data = "{'my-file':'" + default_file_name +"'}"
    
    # add bearer token to the header
    post_headers = {"Authorization": "Bearer " + auth_token,"Accept": "application/json"}
    
    # start the job
    r1 = requests.post(post_endpoint,data=data,headers=post_headers)
    # time.sleep(10)

    # # get the job run_id
    # get_endpoint = CDAP_ENDPOINT + "/v3/namespaces/" + NAMESPACE_ID + "/apps/" + PIPELINE_NAME + "/workflows/DataPipelineWorkflow/runs"
    # get_headers = {"Authorization": "Bearer " + auth_token,"Content-Type": "application/json"}
    
    # # get the status
    # r2 = requests.get(get_endpoint,headers=get_headers)
    
    # # get the status response json
    # status = r2.json()

    # # parse status record for the job that is 'starting'
    # running_job = [x for x in status if x['status'] == 'STARTING']
    
    # # extract the runid
    # job=running_job[0]
    
    # # publish job details to pubsub
    # pubsub_msg = json.dumps(job).encode('utf-8')
    # published_msg = publisher.publish(topic_path, data=pubsub_msg)