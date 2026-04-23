resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"
  namespace  = "aws-loadbalancer-controller"

  create_namespace = true

  set {
    name  = "clusterName"
    value = "${local.env}-${local.org}-${var.cluster-name}"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws-region
  }

  set {
    name  = "vpcId"
    value = data.aws_vpc.vpc.id
  }

  depends_on = [
    kubernetes_service_account.lb_controller
  ]
}
