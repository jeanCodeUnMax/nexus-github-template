#!/usr/bin/env bash
# ============================================================
# NEXUS Template Installer
# Applique le template sur un repo GitHub existant
#
# Prérequis : gh CLI installé et authentifié (gh auth login)
# Usage: ./scripts/apply-template.sh <owner/repo>
# ============================================================

set -euo pipefail

TARGET_REPO="${1:-}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${GREEN}✅${NC} $1"; }
log_warn()    { echo -e "${YELLOW}⚠️ ${NC} $1"; }
log_error()   { echo -e "${RED}❌${NC} $1"; }
log_section() { echo -e "\n${BLUE}══════ $1 ══════${NC}"; }

if [[ -z "$TARGET_REPO" ]]; then
  log_error "Usage: $0 <owner/repo>"
  log_warn  "Exemple: $0 webman/nexus-bridge"
  exit 1
fi

# Vérification gh CLI
if ! command -v gh &> /dev/null; then
  log_error "GitHub CLI (gh) non trouvé. Installez-le: https://cli.github.com"
  exit 1
fi

log_section "NEXUS Template Installer → $TARGET_REPO"

# ── 1. Cloner le repo cible ───────────────────────────────────────────────────
log_section "Étape 1/5 : Clone du repo cible"
TEMP_DIR=$(mktemp -d)
gh repo clone "$TARGET_REPO" "$TEMP_DIR/target"
log_info "Repo cloné dans $TEMP_DIR/target"

# ── 2. Copier les fichiers .github ───────────────────────────────────────────
log_section "Étape 2/5 : Copie des fichiers template"
mkdir -p "$TEMP_DIR/target/.github/ISSUE_TEMPLATE"
mkdir -p "$TEMP_DIR/target/.github/workflows"
mkdir -p "$TEMP_DIR/target/.github/PULL_REQUEST_TEMPLATE"
mkdir -p "$TEMP_DIR/target/scripts"

cp -r "$TEMPLATE_DIR/.github/ISSUE_TEMPLATE/"* "$TEMP_DIR/target/.github/ISSUE_TEMPLATE/"
cp -r "$TEMPLATE_DIR/.github/workflows/"*       "$TEMP_DIR/target/.github/workflows/"
cp -r "$TEMPLATE_DIR/.github/PULL_REQUEST_TEMPLATE/"* "$TEMP_DIR/target/.github/PULL_REQUEST_TEMPLATE/"
cp    "$TEMPLATE_DIR/scripts/agent-dispatch.sh" "$TEMP_DIR/target/scripts/"
chmod +x "$TEMP_DIR/target/scripts/agent-dispatch.sh"

log_info "Fichiers copiés"

# ── 3. Créer les labels NEXUS ─────────────────────────────────────────────────
log_section "Étape 3/5 : Création des labels GitHub"
create_label() {
  local name="$1" color="$2" desc="$3"
  gh label create "$name" --color "$color" --description "$desc" --repo "$TARGET_REPO" 2>/dev/null \
    && log_info "Label créé: $name" \
    || log_warn "Label existant (ignoré): $name"
}

# Labels de type
create_label "epic"         "7057ff" "Objectif stratégique majeur"
create_label "feature"      "0075ca" "Fonctionnalité rattachée à une Epic"
create_label "task"         "e4e669" "Tâche atomique exécutable"
create_label "bug"          "d73a4a" "Anomalie à corriger"

# Labels de statut
create_label "status:in-progress" "fbca04" "En cours de développement"
create_label "status:review"      "0052cc" "En attente de review"
create_label "status:done"        "0e8a16" "Terminé"
create_label "status:merged"      "6f42c1" "PR mergée"
create_label "status:blocked"     "b60205" "Bloqué"

# Labels de scope
create_label "scope:planning"    "c5def5" "Phase de planification"
create_label "scope:development" "bfd4f2" "Phase de développement"
create_label "scope:execution"   "d4c5f9" "Phase d'exécution"
create_label "scope:fix"         "fef2c0" "Correction de bug"

# Labels d'agent
create_label "agent:colab"  "1d76db" "Déclenche Google Colab"
create_label "agent:docker" "2ea44f" "Déclenche container Docker"
create_label "agent:plan"   "8b949e" "Déclenche AI Planner"
create_label "agent:build"  "e99695" "Déclenche build automatique"
create_label "agent:test"   "f9d0c4" "Déclenche suite de tests"

# Labels de priorité
create_label "priority:critical" "b60205" "🔴 Priorité critique"
create_label "priority:high"     "e4e669" "🟠 Priorité haute"
create_label "priority:medium"   "0075ca" "🟡 Priorité moyenne"
create_label "priority:low"      "0e8a16" "🟢 Priorité basse"

# ── 4. Commit et push ────────────────────────────────────────────────────────
log_section "Étape 4/5 : Commit & Push"
cd "$TEMP_DIR/target"
git add .github/ scripts/
git commit -m "feat: apply NEXUS GitHub template

- Issue templates: Epic, Feature, Task, Bug
- Workflows: agent-on-label, kanban-automation, pr-merged, run-agent-command
- PR template with checklist
- Agent dispatch script
- NEXUS labels

Applied from: nexus-github-template"

git push origin HEAD
log_info "Push effectué"

# ── 5. Instructions post-install ──────────────────────────────────────────────
log_section "Étape 5/5 : Configuration requise"

cat << EOF

${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}🎉 NEXUS Template installé sur $TARGET_REPO${NC}
${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}Actions manuelles restantes :${NC}

1. ${YELLOW}Créer le GitHub Project (Kanban)${NC}
   → Aller sur : https://github.com/$TARGET_REPO/projects
   → New project → Board
   → Colonnes : Backlog | Ready | In Progress | Review | Done

2. ${YELLOW}Ajouter les Secrets GitHub Actions${NC}
   → Aller sur : https://github.com/$TARGET_REPO/settings/secrets/actions
   → Ajouter :
     • NEXUS_PAT          — Personal Access Token (read:project)
     • COLAB_WEBHOOK_URL  — URL de votre webhook Colab
     • DOCKER_WEBHOOK_URL — URL de votre webhook Docker
     • DOCKER_WEBHOOK_TOKEN
     • AI_PLANNER_WEBHOOK_URL
     • AI_PLANNER_TOKEN

3. ${YELLOW}Tester le système${NC}
   → Créer une issue avec le label ${GREEN}agent:colab${NC}
   → Commenter sur une issue : ${GREEN}/run-agent plan${NC}

${GREEN}Documentation complète : README.md${NC}
EOF

# Cleanup
rm -rf "$TEMP_DIR"
