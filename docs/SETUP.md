# 🔧 SETUP — Comment démarrer avec NEXUS

## Étape 1: Créer un nouveau repo à partir du template

### Option A : Via l'interface GitHub (plus facile)

1. Allez sur : https://github.com/jeanCodeUnMax/nexus-github-template
2. Cliquez sur le bouton vert **"Use this template"** → **"Create a new repository"**
3. Remplissez :
   - Repository name: `mon-projet`
   - Description: (optionnel)
   - Public ou Private: votre choix
   - Cliquez **"Create repository from template"**

✅ Votre repo est créé !

### Option B : Via la CLI (si vous connaissez Git)

```bash
gh repo create mon-projet --template jeanCodeUnMax/nexus-github-template --public
```

## Étape 2: Configurer les secrets (TRÈS IMPORTANT)

Le Kanban automatisé a besoin d'une clé spéciale pour mettre à jour votre tableau ProjectV2. Voici comment la créer.

### Créer un Personal Access Token (PAT)

**Qu'est-ce que c'est ?** Une clé qui autorise les workflows GitHub à faire des actions en votre nom (lire/écrire issues, mettre à jour le Kanban).

**Comment créer le PAT** (ne colle jamais cette clé dans un chat !) :

1. Allez sur : https://github.com/settings/tokens
2. Cliquez **"Generate new token (classic)"**
3. Donnez un nom : `NEXUS_PAT`
4. **Cochez ces permissions (très important)** :
   - ☑️ `repo` (accès complet au repo)
   - ☑️ `read:project` (lire le ProjectV2)
5. Cliquez **"Generate token"**
6. **Copier le token affiché** (il ne s'affiche qu'une seule fois !)

**Tester le token** (PowerShell) :
```powershell
$pat = '<VOTRE_TOKEN>'
$headers = @{ Authorization = "bearer $pat"; 'User-Agent' = 'PowerShell' }
$body = @{ query = 'query { viewer { login } }' } | ConvertTo-Json
Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Headers $headers -Body $body -ContentType 'application/json'
```

**Réponse attendue** :
```json
{
  "data": {
    "viewer": {
      "login": "votre-login"
    }
  }
}
```

### Ajouter le token au repo

**Via la CLI** (après `gh auth login`) :
```bash
gh secret set NEXUS_PAT --body '<VOTRE_TOKEN>' --repo mon-utilisateur/mon-projet
```

**Via l'interface web** :
1. Allez sur : Repo → **Settings** → **Secrets and variables** → **Actions**
2. Cliquez **"New repository secret"**
3. Name: `NEXUS_PAT`
4. Value: `<VOTRE_TOKEN>`
5. Cliquez **"Add secret"**

✅ Secret ajouté !

## Étape 3: Créer un ProjectV2 (le tableau Kanban)

**Qu'est-ce que c'est ?** C'est le tableau qui affiche vos issues avec des statuts (Backlog, Ready, In Progress, Review, Done).

### Créer manuellement (interface web)

1. Allez sur votre repo → **Projects** (onglet en haut)
2. Cliquez **"Create a project"** → **"Table"**
3. Donnez un nom : `Roadmap` (ou votre choix)
4. Créez des colonnes (Status) avec les options :
   - 📋 Backlog
   - ✅ Ready
   - ▶️ In Progress
   - 🔍 Review
   - ✔️ Done

**Note:** Le script `apply-template.sh` (voir README principal) peut essayer de créer un ProjectV2 automatiquement, mais c'est souvent plus facile de le faire manuellement.

### Ajouter une première issue au projet

1. Créez une issue (exemple: "🎯 Démarrer le projet")
2. Sur la page de l'issue → **Projects** (panneau à droite) → sélectionnez `Roadmap`
3. Vous devez voir l'issue apparaître dans le ProjectV2

✅ Kanban fonctionnel !

## Étape 4: Tester le Kanban automatique

1. **Créez une issue test** : "TEST: Vérifier le Kanban"
2. **Ajoutez-la au ProjectV2** (Projects → Roadmap)
3. **Changez son statut** : Cliquez sur l'issue dans le tableau → changez **Status** de "Backlog" à "In Progress"
4. **Vérifiez l'issue GitHub** : allez sur la page de l'issue, vous devez voir un **label** `status:in-progress` ajouté automatiquement

Si le label apparaît → ✅ Le Kanban fonctionne !

Si rien ne se passe → voir **TROUBLESHOOTING.md**

## Étape 5: Tester les agents (optionnel pour la démo)

**Qu'est-ce qu'un agent ?** C'est un script externe qui peut lire une issue et générer du code, une PR, un document, etc.

Pour la démo, vous pouvez :

1. Créez une issue : "📝 Générer une documentation"
2. Ajoutez le label : `agent:brainstorm` (il doit exister dans le repo)
3. Laissez un commentaire : `/run-agent`
4. Le workflow vérifiera le secret `AGENT_BRAINSTORM_WEBHOOK` et appelera l'agent
5. L'agent répond avec une PR

**Note:** Les agents doivent être configurés (webhooks) — voir **AGENTS.md**

## Étapes suivantes

✅ Repo créé → ✅ Secrets configurés → ✅ Kanban activé → ✅ Prêt à utiliser !

Allez voir **WORKFLOW.md** pour la première issue en vrai.
