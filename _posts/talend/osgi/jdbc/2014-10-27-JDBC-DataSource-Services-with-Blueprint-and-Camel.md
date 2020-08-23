---
layout: post
categories: [camel, osgi, blueprint, jdbc]
title: Pluggable Data Sources
tagline: JDBC DataSource Services with Blueprint and Camel
tags: [camel, services, osgi, blueprint, jdbc]
---
{% include JB/setup %}

Here is a simple example of how to use OSGI Blueprint to create JDBC data sources via configuration rather than code.
The example uses the OSGI _Config-Admin_ service so that new datasources can be dynamically created by just deploying configuration files.

The JDBC javax.sql.DataSource is exposed as an OSGI service and used by an Apache [Camel] client.
The client uses [camel-blueprint] services so _just the interface_ rather than any implementation knowledge of the underlying JDBC classes is required; no reflection is used by the client.
MySQL is used for the example, but any JDBC driver could be used which exposes a public realization of the javax.sql.DataSource.
The [Talend ESB SE] distribution of Apache [Karaf] is used as the OSGI container but this will work in any Blueprint enabled OSGI container.  The Talend ESB uses the Apache [Aries] Blueprint implementation.

The [sample code] is available on Github.
 TBD -- There is a video design walkthrough available on YouTube as well. --

## Design Goals

The primary objective is to use the OSGI service registry for JDBC data sources using the Config-Admin service.
The OSGI service model is a "micro" service model in the sense that the services can only be used within the same jvm running the OSGI container, i.e. this is not a SOA registry.
The end result is that new datasources are made available via the OSGI service registry based on declarative configuration with zero procedural code.
This is made possible by exposing the service using the Managed Service Factory capabilities of OSGI Config-Admin specification.
The client uses the Blueprint container as the Dependency Injection mechanism for consuming the exposed JDBC datasource.
It is actually the Apache [Felix] project that provides the [implementation of the Config-Admin] specification.
The [Configuration-Admin API] as well as the [OSGI Specification] are also available online.

## Pre-Requisites

1.  Install JDK.  1.6 or 1.7 will both work.
2.  Install Apache Maven.
3.  Download and install [Talend ESB SE] Karaf container by unzipping it.
4.  A working instance of Mysql with some data that you want to access.


## Demonstration


1.  You will need to install the mysql driver into your local maven repository.
If you build the code from github this will happen automatically, but if you are just running from binaries use the following commands.

        $ mvn dependency:get -Dartifact=mysql:mysql-connector-java:5.1.26:jar -DrepoUrl=http://repo1.maven.org/maven2/

2.  Start the karaf container from the commandline with the `trun` script in the located in the bin directory.

3.  Install the mysql driver from the local maven repository into the karaf bundle repository using the osgi install command.

        karaf> install mvn:mysql/mysql-connector-java/5.1.26
	    Bundle ID: 247
    	karaf> list | grep -i mysql
	    [ 247] [Resolved   ] [            ] [       ] [   80] Sun Microsystems' JDBC Driver for MySQL (5.1.26)

4.  Install the camel-sql component.  This is available as a pre-installed feature in Talend ESB SE, so all you need to do is use features:install command.

        karaf> features:list | grep -i camel-sql
        [uninstalled] [2.12.3          ] camel-sql                               camel-2.12.3
	    karaf> features:install camel-sql
        Refreshing bundles org.springframework.context.support (90)
        karaf> features:list | grep -i camel-sql
        [installed  ] [2.12.3          ] camel-sql                               camel-2.12.3
	
5.  Install the mysql managed service factory sample bundle

        karaf> install -s mvn:net.eost.example.osgi.jdbc/mysql/1.0-SNAPSHOT
	    karaf> list | grep -i mysql
    	[ 247] [Resolved   ] [            ] [       ] [   80] Sun Microsystems' JDBC Driver for MySQL (5.1.26)
        [ 250] [Active     ] [Created     ] [       ] [   80] jdbc::mysql (1.0.0.SNAPSHOT)
    	karaf> start 250

