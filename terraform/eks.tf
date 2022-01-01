########################################################
# EKS Cluster
########################################################
resource "aws_eks_cluster" "eks_cluster" {
  name     = "private-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids = [
      aws_subnet.public[0].id,
      aws_subnet.public[1].id,
      aws_subnet.public[2].id,
      aws_subnet.private[0].id,
      aws_subnet.private[1].id,
      aws_subnet.private[2].id,
    ]
  }
}
resource "aws_security_group" "eks_cluster" {
  name        = "eks-private-cluster-sg"
  description = "eks-private-cluster-sg"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_iam_role" "eks_cluster" {
  name = "eks-private-cluster-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_iam_assume.json
}
data "aws_iam_policy_document" "eks_cluster_iam_assume" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

########################################################
# EKS Node Group
########################################################
resource "aws_eks_node_group" "eks_node_group" {
  ami_type        = "AL2_x86_64"
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_node_group.arn

  instance_types = ["t3.medium"]
  labels = {
    "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.eks_cluster.name
    "alpha.eksctl.io/nodegroup-name" = var.eks_node_group_name
  }

  launch_template {
    version = 1
    id      = aws_launch_template.launch_template.id
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
    aws_subnet.private[2].id,
  ]

  tags = {
    "alpha.eksctl.io/nodegroup-name" = var.eks_node_group_name
    "alpha.eksctl.io/nodegroup-type" = "managed"
  }
}
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
  assume_role_policy = data.aws_iam_policy_document.eks_node_group_iam_assume.json
}
data "aws_iam_policy_document" "eks_node_group_iam_assume" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}
