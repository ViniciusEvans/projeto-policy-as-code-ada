# API Pagamentos - Compliance Continuo

Projeto final integrador com FastAPI, Policy as Code, SBOM CycloneDX/SPDX, Trivy, Cosign keyless, SLSA Provenance, Gatekeeper, Sigstore Policy Controller, relatorio e KPIs.

> Este repositorio e um laboratorio. Antes de uso corporativo, valide registries, identidades OIDC, retencao, privacidade, regras de licenca e ferramentas autorizadas pela organizacao.

## Entregaveis atendidos

- cinco policies Rego e dez testes positivos/negativos;
- workflow de PR com testes, lint, OPA e scan;
- build e publicacao no GHCR;
- SBOM CycloneDX e SPDX;
- scan Trivy;
- assinatura Cosign keyless por OIDC;
- atestacoes de SBOM e vulnerabilidades;
- provenance SLSA em workflow reutilizavel;
- Gatekeeper para `runAsNonRoot`;
- ClusterImagePolicy para assinatura;
- relatorio CSV, checksum e calculo de KPIs.

## 1. Substituicoes obrigatorias

Substitua `SEU_USUARIO_GITHUB` em todo o repositorio pelo seu usuario ou organizacao, respeitando minusculas no nome da imagem.

```bash
grep -R "SEU_USUARIO_GITHUB" -n .
```

Linux/macOS:

```bash
USUARIO="seu-usuario"
grep -rl 'SEU_USUARIO_GITHUB' . --exclude-dir=.git | xargs sed -i "s/SEU_USUARIO_GITHUB/$USUARIO/g"
```

No Git Bash, se `sed -i` variar, edite os arquivos indicados pelo `grep`.

## 2. Teste local

Pre-requisitos: Python 3.12, uv, Docker e OPA 1.x.

```bash
uv sync --dev
uv run ruff check .
uv run ruff format --check .
uv run pytest -q
opa fmt --fail policies/
opa test policies/ -v
docker build -t api-pagamentos:local .
docker run --rm -p 8080:8080 api-pagamentos:local
```

Teste em outro terminal:

```bash
curl http://localhost:8080/health
```

## 3. Criar o repositorio GitHub

Crie um repositorio vazio chamado `api-pagamentos`, sem adicionar README ou .gitignore pelo site. Depois:

```bash
git init
git add .
git commit -m "feat: projeto final de compliance continuo"
git branch -M main
git remote add origin git@github.com:SEU_USUARIO_GITHUB/api-pagamentos.git
git push -u origin main
```

Se usar HTTPS, troque a URL do remote pela fornecida pelo GitHub.

## 4. Configurar o GitHub

1. Em Actions, permita a execucao dos workflows.
2. Em Packages, mantenha o GHCR habilitado.
3. Proteja a branch `main` e exija os checks `application`, `policy-as-code` e `filesystem-scan`.
4. Nao crie chave Cosign. O workflow usa OIDC keyless com `id-token: write`.
5. Para Dependency-Track, crie secrets `DT_URL`, `DT_TOKEN` e `DT_PROJECT_UUID` somente se ativar essa integracao.

## 5. Abrir um Pull Request de teste

```bash
git checkout -b teste-pipeline
echo "pipeline inicial" >> evidencias/README.md
git add .
git commit -m "test: validar checks do pull request"
git push -u origin teste-pipeline
```

Abra o PR e confirme que os tres jobs passam. Depois faça o merge.

## 6. Gerar o primeiro release

```bash
git checkout main
git pull
git tag -a v1.0.0 -m "Primeiro release assinado"
git push origin v1.0.0
```

A tag executa `.github/workflows/release.yml`, publica a imagem, gera os dois SBOMs, executa Trivy, assina por OIDC, anexa atestacoes e dispara a geracao de provenance.

## 7. Obter imagem e digest

No artefato `evidencias-v1.0.0`, abra `image.txt`. O valor tera o formato:

```text
ghcr.io/usuario/api-pagamentos@sha256:...
```

Use esse valor em `k8s/deployment.yaml` no lugar de `SUBSTITUA_PELO_DIGEST`.

## 8. Verificar assinatura

```bash
IMAGE="ghcr.io/SEU_USUARIO_GITHUB/api-pagamentos@sha256:COLE_O_DIGEST"
cosign verify "$IMAGE" \
  --certificate-identity-regexp '^https://github.com/SEU_USUARIO_GITHUB/api-pagamentos/.github/workflows/release.yml@refs/tags/v.*$' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com'
```