6.  Show the running Managed Service Factory.
	Note that this is _not_ the javax.sql.DataSource service.
	This is the Managed Service Factory that is listening for cfg files in the /etc folder.
    When those config files are provided it will create an instance of the actual javax.sql.DataSource and register it as a service.

        karaf@trun> ls -a | grep -i -A 5 "jdbc::mysql
        
        jdbc::mysql (250) provides:
        ---------------------------
        org.osgi.service.cm.ManagedServiceFactory
        org.osgi.service.blueprint.container.BlueprintContainer


7.  Install the client bundle.

        karaf> install -s mvn:net.eost.example.osgi.jdbc/client/1.0-SNAPSHOT
	    karaf> list | grep -i "jdbc::client"
    	[ 255] [Active     ] [Created     ] [       ] [   80] jdbc::client (1.0.0.SNAPSHOT)

8.  If you display the log and you will see an error.  This is because no configuration file for the datasource has been deployed, and therefore no service has been instantiated.
As a result, when the camel route runs it will not be able to resolve the reference from the camel-sql component for the myds bean.
	

9.  Edit the sample msf.ds.mysql-1.cfg file so that the db parameters match your local mysql database.

10. Copy the sample msf.ds.mysql-1.cfg file to the karaf /etc folder.

        $ cp msf.ds-mysql-1.cfg ~/talend/etc

11. Clear out the clustter in the log, then stop and restart the client bundle.  Then take a look at the log.  You should see the result set of your query.

        karaf> log:clear
    	karaf> stop 255
	    karaf> start 255
    	karaf> log:display

13.  Some addition exploration to familiarize yourself with both the Karaf commandline and the Karaf web console.  List the installed configurations the karaf command line.

    karaf> config:list | grep -A 5 -i msf

14.  List the active services from the karaf command line.

    karaf> services:list | grep -A 5 -i mysql
	jdbc::mysql (254) provides:
	---------------------------
	org.osgi.service.cm.ManagedServiceFactory
	org.osgi.service.blueprint.container.BlueprintContainer
	javax.sql.DataSource

15.  Show the details for services exposed by a specific bundle.

    	karaf> services:ls 250
	    jdbc::mysql (250) provides:
    	---------------------------
	    Bundle-SymbolicName = mysql
    	Bundle-Version = 1.0.0.SNAPSHOT
	    service.pid = msf.ds.mysql
    	objectClass = org.osgi.service.cm.ManagedServiceFactory
	    service.id = 519
	    ----
    	osgi.blueprint.container.version = 1.0.0.SNAPSHOT
    	osgi.blueprint.container.symbolicname = mysql
	    objectClass = org.osgi.service.blueprint.container.BlueprintContainer
    	service.id = 520
	    ----
    	URL = jdbc:mysql://localhost:3306/customerorders
	    databaseName = customerorders
    	service.factoryPid = msf.ds.mysql
	    user = tadmin
    	osgi.jdbc.driver.name = mysql
	    felix.fileinstall.filename = file:/C:/Talend/5.5.1/c0/etc/msf.ds.mysql-1.cfg
    	service.pid = msf.ds.mysql.2bc9fc80-7941-4859-ab1f-b2ab5c6aaf29
	    service.ranking = 0
    	osgi.jdbc.driver.class = com.mysql.jdbc.Driver
	    serverName = localhost
    	dsname = myds_id
	    password = tadmin
    	portNumber = 3306
	    objectClass = javax.sql.DataSource
    	service.id = 526
	
16.  Show the installed configurations in the Karaf web console under the top level Configuration tab and under the Configuration Status->Configurations tab as well.

17.  Show all of the Services under the top level Service tab and under the Configuration Status->Services tab as well.

18.  Copy the original sample msf.ds.mysql-1.cfg to a new msf.ds.mysql-2.cfg file.  
Modify the new cfg to have a different dsname property so that it does not conflict with the current version.  
Then copy the new config file to the karaf/etc folder.
Repeat steps to show the new configuration has resulted in the instantiation of a new service.

19. Show the installed camel context from the karaf console.

        karaf> camel:context-list
         Context              Status         Uptime
         -------              ------         ------
         clientCamelContext   Started        24 minutes
 
