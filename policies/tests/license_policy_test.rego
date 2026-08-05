package supply.license_test

import data.supply.license

allowed := {
	"components": [
		{
			"name": "lib-ok",
			"licenses": [
				{
					"license": {
						"id": "MIT",
					},
				},
			],
		},
	],
}

denied := {
	"components": [
		{
			"name": "lib-bad",
			"licenses": [
				{
					"license": {
						"id": "AGPL-3.0-only",
					},
				},
			],
		},
	],
}

test_allowed_license if {
	result := license.violations with input as allowed
	count(result) == 0
}

test_denied_license if {
	result := license.violations with input as denied
	count(result) == 1
}
