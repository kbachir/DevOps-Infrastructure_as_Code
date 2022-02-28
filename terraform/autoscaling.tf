resource "aws_launch_configuration" "launch-config" {
    name = "custom-launch-config"
    image_id = "ami-018197d3ec2678d3c"
    instance_type = var.instance_type
    associate_public_ip_address = true
    security_groups = [aws_security_group.open_security_group.id]
    key_name = "karim.jenkins"
    user_data = <<EOF
    #!/bin/bash
    cd /home/ubuntu/contents/app
    npm start
    EOF
}


# defining autoscaling group
resource "aws_autoscaling_group" "autoscaling_group" {
    name = "karim_terraform_autoscalinggroup"
    vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
    launch_configuration = aws_launch_configuration.launch-config.name
    min_size = 1
    max_size = 3
    desired_capacity = 1
    health_check_grace_period = 100
    health_check_type = "ELB"
    force_delete = true
    
    tag {
    key                 = "Name"
    value               = "karim_terraform_asg"
    propagate_at_launch = true
  }
}


# define autoscaling configuration policy
resource "aws_autoscaling_policy" "scale_up_policy" {
    name = "karim_scale_up"
    autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown = 60
}
# define autoscaling configuration policy
resource "aws_autoscaling_policy" "scale_down_policy" {
    name = "karim_scale_down"
    autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown = 60
}


# Cloudwatch Scale up policy
resource "aws_cloudwatch_metric_alarm" "scaleup-cpu-alarm" {
    alarm_name = "Over80ThresholdCPUAlarm"
    alarm_description = "Monitors CPU Utilization"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 2 # the number of periods over which data is compared to the specified threshol
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60" # period in seconds
    statistic = "Average"
    threshold = 80
    
    alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
    }
}
# Cloudwatch Scale down policy
resource "aws_cloudwatch_metric_alarm" "scaledown-cpu-alarm" {
    alarm_name = "Lower20ThresholdCPUAlarm"
    alarm_description = "Monitors CPU Utilization"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60" 
    statistic = "Average"
    threshold = 20
    
    alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
    }
}


# defining load balancer
resource "aws_lb" "load_balancer" {
  name = "karim-terraform-loadbalancer"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.open_security_group.id]
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]

  tags = {
      Name = "karim_terraform_loadbalancer"
  }
}

# attaching load balancer to autoscaling group
resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
    lb_target_group_arn = aws_lb_target_group.target_group.arn
}

# creating target group
resource "aws_lb_target_group" "target_group" {
    name = "karim-terraform-targetgroup"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc.id
}

# creating listener group
resource "aws_lb_listener" "listener_group" {
    port = 80
    protocol = "HTTP"
    load_balancer_arn = aws_lb.load_balancer.arn

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_group.arn
    }
}