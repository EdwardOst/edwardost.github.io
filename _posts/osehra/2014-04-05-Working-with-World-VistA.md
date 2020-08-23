---
layout: post
category : osehra
title: "Apache and WorldVistA"
tagline: "RPC Broker Configuration"
tags : [health, vista, osehra]
---
{% include JB/setup %}

This is the first in a series of posts documenting learning VistA.
The goal is to become modestly proficient with VistA so that we can stand up a working VistA instance.
We will then use open source integration technology from Apache to connect VistA to other enterprise functionality, whether in the cloud or on-premise.
This connectivity is provided using an Apache [Camel VistA connector].

## VistA Distribution

We originally started with the baseline [OSEHRA] distribution.
However, we soon found that the the OSEHRA distribution of VistA is more of a bare-bones installation.
It requires installation and configuration of many packages.
While it provides the core packages, it is not really a distribution that is appropriate for beginner VistA users.

After looking around a bit and getting some very valuable input from more experienced users (big thanks to Chris Uyehara), we settled on [WorldVistA] as a mature and stable distribution that is pure open source.
I would make the analogy of OSEHRA VistA as building your own Linux distribution from the kernel and core unix libraries, whereas WorldVistA is a ready-made shrink wrapped version that you can install and run similar to Ubuntu.

I was able to easily [download WorldVistA] on my windows Machine and then followed the instructions for the Cache version.
I used the single user Cache license since I wanted the easiest possible user experience.
However, Cache is ultimately not open source.
GTM provides an open source alternative, and I will probably try that with WorldVistA on Linux OS with GTM in the near future.

Everything went smoothly for the most part.
The one note I would make for Windows users is to be sure to install Cache with Administrator privileges.

In my case I wanted to test the Camel VistA connector running as a proxy between a VistA server and a VistA client.
WorldVistA also provides a download for a [CPRS] client.
After installing and launching Taskman, RPC Broker, and Mailman; I was able to connect with CPRS to the WorldVistA RPC Broker on the default 9211 port.

## Camel-VistA Proxy

At this point I introduced the Camel VistA proxy.
I made a copy of the CPRS shortcut so that I could modify the commandline parameters of the CPRS client to point to the Camel-VistA proxy on port 9201.
The camel proxy was then connecting to VistA on the original port (9211).

I encountered problems when I tried to connect from CPRS through the proxy because it turns out that there is a new version of the RPC Broker in the current release of WorldVistA.
The new RPC client is also used by CPRSv28, which is available via WorldVistA as well.
The new RPC Broker adds support for a variety of useful things like being able to connect through firewalls.
WorldVistA server supoprts both old and new RPC broker configurations for backward compatibility with older clients, e.g. previous versions of CPRS.
The WorldVistA CPRSv28 distribution is also backward compatible with the old RPC broker, so it successfully negotiated even with the old RPC broker.
But the Camel-VistA connector is only designed to work with the  new version of RPC Broker.

Unfortunately, my working copy of WorldVistA had defaulted to starting the old RPC Broker.
Fortunately, the WorldVistA community helped me resolve this issue quickly (big thanks to Nancy Anthracite and Joel Ivey).


## RPC Broker Configuration

You probaby won't need to do this yourself, since the community has already fixed it.
But perhaps you will need to support both old and new RPC Broker clients and this will be helpful.
Just in case here it is.
I have placed double asterisks aroudn the text that I entered.

### Quick Summary

* Connect to VistA with Terminal
* Verify Version of RPC Broker
* Start RPC Broker Logging
* Configure the RPC Broker Listener
* Start the RPC Broker
* Verify Version of RPC Broker

### Verify Version of RPC Broker

Use System Status command and look for the port number of your configured RPC Broker.
The default port for WorldVistA is 9211 shown in bold below.
If the Routine is XWBTCPL then it is the __OLD__ listener.
If the Routine is %ZISTCPS then is the __NEW__ listener.

    EHR>**D ^%SS**
                       Cache System Status:  8:14 pm 05 Apr 2014
     Process  Device      Namespace      Routine         CPU,Glob  Pr User/Location
        9512                             CONTROL           0,0     8
        5328                             WRTDMN          630,1049  9
        6116                             GARCOL            0,0     8
        9140                             JRNDMN         3203,0     8
        9232                             EXPDMN            0,0     8
        5868  //./nul     %SYS           %SYS.Monitor.Control
                                                     1135005,22497 8
        8772  //./nul     %SYS           MONITOR       41820,68    8
       10316  //./nul     %SYS           CLNDMN          255,21    8
        8720  //./nul     %SYS           RECEIVE       10965,584   8
        9308  //./nul     %SYS           ECPWork           0,0     8  ECPWORK
        8940  |TCP|1972   %SYS           %SYS.SERVER     255,49    8
        8332* |TRM|:|8332 %SYS           %SYS.ProcessQuery
                                                       95829,7389  8  UnknownUser
        9204  //./nul     EHR            %ZTM         322830,34762 8  UnknownUser
        9144  //./nul     %SYS           %CSP.Daemon    8670,1316  8
        9356  //./nul     %SYS           %SYS.TaskSuper38505,3129  8  TASKMGR
        9176  //./nul     EHR            %ZTMS1        15810,2222  8  UnknownUser
       10752  **|TCP|9211**   EHR      **XWBTCPL**       55590,8524  8  UnknownUser
     
    5 user, 12 system, 256 mb global/23 mb routine cache
 


### Start RPC Broker Logging

To view the RPC log, you will need to look at the RPC Broker logs.
Be sure that you scroll through any old log records.
Optionally, you may wish to delete all the old logs prior to starting up your new RPC broker instance.

    EHR>D KILLALL^XWBDLOG
    Remove all XWB log entries? No// YES

### Configure the RPC Broker Listener

