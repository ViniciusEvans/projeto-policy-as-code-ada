package kubernetes.trusted_registry

violations contains msg if {
  container := input.spec.template.spec.containers[_]
  not startswith(container.image, "ghcr.io/SEU_USUARIO_GITHUB/api-pagamentos@sha256:")
  msg := sprintf("imagem fora do registry autorizado ou sem digest: %s", [container.image])
}
