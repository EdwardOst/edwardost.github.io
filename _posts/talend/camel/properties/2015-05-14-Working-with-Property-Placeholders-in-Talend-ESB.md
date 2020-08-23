---
layout: post
categories: [Cloud, Platform, SOA]
title: Externalizing Route Configuration
tagline: Working with Context Variables and Property Placeholders in Talend ESB
tags: [esb, camel, spring, osgi, karaf]
---
{% include JB/setup %}

This page documents some of the conventions around Studio Context Variables as well as how to use Camel Property Placeholders in Routes.  It covers both the Studio as well as Runtime configuration and concerns.


### Why are Property Placeholders better than Context Variables

Property Placeholders are part of the underlying framework for both Spring and Camel.  In contrast, Context Variables is a custom API limited to just Talend.  As such Context Variables will not work outside of code generated in Studio.  

Property Placeholders can be wired to the OSGI Config-Admin service which is part of the OSGI standard.  While this happens as well with Context Variables, it is done in a non-standard way which is again limited to Studio.  The Studio approach creates Config Admin services for the route, but they are not made visible via corresponding cfg files in the etc folder.  As a result, Context Variables cannot be easily edited by the Operations team during runtime except with the use of the TAC (although this document will show you how to do it using the Talend conventions).  

In contrast, Property Placeholders are easily and directly integrated with OSGI Config-Admin using either Spring or Blueprint.  Since Studio only supports Spring we stick to that here.

Even when connected to the OSGI Config Admin service, Studio Context Variables are not wired to Camel.  So you cannot use them using the simple {{myProperty}} format.  Instead you have to use quotes and build Java strings.  This can be a problem when dealing with complex Expression Builders in the GUI.  In contrast, PropertyPlaceholders are supported by both Spring and Blueprint flavors of Camel DSL as well as the Java DSL.

More fundamentally, the Talend Context Variable generated code hardcodes the explicit properties specified in Studio.  This results in unnecessarily tight coupling.  The basic Map style interface is sufficiently controlled and much more extensible and loosely coupled.

My recommendation is that you avoid using Context Variables when possible and just use Property Placeholders.

### Basic Property Placeholder Route Summary

A [basic sample route] is provided.  It should run out of the box.  I suggest publishing it via Nexus rather than using a Kar files.  A [more complex example] is also available.  It includes the complete end-to-end code that loads the Talend Context Variables and makes them available as Camel Property Placeholders.

![PropertyPlaceholder Sample Route](/talend/camel/properties/property_placeholder_sample_route.jpg)

The route shown above sends a message every five seconds.  The body of the message is initialized using both Camel Property Placeholders and Studio Context Variables using the cSetBody_1 expression below.

    context.prop1 + " {{prop2}} {{prop3}} "

![Talend Studio Context Variables](/talend/camel/properties/ContextVariables.jpg)
	
The {{prop2}} and {prop3}} are Camel Property Placeholders populated from properties Resources.  The cConfig component includes the code which connects the property resources to the CamelPropertyPlaceholder so the properties are available to the routes.  Exposed properties can be used in any Camel Expression with the {{propertyName}} syntax, and indeed can even be used to set a Camel Endpoint URI so that the transport and endpoint configuration are completely externalized.  

The properties resources are populated from properties files.  The path for one such resource is loaded from the Talend Context Variable configProperties.  Note the classpath: prefix.  This will search the jar in the Studio environment and the bundle in the runtime environment.  Any resources associated with the Route will be included in the deployed bundle.

The other property file is specified in the spring.xml file.  In the Studio environment this is done with a Spring PropertiesFactoryBean.  At runtime this is done with a Spring Dynamic Modules OSGI cm-properties bean.  These beans have the same id, and only one should be active in a given environment.

Note that when sharing Routes which have Resource dependencies with Export Items you should be sure to check the Export Dependencies box so that all Resources are included in the zip file.

Camel Properties are loaded sequentially, so any common keys will overwrite previous entries.  In this case the code in the cConfig loads the property file specified in the Talend Context first.  That means the properties specified in the Spring XML configuration will override them.

### Property Placeholders

If you are using Talend you already know what Context variables are.  However, you may not know what PropertyPlaceholders are.  PropertyPlaceholders are originally from Spring.  There is a similar concept in Camel.

