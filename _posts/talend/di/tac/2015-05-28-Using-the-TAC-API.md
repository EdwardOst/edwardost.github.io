---
layout: post
categories: [talend, di]
title: Using the TAC API
tagline: Integrate and Manage Talend Jobs with your Application
tags: [talend, parameter, context]
---
{% include JB/setup %}

Talend Jobs are scheduled via the Job Conductor and they are parameterized with Context variables.  The Talend Administration Center (TAC) provides a browser management interface.  But many times it desirable to have programmatic control of Jobs via an API.  This post covers how to expose Talend Jobs via the TAC API.  It provides sample jobs, some useful browser utilities, and an example of a wrapping the TAC API in a RESTful service layer using Data Services.

### Overview

The Job Conductor is easy to use and powerful, but it has limitations.  The schedule can be a simple schedule or a more complex Cron schedule.  Jobs can also be triggered by a file trigger.  Finally, jobs can launched by the TAC operators manually from the browser.  With exception of the file trigger, the job is still running at a pre-determined time or with explicit human intervention.  Using file triggers as the mechanism for inter-process communication is clunky at best, and may also require access privileges which are not allowed in a secure environment.  It is preferable to be able to invoke a Talend Job via a real API.

Jobs can also be parameterized with Context variables.  Context variables can be overridden by system administrators in the Job Conductor to provide additional flexibility.  But when the job is run it is always run with the same set of pre-configured Context variables, whether they are the default values or the overridden values, they cannot be changed without human intervention.  It is preferable to be able to pass parameters via an API.

One option is to [build Jobs] as self-contained zip files.  The generated zip files will include windows and linux scripts for launching, the they with contain all necessary jars.  But there are drawbacks to this approach.  The resulting Jobs are run in isolation and lack the monitoring, management, and control provided by the TAC.  There is no centralized logging.  There is no concept of Job Servers or a Job grid.  Instead, these responsibilities fall on the developer.  As individual solutions proliferate the management of the broader system becomes more difficult and the maintenance tail becomes more unwieldy.

So while exported Jobs provide flexibility, they sacrifice manageability.  This trade-off is not necessary.  The TAC API provides a very simple and powerful alternative.  The TAC is included in all enterprise subscriptions.

### TAC API

The [TAC metaservlet] API is documented in the TAC User's Guide.  It is an RPC style HTTP API, i.e. it is not restful.  But it is very easy to use, and it can be easily wrapped with a RESTful interface if desired.

All TAC metaservlet operations are invooked via an HTTP get request.  All parameters to the operation are encoded as a single, unnamed base-64 encoded parameter to the get request.

While the metaservlet documentation is included in Appendix B of the TAC User's Guide, the detailed operations are documented in the TAC commandline itself.  The TAC commandline is available in the WEB-INF/classes directory within the TAC directory.  On windows the full default path is `C:/Talend/5.6.2/tac/apache-tomcat/webapps/org.talend.administrator/WEB-INF/classes/MetaServletCaller.bat`.  There is a similar `MetaServletCaller.sh` script for linux.

Running the MetaServletCaller with no arguments shows the top level help message

	C:\Talend\5.6.1\tac\apache-tomcat\webapps\tac\WEB-INF\classes>MetaServletCaller.bat
	usage: Missing required option: url
	 -f,--format-output          format Json output
	 -h,--help                   print this help message
	 -json,--json-params <arg>   Required params in a Json object
	 -url,--tac-url <arg>        TAC's http url
	 -v,--verbose                display more informations

In order to get the full detailed help message the TAC service itself must be running and you must pass the `--tac-url` parameter.  Use `--help all` for the full help, and the `-h all` for an abbreviated version.  The examples below capture the output to a text file for subsequent reference.

	C:\Talend\5.6.1\tac\apache-tomcat\webapps\tac\WEB-INF\classes>MetaServletCaller.bat --tac-url=http://localhost:8080/tac/ -help all > tac-help.txt

    C:\Talend\5.6.1\tac\apache-tomcat\webapps\tac\WEB-INF\classes>MetaServletCaller.bat --tac-url=http://localhost:8080/tac/ -h > tac-help-short.txt

There are three operations we are interested in.  We are primarily interested in the `runTask`.  The documentation is extracted below.

	----------------------------------------------------------
	  Command: runTask
	----------------------------------------------------------
	Description             : Allows to run a task defined in Job conductor by its id. Mode can be 'asynchronous' or 'synchronous'
	Requires authentication : true
	Since                   : 4.2
	Sample                  : 
	{
	  "actionName": "runTask",
	  "authPass": "admin",
	  "authUser": "admin@company.com",
	  "mode": "synchronous",
	  "taskId": 1
	  **"context": null** 
	}
	Specific error codes    : 
		   30: Error while launching task
		   31: Thread interupted while running
		   32: No right to run this task
		   33: The parameter 'mode' must have the value 'synchronous' or 'asynchronous'
	
The first thing to note is that in order to run a task we must know its system generated `taskId`.  We will use the `getTaskIdByName` operation shown below to look up the `taskId` for a given `taskName`.

The second thing to note is that there is a _very_ important but undocumented argument.  The `context` argument shown above is not in the generated help, see [TDI-32519].

	----------------------------------------------------------
	  Command: getTaskIdByName
	----------------------------------------------------------
	Description             : Get task id by given taskName
	Requires authentication : true
	Since                   : 5.1
	Sample                  : 
	{
	  "actionName": "getTaskIdByName",
	  "authPass": "admin",
	  "authUser": "admin@company.com",
	  "taskName": "task1"
	}


