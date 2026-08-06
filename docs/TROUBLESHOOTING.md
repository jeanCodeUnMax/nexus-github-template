# 🔧 TROUBLESHOOTING — Solutions aux problèmes courants

## ❌ Le Kanban ne se met pas à jour

### Symptôme
Vous changez le statut d'une issue dans le ProjectV2, mais le label ne s'ajoute pas à l'issue GitHub.

### Causes possibles

#### 1. Secret NEXUS_PAT invalide ou manquant

**Vérifier:**
```bash
gh secret list --repo mon-utilisateur/mon-repo
```

Vous devez voir `NEXUS_PAT` dans la liste.

**Solution:**
1. Créer un nouveau PAT : https://github.com/settings/tokens
2. Scopes à cocher : ☑️ repo, ☑️ read:project
3. Ajouter le secret : `gh secret set NEXUS_PAT --body '<TOKEN>' --repo mon-utilisateur/mon-repo`
4. Attendre ~30 secondes que le secret soit synchronisé
5. Relier le test : allez sur une issue, changez son statut dans le Kanban

**Tester le token localement:**
```powershell
$pat = '<VOTRE_PAT>'
$headers = @{ Authorization = "bearer $pat"; 'User-Agent' = 'PowerShell' }
$body = @{ query = 'query { viewer { login } }' } | ConvertTo-Json
Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Headers $headers -Body $body -ContentType 'application/json'
```

Si vous voyez votre login → le token est bon ✅

#### 2. Workflow 02-kanban-automation.yml n'existe pas

**Vérifier:**
```bash
gh workflow list --repo mon-utilisateur/mon-repo
```

Vous devez voir `02-kanban-automation.yml` dans la liste.

**Solution:**
Si le workflow n'existe pas, le repositoryy n'a pas été créé à partir du template correctement. Contactez l'admin.

#### 3. Workflow échoue silencieusement

**Vérifier les logs:**
1. Repo → **Actions** → chercher `📋 Kanban Automation`
2. Cliquer sur le run le plus récent
3. Vérifier les logs (rubriques : Set up job, Get project item details, etc.)

**Erreur commune: "Bad credentials"**
→ Le NEXUS_PAT n'a pas les bonnes permissions ou est expiré (créer un nouveau, voir ci-dessus)

**Erreur: "ProjectV2Item not found"**
→ L'issue n'existe pas ou n'est pas dans le ProjectV2 (l'ajouter manuellement)

### Résolution rapide

1. Vérifier le secret NEXUS_PAT (voir ci-dessus)
2. Tester le token localement
3. Créer une nouvelle issue de test
4. L'ajouter au ProjectV2
5. Changer manuellement le statut Backlog → Ready
6. Attendre 1 minute, rafraîchir l'issue GitHub
7. Le label `status:ready` doit apparaître

---

## ❌ Les labels ne s'ajoutent pas aux issues

### Symptôme
Vous ajoutez un label `status:ready` sur une issue, mais le ProjectV2 ne se met pas à jour.

### Causes possibles

#### 1. Label n'existe pas

**Vérifier:**
```bash
gh label list --repo mon-utilisateur/mon-repo | grep status
```

Vous devez voir :
- status:backlog
- status:ready
- status:in-progress
- status:review
- status:done

**Solution:**
Si les labels manquent, aller sur : Repo → **Labels** → créer les labels manquants.

Ou via CLI :
```bash
gh label create 'status:ready' --repo mon-utilisateur/mon-repo --description 'Ready for development'
gh label create 'status:in-progress' --repo mon-utilisateur/mon-repo --description 'Currently being developed'
```

#### 2. Workflow 05-issue-to-kanban.yml échoue

**Vérifier les logs:**
1. Repo → **Actions** → chercher `🔁 Issue Label → Kanban Sync`
2. Cliquer sur le run le plus récent
3. Regarder les logs pour l'erreur

**Erreur commune: "NEXUS_PAT invalid"**
→ Le token n'a pas les bonnes scopes (voir ci-dessus)

