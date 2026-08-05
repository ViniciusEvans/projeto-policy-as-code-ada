package kubernetes.required_labels

required_labels := {"app", "owner", "environment", "version"}

violations contains msg if {
  provided := {label | input.metadata.labels[label]}
  missing := required_labels - provided
  count(missing) > 0
  msg := sprintf("labels obrigatorias ausentes: %v", [missing])
}
