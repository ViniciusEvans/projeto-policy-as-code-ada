package kubernetes.non_root_test

import data.kubernetes.non_root

valid := {"spec": {"template": {"spec": {"securityContext": {"runAsNonRoot": true}}}}}
invalid := {"spec": {"template": {"spec": {"securityContext": {"runAsNonRoot": false}}}}}

test_non_root_valid if count(non_root.violations with input as valid) == 0
test_non_root_invalid if count(non_root.violations with input as invalid) == 1
