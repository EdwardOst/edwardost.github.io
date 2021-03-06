---
layout: post
categories: [Cloud, Platform, SOA]
title: Service Containers
tagline: Platform-Centric Enterprise Integration
tags: [container, osgi, spring, karaf]
---
{% include JB/setup %}

This is the first in a series of posts on container-centric integration architecture. This first post provides a common definition of Container and how containers are used in an enterprise Java context.  Subsequent posts will explore how SOA and Cloud strategies are driving the need for OSGI Containers that provide modularity and dependency management for Java.  Finally, we will apply these principles to explore two alternative solution architectures using OSGI service containers for Enterprise Integration.


### Containers

Containers are referenced everywhere in the Java literature but seldom clearly defined.  Traditional Java containers include web containers for JSP pages, Servlet containers such as Tomcat, EJB containers, and lightweight containers such as Spring.  Fundamentally containers are just a framework pattern that provides encapsulation and separation of concerns for the components that use them.  Typically the container will provide mechanisms to address cross-cutting concerns like security or transaction management.  In contrast to a simple library, a container wraps the component and may address lifecycle aspects including classloading and thread control.

Spring is the archetype container and arguably the most widely used container today.  Originally servlet and EJB containers had a programmatic API.  Most containers today follow Spring’s example in supporting Dependency Injection patterns.  Dependency Injection provides a declarative API for beans to obtain resources needed to execute a method.  Declarative Dependency Injection is usually implemented using XML configuration or annotations and most frameworks will support both.  This provides a cleaner separation of concerns so that the bean code can be completely independent of the container API.

Containers are sometimes characterized as lightweight containers.  Spring is an example of a lightweight container in the sense that it can run inside of other containers such as a Servlet or EJB container.  Lightweight in this context refers to the resources required to run the container.  Ideally a container can address specific cross-cutting concerns and be composed with other containers that address different concerns.

Of course, lightweight is relative and how lightweight a particular container instance is depends on the modularity of the container design as well as how many modules are actually instantiated.  Even a simple Spring container running in bare JVM can be fairly heavyweight if a full set of transaction management and security modules are installed.  But in general a modular container like Spring will allow configuration of just those elements which are needed.

Open Source Containers typically complement Modularity with Extensibility.  New modules can be added to address other cross-cutting concerns.  If this is done in a consistent manner, an elegant framework is provided for addressing the full spectrum of design concerns facing an application developer.  Because containers decouple the client bean code from the extensible container modules, the cross-cutting features become pluggable.  In this manner open source containers provide an open architecture foundation for application development. 

Patterns are a popular way of approaching design concerns and they provide an interesting perspective on containers.  The Gang of Four Design Patterns book categorized patterns as addressing Creation, Structure, or Behavior.  Dependency Injection can be viewed as a mechanism for transforming procedural Creation code into Structure.  Containers such as Spring also have elements of Aspect Oriented Code which essentially allow Dependency Injection of Behavior.  This allows transformation of Behavioral patterns into Structure as well.  This simplifies the enterprise ecosystem because configuration of structure is much more easily managed than procedural code.

