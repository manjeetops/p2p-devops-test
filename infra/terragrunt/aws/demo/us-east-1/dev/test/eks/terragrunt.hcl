include {
  path = find_in_parent_folders()
}

include "eks" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_eks.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_locals  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  env_locals     = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  project_locals = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  module_locals  = try(read_terragrunt_config("module.hcl").locals, {})
  locals = merge(
    local.account_locals,
    local.region_locals,
    local.project_locals,
    local.env_locals,
    local.module_locals
  )

  // TODO: Add the below variable values
    cluster_name    = ""  // TODO: Add cluster_name
    userarn  = "arn:aws:iam::<AWS_ID>:user/<USER>"  // TODO: Add userarn
    username = "<USERNAME>" // TODO: Add username
    instance_types = ""   // TODO: Add instance_types
    capacity_type  = ""  // TODO: Add capacity_type


}

dependency "vpc" {
  config_path                             = "../vpc"

}

inputs = {
    cluster_name    = local.cluster_name
    cluster_version = "1.31"
    cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
    }
    vpc_id = dependency.vpc.outputs.vpc_id
    subnet_ids = dependency.vpc.outputs.private_subnets
    eks_create_aws_auth_configmap       = false
    eks_manage_aws_auth_configmap       = true

    aws_auth_users = [
        {
            userarn  = local.userarn
            username = local.username
            groups   = ["system:masters"]
        }
    ]
    # EKS Managed Node Group(s)
    eks_managed_node_group_defaults = {
        instance_types = [${local.instance_types}]
    }
    eks_managed_node_groups = {
        example = {  //node-group name
        min_size     = 1
        max_size     = 1
        desired_size = 1
        instance_types = [${local.instance_types}] 
        capacity_type  = ${local.capacity_type}
        }
    }

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_code}"
  }
}
