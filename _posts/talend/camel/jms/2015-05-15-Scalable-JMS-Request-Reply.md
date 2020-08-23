---
layout: post
categories: [talend, camel]
title: Scalable JMS Request-Reply
tagline: Transacted JMS Routes in Talend Studio
tags: [talend, camel, jms, eip, routing]
---
{% include JB/setup %}

Using JMS correctly in a scalable manner is not trivial.  It requires using the appropriate set of message exchange patterns (MEP) in a manner that takes into account failover, fault tolerance, and delivery qualities of service (QoS).  In particular, when routes are built using request reply semantics, it is _not_ a given that an InOut MEP is the appropriate design choice.

There is an excellent discussion of this topic on the [Camel JMS component].  However, it is rather abstract, and there are no systematic examples provided.  Attached are a number of sample routes that demonstrate using JMS in our Talend Studio.

### Basic Concepts

First, a quick review of Camel and JMS terminology.  These terms are related and frequently overloaded.  The definitions below are used in this post, and are broadly consistent with industry usage, but idiom varies.  

Service Providers and Consumers are independent of transport.  It is possible for Service Providers and Consumers to support multiple transports.
* Service Consumer - the set of logical endpoints responsible for consuming business information from a service provider.  The service consumer might be a request-reply client, or it could be a subscriber to a publishing provider.  A request reply client might receive responses synchronously, or it could receive messages asynchronously on a possibly different callback endpoint.  A subscriber might be listening on a JMS endpoint, or it could just be receiving notifications on a callback style SOAP or REST endpoint that was registered with the publisher.
* Service Provider - the set of logical endpoints responsible for delivering a service to a consumer.  It could a simple request-reply SOAP or REST endpoint, it could be a service that is publishing notifications to a JMS queue or topic.

JMS is one possible transport that provides a broad variety of Quality of Service (QoS) to its clients, including guaranteed delivery.
* JMS Client - all applications that use JMS are JMS clients, whether they are sending or receiving messages.
* JMS Sender - a JMS client that is sending a JMS message.  The sender could be sending a request or a response.
* JMS Receiver - a JMS client that is receiving a JMS message.  The receiver could be a polling receiver or a message listener.  It could be receiving the original request, or an acknowledgement.

[Enterprise Integration Patterns] (EIP) design patterns focused on integration made popular in the book of the same name by Gregor Hohpe and Bobby Wolf.

* [Routing Slip EIP] is a particular design pattern in which the a sequence of logical endpoint destinations are attached to a message.  Routing can be either static or dynamic.

[Apache Camel] is a Java library realizating EIP along with a wide variety of other integration concerns.  Camel Components act as factories for Endpoints which encapsulate transports with a uniform Camel API consistening of an Exchange that contains a Message with a body and headers.  Exchanges travel along Routes that consist of Consumer Endpoints, Processors, and Producer Endpoints.
* Camel Consumer: is a Camel endpoint that receives a Message from other processes.  These messages could be from other systems, other processes on the same VM, or other camel routes.  Each consumed message has its own Exchange context.
* Camel Producer: is a Camel endpoint that sends a Message to other processes.

Each Camel Message has an associated Message Exchange Pattern (MEP).  Some Camel Consumers can only receive one type of MEP, other Camel Consumers can process both types of MEP.  Likewise, some Camel Producers can only send one type of MEP, while others can send both types of MEP.
* InOut: each input message will eventually result in a single return message sent to the client.
* InOnly: an input message will not result in any output message being sent to the client.

### Use Case

The basic use case is to send a transacted message to a service which is listening on a JMS queue.  The service provider may or may not provide a business reply, but it should usually provide some kind of acknowledgement.

In some cases, the service could provide an actual reply based on the output of the service or whether an update to the database succeeded.  In this cases the reply is generated synchronously with respect to the receipt of the JMS request.  

In other cases, the service could provide a system generated id or handle for the request.  Or the service might provide a url which the client can subsequently poll.  In these cases the reply is generated asynchronously with respect to the actual processing of the request.

The  service consumer could be a relatively simple client application communicating via JMS, or the service consumer could be a mediation route using enterprise integration patterns (EIP) to integrate the service into a composite workflow.  In the latter case, a [routing slip EIP] could be used.  This pattern might be realized using a [Camel routing-slip] in the mediation route, but it could also be realized using JMS reply-to headers.

We want a wrapper for _both_ the service provider _and_ the service consumer that supports JMS transaction semantics regardless of the routing implementation strategy selected.  The main focus of this post is to encapsulate the JMS API in a flexible way with respect to a message exchange pattern regardless of the orchestration mechanism used.

### Transaction Scope

