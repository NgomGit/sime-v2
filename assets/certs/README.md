# Certificats TLS additionnels

Le serveur `simeanpej.ansd.sn` ne renvoie pas son certificat **intermédiaire**.
Android refuse alors le handshake (`CERTIFICATE_VERIFY_FAILED: unable to get
local issuer certificate`), alors qu'iOS complète la chaîne tout seul.

## Correctif recommandé : CÔTÉ SERVEUR
Configurer le serveur pour servir la **chaîne complète** (certificat feuille +
intermédiaire(s)). Exemple nginx : faire pointer `ssl_certificate` vers un
`fullchain.pem` (feuille + intermédiaire), pas seulement la feuille.
Ce correctif règle le problème pour TOUS les clients (Android, Java, etc.).

## Contournement CÔTÉ APP (si le serveur n'est pas modifiable tout de suite)
Déposer ici le certificat intermédiaire manquant sous le nom exact :

    assets/certs/simeanpej-intermediate.pem

(Format PEM. S'il manque aussi la racine — CA privée non présente dans le
magasin Android —, concaténer intermédiaire **puis** racine dans ce même
fichier.) L'app l'ajoutera automatiquement à son magasin de confiance au
démarrage, sans désactiver la vérification TLS.

### Comment obtenir l'intermédiaire (depuis votre machine, pas l'émulateur)
1. Voir ce que le serveur envoie (vous ne verrez que la feuille) :

    openssl s_client -connect simeanpej.ansd.sn:443 -servername simeanpej.ansd.sn -showcerts </dev/null

2. Récupérer l'URL de l'émetteur (champ « CA Issuers - URI ») :

    openssl s_client -connect simeanpej.ansd.sn:443 -servername simeanpej.ansd.sn </dev/null 2>/dev/null \
      | openssl x509 -noout -text | grep -A2 "Authority Information Access"

3. Télécharger puis convertir en PEM :

    curl -o inter.der <URL_CA_Issuers>
    openssl x509 -inform der -in inter.der -out simeanpej-intermediate.pem

Alternative simple : tester le domaine sur https://www.ssllabs.com/ssltest/ —
le rapport signale « Chain issues: Incomplete » et fournit l'intermédiaire.
