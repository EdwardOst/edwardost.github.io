-- MySQL dump 10.13  Distrib 5.1.61, for Win64 (unknown)
--
-- Host: localhost    Database: cdc_crm
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
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` int(5) NOT NULL DEFAULT '0',
  `firstname` varchar(10) DEFAULT NULL,
  `name` varchar(10) DEFAULT NULL,
  `age` int(3) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (2,'Ost','Ed',1),(3,'Theodore','Monroe',20),(4,'Martin','Grant',50),(5,'Ulysses','Lincoln',69),(6,'Richard','Harding',84),(7,'Ronald','Van Buren',99),(8,'Calvin','Hoover',89),(9,'James','Jefferson',13),(10,'Lyndon','Jackson',89),(11,'Nuno','FRANCISCO',31);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`tadmin`@`localhost`*/ /*!50003 TRIGGER `cdc_crm`.`TCDC_TG_customers_I` 
 AFTER INSERT ON  `cdc_crm`.`customers`
 FOR each row 
 INSERT INTO `cdc_monitor`.`TCDC_customers` 
  ( 
   `TALEND_CDC_SUBSCRIBERS_NAME`,
   `TALEND_CDC_STATE`,
   `TALEND_CDC_TYPE`,
   `TALEND_CDC_CREATION_DATE`,
   `id`
  ) SELECT 
     `TALEND_CDC_SUBSCRIBER_NAME`,
     '0',
     'I',
     sysdate(),
     new.`id`      
    FROM `cdc_monitor`.`TSUBSCRIBERS`
    WHERE `TALEND_CDC_TABLE_TO_WATCH`='cdc_crm.customers' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`tadmin`@`localhost`*/ /*!50003 TRIGGER `cdc_crm`.`TCDC_TG_customers_U` 
 AFTER UPDATE ON `cdc_crm`.`customers`
 FOR each row 
 INSERT INTO `cdc_monitor`.`TCDC_customers` 
  ( 
   `TALEND_CDC_SUBSCRIBERS_NAME`,
   `TALEND_CDC_STATE`,
   `TALEND_CDC_TYPE`,
   `TALEND_CDC_CREATION_DATE`,
   `id`
  ) SELECT 
     `TALEND_CDC_SUBSCRIBER_NAME`,
     '0',
     'U',
     sysdate(),
     new.`id`
    FROM `cdc_monitor`.`TSUBSCRIBERS`
    WHERE `TALEND_CDC_TABLE_TO_WATCH`='cdc_crm.customers' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`tadmin`@`localhost`*/ /*!50003 TRIGGER `cdc_crm`.`TCDC_TG_customers_D` 
 AFTER DELETE ON  `cdc_crm`.`customers`
 FOR each row 
 INSERT INTO `cdc_monitor`.`TCDC_customers` 
  ( 
   `TALEND_CDC_SUBSCRIBERS_NAME`,
   `TALEND_CDC_STATE`,
   `TALEND_CDC_TYPE`,
   `TALEND_CDC_CREATION_DATE`,
   `id`
  ) SELECT 
     `TALEND_CDC_SUBSCRIBER_NAME`,
     '0',
     'D',
     sysdate(),
     old.`id` 
    FROM `cdc_monitor`.`TSUBSCRIBERS`
    WHERE `TALEND_CDC_TABLE_TO_WATCH`='cdc_crm.customers' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-09-17 11:00:30
