# 🎯 WORKFLOW — Comment utiliser le template au quotidien

## Vue d'ensemble du flux

```
1. Vous créez une ISSUE (idée)
        ↓
2. Vous ajoutez des LABELS (agent? statut? type?)
        ↓
3. Vous la mettez dans le ProjectV2 (Kanban)
        ↓
4. L'agent ou vous créez une BRANCHE + PR
        ↓
5. Vous mergez la PR
        ↓
6. Le Kanban passe automatiquement à "Done"
```

## Créer une première issue

### Étape 1: Allez sur GitHub

Repo → **Issues** → **New issue**

### Étape 2: Remplissez la template

**Title:** `🎯 [Epic] Créer la page d'accueil`

**Description** (exemple) :
```
# 🎯 Objectif
Créer une page d'accueil pour le site qui attire les visiteurs.

# 📋 Tâches
- [ ] Créer la structure HTML
- [ ] Ajouter le CSS (design)
- [ ] Tester sur mobile
- [ ] Déployer en production

# 🔗 Lien vers PRD
(si vous avez un document de spécifications)

# Closes #123
(lier d'autres issues si nécessaire)
```

### Étape 3: Ajouter des labels

Sur la page de l'issue (colonne droite) → **Labels** :
- `type:feature` (c'est une nouvelle fonctionnalité)
- `priority:high` (c'est urgent)
- Optionnel : `agent:brainstorm` (demander à l'agent de brainstormer des idées)

### Étape 4: Ajouter au Kanban

Colonne droite → **Projects** → sélectionnez `Roadmap`

L'issue apparaît maintenant dans le tableau Kanban, colonne **Backlog**.

## Déplacer une issue dans le Kanban

### Passer à "Ready" (prêt à travailler)

1. Allez sur le ProjectV2 (`Projects` → `Roadmap`)
2. Cliquez sur votre issue, cherchez le champ **Status**
3. Changez : `Backlog` → `Ready`
4. Retournez sur l'issue GitHub : vous devez voir le label `status:ready` ajouté automatiquement ✅

### Passer à "In Progress" (en cours)

1. Créez une branche locale :
```bash
git checkout -b feat/page-accueil
```

2. Faites vos modifications
3. Committez :
```bash
git add .
git commit -m "feat: créer page d'accueil - Closes #42"
```

4. Poussez la branche :
```bash
git push -u origin feat/page-accueil
```

5. Créez une PR (Pull Request)
   - Allez sur GitHub → **Pull requests** → **New pull request**
   - Base: `main`, Compare: `feat/page-accueil`
   - Title: `feat: créer page d'accueil`
   - Description: `Closes #42` (très important pour lier à l'issue)
   - Cliquez **Create pull request**

6. Sur l'issue GitHub, allez au ProjectV2 et passez le statut à `In Progress`

Le label `status:in-progress` s'ajoute automatiquement.

### Passer à "Review"

1. Quand la PR est prête à être revue, sur l'issue, passez le statut à `Review`
2. Les reviewers commentent et approuvent la PR

### Passer à "Done"

1. Mergez la PR : **Merge pull request** → Confirmez
2. **Automatiquement**, l'issue passe au statut `Done` dans le Kanban
3. Le label `status:merged` ou `status:done` s'ajoute

✅ Cycle complet !

## Utiliser les agents (démo)

### Exemple 1: Brainstorming automatique

1. Créez une issue : "💡 Idées pour la page d'accueil"
2. Ajoutez le label : `agent:brainstorm`
3. Laissez un commentaire : `/run-agent`
4. Le workflow déclenche le webhook AGENT_BRAINSTORM_WEBHOOK
5. L'agent répond avec des idées + une PR

**Note:** L'agent n'existe pas encore pour cette démo, mais le système est prêt.

### Exemple 2: Générer un document

1. Créez une issue : "📚 Générer la documentation du projet"
2. Ajoutez le label : `agent:documentalist`
3. Commentaire : `/run-agent`
4. L'agent génère une PR avec les docs

## Bonnes pratiques

### 1️⃣ Toujours lier les issues aux PRs

Dans la description de la PR :
```
Closes #42
ou
Fixes #123
ou
Resolves #99
```

### 2️⃣ Utiliser les labels correctement

- `type:*` → bug, feature, docs, refactor
- `priority:*` → low, medium, high, urgent
- `status:*` → added by the Kanban (ne les ajoute pas manuellement)
- `agent:*` → demander à un agent de travailler

### 3️⃣ Écrire des descriptions claires

Les agents (et les humains) lisent la description pour comprendre la tâche.

### 4️⃣ Tester avant de merger

Assurez-vous que votre code fonctionne localement avant de créer la PR.

## Dépanner

- Issue ne bouge pas dans le Kanban ? → Voir **TROUBLESHOOTING.md**
- Agent ne répond pas ? → Voir **AGENTS.md** et configurer les webhooks
- Labels ne s'ajoutent pas ? → Vérifier le secret NEXUS_PAT (voir **SETUP.md**)
