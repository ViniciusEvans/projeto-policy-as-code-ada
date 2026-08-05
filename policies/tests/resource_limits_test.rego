package kubernetes.resource_limits_test

import data.kubernetes.resource_limits

valid := {
	"spec": {
		"template": {
			"spec": {
				"containers": [
					{
						"name": "api",
						"resources": {
							"requests": {
								"cpu": "100m",
								"memory": "128Mi",
							},
							"limits": {
								"cpu": "500m",
								"memory": "256Mi",
							},
						},
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
						"resources": {},
					},
				],
			},
		},
	},
}

test_resources_valid if {
	result := resource_limits.violations with input as valid
	count(result) == 0
}

test_resources_invalid if {
	result := resource_limits.violations with input as invalid
	count(result) == 4
}
