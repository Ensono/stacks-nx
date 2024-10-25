@(
  @{
    displayName = "Deployment"
    template = "deploy/common/app/k8s-manifest/deployment.yaml"
    vars = @{
      k8s_image = "`${DOCKER_REGISTRY}/`${DOCKER_IMAGE_NAME}:`${DOCKER_IMAGE_TAG}"
    }
  }
  @{
    displayName = "Ingress"
    template = "deploy/common/app/k8s-manifest/ingress.yaml"
    vars = @{
      host = "`${ENV_NAME}-`${DOMAIN}.`${DNS_BASE_DOMAIN}"
    }
  }
  @{
    displayName = "Namespace"
    template = "deploy/common/app/k8s-manifest/namespace.yaml"
    vars = @{}
  }
  @{
    displayName = "Service"
    template = "deploy/common/app/k8s-manifest/service.yaml"
    vars = @{}
  }
)
