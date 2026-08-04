# NEXUS GitHub Template

Système de gestion de projet structuré pour repos GitHub.
Impose la discipline Epic → Feature → Task, Kanban automatique, et déclenchement d'agents IA.

## Contenu

```
.github/
  ISSUE_TEMPLATE/
    01-epic.yml          ← Objectifs stratégiques
    02-feature.yml       ← Fonctionnalités
    03-task.yml          ← Tâches atomiques
    04-bug.yml           ← Bugs
  PULL_REQUEST_TEMPLATE/
    pull_request_template.md
  workflows/
    01-agent-on-label.yml      ← Déclenche agent sur label agent:*
    02-kanban-automation.yml   ← Sync Kanban ↔ Issues
    03-pr-merged.yml           ← Ferme issues au merge PR
    04-run-agent-command.yml   ← Commande /run-agent
scripts/
  apply-template.sh    ← Installe ce template sur un repo existant
  agent-dispatch.sh    ← Lance un agent manuellement
```

## Installation rapide

```bash
# Prérequis : GitHub CLI installé et authentifié
gh auth login

# Appliquer sur un repo existant
./scripts/apply-template.sh TON_USER/TON_REPO
```

## Secrets requis

| Secret | Usage |
|--------|-------|
| `NEXUS_PAT` | Commentaires automatiques sur issues (scopes: repo, project) |
| `COLAB_WEBHOOK_URL` | Déclenchement Google Colab |
| `DOCKER_WEBHOOK_URL` | Déclenchement container Docker |
| `DOCKER_WEBHOOK_TOKEN` | Auth Docker webhook |
| `AI_PLANNER_WEBHOOK_URL` | Déclenchement AI Planner |
| `AI_PLANNER_TOKEN` | Auth AI Planner |

## Déclencheurs agents

| Méthode | Exemple |
|---------|---------|
| Label sur issue | `agent:colab`, `agent:docker`, `agent:plan` |
| Commentaire | `/run-agent colab` |
| Déplacement Kanban | Carte → "In Progress" |
| PR mergée | Fermeture automatique des issues liées |
