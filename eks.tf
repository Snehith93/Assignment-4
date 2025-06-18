resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(
      [for subnet in aws_subnet.public_subnets : subnet.id],
      [for subnet in aws_subnet.private_subnets : subnet.id]
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-worker-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [for subnet in aws_subnet.private_subnets : subnet.id]

  scaling_config {
    desired_size = var.worker_node_desired_size
    min_size     = var.worker_node_min_size
    max_size     = var.worker_node_max_size
  }

  instance_types = [var.worker_node_instance_type]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}