20. Show the installed camel route from the karaf console.

        karaf> camel:route-list clientCamelContext
    
         Context              Route          Status
         -------              -----          ------
         clientCamelContext   dbtestRoute    Started

### TODO

Modify the client to use a config file for its own reference property placeholder that is used for the sql statement

Modify the client to use a config file to select which data source is used by the datasource bean.
	 
## Analysis


## Step by Step Tutorial

### Create the Maven POM Structure

This section provides a step by step tutorial to create the sample code.

1.  Create a parent pom project using the maven pom-root archetype.  This will create a new subdirectory named after the artifactId (jdbc).

    	$ mvn archetype:generate ^
	      -DarchetypeGroupId=org.codehaus.mojo.archetypes ^
    	  -DarchetypeArtifactId=pom-root ^
	      -DarchetypeVersion=1.1 ^
    	  -DgroupId=net.eost.example.osgi ^
	      -DartifactId=jdbc ^
    	  -DinteractiveMode=false ^
	      -Dversion=1.0-SNAPSHOT

2.  Change to the new jdbc parent-pom directory. Create a child maven project for the mysql datasource service using the camel-blueprint archetype.  The ^ signs below are for a windows batch script.  Use \ for linux.

    	$ cd jdbc
	    $ mvn archetype:generate ^
    	  -DarchetypeGroupId=org.apache.camel.archetypes ^
	      -DarchetypeArtifactId=camel-archetype-blueprint ^
    	  -DarchetypeVersion=2.14.0 ^
	      -DgroupId=net.eost.example.osgi.jdbc ^
    	  -DartifactId=mysql ^
	      -Dpackage=net.eost.example.osgi.jdbc.mysql ^
    	  -Dversion=1.0-SNAPSHOT ^
	      -DinteractiveMode=false ^
    	  -Dcamel-version=2.12.3 ^
	      -Dlog4j-version=1.2.17 ^
    	  -Dmaven-bundle-plugin-version=2.4.0 ^
	      -Dmaven-compiler-plugin-version=2.5.1 ^
    	  -Dmaven-resources-plugin-version=2.6 ^
	      -Dslf4j-version=1.7.7

3.  In the same jdbc parent-pom directory create another child maven project for the client.  Note that the client is using a different maven prototype than the service.

    	mvn archetype:generate ^
	      -DarchetypeGroupId=org.apache.camel.archetypes ^
    	  -DarchetypeArtifactId=camel-archetype-blueprint ^
	      -DarchetypeVersion=2.14.0 ^
    	  -DgroupId=net.eost.example.osgi.jdbc ^
	      -DartifactId=client ^
    	  -Dversion=1.0-SNAPSHOT ^
	      -DinteractiveMode=false ^
    	  -Dpackage=net.eost.example.osgi.jdbc.client ^
	      -Dcamel-version=2.12.3 ^
    	  -Dlog4j-version=1.2.17 ^
	      -Dmaven-bundle-plugin-version=2.4.0 ^
    	  -Dmaven-compiler-plugin-version=2.5.1 ^
	      -Dmaven-resources-plugin-version=2.6 ^
    	  -Dslf4j-version=1.7.7

### Create the Mysql Datasource Service Bundle
	
Go to the mysql child directory created in the previous steps.

4.  Delete the default source packages generated by the archetype in the mysql/src/main/java directory.  You will actually not need any source code for this bundle.

5.  Edit the mysql pom file and add a mysql.version property.

        <properties>
            <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
            <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        
            <mysql.version>5.1.26</mysql.version>
        </properties>

6.  Still editing the mysql pom, add the following dependency for the mysql driver.  
Note that it is marked as provided.
The driver jar will be available at compile time in the developer environment classpath via maven.
At runtime it will be provided by the OSGI container.  This in turn that the driver bundle is provisioned into the karaf container.
The mysql service bundle will expect for it to be previously installed.  If it is not then it will throw an error.

        <dependencies>
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <version>${mysql.version}</version>
                <scope>provided</scope>
            </dependency>
        </dependencies>

