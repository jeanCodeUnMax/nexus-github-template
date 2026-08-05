# DEMO — Comment vérifier le système

Prérequis : gh CLI authentifié, secrets configurés (voir README racine).

1. Créer une issue de test :
   - Titre: "DEMO: NEXUS Kanban & Agents — Workflow demo"
   - Corps: ajouter un contexte court
   - Ajouter le label `agent:brainstorm`

2. Observer :
   - Le workflow `04-run-agent-command.yml` réagit aux commentaires `/run-agent`.
   - Le workflow `05-issue-to-kanban.yml` synchronise labels `status:*` vers le champ `Status` du ProjectV2.
   - Fusionner une PR qui mentionne `Closes #<issue>` devrait ajouter `status:merged` et tenter de déplacer la carte vers `Done`.

3. Test rapide (local) :
   - Sur l'issue, commenter : `/run-agent plan`
   - Ou ajouter le label `agent:brainstorm` pour simuler un déclencheur.

Notes : les actions s'exécutent sur GitHub ; assurez-vous que les secrets Actions sont configurés et que le ProjectV2 contient le champ `Status`.
