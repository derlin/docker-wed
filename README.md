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

### using a data-container for the databases

__Create the container__

First, create and run a data only container. For this, either use a Dockerfile or simply use a run command.
With a dockerfile:

    # Dockerfile
    FROM busybox
    VOLUME /opt/oracle/glassfish4/glassfish/databases/
    CMD /bin/sh

and then:

    docker build -t user/db_store .

With a run command:

    docker run -ti -v /opt/oracle/glassfish4/glassfish/databases --name db_store busybox /bin/sh

__Use the container__

Build the wed-live image, commit, and relaunch it with:

    docker run \     
        --volumes-from db_store \
        -p 8080:8080 -p 1527:1527 -p 4848:4848 \
        derlin/test

__Backup and restore databases__

Backup:

    docker run --volumes-from db_store -v $(pwd):/backup busybox \
        cd /opt/oracle/glassfish4/glassfish/databases && tar czvf /backup/backup.tar.gz .

Restore it in a new container:

    docker run -ti -v /opt/oracle/glassfish4/glassfish/databases --name db_store2 busybox /bin/sh
    docker run --volumes-from db_store2 -v $(pwd):/backup busybox \
        cd /opt/oracle/glassfish4/glassfish/databases && tar xzvf /backup/backup.tar.gz 
    
Some really nice articles about docker volumes are available here: 
* https://docs.docker.com/userguide/dockervolumes/
* http://www.tech-d.net/2013/12/16/persistent-volumes-with-docker-container-as-volume-pattern/
* http://crosbymichael.com/advanced-docker-volumes.html
