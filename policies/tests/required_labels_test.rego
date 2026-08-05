package kubernetes.required_labels_test

import data.kubernetes.required_labels

valid := {"metadata": {"labels": {"app": "api", "owner": "time", "environment": "test", "version": "1"}}}
invalid := {"metadata": {"labels": {"app": "api"}}}

test_valid_labels if count(required_labels.violations with input as valid) == 0
test_invalid_labels if count(required_labels.violations with input as invalid) == 1
