package kubernetes.non_root

violations contains "o pod deve definir runAsNonRoot=true" if {
	object.get(input.spec.template.spec, "securityContext", {}).runAsNonRoot != true
}
