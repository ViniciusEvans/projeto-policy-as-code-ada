package kubernetes.trusted_registry_test

import data.kubernetes.trusted_registry

valid := {
	"spec": {
		"template": {
			"spec": {
				"containers": [
					{
						"name": "api",
						"image": "ghcr.io/ViniciusEvans/projeto-policy-as-code-ada@sha256:abc",
					},
				],
			},
		},
	},
}

invalid := {
	"spec": {
		"template": {
			"spec": {
				"containers": [
					{
						"name": "api",
						"image": "docker.io/library/python:latest",
					},
				],
			},
		},
	},
}

test_registry_valid if {
	result := trusted_registry.violations with input as valid
	count(result) == 0
}

test_registry_invalid if {
	result := trusted_registry.violations with input as invalid
	count(result) == 1
}
