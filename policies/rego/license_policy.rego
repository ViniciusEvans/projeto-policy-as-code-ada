package supply.license

denied_licenses := {"GPL-3.0-only", "AGPL-3.0-only", "SSPL-1.0"}

violations contains msg if {
  component := input.components[_]
  license := component.licenses[_].license.id
  denied_licenses[license]
  msg := sprintf("componente %s viola licenca proibida %s", [component.name, license])
}
