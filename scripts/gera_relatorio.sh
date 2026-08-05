#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_REPOSITORY:?Defina GITHUB_REPOSITORY, por exemplo usuario/api-pagamentos}"
MES="${1:-$(date +%Y-%m)}"
IMAGE="ghcr.io/${GITHUB_REPOSITORY,,}"
IDENTITY_REGEX="^https://github.com/${GITHUB_REPOSITORY}/.github/workflows/release.yml@refs/tags/v.*$"
OUT="relatorios/${MES}"
REPORT="${OUT}/conformidade.csv"
mkdir -p "$OUT"
printf '%s\n' 'release,publicada_em,digest,assinatura,provenance,status' > "$REPORT"

gh release list --limit 100 --json tagName,publishedAt \
  | jq --arg mes "$MES" '[.[] | select(.publishedAt | startswith($mes))]' > "${OUT}/releases.json"

jq -r '.[] | [.tagName, .publishedAt] | @tsv' "${OUT}/releases.json" \
  | while IFS=$'\t' read -r tag published_at; do
      digest="$(docker buildx imagetools inspect "$IMAGE:$tag" --format '{{json .Manifest.Digest}}' | tr -d '"')"
      if cosign verify "$IMAGE@$digest" \
          --certificate-identity-regexp "$IDENTITY_REGEX" \
          --certificate-oidc-issuer "https://token.actions.githubusercontent.com" >/dev/null 2>&1; then
        signature="sim"
      else
        signature="nao"
      fi
      if cosign verify-attestation "$IMAGE@$digest" \
          --type slsaprovenance \
          --certificate-identity-regexp '.*' \
          --certificate-oidc-issuer-regexp '.*' >/dev/null 2>&1; then
        provenance="sim"
      else
        provenance="nao"
      fi
      status="nao_conforme"
      if [[ "$signature" == "sim" && "$provenance" == "sim" ]]; then status="conforme"; fi
      printf '%s,%s,%s,%s,%s,%s\n' "$tag" "$published_at" "$digest" "$signature" "$provenance" "$status" >> "$REPORT"
    done

sha256sum "$REPORT" > "${REPORT}.sha256"
echo "Relatorio gerado em $REPORT"
