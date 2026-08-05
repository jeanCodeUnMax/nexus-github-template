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

## Projet Kanban créé automatiquement
Le script d'installation tente de créer un GitHub Project (ProjectV2) nommé `NEXUS Board` dans le compte propriétaire. Si la création automatique a réussi, vérifiez :

- Lien du projet (exemple) : https://github.com/users/jeanCodeUnMax/projects/10

Actions manuelles restantes :

1. Vérifier (ou créer) un champ single-select nommé `Status` dans le ProjectV2.
   - Valeurs recommandées : `Backlog`, `Ready`, `In Progress`, `Review`, `Done`.
2. Ajouter les secrets GitHub Actions (voir ci‑dessous).

> Remarque : la création complète du champ `Status` via API peut nécessiter des permissions supplémentaires ; le script affiche une notice si la création automatique échoue.

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

## Labels d'agents disponibles

La liste des labels `agent:*` fournis par ce template (utilisés pour déclencher des agents via labels ou `/run-agent`):

- `agent:antigravity` — Déclenche Antigravity / IDE agent
- `agent:colab` — Déclenche Google Colab
- `agent:docker` — Déclenche container Docker
- `agent:plan` — Déclenche AI Planner
- `agent:build` — Déclenche build automatique
- `agent:test` — Déclenche suite de tests
- `agent:documentalist` — Déclenche agent documentaliste / génération de docs
- `agent:brainstorm` — Déclenche session de brainstorming AI
- `agent:front` — Agent développeur front-end
- `agent:back` — Agent développeur back-end
- `agent:architect` — Agent architecte logiciel
- `agent:audit` — Agent audit / revue de sécurité
- `agent:test-unitaire` — Agent pour générer/runner tests unitaires
- `agent:pseudo-code` — Génère pseudo-code ou algorithme
- `agent:annalyste` — Agent analyste (business / data)
- `agent:scrapping` — Agent de scraping / collecte de données
- `agent:debug` — Agent d'aide au debugging
- `agent:copywriters` — Agent copywriting / contenu
- `agent:kaagle` — Déclenche agent Kaggle/expérimentation
- `agent:etude-du-marcher` — Étude de marché / veille

Ajoute d'autres labels `agent:*` si nécessaire en ouvrant une issue ou via `./scripts/apply-template.sh`.
