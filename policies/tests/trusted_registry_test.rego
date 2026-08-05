package kubernetes.trusted_registry_test

import data.kubernetes.trusted_registry

valid := {"spec": {"template": {"spec": {"containers": [{"name": "api", "image": "ghcr.io/SEU_USUARIO_GITHUB/api-pagamentos@sha256:abc"}]}}}}
invalid := {"spec": {"template": {"spec": {"containers": [{"name": "api", "image": "docker.io/library/python:latest"}]}}}}

test_registry_valid if count(trusted_registry.violations with input as valid) == 0
test_registry_invalid if count(trusted_registry.violations with input as invalid) == 1
