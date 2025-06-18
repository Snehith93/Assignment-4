output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API."
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig" {
  description = "The kubeconfig file to connect to the EKS cluster."
  sensitive   = true
  value = yamlencode({
    apiVersion      = "v1"
    clusters = [
      {
        cluster = {
          server                   = aws_eks_cluster.eks_cluster.endpoint
          certificate-authority-data = aws_eks_cluster.eks_cluster.certificate_authority[0].data
        }
        name = "kubernetes"
      }
    ]
    contexts = [
      {
        context = {
          cluster = "kubernetes"
          user    = "aws"
        }
        name = "aws"
      }
    ]
    current-context = "aws"
    kind            = "Config"
    users = [
      {
        name = "aws"
        user = {
          exec = {
            apiVersion = "client.authentication.k8s.io/v1beta1"
            args = [
              "get-token",
              "--cluster-name",
              var.cluster_name,
            ]
            command = "aws"
            env = [
              {
                name  = "AWS_REGION"
                value = var.aws_region
              }
            ]
          }
        }
      }
    ]
  })
}