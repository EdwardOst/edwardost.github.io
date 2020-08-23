-- MySQL dump 10.13  Distrib 5.1.61, for Win64 (unknown)
--
-- Host: localhost    Database: scd
-- ------------------------------------------------------
-- Server version	5.1.61-community

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `address` varchar(16) DEFAULT NULL,
  `city` varchar(14) DEFAULT NULL,
  `company` varchar(13) DEFAULT NULL,
  `firstName` varchar(8) DEFAULT NULL,
  `id` int(2) DEFAULT NULL,
  `lastName` varchar(10) DEFAULT NULL,
  `previous_address` varchar(16) DEFAULT NULL,
  `previous_city` varchar(14) DEFAULT NULL,
  `scd_active` bit(1) NOT NULL,
  `scd_end` datetime DEFAULT NULL,
  `scd_start` datetime NOT NULL,
  `scd_version` int(11) NOT NULL,
  `status` char(1) DEFAULT NULL,
  `systemId` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`systemId`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES ('Katella Avenue','Little Rock','GE','Richard',1,'Taft',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'S',38),('Corona Del Mar','Richmond','HNE','Ronald',2,'Washington',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'M',39),('Bowles Avenue','Lincoln','HNE','Martin',4,'Coolidge',NULL,NULL,'\0','2013-07-09 20:24:57','2013-07-09 20:23:04',1,'M',40),('Grandview Drive','Des Moines','GE','Franklin',5,'Clinton',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'M',41),('Cleveland Ave.','Providence','Talend','Warren',7,'Harding',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'S',42),('Westside Freeway','Bismarck','GE','Bill',8,'Harding',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'M',43),('Redwood Highway','Sacramento','BankOfAnerica','Millard',9,'Harrison',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'M',44),('Erringer Road','Baton Rouge','CenturyLink','Lyndon',10,'Jackson',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:23:04',1,'S',45),('Bowles Avenue','Lincoln','Talend','Martin',4,'Coolidge',NULL,NULL,'','2099-01-01 12:00:00','2013-07-09 20:24:57',2,'M',46);
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-09-17 11:28:59