**Erreur: "Issue not in ProjectV2"**
→ L'issue n'a pas été ajoutée au ProjectV2 (l'ajouter manuellement)

---

## ❌ PR mergée mais issue ne passe pas à Done

### Symptôme
Vous mergez une PR mais l'issue n'est pas fermée et le statut ne passe pas à "Done" dans le Kanban.

### Causes possibles

#### 1. La PR ne linke pas l'issue

**Vérifier:**
Ouvrez la PR → regardez la description, cherchez `Closes #N` ou `Fixes #N`

**Solution:**
Ajouter dans la description de la PR (avant de merger) :
```
Closes #42
```

Puis merger. Refresh l'issue GitHub → elle doit se fermer automatiquement.

#### 2. L'issue n'est pas dans le ProjectV2

**Vérifier:**
Allez sur le ProjectV2 → cherchez l'issue

**Solution:**
Ajouter l'issue au ProjectV2 manuellement (Projects → sélectionner le projet)

#### 3. Workflow 03-pr-merged.yml échoue

**Vérifier les logs:**
1. Repo → **Actions** → chercher `🔀 PR Merged`
2. Cliquer sur le run le plus récent
3. Regarder les logs

**Erreur: "NEXUS_PAT invalid"**
→ Créer un nouveau token (voir plus haut)

---

## ❌ Agent ne répond pas

### Symptôme
Vous laissez un commentaire `/run-agent` ou vous ajoutez un label `agent:brainstorm`, mais rien ne se passe.

### Causes possibles

#### 1. Webhook de l'agent n'existe pas

**Vérifier:**
```bash
gh secret list --repo mon-utilisateur/mon-repo
```

Chercher les secrets :
- AGENT_BRAINSTORM_WEBHOOK
- AGENT_BRAINSTORM_WEBHOOK
- (ou autre agent name)

**Solution:**
1. Configurer le webhook pour l'agent (voir AGENTS.md)
2. Ajouter le secret : `gh secret set AGENT_BRAINSTORM_WEBHOOK --body 'https://...'`

#### 2. Workflow 06-agent-dispatch.yml échoue

**Vérifier les logs:**
1. Repo → **Actions** → chercher `🤖 Agent Dispatch`
2. Cliquer sur le run le plus récent
3. Regarder les logs

**Erreur: "Webhook not found (404)"**
→ Le webhook n'existe pas ou l'URL est fausse

**Erreur: "Timeout"**
→ L'agent est trop lent ou ne répond pas

---

## ✅ Vérifier la santé globale

Exécutez ce script pour tester toutes les automatisations :

```bash
# 1. Vérifier que les secrets existent
echo "=== Secrets ==="
gh secret list --repo mon-utilisateur/mon-repo

# 2. Vérifier que les workflows existent
echo "=== Workflows ==="
gh workflow list --repo mon-utilisateur/mon-repo

# 3. Vérifier que les labels existent
echo "=== Labels ==="
gh label list --repo mon-utilisateur/mon-repo

# 4. Vérifier les runs récents
echo "=== Runs récents ==="
gh run list --repo mon-utilisateur/mon-repo --limit 10
```

---

## 🚀 Déboguer un run qui échoue

### Étape 1: Identifier le run qui échoue

```bash
gh run list --repo mon-utilisateur/mon-repo --limit 10
```

Vous verrez quelque chose comme:
```
failed    🔀 PR Merged — Close Issues & Update Kanban    31128951081
failed    🔁 Issue Label → Kanban Sync                   31128951082
```

### Étape 2: Voir les logs complets

```bash
gh run view 31128951081 --repo mon-utilisateur/mon-repo --log
```

### Étape 3: Chercher le message d'erreur

Regarder pour :
- `Bad credentials` → Problème de token
- `Not found` → Ressource n'existe pas
- `Timeout` → Trop long (agent qui ne répond pas)
- `403 Forbidden` → Permissions insuffisantes

### Étape 4: Corriger et re-tester

1. Corriger le problème (ajouter secret, créer label, etc.)
2. Créer une nouvelle issue de test
3. Déclencher manuellement le workflow (si possible)
4. Vérifier les logs

---

## 🆘 Je suis complètement perdu

Voici un checklist de vérification rapide :

- [ ] Repository créé à partir du template NEXUS
- [ ] PAT créé avec scopes: repo + read:project
- [ ] Secret NEXUS_PAT ajouté au repo
- [ ] ProjectV2 créé avec champ "Status"
- [ ] Labels status:* existent
- [ ] Workflows 02, 03, 05, 06, 07 existent
- [ ] Première issue créée et ajoutée au ProjectV2
- [ ] Statut changé dans le Kanban → label ajouté à l'issue ?

Si tout est ✅ mais ça ne marche toujours pas → voir les logs des workflows (Actions).

---

## 📞 Demander de l'aide

Quand vous posez une question, incluez:

1. **Le symptôme** → "Le Kanban ne se met pas à jour"
2. **Ce que vous avez essayé** → "J'ai réinitialisé le secret NEXUS_PAT"
3. **Les logs** → Copier/coller l'erreur depuis Actions
4. **Les détails** → URL du repo, numéro de l'issue, etc.

Exemple:
> Issue #42 n'a pas reçu le label `status:ready` après déplacement dans le Kanban.
> Logs : "Bad credentials" (ligne 45 du workflow 02-kanban-automation.yml)
> Repo: jeanCodeUnMax/nexus-github-template
> NEXUS_PAT existe et fonctionne localement.
