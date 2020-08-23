---
layout: post
categories: [camel, rest]
title: Create a REST Proxy with Camel
tagline: Talend Studio
tags: [talend, camel, rest, json, xml]
---
{% include JB/setup %}

Here is a short **[video]** showing how to quickly create a [REST proxy route] using Apache Camel in Talend Studio.

![REST proxy](/talend/camel/rest/camel-rest-proxy.png)

Value added mediation begins with the ability to proxy service endpoints.  This allows the infrastructure to add security, reliable message delivery, location independence, exception management, logging, and other enterprise concerns to basic services.  So although this example is very simple, it is also fundamental for building more complex integrations.

To create a proxy for a REST service Talend Studio uses the cHTTP endpoint.  When used at the beginning of a route, the cHTTP endpoint uses the [camel-jetty] component to create a Camel _consumer_ to receive http messages.  Talend Studio also uses the cHTTP endpoint to create a Camel _producer_ that invokes the actual service using the [camel-http] component.

Camel consumers will automatically map http request headers to Camel headers.  This is great since you can manipulate them with Camel's large set of predicate and expression languages.  However, Camel producers may also Camel headers to outbound messages.  Sometimes this is desired behavior.  Other times it is not.  So be diligent in managing your headers.  When in doubt, program defensively and use [removeHeaders] to clean out unwanted headers before sending a message to a Camel producer.

Likewise, when parsing inbound messages consider whether you should save the information to a message header or an exchange property.  Exchange properties will not be sent to external processes by camel producers, and they will be available for the life of the exchange, whereas message headers may no longer be available after a response from a Camel producer overwrites the original message.

When creating or proxying a web service, be sure to follow standard REST conventions such as respecting the HTTP ACCEPT header, and using the Content-Type header in the response.  Supporting both XML and JSON is easy with Camel.  Just use the [camel-xmljson] data format.

You will need to load some addition dependencies using the cConfig component in order to run the camel-xmljson data format.  Version numbers will vary based on your current Studio version.  All libraries are available internally.  
* camel-xmljson-2.10.4
* json-lib-2.4-jdk15.jar
* xom-1.2.7.jar
* commons-lang-2.6.jar
* ezmorph-1.0.6.jar
* commons-collections-3.2.1.jar
* commons-beanutils-1.8.3.jar

[video]: http://www.youtube.com/watch?v=UE7zoPLinOI
[REST proxy route]: /talend/camel/rest/r02_arin_rest_proxy.zip
[camel-jetty]: http://camel.apache.org/jetty.html
[camel-http]: http://camel.apache.org/http.html
[removeHeaders]: http://camel.apache.org/how-to-avoid-sending-some-or-all-message-headers.html
[camel-xmljson]: http://camel.apache.org/xmljson.html
