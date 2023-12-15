import my_utility
import json

def lambda_handler(event, context):
    try:
        # Create an ECS client
        ecs_client = my_utility.boto3.client('ecs')

        # Extract ecs_task_definition_name from ecs_task_definition_arn using a regular expression
        #match = re.search(r'task-definition/(.+):(\d+)', ECS_TASK_DEFINITION_ARN)
        #ecs_task_definition_name = match.group(1) + ':' + match.group(2)

        #logger.info("Setting container environment variables")
        #snowflake_credentials = get_snowflake_credentials()

        launch_params = my_utility.get_params_to_run_ecs_task_dbt()

        # Set the container overrides
        container_overrides = [
            {
                'name': "dbt-container",
                'environment': [
                    {'name': 'DBT_POSTGRES_HOST', 'value': launch_params['host']},
                    {'name': 'DBT_POSTGRES_PORT', 'value': launch_params['port']},
                    {'name': 'DBT_POSTGRES_USER', 'value': launch_params['username']},
                    {'name': 'DBT_POSTGRES_PASS', 'value': launch_params['password']},
                    {'name': 'DBT_POSTGRES_DBNAME', 'value': launch_params['dbname']},
                    {'name': 'DBT_TRANSFORM_MODE', 'value': 'booking-problems-mart-update'}
                ]
            },
        ]

        #logger.info("Submitting task to ECS")

        print(launch_params['ecs-cluster'])
        print(launch_params['ecs-dbt-task-definition'])

        response = ecs_client.run_task(
            taskDefinition=launch_params['ecs-dbt-task-definition'],
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
        #logger.info(f"Task successfully submitted to ECS. Task arn: {response['tasks'][0]['taskArn']}")
    except Exception as error:
        print(error)
        #logger.error(traceback.format_exc())