In the [Spring PropertyPlaceholder] example below the properties file jdbc.properties is read and the properties with key jdbc.username and jdbc.password are used to initialize the username and password properties respectively on the java bean dataSource.  Note the default Spring syntax is to use ${propertyKey} to identify property placeholders.

	<bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
	  <property name="locations" value="classpath:com/foo/jdbc.properties"/>
	</bean>
	<bean id="dataSource" destroy-method="close"

		class="org.apache.commons.dbcp.BasicDataSource">
	  <property name="driverClassName" value="${jdbc.driverClassName}"/>
	  <property name="url" value="${jdbc.url}"/>
	  <property name="username" value="${jdbc.username}"/>
	  <property name="password" value="${jdbc.password}"/>
	</bean>

As noted in the documentation, [Spring Property Placeholders are not supported within Camel Spring XML], the Spring Property Placeholders will work in the non-Camel portions of the Spring XML file, just not within the Camel Context subject to the qualifications noted.  And of course Spring Property Placeholders are not supported when using Camel Java DSL which is what the Studio uses.  [Camel Property Placeholders] fill this gap.  They are similar but they use double curly-brackets {{ and }} to identify placeholders {{propertyKey}} (not sure if this will render in wiki).  In the example below Camel property placeholders are used extensively not just in primitive bean properties but in properties of the Camel Context itself.

	<camelContext trace="{{foo.trace}}" xmlns="http://camel.apache.org/schema/spring">

		<propertyPlaceholder id="properties" location="org/apache/camel/spring/processor/myprop.properties"/>
	 
		<template id="camelTemplate" defaultEndpoint="{{foo.cool}}"/>
	 
		<route>
			<from uri="{{mySourceEndpoint}}"/>
			<setHeader headerName="{{foo.header}}">
				<simple>${in.body} World!</simple>
			</setHeader>
			<to uri="{{myTargetEndpoint}}"/>
		</route>
	</camelContext>

### Context Variable Conventions

OK, Context Variables are bad but how do I use them?  The convention in Talend is that when you publish your route called MyRoute with Context Groups Default and Production, there will be three (not two) corresponding OSGI Configuration Admin configurations created.  They will have the service pid's shown below:

* MyRoute
* MyRoute.talendcontext.Default
* MyRoute.talendcontext.Production

You can display these Config Admin configurations from the karaf console using this command

	karaf> config:list | grep -i MyProperty
	
Or you can navigate to the Karaf console in the browser to Configuration Status->Configurations and do a search with ctrl-f in your browser.

![Configuration Status](/talend/camel/properties/configuration_status.jpg)

I find the Configuration Status view the easiest to use because it is just one long page and it shows everything.  However it does not allow you to edit anything.  You can edit Configurations using the Configuration tab in the Karaf Console shown below.

![Configuration](/talend/camel/properties/configuration.jpg)

You might well expect to see a separate cfg file in the etc folder for each of the three Config Admin configurations created for your Context Variables.However, if you check the containerBase/etc folder you will not find any.  If you create your own etc/MyRoute.cfg file you can override which Context Variable Group to use by setting the context property within the property file as shown below.

	# this value is case sensitive.  In our case we had two Studio Context Variable groups called 'Default' and 'karaf' so one of the two lines below would select the desired Context Variable group.

	# context = Default

	context = karaf

	prop1=parent-override

In the example above we have also overridden one of the context variables named 'prop1' and assigned it a new value that is presumably different than the value assigned in the Studio Context Variable group `karaf`.

You might expect that you could also override individual properties on a per Context Group basis.  For example, you might think that you could edit the MyRoute.talendcontext.karaf.cfg file and change the `prop1` value, thereby separating the configuration for different groups.  But that does not work.  Although the Config Admin configuration will get loaded into the OSGI environment, it will not be loaded sufficiently early in the bundle lifecycle to be used by the Camel Property Placeholder.  Instead, the parent configuration will be loaded, the camel property placeholder will be loaded, the route builders will be called (using just the parent configuration values), and then perhaps the child config admin will be loaded when it is too late.

So if you want to keep sets of custom overrides in the etc folder, I suggest copying and pasting entire sections dedicated to each individual configuration and block commenting out the entire section to keep it simple.

	# context = Default

	# prop1=default-prop1-override

	context = karaf

	prop1=karaf-prop1-override

### Camel Property Placeholder

So after all of that we can now use override Context Variables in the etc folder or via the Karaf console at runtime.  But we are still limited in how we use context variables to the clunky Java string manipulation.  We can only support the right portion of the Expression statement below in Studio.

![Context Variable Injection](/talend/camel/properties/ContextVariable_injection.jpg)

