package kubernetes.resource_limits

violations contains msg if {
	container := input.spec.template.spec.containers[_]
	resources := object.get(container, "resources", {})
	requests := object.get(resources, "requests", {})
	limits := object.get(resources, "limits", {})
	not requests.cpu
	msg := sprintf("container %s sem request de cpu", [container.name])
}

violations contains msg if {
	container := input.spec.template.spec.containers[_]
	resources := object.get(container, "resources", {})
	requests := object.get(resources, "requests", {})
	not requests.memory
	msg := sprintf("container %s sem request de memoria", [container.name])
}

violations contains msg if {
	container := input.spec.template.spec.containers[_]
	resources := object.get(container, "resources", {})
	limits := object.get(resources, "limits", {})
	not limits.cpu
	msg := sprintf("container %s sem limit de cpu", [container.name])
}

violations contains msg if {
	container := input.spec.template.spec.containers[_]
	resources := object.get(container, "resources", {})
	limits := object.get(resources, "limits", {})
	not limits.memory
	msg := sprintf("container %s sem limit de memoria", [container.name])
}