### Invoking the TAC API Interactively

When working with the metaservlet API interactively as a developer, it can be useful to interactively invoke the TAC API.  

The first thing we need to know is the taskId of the job conductor entry we want to run.  When we use the TAC API programmatically we will use the getTaskIdByName operation.  When working interactively we can use the TAC to display the taskId.  Go to the Job Conductor, select any of the columns, and then make sure the `Id` column is checked so that it will be displayed.

![base-64 encoding](/talend/di/tac/job_conductor_id_column.jpg)

Now that we have the taskId we can invoked the job, but we first need to base-64 encode our JSON arguments.  You can use the https://www.base64encode.org/ to do this as shown below.

![base-64 encoding](/talend/di/tac/base64-encode.jpg)

Then paste the resulting base64 encoded string as shown below into the browser.

    http://localhost:8080/org.talend.administrator/metaServlet?ew0KICAiYWN0aW9uTmFtZSI6ICJydW5UYXNrIiwNCiAgImF1dGhQYXNzIjogInRhZG1pbiIsDQogICJhdXRoVXNlciI6ICJ0YWRtaW5AZW9zdC5uZXQiLA0KICAibW9kZSI6ICJhc3luY2hyb25vdXMiLA0KICAidGFza0lkIjogIjgiDQp9DQo=

This url can even be added as a bookmark if desired.  If you are a fan of the Postman Chrome app you can use that instead and save the HTTP get request in a Collection.

The result of the HTTP get message is returned as JSON to the object. It includes the execRequestId which is the handle for your new job instance.

	{
	execRequestId: "1432855205979_a5zn8",
	executionTime: {
	millis: 564,
	seconds: 0
	},
	returnCode: 0
	}

		
Once the browser HTTP get message is sent, you can monitor the progress of in the Execution History.

![base-64 encoding](/talend/di/tac/tac_execution_history.jpg)

### Invoking the TAC API Programmatically

In order to successfully invoke the TAC API, the JSON objects shown in the samples above must be base-64 encoded.  Once the JSON arguments are base-64 encoded, they can be passed as the sole parameter to the HTTP get request.  Of course, if you are integrating with Talend there is a good chance that your application is written in regular Java, or possibly even some other language.  This is no problem since the HTTP get and base-64 are interoperable standards.

If you happen to be integrating with a Java application, you use the Apache Commons Base64 class encodeBase64 method, `org.apache.commons.codec.binary.Base64.encodeBase64()`.  If you are using Talend, use the tLibraryLoad to add the Apache Commmons library.  The attached [metaservlet client job] shown below invokes the TAC API from a Talend Job.

![metaservlet client](/talend/di/tac/invoking_tac_api.jpg)

It uses the encodeBase64() method within a tMap prior to the tRESTclient invocation of the TAC API operations.  Three operations are invoked.  Each operation is invoked within its own SubJob.  Each SubJob starts by initializing the request from the Context Parameters.  The first invocation looks up the taskId based on the human readable job name.  The second invocation uses the taskId returned from the first invocation to trigger the job.  The third invocation uses the returned execRequestId handle as the argument to the getTaskExecutionStatus operation to monitor the job status.

### Creating a RESTful TAC API

The examples above us the metaservlet API.  The metaservlet API uses http as a transport for what are essentially RPC calls with a JSON payload.  But it is not restful.  If you are using Talend Platform for Data Services or Talend MDM you can easily create a [RESTful TAC API].  An example is attached and shown below.

![restful tac api](/talend/di/tac/tac_rest_service.jpg)

The runTask is associated with the HTTP POST event for the url /tasks/{taskName}.  From a RESTful perspective, each Job execution instance is appending its history and status to the Job.  The url path is parsed by the tRESTrequest and used to invoke the metaservlet getTaskIdByName which is then used by the runTask operation.  The POST event returns the execRequestId currently in JSON format, but a truly RESTful implementation would return the execRequestId as url of the form /tasks/{taskName}/{execRequestId}.  This path would then be mapped to the getTaskExecutionStatus operation.

### Known Bugs

Some notes are in order.  First, note that the result returned by the getTaskIdByName is not proper JSON.  There are no enclosing quotes around the field named task Id.  So we need to use a regex to replace it prior to parsing the JSON, see [TDI-32706].

Second, the runTask operation does not document the context argument but it is supported, see [TDI-32519] 

Third, the runTask operation supports the context argument, but the metaservlet API will not parse it correctly if it is the last argument in the JSON payload that is submitted, see [TDI-32380].  The work-around here is just to make sure that the context variable is not the _last_ argument.  It is fine if it is passed as the second to last argument.

[build Jobs]: https://help.talend.com/display/TalendPlatformforDataManagementStudioUserGuide56EN/5.2.2+How+to+build+Jobs
[TAC metaservlet]: https://help.talend.com/display/TalendAdministrationCenterUserGuide56EN/B.+Non-GUI+operation+in+metaServlet
[metaservlet client job]: /talend/di/tac/tac_api_run_and_monitor-5.6.1.zip
[RESTful TAC API]: /talend/di/tac/tac_api_run_service-5.6.1.zip
[TDI-32380]: https://jira.talendforge.org/browse/TDI-32380
[TDI-32706]: https://jira.talendforge.org/browse/TDI-32706
[TDI-32519]: https://jira.talendforge.org/browse/TDI-32519