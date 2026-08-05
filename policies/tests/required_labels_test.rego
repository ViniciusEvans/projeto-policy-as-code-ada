package kubernetes.required_labels_test

import data.kubernetes.required_labels

valid := {
	"metadata": {
		"labels": {
			"app": "api",
			"owner": "time",
			"environment": "test",
			"version": "1",
		},
	},
}

invalid := {
	"metadata": {
		"labels": {
			"app": "api",
		},
	},
}

test_valid_labels if {
	result := required_labels.violations with input as valid
	count(result) == 0
}

test_invalid_labels if {
	result := required_labels.violations with input as invalid
	count(result) == 1
}
