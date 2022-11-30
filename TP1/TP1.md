# TP 1 Linux : Are you dead yet ?

## 1) Editer .bashrc

**Procédé**

* Ajout d'une ligne "exit" sur le fichier .bashrc de tous les utilisateurs.

**Commande**
```powershell
sudo nano .bashrc
```

**Résultat**

* L'utilisateur ne peut pas se connecter à sa session.  




## 2) Editer les fichiers /boot/init

**Procédé**
* Ajouter des lettres et supprimer des lignes

**Commande**
```powershell
sudo nano /boot/initramfs-5.14.0-70.13.1.el9.aarch64.img 
```

**Résultat**

* La VM ne démarre plus


## 3) Fork Bomb (Pinguin version)

**Procédé**
p
* Ajout d'une fonction dans le fichier /etc/profile


**Commande**

```powershell
Pinguin () {
    cat << 'EOF'
           _..._
         .'     '.
        /  _   _  \
        | (o)_(o) |
         \(     ) /
         //'._.'\ \
        //   .   \ \
       ||   .     \ \
       |\   :     / |
       \ `) '   (`  /_
     _)``".____,.'"` (_
     )     )'--'(     (
      '---`      `---`
}

EOF

Pinguin
}

while :
do
((Pinguin)&)
done
```

**Résultat**

* Le terminal affiche une infinité de pingouins. Ce processus ne peut pas être arrêté. 


## 4) Suppression des terminaux

**Procédé**

* Suppression de bash et sh 

**Commande**

```powershell
sudo rm /boot/bash
sudo rm /boot/sh
```

**Résultat**

* L'utilisateur ne peut plus effectuer de commandes


