---
layout: post
categories: [camel, osgi, blueprint]
title: Camel Plus Blueprint for Pluggable Services
tagline: Realizing the Service Activator EIP with Blueprint and Camel Bean Components
tags: [talend, soa, esb, eip, camel, services, osgi, blueprint]
---
{% include JB/setup %}

Here is a simple example of how to use OSGI Blueprint to provide services which are invoked via bean components within larger Camel routes.
The design pattern is to decouple dynamic service injection from mediation and routing.

There are two logical modules, services and mediation.
* Services are provided as OSGI bundles using blueprint.
* Mediation and routing is provided via a [Camel] route using [Talend Open Studio for ESB].

The [sample route] is available for download and there is a youtube [design] walk-through of the route available as well.
The sample [helloworld service] for the OSGI services is available from github.

Services
--------

The [helloworld service] is copied from the Apache Aries blueprint [helloworld samples].
It has been modified so that there are two alternative implementation of the service API.
There are a total of four bundles.
* Helloworld API
* Helloworld Server
* Helloworld Server 2
* Simple OSGI client

You can follow the [helloworld readme] to build and install the the sample services.
The basic design decision is that a service is responsible for registering itself with the container and that this is done via Blueprint.
By convention, the blueprint for a bundle is located in OSGI-INF/blueprint under resources.

        <bean id="helloservice"
                class="org.apache.aries.samples.blueprint.helloworld.server.HelloWorldServiceImpl"
                init-method="startUp">
        </bean>

        <service ref="helloservice"
                interface="org.apache.aries.samples.blueprint.helloworld.api.HelloWorldService" />

The extract from the Helloworld Server example above says, create a regular bean based on the HelloWorldServiceImpl class, and then register it with the OSGI container using the HelloworldService interface.

Mediation
---------

This example uses Talend Studio to create the Camel routes, but Camel routes can be created using the Camel Java domain specific langauge (DSL) in any Java editor, or routes can be created with either the Spring or Blueprint XML based DSL's.

![bean-mediation](/talend/camel/osgi/camel-osgi-bean-route.jpg)

As shown above, we can see that the Camel route depends upon a local bean with id helloworldService and expects a method called hello.
The actual bean configuration is done via the Spring tab.  The contents of the Spring tab are extracted below.

        <bean id="helloworldService" class="org.apache.aries.samples.blueprint.helloworld.server.HelloWorldServiceImpl"/>
        <!-- osgi:reference id="helloworldService" interface="org.apache.aries.samples.blueprint.helloworld.api.HelloWorldService" / -->

In this case we can see that the bean element is uncommented while the osgi:reference has been commented out.
The Spring bean will be instantiated by Spring in Studio and will use the HelloWorldServiceImpl class.
So when running in the Studio the route _is_ coupled to the implementation class.
After all, we need to test it with something.
Strictly speaking, however, this could be any implementation of the same interface, and could be a mock rather than the actual bean.

Whether it is the mock or the actual implementatin, these classes have to be provided to Studio.
In this case we have chosen to use the actual jars.
They are provided via the cConfig components Dependencies property as shown below.

![jar-dependencies](/talend/camel/osgi/camel-osgi-jar-dependencies.jpg)

This allows us to test the bean and the route in the Studio.
Once we are ready to deploy, however, responsibility for providing the service realization will fall to the container.
So we comment out the local Spring bean and uncomment the osgi service reference as shown below.
Note that this is Spring XML bean configuration rather than blueprint.
Both support OSGI.

        <!-- bean id="helloworldService" class="org.apache.aries.samples.blueprint.helloworld.server.HelloWorldServiceImpl"/ -->
        <osgi:reference id="helloworldService" interface="org.apache.aries.samples.blueprint.helloworld.api.HelloWorldService" />

In addition to tweaking the bean configuration, we also no longer need the jars files.
They will be provided by the OSGI context as well.
So we can deactivate the cConfig componoent in the design canvas (right click and select Deactivate).

One step remains.  Although we do not wish to embed the actual jars, we wish to express our dependency on just the _API_ package.
This is an important distinction.  The cConfig component provides an means of embedding or requiring _jars_ while what we want is the more fine-grained, declarative _package_ level dependency.
Both are supported by OSGI but package level dependency management is the best practice.

