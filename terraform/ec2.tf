########################################################
# EKS Node Template
########################################################
resource "aws_launch_template" "launch_template" {
  name                   = "eks-node-launch-template"
  vpc_security_group_ids = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      iops        = 3000
      throughput  = 125
      volume_size = 80
      volume_type = "gp3"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "optional"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                             = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-name" = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name                             = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-name" = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name                             = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-name" = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name                             = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-name" = var.eks_node_group_name
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }
}