provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "angular-iam-service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_role_attachment" {
    name       = "angular-iam-service_attachment"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    roles      = [aws_iam_role.ecs_execution_role.name]
}


# resource "aws_iam_service_linked_role" "IAMServiceLinkedRole1" {
#     custom_suffix = "ecs"
#     aws_service_name = "ecs.amazonaws.com"
#     description = "Role to enable Amazon ECS to manage your cluster."
# }

resource "aws_ecs_cluster" "ECSCluster" {
    name = "angular-ecs-cluster"
}

resource "aws_ecs_service" "ECSService" {
    name = "angular-app-service"
    cluster = aws_ecs_cluster.ECSCluster.id
    load_balancer {
        target_group_arn = aws_lb_target_group.ElasticLoadBalancingV2TargetGroup.arn
        container_name = "angular-app-container"
        container_port = 80
    }
    desired_count = 1
    #platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.ECSTaskDefinition.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    #iam_role = aws_iam_service_linked_role.IAMServiceLinkedRole1.arn
    network_configuration {
        #assign_public_ip = false
        security_groups = [
            "sg-031e977658cb09320"
        ]
        subnets = [
            "subnet-0c25555eeac59dd0e",
            "subnet-028c28c57bc7c4de9",
            "subnet-0425a7dbc129b4594",
            "subnet-01999fc1eaa60c3f2",
            "subnet-079239977aee736c5",
            "subnet-064c38c4d29be712a"
        ]
    }
    health_check_grace_period_seconds = 0
    scheduling_strategy = "REPLICA"
}

resource "aws_ecs_task_definition" "ECSTaskDefinition" {
    container_definitions = jsonencode([
    {
        name  = "angular-app-container"
        image = "377653006175.dkr.ecr.us-east-1.amazonaws.com/angular-node:v4"  # Replace with your image name
        portMappings = [
            {
                containerPort = 80
                hostPort      = 80
            },
        ]
    },
    ])
    family = "angular-app"
    task_role_arn = aws_iam_role.ecs_execution_role.arn
    execution_role_arn = aws_iam_role.ecs_execution_role.arn
    network_mode = "awsvpc"
    requires_compatibilities = [
        "FARGATE"
    ]
    cpu = "1024"
    memory = "3072"
}


resource "aws_lb" "ElasticLoadBalancingV2LoadBalancer" {
    name = "angular-lb"
    internal = false
    load_balancer_type = "application"
    subnets = [
        "subnet-01999fc1eaa60c3f2",
        "subnet-028c28c57bc7c4de9",
        "subnet-0425a7dbc129b4594",
        "subnet-064c38c4d29be712a",
        "subnet-079239977aee736c5",
        "subnet-0c25555eeac59dd0e"
    ]
    security_groups = [
        "sg-031e977658cb09320"
    ]
    ip_address_type = "ipv4"
    access_logs {
        enabled = false
        bucket = ""
        prefix = ""
    }
    idle_timeout = "60"
    enable_deletion_protection = "false"
    enable_http2 = "true"
    enable_cross_zone_load_balancing = "true"
}

resource "aws_lb_listener" "ElasticLoadBalancingV2Listener" {
    load_balancer_arn = aws_lb.ElasticLoadBalancingV2LoadBalancer.arn
    port = 80
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_lb_target_group.ElasticLoadBalancingV2TargetGroup.arn
        type = "forward"
    }
}

resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup" {
    health_check {
        interval = 30
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealthy_threshold = 2
        healthy_threshold = 5
        matcher = "200"
    }
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "vpc-09944f1f6835d0fb8"
    name = "angular-tg"
}