![package-dependencies](/talend/camel/osgi/camel-osgi-package-dependencies.jpg)

Demonstration
-------------

To demonstrate the functionality try the following steps.

1.  Download and deploy a Karaf instance.  I suggest the [Talend Open Studio for ESB] since it includes the GUI we will use for the Camel routes.
2.  Download the [helloworld service] following the instructions on the github site.  This should have two instances the helloworld service implementation as well as the api and a sample client.
3.  Build the helloworld service and deploy the helloworld api and the two helloworld imlpementations to the Karaf instance.

     install mvn:org.apache.aries.samples.blueprint.helloworld/org.apache.aries.samples.blueprint.helloworld.api/1.0.0
     install mvn:org.apache.aries.samples.blueprint.helloworld/org.apache.aries.samples.blueprint.helloworld.server/1.0.0
     install mvn:org.apache.aries.samples.blueprint.helloworld/org.apache.aries.samples.blueprint.helloworld.client/1.0.0
     
4.  The client will run once and will invoke the server implementation.
5.  Install the second helloworld implementation.
     install mvn:org.apache.aries.samples.blueprint.helloworld/org.apache.aries.samples.blueprint.helloworld.server_2/1.0.0
6.  Rerun the client by restarting it.  Note that it still continues to execute with server 1.
7.  Stop the first helloworld server.
8.  Rerun (restart) the client.  Note that it now uses server 2.
9.  Start server 1.  Now both server 1 and server 2 are running.
10.  Download the [sample route] zip file and use Import Items in Talend Studio.
11.  You will need to (re)specify the location of the helloworld jars in the cConfig component to point at the jars you built from the git download using the Modules View.
12.  Run the route in Talend Studio.  
13.  Comment out the spring bean declaration and uncomment the OSGI service bean declaration.  Deactivate the cConfig component.
14.  Deploy the Talend Studio route to your Karaf instance.
15.  You will see route trigger every 5 seconds.  It will be consistently invoking either server 1 or server 2.
16.  Stop the server implementation being used by the route.
17.  Notice that the other server immediately picks up.
18.  Now stop the one remaining service.  Notice that the route blocks.  It would eventually timeout if left too long.
18.  Start one of the two services.  The Camel route and OSGI service client immediately resumes.
        
Analysis
--------

Apache Camel realizes enterprise integration patterns ([EIP]) described in the book by [Hohpe and Woolf].
One of the most obvious but sometimes overlooked patterns is the simple [Service Activator Pattern].
Camel realizes this using the [Bean Component].
While the Camel Bean component provides clean separation of concerns from the mediation and routing side, management of the provisioning and lifecycle of beans is delegated to the container.

In some cases the added separation of concerns may also benefit the allocation of responsibility across development teams.
For example, business logic developers can continue to work with just POJO's while integration developers can focus on mediation logic.
This is true for both Spring and OSGI alternatives and can work effectively even across enteprrise organizational boundaries, e.g. SDK.

What is more complicated is when multiple service providers have to exist in the same runtime environment.
In many cases a Spring container is sufficient for the framework.
But in some cases the added power of OSGI services provide a more powerful alternative for enterprise solutions at runtime.
This is frequently the case in SaaS or iPaaS environments.
In these cases OSGI provides a standards based runtime environment that can successfully encapsulate different service realizations.

Since Camel supports Spring and Blueprint xml based configuration as well as Spring and Karaf containers, developers have a full set of choices.

[Talend Open Studio for ESB]: http://www.talend.com/download?qt-download_landing=4#qt-download_landing
[helloworld service]: https://github.com/EdwardOst/demo-template/tree/master/osgi/samples-1.0.0/blueprint/helloworld
[helloworld readme]: https://github.com/EdwardOst/demo-template/blob/master/osgi/samples-1.0.0/blueprint/helloworld/README.md
[helloworld samples]: http://aries.apache.org/documentation/tutorials/blueprinthelloworldtutorial.html
[Camel]: http://camel.apache.org/
[EIP]: http://camel.apache.org/enterprise-integration-patterns.html
[Hohpe and Woolf]: http://www.eaipatterns.com/
[Service Activator Pattern]: http://www.eaipatterns.com/MessagingAdapter.html
[Bean Component]: http://camel.apache.org/bean
[sample route]: /talend/camel/osgi/osgi_helloworld.zip
