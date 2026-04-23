resource "aws_iam_policy" "lb-controller-policy" {
  name   = "${local.env}-${local.org}-alb-controller-policy"
  policy = file("iam_policy.json")
}

resource "aws_iam_role" "lb_controller_role" {
  name = "${local.env}-${local.org}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = module.eks.oidc-arn }

      Condition = {
        StringEquals = {
          "${module.eks.oidc-url}:sub" = "system:serviceaccount:aws-loadbalancer-controller:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb-controller-policy.arn
}

resource "kubernetes_namespace" "aws_lb_ns" {
  metadata {
    name = "aws-loadbalancer-controller"
  }
}


# Create the service account
resource "kubernetes_service_account" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "aws-loadbalancer-controller"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.alb_attach,
    kubernetes_namespace.aws_lb_ns
  ]
}