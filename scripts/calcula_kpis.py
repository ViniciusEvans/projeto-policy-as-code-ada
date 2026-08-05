from __future__ import annotations

import csv
import json
import sys
from pathlib import Path


def percentage(value: int, total: int) -> float:
    return round((value / total * 100), 2) if total else 0.0


report = Path(sys.argv[1] if len(sys.argv) > 1 else "relatorios/exemplo/conformidade.csv")
with report.open(encoding="utf-8", newline="") as file:
    rows = list(csv.DictReader(file))

total = len(rows)
signed = sum(row.get("assinatura") == "sim" for row in rows)
provenance = sum(row.get("provenance") == "sim" for row in rows)
conformant = sum(row.get("status") == "conforme" for row in rows)

kpis = {
    "releases_totais": total,
    "releases_assinadas_percentual": percentage(signed, total),
    "releases_com_provenance_percentual": percentage(provenance, total),
    "releases_conformes_percentual": percentage(conformant, total),
}
print(json.dumps(kpis, indent=2, ensure_ascii=False))
