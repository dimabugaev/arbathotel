import my_utility
import json

def lambda_handler(event, context):
    """Lambda handler for running SOAP task in ECS"""
    
    # Get parameters from event
    source_id = event.get('source_id')
    datefrom = event.get('datefrom')
    dateto = event.get('dateto')
    
    if not all([source_id, datefrom, dateto]):
        return {
            'statusCode': 400,
            'body': json.dumps('Missing required parameters: source_id, datefrom, dateto')
        }
    
    try:
        # Create an ECS client
        ecs_client = my_utility.boto3.client('ecs')

        # Get ECS parameters using my_utility function
        launch_params = my_utility.get_params_to_run_ecs_task_dbt()

        # Set the container overrides
        container_overrides = [
            {
                'name': "soap-container",
                'environment': [
                    {'name': 'source_id', 'value': str(source_id)},
                    {'name': 'datefrom', 'value': datefrom},
                    {'name': 'dateto', 'value': dateto}
                ]
            },
        ]

        print(launch_params['ecs-cluster'])
        print(launch_params['ecs-soap-task-definition'])

        response = ecs_client.run_task(
            taskDefinition=launch_params['ecs-soap-task-definition'],
            cluster=launch_params['ecs-cluster'],
            launchType='FARGATE',
            overrides={'containerOverrides': container_overrides},
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': [launch_params['ecs-task-private-subnet']],
                    'securityGroups': [launch_params['ecs-task-security-group']],
                    'assignPublicIp': 'DISABLED'
                }
            }
        )
        
        # Get task ARN from response
        task_arn = response['tasks'][0]['taskArn']
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'SOAP task started successfully',
                'taskArn': task_arn,
                'parameters': {
                    'source_id': source_id,
                    'datefrom': datefrom,
                    'dateto': dateto
                }
            })
        }
        
    except Exception as error:
        print(error)
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error starting SOAP task: {str(error)}')
        } 