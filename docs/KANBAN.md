# 📊 KANBAN — Comprendre le système de gestion de projet

## Qu'est-ce que le Kanban ?

Le Kanban est une **méthode visuelle** pour gérer le travail. Les tâches passent par des colonnes :

```
📋 Backlog  →  ✅ Ready  →  ▶️ In Progress  →  🔍 Review  →  ✔️ Done
```

**Chaque colonne représente un état du travail.**

## Les 5 statuts du NEXUS Kanban

| Statut | Meaning | Label | Quand ? |
|--------|---------|-------|--------|
| **Backlog** | Idée, pas encore prêt | (aucun) | Issue créée |
| **Ready** | Prêt à travailler, specced | `status:ready` | Specs OK, dev peut commencer |
| **In Progress** | En cours de développement | `status:in-progress` | Branche créée, PR ouverte |
| **Review** | En attente de validation | `status:review` | PR créée, en revue |
| **Done** | Terminé et en production | `status:done` ou `status:merged` | PR mergée |

## Diagramme complet

```
┌─────────────────────────────────────────────────────────┐
│                   GITHUB REPO                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Issue créée                                            │
│      ↓                                                  │
│  [Ajouter labels + description]                        │
│      ↓                                                  │
│  [Ajouter au ProjectV2 (Kanban)]                      │
│      ↓                                                  │
│  Kanban colonne: 📋 Backlog                            │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│  [Change status in Kanban → Ready]                     │
│      ↓                                                  │
│  Issue GitHub: label `status:ready` ajouté auto       │
│  Kanban colonne: ✅ Ready                              │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│  [Dev crée branche + PR]                               │
│      ↓                                                  │
│  [Change status → In Progress]                         │
│      ↓                                                  │
│  Issue GitHub: label `status:in-progress` ajouté auto  │
│  Kanban colonne: ▶️ In Progress                         │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│  [PR prête à revue]                                    │
│      ↓                                                  │
│  [Change status → Review]                              │
│      ↓                                                  │
│  Issue GitHub: label `status:review` ajouté auto       │
│  Kanban colonne: 🔍 Review                             │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│  [Reviewer approuve + Merge PR]                        │
│      ↓                                                  │
│  Issue GitHub: label `status:merged` ajouté auto       │
│  Kanban colonne: ✔️ Done (automatique!)                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Automatisations NEXUS

### 1. ProjectV2 → Issue (Kanban change status → Label added)

**Workflow:** `.github/workflows/02-kanban-automation.yml`

Quand vous **déplacez une issue** dans le Kanban → le système ajoute **automatiquement** le label correspondant à l'issue GitHub.

**Exemples:**
- Kanban: Backlog → In Progress  →  Issue: `status:in-progress` ajouté
- Kanban: In Progress → Review   →  Issue: `status:review` ajouté
- Kanban: Review → Done          →  Issue: `status:done` ajouté

### 2. Issue → ProjectV2 (Label added → Kanban status updated)

**Workflow:** `.github/workflows/05-issue-to-kanban.yml`

Quand vous **ajoutez un label** `status:*` sur une issue → le Kanban se met à jour.

**Exemple:**
- Vous ajoutez le label `status:ready` à une issue
- Le Kanban la déplace vers la colonne ✅ Ready

### 3. PR Merged → Done (PR merges → Kanban Done + Issue closed)

**Workflow:** `.github/workflows/03-pr-merged.yml`

Quand vous **mergez une PR** qui linke une issue (avec `Closes #N`) :
- L'issue reçoit le label `status:merged`
- Le Kanban la déplace vers ✔️ Done
- L'issue est automatiquement fermée (optional)

**Important:** Toujours utiliser `Closes #N` dans la PR !

```
Description de la PR:
Closes #42   ← Cela lie la PR à l'issue #42
```

## Configurer le ProjectV2 pour NEXUS

### Créer le champ "Status"

1. Allez sur votre ProjectV2 (Projects → votre projet)
2. En haut à droite → **Settings** (icône engrenage)
3. **Custom fields** → **Add field** → Type: **Single select**
4. Name: `Status`
5. Créez les options :
   - Backlog
   - Ready
   - In Progress
   - Review
   - Done

**Important:** Les noms doivent correspondre EXACTEMENT aux valeurs dans les workflows.

### Ajouter une issue au ProjectV2

1. Créez une issue normalement
2. Sur la page de l'issue → **Projects** (colonne droite)
3. Sélectionnez votre ProjectV2
4. L'issue apparaît dans la colonne **Backlog**

## Bonnes pratiques

### 1️⃣ Une issue = une tâche

Ne pas mélanger plusieurs fonctionnalités dans une issue.

✅ BON: "Créer le formulaire de login"
❌ MAUVAIS: "Créer le formulaire de login et envoyer emails"

### 2️⃣ Descriptions claires

La description aide les agents ET les développeurs.

```markdown
## 🎯 Objectif
Créer un formulaire de login sécurisé.

## 📋 Tâches
- [ ] Créer le HTML/template
- [ ] Ajouter la validation
- [ ] Hasher les passwords
- [ ] Écrire les tests

## 🔗 Ressources
- [Doc de sécurité](...)
- [Design Figma](...)
```

### 3️⃣ Utiliser les labels intelligemment

```
type:feature        ← C'est quoi ? (feature, bug, docs, refactor, chore)
priority:high       ← Combien urgent ? (low, medium, high, urgent)
agent:brainstorm    ← Quel agent ? (brainstorm, front, back, architect, etc.)
status:ready        ← Quel statut ? (ajouter via Kanban, pas manuellement)
```

### 4️⃣ Toujours lier les PRs aux issues

```bash
git commit -m "feat: créer login - Closes #42"
```

Ou dans la PR:
```
Closes #42
Closes #43
```

## Dépanner

### Issue ne bouge pas quand je change le statut dans Kanban ?

1. Vérifier que NEXUS_PAT est valide (voir SETUP.md)
2. Vérifier que le ProjectV2 a un champ "Status" (voir ci-dessus)
3. Vérifier les logs du workflow 02-kanban-automation.yml

### Label ne s'ajoute pas quand j'ajoute un label sur l'issue ?

1. S'assurer que le label commence par `status:` (example: `status:ready`)
2. S'assurer que NEXUS_PAT est valide
3. Vérifier les logs du workflow 05-issue-to-kanban.yml

### PR est mergée mais issue ne passe pas à Done ?

1. S'assurer que la PR contient `Closes #N` ou `Fixes #N`
2. S'assurer que l'issue est dans le ProjectV2
3. Vérifier les logs du workflow 03-pr-merged.yml

Tous les logs de workflow se trouvent : Repo → **Actions** → cliquer sur le workflow concerné.
