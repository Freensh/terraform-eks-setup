resource "aws_eks_cluster" "eks" {
    count = var.is_eks_cluster_enabled == true ? 1 : 0
    name = "${var.project_name}-cluster"
    role_arn = aws_iam_role.eks-cluster-role[count.index].arn
    version = var.cluster_version

    vpc_config {
      subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
      endpoint_private_access = var.endpoint_private_access
      endpoint_public_access = var.endpoint_public_access
      security_group_ids = [aws_security_group.eks-cluster-sg.id]
    }

    access_config {
      authentication_mode = "CONFIG_MAP"
      bootstrap_cluster_creator_admin_permissions = true
    }

    tags = {
        Name = "${project_name}-cluster"
        Env = var.env
    }
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
    client_id_list = ["sts:amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks-certificate.certificates[0].shal_fingerprint]
    url = data.tls_certificate.eks-certificate.url
}

#AddOns for EKS Cluster

resource "aws_eks_addon" "eks-addons" {
    for_each = {for idx, addon in var.addons : idx => addon}
    cluster_name = aws_eks_cluster.eks[0].name
    addon_name = each.value.name
    addon_version = each.value.version

    depends_on = [ 
        aws_eks_node_group.ondemand-node,
        aws_eks_node_group.spot-node
     ]
  
}

#NodeGroups OnDemand
resource "aws_eks_node_group" "ondemand-node" {
    cluster_name = aws_eks_cluster.eks[0].name
    node_group_name = "${var.project_name}-on-demand-nodes"

    node_role_arn = aws_iam_role.eks-nodegroup-role[0].arn
    subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id, aws_subnet.private_subnet[2].id]
    instance_types = var.ondemand-instance-types
    capacity_type = "ON_DEMAND"

    scaling_config {
      desired_size = var.desired_capacity_ondemand
      min_size = var.min_capacity_ondemand
      max_size = var.max_capacity_ondemand
    }

    labels = {
        type = "ondemand"
    }

    update_config {
      max_unavailable = 1
    }

    tags = {
      Name = "${var.project_name}-ondemand-nodes"
      Env = var.env
    }
    tags_all = {
      "kubernetes.io/cluster/${var.project_name}-cluster" = "owned"
      Name = "${var.project_name}-ondemand-nodes"
      Env = var.env
    }

    depends_on = [ aws_eks_cluster.eks ]
}