The main goal here is simply that the JMS receive/send pair participate in a transaction.  If the service throws an exception, the message will rollback to the receiving queue.  If for some reason the response send message cannot be placed back onto the JMS provider, the target transaction source (e.g. a database) will rollback and the message will again be restored to the receiving queue.  This post does not cover the details of transaction strategy implementation, but both two-phase commit (2pc) or a transactional resource integrated via JMS API semantics could be used.  

### Design Alternatives

In the Camel routing-slip approach there is a single Camel process that is sending the message to a series of endpoints.  The endpoints are enumerated in a Camel header.  One of these endpoints happens to be the service provider in question and the transport happens to be a Camel JMS endpoint.  In order for the other Camel endpoints in routing slip to be subsequently invoked, the JMS message must be sent with request-reply semantics using the JMS replyTo property.

In this approach the message flow between systems goes from the Camel mediation route acting as the service consumer to the Camel JMS producer endpoint acting as a JMS sender, then to the JMS broker, and then to the JMS receiver.  In our case the JMS receiver is also implemented as a Camel consumer for the service provider.  This second camel instance  is logically separate from the mediating route.

ADD DIAGRAM

There are multiple design challenges.  The challenge for the service consumer is to send the message in a fault tolerant manner.  The default JMS request-reply approach uses temporary queues.  Temporary queues are by definition tied to a specific JMS client.  Only that client instance can receive the reply.  If the camel mediation server fails, no other JMS client will be able to receive the message.  So this is not a good HA option.  The alternative is to use a regular queue as the replyTo destination.  In the event of failure another JMS client will be able to receive the reply message.

The challenge for the service provider is to receive the message and provide a transacted reply using Camel.

In this first approach there is a dedicated integration broker provided by the camel mediation route.  Therefore, there is an extra hop in the message routing for each entry in the recipient list since the message must return to the mediation engine after each service invocation.  A potentially more efficient approach is to provide the routing slip in the replyTo of the JMS message, so that the response is sent directly to the next routing slip recipient.

### Example Routes

The first is r01_jms_inonly_receiver.  It acts as the "server" in this example.  It prepends the word "hello" to the payload of whatever it receives.  This route should be running in order to test the others.  It is notable in that it manually uses the the cFilter component to test for the presence of a JMSReplyTo header.  If it is present it uses the JMSReplyTo header to send the message.  This is important because Camel only support JMS transactions if using the  InOnly MEP.

The pattern of a single JMS transaction spanning the receive / send pair is very common so this shows how you can implement it while still preserving flexibility.  

By default, a JMS camel consumer will have an InOut MEP, but typically .

The second route is r02_jms_inonly_sender.  As the name implies, it will send messages to the "server" using a variety of different MEP patterns.  There are Notes in the route itself describing the different variations.  There are a few variations they are all included in the single camel context, so all but one of them should be deactivated when running the samples.  the first InOnly client does not even get a response to the route.  It is solely to demonstrate that the when inOnly MEP is specified there is no temporary queue created for the response, and that the next element in the route is triggered immediately (rather than waiting for the reply) and it receives the same Camel message that was sent via JMS.

The second route is really two routes that work together (shown in the next two lines).  It is more or less the same as the previous route, but it uses the replyTo option of the Camel-JMS endpoint to specify a fixed queue for the response.  The second stubby route listens on that queue for the response.  Read the camel JMS documentation http://camel.apache.org/jms.html for a description of how these options interact.  Note in particular that the camel option replyTo is different than the JMSReplyTo header.  Also note that things are case sensitive.

The third route is really three routes shown at the bottom of the page.  This is the main route to understand.  When you want to do request-reply type integration in a failover and fault tolerant manner you don't want to use temporary queues which are automatically created for you by Camel JMS.  That is because temporary queues are local to the client and won't failover, and they also won't scale since there is by definition only one consumer.  Plus they are slow since they poll the queue.

Camel-JMS provides the option for exclusive fixed reply queues, but the problem is these are exclusive to the particular camel route.  So it does not scale to a cluster without additional effort to manage the different unique reply-to instances.

So the approach taken here is to use vanilla InOnly MEP with a replyTo queue for a fixed queue.  Since inOnlyMEP is specified, Camel will  _not_ set up the usual internal listener.  Instead, we manually set up another InOnly listener.  Both the original request and the response receive by the listener are then routed to an Aggregator.  The sample Aggregation Strategy takes the original request message and attaches it to the response.

The third route is r03_jms_inout_sender.  If you do want to use native camel jms request-reply interactions, this demonstrates how to do it.

Here is a link to the download https://wiki.talend.com/download/attachments/1643033/JmsMep.zip .

[Enterprise Integration Patterns]: http://www.enterpriseintegrationpatterns.com/
[routing slip EIP]: http://www.enterpriseintegrationpatterns.com/RoutingTable.html
[Apache Camel]: http://camel.apache.org/
[Camel routing-slip]: http://camel.apache.org/routing-slip.html
[Camel JMS component]: http://camel.apache.org/jms.html
