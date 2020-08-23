---
layout: post
categories: [talend, camel, mongodb]
title: Camel MongoDB in Talend Studio
tags: [camel, mongodb, talend]
---
{% include JB/setup %}

[Talend ESB] provides an open source [Talend Studio] with a GUI designer for [Apache Camel] routes running in [Apache Karaf].

While many Camel components are natively represented in the Mediation perspectives tool palette, many are not.
In these cases the [cMessagingEndpoint] can be used as a general purpose component and configured with a URI.
Additional work may be necessary to add the necessary jar dependencies as well as configuring the supporting camel Components in the Camel Context.
This post walks through how to do this for the [Camel MongoDB].

The [sample route] can be imported using Import Items in the Mediation perspective.

### Install MongoDB and Talend Open Studio

Presumably you have [installed MongoDB] already.

Likewise you have hopefully already installed [Talend Open Studio].  It is just an xcopy install.

Import the [movies] into a movielens database

    mongoimport --db movielens --collection movies --file movies.json

### Download Camel Dependencies
First, find out which version of Camel is being used by your version of Talend Studio.
Check the [Talend Release Notes] on help.talend.com and see the section titled [ESB: Changes in Apache Projects].
You may need to create and register a free account to use help.talend.com.

Once you know which version of Camel is in use by Tallend, determine which jars are necessary for the component you are interested in.
In this example we are interested in MongoDB.
The [Camel MongoDB] documentation shows the following: 

    <dependency>
        <groupId>org.apache.camel</groupId>
        <artifactId>camel-mongodb</artifactId>
        <version>2.10.4</version>    <!-- use the same version as your Camel core version -->
    </dependency>

    
Talend Studo does not directly use Maven but we will to make sure that we have a single consistent place to store any jars we download, and so that all transitive jar dependencies are downloaded.
Install [Apache Maven] if it is not already installed.

Now use maven from the commandline to download the desired dependency.  
It will be installed in ~/.m2/repository/... in a path matching the group id, e.g. org/apache/camel
_Be sure to use the same version as the Camel version identified above_.

    mvn dependency:get -Dartifact=org.apache.camel:camel-mongodb:2.10.4:jar -DrepoUrl=http://repo1.maven.org/maven2/

In this case you will also need a separate driver for MongoDB itself.  
A quick search of [Maven Central] for mongodb and driver finds the latest entry.
Since this is not a Camel Component but a driver MongoDB itself, use the latest version.

    mvn dependency:get -Dartifact=org.mongodb:mongo-java-driver:LATEST:jar -DrepoUrl=http://repo1.maven.org/maven2/

You have now downloaded all the dependencies you need.

### Configure Studio Route to use Dependencies

These Library dependencies have to be added using the cConfig component.
Unfortunately, since Studio does not directly use Maven adding the full list of transitive dependency jars may be required.  
Nor will it be obvious (short of checking the POM) which libraries are needed.
So a few iterations of compiling and adding dependencies may be needed.

* Create a new Route in Mediation Perspective.
* Add a cConfig Component.
* Add dependencies to the cConfig component.

In this case we will need three dependencies.
The two jar dependencies downloaded above can be added as `External Modules`.
An additional `Internal Module` is required which is the `camel-jackson-alldep-2.10.4.jar`.
The 2.10.4 corresponds to the Camel version in use by Studio.
Note that checking the versions of internal dependencies is a quick way to determine which version of Camel is being used by Studio.
 
### Configure the Camel MongoDB Component
 
You now need to add and configure the Camel MongoDB component to the route using the dependencies we just added.
This requires two parts.  
* Create a MongoDB connection.
* Injected the MongoDB connection into a camel-mongodb Component.
 
This can be done with either  Spring  or a cBeanRegister component.

#### MongoDB Connection with Spring
* Use the Spring tab to create a bean for the MongoDB connection.
* Use the Spring tab to create a bean for the MongoDB Component.
* The camel-mongodb Component acts as a factory for camel-mongodb endpoints specified in the route URI.

        <bean id="myDb" class="com.mongodb.Mongo">
            <constructor-arg index="0" value="localhost"/>
        </bean>
        
        <bean id="mongodb" class="org.apache.camel.component.mongodb.MongoDbComponent">
        </bean>

#### MongoDB with cBean Register

* Add a cBeanRegister component to the canvass from the tool palette.
* On the Component tab add some `Imports`

        import com.mongodb.Mongo;
        import java.net.UnknownHostException;

* On the Component tab add some `code` to create the mongodDB connection instance.

        Mongo mongodb;
        try {
            mongodb = new Mongo(context.mongoHost);
        } catch (UnknownHostException hostException) {
            throw new RuntimeException("Error connecting to MongoDB", hostException);
        }
        beanInstance = mongodb;

* Add a cBeanRegister component to the canvass from the tool palette.
* On the Component tab add some imports

        import org.apache.camel.component.mongodb.MongoDbComponent;

* Now create the Camel Mongodb component.

        MongoDbComponent mongodbComponent = new MongoDbComponent();
        camelContext.addComponent("mongodb", mongodbComponent);

### Create the Camel Route
* Create the route as shown below

![mongodb route](/talend/camel/mongodb/mongodb-spring.png)

* In all the examples the query is done by example based on the payload to the mongodb endpoint.
* The uri of the mongodb endpoint controls which method is invoked
* The first queries by id  

        body: qbe id: 1
        "mongodb:myDb?database=movielens&amp;collection=movies&amp;operation=<strong>findById</strong>"

* The second queries by the title field and uses the FindOne method to just return the first such element

        body: qbe title: "{ title: \"Toy Story\" }"
        "mongodb:myDb?database=movielens&amp;collection=movies&amp;operation=<strong>findOneByQuery</strong>"
        
* The third queries by the genre and returns all matches

        body: qbe genre: "{ genres: \"Children\" }"
        "mongodb:myDb?database=movielens&amp;collection=movies&amp;operation=<strong>findAll</strong>"
        
* We split the third route to demonstratethat it returns multiple records from the mongodb endpoint.  

[Talend ESB]: http://www.talend.com/products/esb
[Talend Studio]: http://www.talend.com/download/esb
[Apache Camel]: http://camel.apache.org/
[Apache Karaf]: http://karaf.apache.org/
[cMessagingEndpoint]: https://help.talend.com/display/TalendESBMediationComponentsReferenceGuide53EN/cMessagingEndpoint
[Camel MongoDB]: http://camel.apache.org/mongodb.html
[sample route]: /talend/camel/mongodb/mongodbroutes.zip
[installed MongoDB]: http://docs.mongodb.org/manual/installation/
[Talend Open Studio]: http://www.talend.com/download/esb
[movies]: /talend/camel/mongodb/movies.json
[Talend Release Notes]: https://help.talend.com/display/TalendEnterpriseESBReleaseNotes53EN
[ESB: Changes in Apache Projects]: https://help.talend.com/display/TalendEnterpriseESBReleaseNotes53EN/ESB%3A+Changes+in+Apache+Projects
[Camel MongoDB]: http://camel.apache.org/mongodb.html
[Apache Maven]: http://maven.apache.org
[Maven Central]: http://mvnrepository.com/