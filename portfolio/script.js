/**
 * Script principal du Portfolio
 */

document.addEventListener('DOMContentLoaded', () => {
    console.log("Portfolio initialisé !");
    
    // Smooth scrolling pour la navigation
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetSection = document.querySelector(targetId);
            if(targetSection) {
                targetSection.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });

    // Gestion du formulaire de contact
    const form = document.getElementById('contact-form');
    const formStatus = document.getElementById('form-status');

    // Démo Issue #17 : Bouton rouge avec alerte
    const alertBtn = document.getElementById('alert-btn');
    if (alertBtn) {
        alertBtn.addEventListener('click', () => {
            alert('🚨 Alerte rouge ! Tu as cliqué sur le bouton de démo (Issue #17) !');
        });
    }

    if (form) {
        form.addEventListener('submit', (e) => {
            e.preventDefault(); // Empêche le rechargement de la page
            
            const btn = form.querySelector('button[type="submit"]');
            const originalText = btn.textContent;
            
            // Animation de chargement
            btn.textContent = 'Envoi en cours...';
            btn.disabled = true;

            // Simulation d'un appel réseau (1.5 secondes)
            setTimeout(() => {
                formStatus.textContent = "✅ Message envoyé avec succès ! Je vous réponds très vite.";
                formStatus.className = "status-success";
                formStatus.classList.remove('hidden');
                
                form.reset(); // Vide les champs
                
                // Remet le bouton à zéro
                btn.textContent = originalText;
                btn.disabled = false;
                
                // Cache le message après 5 secondes
                setTimeout(() => formStatus.classList.add('hidden'), 5000);
            }, 1500);
        });
    }
});