If we were using Camel with Spring we would use a PropertyPlaceholder element within the CamelContext element.  However, Studio does not use Spring XML (or Blueprint) configuration of Camel routes.  It uses JavaDSL.  So the appropriate method is to use the cConfig component as shown below.

	import org.apache.camel.component.properties.PropertiesComponent;

	propertiesComponent pc = new PropertiesComponent();
	pc.setLocation( "classpath:propertyPlaceholder/MyRoute.properties");
	camelContext.addComponent("properties", pc);

In the example above the myProperties.properties file will be looked up on the classpath.  

If you have more than one property file you can separate them with commas.

	import org.apache.camel.component.properties.PropertiesComponent;

	propertiesComponent pc = new PropertiesComponent();
	pc.setLocation( "classpath:propertyPlaceholder/MyRoute.properties,classpath:someOtherFile.properties");
	camelContext.addComponent("properties", pc);

Note that the key of the Camel Component must be properties by convention.

### Studio Route Resources

How can we add the properties file in the Studio so that it is on the classpath both in the Studio and when deployed to the runtime?  Create a Resource.  In the screenshot below the resource is created in the Studio folder PropertyPlaceholder.  This means that the relative path to the resource on the classpath will also be 'classpath:PropertyPlaceholder/MyRoute.properties'.

![Create Resource](/talend/camel/properties/create_resource.jpg)

You can either import an existing properties file or you can create an empty resource.  I suggest giving the resource a name with the .properties extension so that Studio will use the default properties editor when you open the resource.  The screenshot below shows the creation of an empty, new properties resource.

![Create Route Resource](/talend/camel/properties/NewPropertiesResource.jpg)

Finally, link the new resource to the Camel Route.

![Link Route Resource](/talend/camel/properties/ManageRouteResources.jpg)

![Link Route Resource](/talend/camel/properties/AddRouteResource.jpg)

### Property Resource Management

If we want to be a little clever, we can even manage which properties file we use via a the Context Variables.  In the code below the Studio Context Variables have already been loaded, so they can be reference in the cConfig component to lookup the resource path to be used.  (In this case we happen to use the same properties resource for both Karaf and Default configurations, but they could be different.)

	import org.apache.camel.component.properties.PropertiesComponent;

	PropertiesComponent pc = new PropertiesComponent();
	pc.setLocations( new String[]{ context.configProperties.toString() });
	camelContext.addComponent("properties", pc);

![Specify Property Files with Context Variables](/talend/camel/properties/SpecifyingPropertiesFiles_with_ContextVariables.jpg)


Another issue is having a single point of control for the properties resources we are loading as Camel Placeholder Properties.  It is easy to lose these details in the procedural code.  It is better to externalize them in the Spring XML and to centralize them in a single bean if possible.  Currently we have both OSGI Config-Admin loaded resources as well as classpath: resources.  We may wish to have both resources available to Camel.  Plus we will want to control the precedence for which resources act as the defaults and which are the overrides.  In order to have a single place to manage these declaratively, we introduce the Spring PropertiesFactoryBean in the XML section. 

	<!-- comment out when using in runtime -->
	<bean id="cmProperties" class="org.springframework.beans.factory.config.PropertiesFactoryBean">
		<property name="ignoreResourceNotFound" value="true"/>
		<property name="location" value="classpath:PropertyPlaceholder/property_placeholder_cm.properties"/>
	</bean>

We then reference the PropertiesFactoryBean in the cConfig code that loads the Camel PropertyPlaceholder with the ref: prefix.

	PropertiesComponent pc = new PropertiesComponent();
	pc.setLocation( context.configProperties.toString() + "," + "ref:cmProperties");
	camelContext.addComponent("properties", pc);

There is one last step remaining.  The new PropertiesFactoryBean is included in the Studio classpath, but it is not included in the runtime classpath unless we add it.  Fortunately it already deploy in the runtime container, so it is just a matter of adding it  package to our bundle classpath imports using the Edit Route Manifest as shown below.

![Specify Property Files with Context Variables](/talend/camel/properties/edit_route_manifest.jpg)

### Camel Property Placeholder

OK, so now we can have a separate properties file that follows normal Camel conventions and it will work in Studio.  Plus it will get shipped as part of the bundle since it is defined as a Resource.  We have the advantage of using standard Camel API's so our code is more portable, and it is easier to use with the {{property}} convention.  And we can specify multiple property resources which are still centrally managed.

Unfortunately it is not an OSGI Config-Admin service so it will still not be readily editable by the Operations team via a cfg file in the etc folder, nor will it be visible in the Config Admin service on either the karaf commandline or in the Karaf Console.

