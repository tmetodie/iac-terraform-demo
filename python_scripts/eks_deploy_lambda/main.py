import os
import boto3
from kubernetes import client, config
from kubernetes.config.kube_config import KubeConfigLoader
from kubernetes.client.rest import ApiException
from pprint import pprint

eks = boto3.client('eks')
s3 = boto3.client('s3')
cluster_name = os.environ["CLUSTER_NAME"]

def build_eks_kubeconfig():
    cluster = eks.describe_cluster(name=cluster_name)
    cluster_cert = cluster["cluster"]["certificateAuthority"]["data"]
    cluster_ep = cluster["cluster"]["endpoint"]

    cluster_config = {
        "apiVersion": "v1",
        "kind": "Config",
        "clusters": [
            {
                "cluster": {
                    "server": str(cluster_ep),
                    "certificate-authority-data": str(cluster_cert)
                },
                "name": "kubernetes"
            }
        ],
        "contexts": [
            {
                "context": {
                    "cluster": "kubernetes",
                    "user": "aws"
                },
                "name": "aws"
            }
        ],
        "current-context": "aws",
        "preferences": {},
        "users": [
            {
                "name": "aws",
                "user": {
                    "exec": {
                        "apiVersion": "client.authentication.k8s.io/v1alpha1",
                        "command": "aws",
                        "args": [
                            "eks", "get-token", "--cluster-name", cluster_name
                        ]
                    }
                }
            }
        ]
    }
    
    return cluster_config

get_ecr_tag():

    s3.download_file('BUCKET_NAME', 'OBJECT_NAME', 'FILE_NAME')

def patch_deployment():
    try:
        api_response = api_instance.patch_namespaced_deployment(name, namespace, body, pretty=pretty)
        pprint(api_response)
    except ApiException as e:
        print("Exception when calling AppsV1Api->patch_namespaced_deployment: %s\n" % e)

def handler(event, context):
    print(event)
    eks_kubeconfig = build_eks_kubeconfig()
    print(eks_kubeconfig)
    k8s_config = yaml.safe_load(yaml.dump(eks_kubeconfig, default_flow_style=False))
    config = KubeConfigLoader(
        config_dict=k8s_config,
        config_base_path=None)
    kube_config.load_kube_config(client_configuration=config)

    coreApi = client.AppsV1Api()

    ecr_event_data = event["CodePipeline.job"]["data"]["inputArtifacts"]