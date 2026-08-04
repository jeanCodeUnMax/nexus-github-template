#!/usr/bin/env bash
# ============================================================
# NEXUS Agent Dispatcher
# Usage: ./scripts/agent-dispatch.sh <agent_type> <issue_number> [options]
# Exemples:
#   ./scripts/agent-dispatch.sh colab 42
#   ./scripts/agent-dispatch.sh docker 17 image=python:3.11
#   ./scripts/agent-dispatch.sh plan 5 scope=full
# ============================================================

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
AGENT_TYPE="${1:-}"
ISSUE_NUMBER="${2:-}"
SHIFT_COUNT=2

if [[ -z "$AGENT_TYPE" || -z "$ISSUE_NUMBER" ]]; then
  echo "❌ Usage: $0 <agent_type> <issue_number> [key=value ...]"
  echo "   Agents: colab | docker | plan"
  exit 1
fi

shift $SHIFT_COUNT
EXTRA_PARAMS="$*"

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Validation env vars ───────────────────────────────────────────────────────
check_secret() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    log_error "Variable $var_name non définie. Ajoutez-la dans vos secrets GitHub ou votre .env local."
    exit 1
  fi
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
case "$AGENT_TYPE" in
  colab)
    check_secret "COLAB_WEBHOOK_URL"
    log_info "🎓 Dispatch → Google Colab (Issue #${ISSUE_NUMBER})"
    curl -s -X POST "${COLAB_WEBHOOK_URL}" \
      -H "Content-Type: application/json" \
      -d "{
        \"issue_number\": \"${ISSUE_NUMBER}\",
        \"extra_params\": \"${EXTRA_PARAMS}\",
        \"source\": \"manual-dispatch\"
      }"
    log_info "✅ Colab webhook envoyé"
    ;;

  docker)
    check_secret "DOCKER_WEBHOOK_URL"
    check_secret "DOCKER_WEBHOOK_TOKEN"
    log_info "🐳 Dispatch → Docker (Issue #${ISSUE_NUMBER})"
    curl -s -X POST "${DOCKER_WEBHOOK_URL}" \
      -H "Authorization: Bearer ${DOCKER_WEBHOOK_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{
        \"issue_number\": \"${ISSUE_NUMBER}\",
        \"extra_params\": \"${EXTRA_PARAMS}\",
        \"source\": \"manual-dispatch\"
      }"
    log_info "✅ Docker webhook envoyé"
    ;;

  plan)
    check_secret "AI_PLANNER_WEBHOOK_URL"
    check_secret "AI_PLANNER_TOKEN"
    log_info "🧠 Dispatch → AI Planner (Issue #${ISSUE_NUMBER})"
    curl -s -X POST "${AI_PLANNER_WEBHOOK_URL}" \
      -H "Authorization: Bearer ${AI_PLANNER_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{
        \"issue_number\": \"${ISSUE_NUMBER}\",
        \"extra_params\": \"${EXTRA_PARAMS}\",
        \"source\": \"manual-dispatch\"
      }"
    log_info "✅ AI Planner webhook envoyé"
    ;;

  *)
    log_error "Agent inconnu : ${AGENT_TYPE}"
    log_warn "Agents disponibles : colab | docker | plan"
    exit 1
    ;;
esac

echo ""
log_info "Dispatch terminé pour Issue #${ISSUE_NUMBER} → agent:${AGENT_TYPE}"
