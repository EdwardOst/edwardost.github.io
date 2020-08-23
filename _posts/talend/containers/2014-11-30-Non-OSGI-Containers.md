---
layout: post
categories: [Container, Talend]
title: Talend ESB Containers
tagline: Can I use Talend ESB in Tomcat or JEE Servers?
tags: [container, osgi, talend, karaf]
---
{% include JB/setup %}


The [Installation and Upgrade Guide](https://help.talend.com/display/TalendPlatformforDataServicesInstallationandUpgradeGuide55EN/Home) lists [compatible Runtime containers](https://help.talend.com/display/TalendPlatformforDataServicesInstallationandUpgradeGuide55EN/1.7+Compatible+Runtime+Containers) which are supported for enterprise subscription customers.  These JEE containers are supported with limitations captured in the footnotes.  This document elaborates on the constraints and their implications for development environments and solution architecture.

Containers host both Application Services as well as Infrastructure Services.  Application Services are business domain services designed by users of Talend.  They can also be designed visually with Talend Studio, or they can be designed programmatically with Java and Spring or Blueprint in a traditional Eclipse environment.

Talend Studio supports two types of Application Service designs.  Service enablement is done with Data Services for REST, SOAP, or JMS (in 5.6) designed in the Integration Perspective.  Mediation Routes provide Composite Services designed in the Mediation Perspective.

Visual design with Talend Studio Routes or Data Services only supports deployment to the Talend Karaf container.  Talend Studio visual designs cannot be deployed to any other container such as Tomcat, WebSphere, WebLogic, or JBoss.

Infrastructure Services are supplied as part of the ESB and are typically configured rather than designed.  Infrastructure Services include the Service Activity Monitor (SAM), Security Token Service (STS), Identity Management (IDM), and Enterprise Logging.

Infrastructure Services can only be deployed to the Talend Karaf container or Tomcat.  Infrastructure services cannot be deployed to any of the JEE containers such as WebSphere, WebLogic, or JBoss.

Of course, these services are interoperable regardless of hosting platform since they are realized with open standards such as SOAP, REST, and JMS.  This information is summarized in more detail below.

|                                   | Application Services                  | Data Services | Infrastructure Services |
|-----------------------------------|---------------------------------------|---------------|-------------------------|
| Talend OSGI,Runtime (Apach Karaf) | Studio or Eclipse Spring or Blueprint | Talend Studio | All except IDM          |
| Tomcat                            | Eclipse Spring                        | No            | All                     |
| JBoss                             | Eclipse Spring                        | No            | None                    |
| WebLogic                          | Eclipse Spring                        | No            | None                    |
| WebSphere                         | Eclipse Spring                        | No            | None                    |