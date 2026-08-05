# DEMO — Guide pas-à-pas pour débutants

Ce guide montre comment tester le template NEXUS et comprendre le flux Kanban ↔ Issues ↔ Agents. Chaque étape est décrite pour quelqu'un qui n'est pas familier avec GitHub.

Prérequis
- Un compte GitHub et accès au dépôt `jeanCodeUnMax/nexus-github-template`.
- GitHub CLI (gh) installé et authentifié : `gh auth login`.
- (Optionnel mais recommandé) Un Personal Access Token (PAT) avec les scopes `repo` et `read:project` pour permettre la création automatique du ProjectV2.

1) Appliquer le template (local)
- Ouvrir un terminal dans le dossier du projet et exécuter :

  ./scripts/apply-template.sh <owner/repo>

  Exemple :
  ./scripts/apply-template.sh jeandom/mon-repo-test

- Ce script : copie les fichiers `.github/`, crée des labels standards, et tente de créer un GitHub Project (ProjectV2) nommé `NEXUS Board`.
- Si la création automatique échoue, un message indique l'URL pour créer manuellement le ProjectV2.

2) Ajouter les secrets GitHub Actions (via l'UI)
- Aller dans : https://github.com/<owner>/<repo>/settings/secrets/actions
- Ajouter :
  - `NEXUS_PAT` — Personal Access Token (scopes: repo, read:project)
  - `COLAB_WEBHOOK_URL`, `DOCKER_WEBHOOK_URL`, `DOCKER_WEBHOOK_TOKEN`, `AI_PLANNER_WEBHOOK_URL`, `AI_PLANNER_TOKEN`

3) Vérifier / configurer le ProjectV2 (Kanban)
- Ouvrir : https://github.com/<owner>/projects (ou le lien affiché par le script)
- Si le projet existe, ouvrir ses paramètres → Fields → Add field
  - Type: Single select
  - Name: `Status`
  - Options recommandées : `Backlog`, `Ready`, `In Progress`, `Review`, `Done`
- Sauvegarder.

4) Tester un déclencheur agent (démo simple)
- Créer une issue via l'UI ou la CLI :
  - Titre : `DEMO: NEXUS Kanban & Agents — Workflow demo`
  - Corps : quelques lignes expliquant le test
- Ajouter le label `agent:brainstorm` (ou `agent:plan`, `agent:antigravity`, etc.)
- Attendre :
  - Le workflow `04-run-agent-command.yml` (sur commentaire `/run-agent`) ou le déclencheur label se lancera.
  - Un commentaire automatique doit apparaître pour confirmer le dispatch de l'agent.

Exemple de commande sur l'issue :
- Commenter : `/run-agent plan`
- Le workflow va réagir, poster une réaction "rocket" et commenter la PR/issue avec le résumé du dispatch.

5) Tester la synchronisation Kanban ↔ Issues
- Déplacer manuellement une carte du ProjectV2 vers `In Progress` → le workflow `02-kanban-automation.yml` ajoute le label `status:in-progress` à l'issue et poste un commentaire.
- Sur l'issue, ajouter le label `status:review` → le workflow `05-issue-to-kanban.yml` va tenter de mettre à jour la carte du ProjectV2 (champ `Status`) sur la valeur correspondante.

6) Tester fermeture via PR
- Créer une branche, ouvrir une PR et dans le corps écrire `Closes #<numéro_issue>`.
- Merger la PR → le workflow `03-pr-merged.yml` ajoute `status:merged` à l'issue et tente de déplacer la carte vers `Done`.

7) Dépannage rapide
- Si un workflow ne se déclenche pas : aller sur l'onglet Actions du repo, ouvrir le run et lire les logs.
- Erreur fréquente : token `NEXUS_PAT` sans `read:project` empêchera les requêtes GraphQL ProjectV2.
- Vérifier que le champ `Status` existe et que les options correspondent (ex: 'Done') pour que les mises à jour se fassent.

8) Prochaine étape pour les débutants
- Lire `docs/AGENTS.md` pour comprendre chaque label agent:* et son usage.
- Essayer : créer une issue, ajouter `agent:brainstorm`, commenter `/run-agent plan` puis suivre les Actions.

Si tu veux, j'ajoute des captures d'écran, ou je crée une vidéo courte de démonstration. Dis‑moi ce qui t'aiderait le plus.
