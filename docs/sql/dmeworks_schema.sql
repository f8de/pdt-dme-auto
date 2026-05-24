-- MySQL dump 10.13  Distrib 5.7.19, for Win64 (x86_64)
--
-- Host: localhost    Database: dmeworks
-- ------------------------------------------------------
-- Server version	5.7.19-log

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
-- Table structure for table `tbl_ability_eligibility_payer`
--

DROP TABLE IF EXISTS `tbl_ability_eligibility_payer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_ability_eligibility_payer` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Code` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Name` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `Comments` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `SearchOptions` mediumtext COLLATE latin1_general_ci NOT NULL,
  `AllowsSubmission` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_ability_eligibility_payer` (`Code`)
) ENGINE=InnoDB AUTO_INCREMENT=892 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_doctor`
--

DROP TABLE IF EXISTS `tbl_doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_doctor` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Courtesy` enum('Dr.','Miss','Mr.','Mrs.','Rev.') COLLATE latin1_general_ci NOT NULL,
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `FirstName` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `LastName` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `LicenseNumber` varchar(16) COLLATE latin1_general_ci NOT NULL,
  `LicenseExpired` date DEFAULT NULL,
  `MedicaidNumber` varchar(16) COLLATE latin1_general_ci NOT NULL,
  `MiddleName` varchar(1) COLLATE latin1_general_ci NOT NULL,
  `OtherID` varchar(16) COLLATE latin1_general_ci NOT NULL,
  `FEDTaxID` varchar(9) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `DEANumber` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Suffix` varchar(4) COLLATE latin1_general_ci NOT NULL,
  `Title` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `TypeID` int(11) DEFAULT NULL,
  `UPINNumber` varchar(11) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `MIR` set('FirstName','LastName','Address1','City','State','Zip','NPI','Phone') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `NPI` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `PecosEnrolled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_doctortype`
--

DROP TABLE IF EXISTS `tbl_doctortype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_doctortype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=741 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_icd10`
--

DROP TABLE IF EXISTS `tbl_icd10`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_icd10` (
  `Code` varchar(8) COLLATE latin1_general_ci NOT NULL,
  `Description` varchar(255) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Header` tinyint(1) NOT NULL DEFAULT '0',
  `ActiveDate` date DEFAULT NULL,
  `InactiveDate` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_icd9`
--

DROP TABLE IF EXISTS `tbl_icd9`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_icd9` (
  `Code` varchar(6) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Description` varchar(255) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ActiveDate` date DEFAULT NULL,
  `InactiveDate` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_insurancecompany`
--

DROP TABLE IF EXISTS `tbl_insurancecompany`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_insurancecompany` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Basis` enum('Bill','Allowed') COLLATE latin1_general_ci NOT NULL DEFAULT 'Bill',
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ECSFormat` enum('Region A','Region B','Region C','Region D','Zirmed','Medi-Cal','Availity','Office Ally','Ability') COLLATE latin1_general_ci NOT NULL DEFAULT 'Region A',
  `ExpectedPercent` double DEFAULT NULL,
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PriceCodeID` int(11) DEFAULT NULL,
  `PrintHAOOnInvoice` tinyint(1) DEFAULT NULL,
  `PrintInvOnInvoice` tinyint(1) DEFAULT NULL,
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Title` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Type` int(11) DEFAULT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MedicareNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `OfficeAllyNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ZirmedNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `InvoiceFormID` int(11) DEFAULT NULL,
  `MedicaidNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MIR` set('MedicareNumber') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `GroupID` int(11) DEFAULT NULL,
  `AvailityNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AbilityNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AbilityEligibilityPayerId` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_insurancecompanygroup`
--

DROP TABLE IF EXISTS `tbl_insurancecompanygroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_insurancecompanygroup` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_insurancecompanytype`
--

DROP TABLE IF EXISTS `tbl_insurancecompanytype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_insurancecompanytype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_variables`
--

DROP TABLE IF EXISTS `tbl_variables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_variables` (
  `Name` varchar(31) COLLATE latin1_general_ci NOT NULL,
  `Value` varchar(255) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_zipcode`
--

DROP TABLE IF EXISTS `tbl_zipcode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_zipcode` (
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(30) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`Zip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'dmeworks'
--
/*!50003 DROP PROCEDURE IF EXISTS `mir_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update`()
BEGIN

  CALL mir_update_doctor(null); --

  CALL mir_update_insurancecompany(null); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_doctor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_doctor`(P_DoctorID INT)
BEGIN

  UPDATE tbl_doctor

  SET MIR =

      CONCAT_WS(',',

          IF(IFNULL(FirstName , '') = '', 'FirstName' , null),

          IF(IFNULL(LastName  , '') = '', 'LastName'  , null),

          IF(IFNULL(Address1  , '') = '', 'Address1'  , null),

          IF(IFNULL(City      , '') = '', 'City'      , null),

          IF(IFNULL(State     , '') = '', 'State'     , null),

          IF(IFNULL(Zip       , '') = '', 'Zip'       , null),

          IF(IFNULL(NPI       , '') = '', 'NPI'       , null),

          IF((IFNULL(Fax   , '') = '') and 

             (IFNULL(Phone , '') = '') and 

             (IFNULL(Phone2, '') = '')  , 'Phone'     , null))

  WHERE (ID = P_DoctorID) OR (P_DoctorID IS NULL); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_insurancecompany` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_insurancecompany`(P_InsuranceCompanyID INT)
BEGIN

  UPDATE tbl_insurancecompany

  SET MIR =

      CONCAT_WS(',',

          IF(IFNULL(MedicareNumber, '') = '', 'MedicareNumber' , null)

               )

  WHERE (ID = P_InsuranceCompanyID) OR (P_InsuranceCompanyID IS NULL); --

END ;;
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

-- Dump completed on 2026-05-23 23:52:09
