package kubernetes.trusted_registry

allowed_image_prefix := "ghcr.io/viniciusevans/projeto-policy-as-code-ada@sha256:"

violations contains msg if {
	container := input.spec.template.spec.containers[_]
	not startswith(lower(container.image), allowed_image_prefix)
	msg := sprintf(
		"imagem fora do registry autorizado ou sem digest: %s",
		[container.image],
	)
}
