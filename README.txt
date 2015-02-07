### Mini-projet de Systèmes d'informations (3e année, janvier 2015)


Le container inclut un Glassfish faisant tourner un war (WeddingSiteApp.war). 
Le site comprend:
- single site avec Angularjs pour faire des cadeaux de mariage et laisser un commentaire dans le guest book 
- single admin page pour gérer les cadeaux

Le tout avec un service REST et JPA côté serveur.

### Pour utiliser le container
Lancer le container:
    
    docker run  \
         -v path/to/war/folder:/opt/oracle/glassfish4/glassfish/domains/domain1/autodeploy/  \
         -v path/to/datasources:/opt/oracle/glassfish4/glassfish/databases/ \
        -p 8080:8080 -p 1527:1527 -p 4848:4848 \
         derlin/wed-live:latest

Ajouter __-d__ pour le lancer en daemon.

Pour ensuite ouvrir un shell:

    docker ps
    docker exec -ti <container id> bash

### pour l'autodeploy avec netbeans

In `project.properties` file must add a reference for your end folder:
    
    war.custom.dir=/path/to/war/folder/

Then, in your `build.xml` file should add this chunk of code: 

    <target name=“-post-dist”> 
        <echo message=“Copy .war file to my custom folder”/> 
        <copy file=“${dist.war}” todir=“${war.custom.dir}” /> 
    </target>

Note: don't use the default dist folder, since it is removed/recreated on each build !