To use the OSGI Config-Admin service we can use the Spring XML configuration in Studio with 

	<!-- comment out when using in Studio -->
	<osgix:cm-properties id="cmProperties" persistent-id="property_placeholder_cm">
		<prop key="firstname">muffin</prop>
		<prop key="osgiProp">osgi-value</prop>
	</osgix:cm-properties>

Adding the xml above in the Spring tab in Studio will load an OSGI Config-Admin service with persistent-id of property_placeholder_cm.  If no such service exists, it will use the default properties for firstname and osgiProp specified.  If the Config-Admin service exists or has been instantiated by a file in the etc folder, the values in the etc properties file will take precedence.  By convention the name of the file would be persistent-id.cfg, so in this case it would be property_placeholder_cm.cfg.

We have specified the same id for this bean as the PropertyFactoryBean.  This means that it will be injected into the Camel Property Placeholder using our previous code, because the ref:cmProperties uri in the CamelPropertyPlaceholder location attribute will match our new OSGI cm-property, which happens to expose the same Property interface created the PropertyFactoryBean.  Unfortunately the osgi:cm-properties elements shown above will not work in Studio.  So you will need to comment them out until you are ready to publish your job.  In the Studio environment the PropertyBeanFactory should be used.  Before publishing to the runtime the PropertyFactoryBean should be commented out, and the osgi:cm-properties element should be uncommented.

Note that once deployed you you will need to restart the Camel bundle in order for any changes to the underlying Config Admin service to take effect because Camel uses a builder pattern, so once the route is created subsequent modifications to Config Admin service do not affect the already instantiated route.

### Connecting the Talend Context to Camel PropertyPlaceholder

Everything is just about ready now, but we still have two classes of properties.  Regular property resources can now be added and easily referenced. but the same is not true of Talend Context Variables.  If we merge the Talend Context Variables with the other properties in the CamelPropertyPlaceholder we will have access to all properties using the standard Camel API.

We will use this bean to aggregate however many property resources we wish to add to the Camel Property Placeholders.  The updated cConfig is shown below.

Properties configProperties;

	try {
		DefaultPropertiesResolver resolver = new DefaultPropertiesResolver();
		configProperties = resolver.resolveProperties(camelContext, false, context.configProperties);
	} catch (Exception e) {
		throw new java.util.MissingResourceException("Error loading resource: context.configProperties", this.getClass().getName(), context.configProperties.toString());
	}

	// this is necessary because the Talend context Property has its _defaults_ set, but these do not
	// initialize the actual Property collection itself.
	for (String property : context.stringPropertyNames()) {
		context.put(property, context.getProperty(property));
		}


	java.util.Properties contextProperties = camelContext.getRegistry().lookup("contextProperties", Properties.class);

	contextProperties.putAll(context);
	contextProperties.putAll(configProperties);

	PropertiesComponent pc = new PropertiesComponent();
	pc.setLocation( "ref:contextProperties,ref:cmProperties");
	camelContext.addComponent("properties", pc);

In the example above we will only load the property file identified by the Talend Context Variable configProperties if there is no OSGI Config-Admin with the persistent id of cmProperties.  When we run in the Studio the cmProperties bean will not exist, so the configProperties will be loaded based from the classpath: resource specified in the Talend Context.
 
Note that the sequence of loading is important.  In the example above the Talend Context Variables will be overwritten by any properties specified in the classpath properties file, and these will in turn be overwritten by the OSGI Config-Admin configuration file if present.

Also note that it is necessary to initialize the Talend Context Variables.  This may seem odd given that the Talend Context variable is extended from Properties.  But only the hardcoded Talend Context Variables are actually initialized.  These values and the setters are not loaded into the actual property.  The readContextValues() method only loads the context variable with defaults with the seeming copy constructor shown below.  But this is deceptive.  This is really quite a terrible piece of code which can result in fundamental semantic differences depending on how the Context is loaded.

	context = new ContextProperties(defaultProps);

Here is a link to the [more complex example] route exported as a zip.  That's it.  Hopefully this is helpful.

[basic sample route]: /talend/camel/properties/property_placeholder.zip
[more complex example]: /talend/camel/properties/property_placeholder_with_camel_context_var.zip
[Spring PropertyPlaceholder]: http://docs.spring.io/spring/docs/3.1.x/spring-framework-reference/htmlsingle/spring-framework-reference.html#beans-factory-placeholderconfigurer
[Spring Property Placeholders are not supported within Camel Spring XML]: http://camel.apache.org/how-do-i-use-spring-property-placeholder-with-camel-xml.html
[Camel Property Placeholders]: http://camel.apache.org/using-propertyplaceholder.html