Para listar atestacoes:

```bash
cosign tree "$IMAGE"
```

A identidade exata emitida deve ser conferida na saida do primeiro release. Se diferir, ajuste a regex sem amplia-la para outros repositorios.

## 9. Kubernetes ou OKD

O cluster precisa ter Gatekeeper e Sigstore Policy Controller instalados por um administrador. Se voce nao tiver permissao, use um cluster local, por exemplo kind ou minikube, e registre no README que e ambiente de laboratorio.

Aplique primeiro o namespace e Gatekeeper:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/constraint-template.yaml
kubectl apply -f k8s/constraint.yaml
```

Aplique a policy Sigstore:

```bash
kubectl apply -f k8s/cluster-image-policy.yaml
```

Depois da substituicao do digest:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl -n compliance-demo get pods
```

### Teste negativo Gatekeeper

```bash
kubectl -n compliance-demo create deployment inseguro --image=nginx:latest
```

A solicitacao deve ser negada por ausencia de `runAsNonRoot=true`.

### Teste negativo de assinatura

Use uma imagem propria que voce publicou sem executar Cosign. Nao utilize imagens de terceiros como tentativa de contorno de controles.

```bash
kubectl -n compliance-demo run intruso --image=ghcr.io/SEU_USUARIO_GITHUB/api-pagamentos-sem-assinatura:teste
```

Capture a mensagem de rejeicao como evidencia.

## 10. Dependency-Track

Depois de criar o projeto e obter o UUID:

```bash
export DT_URL="https://dependency-track.exemplo"
export DT_TOKEN="token-fornecido-pelo-administrador"
export DT_PROJECT_UUID="uuid-do-projeto"
./scripts/submit_dependency_track.sh sbom.cdx.json
```

Nunca grave `DT_TOKEN` no Git.

## 11. Relatorio e KPIs

Autentique `gh`, `cosign` e Docker, depois:

```bash
export GITHUB_REPOSITORY="SEU_USUARIO_GITHUB/api-pagamentos"
./scripts/gera_relatorio.sh 2026-08
python scripts/calcula_kpis.py relatorios/2026-08/conformidade.csv
```

O relatorio inclui checksum. Para a banca, mostre o CSV e quatro KPIs descritos em `dashboards/README.md`.

## 12. Evidencias para a banca

Salve por release:

- resultado de `opa test`;
- URL e status do workflow;
- digest da imagem;
- `sbom.cdx.json` e `sbom.spdx.json`;
- `trivy.json`;
- saida de `cosign verify`;
- provenance;
- deploy assinado aceito;
- imagem sem assinatura rejeitada;
- CSV de conformidade;
- captura do dashboard.

## 13. Mapeamento de controles

| Implementacao | Evidencia | NIST SSDF | SLSA | ISO 27001:2022 | OWASP Top 10 |
|---|---|---|---|---|---|
| OPA no PR e Gatekeeper | testes e deny de admissao | PW.7.1 | Source | A.8.26 | A05 |
| Scan Trivy | JSON do scan | RV.1.1 | Dependencies | A.8.29 | A06 |
| SBOM CycloneDX e SPDX | arquivos e atestacoes | PW.4.1, RV.1.3 | Dependencies | A.8.25 | A06 |
| Cosign keyless | verificacao da assinatura | PS.2.1 | Authenticity | A.8.24 | A08 |
| Provenance | atestacao vinculada ao digest | PS.3.1 | Build | A.8.25 | A08 |
| Relatorio e logs | CSV e checksums | RV.1.1 | Evidence | A.8.15 | A09 |

## 14. Observacoes de seguranca

- Os workflows usam tags de Actions para facilitar o laboratorio. Para endurecimento, fixe cada Action por SHA verificado.
- O scan inicialmente registra vulnerabilidades sem bloquear o release. Depois de estabilizar a imagem, altere o gate conforme o criterio aprovado.
- O exemplo local de checksums detecta alteracao, mas nao substitui storage WORM ou Object Lock real.
- Valide versoes de APIs do Gatekeeper e policy-controller instaladas no seu cluster.
- O script de relatorio usa regex ampla somente para verificar provenance criado pelo gerador SLSA. Restrinja emissor e identidade depois de observar a identidade real emitida no seu ambiente.