7.  Still editing the mysql pom, modify the maven-bundle-plugin as shown below.
Note that there are _no exports_.  This may seem surprising at first if you are accustomed to tight coupling between bundles using package imports and exports.
If there are no exported packages how will the client get access to the datasource?  
The answer is that the client does import the javax.sql package so that it can get access to the javax.sql.DataSource _interface_.  
But the interface is provided by the OSGI Services API so the client does not even know whether it is mysql or an oracle or a postgres realization of the interface.
Blueprint provides access to the OSGI Service API using familiar xml style declarative dependency injection.

        <plugins>
            <plugin>
                <groupId>org.apache.felix</groupId>
                <artifactId>maven-bundle-plugin</artifactId>
                <version>2.4.0</version>
                <extensions>true</extensions>
                <configuration>
                    <instructions>
                        <Import-Package>com.mysql.jdbc.jdbc2.optional</Import-Package>
                    </instructions>
                </configuration>
            </plugin>
        </plugins>
 
 7.  Create the msf-mysql.xml blueprint configuration file in the src/main/resources/OSGI-INF/blueprint directory as shown below.
 
    <?xml version="1.0" encoding="UTF-8"?>
    <blueprint xmlns="http://www.osgi.org/xmlns/blueprint/v1.0.0"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:cm="http://aries.apache.org/blueprint/xmlns/blueprint-cm/v1.1.0"
               xmlns:camel="http://camel.apache.org/schema/blueprint"
               xsi:schemaLocation="
           http://www.osgi.org/xmlns/blueprint/v1.0.0 http://www.osgi.org/xmlns/blueprint/v1.0.0/blueprint.xsd
           http://camel.apache.org/schema/blueprint http://camel.apache.org/schema/blueprint/camel-blueprint-2.12.0.xsd
           http://aries.apache.org/blueprint/xmlns/blueprint-cm/v1.1.0 http://aries.apache.org/schemas/blueprint-cm/blueprint-cm-1.1.0.xsd">

        <cm:managed-service-factory id="msf-ds-mysql"
                                    factory-pid="msf.ds.mysql" 
                                    interface="javax.sql.DataSource" >
            <service-properties>
                <entry key="osgi.jdbc.driver.class" value="com.mysql.jdbc.Driver"/>
                <entry key="osgi.jdbc.driver.name" value="mysql"/>
                <cm:cm-properties persistent-id="" update="true"/>
            </service-properties>
            <cm:managed-component class="com.mysql.jdbc.jdbc2.optional.MysqlDataSource">
                <cm:managed-properties persistent-id="" update-strategy="container-managed"/>
            </cm:managed-component>
        </cm:managed-service-factory>

    </blueprint>
 
### Create the Camel-Mysql Client Bundle
	

4.  Delete the default source and test packages generated by the archetype in the mysql/src/main/java directory.
Also delete the default blueprint.xml file located in the src/main/resources/OSGI-INF/blueprint directory.

5.  Edit the client pom file and add the camel.version property shown below.  Change any existing dependencies to use the property `${camel.version}` rather than the hardcoded values generated by the archetype.
	
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

        <camel.version>2.12.3</camel.version>
    </properties>
	
	
6.  Still editing the client pom file, add the camel-mysql dependency.  Also add a dependency on the mysql service we created in the previous step.
Note that the camel-sql scope is marked as provided.
This means that while at compile time Maven will have responsibility for providing access to the jar on the classpath, but at runtime the camel-sql bundle will be by provided by the OSGI container.
This means that the camel-sql bundle will have to be provisioned to the OSGI container in advance.  This can be done in our example by simply installing the camel-sql feature which is included in the Talend ESB distribution.
Also note that the mysql datasource service bundle is marked as test scope.
This means anything that depends on this client package will _not_ have a transitive dependency on the mysql data source service provider.
That is the intent, the data source provider is completely pluggable and is only needed for testing.
One consequence of this is that the OSGI manifest headers in the resulting bundle generated by the maven-bundle-plugin will _not_ import the mysql bundle.

        <dependency>
            <groupId>org.apache.camel</groupId>
            <artifactId>camel-sql</artifactId>
            <version>${camel.version}</version>
            <scope>provided</scope>
        </dependency>

        <dependency>
            <groupId>net.eost.example.osgi.jdbc</groupId>
            <artifactId>mysql</artifactId>
            <version>1.0-SNAPSHOT</version>
            <scope>test</scope>
        </dependency>