If the RPC Broker does not match the version you want, then modify the listener.

    EHR>**D ^XUP**
     
    Setting up programmer environment
    This is a TEST account.
 
    Terminal Type set to: C-VT100
 
    You have 265 new messages.
    Select OPTION NAME: **EVE**
         1   EVE       Systems Manager Menu
         2   EVENT CAPTURE  ECX ECS MAINTENANCE     Event Capture
         3   EVENT CAPTURE (ECS) EXTRACT AU  ECX ECS SOURCE AUDIT     Event Capture
    (ECS) Extract Audit
         4   EVENT CAPTURE DATA ENTRY  ECENTER     Event Capture Data Entry
         5   EVENT CAPTURE EXTRACT  ECXEC     Event Capture Extract
    Press <RETURN> to see more, '^' to exit this list, OR
    CHOOSE 1-5: **1**  EVE     Systems Manager Menu
              Core Applications ...
              Device Management ...
              Menu Management ...
              Programmer Options ...
              Operations Management ...
              Spool Management ...
              Information Security Officer Menu ...
              Taskman Management ...
              User Management ...
       FM     VA FileMan ...
              Application Utilities ...
              Capacity Planning ...
              HL7 Main Menu ...
              Manage Mailman ...
              MAS Parameter Entry/Edit
    
    Select Systems Manager Menu Option: **OP**erations Management
              System Status
              Introductory text edit
              CPU/Service/User/Device Stats
       RJD    Kill off a users' job
              Alert Management ...
              Alpha/Beta Test Option Usage Menu ...
              Clean old Job Nodes in XUTL
              Delete Old (>14 d) Alerts
              Foundations Management
              Kernel Management Menu ...
              Post sign-in Text Edit
              RPC Broker Management Menu ...
              User Management Menu ...
 
    Select Operations Management Option: **RPC** Broker Management Menu
              RPC Listener Edit
              Start All RPC Broker Listeners
              Stop All RPC Broker Listeners
              Clear XWB Log Files
              Debug Parameter Edit
              View XWB Log
 
    Select RPC Broker Management Menu Option: **RPC LIST**ener Edit
    Select RPC BROKER SITE PARAMETERS DOMAIN NAME: **?**
        Answer with RPC BROKER SITE PARAMETERS DOMAIN NAME, or STATUS:
       BETA.VISTA-OFFICE.ORG
 
    Select RPC BROKER SITE PARAMETERS DOMAIN NAME: **`1**   BETA.VISTA-OFFICE.ORG
        Select BOX-VOLUME PAIR: EHR:TRYCACHE//
        BOX-VOLUME PAIR: EHR:TRYCACHE//
        Select PORT: 9211//
          PORT:  9211//
          STATUS: STOPPED//
          TYPE OF LISTENER: **?**       **[this is the missing default, it should be set to New]**
           Choose from: 
             0        Original
             1        New Style
          TYPE OF LISTENER: **1**  New Style
          CONTROLLED BY LISTENER STARTER: YES//
 
    Select RPC BROKER SITE PARAMETERS DOMAIN NAME:

### Verify Version of RPC Broker

Rerun the System Status command and check for XWBTCPL (OLD) or %ZISTCPS (NEW) listener.

    EHR>D ^%SS
                   Cache System Status:  8:53 pm 05 Apr 2014
     Process  Device      Namespace      Routine         CPU,Glob  Pr User/Location
        9512                             CONTROL           0,0     8
        5328                             WRTDMN          864,1458  9
        6116                             GARCOL            0,0     8
        9140                             JRNDMN         4370,0     8
        9232                             EXPDMN            0,0     8
        5868  //./nul     %SYS           %SYS.Monitor.Control
                                                     1546575,30501 8
        8772  //./nul     %SYS           MONITOR       45900,71    8
       10316  //./nul     %SYS           CLNDMN          510,39    8
        8720  //./nul     %SYS           RECEIVE       15045,799   8
        9308  //./nul     %SYS           ECPWork           0,0     8  ECPWORK
        8940  |TCP|1972   %SYS           %SYS.SERVER     255,49    8
        8584* |TRM|:|8584 %SYS           %SYS.ProcessQuery
                                                       50898,3451  8  UnknownUser
        9204  //./nul     EHR            %ZTM         444465,47879 8  UnknownUser
        9144  //./nul     %SYS           %CSP.Daemon   11730,1786  8
        9356  //./nul     %SYS           %SYS.TaskSuper52530,4258  8  TASKMGR
        2612  **|TCP|9211**   EHR      **%ZISTCPS**      64770,9176  8  UnknownUser
       11192  //./nul     EHR            %ZTMS1         5355,296   8  UnknownUser
     
    5 user, 12 system, 256 mb global/23 mb routine cache


### Review the RPC Log

Look for the square brackets as an indicator that the new version of the RPC broker is being used.

    EHR>D VIEW^XWBDLOG
    
    Log Files
     
    Log from Job 3320 17 Lines
    14:50:07 = Log start: Apr 05, 2014@14:50:07
    14:50:07 = XWBTCPM
    14:50:07 = rd: **[XWB]**
    14:50:07 = MSG format is [XWB] type NEW
    14:50:07 = rd: 1130
    14:50:07 = rd: 2
    14:50:07 = rd: \05
    14:50:07 = rd: 1.106
    14:50:07 = rd: \11
    14:50:07 = rd: XWB IM HERE
    Return to continue, Next log, Exit: Continue//


[Camel VistA connector]: https://github.com/OSEHRA/vista-soa-ri
[OSEHRA]: http://www.osehra.org/
[WorldVistA]: http://worldvista.org/
[download WorldVistA]: http://worldvista.org/Software_Download
[CPRS]: http://worldvista.org/Software_Download/worldvista_ehr_v2_clients