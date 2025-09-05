🌞 Déterminer quel algorithme de chiffrement utiliser pour vos clés :
Désromais l'utilisation de l'algorithme de chiffrement RSA est fortement déconseillée car considérer comme non sûres (notamment les clés de 1024 bits). Les clés de 3072 ou de 4092 sont acceptables mais posséde énormément de problémes : lenteur de la création des clés, les clés sont lourds a stocker,...
Source fiable qui explique pourquoi on évite RSA : OpenSSH : https://www.openssh.com/txt/release-8.8 .
Il est conseiller de remplacer RSA par l algorithme Ed25519 (plus rapide et plus sûrs). Elle offre un niveau de sécurité équivalent à une clé RSA de 3072 bits, mais avec une taille de clé plus petite et une résistance accrue aux erreurs de génération de nombres aléatoires.
Source qui explique pourquoi on devrait utiliser Ed225519 : https://nikk.is-a.dev/blog/ed25119_n_rsa/
