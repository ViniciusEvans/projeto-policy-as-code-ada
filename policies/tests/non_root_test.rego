package kubernetes.non_root_test

import data.kubernetes.non_root

valid := {
	"spec": {
		"template": {
			"spec": {
				"securityContext": {
					"runAsNonRoot": true,
				},
			},
		},
	},
}

invalid := {
	"spec": {
		"template": {
			"spec": {
				"securityContext": {
					"runAsNonRoot": false,
				},
			},
		},
	},
}

test_non_root_valid if {
	result := non_root.violations with input as valid
	count(result) == 0
}

test_non_root_invalid if {
	result := non_root.violations with input as invalid
	count(result) == 1
}