7.  Still editing the client pom, modify the maven-bundle-plugin as shown below.
We only need the standard maven-bundle-plugin defaults.
Note that this bundle is a client and not surprisingly does not need any exports.  
Somewhat more surprisingly, it also does not need any explicit package imports from the mysql service bundle.
Since the mysql jar is marked as optional, any of its transitive dependencies will not be included in the generated package imports created by the maven-bundle-plugin.
The javax.sql package is a dependency of the camel-sql jar, however, so it will be included, but the mysql specific packages will not be included.
This is by design.  There is only a _runtime_ dependency on the service interface.  However, we do need some compile-time and test-time dependency so that we can actually test it.

        <plugins>
            <plugin>
                <groupId>org.apache.felix</groupId>
                <artifactId>maven-bundle-plugin</artifactId>
                <version>2.4.0</version>
                <extensions>true</extensions>
            </plugin>
        </plugins>

8.  Create the client.xml blueprint configuration file in the src/main/resources/OSGI-INF/blueprint directory as shown below.

    <?xml version="1.0" encoding="UTF-8"?>
    <blueprint xmlns="http://www.osgi.org/xmlns/blueprint/v1.0.0"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:cm="http://aries.apache.org/blueprint/xmlns/blueprint-cm/v1.1.0"
               xmlns:camel="http://camel.apache.org/schema/blueprint"
               xsi:schemaLocation="
           http://www.osgi.org/xmlns/blueprint/v1.0.0 http://www.osgi.org/xmlns/blueprint/v1.0.0/blueprint.xsd
           http://camel.apache.org/schema/blueprint http://camel.apache.org/schema/blueprint/camel-blueprint-2.12.0.xsd
           http://aries.apache.org/blueprint/xmlns/blueprint-cm/v1.1.0 http://aries.apache.org/schemas/blueprint-cm/blueprint-cm-1.1.0.xsd">

        <reference id="myds" interface="javax.sql.DataSource" filter="(&amp;(dsname=myds_id)(osgi.jdbc.driver.class=com.mysql.jdbc.Driver)(osgi.jdbc.driver.name=mysql))" availability="optional"/>

        <camelContext id="clientCamelContext" trace="false" xmlns="http://camel.apache.org/schema/blueprint">
            <route id="dbtestRoute">
                <from uri="timer:dbtest?repeatCount=1&amp;delay=3000"/>
                <to uri="sql:select * from customers?dataSource=myds"/>
                <to uri="log:sqlResult"/>
            </route>

        </camelContext>

    </blueprint>

## Other Resources

Christian Schneider has an excellent and more extensive example using JPA as well as JDBC on his [liquid-reality] blog.
The primary difference is that his example does not use the config-admin Managed Service Factory so it is not a data driven configuration.
Christian's example also comes with some nice karaf commandline utilities for listing sql datasources and even executing sql queries from the karaf commandline.
These are pretty useful for testing and exploring the sql datasources, but they will not work with the vanilla services as implemented in this example.


[Talend ESB SE]: http://www.talend.com/download/esb#quicktabs-product_download_tabs
[sample code]: https://github.com/EdwardOst/example-osgi-jdbc
[design walkthrough]: tbd
[Camel]: http://camel.apache.org/
[camel-blueprint]: http://camel.apache.org/using-osgi-blueprint-with-camel.html
[Karaf]: http://karaf.apache.org/
[Aries]: http://aries.apache.org/
[Felix]: http://felix.apache.org/
[implementation of the Config-Admin]: http://felix.apache.org/documentation/subprojects/apache-felix-config-admin.html
[Configuration-Admin API]: http://www.osgi.org/javadoc/r4v42/org/osgi/service/cm/ConfigurationAdmin.html
[OSGI Specification]: http://www.osgi.org/Specifications/HomePage 
[liquid-reality]: http://www.liquid-reality.de/display/liquid/2012/01/13/Apache+Karaf+Tutorial+Part+6+-+Database+Access

