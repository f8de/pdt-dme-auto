-- MySQL dump 10.13  Distrib 5.7.19, for Win64 (x86_64)
--
-- Host: localhost    Database: c02
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
-- Temporary table structure for view `tbl_ability_eligibility_payer`
--

DROP TABLE IF EXISTS `tbl_ability_eligibility_payer`;
/*!50001 DROP VIEW IF EXISTS `tbl_ability_eligibility_payer`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_ability_eligibility_payer` AS SELECT 
 1 AS `Id`,
 1 AS `Code`,
 1 AS `Name`,
 1 AS `Comments`,
 1 AS `SearchOptions`,
 1 AS `AllowsSubmission`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tbl_ability_eligibility_request`
--

DROP TABLE IF EXISTS `tbl_ability_eligibility_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_ability_eligibility_request` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL,
  `CustomerInsuranceID` int(11) NOT NULL,
  `RequestTime` datetime NOT NULL,
  `RequestText` mediumtext COLLATE latin1_general_ci NOT NULL,
  `ResponseTime` datetime DEFAULT NULL,
  `ResponseText` mediumtext COLLATE latin1_general_ci,
  `SubmissionTime` datetime DEFAULT NULL,
  `SubmissionText` mediumtext COLLATE latin1_general_ci,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_authorizationtype`
--

DROP TABLE IF EXISTS `tbl_authorizationtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_authorizationtype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_batchpayment`
--

DROP TABLE IF EXISTS `tbl_batchpayment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_batchpayment` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InsuranceCompanyID` int(11) NOT NULL,
  `CheckNumber` varchar(14) COLLATE latin1_general_ci NOT NULL,
  `CheckDate` date NOT NULL,
  `CheckAmount` decimal(18,2) NOT NULL,
  `AmountUsed` decimal(18,2) NOT NULL,
  `LastUpdateUserID` smallint(6) NOT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_billingtype`
--

DROP TABLE IF EXISTS `tbl_billingtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_billingtype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_changes`
--

DROP TABLE IF EXISTS `tbl_changes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_changes` (
  `TableName` varchar(64) COLLATE latin1_general_ci NOT NULL,
  `SessionID` int(11) NOT NULL,
  `LastUpdateUserID` smallint(6) NOT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TableName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform`
--

DROP TABLE IF EXISTS `tbl_cmnform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CMNType` enum('DMERC 01.02A','DMERC 01.02B','DMERC 02.03A','DMERC 02.03B','DMERC 03.02','DMERC 04.03B','DMERC 04.03C','DMERC 06.02B','DMERC 07.02A','DMERC 07.02B','DMERC 08.02','DMERC 09.02','DMERC 10.02A','DMERC 10.02B','DMERC 484.2','DMERC DRORDER','DMERC URO','DME 04.04B','DME 04.04C','DME 06.03B','DME 07.03A','DME 09.03','DME 10.03','DME 484.03') COLLATE latin1_general_ci NOT NULL DEFAULT 'DME 484.03',
  `InitialDate` date DEFAULT NULL,
  `RevisedDate` date DEFAULT NULL,
  `RecertificationDate` date DEFAULT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `Customer_ICD9_1` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `Customer_ICD9_2` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `Customer_ICD9_3` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `Customer_ICD9_4` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `DoctorID` int(11) DEFAULT NULL,
  `POSTypeID` int(11) DEFAULT NULL,
  `FacilityID` int(11) DEFAULT NULL,
  `AnsweringName` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AnsweringTitle` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AnsweringEmployer` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `EstimatedLengthOfNeed` int(11) NOT NULL DEFAULT '0',
  `Signature_Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Signature_Date` date DEFAULT NULL,
  `OnFile` tinyint(1) NOT NULL DEFAULT '0',
  `OrderID` int(11) DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `MIR` set('CMNType','InitialDate','CustomerID','Customer','ICD9_1.Required','ICD9_1.Unknown','ICD9_1.Inactive','ICD9_2.Unknown','ICD9_2.Inactive','ICD9_3.Unknown','ICD9_3.Inactive','ICD9_4.Unknown','ICD9_4.Inactive','DoctorID','Doctor','POSTypeID','EstimatedLengthOfNeed','Signature_Name','Signature_Date','Answers') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Customer_UsingICD10` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0102a`
--

DROP TABLE IF EXISTS `tbl_cmnform_0102a`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0102a` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer6` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0102b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0102b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0102b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer12` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer13` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer14` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer15` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer16` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer19` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer20` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer21_Ulcer1_Stage` varchar(30) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer21_Ulcer1_MaxLength` double DEFAULT NULL,
  `Answer21_Ulcer1_MaxWidth` double DEFAULT NULL,
  `Answer21_Ulcer2_Stage` varchar(30) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer21_Ulcer2_MaxLength` double DEFAULT NULL,
  `Answer21_Ulcer2_MaxWidth` double DEFAULT NULL,
  `Answer21_Ulcer3_Stage` varchar(30) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer21_Ulcer3_MaxLength` double DEFAULT NULL,
  `Answer21_Ulcer3_MaxWidth` double DEFAULT NULL,
  `Answer22` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0203a`
--

DROP TABLE IF EXISTS `tbl_cmnform_0203a`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0203a` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer2` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` int(11) DEFAULT NULL,
  `Answer6` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0203b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0203b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0203b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer2` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` int(11) DEFAULT NULL,
  `Answer8` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer9` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0302`
--

DROP TABLE IF EXISTS `tbl_cmnform_0302`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0302` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer12` int(11) DEFAULT NULL,
  `Answer14` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0403b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0403b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0403b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer2` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0403c`
--

DROP TABLE IF EXISTS `tbl_cmnform_0403c`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0403c` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer6a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer6b` int(11) NOT NULL DEFAULT '0',
  `Answer7a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7b` int(11) NOT NULL DEFAULT '0',
  `Answer8` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer9a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer9b` int(11) NOT NULL DEFAULT '0',
  `Answer10a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer10b` int(11) NOT NULL DEFAULT '0',
  `Answer10c` int(11) NOT NULL DEFAULT '0',
  `Answer11a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer11b` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0404b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0404b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0404b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer2` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer3` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer4` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer5` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0404c`
--

DROP TABLE IF EXISTS `tbl_cmnform_0404c`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0404c` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer6` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7b` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer8` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer9a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer9b` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer10a` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer10b` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer10c` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer11` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer12` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0602b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0602b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0602b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer2` date DEFAULT NULL,
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` int(11) DEFAULT NULL,
  `Answer5` enum('1','2','3','4','5') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer6` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer8_begun` date DEFAULT NULL,
  `Answer8_ended` date DEFAULT NULL,
  `Answer9` date DEFAULT NULL,
  `Answer10` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer11` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer12` enum('2','4') COLLATE latin1_general_ci NOT NULL DEFAULT '2',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0603b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0603b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0603b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer2` int(11) DEFAULT NULL,
  `Answer3` enum('1','2','3','4','5') COLLATE latin1_general_ci NOT NULL DEFAULT '5',
  `Answer4` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer5` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer6` date DEFAULT NULL,
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0702a`
--

DROP TABLE IF EXISTS `tbl_cmnform_0702a`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0702a` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer2` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0702b`
--

DROP TABLE IF EXISTS `tbl_cmnform_0702b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0702b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer6` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer7` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer8` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer12` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer13` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer14` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0703a`
--

DROP TABLE IF EXISTS `tbl_cmnform_0703a`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0703a` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer2` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer3` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0802`
--

DROP TABLE IF EXISTS `tbl_cmnform_0802`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0802` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1_HCPCS` varchar(5) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer1_MG` int(11) DEFAULT NULL,
  `Answer1_Times` int(11) DEFAULT NULL,
  `Answer2_HCPCS` varchar(5) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer2_MG` int(11) DEFAULT NULL,
  `Answer2_Times` int(11) DEFAULT NULL,
  `Answer3_HCPCS` varchar(5) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer3_MG` int(11) DEFAULT NULL,
  `Answer3_Times` int(11) DEFAULT NULL,
  `Answer4` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  `Answer5_1` enum('1','2','3','4','5') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer5_2` enum('1','2','3','4','5') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer5_3` enum('1','2','3','4','5') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer8` varchar(60) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer9` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer10` varchar(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer11` date DEFAULT NULL,
  `Answer12` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0902`
--

DROP TABLE IF EXISTS `tbl_cmnform_0902`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0902` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('1','3','4') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer2` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer3` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer4` enum('1','3','4') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer5` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer6` int(11) NOT NULL DEFAULT '1',
  `Answer7` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_0903`
--

DROP TABLE IF EXISTS `tbl_cmnform_0903`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_0903` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1a` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer1b` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer1c` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer2a` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer2b` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer2c` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer3` enum('1','2','3','4') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer4` enum('1','2') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_1002a`
--

DROP TABLE IF EXISTS `tbl_cmnform_1002a`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_1002a` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer3` int(11) DEFAULT NULL,
  `Concentration_AminoAcid` double DEFAULT NULL,
  `Concentration_Dextrose` double DEFAULT NULL,
  `Concentration_Lipids` double DEFAULT NULL,
  `Dose_AminoAcid` double DEFAULT NULL,
  `Dose_Dextrose` double DEFAULT NULL,
  `Dose_Lipids` double DEFAULT NULL,
  `DaysPerWeek_Lipids` double DEFAULT NULL,
  `GmsPerDay_AminoAcid` double DEFAULT NULL,
  `Answer5` enum('1','3','7') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_1002b`
--

DROP TABLE IF EXISTS `tbl_cmnform_1002b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_1002b` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer7` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer8` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer10a` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer10b` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer11a` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer11b` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer12` int(11) DEFAULT NULL,
  `Answer13` enum('1','2','3','4') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer14` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer15` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_1003`
--

DROP TABLE IF EXISTS `tbl_cmnform_1003`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_1003` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer2` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer3a` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer3b` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer4a` int(11) DEFAULT NULL,
  `Answer4b` int(11) DEFAULT NULL,
  `Answer5` enum('1','2','3','4') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer6` int(11) DEFAULT NULL,
  `Answer7` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer8a` int(11) DEFAULT NULL,
  `Answer8b` int(11) DEFAULT NULL,
  `Answer8c` int(11) DEFAULT NULL,
  `Answer8d` int(11) DEFAULT NULL,
  `Answer8e` int(11) DEFAULT NULL,
  `Answer8f` int(11) DEFAULT NULL,
  `Answer8g` int(11) DEFAULT NULL,
  `Answer8h` int(11) DEFAULT NULL,
  `Answer9` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_48403`
--

DROP TABLE IF EXISTS `tbl_cmnform_48403`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_48403` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1a` int(11) DEFAULT NULL,
  `Answer1b` int(11) DEFAULT NULL,
  `Answer1c` date DEFAULT NULL,
  `Answer2` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer3` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `Answer4` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer5` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer6a` int(11) DEFAULT NULL,
  `Answer6b` int(11) DEFAULT NULL,
  `Answer6c` date DEFAULT NULL,
  `Answer7` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer8` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer9` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_4842`
--

DROP TABLE IF EXISTS `tbl_cmnform_4842`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_4842` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Answer1a` int(11) DEFAULT NULL,
  `Answer1b` int(11) DEFAULT NULL,
  `Answer1c` date DEFAULT NULL,
  `Answer2` enum('Y','N') COLLATE latin1_general_ci NOT NULL DEFAULT 'Y',
  `Answer3` enum('1','2','3') COLLATE latin1_general_ci NOT NULL DEFAULT '1',
  `PhysicianAddress` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PhysicianCity` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PhysicianState` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PhysicianZip` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PhysicianName` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Answer5` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer6` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `Answer7a` int(11) DEFAULT NULL,
  `Answer7b` int(11) DEFAULT NULL,
  `Answer7c` date DEFAULT NULL,
  `Answer8` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer9` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  `Answer10` enum('Y','N','D') COLLATE latin1_general_ci NOT NULL DEFAULT 'D',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_details`
--

DROP TABLE IF EXISTS `tbl_cmnform_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_details` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `BillingCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `OrderedQuantity` double NOT NULL DEFAULT '0',
  `OrderedUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `BillablePrice` double NOT NULL DEFAULT '0',
  `AllowablePrice` double NOT NULL DEFAULT '0',
  `Period` enum('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually','Custom') COLLATE latin1_general_ci NOT NULL DEFAULT 'One time',
  `Modifier1` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier2` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier3` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier4` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PredefinedTextID` int(11) DEFAULT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_drorder`
--

DROP TABLE IF EXISTS `tbl_cmnform_drorder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_drorder` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Prognosis` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MedicalJustification` longtext COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_cmnform_uro`
--

DROP TABLE IF EXISTS `tbl_cmnform_uro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_cmnform_uro` (
  `CMNFormID` int(11) NOT NULL DEFAULT '0',
  `Prognosis` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`CMNFormID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_company`
--

DROP TABLE IF EXISTS `tbl_company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_company` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillCustomerCopayUpfront` tinyint(1) NOT NULL DEFAULT '0',
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `FederalTaxID` varchar(9) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `TaxonomyCode` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '332B00000X',
  `EIN` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `SSN` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `TaxIDType` enum('SSN','EIN') COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ParticipatingProvider` tinyint(1) NOT NULL DEFAULT '0',
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `POAuthorizationCodeReqiered` tinyint(1) NOT NULL DEFAULT '0',
  `Print_PricesOnOrders` tinyint(1) NOT NULL DEFAULT '0',
  `Picture` mediumblob,
  `POSTypeID` int(11) DEFAULT '12',
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `SystemGenerate_BlanketAssignments` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_CappedRentalLetters` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_CustomerAccountNumbers` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_DeliveryPickupTickets` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_DroctorsOrder` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_HIPPAForms` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_PatientBillOfRights` tinyint(1) NOT NULL DEFAULT '0',
  `SystemGenerate_PurchaseOrderNumber` tinyint(1) NOT NULL DEFAULT '0',
  `WriteoffDifference` tinyint(1) NOT NULL DEFAULT '0',
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `IncludeLocationInfo` tinyint(1) NOT NULL DEFAULT '0',
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Print_CompanyInfoOnInvoice` tinyint(1) NOT NULL DEFAULT '0',
  `Print_CompanyInfoOnDelivery` tinyint(1) NOT NULL DEFAULT '0',
  `Print_CompanyInfoOnPickup` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Show_InactiveCustomers` tinyint(1) NOT NULL DEFAULT '0',
  `WarehouseID` int(11) DEFAULT NULL,
  `NPI` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `TaxRateID` int(11) DEFAULT NULL,
  `ImagingServer` varchar(250) COLLATE latin1_general_ci DEFAULT NULL,
  `ZirmedNumber` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AutomaticallyReorderInventory` tinyint(1) NOT NULL DEFAULT '1',
  `AvailityNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Show_QuantityOnHand` tinyint(1) NOT NULL DEFAULT '0',
  `Use_Icd10ForNewCmnRx` tinyint(1) NOT NULL DEFAULT '0',
  `OrderSurveyID` int(11) DEFAULT NULL,
  `AbilityIntegrationSettings` mediumtext COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_compliance`
--

DROP TABLE IF EXISTS `tbl_compliance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_compliance` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `OrderID` int(11) DEFAULT NULL,
  `DeliveryDate` date NOT NULL DEFAULT '0000-00-00',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_compliance_items`
--

DROP TABLE IF EXISTS `tbl_compliance_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_compliance_items` (
  `ComplianceID` int(11) NOT NULL DEFAULT '0',
  `InventoryItemID` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_compliance_notes`
--

DROP TABLE IF EXISTS `tbl_compliance_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_compliance_notes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ComplianceID` int(11) NOT NULL DEFAULT '0',
  `Date` date NOT NULL DEFAULT '0000-00-00',
  `Done` tinyint(1) NOT NULL DEFAULT '0',
  `Notes` longtext COLLATE latin1_general_ci NOT NULL,
  `CreatedByUserID` smallint(6) DEFAULT NULL,
  `AssignedToUserID` smallint(6) DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `IX_compliance_notes_Done_Date` (`Done`,`Date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_customer`
--

DROP TABLE IF EXISTS `tbl_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_customer` (
  `AccountNumber` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillingTypeID` int(11) DEFAULT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Courtesy` enum('Dr.','Miss','Mr.','Mrs.','Rev.') COLLATE latin1_general_ci NOT NULL DEFAULT 'Dr.',
  `CustomerBalance` double DEFAULT NULL,
  `CustomerClassCode` char(2) COLLATE latin1_general_ci DEFAULT NULL,
  `CustomerTypeID` int(11) DEFAULT NULL,
  `DeceasedDate` date DEFAULT NULL,
  `DateofBirth` date DEFAULT NULL,
  `FirstName` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `LastName` varchar(30) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LocationID` int(11) DEFAULT NULL,
  `MiddleName` char(1) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Suffix` varchar(4) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `TotalBalance` double DEFAULT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillActive` tinyint(1) NOT NULL DEFAULT '0',
  `BillAddress1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillAddress2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillCity` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillName` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillState` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BillZip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `CommercialAccount` tinyint(1) DEFAULT NULL,
  `DeliveryDirections` longtext COLLATE latin1_general_ci NOT NULL,
  `EmploymentStatus` enum('Unknown','Full Time','Part Time','Retired','Student','Unemployed') COLLATE latin1_general_ci NOT NULL DEFAULT 'Unknown',
  `Gender` enum('Male','Female') COLLATE latin1_general_ci NOT NULL DEFAULT 'Male',
  `Height` double DEFAULT NULL,
  `License` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MaritalStatus` enum('Unknown','Single','Married','Legaly Separated','Divorced','Widowed') COLLATE latin1_general_ci NOT NULL DEFAULT 'Unknown',
  `MilitaryBranch` enum('N/A','Army','Air Force','Navy','Marines','Coast Guard','National Guard') COLLATE latin1_general_ci NOT NULL DEFAULT 'N/A',
  `MilitaryStatus` enum('N/A','Active','Reserve','Retired') COLLATE latin1_general_ci NOT NULL DEFAULT 'N/A',
  `ShipActive` tinyint(1) NOT NULL DEFAULT '0',
  `ShipAddress1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ShipAddress2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ShipCity` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ShipName` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ShipState` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ShipZip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `SSNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `StudentStatus` enum('N/A','Full Time','Part Time') COLLATE latin1_general_ci NOT NULL DEFAULT 'N/A',
  `Weight` double DEFAULT NULL,
  `Basis` enum('Bill','Allowed') COLLATE latin1_general_ci NOT NULL DEFAULT 'Bill',
  `Block12HCFA` tinyint(1) NOT NULL DEFAULT '0',
  `Block13HCFA` tinyint(1) NOT NULL DEFAULT '0',
  `CommercialAcctCreditLimit` double DEFAULT NULL,
  `CommercialAcctTerms` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `CopayDollar` double DEFAULT NULL,
  `Deductible` double DEFAULT NULL,
  `Frequency` enum('Per Visit','Monthly','Yearly') COLLATE latin1_general_ci NOT NULL DEFAULT 'Per Visit',
  `Hardship` tinyint(1) NOT NULL DEFAULT '0',
  `MonthsValid` int(11) NOT NULL DEFAULT '0',
  `OutOfPocket` double DEFAULT NULL,
  `SignatureOnFile` date DEFAULT NULL,
  `SignatureType` char(1) COLLATE latin1_general_ci DEFAULT NULL,
  `TaxRateID` int(11) DEFAULT NULL,
  `Doctor1_ID` int(11) DEFAULT NULL,
  `Doctor2_ID` int(11) DEFAULT NULL,
  `EmergencyContact` longtext COLLATE latin1_general_ci NOT NULL,
  `FacilityID` int(11) DEFAULT NULL,
  `LegalRepID` int(11) DEFAULT NULL,
  `ReferralID` int(11) DEFAULT NULL,
  `SalesRepID` int(11) DEFAULT NULL,
  `AccidentType` enum('Auto','No','Other') COLLATE latin1_general_ci NOT NULL,
  `StateOfAccident` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `DateOfInjury` date DEFAULT NULL,
  `Emergency` tinyint(1) NOT NULL DEFAULT '0',
  `EmploymentRelated` tinyint(1) NOT NULL DEFAULT '0',
  `FirstConsultDate` date DEFAULT NULL,
  `ICD9_1` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_2` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_3` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_4` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `POSTypeID` int(11) DEFAULT NULL,
  `ReturnToWorkDate` date DEFAULT NULL,
  `CopayPercent` double DEFAULT NULL,
  `SetupDate` date NOT NULL DEFAULT '0000-00-00',
  `HIPPANote` tinyint(1) NOT NULL DEFAULT '0',
  `SupplierStandards` tinyint(1) NOT NULL DEFAULT '0',
  `InactiveDate` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `InvoiceFormID` int(11) DEFAULT '4',
  `MIR` set('AccountNumber','FirstName','LastName','Address1','City','State','Zip','EmploymentStatus','Gender','MaritalStatus','MilitaryBranch','MilitaryStatus','StudentStatus','MonthsValid','DateofBirth','SignatureOnFile','Doctor1_ID','Doctor1','ICD9_1') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Email` varchar(150) COLLATE latin1_general_ci DEFAULT NULL,
  `Collections` bit(1) NOT NULL DEFAULT b'0',
  `ICD10_01` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_02` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_03` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_04` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_05` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_06` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_07` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_08` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_09` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_10` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_11` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_12` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `AccountNumber` (`AccountNumber`),
  KEY `IDX_FIRST_LAST_DOB_MIDDLE` (`FirstName`,`LastName`,`DateofBirth`,`MiddleName`),
  KEY `IX_customer_InactiveDate` (`InactiveDate`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_customer_insurance`
--

DROP TABLE IF EXISTS `tbl_customer_insurance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_customer_insurance` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Basis` enum('Bill','Allowed') COLLATE latin1_general_ci NOT NULL DEFAULT 'Bill',
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `DateofBirth` date DEFAULT NULL,
  `Gender` enum('Male','Female') COLLATE latin1_general_ci NOT NULL DEFAULT 'Male',
  `GroupNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InactiveDate` date DEFAULT NULL,
  `InsuranceCompanyID` int(11) NOT NULL DEFAULT '0',
  `InsuranceType` char(2) COLLATE latin1_general_ci DEFAULT NULL,
  `FirstName` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastName` varchar(30) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MiddleName` char(1) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Employer` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Mobile` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PaymentPercent` int(11) DEFAULT NULL,
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PolicyNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Rank` int(11) DEFAULT NULL,
  `RelationshipCode` char(2) COLLATE latin1_general_ci DEFAULT NULL,
  `RequestEligibility` tinyint(1) NOT NULL DEFAULT '0',
  `RequestEligibilityOn` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `MIR` set('FirstName','LastName','Address1','City','State','Zip','Gender','DateofBirth','InsuranceCompanyID','InsuranceCompany','InsuranceType','PolicyNumber','RelationshipCode') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Suffix` varchar(4) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_customer_notes`
--

DROP TABLE IF EXISTS `tbl_customer_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_customer_notes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL,
  `Notes` longtext COLLATE latin1_general_ci NOT NULL,
  `Active` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Operator` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `CallbackDate` datetime DEFAULT NULL,
  `CreatedBy` smallint(6) DEFAULT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_customerclass`
--

DROP TABLE IF EXISTS `tbl_customerclass`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_customerclass` (
  `Code` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Description` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_customertype`
--

DROP TABLE IF EXISTS `tbl_customertype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_customertype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_denial`
--

DROP TABLE IF EXISTS `tbl_denial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_denial` (
  `Code` varchar(6) COLLATE latin1_general_ci NOT NULL,
  `Description` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_depositdetails`
--

DROP TABLE IF EXISTS `tbl_depositdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_depositdetails` (
  `OrderDetailsID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  `Amount` decimal(18,2) NOT NULL,
  `LastUpdateUserID` smallint(6) NOT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`OrderDetailsID`),
  KEY `IDX_DEPOSITS` (`CustomerID`,`OrderID`,`OrderDetailsID`),
  CONSTRAINT `FK_DEPOSITDETAILS_DEPOSITS` FOREIGN KEY (`CustomerID`, `OrderID`) REFERENCES `tbl_deposits` (`CustomerID`, `OrderID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_DEPOSITDETAILS_ORDERDETAILS` FOREIGN KEY (`OrderDetailsID`) REFERENCES `tbl_orderdetails` (`ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_deposits`
--

DROP TABLE IF EXISTS `tbl_deposits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_deposits` (
  `CustomerID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `Amount` decimal(18,2) NOT NULL,
  `Date` date NOT NULL,
  `PaymentMethod` enum('Cash','Check','Credit Card') COLLATE latin1_general_ci NOT NULL,
  `Notes` text COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) NOT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`CustomerID`,`OrderID`),
  CONSTRAINT `FK_DEPOSITS_ORDER` FOREIGN KEY (`CustomerID`, `OrderID`) REFERENCES `tbl_order` (`CustomerID`, `ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tbl_doctor`
--

DROP TABLE IF EXISTS `tbl_doctor`;
/*!50001 DROP VIEW IF EXISTS `tbl_doctor`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_doctor` AS SELECT 
 1 AS `Address1`,
 1 AS `Address2`,
 1 AS `City`,
 1 AS `Contact`,
 1 AS `Courtesy`,
 1 AS `Fax`,
 1 AS `FirstName`,
 1 AS `ID`,
 1 AS `LastName`,
 1 AS `LicenseNumber`,
 1 AS `LicenseExpired`,
 1 AS `MedicaidNumber`,
 1 AS `MiddleName`,
 1 AS `OtherID`,
 1 AS `FEDTaxID`,
 1 AS `DEANumber`,
 1 AS `Phone`,
 1 AS `Phone2`,
 1 AS `State`,
 1 AS `Suffix`,
 1 AS `Title`,
 1 AS `TypeID`,
 1 AS `UPINNumber`,
 1 AS `Zip`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`,
 1 AS `MIR`,
 1 AS `NPI`,
 1 AS `PecosEnrolled`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `tbl_doctortype`
--

DROP TABLE IF EXISTS `tbl_doctortype`;
/*!50001 DROP VIEW IF EXISTS `tbl_doctortype`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_doctortype` AS SELECT 
 1 AS `ID`,
 1 AS `Name`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tbl_eligibilityrequest`
--

DROP TABLE IF EXISTS `tbl_eligibilityrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_eligibilityrequest` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `CustomerInsuranceID` int(11) NOT NULL DEFAULT '0',
  `Region` enum('Region A','Region B','Region C','Region D','Zirmed','Medi-Cal','Availity','Office Ally','Ability') COLLATE latin1_general_ci NOT NULL DEFAULT 'Region A',
  `RequestBatchID` int(11) DEFAULT NULL,
  `RequestTime` datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  `RequestText` mediumtext COLLATE latin1_general_ci NOT NULL,
  `ResponseBatchID` int(11) DEFAULT NULL,
  `ResponseTime` datetime DEFAULT NULL,
  `ResponseText` mediumtext COLLATE latin1_general_ci,
  `SubmissionTime` datetime DEFAULT NULL,
  `SubmissionText` mediumtext COLLATE latin1_general_ci,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_facility`
--

DROP TABLE IF EXISTS `tbl_facility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_facility` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `DefaultDeliveryWeek` enum('1st week of month','2nd week of month','3rd week of month','4th week of month','as needed') COLLATE latin1_general_ci NOT NULL,
  `Directions` longtext COLLATE latin1_general_ci,
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `MedicaidID` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `MedicareID` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `POSTypeID` int(11) DEFAULT '12',
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `NPI` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `MIR` set('Name','Address1','City','State','Zip','POSTypeID','NPI') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_hao`
--

DROP TABLE IF EXISTS `tbl_hao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_hao` (
  `Code` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `Description` longtext COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tbl_icd10`
--

DROP TABLE IF EXISTS `tbl_icd10`;
/*!50001 DROP VIEW IF EXISTS `tbl_icd10`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_icd10` AS SELECT 
 1 AS `Code`,
 1 AS `Description`,
 1 AS `Header`,
 1 AS `ActiveDate`,
 1 AS `InactiveDate`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `tbl_icd9`
--

DROP TABLE IF EXISTS `tbl_icd9`;
/*!50001 DROP VIEW IF EXISTS `tbl_icd9`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_icd9` AS SELECT 
 1 AS `Code`,
 1 AS `Description`,
 1 AS `ActiveDate`,
 1 AS `InactiveDate`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tbl_image`
--

DROP TABLE IF EXISTS `tbl_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_image` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Type` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Description` text COLLATE latin1_general_ci,
  `CustomerID` int(11) DEFAULT NULL,
  `OrderID` int(11) DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT NULL,
  `DoctorID` int(11) DEFAULT NULL,
  `CMNFormID` int(11) DEFAULT NULL,
  `Thumbnail` blob,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tbl_insurancecompany`
--

DROP TABLE IF EXISTS `tbl_insurancecompany`;
/*!50001 DROP VIEW IF EXISTS `tbl_insurancecompany`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_insurancecompany` AS SELECT 
 1 AS `Address1`,
 1 AS `Address2`,
 1 AS `Basis`,
 1 AS `City`,
 1 AS `Contact`,
 1 AS `ECSFormat`,
 1 AS `ExpectedPercent`,
 1 AS `Fax`,
 1 AS `ID`,
 1 AS `Name`,
 1 AS `Phone`,
 1 AS `Phone2`,
 1 AS `PriceCodeID`,
 1 AS `PrintHAOOnInvoice`,
 1 AS `PrintInvOnInvoice`,
 1 AS `State`,
 1 AS `Title`,
 1 AS `Type`,
 1 AS `Zip`,
 1 AS `MedicareNumber`,
 1 AS `OfficeAllyNumber`,
 1 AS `ZirmedNumber`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`,
 1 AS `InvoiceFormID`,
 1 AS `MedicaidNumber`,
 1 AS `MIR`,
 1 AS `GroupID`,
 1 AS `AvailityNumber`,
 1 AS `AbilityNumber`,
 1 AS `AbilityEligibilityPayerId`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `tbl_insurancecompanygroup`
--

DROP TABLE IF EXISTS `tbl_insurancecompanygroup`;
/*!50001 DROP VIEW IF EXISTS `tbl_insurancecompanygroup`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_insurancecompanygroup` AS SELECT 
 1 AS `ID`,
 1 AS `Name`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `tbl_insurancecompanytype`
--

DROP TABLE IF EXISTS `tbl_insurancecompanytype`;
/*!50001 DROP VIEW IF EXISTS `tbl_insurancecompanytype`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_insurancecompanytype` AS SELECT 
 1 AS `ID`,
 1 AS `Name`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tbl_insurancetype`
--

DROP TABLE IF EXISTS `tbl_insurancetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_insurancetype` (
  `Code` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Description` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_inventory`
--

DROP TABLE IF EXISTS `tbl_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_inventory` (
  `WarehouseID` int(11) NOT NULL DEFAULT '0',
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `OnHand` double NOT NULL DEFAULT '0',
  `Committed` double NOT NULL DEFAULT '0',
  `OnOrder` double NOT NULL DEFAULT '0',
  `UnAvailable` double NOT NULL DEFAULT '0',
  `Rented` double NOT NULL DEFAULT '0',
  `Sold` double NOT NULL DEFAULT '0',
  `BackOrdered` double NOT NULL DEFAULT '0',
  `ReOrderPoint` double NOT NULL DEFAULT '0',
  `CostPerUnit` decimal(18,2) NOT NULL DEFAULT '0.00',
  `TotalCost` decimal(18,2) NOT NULL DEFAULT '0.00',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`WarehouseID`,`InventoryItemID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_inventory_transaction`
--

DROP TABLE IF EXISTS `tbl_inventory_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_inventory_transaction` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `WarehouseID` int(11) NOT NULL DEFAULT '0',
  `TypeID` int(11) NOT NULL DEFAULT '0',
  `Date` date NOT NULL DEFAULT '0000-00-00',
  `Quantity` double DEFAULT NULL,
  `Cost` decimal(18,2) DEFAULT NULL,
  `Description` varchar(30) COLLATE latin1_general_ci DEFAULT NULL,
  `SerialID` int(11) DEFAULT NULL,
  `VendorID` int(11) DEFAULT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `PurchaseOrderID` int(11) DEFAULT NULL,
  `PurchaseOrderDetailsID` int(11) DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT NULL,
  `ManufacturerID` int(11) DEFAULT NULL,
  `OrderDetailsID` int(11) DEFAULT NULL,
  `OrderID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `idx_typeid_custid_orid_ordetailsid_itemid_warehouseid` (`TypeID`,`CustomerID`,`OrderID`,`OrderDetailsID`,`InventoryItemID`,`WarehouseID`),
  KEY `idx_typeid_itemid_warehouseid` (`TypeID`,`InventoryItemID`,`WarehouseID`),
  KEY `idx_typeid_poid_podetailsid_itemid_warehouseid` (`TypeID`,`PurchaseOrderID`,`PurchaseOrderDetailsID`,`InventoryItemID`,`WarehouseID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_inventory_transaction_type`
--

DROP TABLE IF EXISTS `tbl_inventory_transaction_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_inventory_transaction_type` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `OnHand` int(11) NOT NULL DEFAULT '0',
  `Committed` int(11) NOT NULL DEFAULT '0',
  `OnOrder` int(11) NOT NULL DEFAULT '0',
  `UnAvailable` int(11) NOT NULL DEFAULT '0',
  `Rented` int(11) NOT NULL DEFAULT '0',
  `Sold` int(11) NOT NULL DEFAULT '0',
  `BackOrdered` int(11) NOT NULL DEFAULT '0',
  `AdjTotalCost` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_inventoryitem`
--

DROP TABLE IF EXISTS `tbl_inventoryitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_inventoryitem` (
  `Barcode` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `BarcodeType` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Basis` enum('Bill','Allowed') COLLATE latin1_general_ci NOT NULL DEFAULT 'Bill',
  `CommissionPaidAt` enum('Billing','Payment','Never') COLLATE latin1_general_ci NOT NULL DEFAULT 'Billing',
  `VendorID` int(11) DEFAULT NULL,
  `FlatRate` tinyint(1) NOT NULL DEFAULT '0',
  `FlatRateAmount` double DEFAULT NULL,
  `Frequency` enum('One time','Monthly','Weekly','Never') COLLATE latin1_general_ci NOT NULL DEFAULT 'One time',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InventoryCode` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ModelNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Name` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `O2Tank` tinyint(1) NOT NULL DEFAULT '0',
  `Percentage` tinyint(1) NOT NULL DEFAULT '0',
  `PercentageAmount` double NOT NULL DEFAULT '0',
  `PredefinedTextID` int(11) DEFAULT NULL,
  `ProductTypeID` int(11) DEFAULT NULL,
  `Serialized` tinyint(1) NOT NULL DEFAULT '0',
  `Service` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Inactive` tinyint(1) NOT NULL DEFAULT '0',
  `ManufacturerID` int(11) DEFAULT NULL,
  `PurchasePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `UserField1` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `UserField2` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_invoice`
--

DROP TABLE IF EXISTS `tbl_invoice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_invoice` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `OrderID` int(11) DEFAULT NULL,
  `Approved` tinyint(1) NOT NULL DEFAULT '0',
  `InvoiceDate` date DEFAULT NULL,
  `InvoiceBalance` decimal(18,2) NOT NULL DEFAULT '0.00',
  `SubmittedTo` enum('Ins1','Ins2','Ins3','Ins4','Patient') COLLATE latin1_general_ci NOT NULL DEFAULT 'Ins1',
  `SubmittedBy` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `SubmittedDate` date DEFAULT NULL,
  `SubmittedBatch` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `CustomerInsurance1_ID` int(11) DEFAULT NULL,
  `CustomerInsurance2_ID` int(11) DEFAULT NULL,
  `CustomerInsurance3_ID` int(11) DEFAULT NULL,
  `CustomerInsurance4_ID` int(11) DEFAULT NULL,
  `ICD9_1` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_2` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_3` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_4` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `DoctorID` int(11) DEFAULT NULL,
  `POSTypeID` int(11) DEFAULT NULL,
  `TaxRateID` int(11) DEFAULT NULL,
  `TaxRatePercent` double DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Discount` double DEFAULT '0',
  `AcceptAssignment` tinyint(1) NOT NULL DEFAULT '0',
  `ClaimNote` varchar(80) COLLATE latin1_general_ci DEFAULT NULL,
  `FacilityID` int(11) DEFAULT NULL,
  `ReferralID` int(11) DEFAULT NULL,
  `SalesrepID` int(11) DEFAULT NULL,
  `Archived` tinyint(1) NOT NULL DEFAULT '0',
  `ICD10_01` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_02` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_03` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_04` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_05` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_06` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_07` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_08` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_09` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_10` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_11` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_12` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_CUSTOMERID_ID` (`CustomerID`,`ID`),
  KEY `IDX_CUSTOMERID_ORDERID` (`CustomerID`,`OrderID`),
  CONSTRAINT `FK_ORDER_2` FOREIGN KEY (`CustomerID`, `OrderID`) REFERENCES `tbl_order` (`CustomerID`, `ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_invoice_transaction`
--

DROP TABLE IF EXISTS `tbl_invoice_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_invoice_transaction` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceDetailsID` int(11) NOT NULL DEFAULT '0',
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `InsuranceCompanyID` int(11) DEFAULT NULL,
  `CustomerInsuranceID` int(11) DEFAULT NULL,
  `TransactionTypeID` int(11) NOT NULL DEFAULT '0',
  `TransactionDate` date DEFAULT NULL,
  `Amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Quantity` double NOT NULL DEFAULT '0',
  `Taxes` decimal(18,2) NOT NULL DEFAULT '0.00',
  `BatchNumber` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Comments` text COLLATE latin1_general_ci,
  `Extra` text COLLATE latin1_general_ci,
  `Approved` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Deductible` decimal(18,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`ID`),
  KEY `IDX_CUSTOMERID_INVOICEID_INVOICEDETAILSID` (`CustomerID`,`InvoiceID`,`InvoiceDetailsID`),
  CONSTRAINT `FK_INVOICE_TRANSACTION_INVOICE` FOREIGN KEY (`CustomerID`, `InvoiceID`, `InvoiceDetailsID`) REFERENCES `tbl_invoicedetails` (`CustomerID`, `InvoiceID`, `ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbl_invoice_transaction_beforeinsert` BEFORE INSERT ON tbl_invoice_transaction

FOR EACH ROW BEGIN

  DECLARE V_OldValue DECIMAL(18, 2) DEFAULT (0); --

  DECLARE V_Quantity DOUBLE DEFAULT (0); --

  DECLARE V_TranType VARCHAR(50); --



  -- we will allow to change Allowable, Billable and Taxes through transactions but in UI

  -- all will stay the same



  SELECT Name

  INTO V_TranType

  FROM tbl_invoice_transactiontype

  WHERE ID = NEW.TransactionTypeID; --



  IF (V_TranType = 'Adjust Allowable') THEN

    SELECT AllowableAmount, Quantity

    INTO V_OldValue, V_Quantity

    FROM tbl_invoicedetails

    WHERE (CustomerID = NEW.CustomerID) AND (InvoiceID = NEW.InvoiceID) AND (ID = NEW.InvoiceDetailsID); --



    SET NEW.Quantity = V_Quantity; --

    SET NEW.Comments = Concat('Previous Value=', V_OldValue); --



    IF 0.001 < ABS(V_OldValue - NEW.Amount) THEN

      UPDATE tbl_invoicedetails

      SET AllowableAmount = NEW.Amount

      WHERE (CustomerID = NEW.CustomerID) AND (InvoiceID = NEW.InvoiceID) AND (ID = NEW.InvoiceDetailsID); --

    END IF; --

  ELSEIF (V_TranType = 'Adjust Customary') THEN

    SELECT BillableAmount, Quantity

    INTO V_OldValue, V_Quantity

    FROM tbl_invoicedetails

    WHERE (CustomerID = NEW.CustomerID) AND (InvoiceID = NEW.InvoiceID) AND (ID = NEW.InvoiceDetailsID); --



    SET NEW.Quantity = V_Quantity; --

    SET NEW.Comments = Concat('Previous Value=', V_OldValue); --



    IF 0.001 < ABS(V_OldValue - NEW.Amount) THEN

      UPDATE tbl_invoicedetails

      SET BillableAmount = NEW.Amount

      WHERE (CustomerID = NEW.CustomerID) AND (InvoiceID = NEW.InvoiceID) AND (ID = NEW.InvoiceDetailsID); --

    END IF; --

  ELSEIF (V_TranType = 'Adjust Taxes') THEN

    SELECT Taxes, Quantity

    INTO V_OldValue, V_Quantity

    FROM tbl_invoicedetails

    WHERE (CustomerID = NEW.CustomerID) AND (InvoiceID = NEW.InvoiceID) AND (ID = NEW.InvoiceDetailsID); --



    SET NEW.Quantity = V_Quantity; --

    SET NEW.Comments = Concat('Previous Value=', V_OldValue); --



    IF 0.001 < ABS(V_OldValue - NEW.Amount) THEN

      UPDATE tbl_invoicedetails

      SET Taxes = NEW.Amount

      WHERE (CustomerID = NEW.CustomerID) AND (InvoiceID = NEW.InvoiceID) AND (ID = NEW.InvoiceDetailsID); --

    END IF; --

  END IF; --

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbl_invoice_transactiontype`
--

DROP TABLE IF EXISTS `tbl_invoice_transactiontype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_invoice_transactiontype` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Balance` int(11) NOT NULL DEFAULT '0',
  `Allowable` int(11) NOT NULL DEFAULT '0',
  `Amount` int(11) NOT NULL DEFAULT '0',
  `Taxes` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `IX_invoice_transactiontype_name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_invoicedetails`
--

DROP TABLE IF EXISTS `tbl_invoicedetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_invoicedetails` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `PriceCodeID` int(11) NOT NULL DEFAULT '0',
  `OrderID` int(11) DEFAULT NULL,
  `OrderDetailsID` int(11) DEFAULT NULL,
  `Balance` decimal(18,2) NOT NULL DEFAULT '0.00',
  `BillableAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `AllowableAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Taxes` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Quantity` double NOT NULL DEFAULT '0',
  `InvoiceDate` date DEFAULT NULL,
  `DOSFrom` date NOT NULL DEFAULT '0000-00-00',
  `DOSTo` date DEFAULT NULL,
  `BillingCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Modifier1` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier2` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier3` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier4` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `DXPointer` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `BillingMonth` int(11) NOT NULL DEFAULT '0',
  `SendCMN_RX_w_invoice` tinyint(1) NOT NULL DEFAULT '0',
  `SpecialCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `ReviewCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `MedicallyUnnecessary` tinyint(1) NOT NULL DEFAULT '0',
  `AuthorizationNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `AuthorizationTypeID` int(11) DEFAULT NULL,
  `InvoiceNotes` varchar(255) COLLATE latin1_general_ci DEFAULT NULL,
  `InvoiceRecord` varchar(255) COLLATE latin1_general_ci DEFAULT NULL,
  `CMNFormID` int(11) DEFAULT NULL,
  `HAOCode` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `BillIns1` tinyint(1) NOT NULL DEFAULT '1',
  `BillIns2` tinyint(1) NOT NULL DEFAULT '1',
  `BillIns3` tinyint(1) NOT NULL DEFAULT '1',
  `BillIns4` tinyint(1) NOT NULL DEFAULT '1',
  `Hardship` tinyint(1) NOT NULL DEFAULT '0',
  `ShowSpanDates` tinyint(1) NOT NULL DEFAULT '0',
  `PaymentAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `WriteoffAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `CurrentPayer` enum('Ins1','Ins2','Ins3','Ins4','Patient','None') COLLATE latin1_general_ci NOT NULL DEFAULT 'Ins1',
  `Pendings` tinyint(4) NOT NULL DEFAULT '0',
  `Submits` tinyint(4) NOT NULL DEFAULT '0',
  `Payments` tinyint(4) NOT NULL DEFAULT '0',
  `SubmittedDate` date DEFAULT NULL,
  `Submitted` tinyint(1) NOT NULL DEFAULT '0',
  `CurrentInsuranceCompanyID` int(11) DEFAULT NULL,
  `CurrentCustomerInsuranceID` int(11) DEFAULT NULL,
  `AcceptAssignment` tinyint(1) NOT NULL DEFAULT '0',
  `DeductibleAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `DrugNoteField` varchar(20) COLLATE latin1_general_ci DEFAULT NULL,
  `DrugControlNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `NopayIns1` tinyint(1) NOT NULL DEFAULT '0',
  `PointerICD10` smallint(6) NOT NULL DEFAULT '0',
  `DXPointer10` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `HaoDescription` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_CUSTOMERID_INVOICEID_ID` (`CustomerID`,`InvoiceID`,`ID`),
  CONSTRAINT `FK_INVOICE` FOREIGN KEY (`CustomerID`, `InvoiceID`) REFERENCES `tbl_invoice` (`CustomerID`, `ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_invoiceform`
--

DROP TABLE IF EXISTS `tbl_invoiceform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_invoiceform` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ReportFileName` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `MarginTop` double NOT NULL DEFAULT '0.25',
  `MarginLeft` double NOT NULL DEFAULT '0.19',
  `MarginBottom` double NOT NULL DEFAULT '0.18',
  `MarginRight` double NOT NULL DEFAULT '0.22',
  `SpecialCoding` varchar(20) COLLATE latin1_general_ci DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_invoicenotes`
--

DROP TABLE IF EXISTS `tbl_invoicenotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_invoicenotes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceDetailsID` int(11) NOT NULL DEFAULT '0',
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `CallbackDate` date DEFAULT NULL,
  `Done` tinyint(1) NOT NULL DEFAULT '0',
  `Notes` longtext COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_kit`
--

DROP TABLE IF EXISTS `tbl_kit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_kit` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_kitdetails`
--

DROP TABLE IF EXISTS `tbl_kitdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_kitdetails` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KitID` int(11) NOT NULL,
  `WarehouseID` int(11) NOT NULL,
  `InventoryItemID` int(11) NOT NULL,
  `PriceCodeID` int(11) DEFAULT NULL,
  `Quantity` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_legalrep`
--

DROP TABLE IF EXISTS `tbl_legalrep`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_legalrep` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Courtesy` enum('Dr.','Miss','Mr.','Mrs.','Rev.') COLLATE latin1_general_ci NOT NULL,
  `FirstName` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `OfficePhone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `LastName` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `MiddleName` varchar(1) COLLATE latin1_general_ci NOT NULL,
  `Mobile` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Pager` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Suffix` varchar(4) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `FirmName` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_location`
--

DROP TABLE IF EXISTS `tbl_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_location` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Code` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `FEDTaxID` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `TaxIDType` enum('SSN','EIN') COLLATE latin1_general_ci NOT NULL DEFAULT 'SSN',
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PrintInfoOnDelPupTicket` tinyint(1) DEFAULT NULL,
  `PrintInfoOnInvoiceAcctStatements` tinyint(1) DEFAULT NULL,
  `PrintInfoOnPartProvider` tinyint(1) DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `NPI` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `InvoiceFormID` int(11) DEFAULT NULL,
  `PriceCodeID` int(11) DEFAULT NULL,
  `ParticipatingProvider` tinyint(1) DEFAULT NULL,
  `Email` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `WarehouseID` int(11) DEFAULT NULL,
  `POSTypeID` int(11) DEFAULT '12',
  `TaxRateID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_manufacturer`
--

DROP TABLE IF EXISTS `tbl_manufacturer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_manufacturer` (
  `AccountNumber` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_medicalconditions`
--

DROP TABLE IF EXISTS `tbl_medicalconditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_medicalconditions` (
  `Code` varchar(6) COLLATE latin1_general_ci NOT NULL,
  `Description` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_object`
--

DROP TABLE IF EXISTS `tbl_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_object` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Description` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_order`
--

DROP TABLE IF EXISTS `tbl_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_order` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `Approved` tinyint(1) NOT NULL DEFAULT '0',
  `RetailSales` tinyint(1) NOT NULL DEFAULT '0',
  `OrderDate` date DEFAULT NULL,
  `DeliveryDate` date DEFAULT NULL,
  `BillDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `ShippingMethodID` int(11) DEFAULT NULL,
  `SpecialInstructions` text COLLATE latin1_general_ci,
  `TicketMesage` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `CustomerInsurance1_ID` int(11) DEFAULT NULL,
  `CustomerInsurance2_ID` int(11) DEFAULT NULL,
  `CustomerInsurance3_ID` int(11) DEFAULT NULL,
  `CustomerInsurance4_ID` int(11) DEFAULT NULL,
  `ICD9_1` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_2` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_3` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD9_4` varchar(6) COLLATE latin1_general_ci DEFAULT NULL,
  `DoctorID` int(11) DEFAULT NULL,
  `POSTypeID` int(11) DEFAULT NULL,
  `TakenBy` varchar(50) COLLATE latin1_general_ci DEFAULT '',
  `Discount` double DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `SaleType` enum('Retail','Back Office') COLLATE latin1_general_ci NOT NULL DEFAULT 'Back Office',
  `State` enum('New','Approved','Closed','Canceled') COLLATE latin1_general_ci NOT NULL DEFAULT 'New',
  `MIR` set('BillDate','CustomerID','DeliveryDate','Customer.Inactive','Customer.MIR','Policy1.Required','Policy1.MIR','Policy2.Required','Policy2.MIR','Facility.MIR','PosType.Required','ICD9.Required','ICD9.1.Unknown','ICD9.1.Inactive','ICD9.2.Unknown','ICD9.2.Inactive','ICD9.3.Unknown','ICD9.3.Inactive','ICD9.4.Unknown','ICD9.4.Inactive','ICD10.Required','ICD10.01.Unknown','ICD10.01.Inactive','ICD10.02.Unknown','ICD10.02.Inactive','ICD10.03.Unknown','ICD10.03.Inactive','ICD10.04.Unknown','ICD10.04.Inactive','ICD10.05.Unknown','ICD10.05.Inactive','ICD10.06.Unknown','ICD10.06.Inactive','ICD10.07.Unknown','ICD10.07.Inactive','ICD10.08.Unknown','ICD10.08.Inactive','ICD10.09.Unknown','ICD10.09.Inactive','ICD10.10.Unknown','ICD10.10.Inactive','ICD10.11.Unknown','ICD10.11.Inactive','ICD10.12.Unknown','ICD10.12.Inactive') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AcceptAssignment` tinyint(1) NOT NULL DEFAULT '0',
  `ClaimNote` varchar(80) COLLATE latin1_general_ci DEFAULT NULL,
  `FacilityID` int(11) DEFAULT NULL,
  `ReferralID` int(11) DEFAULT NULL,
  `SalesrepID` int(11) DEFAULT NULL,
  `LocationID` int(11) DEFAULT NULL,
  `Archived` tinyint(1) NOT NULL DEFAULT '0',
  `TakenAt` datetime DEFAULT NULL,
  `ICD10_01` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_02` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_03` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_04` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_05` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_06` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_07` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_08` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_09` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_10` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_11` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `ICD10_12` varchar(8) COLLATE latin1_general_ci DEFAULT NULL,
  `UserField1` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `UserField2` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `IDX_CUSTOMERID_ID` (`CustomerID`,`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_order_survey`
--

DROP TABLE IF EXISTS `tbl_order_survey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_order_survey` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SurveyID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `Form` text COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `OrderID` (`OrderID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_orderdeposits`
--

DROP TABLE IF EXISTS `tbl_orderdeposits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_orderdeposits` (
  `OrderDetailsID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  `Amount` decimal(18,2) NOT NULL,
  `Date` date NOT NULL,
  `LastUpdateUserID` smallint(6) NOT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`OrderDetailsID`),
  KEY `IDX_ORDERDEPOSITS` (`CustomerID`,`OrderID`,`OrderDetailsID`),
  CONSTRAINT `FK_ORDERDEPOSITS_ORDER` FOREIGN KEY (`CustomerID`, `OrderID`) REFERENCES `tbl_order` (`CustomerID`, `ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ORDERDEPOSITS_ORDERDETAILS` FOREIGN KEY (`OrderDetailsID`) REFERENCES `tbl_orderdetails` (`ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_orderdetails`
--

DROP TABLE IF EXISTS `tbl_orderdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_orderdetails` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) NOT NULL DEFAULT '0',
  `CustomerID` int(11) NOT NULL DEFAULT '0',
  `SerialNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `PriceCodeID` int(11) NOT NULL DEFAULT '0',
  `SaleRentType` enum('Medicare Oxygen Rental','One Time Rental','Monthly Rental','Capped Rental','Parental Capped Rental','Rent to Purchase','One Time Sale','Re-occurring Sale') COLLATE latin1_general_ci NOT NULL DEFAULT 'Monthly Rental',
  `SerialID` int(11) DEFAULT NULL,
  `BillablePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `AllowablePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Taxable` tinyint(1) NOT NULL DEFAULT '0',
  `FlatRate` tinyint(1) NOT NULL DEFAULT '0',
  `DOSFrom` date NOT NULL DEFAULT '0000-00-00',
  `DOSTo` date DEFAULT NULL,
  `PickupDate` date DEFAULT NULL,
  `ShowSpanDates` tinyint(1) NOT NULL DEFAULT '0',
  `OrderedQuantity` double NOT NULL DEFAULT '0',
  `OrderedUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `OrderedWhen` enum('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually') COLLATE latin1_general_ci NOT NULL DEFAULT 'One time',
  `OrderedConverter` double NOT NULL DEFAULT '1',
  `BilledQuantity` double NOT NULL DEFAULT '0',
  `BilledUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `BilledWhen` enum('One time','Daily','Weekly','Monthly','Calendar Monthly','Quarterly','Semi-Annually','Annually','Custom') COLLATE latin1_general_ci NOT NULL DEFAULT 'One time',
  `BilledConverter` double NOT NULL DEFAULT '1',
  `DeliveryQuantity` double NOT NULL DEFAULT '0',
  `DeliveryUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `DeliveryConverter` double NOT NULL DEFAULT '1',
  `BillingCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Modifier1` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier2` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier3` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier4` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `DXPointer` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `BillingMonth` int(11) NOT NULL DEFAULT '1',
  `BillItemOn` enum('Day of Delivery','Last day of the Month','Last day of the Period','Day of Pick-up') COLLATE latin1_general_ci NOT NULL DEFAULT 'Day of Delivery',
  `AuthorizationNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `AuthorizationTypeID` int(11) DEFAULT NULL,
  `ReasonForPickup` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `SendCMN_RX_w_invoice` tinyint(1) NOT NULL DEFAULT '0',
  `MedicallyUnnecessary` tinyint(1) NOT NULL DEFAULT '0',
  `Sale` tinyint(1) NOT NULL DEFAULT '0',
  `SpecialCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `ReviewCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `NextOrderID` int(11) DEFAULT NULL,
  `ReoccuringID` int(11) DEFAULT NULL,
  `CMNFormID` int(11) DEFAULT NULL,
  `HAOCode` varchar(10) COLLATE latin1_general_ci DEFAULT NULL,
  `State` enum('New','Approved','Pickup','Closed','Canceled') COLLATE latin1_general_ci NOT NULL DEFAULT 'New',
  `BillIns1` tinyint(1) NOT NULL DEFAULT '1',
  `BillIns2` tinyint(1) NOT NULL DEFAULT '1',
  `BillIns3` tinyint(1) NOT NULL DEFAULT '1',
  `BillIns4` tinyint(1) NOT NULL DEFAULT '1',
  `EndDate` date DEFAULT NULL,
  `MIR` set('InventoryItemID','PriceCodeID','SaleRentType','OrderedQuantity','OrderedUnits','OrderedWhen','OrderedConverter','BilledQuantity','BilledUnits','BilledWhen','BilledConverter','DeliveryQuantity','DeliveryUnits','DeliveryConverter','BillingCode','BillItemOn','DXPointer9','DXPointer10','Modifier1','Modifier2','Modifier3','CMNForm.Required','CMNForm.RecertificationDate','CMNForm.FormExpired','CMNForm.MIR','EndDate.Invalid','EndDate.Unconfirmed','AuthorizationNumber.Expired','AuthorizationNumber.Expires') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `NextBillingDate` date DEFAULT NULL,
  `WarehouseID` int(11) NOT NULL,
  `AcceptAssignment` tinyint(1) NOT NULL DEFAULT '0',
  `DrugNoteField` varchar(20) COLLATE latin1_general_ci DEFAULT NULL,
  `DrugControlNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `NopayIns1` tinyint(1) NOT NULL DEFAULT '0',
  `PointerICD10` smallint(6) NOT NULL DEFAULT '0',
  `DXPointer10` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `MIR.ORDER` set('Customer.Inactive','Customer.MIR','Policy1.Required','Policy1.MIR','Policy2.Required','Policy2.MIR','Facility.MIR','PosType.Required','ICD9.Required','ICD9.1.Unknown','ICD9.1.Inactive','ICD9.2.Unknown','ICD9.2.Inactive','ICD9.3.Unknown','ICD9.3.Inactive','ICD9.4.Unknown','ICD9.4.Inactive','ICD10.Required','ICD10.01.Unknown','ICD10.01.Inactive','ICD10.02.Unknown','ICD10.02.Inactive','ICD10.03.Unknown','ICD10.03.Inactive','ICD10.04.Unknown','ICD10.04.Inactive','ICD10.05.Unknown','ICD10.05.Inactive','ICD10.06.Unknown','ICD10.06.Inactive','ICD10.07.Unknown','ICD10.07.Inactive','ICD10.08.Unknown','ICD10.08.Inactive','ICD10.09.Unknown','ICD10.09.Inactive','ICD10.10.Unknown','ICD10.10.Inactive','ICD10.11.Unknown','ICD10.11.Inactive','ICD10.12.Unknown','ICD10.12.Inactive') COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `HaoDescription` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  `UserField1` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `UserField2` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `AuthorizationExpirationDate` date DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_CUSTOMERID_ORDERID_ID` (`CustomerID`,`OrderID`,`ID`),
  KEY `IDX_CUSTOMERID_ORDERID_ID_INVENTORYITEMID` (`CustomerID`,`OrderID`,`ID`,`InventoryItemID`),
  KEY `IDX_CUSTOMERID_NEXTORDERID` (`CustomerID`,`NextOrderID`),
  KEY `IDX_InventoryItemID_SerialNumber` (`InventoryItemID`,`SerialNumber`),
  CONSTRAINT `FK_NEXTORDER` FOREIGN KEY (`CustomerID`, `NextOrderID`) REFERENCES `tbl_order` (`CustomerID`, `ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ORDER` FOREIGN KEY (`CustomerID`, `OrderID`) REFERENCES `tbl_order` (`CustomerID`, `ID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_payer`
--

DROP TABLE IF EXISTS `tbl_payer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_payer` (
  `InsuranceCompanyID` int(11) NOT NULL,
  `ParticipatingProvider` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) NOT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ExtractOrderingPhysician` tinyint(1) NOT NULL DEFAULT '1',
  `ExtractReferringPhysician` tinyint(1) NOT NULL DEFAULT '0',
  `ExtractRenderingProvider` tinyint(1) NOT NULL DEFAULT '0',
  `TaxonomyCodePrefix` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`InsuranceCompanyID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_paymentplan`
--

DROP TABLE IF EXISTS `tbl_paymentplan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_paymentplan` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL,
  `Period` enum('Weekly','Bi-weekly','Monthly') COLLATE latin1_general_ci NOT NULL DEFAULT 'Weekly',
  `FirstPayment` date NOT NULL DEFAULT '1900-01-01',
  `PaymentCount` int(11) NOT NULL,
  `PaymentAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Details` mediumtext COLLATE latin1_general_ci,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_paymentplan_payments`
--

DROP TABLE IF EXISTS `tbl_paymentplan_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_paymentplan_payments` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `PaymentPlanID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  `Index` int(11) NOT NULL,
  `DueDate` date NOT NULL DEFAULT '1900-01-01',
  `DueAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `PaymentDate` date DEFAULT NULL,
  `PaymentAmount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Details` mediumtext COLLATE latin1_general_ci,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_permissions`
--

DROP TABLE IF EXISTS `tbl_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_permissions` (
  `UserID` smallint(6) NOT NULL,
  `ObjectID` smallint(6) NOT NULL,
  `ADD_EDIT` tinyint(1) NOT NULL DEFAULT '0',
  `DELETE` tinyint(1) NOT NULL DEFAULT '0',
  `PROCESS` tinyint(1) NOT NULL DEFAULT '0',
  `VIEW` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`,`ObjectID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_postype`
--

DROP TABLE IF EXISTS `tbl_postype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_postype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_predefinedtext`
--

DROP TABLE IF EXISTS `tbl_predefinedtext`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_predefinedtext` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Type` enum('Document Text','Account Statements','Compliance Notes','Customer Notes','Invoice Notes','HAO') COLLATE latin1_general_ci NOT NULL DEFAULT 'Document Text',
  `Text` longtext COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_pricecode`
--

DROP TABLE IF EXISTS `tbl_pricecode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_pricecode` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_pricecode_item`
--

DROP TABLE IF EXISTS `tbl_pricecode_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_pricecode_item` (
  `AcceptAssignment` tinyint(1) NOT NULL DEFAULT '0',
  `OrderedQuantity` double NOT NULL DEFAULT '0',
  `OrderedUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `OrderedWhen` enum('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually') COLLATE latin1_general_ci NOT NULL DEFAULT 'One time',
  `OrderedConverter` double NOT NULL DEFAULT '1',
  `BilledUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `BilledWhen` enum('One time','Daily','Weekly','Monthly','Calendar Monthly','Quarterly','Semi-Annually','Annually','Custom') COLLATE latin1_general_ci NOT NULL DEFAULT 'One time',
  `BilledConverter` double NOT NULL DEFAULT '1',
  `DeliveryUnits` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `DeliveryConverter` double NOT NULL DEFAULT '1',
  `BillingCode` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `BillItemOn` enum('Day of Delivery','Last day of the Month','Last day of the Period','Day of Pick-up') COLLATE latin1_general_ci NOT NULL DEFAULT 'Day of Delivery',
  `DefaultCMNType` enum('DMERC 02.03A','DMERC 02.03B','DMERC 03.02','DMERC 07.02B','DMERC 08.02','DMERC DRORDER','DMERC URO','DME 04.04B','DME 04.04C','DME 06.03B','DME 07.03A','DME 09.03','DME 10.03','DME 484.03') COLLATE latin1_general_ci NOT NULL DEFAULT 'DME 484.03',
  `DefaultOrderType` enum('Sale','Rental') COLLATE latin1_general_ci NOT NULL DEFAULT 'Sale',
  `AuthorizationTypeID` int(11) DEFAULT NULL,
  `FlatRate` tinyint(1) NOT NULL DEFAULT '0',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `Modifier1` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier2` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier3` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Modifier4` varchar(8) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `PriceCodeID` int(11) NOT NULL DEFAULT '0',
  `PredefinedTextID` int(11) DEFAULT NULL,
  `Rent_AllowablePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Rent_BillablePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Sale_AllowablePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Sale_BillablePrice` decimal(18,2) NOT NULL DEFAULT '0.00',
  `RentalType` enum('Medicare Oxygen Rental','One Time Rental','Monthly Rental','Capped Rental','Parental Capped Rental','Rent to Purchase') COLLATE latin1_general_ci NOT NULL DEFAULT 'Monthly Rental',
  `ReoccuringSale` tinyint(1) NOT NULL DEFAULT '0',
  `ShowSpanDates` tinyint(1) NOT NULL DEFAULT '0',
  `Taxable` tinyint(1) NOT NULL DEFAULT '0',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `BillInsurance` tinyint(1) NOT NULL DEFAULT '1',
  `DrugNoteField` varchar(20) COLLATE latin1_general_ci DEFAULT NULL,
  `DrugControlNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `UserField1` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `UserField2` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `InventoryItemID` (`InventoryItemID`,`PriceCodeID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_producttype`
--

DROP TABLE IF EXISTS `tbl_producttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_producttype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_provider`
--

DROP TABLE IF EXISTS `tbl_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_provider` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `LocationID` int(11) NOT NULL DEFAULT '0',
  `InsuranceCompanyID` int(11) NOT NULL DEFAULT '0',
  `ProviderNumber` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Password` varchar(20) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ProviderNumberType` varchar(6) COLLATE latin1_general_ci NOT NULL DEFAULT '1C',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_providernumbertype`
--

DROP TABLE IF EXISTS `tbl_providernumbertype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_providernumbertype` (
  `Code` varchar(6) COLLATE latin1_general_ci NOT NULL,
  `Description` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_purchaseorder`
--

DROP TABLE IF EXISTS `tbl_purchaseorder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_purchaseorder` (
  `Approved` tinyint(1) NOT NULL DEFAULT '0',
  `Cost` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Freight` decimal(18,2) NOT NULL DEFAULT '0.00',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Tax` decimal(18,2) NOT NULL DEFAULT '0.00',
  `TotalDue` decimal(18,2) NOT NULL DEFAULT '0.00',
  `VendorID` int(11) NOT NULL,
  `ShipToName` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ShipToAddress1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `ShipToAddress2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `ShipToCity` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `ShipToState` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `ShipToZip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `ShipToPhone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `OrderDate` date DEFAULT NULL,
  `CompanyName` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `CompanyAddress1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `CompanyAddress2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `CompanyCity` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `CompanyState` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `CompanyZip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ShipVia` enum('BEST WAY','UPS/RPS') COLLATE latin1_general_ci DEFAULT NULL,
  `FOB` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `VendorSalesRep` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Terms` text COLLATE latin1_general_ci,
  `CompanyPhone` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `TaxRateID` int(11) DEFAULT NULL,
  `Reoccuring` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedDate` date DEFAULT NULL,
  `CreatedUserID` smallint(6) DEFAULT NULL,
  `SubmittedDate` date DEFAULT NULL,
  `SubmittedUserID` smallint(6) DEFAULT NULL,
  `LocationID` int(11) DEFAULT NULL,
  `Number` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Archived` tinyint(1) NOT NULL DEFAULT '0',
  `ConfirmationNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ix_purchaseorder_search` (`LocationID`,`ID`,`Number`,`VendorID`,`OrderDate`,`SubmittedDate`,`Approved`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_purchaseorderdetails`
--

DROP TABLE IF EXISTS `tbl_purchaseorderdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_purchaseorderdetails` (
  `BackOrder` int(11) NOT NULL DEFAULT '0',
  `Ordered` int(11) NOT NULL DEFAULT '0',
  `Received` int(11) NOT NULL DEFAULT '0',
  `Price` double NOT NULL DEFAULT '0',
  `Customer` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `DatePromised` date DEFAULT NULL,
  `DateReceived` date DEFAULT NULL,
  `DropShipToCustomer` tinyint(1) NOT NULL DEFAULT '0',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `InventoryItemID` int(11) NOT NULL,
  `PurchaseOrderID` int(11) DEFAULT NULL,
  `WarehouseID` int(11) DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `VendorSTKNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `ReferenceNumber` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ix_purchaseorderdetails_parent` (`PurchaseOrderID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_referral`
--

DROP TABLE IF EXISTS `tbl_referral`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_referral` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Courtesy` enum('Dr.','Miss','Mr.','Mrs.','Rev.') COLLATE latin1_general_ci NOT NULL,
  `Employer` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `FirstName` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `HomePhone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `LastName` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `MiddleName` varchar(1) COLLATE latin1_general_ci NOT NULL,
  `Mobile` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ReferralTypeID` int(11) DEFAULT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Suffix` varchar(4) COLLATE latin1_general_ci NOT NULL,
  `WorkPhone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastContacted` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_referraltype`
--

DROP TABLE IF EXISTS `tbl_referraltype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_referraltype` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_relationship`
--

DROP TABLE IF EXISTS `tbl_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_relationship` (
  `Code` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Description` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_salesrep`
--

DROP TABLE IF EXISTS `tbl_salesrep`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_salesrep` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Courtesy` enum('Dr.','Miss','Mr.','Mrs.','Rev.') COLLATE latin1_general_ci NOT NULL,
  `FirstName` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `HomePhone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `LastName` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `MiddleName` varchar(1) COLLATE latin1_general_ci NOT NULL,
  `Mobile` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Pager` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Suffix` varchar(4) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_serial`
--

DROP TABLE IF EXISTS `tbl_serial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_serial` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CurrentCustomerID` int(11) DEFAULT NULL,
  `InventoryItemID` int(11) NOT NULL DEFAULT '0',
  `LastCustomerID` int(11) DEFAULT NULL,
  `ManufacturerID` int(11) DEFAULT NULL,
  `VendorID` int(11) DEFAULT NULL,
  `WarehouseID` int(11) DEFAULT NULL,
  `LengthOfWarranty` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LotNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MaintenanceRecord` longtext COLLATE latin1_general_ci NOT NULL,
  `ManufaturerSerialNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ModelNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `MonthsRented` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `NextMaintenanceDate` date DEFAULT NULL,
  `PurchaseOrderID` int(11) DEFAULT NULL,
  `PurchaseAmount` double NOT NULL DEFAULT '0',
  `PurchaseDate` date DEFAULT NULL,
  `SerialNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `SoldDate` date DEFAULT NULL,
  `Status` enum('Empty','Filled','Junked','Lost','Reserved','On Hand','Rented','Sold','Sent','Maintenance','Transferred Out') COLLATE latin1_general_ci NOT NULL DEFAULT 'Empty',
  `Warranty` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `OwnRent` enum('Own','Rent') COLLATE latin1_general_ci NOT NULL DEFAULT 'Own',
  `FirstRented` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `SalvageValue` decimal(18,2) DEFAULT NULL,
  `SalePrice` decimal(18,2) DEFAULT NULL,
  `ConsignmentType` varchar(20) COLLATE latin1_general_ci DEFAULT NULL,
  `ConsignmentName` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `ConsignmentDate` datetime DEFAULT NULL,
  `VendorStockNumber` varchar(20) COLLATE latin1_general_ci DEFAULT NULL,
  `LotNumberExpires` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_InventoryItemID_SerialNumber` (`InventoryItemID`,`SerialNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_serial_maintenance`
--

DROP TABLE IF EXISTS `tbl_serial_maintenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_serial_maintenance` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SerialID` int(11) NOT NULL,
  `AdditionalEquipment` text COLLATE latin1_general_ci,
  `DescriptionOfProblem` text COLLATE latin1_general_ci,
  `DescriptionOfWork` text COLLATE latin1_general_ci,
  `MaintenanceRecord` text COLLATE latin1_general_ci,
  `LaborHours` varchar(255) COLLATE latin1_general_ci DEFAULT NULL,
  `Technician` varchar(255) COLLATE latin1_general_ci DEFAULT NULL,
  `MaintenanceDue` date DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `MaintenanceCost` decimal(18,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_serial_transaction`
--

DROP TABLE IF EXISTS `tbl_serial_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_serial_transaction` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `TypeID` int(11) NOT NULL DEFAULT '0',
  `SerialID` int(11) NOT NULL DEFAULT '0',
  `TransactionDatetime` datetime NOT NULL,
  `VendorID` int(11) DEFAULT NULL,
  `WarehouseID` int(11) DEFAULT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `OrderID` int(11) DEFAULT NULL,
  `OrderDetailsID` int(11) DEFAULT NULL,
  `LotNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_serial_transaction_type`
--

DROP TABLE IF EXISTS `tbl_serial_transaction_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_serial_transaction_type` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_sessions`
--

DROP TABLE IF EXISTS `tbl_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_sessions` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` smallint(6) NOT NULL,
  `LoginTime` datetime NOT NULL,
  `LastUpdateTime` datetime NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_shippingmethod`
--

DROP TABLE IF EXISTS `tbl_shippingmethod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_shippingmethod` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Type` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_signaturetype`
--

DROP TABLE IF EXISTS `tbl_signaturetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_signaturetype` (
  `Code` char(1) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Description` varchar(100) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_submitter`
--

DROP TABLE IF EXISTS `tbl_submitter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_submitter` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ECSFormat` enum('Region A','Region B','Region C','Region D') COLLATE latin1_general_ci DEFAULT NULL,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Number` varchar(16) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Password` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Production` tinyint(1) NOT NULL DEFAULT '0',
  `ContactName` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone1` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastBatchNumber` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_survey`
--

DROP TABLE IF EXISTS `tbl_survey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_survey` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `Description` varchar(200) COLLATE latin1_general_ci NOT NULL,
  `Template` mediumtext COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_taxrate`
--

DROP TABLE IF EXISTS `tbl_taxrate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_taxrate` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CityTax` double DEFAULT NULL,
  `CountyTax` double DEFAULT NULL,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `OtherTax` double DEFAULT NULL,
  `StateTax` double DEFAULT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_user`
--

DROP TABLE IF EXISTS `tbl_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_user` (
  `ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `Login` varchar(16) COLLATE latin1_general_ci NOT NULL,
  `Password` varchar(32) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Email` varchar(150) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Login` (`Login`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_user_location`
--

DROP TABLE IF EXISTS `tbl_user_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_user_location` (
  `UserID` smallint(6) NOT NULL,
  `LocationID` int(11) NOT NULL,
  PRIMARY KEY (`UserID`,`LocationID`),
  UNIQUE KEY `LocationID` (`LocationID`,`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_user_notifications`
--

DROP TABLE IF EXISTS `tbl_user_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_user_notifications` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Args` varchar(255) COLLATE latin1_general_ci NOT NULL,
  `UserID` smallint(6) NOT NULL,
  `Datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
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
-- Table structure for table `tbl_vendor`
--

DROP TABLE IF EXISTS `tbl_vendor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_vendor` (
  `AccountNumber` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL,
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `State` varchar(2) COLLATE latin1_general_ci NOT NULL,
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL,
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Comments` text COLLATE latin1_general_ci,
  `FOBDelivery` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `Terms` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `ShipVia` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_warehouse`
--

DROP TABLE IF EXISTS `tbl_warehouse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_warehouse` (
  `Address1` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Address2` varchar(40) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `City` varchar(25) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Contact` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Fax` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Phone2` varchar(50) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `State` char(2) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `Zip` varchar(10) COLLATE latin1_general_ci NOT NULL DEFAULT '',
  `LastUpdateUserID` smallint(6) DEFAULT NULL,
  `LastUpdateDatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tbl_zipcode`
--

DROP TABLE IF EXISTS `tbl_zipcode`;
/*!50001 DROP VIEW IF EXISTS `tbl_zipcode`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `tbl_zipcode` AS SELECT 
 1 AS `Zip`,
 1 AS `State`,
 1 AS `City`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_billinglist`
--

DROP TABLE IF EXISTS `view_billinglist`;
/*!50001 DROP VIEW IF EXISTS `view_billinglist`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_billinglist` AS SELECT 
 1 AS `OrderID`,
 1 AS `BillingMonth`,
 1 AS `BillingFlags`,
 1 AS `BillingTypeID`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_invoicetransaction_statistics`
--

DROP TABLE IF EXISTS `view_invoicetransaction_statistics`;
/*!50001 DROP VIEW IF EXISTS `view_invoicetransaction_statistics`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_invoicetransaction_statistics` AS SELECT 
 1 AS `CustomerID`,
 1 AS `OrderID`,
 1 AS `InvoiceID`,
 1 AS `InvoiceDetailsID`,
 1 AS `BillableAmount`,
 1 AS `AllowableAmount`,
 1 AS `Quantity`,
 1 AS `Hardship`,
 1 AS `BillingCode`,
 1 AS `InventoryItemID`,
 1 AS `DOSFrom`,
 1 AS `DOSTo`,
 1 AS `Insurance1_ID`,
 1 AS `Insurance2_ID`,
 1 AS `Insurance3_ID`,
 1 AS `Insurance4_ID`,
 1 AS `InsuranceCompany1_ID`,
 1 AS `InsuranceCompany2_ID`,
 1 AS `InsuranceCompany3_ID`,
 1 AS `InsuranceCompany4_ID`,
 1 AS `Percent`,
 1 AS `Basis`,
 1 AS `PaymentAmount`,
 1 AS `WriteoffAmount`,
 1 AS `Insurances`,
 1 AS `PendingSubmissions`,
 1 AS `Submits`,
 1 AS `Payments`,
 1 AS `CurrentInsuranceID`,
 1 AS `CurrentInsuranceCompanyID`,
 1 AS `InvoiceSubmitted`,
 1 AS `SubmittedDate`,
 1 AS `CurrentPayer`,
 1 AS `NopayIns1`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_mir`
--

DROP TABLE IF EXISTS `view_mir`;
/*!50001 DROP VIEW IF EXISTS `view_mir`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_mir` AS SELECT 
 1 AS `OrderDetailsID`,
 1 AS `OrderID`,
 1 AS `OrderApproved`,
 1 AS `CustomerID`,
 1 AS `CustomerName`,
 1 AS `CustomerInsuranceID_1`,
 1 AS `InsuranceCompanyID_1`,
 1 AS `CustomerInsuranceID_2`,
 1 AS `InsuranceCompanyID_2`,
 1 AS `CMNFormID`,
 1 AS `FacilityID`,
 1 AS `DoctorID`,
 1 AS `SaleRentType`,
 1 AS `BillingCode`,
 1 AS `Payers`,
 1 AS `InventoryItem`,
 1 AS `PriceCode`,
 1 AS `MIR`,
 1 AS `Details`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_orderdetails`
--

DROP TABLE IF EXISTS `view_orderdetails`;
/*!50001 DROP VIEW IF EXISTS `view_orderdetails`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_orderdetails` AS SELECT 
 1 AS `ID`,
 1 AS `OrderID`,
 1 AS `CustomerID`,
 1 AS `SerialNumber`,
 1 AS `InventoryItemID`,
 1 AS `PriceCodeID`,
 1 AS `SaleRentType`,
 1 AS `SerialID`,
 1 AS `BillablePrice`,
 1 AS `AllowablePrice`,
 1 AS `Taxable`,
 1 AS `FlatRate`,
 1 AS `DOSFrom`,
 1 AS `DOSTo`,
 1 AS `PickupDate`,
 1 AS `ShowSpanDates`,
 1 AS `OrderedQuantity`,
 1 AS `OrderedUnits`,
 1 AS `OrderedWhen`,
 1 AS `OrderedConverter`,
 1 AS `BilledQuantity`,
 1 AS `BilledUnits`,
 1 AS `BilledWhen`,
 1 AS `BilledConverter`,
 1 AS `DeliveryQuantity`,
 1 AS `DeliveryUnits`,
 1 AS `DeliveryConverter`,
 1 AS `BillingCode`,
 1 AS `Modifier1`,
 1 AS `Modifier2`,
 1 AS `Modifier3`,
 1 AS `Modifier4`,
 1 AS `DXPointer`,
 1 AS `BillingMonth`,
 1 AS `BillItemOn`,
 1 AS `AuthorizationNumber`,
 1 AS `AuthorizationTypeID`,
 1 AS `ReasonForPickup`,
 1 AS `SendCMN_RX_w_invoice`,
 1 AS `MedicallyUnnecessary`,
 1 AS `Sale`,
 1 AS `SpecialCode`,
 1 AS `ReviewCode`,
 1 AS `NextOrderID`,
 1 AS `ReoccuringID`,
 1 AS `CMNFormID`,
 1 AS `HAOCode`,
 1 AS `State`,
 1 AS `BillIns1`,
 1 AS `BillIns2`,
 1 AS `BillIns3`,
 1 AS `BillIns4`,
 1 AS `EndDate`,
 1 AS `MIR`,
 1 AS `NextBillingDate`,
 1 AS `WarehouseID`,
 1 AS `AcceptAssignment`,
 1 AS `DrugNoteField`,
 1 AS `DrugControlNumber`,
 1 AS `NopayIns1`,
 1 AS `PointerICD10`,
 1 AS `DXPointer10`,
 1 AS `MIR.ORDER`,
 1 AS `HaoDescription`,
 1 AS `UserField1`,
 1 AS `UserField2`,
 1 AS `AuthorizationExpirationDate`,
 1 AS `IsActive`,
 1 AS `IsCanceled`,
 1 AS `IsSold`,
 1 AS `IsRented`,
 1 AS `ActualSaleRentType`,
 1 AS `ActualBillItemOn`,
 1 AS `ActualOrderedWhen`,
 1 AS `ActualBilledWhen`,
 1 AS `ActualDosTo`,
 1 AS `InvoiceDate`,
 1 AS `IsOxygen`,
 1 AS `IsZeroAmount`,
 1 AS `IsPickedup`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_orderdetails_core`
--

DROP TABLE IF EXISTS `view_orderdetails_core`;
/*!50001 DROP VIEW IF EXISTS `view_orderdetails_core`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_orderdetails_core` AS SELECT 
 1 AS `ID`,
 1 AS `OrderID`,
 1 AS `CustomerID`,
 1 AS `SerialNumber`,
 1 AS `InventoryItemID`,
 1 AS `PriceCodeID`,
 1 AS `SaleRentType`,
 1 AS `SerialID`,
 1 AS `BillablePrice`,
 1 AS `AllowablePrice`,
 1 AS `Taxable`,
 1 AS `FlatRate`,
 1 AS `DOSFrom`,
 1 AS `DOSTo`,
 1 AS `PickupDate`,
 1 AS `ShowSpanDates`,
 1 AS `OrderedQuantity`,
 1 AS `OrderedUnits`,
 1 AS `OrderedWhen`,
 1 AS `OrderedConverter`,
 1 AS `BilledQuantity`,
 1 AS `BilledUnits`,
 1 AS `BilledWhen`,
 1 AS `BilledConverter`,
 1 AS `DeliveryQuantity`,
 1 AS `DeliveryUnits`,
 1 AS `DeliveryConverter`,
 1 AS `BillingCode`,
 1 AS `Modifier1`,
 1 AS `Modifier2`,
 1 AS `Modifier3`,
 1 AS `Modifier4`,
 1 AS `DXPointer`,
 1 AS `BillingMonth`,
 1 AS `BillItemOn`,
 1 AS `AuthorizationNumber`,
 1 AS `AuthorizationTypeID`,
 1 AS `ReasonForPickup`,
 1 AS `SendCMN_RX_w_invoice`,
 1 AS `MedicallyUnnecessary`,
 1 AS `Sale`,
 1 AS `SpecialCode`,
 1 AS `ReviewCode`,
 1 AS `NextOrderID`,
 1 AS `ReoccuringID`,
 1 AS `CMNFormID`,
 1 AS `HAOCode`,
 1 AS `State`,
 1 AS `BillIns1`,
 1 AS `BillIns2`,
 1 AS `BillIns3`,
 1 AS `BillIns4`,
 1 AS `EndDate`,
 1 AS `MIR`,
 1 AS `NextBillingDate`,
 1 AS `WarehouseID`,
 1 AS `AcceptAssignment`,
 1 AS `DrugNoteField`,
 1 AS `DrugControlNumber`,
 1 AS `NopayIns1`,
 1 AS `PointerICD10`,
 1 AS `DXPointer10`,
 1 AS `MIR.ORDER`,
 1 AS `HaoDescription`,
 1 AS `UserField1`,
 1 AS `UserField2`,
 1 AS `AuthorizationExpirationDate`,
 1 AS `IsActive`,
 1 AS `IsCanceled`,
 1 AS `IsSold`,
 1 AS `IsRented`,
 1 AS `ActualSaleRentType`,
 1 AS `ActualBillItemOn`,
 1 AS `ActualOrderedWhen`,
 1 AS `ActualBilledWhen`,
 1 AS `ActualDosTo`,
 1 AS `InvoiceDate`,
 1 AS `IsOxygen`,
 1 AS `IsZeroAmount`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_pricecode`
--

DROP TABLE IF EXISTS `view_pricecode`;
/*!50001 DROP VIEW IF EXISTS `view_pricecode`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_pricecode` AS SELECT 
 1 AS `ID`,
 1 AS `Name`,
 1 AS `IsRetail`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_reoccuringlist`
--

DROP TABLE IF EXISTS `view_reoccuringlist`;
/*!50001 DROP VIEW IF EXISTS `view_reoccuringlist`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_reoccuringlist` AS SELECT 
 1 AS `OrderID`,
 1 AS `BilledWhen`,
 1 AS `BillItemOn`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_sequence`
--

DROP TABLE IF EXISTS `view_sequence`;
/*!50001 DROP VIEW IF EXISTS `view_sequence`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_sequence` AS SELECT 
 1 AS `num`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_sequence_core`
--

DROP TABLE IF EXISTS `view_sequence_core`;
/*!50001 DROP VIEW IF EXISTS `view_sequence_core`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_sequence_core` AS SELECT 
 1 AS `num`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_taxrate`
--

DROP TABLE IF EXISTS `view_taxrate`;
/*!50001 DROP VIEW IF EXISTS `view_taxrate`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_taxrate` AS SELECT 
 1 AS `ID`,
 1 AS `CityTax`,
 1 AS `CountyTax`,
 1 AS `Name`,
 1 AS `OtherTax`,
 1 AS `StateTax`,
 1 AS `LastUpdateUserID`,
 1 AS `LastUpdateDatetime`,
 1 AS `TotalTax`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'c02'
--
/*!50003 DROP FUNCTION IF EXISTS `GetAllowableAmount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetAllowableAmount`(

  P_SaleRentType VARCHAR(50),

  P_BillingMonth INT,

  P_Price DECIMAL(18, 2),

  P_Quantity INT,

  P_SalePrice DECIMAL(18, 2),

  B_FlatRate BIT) RETURNS decimal(18,2)
    DETERMINISTIC
BEGIN

  IF P_BillingMonth <= 0 THEN

    SET P_BillingMonth = 1; --

  END IF; --



  IF B_FlatRate = 1 THEN

    SET P_Quantity = 1; --

  END IF; --



  IF P_SaleRentType IN ('One Time Sale', 'Re-occurring Sale', 'One Time Rental') THEN

    IF P_BillingMonth = 1 THEN

      RETURN P_Price * P_Quantity; --

    END IF; --

  ELSEIF P_SaleRentType IN ('Medicare Oxygen Rental','Monthly Rental') THEN

    RETURN P_Price * P_Quantity; --

  ELSEIF P_SaleRentType = 'Rent to Purchase' THEN

    IF P_BillingMonth <= 9 THEN

      RETURN P_Price * P_Quantity; --

    ELSEIF P_BillingMonth = 10 THEN

      RETURN (P_SalePrice - 9 * P_Price) * P_Quantity; --

    END IF; --

  ELSEIF P_SaleRentType = 'Capped Rental' THEN

    IF P_BillingMonth <= 3 THEN

      RETURN P_Price * P_Quantity; --

    ELSEIF P_BillingMonth <= 15 THEN

      RETURN 0.75 * P_Price * P_Quantity; --

    ELSEIF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

      RETURN P_Price * P_Quantity; --

    END IF; --

  ELSEIF P_SaleRentType = 'Parental Capped Rental' THEN

    IF P_BillingMonth <= 15 THEN

      RETURN P_Price * P_Quantity; --

    ELSEIF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

      RETURN P_Price * P_Quantity; --

    END IF; --

  END IF; --



  RETURN 0.00; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetAmountMultiplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetAmountMultiplier`(

    P_FromDate DATETIME,

    P_ToDate DATETIME,

    P_PickupDate DATETIME,

    P_SaleRentType VARCHAR(50),

    P_OrderedWhen VARCHAR(50),

    P_BilledWhen VARCHAR(50)) RETURNS double
    DETERMINISTIC
BEGIN

    DECLARE V_NextToDate DATETIME; --



    IF     P_SaleRentType = 'One Time Sale'          THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Re-occurring Sale'      THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Rent to Purchase'       THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Capped Rental'          THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Parental Capped Rental' THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Medicare Oxygen Rental' THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Monthly Rental'         THEN

        IF (P_OrderedWhen = 'Daily') THEN

            SET V_NextToDate = GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen); --

            IF P_PickupDate IS NULL THEN

                RETURN DATEDIFF(V_NextToDate, P_FromDate); --

            ELSEIF V_NextToDate <= P_PickupDate THEN

                RETURN DATEDIFF(V_NextToDate, P_FromDate); --

            ELSEIF P_FromDate <= P_PickupDate THEN

                RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1); --

            ELSE -- P_PickupDate < P_FromDate

                RETURN 0; --

            END IF; --

        ELSE

          RETURN GetMultiplier(P_FromDate, P_ToDate, P_OrderedWhen, P_BilledWhen); --

        END IF; --

    ELSEIF P_SaleRentType = 'One Time Rental'        THEN

        IF     P_OrderedWhen = 'One Time'      THEN RETURN 1; --

        ELSEIF P_OrderedWhen = 'Daily'         THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1); --

        ELSEIF P_OrderedWhen = 'Weekly'        THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1) / 7.0; --

        ELSEIF P_OrderedWhen = 'Monthly'       THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1) / 30.4; --

        ELSEIF P_OrderedWhen = 'Quarterly'     THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1) / 91.25; --

        ELSEIF P_OrderedWhen = 'Semi-Annually' THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1) / 182.5; --

        ELSEIF P_OrderedWhen = 'Annually'      THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1) / 365.0; --

        END IF; --

    END IF; --



    RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetBillableAmount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetBillableAmount`(

  P_SaleRentType VARCHAR(50),

  P_BillingMonth INT,

  P_Price DECIMAL(18, 2),

  P_Quantity INT,

  P_SalePrice DECIMAL(18, 2),

  B_FlatRate BIT) RETURNS decimal(18,2)
    DETERMINISTIC
BEGIN

  IF P_BillingMonth <= 0 THEN

    SET P_BillingMonth = 1; --

  END IF; --



  IF B_FlatRate = 1 THEN

    SET P_Quantity = 1; --

  END IF; --



  IF P_SaleRentType IN ('One Time Sale', 'Re-occurring Sale', 'One Time Rental') THEN

    IF P_BillingMonth = 1 THEN

      RETURN P_Price * P_Quantity; --

    END IF; --

  ELSEIF P_SaleRentType IN ('Medicare Oxygen Rental','Monthly Rental') THEN

    RETURN P_Price * P_Quantity; --

  ELSEIF P_SaleRentType = 'Rent to Purchase' THEN

    IF P_BillingMonth <= 9 THEN

      RETURN P_Price * P_Quantity; --

    ELSEIF P_BillingMonth = 10 THEN

      RETURN (P_SalePrice - 9 * P_Price) * P_Quantity; --

    END IF; --

  ELSEIF P_SaleRentType = 'Capped Rental' OR P_SaleRentType = 'Parental Capped Rental' THEN

    IF P_BillingMonth <= 15 THEN

      RETURN P_Price * P_Quantity; --

    ELSEIF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

      RETURN P_Price * P_Quantity; --

    END IF; --

  END IF; --



  RETURN 0.00; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetInvoiceModifier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetInvoiceModifier`(

  P_DeliveryDate DATETIME, P_SaleRentType VARCHAR(50), P_BillingMonth INT, P_Index INT,

  P_Modifier1 VARCHAR(8), P_Modifier2 VARCHAR(8),

  P_Modifier3 VARCHAR(8), P_Modifier4 VARCHAR(8)) RETURNS varchar(2) CHARSET latin1 COLLATE latin1_general_ci
    DETERMINISTIC
BEGIN

  IF P_BillingMonth <= 0 THEN

    SET P_BillingMonth = 1; --

  END IF; --



  IF P_SaleRentType = 'Capped Rental' OR P_SaleRentType = 'Parental Capped Rental' THEN

    IF     P_Index = 1 THEN

      IF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

        RETURN 'MS'; --

      ELSE

        RETURN 'RR'; --

      END IF; --

    ELSEIF P_Index = 2 THEN

      IF P_BillingMonth = 1 THEN

        RETURN 'KH'; --

      ELSEIF P_BillingMonth <= 3 THEN

        RETURN 'KI'; --

      ELSEIF P_BillingMonth <= 15 THEN

        RETURN 'KJ'; --

      ELSEIF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

        IF P_Modifier4 = 'KX' THEN

          RETURN 'KX'; --

        ELSE

          RETURN ''; --

        END IF; --

      ELSE

        RETURN ''; --

      END IF; --

    ELSEIF P_Index = 3 THEN

      IF P_DeliveryDate < '2006-01-01' THEN

        IF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

          RETURN ''; --

        END IF; --

      ELSE

        IF (P_BillingMonth >= 12) THEN

          RETURN 'KX'; --

        END IF; --

      END IF; --

    ELSEIF P_Index = 4 THEN

      IF P_DeliveryDate < '2006-01-01' THEN

        IF (22 <= P_BillingMonth) AND ((P_BillingMonth - 22) Mod 6 = 0) THEN

          RETURN ''; --

        END IF; --

      ELSE

        IF (P_BillingMonth >= 12) THEN

          RETURN ''; --

        END IF; --

      END IF; --

    END IF; --

  END IF; --



  IF     P_Index = 1 THEN

    RETURN P_Modifier1; --

  ELSEIF P_Index = 2 THEN

    RETURN P_Modifier2; --

  ELSEIF P_Index = 3 THEN

    RETURN P_Modifier3; --

  ELSEIF P_Index = 4 THEN

    RETURN P_Modifier4; --

  ELSE

    RETURN ''; --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetMultiplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetMultiplier`(P_FromDate DATETIME, P_ToDate DATETIME, P_OrderedWhen VARCHAR(50), P_BilledWhen VARCHAR(50)) RETURNS double
    DETERMINISTIC
BEGIN

  IF P_OrderedWhen = 'One Time' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'  AND P_BilledWhen = 'Daily' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'  AND P_BilledWhen = 'Weekly' THEN RETURN 7; --

  ELSEIF P_OrderedWhen = 'Weekly' AND P_BilledWhen = 'Weekly' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'   AND P_BilledWhen = 'Monthly' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate); --

  ELSEIF P_OrderedWhen = 'Weekly'  AND P_BilledWhen = 'Monthly' THEN RETURN 4; --

  ELSEIF P_OrderedWhen = 'Monthly' AND P_BilledWhen = 'Monthly' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'   AND P_BilledWhen = 'Calendar Monthly' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate); --

  ELSEIF P_OrderedWhen = 'Weekly'  AND P_BilledWhen = 'Calendar Monthly' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate) / 7.0; --

  ELSEIF P_OrderedWhen = 'Monthly' AND P_BilledWhen = 'Calendar Monthly' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'     AND P_BilledWhen = 'Quarterly' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate); --

  ELSEIF P_OrderedWhen = 'Weekly'    AND P_BilledWhen = 'Quarterly' THEN RETURN 13; --

  ELSEIF P_OrderedWhen = 'Monthly'   AND P_BilledWhen = 'Quarterly' THEN RETURN 3; --

  ELSEIF P_OrderedWhen = 'Quarterly' AND P_BilledWhen = 'Quarterly' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'         AND P_BilledWhen = 'Semi-Annually' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate); --

  ELSEIF P_OrderedWhen = 'Weekly'        AND P_BilledWhen = 'Semi-Annually' THEN RETURN 26; --

  ELSEIF P_OrderedWhen = 'Monthly'       AND P_BilledWhen = 'Semi-Annually' THEN RETURN 6; --

  ELSEIF P_OrderedWhen = 'Quarterly'     AND P_BilledWhen = 'Semi-Annually' THEN RETURN 2; --

  ELSEIF P_OrderedWhen = 'Semi-Annually' AND P_BilledWhen = 'Semi-Annually' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'         AND P_BilledWhen = 'Annually' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate); --

  ELSEIF P_OrderedWhen = 'Weekly'        AND P_BilledWhen = 'Annually' THEN RETURN 52; --

  ELSEIF P_OrderedWhen = 'Monthly'       AND P_BilledWhen = 'Annually' THEN RETURN 12; --

  ELSEIF P_OrderedWhen = 'Quarterly'     AND P_BilledWhen = 'Annually' THEN RETURN 4; --

  ELSEIF P_OrderedWhen = 'Semi-Annually' AND P_BilledWhen = 'Annually' THEN RETURN 2; --

  ELSEIF P_OrderedWhen = 'Annually'      AND P_BilledWhen = 'Annually' THEN RETURN 1; --



  ELSEIF P_OrderedWhen = 'Daily'  AND P_BilledWhen = 'Custom' THEN RETURN DATEDIFF(GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen), P_FromDate); --



  END IF; --



  RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetNewDosTo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNewDosTo`(P_NewFromDate DATETIME, P_OldFromDate DATETIME, P_OldToDate DATETIME, P_Frequency VARCHAR(50)) RETURNS datetime
    DETERMINISTIC
BEGIN

  DECLARE V_LENGTH INT; --



  IF     P_Frequency = 'One time'         THEN RETURN P_NewFromDate; --

  ELSEIF P_Frequency = 'Daily'            THEN RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL 01 DAY  ), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Weekly'           THEN RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL 07 DAY  ), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Monthly'          THEN RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL 01 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Calendar Monthly' THEN

    SET P_NewFromDate = DATE_ADD(P_NewFromDate, INTERVAL 01 MONTH); --

    RETURN DATE_ADD(P_NewFromDate, INTERVAL 0-DAY(P_NewFromDate) DAY); -- end of month

  ELSEIF P_Frequency = 'Quarterly'        THEN RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL 03 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Semi-Annually'    THEN RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL 06 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Annually'         THEN RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL 12 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Custom'           THEN

    SET V_LENGTH = DATEDIFF(P_OldToDate, P_OldFromDate) + 1; --

    RETURN DATE_ADD(DATE_ADD(P_NewFromDate, INTERVAL V_LENGTH DAY), INTERVAL -1 DAY); --

  END IF; --



  RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetNextDosFrom` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextDosFrom`(P_FromDate DATETIME, P_ToDate DATETIME, P_Frequency VARCHAR(50)) RETURNS datetime
    DETERMINISTIC
BEGIN

  IF     P_Frequency = 'One time'         THEN RETURN P_FromDate; --

  ELSEIF P_Frequency = 'Daily'            THEN RETURN DATE_ADD(P_FromDate, INTERVAL 01 DAY); --

  ELSEIF P_Frequency = 'Weekly'           THEN RETURN DATE_ADD(P_FromDate, INTERVAL 07 DAY); --

  ELSEIF P_Frequency = 'Monthly'          THEN RETURN DATE_ADD(P_FromDate, INTERVAL 01 MONTH); --

  ELSEIF P_Frequency = 'Calendar Monthly' THEN

    SET P_FromDate = DATE_ADD(P_FromDate, INTERVAL 1 MONTH); --

    RETURN DATE_ADD(P_FromDate, INTERVAL 1-DAY(P_FromDate) DAY); --

  ELSEIF P_Frequency = 'Quarterly'        THEN RETURN DATE_ADD(P_FromDate, INTERVAL 03 MONTH); --

  ELSEIF P_Frequency = 'Semi-Annually'    THEN RETURN DATE_ADD(P_FromDate, INTERVAL 06 MONTH); --

  ELSEIF P_Frequency = 'Annually'         THEN RETURN DATE_ADD(P_FromDate, INTERVAL 12 MONTH); --

  ELSEIF P_Frequency = 'Custom'           THEN RETURN DATE_ADD(P_ToDate  , INTERVAL 01 DAY); --

  END IF; --



  RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetNextDosTo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextDosTo`(P_FromDate DATETIME, P_ToDate DATETIME, P_Frequency VARCHAR(50)) RETURNS datetime
    DETERMINISTIC
BEGIN

  DECLARE V_LENGTH INT; --



  IF     P_Frequency = 'One time'         THEN RETURN P_FromDate; --

  ELSEIF P_Frequency = 'Daily'            THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * 01 DAY  ), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Weekly'           THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * 07 DAY  ), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Monthly'          THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * 01 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Calendar Monthly' THEN

    SET P_FromDate = DATE_ADD(P_FromDate, INTERVAL 02 MONTH); --

    RETURN DATE_ADD(P_FromDate, INTERVAL 0-DAY(P_FromDate) DAY); --

  ELSEIF P_Frequency = 'Quarterly'        THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * 03 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Semi-Annually'    THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * 06 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Annually'         THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * 12 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Custom'           THEN

    SET V_LENGTH = DATEDIFF(P_ToDate, P_FromDate) + 1; --

    RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 2 * V_LENGTH DAY), INTERVAL -1 DAY); --

  END IF; --



  RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetPeriodEnd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetPeriodEnd`(P_FromDate DATETIME, P_ToDate DATETIME, P_Frequency VARCHAR(50)) RETURNS datetime
    DETERMINISTIC
BEGIN

  IF     P_Frequency = 'One time'         THEN RETURN P_FromDate; --

  ELSEIF P_Frequency = 'Daily'            THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 01 DAY  ), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Weekly'           THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 07 DAY  ), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Monthly'          THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 01 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Calendar Monthly' THEN

    SET P_FromDate = DATE_ADD(P_FromDate, INTERVAL 1 MONTH); --

    RETURN DATE_ADD(P_FromDate, INTERVAL 0-DAY(P_FromDate) DAY); --

  ELSEIF P_Frequency = 'Quarterly'        THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 03 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Semi-Annually'    THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 06 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Annually'         THEN RETURN DATE_ADD(DATE_ADD(P_FromDate, INTERVAL 12 MONTH), INTERVAL -1 DAY); --

  ELSEIF P_Frequency = 'Custom'           THEN RETURN P_ToDate; --

  END IF; --



  RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetPeriodEnd2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetPeriodEnd2`(P_FromDate DATETIME, P_ToDate DATETIME, P_PickupDate DATETIME, P_Frequency VARCHAR(50)) RETURNS datetime
    DETERMINISTIC
BEGIN

  DECLARE V_PeriodEnd DATETIME; --



  SET V_PeriodEnd = `GetPeriodEnd`(P_FromDate, P_ToDate, P_Frequency); --



  IF     P_PickupDate IS NULL        THEN RETURN V_PeriodEnd; --

  ELSEIF V_PeriodEnd <= P_PickupDate THEN RETURN V_PeriodEnd; --

  ELSEIF P_FromDate  <= P_PickupDate THEN RETURN P_PickupDate; --

  END IF; --



  RETURN P_FromDate; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetQuantityMultiplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetQuantityMultiplier`(

    P_FromDate DATETIME,

    P_ToDate DATETIME,

    P_PickupDate DATETIME,

    P_SaleRentType VARCHAR(50),

    P_OrderedWhen VARCHAR(50),

    P_BilledWhen VARCHAR(50)) RETURNS double
    DETERMINISTIC
BEGIN

    DECLARE V_NextToDate DATETIME; --



    IF     P_SaleRentType = 'One Time Sale'          THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Re-occurring Sale'      THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Rent to Purchase'       THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Capped Rental'          THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Parental Capped Rental' THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Medicare Oxygen Rental' THEN RETURN 1; --

    ELSEIF P_SaleRentType = 'Monthly Rental'         THEN

        IF (P_OrderedWhen = 'Daily') THEN

            SET V_NextToDate = GetNextDosFrom(P_FromDate, P_ToDate, P_BilledWhen); --

            IF P_PickupDate IS NULL THEN

                RETURN DATEDIFF(V_NextToDate, P_FromDate); --

            ELSEIF V_NextToDate <= P_PickupDate THEN

                RETURN DATEDIFF(V_NextToDate, P_FromDate); --

            ELSEIF P_FromDate <= P_PickupDate THEN

                RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1); --

            ELSE -- P_PickupDate < P_FromDate

                RETURN 0; --

            END IF; --

        ELSE

            RETURN 1; --

        END IF; --

    ELSEIF P_SaleRentType = 'One Time Rental'        THEN RETURN (DATEDIFF(P_PickupDate, P_FromDate) + 1); --

    END IF; --



    RETURN NULL; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `InvoiceMustBeSkipped` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `InvoiceMustBeSkipped`(

  P_DeliveryDate DATETIME, P_DosFrom DATETIME, P_SaleRentType VARCHAR(50), P_BillingMonth INT,

  P_Modifier1 VARCHAR(8), P_Modifier2 VARCHAR(8), P_Modifier3 VARCHAR(8), P_Modifier4 VARCHAR(8)) RETURNS bit(1)
    DETERMINISTIC
BEGIN

  -- means that we should not generate invoice

  -- 'Capped rental' with delivery date after 2006-01-01 will be treated like 'Rent to Purchase'

  IF P_BillingMonth <= 0 THEN

    SET P_BillingMonth = 1; --

  END IF; --



  IF P_SaleRentType IN ('One Time Sale', 'Re-occurring Sale', 'One Time Rental') THEN

    RETURN (1 < P_BillingMonth); --

  ELSEIF P_SaleRentType = 'Medicare Oxygen Rental' THEN

    IF P_DeliveryDate < '2006-01-01' THEN

      RETURN ('2009-01-01' <= P_DosFrom) AND (36 < P_BillingMonth); --

    ELSE

      RETURN (36 < P_BillingMonth); --

    END IF; --

  ELSEIF P_SaleRentType = 'Monthly Rental' THEN

    RETURN 0; --

  ELSEIF P_SaleRentType = 'Rent to Purchase' THEN

    RETURN (10 < P_BillingMonth); --

  ELSEIF P_SaleRentType = 'Capped Rental' OR P_SaleRentType = 'Parental Capped Rental' THEN

    IF P_DeliveryDate < '2006-01-01' THEN

      IF (P_BillingMonth <= 15) THEN

        RETURN 0; --

      ELSEIF (P_BillingMonth < 22) THEN

        RETURN 1; --

      ELSE

        RETURN ((P_BillingMonth - 22) mod 6 != 0); --

      END IF; --

    ELSE

      RETURN (13 < P_BillingMonth); --

    END IF; --

  END IF; --



  RETURN 0; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `OrderedQty2BilledQty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `OrderedQty2BilledQty`(

    P_FromDate DATE,

    P_ToDate DATE,

    P_OrderedQty DOUBLE,

    P_OrderedWhen VARCHAR(50),

    P_BilledWhen VARCHAR(50),

    P_OrderedConverter DOUBLE,

    P_DeliveryConverter DOUBLE,

    P_BilledConverter DOUBLE) RETURNS double
    DETERMINISTIC
BEGIN

  DECLARE V_Multiplier INT; --



  IF P_OrderedConverter < 0.000000001 THEN

    RETURN 0; /* Parameter OrderedConverter must be greater tha zero */

  END IF; --



  IF P_DeliveryConverter < 0.000000001 THEN

    RETURN 0; /* Paramater DeliveryConverter must be greater tha zero */

  END IF; --



  IF P_BilledConverter < 0.000000001 THEN

    RETURN 0; /* Parameter BilledConverter must be greater tha zero */

  END IF; --



  SET V_Multiplier = GetMultiplier(P_FromDate, P_ToDate, P_OrderedWhen, P_BilledWhen); --



  RETURN CEILING(P_OrderedQty * V_Multiplier * P_OrderedConverter / P_DeliveryConverter) * P_DeliveryConverter / P_BilledConverter; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `OrderedQty2DeliveryQty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `OrderedQty2DeliveryQty`(

    P_FromDate DATE,

    P_ToDate DATE,

    P_OrderedQty DOUBLE,

    P_OrderedWhen VARCHAR(50),

    P_BilledWhen VARCHAR(50),

    P_OrderedConverter DOUBLE,

    P_DeliveryConverter DOUBLE,

    P_BilledConverter DOUBLE /* Unused parameter */) RETURNS double
    DETERMINISTIC
BEGIN

  DECLARE V_Multiplier INT; --



  IF P_OrderedConverter < 0.000000001 THEN

    RETURN 0; /* Parameter OrderedConverter must be greater than zero */

  END IF; --



  IF P_DeliveryConverter < 0.000000001 THEN

    RETURN 0; /* Paramater DeliveryConverter must be greater than zero */

  END IF; --



  SET V_Multiplier = GetMultiplier(P_FromDate, P_ToDate, P_OrderedWhen, P_BilledWhen); --



  RETURN CEILING(P_OrderedQty * V_Multiplier * P_OrderedConverter / P_DeliveryConverter); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `OrderMustBeClosed` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `OrderMustBeClosed`(

  P_DeliveryDate DATETIME, P_DosFrom DATETIME, P_SaleRentType VARCHAR(50), P_BillingMonth INT,

  P_Modifier1 VARCHAR(8), P_Modifier2 VARCHAR(8), P_Modifier3 VARCHAR(8), P_Modifier4 VARCHAR(8)) RETURNS bit(1)
    DETERMINISTIC
BEGIN

  -- means that we should stop billing (that is we should set EndDate = InvoiceDate and State = 'Closed')

  IF P_BillingMonth <= 0 THEN

    SET P_BillingMonth = 1; --

  END IF; --



  IF P_SaleRentType IN ('One Time Sale', 'Re-occurring Sale', 'One Time Rental') THEN

    RETURN (1 <= P_BillingMonth); --

  ELSEIF P_SaleRentType = 'Medicare Oxygent Rental' THEN

    IF P_DeliveryDate < '2006-01-01' THEN

      RETURN ('2009-01-01' <= P_DosFrom) AND (36 <= P_BillingMonth); --

    ELSE

      -- we bill only 36 monthes but contract is 60 monthes

      RETURN (60 <= P_BillingMonth); --

    END IF; --

  ELSEIF P_SaleRentType = 'Monthly Rental' THEN

    RETURN 0; --

  ELSEIF P_SaleRentType = 'Rent to Purchase' THEN

    RETURN (10 <= P_BillingMonth); --

  ELSEIF P_SaleRentType = 'Capped Rental' OR P_SaleRentType = 'Parental Capped Rental' THEN

    IF P_DeliveryDate < '2006-01-01' THEN

      RETURN (12 <= P_BillingMonth) and (P_BillingMonth <= 13) and (P_Modifier3 = 'BP'); --

    ELSE

      RETURN (13 <= P_BillingMonth); --

    END IF; --

  END IF; --



  RETURN 0; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `OrderMustBeSkipped` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `OrderMustBeSkipped`(

  P_DeliveryDate DATETIME, P_DosFrom DATETIME, P_SaleRentType VARCHAR(50), P_BillingMonth INT,

  P_Modifier1 VARCHAR(8), P_Modifier2 VARCHAR(8),

  P_Modifier3 VARCHAR(8), P_Modifier4 VARCHAR(8)) RETURNS bit(1)
    DETERMINISTIC
BEGIN

  -- means that we should not process order

  IF P_BillingMonth <= 0 THEN

    SET P_BillingMonth = 1; --

  END IF; --



  IF P_SaleRentType IN ('One Time Sale', 'Re-occurring Sale', 'One Time Rental') THEN

    RETURN (1 < P_BillingMonth); --

  ELSEIF P_SaleRentType = 'Medicare Oxygen Rental' THEN

    IF P_DeliveryDate < '2006-01-01' THEN

      RETURN ('2009-01-01' <= P_DosFrom) AND (36 < P_BillingMonth); --

    ELSE

      -- we bill only 36 monthes but contract is 60 monthes

      RETURN (60 < P_BillingMonth); --

    END IF; --

  ELSEIF P_SaleRentType = 'Monthly Rental' THEN

    RETURN 0; --

  ELSEIF P_SaleRentType = 'Rent to Purchase' THEN

    RETURN (10 < P_BillingMonth); --

  ELSEIF P_SaleRentType = 'Capped Rental' OR P_SaleRentType = 'Parental Capped Rental' THEN

    IF P_DeliveryDate < '2006-01-01' THEN

      IF (12 <= P_BillingMonth) AND (P_BillingMonth <= 15) THEN

        RETURN (P_Modifier3 NOT IN ('BP', 'BR', 'BU')); --

      ELSE

        RETURN 0; --

      END IF; --

    ELSE

      RETURN (13 < P_BillingMonth); --

    END IF; --

  END IF; --



  RETURN 0; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `customer_insurance_fixrank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_insurance_fixrank`(P_CustomerID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE V_ID, V_Rank INT; --

  DECLARE cur CURSOR FOR

    SELECT ID

    FROM tbl_customer_insurance

    WHERE (CustomerID = P_CustomerID)

    ORDER BY IF(InactiveDate <= Current_Date(), 1, 0), `Rank`, ID; --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  SET V_Rank = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO V_ID; --



    IF NOT done THEN

      UPDATE tbl_customer_insurance SET `Rank` = IF(InactiveDate <= Current_Date(), 99999, V_Rank) WHERE (ID = V_ID) AND (CustomerID = P_CustomerID); --

      SET V_Rank = V_Rank + 1; --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fixInvoicePolicies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fixInvoicePolicies`()
BEGIN

  UPDATE tbl_invoice

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_invoice.CustomerInsurance1_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_invoice.CustomerID

  SET tbl_invoice.CustomerInsurance1_ID = tbl_customer_insurance.ID; --



  UPDATE tbl_invoice

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_invoice.CustomerInsurance2_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_invoice.CustomerID

  SET tbl_invoice.CustomerInsurance2_ID = tbl_customer_insurance.ID; --



  UPDATE tbl_invoice

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_invoice.CustomerInsurance3_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_invoice.CustomerID

  SET tbl_invoice.CustomerInsurance3_ID = tbl_customer_insurance.ID; --



  UPDATE tbl_invoice

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_invoice.CustomerInsurance4_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_invoice.CustomerID

  SET tbl_invoice.CustomerInsurance4_ID = tbl_customer_insurance.ID; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fixOrderPolicies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fixOrderPolicies`()
BEGIN

  UPDATE tbl_order

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_order.CustomerInsurance1_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_order.CustomerID

  SET tbl_order.CustomerInsurance1_ID = tbl_customer_insurance.ID; --



  UPDATE tbl_order

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_order.CustomerInsurance2_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_order.CustomerID

  SET tbl_order.CustomerInsurance2_ID = tbl_customer_insurance.ID; --



  UPDATE tbl_order

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_order.CustomerInsurance3_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_order.CustomerID

  SET tbl_order.CustomerInsurance3_ID = tbl_customer_insurance.ID; --



  UPDATE tbl_order

        INNER JOIN tbl_customer_insurance ON tbl_customer_insurance.InsuranceCompanyID = tbl_order.CustomerInsurance4_ID

                                          AND tbl_customer_insurance.CustomerID = tbl_order.CustomerID

  SET tbl_order.CustomerInsurance4_ID = tbl_customer_insurance.ID; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fix_serial_transactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fix_serial_transactions`(P_SerialID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --



  -- cursor variables

  DECLARE cur_Priority         int(11); --

  DECLARE cur_CustomerID       int(11); --

  DECLARE cur_OrderID          int(11); --

  DECLARE cur_OrderDetailsID   int(11); --

  DECLARE cur_SerialID         int(11); --

  DECLARE cur_WarehouseID      int(11); --

  DECLARE cur_TranType         varchar(50); --

  DECLARE cur_TranTime         datetime; --



  DECLARE cur CURSOR FOR

  SELECT

    Priority

  , CustomerID

  , OrderID

  , OrderDetailsID

  , SerialID

  , WarehouseID

  , TranType

  , TranTime

  FROM `{E9A96545-F98D-4318-836E-A10EA2CD78B7}`

  ORDER BY DateReserved, OrderDetailsID, SerialId, Priority; --



  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  DROP TABLE IF EXISTS `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}`; --



  CREATE TEMPORARY TABLE `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` AS

  SELECT DISTINCT

    od.SerialID

  , od.CustomerID

  , od.OrderID

  , od.ID as OrderDetailsID

  , od.WarehouseID

  , o.DeliveryDate as DateReserved

  , trf.Time as DateTransferred

  , CASE WHEN (o.Approved = 1) AND (od.IsRented = 1)

         THEN o.DeliveryDate

         ELSE NULL END as DateRented

  , CASE WHEN (o.Approved = 1) AND (od.IsRented = 1) AND (od.IsActive = 0) AND (od.IsCanceled = 0) AND (od.IsPickedup = 0)

         THEN od.EndDate

         ELSE NULL END as DateRentSold

  , CASE WHEN (o.Approved = 1) AND (od.IsRented = 1) AND (od.IsActive = 0) AND (od.IsCanceled = 0) AND (od.IsPickedup = 1)

         THEN od.EndDate

         ELSE NULL END as DatePickedup

  , CASE WHEN (o.Approved = 1) AND (od.IsSold = 1)

         THEN o.DeliveryDate

         ELSE NULL END as DateSold

  FROM tbl_order AS o

       INNER JOIN view_orderdetails AS od ON od.CustomerID = o.CustomerID

                                         AND od.OrderID    = o.ID

       INNER JOIN tbl_serial AS s ON od.SerialID        = s.ID -- serial exists

                                 AND od.InventoryItemID = s.InventoryItemID

       LEFT JOIN (SELECT st.SerialID, st.WarehouseID, MIN(TransactionDatetime) as Time

                  FROM tbl_serial_transaction as st

                       INNER JOIN tbl_serial_transaction_type as stt ON stt.ID = st.TypeID

                  WHERE stt.Name = 'Transferred In'

                  GROUP BY st.SerialID, st.WarehouseID) as trf ON trf.SerialID    = od.SerialID

                                                              AND trf.WarehouseID = od.WarehouseID

  WHERE (o.DeliveryDate IS NOT NULL)

    AND (P_SerialID IS NULL OR s.ID = P_SerialID)

  ORDER BY od.SerialID, o.DeliveryDate, od.ID; --



  ALTER TABLE `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` ADD COLUMN Number INT NOT NULL AUTO_INCREMENT PRIMARY KEY; --

  ALTER TABLE `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` ADD COLUMN IsFirst BOOL NOT NULL DEFAULT 0; --



  DROP TABLE IF EXISTS `{F591E13A-9C30-445B-A812-BDE8F9A4566F}`; --



  CREATE TEMPORARY TABLE `{F591E13A-9C30-445B-A812-BDE8F9A4566F}` AS

  SELECT SerialID, Min(Number) as Number

  FROM `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}`

  GROUP BY SerialID; --



  UPDATE `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` AS a

         INNER JOIN `{F591E13A-9C30-445B-A812-BDE8F9A4566F}` AS b ON a.SerialID = b.SerialID

  SET a.IsFirst = CASE WHEN a.Number = b.Number THEN 1 ELSE 0 END; --



  DROP TABLE IF EXISTS `{F591E13A-9C30-445B-A812-BDE8F9A4566F}`; --



  -- delete bad entries



  DROP TABLE IF EXISTS `{B3F09F5E-8C0F-41BD-B652-25386EAAEAC4}`; --



  CREATE TEMPORARY TABLE `{B3F09F5E-8C0F-41BD-B652-25386EAAEAC4}` AS

  SELECT SerialID

  FROM `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}`

  GROUP BY SerialID

  HAVING 2 <= SUM(CASE WHEN DateRentSold IS NULL AND DatePickedup IS NULL THEN 1 ELSE 0 END); --



  -- OUTPUT bad entries for investigations



  SELECT SerialID

  FROM `{B3F09F5E-8C0F-41BD-B652-25386EAAEAC4}`; --



  DELETE FROM `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}`

  WHERE SerialID IN (SELECT SerialID FROM `{B3F09F5E-8C0F-41BD-B652-25386EAAEAC4}`); --



  DROP TABLE IF EXISTS `{B3F09F5E-8C0F-41BD-B652-25386EAAEAC4}`; --



  -- OUTPUT bad entries for investigations

  SELECT DISTINCT tmp.SerialID, stt.Name

  FROM `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` as tmp

       INNER JOIN tbl_serial_transaction as st ON st.SerialID = tmp.SerialID

       INNER JOIN tbl_serial_transaction_type as stt ON stt.ID = st.TypeID

  WHERE stt.Name NOT IN ('Reserved', 'Reserve Cancelled', 'Rented', 'Sold', 'Returned', 'In from Maintenance', 'Transferred In')

  ORDER BY tmp.SerialID, stt.Name; --



  DELETE tmp

  FROM `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` as tmp

       INNER JOIN tbl_serial_transaction as st ON st.SerialID = tmp.SerialID

       INNER JOIN tbl_serial_transaction_type as stt ON stt.ID = st.TypeID

  WHERE stt.Name NOT IN ('Reserved', 'Reserve Cancelled', 'Rented', 'Sold', 'Returned', 'In from Maintenance', 'Transferred In'); --



  DROP TABLE IF EXISTS `{E9A96545-F98D-4318-836E-A10EA2CD78B7}`; --



  CREATE TEMPORARY TABLE `{E9A96545-F98D-4318-836E-A10EA2CD78B7}` AS

  SELECT

    CASE WHEN s.IsFirst = 1              AND t.Name = 'Transferred In'      THEN 0

         WHEN s.IsFirst = 0              AND t.Name = 'In from Maintenance' THEN 0

         WHEN s.DateReserved IS NOT NULL AND t.Name = 'Reserved'            THEN 1

         WHEN s.DateSold     IS NOT NULL AND t.Name = 'Sold'                THEN 2

         WHEN s.DateRented   IS NOT NULL AND t.Name = 'Rented'              THEN 2

         WHEN s.DateRentSold IS NOT NULL AND t.Name = 'Sold'                THEN 3

         WHEN s.DatePickedup IS NOT NULL AND t.Name = 'Returned'            THEN 3

         END as Priority

  , s.DateReserved

  , s.CustomerID

  , s.OrderID

  , s.OrderDetailsID

  , s.SerialID

  , s.WarehouseID

  , t.Name as TranType

  , CASE WHEN s.IsFirst = 1              AND t.Name = 'Transferred In'      THEN IFNULL(s.DateTransferred, s.DateReserved)

         WHEN s.IsFirst = 0              AND t.Name = 'In from Maintenance' THEN s.DateReserved

         WHEN s.DateReserved IS NOT NULL AND t.Name = 'Reserved'            THEN s.DateReserved

         WHEN s.DateSold     IS NOT NULL AND t.Name = 'Sold'                THEN s.DateSold

         WHEN s.DateRented   IS NOT NULL AND t.Name = 'Rented'              THEN s.DateRented

         WHEN s.DateRentSold IS NOT NULL AND t.Name = 'Sold'                THEN s.DateRentSold

         WHEN s.DatePickedup IS NOT NULL AND t.Name = 'Returned'            THEN s.DatePickedup

         END as TranTime

  FROM ( SELECT Name

         FROM tbl_serial_transaction_type

         WHERE Name IN ('Reserved', 'Reserve Cancelled', 'Rented', 'Sold', 'Returned', 'In from Maintenance', 'Transferred In')

       ) as t

       INNER JOIN `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}` as s

               ON (s.IsFirst = 1              AND t.Name = 'Transferred In')

               OR (s.IsFirst = 0              AND t.Name = 'In from Maintenance')

               OR (s.DateReserved IS NOT NULL AND t.Name = 'Reserved')

               OR (s.DateSold     IS NOT NULL AND t.Name = 'Sold')

               OR (s.DateRented   IS NOT NULL AND t.Name = 'Rented')

               OR (s.DateRentSold IS NOT NULL AND t.Name = 'Sold')

               OR (s.DatePickedup IS NOT NULL AND t.Name = 'Returned')

  ORDER BY SerialId, DateReserved, OrderDetailsID, Priority; --



  DROP TABLE IF EXISTS `{B19B3C36-B432-4F3C-86F9-F4AF004EE8AF}`; --



  DELETE

  FROM tbl_serial_transaction

  WHERE SerialID IN (SELECT SerialID FROM `{E9A96545-F98D-4318-836E-A10EA2CD78B7}`); --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

     cur_Priority

    ,cur_CustomerID

    ,cur_OrderID

    ,cur_OrderDetailsID

    ,cur_SerialID

    ,cur_WarehouseID

    ,cur_TranType

    ,cur_TranTime; --



    IF (done = 0) THEN

      CALL serial_add_transaction(

          cur_TranType       -- P_TranType         VARCHAR(50)

        , cur_TranTime       -- P_TranTime         DATETIME

        , cur_SerialID       -- P_SerialID         INT,

        , cur_WarehouseID    -- P_WarehouseID      INT,

        , null               -- P_VendorID         INT,

        , cur_CustomerID     -- P_CustomerID       INT,

        , cur_OrderID        -- P_OrderID          INT,

        , cur_OrderDetailsID -- P_OrderDetailsID   INT,

        , null               -- P_LotNumber        VARCHAR(50),

        , 1                  -- P_LastUpdateUserID INT

      ); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --



  DROP TABLE IF EXISTS `{E9A96545-F98D-4318-836E-A10EA2CD78B7}`; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `internal_inventory_transfer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `internal_inventory_transfer`(

  P_InventoryItemID  INT

, P_SrcWarehouseID   INT

, P_DstWarehouseID   INT

, P_Quantity         INT

, P_Description      VARCHAR(30)

, P_LastUpdateUserID INT)
BEGIN

  DECLARE

    V_OnHand INT; --

  DECLARE

    V_CostPerUnit DECIMAL(18, 2); --



  IF (P_InventoryItemID IS NOT NULL)

  AND (P_SrcWarehouseID IS NOT NULL)

  AND (P_DstWarehouseID IS NOT NULL)

  AND (0 < IFNULL(P_Quantity, 0)) THEN

    CALL inventory_refresh(P_SrcWarehouseID, P_InventoryItemID); --



    SELECT

      IFNULL(OnHand     , 0) as OnHand

    , IFNULL(CostPerUnit, 0) as CostPerUnit

    INTO

      V_OnHand

    , V_CostPerUnit

    FROM tbl_inventory

    WHERE (InventoryItemID = P_InventoryItemID)

      AND (WarehouseID     = P_SrcWarehouseID); --



    IF (P_Quantity <= V_OnHand) THEN

      CALL inventory_transaction_add_adjustment(

        P_SrcWarehouseID,

        P_InventoryItemID,

        'Transferred Out',

        P_Description,

        P_Quantity,

        V_CostPerUnit,

        P_LastUpdateUserID); --



      CALL inventory_transaction_add_adjustment(

        P_DstWarehouseID,

        P_InventoryItemID,

        'Transferred In',

        P_Description,

        P_Quantity,

        V_CostPerUnit,

        P_LastUpdateUserID); --



      CALL inventory_refresh(P_SrcWarehouseID, P_InventoryItemID); --

      CALL inventory_refresh(P_DstWarehouseID, P_InventoryItemID); --

    END IF; --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InventoryItem_Clone` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InventoryItem_Clone`(P_OldInventoryItemID INT, P_NewName VARCHAR(100), OUT P_NewInventoryItemID INT)
BEGIN

  DECLARE V_RowCount INT; --



  INSERT INTO tbl_inventoryitem (

    Barcode

  , BarcodeType

  , Basis

  , CommissionPaidAt

  , VendorID

  , FlatRate

  , FlatRateAmount

  , Frequency

  , InventoryCode

  , ModelNumber

  , Name

  , O2Tank

  , Percentage

  , PercentageAmount

  , PredefinedTextID

  , ProductTypeID

  , Serialized

  , Service

  , LastUpdateUserID

  , LastUpdateDatetime

  , Inactive

  , ManufacturerID

  , PurchasePrice

  ) SELECT

    Barcode

  , BarcodeType

  , Basis

  , CommissionPaidAt

  , VendorID

  , FlatRate

  , FlatRateAmount

  , Frequency

  , InventoryCode

  , ModelNumber

  , IFNULL(P_NewName, Name) as Name

  , O2Tank

  , Percentage

  , PercentageAmount

  , PredefinedTextID

  , ProductTypeID

  , Serialized

  , Service

  , LastUpdateUserID

  , LastUpdateDatetime

  , Inactive

  , ManufacturerID

  , PurchasePrice

  FROM tbl_inventoryitem

  WHERE (ID = P_OldInventoryItemID); --



  SELECT ROW_COUNT(), LAST_INSERT_ID() INTO V_RowCount, P_NewInventoryItemID; --



  IF (V_RowCount = 0) THEN

    SET P_NewInventoryItemID = NULL; --

  ELSE

    INSERT INTO `tbl_pricecode_item` (

      AcceptAssignment

    , OrderedQuantity

    , OrderedUnits

    , OrderedWhen

    , OrderedConverter

    , BilledUnits

    , BilledWhen

    , BilledConverter

    , DeliveryUnits

    , DeliveryConverter

    , BillingCode

    , BillItemOn

    , DefaultCMNType

    , DefaultOrderType

    , AuthorizationTypeID

    , FlatRate

    , InventoryItemID

    , Modifier1

    , Modifier2

    , Modifier3

    , Modifier4

    , PriceCodeID

    , PredefinedTextID

    , Rent_AllowablePrice

    , Rent_BillablePrice

    , Sale_AllowablePrice

    , Sale_BillablePrice

    , RentalType

    , ReoccuringSale

    , ShowSpanDates

    , Taxable

    , LastUpdateUserID

    , LastUpdateDatetime

    , BillInsurance

    , DrugNoteField

    , DrugControlNumber

    ) SELECT

      AcceptAssignment

    , OrderedQuantity

    , OrderedUnits

    , OrderedWhen

    , OrderedConverter

    , BilledUnits

    , BilledWhen

    , BilledConverter

    , DeliveryUnits

    , DeliveryConverter

    , BillingCode

    , BillItemOn

    , DefaultCMNType

    , DefaultOrderType

    , AuthorizationTypeID

    , FlatRate

    , P_NewInventoryItemID as InventoryItemID

    , Modifier1

    , Modifier2

    , Modifier3

    , Modifier4

    , PriceCodeID

    , PredefinedTextID

    , Rent_AllowablePrice

    , Rent_BillablePrice

    , Sale_AllowablePrice

    , Sale_BillablePrice

    , RentalType

    , ReoccuringSale

    , ShowSpanDates

    , Taxable

    , LastUpdateUserID

    , LastUpdateDatetime

    , BillInsurance

    , DrugNoteField

    , DrugControlNumber

    FROM `tbl_pricecode_item`

    WHERE (InventoryItemID = P_OldInventoryItemID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_adjust_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_adjust_2`(

  P_WarehouseID INT

, P_InventoryItemID INT

, P_OnHand INT

, P_Rented INT

, P_Sold INT

, P_Unavailable INT

, P_Committed INT

, P_OnOrder INT

, P_BackOrdered INT

, P_ReOrderPoint INT

, P_CostPerUnit DECIMAL(18, 2)

, P_LastUpdateUserID INT)
BEGIN

  DECLARE

    V_DeltaOnHand

  , V_DeltaRented

  , V_DeltaSold

  , V_DeltaUnavailable

  , V_DeltaCommitted

  , V_DeltaOnOrder

  , V_DeltaBackOrdered INT; --

  DECLARE

    V_CostPerUnit DECIMAL(18, 2); --



  IF (P_WarehouseID IS NOT NULL) AND (P_InventoryItemID IS NOT NULL) THEN

    CALL inventory_refresh(P_WarehouseID, P_InventoryItemID); --



    /* in case when this entry does not have any transactions */

    SET V_DeltaOnHand        = IF(0 <= IFNULL(P_OnHand     , -1), P_OnHand      - 0, NULL); --

    SET V_DeltaRented        = IF(0 <= IFNULL(P_Rented     , -1), P_Rented      - 0, NULL); --

    SET V_DeltaSold          = IF(0 <= IFNULL(P_Sold       , -1), P_Sold        - 0, NULL); --

    SET V_DeltaUnavailable   = IF(0 <= IFNULL(P_Unavailable, -1), P_Unavailable - 0, NULL); --

    SET V_DeltaCommitted     = IF(0 <= IFNULL(P_Committed  , -1), P_Committed   - 0, NULL); --

    SET V_DeltaOnOrder       = IF(0 <= IFNULL(P_OnOrder    , -1), P_OnOrder     - 0, NULL); --

    SET V_DeltaBackOrdered   = IF(0 <= IFNULL(P_BackOrdered, -1), P_BackOrdered - 0, NULL); --

    SET V_CostPerUnit        = P_CostPerUnit; --



    SELECT

      IF(0 <= IFNULL(P_OnHand     , -1), P_OnHand      - IFNULL(OnHand     , 0), NULL) as DeltaOnHand

    , IF(0 <= IFNULL(P_Rented     , -1), P_Rented      - IFNULL(Rented     , 0), NULL) as DeltaRented

    , IF(0 <= IFNULL(P_Sold       , -1), P_Sold        - IFNULL(Sold       , 0), NULL) as DeltaSold

    , IF(0 <= IFNULL(P_Unavailable, -1), P_Unavailable - IFNULL(Unavailable, 0), NULL) as DeltaUnavailable

    , IF(0 <= IFNULL(P_Committed  , -1), P_Committed   - IFNULL(Committed  , 0), NULL) as DeltaCommitted

    , IF(0 <= IFNULL(P_OnOrder    , -1), P_OnOrder     - IFNULL(OnOrder    , 0), NULL) as DeltaOnOrder

    , IF(0 <= IFNULL(P_BackOrdered, -1), P_BackOrdered - IFNULL(BackOrdered, 0), NULL) as DeltaBackOrdered

    , CostPerUnit

    INTO

      V_DeltaOnHand

    , V_DeltaRented

    , V_DeltaSold

    , V_DeltaUnavailable

    , V_DeltaCommitted

    , V_DeltaOnOrder

    , V_DeltaBackOrdered

    , V_CostPerUnit

    FROM tbl_inventory

    WHERE (WarehouseID     = P_WarehouseID)

      AND (InventoryItemID = P_InventoryItemID); --



    SET V_CostPerUnit = IFNULL(P_CostPerUnit, IFNULL(V_CostPerUnit, 0)); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'OnHand Adjustment',

      'Manual Adjustment',

      IFNULL(V_DeltaOnHand, 0) + IFNULL(V_DeltaCommitted, 0) + IF(V_DeltaOnOrder < 0, V_DeltaOnOrder, 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Rented Adjustment',

      'Manual Adjustment',

      V_DeltaRented,

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Sold Adjustment',

      'Manual Adjustment',

      V_DeltaSold,

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Unavailable Adj',

      'Manual Adjustment',

      0 - V_DeltaUnavailable,

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Committed',

      'Manual Adjustment',

      IF(0 < V_DeltaCommitted, ABS(V_DeltaCommitted), 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Commit Cancelled',

      'Manual Adjustment',

      IF(V_DeltaCommitted < 0, ABS(V_DeltaCommitted), 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Ordered',

      'Manual Adjustment',

      IF(0 < V_DeltaOnOrder, ABS(V_DeltaOnOrder), 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Received',

      'Manual Adjustment',

      IF(V_DeltaOnOrder < 0, ABS(V_DeltaOnOrder), 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'BackOrdered',

      'Manual Adjustment',

      IF(0 < V_DeltaBackOrdered, ABS(V_DeltaBackOrdered), 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    CALL inventory_transaction_add_adjustment(

      P_WarehouseID,

      P_InventoryItemID,

      'Fill Back Order',

      'Manual Adjustment',

      IF(V_DeltaBackOrdered < 0, ABS(V_DeltaBackOrdered), 0),

      V_CostPerUnit,

      P_LastUpdateUserID); --



    IF (0 < IFNULL(P_CostPerUnit, -1)) THEN

      CALL inventory_transaction_add_adjustment(

        P_WarehouseID,

        P_InventoryItemID,

        'CostPerUnit Adj',

        'Manual Adjustment',

        1, -- to satisfy quantity check

        P_CostPerUnit,

        P_LastUpdateUserID); --

    END IF; --



    IF (0 <= IFNULL(P_ReOrderPoint, -1)) THEN

      UPDATE tbl_inventory

      SET ReOrderPoint = P_ReOrderPoint

      WHERE (WarehouseID     = P_WarehouseID)

        AND (InventoryItemID = P_InventoryItemID); --

    END IF; --



    CALL inventory_refresh(P_WarehouseID, P_InventoryItemID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_order_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_order_refresh`(P_OrderID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE V_WarehouseID, V_InventoryItemID INT; --

  DECLARE cur CURSOR FOR SELECT WarehouseID, InventoryItemID FROM tbl_orderdetails WHERE (OrderID = P_OrderID); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO V_WarehouseID, V_InventoryItemID; --



    IF NOT done THEN

      CALL inventory_refresh(V_WarehouseID, V_InventoryItemID); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_po_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_po_refresh`(P_PurchaseOrderID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE V_WarehouseID, V_InventoryItemID INT; --

  DECLARE cur CURSOR FOR SELECT WarehouseID, InventoryItemID FROM tbl_purchaseorderdetails WHERE (PurchaseOrderID = P_PurchaseOrderID); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO V_WarehouseID, V_InventoryItemID; --



    IF NOT done THEN

      CALL inventory_refresh(V_WarehouseID, V_InventoryItemID); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_refresh`(P_WarehouseID INT, P_InventoryItemID INT)
BEGIN

  DECLARE

    V_WarehouseID,

    V_InventoryItemID INT; --

  DECLARE

    V_OnHand,

    V_Committed,

    V_OnOrder,

    V_UnAvailable,

    V_Rented,

    V_Sold,

    V_BackOrdered INT; --

  DECLARE

    V_UnitPrice DECIMAL(18, 2); --



  DECLARE done INT DEFAULT 0; --

  DECLARE cur CURSOR FOR

      SELECT

        summary.WarehouseID

      , summary.InventoryItemID

      , IF(item.Service = 0, IFNULL(summary.OnHand      , 0), 0) as OnHand

      , IF(item.Service = 0, IFNULL(summary.Committed   , 0), 0) as Committed

      , IF(item.Service = 0, IFNULL(summary.OnOrder     , 0), 0) as OnOrder

      , IF(item.Service = 0, IFNULL(summary.UnAvailable , 0), 0) as UnAvailable

      , IF(item.Service = 0, IFNULL(summary.Rented      , 0), 0) as Rented

      , IF(item.Service = 0, IFNULL(summary.Sold        , 0), 0) as Sold

      , IF(item.Service = 0, IFNULL(summary.BackOrdered , 0), 0) as BackOrdered

      , IF(item.Service = 0, IFNULL(tran.Cost / tran.Quantity, IFNULL(summary.TotalCost / summary.TotalQuantity, 0)), 0) as UnitPrice

      FROM (SELECT

              tran.WarehouseID

            , tran.InventoryItemID

            , SUM(CASE WHEN tran_type.OnHand       > 0 THEN tran.Quantity WHEN tran_type.OnHand       < 0 THEN -tran.Quantity ELSE null END) as OnHand

            , SUM(CASE WHEN tran_type.Committed    > 0 THEN tran.Quantity WHEN tran_type.Committed    < 0 THEN -tran.Quantity ELSE null END) as Committed

            , SUM(CASE WHEN tran_type.OnOrder      > 0 THEN tran.Quantity WHEN tran_type.OnOrder      < 0 THEN -tran.Quantity ELSE null END) as OnOrder

            , SUM(CASE WHEN tran_type.UnAvailable  > 0 THEN tran.Quantity WHEN tran_type.UnAvailable  < 0 THEN -tran.Quantity ELSE null END) as UnAvailable

            , SUM(CASE WHEN tran_type.Rented       > 0 THEN tran.Quantity WHEN tran_type.Rented       < 0 THEN -tran.Quantity ELSE null END) as Rented

            , SUM(CASE WHEN tran_type.Sold         > 0 THEN tran.Quantity WHEN tran_type.Sold         < 0 THEN -tran.Quantity ELSE null END) as Sold

            , SUM(CASE WHEN tran_type.BackOrdered  > 0 THEN tran.Quantity WHEN tran_type.BackOrdered  < 0 THEN -tran.Quantity ELSE null END) as BackOrdered

            , SUM(IF(tran_type.AdjTotalCost = 1, tran.Cost    , null)) as TotalCost

            , SUM(IF(tran_type.AdjTotalCost = 1, tran.Quantity, null)) as TotalQuantity

            , MAX(IF(tran_type.Name = 'CostPerUnit Adj', tran.ID, null)) as LastAdjustID

            FROM tbl_inventory_transaction as tran

                 INNER JOIN tbl_inventory_transaction_type as tran_type ON tran.TypeID = tran_type.ID

            WHERE ((P_WarehouseID     IS NULL) OR (tran.WarehouseID     = P_WarehouseID    ))

              AND ((P_InventoryItemID IS NULL) OR (tran.InventoryItemID = P_InventoryItemID))

            GROUP BY tran.WarehouseID, tran.InventoryItemID) as summary

      LEFT JOIN tbl_inventory_transaction as tran ON tran.ID              = summary.LastAdjustID

                                                 AND tran.WarehouseID     = summary.WarehouseID

                                                 AND tran.InventoryItemID = summary.InventoryItemID

      INNER JOIN tbl_inventoryitem as item ON item.ID = summary.InventoryItemID

      WHERE (1 = 1); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

      V_WarehouseID

    , V_InventoryItemID

    , V_OnHand

    , V_Committed

    , V_OnOrder

    , V_UnAvailable

    , V_Rented

    , V_Sold

    , V_BackOrdered

    , V_UnitPrice; --



    IF NOT done THEN

      UPDATE tbl_inventory SET

       OnHand           = V_OnHand

      ,Committed        = V_Committed

      ,OnOrder          = V_OnOrder

      ,UnAvailable      = V_UnAvailable

      ,Rented           = V_Rented

      ,Sold             = V_Sold

      ,BackOrdered      = V_BackOrdered

      ,CostPerUnit      = V_UnitPrice

      ,TotalCost        = V_UnitPrice * (V_OnHand + V_Rented + V_UnAvailable)

      ,LastUpdateUserID = 1

      WHERE (WarehouseID     = V_WarehouseID)

        AND (InventoryItemID = V_InventoryItemID); --



      IF (ROW_COUNT() = 0) THEN

        INSERT IGNORE INTO tbl_inventory SET

         OnHand           = V_OnHand

        ,Committed        = V_Committed

        ,OnOrder          = V_OnOrder

        ,UnAvailable      = V_UnAvailable

        ,Rented           = V_Rented

        ,Sold             = V_Sold

        ,BackOrdered      = V_BackOrdered

        ,CostPerUnit      = V_UnitPrice

        ,TotalCost        = V_UnitPrice * (V_OnHand + V_Rented + V_UnAvailable)

        ,LastUpdateUserID = 1

        ,ReOrderPoint     = 0

        ,WarehouseID      = V_WarehouseID

        ,InventoryItemID  = V_InventoryItemID; --

      END IF; --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_transaction_add_adjustment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_transaction_add_adjustment`(

  P_WarehouseID INT,

  P_InventoryItemID INT,

  P_Type VARCHAR(50),

  P_Description VARCHAR(30),

  P_Quantity INT,

  P_CostPerUnit DECIMAL(18, 2),

  P_LastUpdateUserID INT)
BEGIN

  DECLARE V_TranTypeID INT; --



  IF (P_WarehouseID IS NOT NULL) AND (P_InventoryItemID IS NOT NULL) AND (IFNULL(P_Quantity, 0) != 0) THEN

    SELECT ID

    INTO V_TranTypeID

    FROM tbl_inventory_transaction_type

    WHERE (Name = P_Type); --



    IF (V_TranTypeID IS NOT NULL) THEN

      INSERT INTO tbl_inventory_transaction SET

       WarehouseID            = P_WarehouseID

      ,InventoryItemID        = P_InventoryItemID

      ,TypeID                 = V_TranTypeID

      ,Date                   = Now()

      ,Quantity               = P_Quantity

      ,Cost                   = P_Quantity * P_CostPerUnit

      ,Description            = IFNULL(P_Description, 'No Description')

      ,SerialID               = NULL

      ,VendorID               = NULL

      ,CustomerID             = NULL

      ,LastUpdateUserID       = P_LastUpdateUserID

      ,LastUpdateDatetime     = Now()

      ,PurchaseOrderID        = NULL

      ,PurchaseOrderDetailsID = NULL

      ,InvoiceID              = NULL

      ,ManufacturerID         = NULL

      ,OrderID                = NULL

      ,OrderDetailsID         = NULL; --

    END IF; --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_transaction_order_cleanup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_transaction_order_cleanup`()
BEGIN

  -- delete transactions if corresponding orders or line items do not exist

  DELETE tran

  FROM tbl_inventory_transaction as tran

       LEFT JOIN view_orderdetails as d ON tran.InventoryItemID = d.InventoryItemID

                                       AND tran.WarehouseID     = d.WarehouseID

                                       AND tran.CustomerID      = d.CustomerID

                                       AND tran.OrderID         = d.OrderID

                                       AND tran.OrderDetailsID  = d.ID

       LEFT JOIN tbl_order as o ON d.OrderID    = o.ID

                               AND d.CustomerID = o.CustomerID

  WHERE (tran.OrderID IS NOT NULL)

    AND (o.ID IS NULL); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_transaction_order_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_transaction_order_refresh`(P_OrderID INT)
BEGIN

  -- type:

  -- Committed

  -- Sold

  -- Rented

  -- Rental Returned

  -- since user with necessary permissions have ability to set Approved = False

  -- we need to delete all transactions for not approved order

  -- and check all warehouses for it.



  -- if something was severily changed we need to delete

  DELETE tran

  FROM tbl_inventory_transaction as tran

       LEFT JOIN view_orderdetails as d ON tran.InventoryItemID = d.InventoryItemID

                                       AND tran.WarehouseID     = d.WarehouseID

                                       AND tran.CustomerID      = d.CustomerID

                                       AND tran.OrderID         = d.OrderID

                                       AND tran.OrderDetailsID  = d.ID

       LEFT JOIN tbl_order as o ON d.OrderID    = o.ID

                               AND d.CustomerID = o.CustomerID

  WHERE (tran.OrderID = P_OrderID)

    AND (o.ID IS NULL); --



  -- if transaction type does not correspond to the state of order we need to delete

  DELETE tran

  FROM tbl_inventory_transaction as tran

       INNER JOIN view_orderdetails as d ON tran.InventoryItemID = d.InventoryItemID

                                        AND tran.WarehouseID     = d.WarehouseID

                                        AND tran.CustomerID      = d.CustomerID

                                        AND tran.OrderID         = d.OrderID

                                        AND tran.OrderDetailsID  = d.ID

       INNER JOIN tbl_order as o ON d.OrderID    = o.ID

                                AND d.CustomerID = o.CustomerID

       INNER JOIN tbl_inventory_transaction_type as tt ON tt.ID = tran.TypeID

  WHERE (tran.OrderID = P_OrderID)

    AND NOT CASE tt.Name WHEN 'Committed'       THEN 1

                         WHEN 'Sold'            THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsSold

                         WHEN 'Rented'          THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsRented

                         WHEN 'Rental Returned' THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsRented AND d.IsPickedup

                         ELSE 0 END; --



  -- if transaction were not removed we have to update it to sync with order

  UPDATE tbl_inventory_transaction as tran

         INNER JOIN view_orderdetails as d ON tran.WarehouseID     = d.WarehouseID

                                          AND tran.InventoryItemID = d.InventoryItemID

                                          AND tran.CustomerID      = d.CustomerID

                                          AND tran.OrderID         = d.OrderID

                                          AND tran.OrderDetailsID  = d.ID

         INNER JOIN tbl_order as o ON d.OrderID = o.ID

                                  AND d.CustomerID = o.CustomerID

         INNER JOIN tbl_inventory_transaction_type as tt ON tt.ID = tran.TypeID

  SET tran.Date        = IFNULL(o.OrderDate, CURRENT_DATE()),

      tran.Quantity    = d.DeliveryQuantity,

      tran.Description = CONCAT('Order #', d.OrderID),

      tran.Cost        = 0,

      tran.SerialID    = NULL,

      tran.VendorID    = NULL,

      tran.InvoiceID   = NULL,

      tran.ManufacturerID = NULL,

      tran.LastUpdateUserID = o.LastUpdateUserID

  WHERE (o.ID = P_OrderID)

    AND CASE tt.Name WHEN 'Committed'       THEN 1

                     WHEN 'Sold'            THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsSold

                     WHEN 'Rented'          THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsRented

                     WHEN 'Rental Returned' THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsRented AND d.IsPickedup

                     ELSE 0 END; --



  INSERT INTO tbl_inventory_transaction

    (WarehouseID

    ,InventoryItemID

    ,TypeID

    ,Date

    ,Quantity

    ,Cost

    ,Description

    ,CustomerID

    ,OrderID

    ,OrderDetailsID

    ,LastUpdateUserID

    ,SerialID

    ,VendorID

    ,PurchaseOrderID

    ,PurchaseOrderDetailsID

    ,InvoiceID

    ,ManufacturerID)

  SELECT d.WarehouseID,

         d.InventoryItemID,

         tt.ID as TypeID,

         IFNULL(o.OrderDate, CURRENT_DATE()) as Date,

         d.DeliveryQuantity as Quantity,

         0 as Cost,

         CONCAT('Order #', d.OrderID) as Description,

         d.CustomerID,

         d.OrderID,

         d.ID as OrderDetailsID,

         o.LastUpdateUserID,

         NULL as SerialID,

         NULL as VendorID,

         NULL as PurchaseOrderID,

         NULL as PurchaseOrderDetailsID,

         NULL as InvoiceID,

         NULL as ManufacturerID

  FROM view_orderdetails as d

       INNER JOIN tbl_order as o ON d.OrderID    = o.ID

                                AND d.CustomerID = o.CustomerID

       INNER JOIN tbl_inventory_transaction_type as tt ON tt.Name IN ('Committed', 'Sold', 'Rented', 'Rental Returned')

       LEFT JOIN tbl_inventory_transaction as tran ON tran.WarehouseID     = d.WarehouseID

                                                  AND tran.InventoryItemID = d.InventoryItemID

                                                  AND tran.CustomerID      = d.CustomerID

                                                  AND tran.OrderID         = d.OrderID

                                                  AND tran.OrderDetailsID  = d.ID

                                                  AND tran.TypeID          = tt.ID

  WHERE (o.ID = P_OrderID)

    AND (tran.ID IS NULL)

    AND CASE tt.Name WHEN 'Committed'       THEN 1

                     WHEN 'Sold'            THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsSold

                     WHEN 'Rented'          THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsRented

                     WHEN 'Rental Returned' THEN (o.Approved = 1) AND (o.DeliveryDate IS NOT NULL) AND d.IsRented AND d.IsPickedup

                     ELSE 0 END; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_transaction_po_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_transaction_po_refresh`(P_PurchaseOrderID INT, P_Type VARCHAR(50))
BEGIN

  -- 'Ordered'

  -- 'Received'

  -- 'BackOrdered'

  UPDATE tbl_inventory_transaction as tran

         INNER JOIN tbl_purchaseorderdetails as podetails ON tran.WarehouseID = podetails.WarehouseID

                                                         AND tran.InventoryItemID = podetails.InventoryItemID

                                                         AND tran.PurchaseOrderID = podetails.PurchaseOrderID

                                                         AND tran.PurchaseOrderDetailsID = podetails.ID

         INNER JOIN tbl_purchaseorder as po ON podetails.PurchaseOrderID = po.ID

         INNER JOIN tbl_inventory_transaction_type ON tbl_inventory_transaction_type.ID   = tran.TypeID

                                                  AND tbl_inventory_transaction_type.Name = P_Type

  SET tran.Date = CASE P_Type WHEN 'Ordered'     THEN IFNULL(po.OrderDate   , CURRENT_DATE())

                              WHEN 'Received'    THEN IFNULL(podetails.DateReceived, CURRENT_DATE())

                              WHEN 'BackOrdered' THEN IFNULL(podetails.DateReceived, CURRENT_DATE())

                              ELSE 0 END,

      tran.Quantity = CASE P_Type WHEN 'Ordered'     THEN podetails.Ordered

                                  WHEN 'Received'    THEN podetails.Received

                                  WHEN 'BackOrdered' THEN podetails.Ordered - podetails.Received

                                  ELSE 0 END,

      tran.Cost = CASE P_Type WHEN 'Ordered'     THEN 0

                              WHEN 'Received'    THEN IFNULL(podetails.Received, 0) * IFNULL(podetails.Price, 0)

                              WHEN 'BackOrdered' THEN 0

                              ELSE 0 END,

      tran.Description = CONCAT('PO #', podetails.PurchaseOrderID),

      tran.SerialID = NULL,

      tran.VendorID = po.VendorID,

      tran.CustomerID = NULL,

      tran.InvoiceID  = NULL,

      tran.ManufacturerID = NULL,

      tran.OrderDetailsID = NULL,

      tran.LastUpdateUserID = po.LastUpdateUserID

  WHERE (po.ID = P_PurchaseOrderID)

    AND (po.Approved = 1)

    AND CASE P_Type WHEN 'Ordered'     THEN (0 < podetails.Ordered)

                    WHEN 'Received'    THEN (0 < podetails.Ordered) AND (0 < podetails.Received)

                    WHEN 'BackOrdered' THEN (0 < podetails.Ordered) AND (0 < podetails.Received) -- AND (podetails.Received < podetails.Ordered)

                    ELSE 0 END; --



  INSERT INTO tbl_inventory_transaction

  (WarehouseID,

   InventoryItemID,

   TypeID,

   Date,

   Quantity,

   Cost,

   Description,

   SerialID,

   VendorID,

   CustomerID,

   LastUpdateUserID,

   PurchaseOrderID,

   PurchaseOrderDetailsID,

   InvoiceID,

   ManufacturerID,

   OrderDetailsID)

  SELECT podetails.WarehouseID,

         podetails.InventoryItemID,

         tran_type.ID as TypeID,

         CASE P_Type WHEN 'Ordered'     THEN IFNULL(po.OrderDate   , CURRENT_DATE())

                     WHEN 'Received'    THEN IFNULL(podetails.DateReceived, CURRENT_DATE())

                     WHEN 'BackOrdered' THEN IFNULL(podetails.DateReceived, CURRENT_DATE())

                     ELSE 0 END as Date,

         CASE P_Type WHEN 'Ordered'     THEN podetails.Ordered

                     WHEN 'Received'    THEN podetails.Received

                     WHEN 'BackOrdered' THEN podetails.Ordered - podetails.Received

                     ELSE 0 END as Quantity,

         CASE P_Type WHEN 'Ordered'     THEN 0

                     WHEN 'Received'    THEN IFNULL(podetails.Received, 0) * IFNULL(podetails.Price, 0)

                     WHEN 'BackOrdered' THEN 0

                     ELSE 0 END as Cost,

         CONCAT('PO #', podetails.PurchaseOrderID) as Description,

         NULL as SerialID,

         po.VendorID,

         NULL as CustomerID,

         po.LastUpdateUserID,

         podetails.PurchaseOrderID,

         podetails.ID as PurchaseOrderDetailsID,

         NULL as InvoiceID,

         NULL as ManufacturerID,

         NULL as OrderDetailsID

  FROM tbl_purchaseorderdetails as podetails

       INNER JOIN tbl_purchaseorder as po ON podetails.PurchaseOrderID = po.ID

       INNER JOIN tbl_inventory_transaction_type as tran_type ON tran_type.Name = P_Type

       LEFT JOIN tbl_inventory_transaction as tran ON tran.WarehouseID = podetails.WarehouseID

                                                  AND tran.InventoryItemID = podetails.InventoryItemID

                                                  AND tran.PurchaseOrderID = podetails.PurchaseOrderID

                                                  AND tran.PurchaseOrderDetailsID = podetails.ID

                                                  AND tran.TypeID = tran_type.ID

  WHERE (po.ID = P_PurchaseOrderID)

    AND (po.Approved = 1)

    AND (tran.ID IS NULL)

    AND CASE P_Type WHEN 'Ordered'     THEN (0 < podetails.Ordered)

                    WHEN 'Received'    THEN (0 < podetails.Ordered) AND (0 < podetails.Received)

                    WHEN 'BackOrdered' THEN (0 < podetails.Ordered) AND (0 < podetails.Received) -- AND (podetails.Received < podetails.Ordered)

                    ELSE 0 END; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inventory_transfer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_transfer`(

  P_InventoryItemID   INT

, P_SrcWarehouseID   INT

, P_DstWarehouseID   INT

, P_Quantity         INT

, P_LastUpdateUserID INT)
BEGIN

  CALL internal_inventory_transfer(

    P_InventoryItemID

  , P_SrcWarehouseID

  , P_DstWarehouseID

  , P_Quantity

  , 'Inventory Transfer'

  , P_LastUpdateUserID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_AddAutoSubmit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_AddAutoSubmit`(

  P_InvoiceDetailsID INT,

  P_InsuranceCompanyID INT,

  P_TransactionDate DATETIME,

  P_LastUpdateUserID smallint,

  OUT P_Result VARCHAR(50))
    MODIFIES SQL DATA
PROC: BEGIN

  DECLARE V_CustomerID, V_InvoiceID, V_InvoiceDetailsID INT; --

  DECLARE V_TransmittedCustomerInsuranceID, V_TransmittedInsuranceCompanyID INT; --

  DECLARE V_Billable DECIMAL(18, 2); --

  DECLARE V_Quantity, V_Count INT; --



  SELECT

   `detail`.CustomerID,

   `detail`.InvoiceID,

   `detail`.ID as InvoiceDetailsID,

   CASE WHEN ins1.InsuranceCompanyID = P_InsuranceCompanyID THEN ins1.ID

        WHEN ins2.InsuranceCompanyID = P_InsuranceCompanyID THEN ins2.ID

        WHEN ins3.InsuranceCompanyID = P_InsuranceCompanyID THEN ins3.ID

        WHEN ins4.InsuranceCompanyID = P_InsuranceCompanyID THEN ins4.ID

        ELSE NULL END AS TransmittedCustomerInsuranceID,

   CASE WHEN ins1.InsuranceCompanyID = P_InsuranceCompanyID THEN ins1.InsuranceCompanyID

        WHEN ins2.InsuranceCompanyID = P_InsuranceCompanyID THEN ins2.InsuranceCompanyID

        WHEN ins3.InsuranceCompanyID = P_InsuranceCompanyID THEN ins3.InsuranceCompanyID

        WHEN ins4.InsuranceCompanyID = P_InsuranceCompanyID THEN ins4.InsuranceCompanyID

        ELSE NULL END AS TransmittedInsuranceCompanyID,

   `detail`.BillableAmount,

   `detail`.Quantity

  INTO

    V_CustomerID,

    V_InvoiceID,

    V_InvoiceDetailsID,

    V_TransmittedCustomerInsuranceID,

    V_TransmittedInsuranceCompanyID,

    V_Billable,

    V_Quantity

  FROM tbl_invoicedetails as `detail`

       INNER JOIN tbl_invoice as `invoice` ON `detail`.InvoiceID  = `invoice`.ID

                                          AND `detail`.CustomerID = `invoice`.CustomerID

       LEFT JOIN `tbl_customer_insurance` as `ins1` ON `ins1`.ID         = `invoice`.CustomerInsurance1_ID

                                                   AND `ins1`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns1 = 1

       LEFT JOIN `tbl_customer_insurance` as `ins2` ON `ins2`.ID         = `invoice`.CustomerInsurance2_ID

                                                   AND `ins2`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns2 = 1

       LEFT JOIN `tbl_customer_insurance` as `ins3` ON `ins3`.ID         = `invoice`.CustomerInsurance3_ID

                                                   AND `ins3`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns3 = 1

       LEFT JOIN `tbl_customer_insurance` as `ins4` ON `ins4`.ID         = `invoice`.CustomerInsurance4_ID

                                                   AND `ins4`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns4 = 1

  WHERE (`detail`.ID = P_InvoiceDetailsID); --



  IF (V_CustomerID IS NULL) OR (V_InvoiceID IS NULL) OR (V_InvoiceDetailsID IS NULL) THEN

    SET P_Result = 'InvoiceDetailsID is wrong'; --

    LEAVE PROC; --

  END IF; --



  IF (V_TransmittedCustomerInsuranceID IS NULL) OR (V_TransmittedInsuranceCompanyID IS NULL) THEN

    SET P_Result = 'Autosubmitted Company ID is wrong'; --

    LEAVE PROC; --

  END IF; --



  SELECT COUNT(*)

  INTO V_Count

  FROM tbl_invoice_transaction as it

       INNER JOIN tbl_invoice_transactiontype as tt ON it.TransactionTypeID = tt.ID

  WHERE (tt.Name               = 'Auto Submit'                  )

    AND (it.CustomerID         = V_CustomerID                   )

    AND (it.InvoiceID          = V_InvoiceID                    )

    AND (it.InvoiceDetailsID   = V_InvoiceDetailsID             )

    AND (it.InsuranceCompanyID = V_TransmittedInsuranceCompanyID); --



  IF 0 < V_Count THEN

    SET P_Result = 'Transaction already exists'; --

    LEAVE PROC; --

  END IF; --



  INSERT INTO tbl_invoice_transaction (

    InvoiceDetailsID

  , InvoiceID

  , CustomerID

  , InsuranceCompanyID

  , CustomerInsuranceID

  , TransactionTypeID

  , TransactionDate

  , Amount

  , Quantity

  , Taxes

  , BatchNumber

  , Comments

  , Extra

  , Approved

  , LastUpdateUserID)

  SELECT

    V_InvoiceDetailsID

  , V_InvoiceID

  , V_CustomerID

  , V_TransmittedInsuranceCompanyID

  , V_TransmittedCustomerInsuranceID

  , ID as TransactionTypeID

  , P_TransactionDate

  , V_Billable as Amount

  , V_Quantity as Quantity

  , 0.00       as Taxes

  , ''         as BatchNumber

  , 'EDI'      as Comments

  , null       as Extra

  , 1          as Approved

  , P_LastUpdateUserID

  FROM tbl_invoice_transactiontype

  WHERE (Name = 'Auto Submit'); --



  SET P_Result = 'Success'; --

END PROC ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_AddPayment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_AddPayment`( P_InvoiceDetailsID INT

, P_InsuranceCompanyID INT

, P_TransactionDate DATETIME

, P_Extra TEXT

, P_Comments TEXT

, P_Options TEXT

, P_LastUpdateUserID smallint

, OUT P_Result VARCHAR(255))
    MODIFIES SQL DATA
PROC: BEGIN

  DECLARE V_CustomerID, V_InvoiceID, V_InvoiceDetailsID, V_CustomerInsuranceID, V_InsuranceCompanyID INT; --

  DECLARE V_BasisAllowable, V_FirstInsurance BOOL; --

  DECLARE V_AllowableAmount, V_BillableAmount DECIMAL(18, 2); --

  DECLARE V_Quantity, V_Count INT; --

  DECLARE V_ExtraPaid, V_ExtraAllowable, V_ExtraDeductible, V_ExtraCheckNumber, V_ExtraPostingGuid, V_ExtraSequestration, V_ExtraContractualWriteoff VARCHAR(18); --

  DECLARE V_NumericRegexp VARCHAR(50); --

  DECLARE V_PaymentPaidAmount, V_PaymentAllowableAmount, V_PaymentDeductibleAmount, V_PaymentSequestrationAmount, V_PaymentContractualWriteoffAmount DECIMAL(18, 2); --



  SET V_ExtraPaid                = ExtractValue(P_Extra, 'values/v[@n="Paid"]/text()'); --

  SET V_ExtraAllowable           = ExtractValue(P_Extra, 'values/v[@n="Allowable"]/text()'); --

  SET V_ExtraCheckNumber         = ExtractValue(P_Extra, 'values/v[@n="CheckNumber"]/text()'); --

  SET V_ExtraPostingGuid         = ExtractValue(P_Extra, 'values/v[@n="PostingGuid"]/text()'); --

  SET V_ExtraDeductible          = ExtractValue(P_Extra, 'values/v[@n="Deductible"]/text()'); --

  SET V_ExtraSequestration       = ExtractValue(P_Extra, 'values/v[@n="Sequestration"]/text()'); --

  SET V_ExtraContractualWriteoff = ExtractValue(P_Extra, 'values/v[@n="ContractualWriteoff"]/text()'); --



  SET V_NumericRegexp = '^(-|\\+)?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$'; --



  SET V_PaymentPaidAmount                = CASE WHEN V_ExtraPaid                REGEXP V_NumericRegexp THEN V_ExtraPaid                ELSE NULL END; --

  SET V_PaymentAllowableAmount           = CASE WHEN V_ExtraAllowable           REGEXP V_NumericRegexp THEN V_ExtraAllowable           ELSE NULL END; --

  SET V_PaymentDeductibleAmount          = CASE WHEN V_ExtraDeductible          REGEXP V_NumericRegexp THEN V_ExtraDeductible          ELSE NULL END; --

  SET V_PaymentSequestrationAmount       = CASE WHEN V_ExtraSequestration       REGEXP V_NumericRegexp THEN V_ExtraSequestration       ELSE NULL END; --

  SET V_PaymentContractualWriteoffAmount = CASE WHEN V_ExtraContractualWriteoff REGEXP V_NumericRegexp THEN V_ExtraContractualWriteoff ELSE NULL END; --



  IF (V_PaymentPaidAmount IS NULL) THEN

    SET P_Result = 'Paid amount is not specified'; --

    LEAVE PROC; --

  END IF; --



  SELECT

   `detail`.CustomerID,

   `detail`.InvoiceID,

   `detail`.ID as InvoiceDetailsID,

   CASE WHEN ins1.InsuranceCompanyID = P_InsuranceCompanyID THEN ins1.ID

        WHEN ins2.InsuranceCompanyID = P_InsuranceCompanyID THEN ins2.ID

        WHEN ins3.InsuranceCompanyID = P_InsuranceCompanyID THEN ins3.ID

        WHEN ins4.InsuranceCompanyID = P_InsuranceCompanyID THEN ins4.ID

        ELSE NULL END AS CustomerInsuranceID,

   CASE WHEN ins1.InsuranceCompanyID = P_InsuranceCompanyID THEN ins1.InsuranceCompanyID

        WHEN ins2.InsuranceCompanyID = P_InsuranceCompanyID THEN ins2.InsuranceCompanyID

        WHEN ins3.InsuranceCompanyID = P_InsuranceCompanyID THEN ins3.InsuranceCompanyID

        WHEN ins4.InsuranceCompanyID = P_InsuranceCompanyID THEN ins4.InsuranceCompanyID

        ELSE NULL END AS InsuranceCompanyID,

   CASE WHEN ins1.ID IS NOT NULL THEN ins1.InsuranceCompanyID = P_InsuranceCompanyID

        WHEN ins2.ID IS NOT NULL THEN ins2.InsuranceCompanyID = P_InsuranceCompanyID

        WHEN ins3.ID IS NOT NULL THEN ins3.InsuranceCompanyID = P_InsuranceCompanyID

        WHEN ins4.ID IS NOT NULL THEN ins4.InsuranceCompanyID = P_InsuranceCompanyID

        ELSE 0 END AS FirstInsurance,

   CASE WHEN ins1.ID IS NOT NULL THEN ins1.Basis = 'Allowed'

        WHEN ins2.ID IS NOT NULL THEN ins2.Basis = 'Allowed'

        WHEN ins3.ID IS NOT NULL THEN ins3.Basis = 'Allowed'

        WHEN ins4.ID IS NOT NULL THEN ins4.Basis = 'Allowed'

        ELSE 0 END AS BasisAllowable,

   `detail`.AllowableAmount,

   `detail`.BillableAmount,

   `detail`.Quantity

  INTO

    V_CustomerID,

    V_InvoiceID,

    V_InvoiceDetailsID,

    V_CustomerInsuranceID,

    V_InsuranceCompanyID,

    V_FirstInsurance,

    V_BasisAllowable,

    V_AllowableAmount,

    V_BillableAmount,

    V_Quantity

  FROM tbl_invoicedetails as `detail`

       INNER JOIN tbl_invoice as `invoice` ON `detail`.InvoiceID  = `invoice`.ID

                                          AND `detail`.CustomerID = `invoice`.CustomerID

       LEFT JOIN `tbl_customer_insurance` as ins1 ON ins1.ID         = `invoice`.CustomerInsurance1_ID

                                                 AND ins1.CustomerID = `invoice`.CustomerID

                                                 AND `detail`.BillIns1 = 1

       LEFT JOIN `tbl_customer_insurance` as ins2 ON ins2.ID         = `invoice`.CustomerInsurance2_ID

                                                 AND ins2.CustomerID = `invoice`.CustomerID

                                                 AND `detail`.BillIns2 = 1

       LEFT JOIN `tbl_customer_insurance` as ins3 ON ins3.ID         = `invoice`.CustomerInsurance3_ID

                                                 AND ins3.CustomerID = `invoice`.CustomerID

                                                 AND `detail`.BillIns3 = 1

       LEFT JOIN `tbl_customer_insurance` as ins4 ON ins4.ID         = `invoice`.CustomerInsurance4_ID

                                                 AND ins4.CustomerID = `invoice`.CustomerID

                                                 AND `detail`.BillIns4 = 1

  WHERE (`detail`.ID = P_InvoiceDetailsID); --



  IF (V_CustomerID IS NULL)

  OR (V_InvoiceID IS NULL)

  OR (V_InvoiceDetailsID IS NULL) THEN

    SET P_Result = 'InvoiceDetailsID is wrong'; --

    LEAVE PROC; --

  END IF; --



  IF ((V_InsuranceCompanyID IS NULL) != (P_InsuranceCompanyID IS NULL)) THEN

    SET P_Result = 'InsuranceCompanyID is wrong'; --

    LEAVE PROC; --

  END IF; --



  IF (V_ExtraCheckNumber != '')

  AND (V_ExtraPostingGuid != '') THEN

    -- if we got both check number and posting guid we have to check that

    -- there are no other payment / denied transactions with same check number but different PostingGuid

    -- that way we allow posting multiple transaction for same checknumber

    -- but prevent autoposting from posting same check (and 835) twice since PostingGuid is used only by auto posting

    SELECT SUM(CASE WHEN ExtractValue(it.Extra, 'values/v[@n="CheckNumber"]/text()') = V_ExtraCheckNumber

                     AND ExtractValue(it.Extra, 'values/v[@n="PostingGuid"]/text()') != V_ExtraPostingGuid

                    THEN 1 ELSE 0 END)

    INTO V_Count

    FROM tbl_invoice_transaction as it

         INNER JOIN tbl_invoice_transactiontype as tt ON it.TransactionTypeID = tt.ID

    WHERE (tt.Name IN ('Denied', 'Payment'))

      AND (it.CustomerID         = V_CustomerID        )

      AND (it.InvoiceID          = V_InvoiceID         )

      AND (it.InvoiceDetailsID   = V_InvoiceDetailsID  )

      AND (it.InsuranceCompanyID = V_InsuranceCompanyID OR (it.InsuranceCompanyID IS NULL AND V_InsuranceCompanyID IS NULL)); --



    IF V_Count != 0 THEN

      SET P_Result = CONCAT('Payment for check# ', V_ExtraCheckNumber, ' does already exist'); --

      LEAVE PROC; --

    END IF; --

  END IF; --



  -- 'Adjust Allowable' - optional

  -- 'Denied' IF Amount = 0 - optional

  -- 'Payment' OTHERWISE

  -- 'Contractual Writeoff'

  -- 'Deductible'

  -- 'Auto Submit'

  -- 'Sequestration Writeoff'

  -- 'Hardship Writeoff'

  -- 'Balance Writeoff' - optional



  IF (0 < FIND_IN_SET('Adjust Allowable', P_Options))

  AND (V_CustomerInsuranceID IS NOT NULL)

  AND (V_InsuranceCompanyID IS NOT NULL)

  AND (V_FirstInsurance = 1)

  AND (0.01 <= ABS(V_PaymentAllowableAmount - V_AllowableAmount)) THEN

    -- we should add transaction only once

    SELECT COUNT(*)

    INTO V_Count

    FROM tbl_invoice_transaction as it

         INNER JOIN tbl_invoice_transactiontype as tt ON it.TransactionTypeID = tt.ID

    WHERE (tt.Name = 'Adjust Allowable')

      AND (it.CustomerID         = V_CustomerID        )

      AND (it.InvoiceID          = V_InvoiceID         )

      AND (it.InvoiceDetailsID   = V_InvoiceDetailsID  )

      AND (it.InsuranceCompanyID = V_InsuranceCompanyID); --



    IF V_Count = 0 THEN

      INSERT INTO tbl_invoice_transaction (

        InvoiceDetailsID

      , InvoiceID

      , CustomerID

      , InsuranceCompanyID

      , CustomerInsuranceID

      , TransactionTypeID

      , TransactionDate

      , Amount

      , Quantity

      , Taxes

      , BatchNumber

      , Comments

      , Extra

      , Approved

      , LastUpdateUserID)

      SELECT

        V_InvoiceDetailsID

      , V_InvoiceID

      , V_CustomerID

      , V_InsuranceCompanyID

      , V_CustomerInsuranceID

      , ID   as TransactionTypeID

      , P_TransactionDate

      , V_PaymentAllowableAmount

      , V_Quantity

      , 0.00       as Taxes

      , ''         as BatchNumber

      , P_Comments as Comments

      , null       as Extra

      , 1          as Approved

      , P_LastUpdateUserID

      FROM tbl_invoice_transactiontype

      WHERE (Name = 'Adjust Allowable'); --



      SET V_AllowableAmount = V_PaymentAllowableAmount; --

    END IF; --

  END IF; --



  IF (0 < FIND_IN_SET('Post Denied', P_Options))

  AND (ABS(V_PaymentPaidAmount) < 0.01) THEN

    -- we allow adding 'denied' transaction many times since they will not affect anything

    INSERT INTO tbl_invoice_transaction (

      InvoiceDetailsID

    , InvoiceID

    , CustomerID

    , InsuranceCompanyID

    , CustomerInsuranceID

    , TransactionTypeID

    , TransactionDate

    , Amount

    , Quantity

    , Taxes

    , BatchNumber

    , Comments

    , Extra

    , Approved

    , LastUpdateUserID)

    SELECT

      V_InvoiceDetailsID

    , V_InvoiceID

    , V_CustomerID

    , V_InsuranceCompanyID

    , V_CustomerInsuranceID

    , ID as TransactionTypeID

    , P_TransactionDate

    , 0.00       as Amount

    , V_Quantity

    , 0.00       as Taxes

    , ''         as BatchNumber

    , P_Comments as Comments

    , P_Extra    as Extra

    , 1          as Approved

    , P_LastUpdateUserID

    FROM tbl_invoice_transactiontype

    WHERE (Name = 'Denied'); --

  ELSE

    INSERT INTO tbl_invoice_transaction (

      InvoiceDetailsID

    , InvoiceID

    , CustomerID

    , InsuranceCompanyID

    , CustomerInsuranceID

    , TransactionTypeID

    , TransactionDate

    , Amount

    , Quantity

    , Taxes

    , BatchNumber

    , Comments

    , Extra

    , Approved

    , LastUpdateUserID)

    SELECT

      V_InvoiceDetailsID

    , V_InvoiceID

    , V_CustomerID

    , V_InsuranceCompanyID

    , V_CustomerInsuranceID

    , ID as TransactionTypeID

    , P_TransactionDate

    , V_PaymentPaidAmount

    , V_Quantity

    , 0.00       as Taxes

    , ''         as BatchNumber

    , P_Comments as Comments

    , P_Extra    as Extra

    , 1          as Approved

    , P_LastUpdateUserID

    FROM tbl_invoice_transactiontype

    WHERE (Name = 'Payment'); --

  END IF; --



  IF (V_CustomerInsuranceID IS NOT NULL)

  AND (V_InsuranceCompanyID IS NOT NULL) THEN

    IF (0.01 <= ABS(V_PaymentSequestrationAmount)) THEN

      INSERT INTO tbl_invoice_transaction (

        InvoiceDetailsID

      , InvoiceID

      , CustomerID

      , InsuranceCompanyID

      , CustomerInsuranceID

      , TransactionTypeID

      , TransactionDate

      , Amount

      , Quantity

      , Taxes

      , BatchNumber

      , Comments

      , Extra

      , Approved

      , LastUpdateUserID)

      SELECT

        V_InvoiceDetailsID

      , V_InvoiceID

      , V_CustomerID

      , V_InsuranceCompanyID

      , V_CustomerInsuranceID

      , ID as TransactionTypeID

      , P_TransactionDate

      , V_PaymentSequestrationAmount

      , V_Quantity

      , 0.00       as Taxes

      , ''         as BatchNumber

      , 'Sequestration Writeoff' as Comments

      , null       as Extra

      , 1          as Approved

      , P_LastUpdateUserID

      FROM tbl_invoice_transactiontype

      WHERE (Name = 'Writeoff'); --

    END IF; --



    IF (V_FirstInsurance = 1)

    AND (0.01 <= ABS(V_PaymentContractualWriteoffAmount)) THEN

      INSERT INTO tbl_invoice_transaction (

        InvoiceDetailsID

      , InvoiceID

      , CustomerID

      , InsuranceCompanyID

      , CustomerInsuranceID

      , TransactionTypeID

      , TransactionDate

      , Amount

      , Quantity

      , Taxes

      , BatchNumber

      , Comments

      , Extra

      , Approved

      , LastUpdateUserID)

      SELECT

        V_InvoiceDetailsID

      , V_InvoiceID

      , V_CustomerID

      , V_InsuranceCompanyID

      , V_CustomerInsuranceID

      , ID as TransactionTypeID

      , P_TransactionDate

      , V_PaymentContractualWriteoffAmount

      , V_Quantity

      , 0.00       as Taxes

      , ''         as BatchNumber

      , P_Comments as Comments

      , null       as Extra

      , 1          as Approved

      , P_LastUpdateUserID

      FROM tbl_invoice_transactiontype

      WHERE (Name = 'Contractual Writeoff'); --

    ELSEIF (V_FirstInsurance = 1)

    AND (V_BasisAllowable = 1)

    AND (0.01 <= V_BillableAmount - V_AllowableAmount) THEN

      SELECT COUNT(*)

      INTO V_Count

      FROM tbl_invoice_transaction as it

           INNER JOIN tbl_invoice_transactiontype as tt ON it.TransactionTypeID = tt.ID

      WHERE (tt.Name               = 'Contractual Writeoff')

        AND (it.CustomerID         = V_CustomerID          )

        AND (it.InvoiceID          = V_InvoiceID           )

        AND (it.InvoiceDetailsID   = V_InvoiceDetailsID    )

        AND (it.InsuranceCompanyID = V_InsuranceCompanyID  ); --



      IF V_Count = 0 THEN

        INSERT INTO tbl_invoice_transaction (

          InvoiceDetailsID

        , InvoiceID

        , CustomerID

        , InsuranceCompanyID

        , CustomerInsuranceID

        , TransactionTypeID

        , TransactionDate

        , Amount

        , Quantity

        , Taxes

        , BatchNumber

        , Comments

        , Extra

        , Approved

        , LastUpdateUserID)

        SELECT

          V_InvoiceDetailsID

        , V_InvoiceID

        , V_CustomerID

        , V_InsuranceCompanyID

        , V_CustomerInsuranceID

        , ID as TransactionTypeID

        , P_TransactionDate

        , V_BillableAmount - V_AllowableAmount

        , V_Quantity

        , 0.00       as Taxes

        , ''         as BatchNumber

        , P_Comments as Comments

        , null       as Extra

        , 1          as Approved

        , P_LastUpdateUserID

        FROM tbl_invoice_transactiontype

        WHERE (Name = 'Contractual Writeoff'); --

      END IF; --

    END IF; --



    IF (V_FirstInsurance = 1)

    AND (0.01 <= V_PaymentDeductibleAmount) THEN

      SELECT COUNT(*)

      INTO V_Count

      FROM tbl_invoice_transaction as it

           INNER JOIN tbl_invoice_transactiontype as tt ON it.TransactionTypeID = tt.ID

      WHERE (tt.Name               = 'Deductible'        )

        AND (it.CustomerID         = V_CustomerID        )

        AND (it.InvoiceID          = V_InvoiceID         )

        AND (it.InvoiceDetailsID   = V_InvoiceDetailsID  )

        AND (it.InsuranceCompanyID = V_InsuranceCompanyID); --



      IF V_Count = 0 THEN

        INSERT INTO tbl_invoice_transaction (

          InvoiceDetailsID

        , InvoiceID

        , CustomerID

        , InsuranceCompanyID

        , CustomerInsuranceID

        , TransactionTypeID

        , TransactionDate

        , Amount

        , Quantity

        , Taxes

        , BatchNumber

        , Comments

        , Extra

        , Approved

        , LastUpdateUserID)

        SELECT

          V_InvoiceDetailsID

        , V_InvoiceID

        , V_CustomerID

        , V_InsuranceCompanyID

        , V_CustomerInsuranceID

        , ID as TransactionTypeID

        , P_TransactionDate

        , V_PaymentDeductibleAmount

        , V_Quantity

        , 0.00       as Taxes

        , ''         as BatchNumber

        , P_Comments as Comments

        , null       as Extra

        , 1          as Approved

        , P_LastUpdateUserID

        FROM tbl_invoice_transactiontype

        WHERE (Name = 'Deductible'); --

      END IF; --

    END IF; --

  END IF; --



  CALL InvoiceDetails_RecalculateInternals_Single(null, P_InvoiceDetailsID); --

  -- for the following operations we need updated balance so we need to recalculate it



  INSERT INTO tbl_invoice_transaction (

    InvoiceDetailsID

  , InvoiceID

  , CustomerID

  , InsuranceCompanyID

  , CustomerInsuranceID

  , TransactionTypeID

  , TransactionDate

  , Amount

  , Quantity

  , Comments

  , Taxes

  , BatchNumber

  , Extra

  , Approved

  , LastUpdateUserID)

  SELECT

    det.ID as InvoiceDetailsID

  , det.InvoiceID

  , det.CustomerID

  , det.CurrentInsuranceCompanyID

  , det.CurrentCustomerInsuranceID

  , itt.ID as TransactionTypeID

  , NOW() as TransactionDate

  , det.Balance

  , det.Quantity

  , CASE WHEN det.Hardship = 1 THEN 'Hardship Writeoff' ELSE CONCAT('Wrote off by ', IFNULL(usr.Login, '?')) END AS Comments

  , 0.00 as Taxes

  , ''   as BatchNumber

  , null as Extra

  , 1    as Approved

  , P_LastUpdateUserID

  FROM tbl_invoicedetails as det

       INNER JOIN tbl_invoice_transactiontype as itt ON itt.Name = 'Writeoff'

       LEFT JOIN tbl_user as usr ON usr.ID = P_LastUpdateUserID

  WHERE (det.ID = P_InvoiceDetailsID)

    AND ((det.Hardship = 1 AND det.CurrentPayer = 'Patient') OR (0 < FIND_IN_SET('Writeoff Balance', P_Options)))

    AND (0.01 <= det.Balance); --



  IF (ROW_COUNT() != 0) THEN

    CALL InvoiceDetails_RecalculateInternals_Single(null, P_InvoiceDetailsID); --

  END IF; --



  SET P_Result = 'Success'; --

END PROC ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_AddSubmitted` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_AddSubmitted`(

  P_InvoiceDetailsID INT,

  P_Amount DECIMAL(18,2),

  P_SubmittedTo VARCHAR(50),

  P_SubmittedBy VARCHAR(50),

  P_SubmittedBatch VARCHAR(50),

  P_LastUpdateUserID smallint)
BEGIN

  CALL InvoiceDetails_InternalAddSubmitted(P_InvoiceDetailsID, P_Amount, P_SubmittedTo, P_SubmittedBy, P_SubmittedBatch, P_LastUpdateUserID); --

  CALL InvoiceDetails_RecalculateInternals_Single(null, P_InvoiceDetailsID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_InternalAddAutoSubmit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_InternalAddAutoSubmit`(

  P_InvoiceDetailsID INT,

  P_AutoSubmittedTo VARCHAR(5),

  P_LastUpdateUserID smallint,

  OUT P_Result VARCHAR(50))
    MODIFIES SQL DATA
BEGIN

  DECLARE V_CustomerID, V_InvoiceID, V_InvoiceDetailsID INT; --

  DECLARE V_TransmittedCustomerInsuranceID, V_TransmittedInsuranceCompanyID INT; --

  DECLARE V_Billable DECIMAL(18, 2); --

  DECLARE V_Quantity, V_Count INT; --



  SELECT

   `detail`.CustomerID,

   `detail`.InvoiceID,

   `detail`.ID as InvoiceDetailsID,

   CASE WHEN P_AutoSubmittedTo = 'Ins1' THEN `ins1`.ID

        WHEN P_AutoSubmittedTo = 'Ins2' THEN `ins2`.ID

        WHEN P_AutoSubmittedTo = 'Ins3' THEN `ins3`.ID

        WHEN P_AutoSubmittedTo = 'Ins4' THEN `ins4`.ID

        ELSE NULL END AS TransmittedCustomerInsuranceID,

   CASE WHEN P_AutoSubmittedTo = 'Ins1' THEN `ins1`.InsuranceCompanyID

        WHEN P_AutoSubmittedTo = 'Ins2' THEN `ins2`.InsuranceCompanyID

        WHEN P_AutoSubmittedTo = 'Ins3' THEN `ins3`.InsuranceCompanyID

        WHEN P_AutoSubmittedTo = 'Ins4' THEN `ins4`.InsuranceCompanyID

        ELSE NULL END AS TransmittedInsuranceCompanyID,

   `detail`.BillableAmount,

   `detail`.Quantity

  INTO

    V_CustomerID,

    V_InvoiceID,

    V_InvoiceDetailsID,

    V_TransmittedCustomerInsuranceID,

    V_TransmittedInsuranceCompanyID,

    V_Billable,

    V_Quantity

  FROM tbl_invoicedetails as `detail`

       INNER JOIN tbl_invoice as `invoice` ON `detail`.InvoiceID  = `invoice`.ID

                                          AND `detail`.CustomerID = `invoice`.CustomerID

       LEFT JOIN `tbl_customer_insurance` as `ins1` ON `ins1`.ID         = `invoice`.CustomerInsurance1_ID

                                                   AND `ins1`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns1 = 1

       LEFT JOIN `tbl_customer_insurance` as `ins2` ON `ins2`.ID         = `invoice`.CustomerInsurance2_ID

                                                   AND `ins2`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns2 = 1

       LEFT JOIN `tbl_customer_insurance` as `ins3` ON `ins3`.ID         = `invoice`.CustomerInsurance3_ID

                                                   AND `ins3`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns3 = 1

       LEFT JOIN `tbl_customer_insurance` as `ins4` ON `ins4`.ID         = `invoice`.CustomerInsurance4_ID

                                                   AND `ins4`.CustomerID = `invoice`.CustomerID

                                                   AND `detail`.BillIns4 = 1

  WHERE (`detail`.ID = P_InvoiceDetailsID); --



  IF (V_CustomerID IS NULL) OR (V_InvoiceID IS NULL) OR (V_InvoiceDetailsID IS NULL) THEN

    SET P_Result = 'InvoiceDetailsID is wrong'; --

  ELSEIF (V_TransmittedCustomerInsuranceID IS NULL) OR (V_TransmittedInsuranceCompanyID IS NULL) THEN

    SET P_Result = 'Autosubmitted Payer is wrong'; --

  ELSE

    SELECT COUNT(*)

    INTO V_Count

    FROM tbl_invoice_transaction as it

         INNER JOIN tbl_invoice_transactiontype as tt ON it.TransactionTypeID = tt.ID

    WHERE (tt.Name               = 'Auto Submit'                  )

      AND (it.CustomerID         = V_CustomerID                   )

      AND (it.InvoiceID          = V_InvoiceID                    )

      AND (it.InvoiceDetailsID   = V_InvoiceDetailsID             )

      AND (it.InsuranceCompanyID = V_TransmittedInsuranceCompanyID); --



    IF 0 < V_Count THEN

      SET P_Result = 'Transaction already exists'; --

    ELSE

      INSERT INTO tbl_invoice_transaction (

        InvoiceDetailsID

      , InvoiceID

      , CustomerID

      , InsuranceCompanyID

      , CustomerInsuranceID

      , TransactionTypeID

      , TransactionDate

      , Amount

      , Quantity

      , Taxes

      , BatchNumber

      , Comments

      , Extra

      , Approved

      , LastUpdateUserID)

      SELECT

        V_InvoiceDetailsID

      , V_InvoiceID

      , V_CustomerID

      , V_TransmittedInsuranceCompanyID

      , V_TransmittedCustomerInsuranceID

      , ID as TransactionTypeID

      , CURRENT_DATE() as TransactionDate

      , V_Billable as Amount

      , V_Quantity as Quantity

      , 0.00       as Taxes

      , ''         as BatchNumber

      , 'Manual'   as Comments

      , null       as Extra

      , 1          as Approved

      , P_LastUpdateUserID

      FROM tbl_invoice_transactiontype

      WHERE (Name = 'Auto Submit'); --

    END IF; --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_InternalAddSubmitted` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_InternalAddSubmitted`(

  P_InvoiceDetailsID INT,

  P_Amount DECIMAL(18,2),

  P_SubmittedTo VARCHAR(50),

  P_SubmittedBy VARCHAR(50),

  P_SubmittedBatch VARCHAR(50),

  P_LastUpdateUserID smallint)
BEGIN

  DECLARE V_TransactionTypeID INT DEFAULT (0); --



  SELECT ID

  INTO V_TransactionTypeID

  FROM tbl_invoice_transactiontype

  WHERE Name = 'Submit'; --



  IF P_SubmittedTo = 'Patient' THEN

    INSERT INTO `tbl_invoice_transaction` (

      `InvoiceDetailsID`,

      `InvoiceID`,

      `CustomerID`,

      `InsuranceCompanyID`,

      `CustomerInsuranceID`,

      `TransactionTypeID`,

      `Amount`,

      `Quantity`,

      `TransactionDate`,

      `BatchNumber`,

      `Comments`,

      `LastUpdateUserID`)

    SELECT tbl_invoicedetails.ID as `InvoiceDetailsID`,

           tbl_invoicedetails.InvoiceID,

           tbl_invoicedetails.CustomerID,

           NULL                  as `InsuranceCompanyID`,

           NULL                  as `CustomerInsuranceID`,

           V_TransactionTypeID,

           P_Amount,

           tbl_invoicedetails.Quantity,

           CURRENT_DATE() as `TransactionDate`,

           P_SubmittedBatch,

           Concat('Submitted by ', P_SubmittedBy) as `Comments`,

           P_LastUpdateUserID

    FROM tbl_invoicedetails

    WHERE (tbl_invoicedetails.ID = P_InvoiceDetailsID); --



  ELSEIF P_SubmittedTo = 'Ins4' THEN

    INSERT INTO `tbl_invoice_transaction` (

      `InvoiceDetailsID`,

      `InvoiceID`,

      `CustomerID`,

      `InsuranceCompanyID`,

      `CustomerInsuranceID`,

      `TransactionTypeID`,

      `Amount`,

      `Quantity`,

      `TransactionDate`,

      `BatchNumber`,

      `Comments`,

      `LastUpdateUserID`)

    SELECT tbl_invoicedetails.ID as `InvoiceDetailsID`,

           tbl_invoicedetails.InvoiceID,

           tbl_invoicedetails.CustomerID,

           tbl_customer_insurance.InsuranceCompanyID,

           tbl_customer_insurance.ID as `CustomerInsuranceID`,

           V_TransactionTypeID,

           P_Amount,

           tbl_invoicedetails.Quantity,

           CURRENT_DATE() as `TransactionDate`,

           P_SubmittedBatch,

           Concat('Submitted by ', P_SubmittedBy) as `Comments`,

           P_LastUpdateUserID

    FROM ((tbl_invoicedetails

           INNER JOIN tbl_invoice ON tbl_invoicedetails.CustomerID = tbl_invoice.CustomerID

                                 AND tbl_invoicedetails.InvoiceID = tbl_invoice.ID)

          INNER JOIN tbl_customer_insurance ON tbl_invoice.CustomerID = tbl_customer_insurance.CustomerID

                                           AND tbl_invoice.CustomerInsurance4_ID = tbl_customer_insurance.ID)

    WHERE (tbl_invoicedetails.ID = P_InvoiceDetailsID); --



  ELSEIF P_SubmittedTo = 'Ins3' THEN

    INSERT INTO `tbl_invoice_transaction` (

      `InvoiceDetailsID`,

      `InvoiceID`,

      `CustomerID`,

      `InsuranceCompanyID`,

      `CustomerInsuranceID`,

      `TransactionTypeID`,

      `Amount`,

      `Quantity`,

      `TransactionDate`,

      `BatchNumber`,

      `Comments`,

      `LastUpdateUserID`)

    SELECT tbl_invoicedetails.ID as `InvoiceDetailsID`,

           tbl_invoicedetails.InvoiceID,

           tbl_invoicedetails.CustomerID,

           tbl_customer_insurance.InsuranceCompanyID,

           tbl_customer_insurance.ID as `CustomerInsuranceID`,

           V_TransactionTypeID,

           P_Amount,

           tbl_invoicedetails.Quantity,

           CURRENT_DATE() as `TransactionDate`,

           P_SubmittedBatch,

           Concat('Submitted by ', P_SubmittedBy) as `Comments`,

           P_LastUpdateUserID

    FROM ((tbl_invoicedetails

           INNER JOIN tbl_invoice ON tbl_invoicedetails.CustomerID = tbl_invoice.CustomerID

                                 AND tbl_invoicedetails.InvoiceID = tbl_invoice.ID)

          INNER JOIN tbl_customer_insurance ON tbl_invoice.CustomerID = tbl_customer_insurance.CustomerID

                                           AND tbl_invoice.CustomerInsurance3_ID = tbl_customer_insurance.ID)

    WHERE (tbl_invoicedetails.ID = P_InvoiceDetailsID); --



  ELSEIF P_SubmittedTo = 'Ins2' THEN

    INSERT INTO `tbl_invoice_transaction` (

      `InvoiceDetailsID`,

      `InvoiceID`,

      `CustomerID`,

      `InsuranceCompanyID`,

      `CustomerInsuranceID`,

      `TransactionTypeID`,

      `Amount`,

      `Quantity`,

      `TransactionDate`,

      `BatchNumber`,

      `Comments`,

      `LastUpdateUserID`)

    SELECT tbl_invoicedetails.ID as `InvoiceDetailsID`,

           tbl_invoicedetails.InvoiceID,

           tbl_invoicedetails.CustomerID,

           tbl_customer_insurance.InsuranceCompanyID,

           tbl_customer_insurance.ID as `CustomerInsuranceID`,

           V_TransactionTypeID,

           P_Amount,

           tbl_invoicedetails.Quantity,

           CURRENT_DATE() as `TransactionDate`,

           P_SubmittedBatch,

           Concat('Submitted by ', P_SubmittedBy) as `Comments`,

           P_LastUpdateUserID

    FROM ((tbl_invoicedetails

           INNER JOIN tbl_invoice ON tbl_invoicedetails.CustomerID = tbl_invoice.CustomerID

                                 AND tbl_invoicedetails.InvoiceID = tbl_invoice.ID)

          INNER JOIN tbl_customer_insurance ON tbl_invoice.CustomerID = tbl_customer_insurance.CustomerID

                                           AND tbl_invoice.CustomerInsurance2_ID = tbl_customer_insurance.ID)

    WHERE (tbl_invoicedetails.ID = P_InvoiceDetailsID); --



  ELSEIF P_SubmittedTo = 'Ins1' THEN

    INSERT INTO `tbl_invoice_transaction` (

      `InvoiceDetailsID`,

      `InvoiceID`,

      `CustomerID`,

      `InsuranceCompanyID`,

      `CustomerInsuranceID`,

      `TransactionTypeID`,

      `Amount`,

      `Quantity`,

      `TransactionDate`,

      `BatchNumber`,

      `Comments`,

      `LastUpdateUserID`)

    SELECT tbl_invoicedetails.ID as `InvoiceDetailsID`,

           tbl_invoicedetails.InvoiceID,

           tbl_invoicedetails.CustomerID,

           tbl_customer_insurance.InsuranceCompanyID,

           tbl_customer_insurance.ID as `CustomerInsuranceID`,

           V_TransactionTypeID,

           P_Amount,

           tbl_invoicedetails.Quantity,

           CURRENT_DATE() as `TransactionDate`,

           P_SubmittedBatch,

           Concat('Submitted by ', P_SubmittedBy) as `Comments`,

           P_LastUpdateUserID

    FROM ((tbl_invoicedetails

           INNER JOIN tbl_invoice ON tbl_invoicedetails.CustomerID = tbl_invoice.CustomerID

                                 AND tbl_invoicedetails.InvoiceID = tbl_invoice.ID)

          INNER JOIN tbl_customer_insurance ON tbl_invoice.CustomerID = tbl_customer_insurance.CustomerID

                                           AND tbl_invoice.CustomerInsurance1_ID = tbl_customer_insurance.ID)

    WHERE (tbl_invoicedetails.ID = P_InvoiceDetailsID); --



  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_InternalReflag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_InternalReflag`(P_InvoiceID TEXT, P_InvoiceDetailsID TEXT, P_LastUpdateUserID SMALLINT)
BEGIN

  DECLARE F_Insco_1 tinyint DEFAULT 01; --

  DECLARE F_Insco_2 tinyint DEFAULT 02; --

  DECLARE F_Insco_3 tinyint DEFAULT 04; --

  DECLARE F_Insco_4 tinyint DEFAULT 08; --

  DECLARE F_Patient tinyint DEFAULT 16; --



  DECLARE V_TransactionTypeID int DEFAULT 0; --

  DECLARE V_Username VARCHAR(50); --



  SET V_TransactionTypeID = NULL; --

  SELECT ID

  INTO V_TransactionTypeID

  FROM tbl_invoice_transactiontype

  WHERE (Name = 'Voided Submission'); --



  SET V_Username = ''; --

  SELECT Login

  INTO V_Username

  FROM tbl_user

  WHERE (ID = P_LastUpdateUserID); --



  INSERT INTO tbl_invoice_transaction

    (InvoiceDetailsID

    ,InvoiceID

    ,CustomerID

    ,InsuranceCompanyID

    ,CustomerInsuranceID

    ,TransactionTypeID

    ,Amount

    ,Quantity

    ,TransactionDate

    ,BatchNumber

    ,Comments

    ,LastUpdateUserID)

  SELECT

     InvoiceDetailsID

    ,InvoiceID

    ,CustomerID

    ,CASE CurrentPayer WHEN 'Patient' THEN null

                       WHEN 'Ins4'    THEN InsuranceCompany4_ID

                       WHEN 'Ins3'    THEN InsuranceCompany3_ID

                       WHEN 'Ins2'    THEN InsuranceCompany2_ID

                       WHEN 'Ins1'    THEN InsuranceCompany1_ID

                       ELSE null END as InsuranceCompanyID

    ,CASE CurrentPayer WHEN 'Patient' THEN null

                       WHEN 'Ins4'    THEN Insurance4_ID

                       WHEN 'Ins3'    THEN Insurance3_ID

                       WHEN 'Ins2'    THEN Insurance2_ID

                       WHEN 'Ins1'    THEN Insurance1_ID

                       ELSE null END as CustomerInsuranceID

    ,V_TransactionTypeID as TransactionTypeID

    ,BillableAmount

    ,Quantity

    ,CURRENT_DATE()

    ,null as BatchNumber

    ,Concat('Reflagged by ', V_Username) as Comments

    ,P_LastUpdateUserID as LastUpdateUserID

  FROM view_invoicetransaction_statistics

  WHERE ((0 < FIND_IN_SET(InvoiceID, P_InvoiceID)) OR (P_InvoiceID IS NULL) OR (P_InvoiceID = ''))

    AND ((0 < FIND_IN_SET(InvoiceDetailsID, P_InvoiceDetailsID)) OR (P_InvoiceDetailsID IS NULL) OR (P_InvoiceDetailsID = ''))

    AND ((CurrentPayer = 'Patient' AND Submits & F_Patient != 0) OR

         (CurrentPayer = 'Ins4'    AND Submits & F_Insco_4 != 0) OR

         (CurrentPayer = 'Ins3'    AND Submits & F_Insco_3 != 0) OR

         (CurrentPayer = 'Ins2'    AND Submits & F_Insco_2 != 0) OR

         (CurrentPayer = 'Ins1'    AND Submits & F_Insco_1 != 0)); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_InternalWriteoffBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_InternalWriteoffBalance`( P_InvoiceID TEXT

, P_InvoiceDetailsID TEXT

, P_LastUpdateUserID SMALLINT)
    MODIFIES SQL DATA
BEGIN

  INSERT INTO tbl_invoice_transaction (

    InvoiceDetailsID

  , InvoiceID

  , CustomerID

  , InsuranceCompanyID

  , CustomerInsuranceID

  , TransactionTypeID

  , TransactionDate

  , Amount

  , Quantity

  , Comments

  , Taxes

  , BatchNumber

  , Extra

  , Approved

  , LastUpdateUserID)

  SELECT

    det.ID as InvoiceDetailsID

  , det.InvoiceID

  , det.CustomerID

  , det.CurrentInsuranceCompanyID

  , det.CurrentCustomerInsuranceID

  , itt.ID as TransactionTypeID

  , NOW() as TransactionDate

  , det.Balance

  , det.Quantity

  , CONCAT('Wrote off by ', usr.Login) as Comments

  , 0.00 as Taxes

  , ''   as BatchNumber

  , null as Extra

  , 1    as Approved

  , P_LastUpdateUserID

  FROM tbl_invoicedetails as det

       INNER JOIN tbl_invoice_transactiontype as itt ON itt.Name = 'Writeoff'

       LEFT JOIN tbl_user as usr ON usr.ID = P_LastUpdateUserID

  WHERE ((0 < FIND_IN_SET(det.InvoiceID, P_InvoiceID)) OR (P_InvoiceID IS NULL) OR (P_InvoiceID = ''))

    AND ((0 < FIND_IN_SET(det.ID, P_InvoiceDetailsID)) OR (P_InvoiceDetailsID IS NULL) OR (P_InvoiceDetailsID = ''))

    AND (0.01 <= det.Balance); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_RecalculateInternals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_RecalculateInternals`(P_InvoiceID TEXT, P_InvoiceDetailsID TEXT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE

    V_PrevCustomerID,

    V_PrevInvoiceID,

    V_PrevDetailsID,

    cur_CustomerID,

    cur_InvoiceID,

    cur_DetailsID,

    cur_TranID INT; --

  -- cursor variables

  DECLARE

    cur_CustomerInsuranceID_1,

    cur_CustomerInsuranceID_2,

    cur_CustomerInsuranceID_3,

    cur_CustomerInsuranceID_4,

    cur_InsuranceCompanyID_1,

    cur_InsuranceCompanyID_2,

    cur_InsuranceCompanyID_3,

    cur_InsuranceCompanyID_4 INT; --

  DECLARE

    V_CustomerInsuranceID_1,

    V_CustomerInsuranceID_2,

    V_CustomerInsuranceID_3,

    V_CustomerInsuranceID_4,

    V_InsuranceCompanyID_1,

    V_InsuranceCompanyID_2,

    V_InsuranceCompanyID_3,

    V_InsuranceCompanyID_4 INT; --

  DECLARE

    cur_TranAmount,

    V_PaymentAmount_Insco_1,

    V_PaymentAmount_Insco_2,

    V_PaymentAmount_Insco_3,

    V_PaymentAmount_Insco_4,

    V_PaymentAmount_Patient,

    V_PaymentAmount,

    V_WriteoffAmount,

    V_DeductibleAmount decimal(18,2); --

  DECLARE

    cur_Percent int; --

  DECLARE

    cur_Basis VARCHAR(7); --

  DECLARE

    cur_TranType VARCHAR(50); --

  DECLARE

    cur_TranOwner,

    cur_Insurances,

    V_ProposedPayer, -- modified by 'Change Current Payee' transaction

    V_CurrentPayer,  -- used only to simplify evaluations

    V_Insurances,    -- insurances available for current line

    V_Pendings,

    V_Submits,

    V_ZeroPayments tinyint; --

  DECLARE

    cur_TranDate,

    V_SubmitDate_1,

    V_SubmitDate_2,

    V_SubmitDate_3,

    V_SubmitDate_4,

    V_SubmitDate_P DATE; --



  DECLARE F_Insco_1 tinyint DEFAULT 01; --

  DECLARE F_Insco_2 tinyint DEFAULT 02; --

  DECLARE F_Insco_3 tinyint DEFAULT 04; --

  DECLARE F_Insco_4 tinyint DEFAULT 08; --

  DECLARE F_Patient tinyint DEFAULT 16; --



  DECLARE cur CURSOR FOR

    SELECT

      `detail`.CustomerID,

      `detail`.InvoiceID,

      `detail`.ID as InvoiceDetailsID,

      `tran`.`ID` as TranID,

      `trantype`.`Name` as TranType,

      `tran`.`Amount` as TranAmount,

      `tran`.`TransactionDate` as TranDate,

      CASE WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance1_ID THEN F_Insco_1

           WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance2_ID THEN F_Insco_2

           WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance3_ID THEN F_Insco_3

           WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance4_ID THEN F_Insco_4

           WHEN `tran`.CustomerInsuranceID IS NULL                           THEN F_Patient

           ELSE 0 END AS TranOwner,

      IF((`insurance1`.ID IS NOT NULL) AND (`detail`.BillIns1 = 1) AND (`detail`.NopayIns1 = 0), F_Insco_1, 0) +

      IF((`insurance2`.ID IS NOT NULL) AND (`detail`.BillIns2 = 1), F_Insco_2, 0) +

      IF((`insurance3`.ID IS NOT NULL) AND (`detail`.BillIns3 = 1), F_Insco_3, 0) +

      IF((`insurance4`.ID IS NOT NULL) AND (`detail`.BillIns4 = 1), F_Insco_4, 0) as Insurances,

      `insurance1`.ID as CustomerInsuranceID_1,

      `insurance2`.ID as CustomerInsuranceID_2,

      `insurance3`.ID as CustomerInsuranceID_3,

      `insurance4`.ID as CustomerInsuranceID_4,

      `insurance1`.InsuranceCompanyID as InsuranceCompanyID_1,

      `insurance2`.InsuranceCompanyID as InsuranceCompanyID_2,

      `insurance3`.InsuranceCompanyID as InsuranceCompanyID_3,

      `insurance4`.InsuranceCompanyID as InsuranceCompanyID_4,

       CASE WHEN IFNULL(`insurance1`.PaymentPercent, 0) < 000 THEN 000

            WHEN 100 < IFNULL(`insurance1`.PaymentPercent, 0) THEN 100

            ELSE IFNULL(`insurance1`.PaymentPercent, 0) END as Percent,

       IFNULL(`insurance1`.Basis, 'Bill') as Basis

    FROM tbl_invoicedetails as `detail`

         INNER JOIN tbl_invoice as `invoice` ON `invoice`.CustomerID = `detail`.CustomerID

                                            AND `invoice`.ID         = `detail`.InvoiceID

         LEFT JOIN `tbl_customer_insurance` as `insurance1` ON `insurance1`.ID         = `invoice`.CustomerInsurance1_ID

                                                           AND `insurance1`.CustomerID = `invoice`.CustomerID

         LEFT JOIN `tbl_customer_insurance` as `insurance2` ON `insurance2`.ID         = `invoice`.CustomerInsurance2_ID

                                                           AND `insurance2`.CustomerID = `invoice`.CustomerID

         LEFT JOIN `tbl_customer_insurance` as `insurance3` ON `insurance3`.ID         = `invoice`.CustomerInsurance3_ID

                                                           AND `insurance3`.CustomerID = `invoice`.CustomerID

         LEFT JOIN `tbl_customer_insurance` as `insurance4` ON `insurance4`.ID         = `invoice`.CustomerInsurance4_ID

                                                           AND `insurance4`.CustomerID = `invoice`.CustomerID

         LEFT JOIN tbl_invoice_transaction as `tran` ON `tran`.InvoiceDetailsID = `detail`.ID

                                                    AND `tran`.InvoiceID        = `detail`.InvoiceID

                                                    AND `tran`.CustomerID       = `detail`.CustomerID

         LEFT JOIN tbl_invoice_transactiontype as `trantype` ON `trantype`.ID = `tran`.TransactionTypeID

  WHERE CASE

        WHEN (P_InvoiceID        IS NOT NULL) THEN 0 < FIND_IN_SET(`invoice`.ID, P_InvoiceID)

        WHEN (P_InvoiceDetailsID IS NOT NULL) THEN 0 < FIND_IN_SET(`detail`.ID, P_InvoiceDetailsID)

        ELSE 1 END

  ORDER BY `detail`.CustomerID, `detail`.InvoiceID, `detail`.ID, `tran`.`ID`; --



  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  SET V_PrevCustomerID = null; --

  SET V_PrevInvoiceID  = null; --

  SET V_PrevDetailsID  = null; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

      cur_CustomerID,

      cur_InvoiceID,

      cur_DetailsID,

      cur_TranID,

      cur_TranType,

      cur_TranAmount,

      cur_TranDate,

      cur_TranOwner,

      cur_Insurances,

      cur_CustomerInsuranceID_1,

      cur_CustomerInsuranceID_2,

      cur_CustomerInsuranceID_3,

      cur_CustomerInsuranceID_4,

      cur_InsuranceCompanyID_1,

      cur_InsuranceCompanyID_2,

      cur_InsuranceCompanyID_3,

      cur_InsuranceCompanyID_4,

      cur_Percent,

      cur_Basis; --



    IF (done != 0)

    OR (V_PrevCustomerID IS NULL) OR (cur_CustomerID != V_PrevCustomerID)

    OR (V_PrevInvoiceID  IS NULL) OR (cur_InvoiceID  != V_PrevInvoiceID)

    OR (V_PrevDetailsID  IS NULL) OR (cur_DetailsID  != V_PrevDetailsID)

    THEN

      IF  (V_PrevCustomerID IS NOT NULL)

      AND (V_PrevInvoiceID  IS NOT NULL)

      AND (V_PrevDetailsID  IS NOT NULL)

      THEN

        -- we must allow changing payer regardless of the payments (zero payments and total amount paid)

        SET V_CurrentPayer

          = CASE WHEN (V_ProposedPayer = F_Insco_1) THEN F_Insco_1

                 WHEN (V_ProposedPayer = F_Insco_2) THEN F_Insco_2

                 WHEN (V_ProposedPayer = F_Insco_3) THEN F_Insco_3

                 WHEN (V_ProposedPayer = F_Insco_4) THEN F_Insco_4

                 WHEN (V_ProposedPayer = F_Patient) THEN F_Patient

                 WHEN (V_Insurances & F_Insco_1 != 0) AND (V_PaymentAmount_Insco_1 < 0.01) AND (V_ZeroPayments & F_Insco_1 = 0) THEN F_Insco_1

                 WHEN (V_Insurances & F_Insco_2 != 0) AND (V_PaymentAmount_Insco_2 < 0.01) AND (V_ZeroPayments & F_Insco_2 = 0) THEN F_Insco_2

                 WHEN (V_Insurances & F_Insco_3 != 0) AND (V_PaymentAmount_Insco_3 < 0.01) AND (V_ZeroPayments & F_Insco_3 = 0) THEN F_Insco_3

                 WHEN (V_Insurances & F_Insco_4 != 0) AND (V_PaymentAmount_Insco_4 < 0.01) AND (V_ZeroPayments & F_Insco_4 = 0) THEN F_Insco_4

                 ELSE F_Patient END; -- we should never switch from patient - somebody must pay --



        -- save into db

        UPDATE tbl_invoicedetails

        SET Balance = BillableAmount - V_PaymentAmount - V_WriteoffAmount,

            PaymentAmount  = V_PaymentAmount,

            WriteoffAmount = V_WriteoffAmount,

            DeductibleAmount = V_DeductibleAmount,

            CurrentPayer

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN 'None'

                     WHEN V_CurrentPayer = F_Insco_1 THEN 'Ins1'

                     WHEN V_CurrentPayer = F_Insco_2 THEN 'Ins2'

                     WHEN V_CurrentPayer = F_Insco_3 THEN 'Ins3'

                     WHEN V_CurrentPayer = F_Insco_4 THEN 'Ins4'

                     WHEN V_CurrentPayer = F_Patient THEN 'Patient'

                     ELSE 'None' END,

            SubmittedDate

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN null

                     WHEN V_CurrentPayer = F_Insco_1 THEN V_SubmitDate_1

                     WHEN V_CurrentPayer = F_Insco_2 THEN V_SubmitDate_2

                     WHEN V_CurrentPayer = F_Insco_3 THEN V_SubmitDate_3

                     WHEN V_CurrentPayer = F_Insco_4 THEN V_SubmitDate_4

                     WHEN V_CurrentPayer = F_Patient THEN V_SubmitDate_P

                     ELSE null END,

            Submitted

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN 1

                     WHEN V_CurrentPayer = F_Insco_1 THEN IF(V_SubmitDate_1 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Insco_2 THEN IF(V_SubmitDate_2 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Insco_3 THEN IF(V_SubmitDate_3 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Insco_4 THEN IF(V_SubmitDate_4 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Patient THEN IF(V_SubmitDate_P IS NOT NULL, 1, 0)

                     ELSE 1 END,

            CurrentInsuranceCompanyID

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN null

                     WHEN V_CurrentPayer = F_Insco_1 THEN V_InsuranceCompanyID_1

                     WHEN V_CurrentPayer = F_Insco_2 THEN V_InsuranceCompanyID_2

                     WHEN V_CurrentPayer = F_Insco_3 THEN V_InsuranceCompanyID_3

                     WHEN V_CurrentPayer = F_Insco_4 THEN V_InsuranceCompanyID_4

                     WHEN V_CurrentPayer = F_Patient THEN null

                     ELSE null END,

            CurrentCustomerInsuranceID

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN null

                     WHEN V_CurrentPayer = F_Insco_1 THEN V_CustomerInsuranceID_1

                     WHEN V_CurrentPayer = F_Insco_2 THEN V_CustomerInsuranceID_2

                     WHEN V_CurrentPayer = F_Insco_3 THEN V_CustomerInsuranceID_3

                     WHEN V_CurrentPayer = F_Insco_4 THEN V_CustomerInsuranceID_4

                     WHEN V_CurrentPayer = F_Patient THEN null

                     ELSE null END,

            -- for debugging

            Pendings    = V_Pendings,

            Submits     = V_Submits,

            Payments

              = CASE WHEN 0.01 <= V_PaymentAmount_Insco_1 OR V_ZeroPayments & F_Insco_1 != 0 THEN F_Insco_1 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Insco_2 OR V_ZeroPayments & F_Insco_2 != 0 THEN F_Insco_2 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Insco_3 OR V_ZeroPayments & F_Insco_3 != 0 THEN F_Insco_3 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Insco_4 OR V_ZeroPayments & F_Insco_4 != 0 THEN F_Insco_4 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Patient THEN F_Patient ELSE 0 END

        WHERE (CustomerID = V_PrevCustomerID) AND (InvoiceID = V_PrevInvoiceID) AND (ID = V_PrevDetailsID); --

      END IF; --



      -- init / reinit

      SET V_PrevCustomerID = cur_CustomerID; --

      SET V_PrevInvoiceID  = cur_InvoiceID; --

      SET V_PrevDetailsID  = cur_DetailsID; --



      SET V_PaymentAmount_Insco_1 = 0.0; --

      SET V_PaymentAmount_Insco_2 = 0.0; --

      SET V_PaymentAmount_Insco_3 = 0.0; --

      SET V_PaymentAmount_Insco_4 = 0.0; --

      SET V_PaymentAmount_Patient = 0.0; --

      SET V_PaymentAmount  = 0.0; --

      SET V_WriteoffAmount = 0.0; --

      SET V_DeductibleAmount = 0.0; --

      SET V_ProposedPayer = null; --

      SET V_Insurances = cur_Insurances; -- snapshot of insurances available for current line

      SET V_Pendings = 0; --

      SET V_Submits  = 0; --

      SET V_ZeroPayments = 0; --

      SET V_SubmitDate_1 = null; --

      SET V_SubmitDate_2 = null; --

      SET V_SubmitDate_3 = null; --

      SET V_SubmitDate_4 = null; --

      SET V_SubmitDate_P = null; --

      SET V_InsuranceCompanyID_1 = cur_InsuranceCompanyID_1; --

      SET V_InsuranceCompanyID_2 = cur_InsuranceCompanyID_2; --

      SET V_InsuranceCompanyID_3 = cur_InsuranceCompanyID_3; --

      SET V_InsuranceCompanyID_4 = cur_InsuranceCompanyID_4; --

      SET V_CustomerInsuranceID_1 = cur_CustomerInsuranceID_1; --

      SET V_CustomerInsuranceID_2 = cur_CustomerInsuranceID_2; --

      SET V_CustomerInsuranceID_3 = cur_CustomerInsuranceID_3; --

      SET V_CustomerInsuranceID_4 = cur_CustomerInsuranceID_4; --

    END IF; --



    IF (done = 0)

    AND (cur_TranID IS NOT NULL)

    THEN

      -- Only 'Payment' and 'Change Current Payee' changes current payer

      IF (cur_TranType = 'Contractual Writeoff') OR (cur_TranType = 'Writeoff') THEN

        SET V_WriteoffAmount = V_WriteoffAmount + IFNULL(cur_TranAmount, 0); --



      ELSEIF (cur_TranType = 'Submit') OR (cur_TranType = 'Auto Submit') THEN

        SET V_Submits = V_Submits | cur_TranOwner; --

        IF     (cur_TranOwner = F_Insco_1) THEN

          SET V_SubmitDate_1 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Insco_2) THEN

          SET V_SubmitDate_2 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Insco_3) THEN

          SET V_SubmitDate_3 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Insco_4) THEN

          SET V_SubmitDate_4 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Patient) THEN

          SET V_SubmitDate_P = cur_TranDate; --

        END IF; --



      ELSEIF (cur_TranType = 'Voided Submission') THEN

        SET V_Submits = V_Submits & ~cur_TranOwner; --

        IF     (cur_TranOwner = F_Insco_1) THEN

          SET V_SubmitDate_1 = null; --

        ELSEIF (cur_TranOwner = F_Insco_2) THEN

          SET V_SubmitDate_2 = null; --

        ELSEIF (cur_TranOwner = F_Insco_3) THEN

          SET V_SubmitDate_3 = null; --

        ELSEIF (cur_TranOwner = F_Insco_4) THEN

          SET V_SubmitDate_4 = null; --

        ELSEIF (cur_TranOwner = F_Patient) THEN

          SET V_SubmitDate_P = null; --

        END IF; --



      ELSEIF (cur_TranType = 'Pending Submission') THEN

        SET V_Pendings = V_Pendings | cur_TranOwner; --



      ELSEIF (cur_TranType = 'Change Current Payee') THEN

        IF (cur_TranOwner = F_Insco_1 and V_Insurances & F_Insco_1 != 0)

        OR (cur_TranOwner = F_Insco_2 and V_Insurances & F_Insco_2 != 0)

        OR (cur_TranOwner = F_Insco_3 and V_Insurances & F_Insco_3 != 0)

        OR (cur_TranOwner = F_Insco_4 and V_Insurances & F_Insco_4 != 0)

        OR (cur_TranOwner = F_Patient)

        THEN

          -- "Change Current Payee" transaction changes responsibility unconditionally

          SET V_ProposedPayer = cur_TranOwner; --

        END IF; --



      ELSEIF (cur_TranType = 'Payment') THEN

        IF (ABS(cur_TranAmount) < 0.01) THEN

          SET V_ZeroPayments = V_ZeroPayments | cur_TranOwner; --

        ELSE

          SET V_ZeroPayments = V_ZeroPayments & ~cur_TranOwner; --

        END IF; --



        IF (cur_TranOwner = F_Insco_1) THEN

          SET V_PaymentAmount_Insco_1 = V_PaymentAmount_Insco_1 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Insco_2) THEN

          SET V_PaymentAmount_Insco_2 = V_PaymentAmount_Insco_2 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Insco_3) THEN

          SET V_PaymentAmount_Insco_3 = V_PaymentAmount_Insco_3 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Insco_4) THEN

          SET V_PaymentAmount_Insco_4 = V_PaymentAmount_Insco_4 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Patient) THEN

          SET V_PaymentAmount_Patient = V_PaymentAmount_Patient + cur_TranAmount; --

        END IF; --



        SET V_PaymentAmount = V_PaymentAmount + cur_TranAmount; --



        IF (cur_TranOwner = V_ProposedPayer)

        AND (0.00 <= cur_TranAmount) THEN

          -- "Payment" transaction (with positive or zero amount) advances responsibility to next payer

          SET V_ProposedPayer = null; --

        END IF; --



      ELSEIF (cur_TranType = 'Deductible') THEN

        -- I guess we should use deductible amount of first insurance only

        IF (cur_TranOwner = F_Insco_1) THEN

          SET V_DeductibleAmount = IFNULL(cur_TranAmount, 0.0); --

        END IF; --



      END IF; --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_RecalculateInternals_Single` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_RecalculateInternals_Single`(P_InvoiceID INT, P_InvoiceDetailsID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE

    V_PrevCustomerID,

    V_PrevInvoiceID,

    V_PrevDetailsID,

    cur_CustomerID,

    cur_InvoiceID,

    cur_DetailsID,

    cur_TranID INT; --

  -- cursor variables

  DECLARE

    cur_CustomerInsuranceID_1,

    cur_CustomerInsuranceID_2,

    cur_CustomerInsuranceID_3,

    cur_CustomerInsuranceID_4,

    cur_InsuranceCompanyID_1,

    cur_InsuranceCompanyID_2,

    cur_InsuranceCompanyID_3,

    cur_InsuranceCompanyID_4 INT; --

  DECLARE

    V_CustomerInsuranceID_1,

    V_CustomerInsuranceID_2,

    V_CustomerInsuranceID_3,

    V_CustomerInsuranceID_4,

    V_InsuranceCompanyID_1,

    V_InsuranceCompanyID_2,

    V_InsuranceCompanyID_3,

    V_InsuranceCompanyID_4 INT; --

  DECLARE

    cur_TranAmount,

    V_PaymentAmount_Insco_1,

    V_PaymentAmount_Insco_2,

    V_PaymentAmount_Insco_3,

    V_PaymentAmount_Insco_4,

    V_PaymentAmount_Patient,

    V_PaymentAmount,

    V_WriteoffAmount,

    V_DeductibleAmount decimal(18,2); --

  DECLARE

    cur_Percent int; --

  DECLARE

    cur_Basis VARCHAR(7); --

  DECLARE

    cur_TranType VARCHAR(50); --

  DECLARE

    cur_TranOwner,

    cur_Insurances,

    V_ProposedPayer, -- modified by 'Change Current Payee' transaction

    V_CurrentPayer,  -- used only to simplify evaluations

    V_Insurances,    -- insurances available for current line

    V_Pendings,

    V_Submits,

    V_ZeroPayments tinyint; --

  DECLARE

    cur_TranDate,

    V_SubmitDate_1,

    V_SubmitDate_2,

    V_SubmitDate_3,

    V_SubmitDate_4,

    V_SubmitDate_P DATE; --



  DECLARE F_Insco_1 tinyint DEFAULT 01; --

  DECLARE F_Insco_2 tinyint DEFAULT 02; --

  DECLARE F_Insco_3 tinyint DEFAULT 04; --

  DECLARE F_Insco_4 tinyint DEFAULT 08; --

  DECLARE F_Patient tinyint DEFAULT 16; --



  DECLARE cur CURSOR FOR

    SELECT

      `detail`.CustomerID,

      `detail`.InvoiceID,

      `detail`.ID as InvoiceDetailsID,

      `tran`.`ID` as TranID,

      `trantype`.`Name` as TranType,

      `tran`.`Amount` as TranAmount,

      `tran`.`TransactionDate` as TranDate,

      CASE WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance1_ID THEN F_Insco_1

           WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance2_ID THEN F_Insco_2

           WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance3_ID THEN F_Insco_3

           WHEN `tran`.CustomerInsuranceID = `invoice`.CustomerInsurance4_ID THEN F_Insco_4

           WHEN `tran`.CustomerInsuranceID IS NULL                           THEN F_Patient

           ELSE 0 END AS TranOwner,

      IF((`insurance1`.ID IS NOT NULL) AND (`detail`.BillIns1 = 1) AND (`detail`.NopayIns1 = 0), F_Insco_1, 0) +

      IF((`insurance2`.ID IS NOT NULL) AND (`detail`.BillIns2 = 1), F_Insco_2, 0) +

      IF((`insurance3`.ID IS NOT NULL) AND (`detail`.BillIns3 = 1), F_Insco_3, 0) +

      IF((`insurance4`.ID IS NOT NULL) AND (`detail`.BillIns4 = 1), F_Insco_4, 0) as Insurances,

      `insurance1`.ID as CustomerInsuranceID_1,

      `insurance2`.ID as CustomerInsuranceID_2,

      `insurance3`.ID as CustomerInsuranceID_3,

      `insurance4`.ID as CustomerInsuranceID_4,

      `insurance1`.InsuranceCompanyID as InsuranceCompanyID_1,

      `insurance2`.InsuranceCompanyID as InsuranceCompanyID_2,

      `insurance3`.InsuranceCompanyID as InsuranceCompanyID_3,

      `insurance4`.InsuranceCompanyID as InsuranceCompanyID_4,

       CASE WHEN IFNULL(`insurance1`.PaymentPercent, 0) < 000 THEN 000

            WHEN 100 < IFNULL(`insurance1`.PaymentPercent, 0) THEN 100

            ELSE IFNULL(`insurance1`.PaymentPercent, 0) END as Percent,

       IFNULL(`insurance1`.Basis, 'Bill') as Basis

    FROM tbl_invoicedetails as `detail`

         INNER JOIN tbl_invoice as `invoice` ON `invoice`.CustomerID = `detail`.CustomerID

                                            AND `invoice`.ID         = `detail`.InvoiceID

         LEFT JOIN `tbl_customer_insurance` as `insurance1` ON `insurance1`.ID         = `invoice`.CustomerInsurance1_ID

                                                           AND `insurance1`.CustomerID = `invoice`.CustomerID

         LEFT JOIN `tbl_customer_insurance` as `insurance2` ON `insurance2`.ID         = `invoice`.CustomerInsurance2_ID

                                                           AND `insurance2`.CustomerID = `invoice`.CustomerID

         LEFT JOIN `tbl_customer_insurance` as `insurance3` ON `insurance3`.ID         = `invoice`.CustomerInsurance3_ID

                                                           AND `insurance3`.CustomerID = `invoice`.CustomerID

         LEFT JOIN `tbl_customer_insurance` as `insurance4` ON `insurance4`.ID         = `invoice`.CustomerInsurance4_ID

                                                           AND `insurance4`.CustomerID = `invoice`.CustomerID

         LEFT JOIN tbl_invoice_transaction as `tran` ON `tran`.InvoiceDetailsID = `detail`.ID

                                                    AND `tran`.InvoiceID        = `detail`.InvoiceID

                                                    AND `tran`.CustomerID       = `detail`.CustomerID

         LEFT JOIN tbl_invoice_transactiontype as `trantype` ON `trantype`.ID = `tran`.TransactionTypeID

  WHERE ((P_InvoiceID        IS NULL) OR (`invoice`.ID = P_InvoiceID       ))

    AND ((P_InvoiceDetailsID IS NULL) OR (`detail`.ID  = P_InvoiceDetailsID))

  ORDER BY `detail`.CustomerID, `detail`.InvoiceID, `detail`.ID, `tran`.`ID`; --



  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  SET V_PrevCustomerID = null; --

  SET V_PrevInvoiceID  = null; --

  SET V_PrevDetailsID  = null; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

      cur_CustomerID,

      cur_InvoiceID,

      cur_DetailsID,

      cur_TranID,

      cur_TranType,

      cur_TranAmount,

      cur_TranDate,

      cur_TranOwner,

      cur_Insurances,

      cur_CustomerInsuranceID_1,

      cur_CustomerInsuranceID_2,

      cur_CustomerInsuranceID_3,

      cur_CustomerInsuranceID_4,

      cur_InsuranceCompanyID_1,

      cur_InsuranceCompanyID_2,

      cur_InsuranceCompanyID_3,

      cur_InsuranceCompanyID_4,

      cur_Percent,

      cur_Basis; --



    IF (done != 0)

    OR (V_PrevCustomerID IS NULL) OR (cur_CustomerID != V_PrevCustomerID)

    OR (V_PrevInvoiceID  IS NULL) OR (cur_InvoiceID  != V_PrevInvoiceID)

    OR (V_PrevDetailsID  IS NULL) OR (cur_DetailsID  != V_PrevDetailsID)

    THEN

      IF  (V_PrevCustomerID IS NOT NULL)

      AND (V_PrevInvoiceID  IS NOT NULL)

      AND (V_PrevDetailsID  IS NOT NULL)

      THEN

        -- we must allow changing payer regardless of the payments (zero payments and total amount paid)

        SET V_CurrentPayer

          = CASE WHEN (V_ProposedPayer = F_Insco_1) THEN F_Insco_1

                 WHEN (V_ProposedPayer = F_Insco_2) THEN F_Insco_2

                 WHEN (V_ProposedPayer = F_Insco_3) THEN F_Insco_3

                 WHEN (V_ProposedPayer = F_Insco_4) THEN F_Insco_4

                 WHEN (V_ProposedPayer = F_Patient) THEN F_Patient

                 WHEN (V_Insurances & F_Insco_1 != 0) AND (V_PaymentAmount_Insco_1 < 0.01) AND (V_ZeroPayments & F_Insco_1 = 0) THEN F_Insco_1

                 WHEN (V_Insurances & F_Insco_2 != 0) AND (V_PaymentAmount_Insco_2 < 0.01) AND (V_ZeroPayments & F_Insco_2 = 0) THEN F_Insco_2

                 WHEN (V_Insurances & F_Insco_3 != 0) AND (V_PaymentAmount_Insco_3 < 0.01) AND (V_ZeroPayments & F_Insco_3 = 0) THEN F_Insco_3

                 WHEN (V_Insurances & F_Insco_4 != 0) AND (V_PaymentAmount_Insco_4 < 0.01) AND (V_ZeroPayments & F_Insco_4 = 0) THEN F_Insco_4

                 ELSE F_Patient END; -- we should never switch from patient - somebody must pay --



        -- save into db

        UPDATE tbl_invoicedetails

        SET Balance = BillableAmount - V_PaymentAmount - V_WriteoffAmount,

            PaymentAmount  = V_PaymentAmount,

            WriteoffAmount = V_WriteoffAmount,

            DeductibleAmount = V_DeductibleAmount,

            CurrentPayer

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN 'None'

                     WHEN V_CurrentPayer = F_Insco_1 THEN 'Ins1'

                     WHEN V_CurrentPayer = F_Insco_2 THEN 'Ins2'

                     WHEN V_CurrentPayer = F_Insco_3 THEN 'Ins3'

                     WHEN V_CurrentPayer = F_Insco_4 THEN 'Ins4'

                     WHEN V_CurrentPayer = F_Patient THEN 'Patient'

                     ELSE 'None' END,

            SubmittedDate

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN null

                     WHEN V_CurrentPayer = F_Insco_1 THEN V_SubmitDate_1

                     WHEN V_CurrentPayer = F_Insco_2 THEN V_SubmitDate_2

                     WHEN V_CurrentPayer = F_Insco_3 THEN V_SubmitDate_3

                     WHEN V_CurrentPayer = F_Insco_4 THEN V_SubmitDate_4

                     WHEN V_CurrentPayer = F_Patient THEN V_SubmitDate_P

                     ELSE null END,

            Submitted

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN 1

                     WHEN V_CurrentPayer = F_Insco_1 THEN IF(V_SubmitDate_1 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Insco_2 THEN IF(V_SubmitDate_2 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Insco_3 THEN IF(V_SubmitDate_3 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Insco_4 THEN IF(V_SubmitDate_4 IS NOT NULL, 1, 0)

                     WHEN V_CurrentPayer = F_Patient THEN IF(V_SubmitDate_P IS NOT NULL, 1, 0)

                     ELSE 1 END,

            CurrentInsuranceCompanyID

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN null

                     WHEN V_CurrentPayer = F_Insco_1 THEN V_InsuranceCompanyID_1

                     WHEN V_CurrentPayer = F_Insco_2 THEN V_InsuranceCompanyID_2

                     WHEN V_CurrentPayer = F_Insco_3 THEN V_InsuranceCompanyID_3

                     WHEN V_CurrentPayer = F_Insco_4 THEN V_InsuranceCompanyID_4

                     WHEN V_CurrentPayer = F_Patient THEN null

                     ELSE null END,

            CurrentCustomerInsuranceID

              = CASE WHEN BillableAmount - V_PaymentAmount - V_WriteoffAmount < 0.01 THEN null

                     WHEN V_CurrentPayer = F_Insco_1 THEN V_CustomerInsuranceID_1

                     WHEN V_CurrentPayer = F_Insco_2 THEN V_CustomerInsuranceID_2

                     WHEN V_CurrentPayer = F_Insco_3 THEN V_CustomerInsuranceID_3

                     WHEN V_CurrentPayer = F_Insco_4 THEN V_CustomerInsuranceID_4

                     WHEN V_CurrentPayer = F_Patient THEN null

                     ELSE null END,

            -- for debugging

            Pendings    = V_Pendings,

            Submits     = V_Submits,

            Payments

              = CASE WHEN 0.01 <= V_PaymentAmount_Insco_1 OR V_ZeroPayments & F_Insco_1 != 0 THEN F_Insco_1 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Insco_2 OR V_ZeroPayments & F_Insco_2 != 0 THEN F_Insco_2 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Insco_3 OR V_ZeroPayments & F_Insco_3 != 0 THEN F_Insco_3 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Insco_4 OR V_ZeroPayments & F_Insco_4 != 0 THEN F_Insco_4 ELSE 0 END

              + CASE WHEN 0.01 <= V_PaymentAmount_Patient THEN F_Patient ELSE 0 END

        WHERE (CustomerID = V_PrevCustomerID) AND (InvoiceID = V_PrevInvoiceID) AND (ID = V_PrevDetailsID); --

      END IF; --



      -- init / reinit

      SET V_PrevCustomerID = cur_CustomerID; --

      SET V_PrevInvoiceID  = cur_InvoiceID; --

      SET V_PrevDetailsID  = cur_DetailsID; --



      SET V_PaymentAmount_Insco_1 = 0.0; --

      SET V_PaymentAmount_Insco_2 = 0.0; --

      SET V_PaymentAmount_Insco_3 = 0.0; --

      SET V_PaymentAmount_Insco_4 = 0.0; --

      SET V_PaymentAmount_Patient = 0.0; --

      SET V_PaymentAmount  = 0.0; --

      SET V_WriteoffAmount = 0.0; --

      SET V_DeductibleAmount = 0.0; --

      SET V_ProposedPayer = null; --

      SET V_Insurances = cur_Insurances; -- snapshot of insurances available for current line

      SET V_Pendings = 0; --

      SET V_Submits  = 0; --

      SET V_ZeroPayments = 0; --

      SET V_SubmitDate_1 = null; --

      SET V_SubmitDate_2 = null; --

      SET V_SubmitDate_3 = null; --

      SET V_SubmitDate_4 = null; --

      SET V_SubmitDate_P = null; --

      SET V_InsuranceCompanyID_1 = cur_InsuranceCompanyID_1; --

      SET V_InsuranceCompanyID_2 = cur_InsuranceCompanyID_2; --

      SET V_InsuranceCompanyID_3 = cur_InsuranceCompanyID_3; --

      SET V_InsuranceCompanyID_4 = cur_InsuranceCompanyID_4; --

      SET V_CustomerInsuranceID_1 = cur_CustomerInsuranceID_1; --

      SET V_CustomerInsuranceID_2 = cur_CustomerInsuranceID_2; --

      SET V_CustomerInsuranceID_3 = cur_CustomerInsuranceID_3; --

      SET V_CustomerInsuranceID_4 = cur_CustomerInsuranceID_4; --

    END IF; --



    IF (done = 0)

    AND (cur_TranID IS NOT NULL)

    THEN

      -- Only 'Payment' and 'Change Current Payee' changes current payer

      IF (cur_TranType = 'Contractual Writeoff') OR (cur_TranType = 'Writeoff') THEN

        SET V_WriteoffAmount = V_WriteoffAmount + IFNULL(cur_TranAmount, 0); --



      ELSEIF (cur_TranType = 'Submit') OR (cur_TranType = 'Auto Submit') THEN

        SET V_Submits = V_Submits | cur_TranOwner; --

        IF     (cur_TranOwner = F_Insco_1) THEN

          SET V_SubmitDate_1 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Insco_2) THEN

          SET V_SubmitDate_2 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Insco_3) THEN

          SET V_SubmitDate_3 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Insco_4) THEN

          SET V_SubmitDate_4 = cur_TranDate; --

        ELSEIF (cur_TranOwner = F_Patient) THEN

          SET V_SubmitDate_P = cur_TranDate; --

        END IF; --



      ELSEIF (cur_TranType = 'Voided Submission') THEN

        SET V_Submits = V_Submits & ~cur_TranOwner; --

        IF     (cur_TranOwner = F_Insco_1) THEN

          SET V_SubmitDate_1 = null; --

        ELSEIF (cur_TranOwner = F_Insco_2) THEN

          SET V_SubmitDate_2 = null; --

        ELSEIF (cur_TranOwner = F_Insco_3) THEN

          SET V_SubmitDate_3 = null; --

        ELSEIF (cur_TranOwner = F_Insco_4) THEN

          SET V_SubmitDate_4 = null; --

        ELSEIF (cur_TranOwner = F_Patient) THEN

          SET V_SubmitDate_P = null; --

        END IF; --



      ELSEIF (cur_TranType = 'Pending Submission') THEN

        SET V_Pendings = V_Pendings | cur_TranOwner; --



      ELSEIF (cur_TranType = 'Change Current Payee') THEN

        IF (cur_TranOwner = F_Insco_1 and V_Insurances & F_Insco_1 != 0)

        OR (cur_TranOwner = F_Insco_2 and V_Insurances & F_Insco_2 != 0)

        OR (cur_TranOwner = F_Insco_3 and V_Insurances & F_Insco_3 != 0)

        OR (cur_TranOwner = F_Insco_4 and V_Insurances & F_Insco_4 != 0)

        OR (cur_TranOwner = F_Patient)

        THEN

          -- "Change Current Payee" transaction changes responsibility unconditionally

          SET V_ProposedPayer = cur_TranOwner; --

        END IF; --



      ELSEIF (cur_TranType = 'Payment') THEN

        IF (ABS(cur_TranAmount) < 0.01) THEN

          SET V_ZeroPayments = V_ZeroPayments | cur_TranOwner; --

        ELSE

          SET V_ZeroPayments = V_ZeroPayments & ~cur_TranOwner; --

        END IF; --



        IF (cur_TranOwner = F_Insco_1) THEN

          SET V_PaymentAmount_Insco_1 = V_PaymentAmount_Insco_1 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Insco_2) THEN

          SET V_PaymentAmount_Insco_2 = V_PaymentAmount_Insco_2 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Insco_3) THEN

          SET V_PaymentAmount_Insco_3 = V_PaymentAmount_Insco_3 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Insco_4) THEN

          SET V_PaymentAmount_Insco_4 = V_PaymentAmount_Insco_4 + cur_TranAmount; --

        ELSEIF (cur_TranOwner = F_Patient) THEN

          SET V_PaymentAmount_Patient = V_PaymentAmount_Patient + cur_TranAmount; --

        END IF; --



        SET V_PaymentAmount = V_PaymentAmount + cur_TranAmount; --



        IF (cur_TranOwner = V_ProposedPayer)

        AND (0.00 <= cur_TranAmount) THEN

          -- "Payment" transaction (with positive or zero amount) advances responsibility to next payer

          SET V_ProposedPayer = null; --

        END IF; --



      ELSEIF (cur_TranType = 'Deductible') THEN

        -- I guess we should use deductible amount of first insurance only

        IF (cur_TranOwner = F_Insco_1) THEN

          SET V_DeductibleAmount = IFNULL(cur_TranAmount, 0.0); --

        END IF; --



      END IF; --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_Reflag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_Reflag`(P_InvoiceID TEXT, P_InvoiceDetailsID TEXT, P_LastUpdateUserID SMALLINT)
BEGIN

  CALL InvoiceDetails_RecalculateInternals(P_InvoiceID, P_InvoiceDetailsID); --

  CALL InvoiceDetails_InternalReflag      (P_InvoiceID, P_InvoiceDetailsID, P_LastUpdateUserID); --

  CALL InvoiceDetails_RecalculateInternals(P_InvoiceID, P_InvoiceDetailsID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InvoiceDetails_WriteoffBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InvoiceDetails_WriteoffBalance`( P_InvoiceID TEXT

, P_InvoiceDetailsID TEXT

, P_LastUpdateUserID SMALLINT)
BEGIN

  CALL InvoiceDetails_RecalculateInternals   (P_InvoiceID, P_InvoiceDetailsID); --

  CALL InvoiceDetails_InternalWriteoffBalance(P_InvoiceID, P_InvoiceDetailsID, P_LastUpdateUserID); --

  CALL InvoiceDetails_RecalculateInternals   (P_InvoiceID, P_InvoiceDetailsID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_AddAutoSubmit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_AddAutoSubmit`(

  P_InvoiceID INT,

  P_AutoSubmittedTo VARCHAR(5),

  P_LastUpdateUserID smallint)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE V_InvoiceDetailsID INT; --

  DECLARE V_Result VARCHAR(50); --

  DECLARE cur CURSOR FOR SELECT ID FROM tbl_invoicedetails WHERE (InvoiceID = P_InvoiceID); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, null); --



  OPEN cur; --



  REPEAT

    FETCH cur INTO V_InvoiceDetailsID; --

    IF NOT done THEN

      CALL InvoiceDetails_InternalAddAutoSubmit(V_InvoiceDetailsID, P_AutoSubmittedTo, P_LastUpdateUserID, V_Result); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --



  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, null); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_AddSubmitted` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_AddSubmitted`(

  P_InvoiceID INT,

  P_SubmittedTo VARCHAR(50),

  P_SubmittedBy VARCHAR(50),

  P_SubmittedBatch VARCHAR(50),

  P_LastUpdateUserID smallint)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE V_InvoiceDetailsID INT; --

  DECLARE cur CURSOR FOR SELECT ID FROM tbl_invoicedetails WHERE (InvoiceID = P_InvoiceID) AND (CurrentPayer = P_SubmittedTo); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, null); --



  OPEN cur; --



  REPEAT

    FETCH cur INTO V_InvoiceDetailsID; --

    IF NOT done THEN

      CALL InvoiceDetails_AddSubmitted(V_InvoiceDetailsID, 0.00, P_SubmittedTo, P_SubmittedBy, P_SubmittedBatch, P_LastUpdateUserID); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --



  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, null); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_InternalReflag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_InternalReflag`(P_InvoiceID INT, P_Extra TEXT, P_LastUpdateUserID SMALLINT)
BEGIN

  DECLARE F_Insco_1 tinyint DEFAULT 01; --

  DECLARE F_Insco_2 tinyint DEFAULT 02; --

  DECLARE F_Insco_3 tinyint DEFAULT 04; --

  DECLARE F_Insco_4 tinyint DEFAULT 08; --

  DECLARE F_Patient tinyint DEFAULT 16; --



  DECLARE V_TransactionTypeID int DEFAULT 0; --

  DECLARE V_Username VARCHAR(50); --



  SET V_TransactionTypeID = NULL; --

  SELECT ID

  INTO V_TransactionTypeID

  FROM tbl_invoice_transactiontype

  WHERE (Name = 'Voided Submission'); --



  SET V_Username = ''; --

  SELECT Login

  INTO V_Username

  FROM tbl_user

  WHERE (ID = P_LastUpdateUserID); --



  IF P_Extra NOT LIKE '<values>%</values>'

  AND P_Extra NOT LIKE '<values%/>'

  THEN

    SET P_Extra = NULL; --

  END IF; --



  INSERT INTO tbl_invoice_transaction

  ( InvoiceDetailsID

  , InvoiceID

  , CustomerID

  , InsuranceCompanyID

  , CustomerInsuranceID

  , TransactionTypeID

  , Amount

  , Quantity

  , TransactionDate

  , BatchNumber

  , Comments

  , Extra

  , LastUpdateUserID)

  SELECT

    InvoiceDetailsID

  , InvoiceID

  , CustomerID

  , CASE CurrentPayer WHEN 'Patient' THEN null

                      WHEN 'Ins4'    THEN InsuranceCompany4_ID

                      WHEN 'Ins3'    THEN InsuranceCompany3_ID

                      WHEN 'Ins2'    THEN InsuranceCompany2_ID

                      WHEN 'Ins1'    THEN InsuranceCompany1_ID

                      ELSE null END as InsuranceCompanyID

  , CASE CurrentPayer WHEN 'Patient' THEN null

                      WHEN 'Ins4'    THEN Insurance4_ID

                      WHEN 'Ins3'    THEN Insurance3_ID

                      WHEN 'Ins2'    THEN Insurance2_ID

                      WHEN 'Ins1'    THEN Insurance1_ID

                      ELSE null END as CustomerInsuranceID

  , V_TransactionTypeID as TransactionTypeID

  , BillableAmount

  , Quantity

  , CURRENT_DATE()

  , null as BatchNumber

  , Concat('Reflagged by ', V_Username) as Comments

  , P_Extra

  , P_LastUpdateUserID as LastUpdateUserID

  FROM view_invoicetransaction_statistics

  WHERE (InvoiceID = P_InvoiceID)

    AND ((CurrentPayer = 'Patient' AND Submits & F_Patient != 0) OR

         (CurrentPayer = 'Ins4'    AND Submits & F_Insco_4 != 0) OR

         (CurrentPayer = 'Ins3'    AND Submits & F_Insco_3 != 0) OR

         (CurrentPayer = 'Ins2'    AND Submits & F_Insco_2 != 0) OR

         (CurrentPayer = 'Ins1'    AND Submits & F_Insco_1 != 0)); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_InternalUpdateBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_InternalUpdateBalance`(P_InvoiceID INT)
BEGIN

  UPDATE tbl_invoice as i

  LEFT JOIN (SELECT tbl_invoicedetails.InvoiceID, Sum(tbl_invoicedetails.Balance) as Balance

             FROM tbl_invoice

                  INNER JOIN tbl_invoicedetails ON tbl_invoicedetails.CustomerID = tbl_invoice.CustomerID

                                               AND tbl_invoicedetails.InvoiceID  = tbl_invoice.ID

             WHERE (tbl_invoice.ID = P_InvoiceID)

             GROUP BY tbl_invoicedetails.InvoiceID) as b

         ON b.InvoiceID = i.ID

  SET i.InvoiceBalance = IFNULL(b.Balance, 0)

  WHERE (i.ID = P_InvoiceID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_InternalUpdatePendingSubmissions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_InternalUpdatePendingSubmissions`(P_InvoiceID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE

    V_CustomerID,

    V_InvoiceID,

    V_InvoiceDetailsID,

    V_Insurance1_ID,

    V_Insurance2_ID,

    V_Insurance3_ID,

    V_Insurance4_ID,

    V_Company1_ID,

    V_Company2_ID,

    V_Company3_ID,

    V_Company4_ID,

    V_Insurances,

    V_PendingSubmissions,

    V_Payments INT; --

  DECLARE

    V_CurrentPayer VARCHAR(10); --

  DECLARE

    V_PendingSubmissionID,

    V_WriteoffID INT; --

  DECLARE

    V_PaymentAmount,

    V_WriteoffAmount,

    V_BillableAmount DECIMAL(18, 2); --

  DECLARE

    V_Quantity DOUBLE; --

  DECLARE

    V_Hardship TINYINT(1); --

  DECLARE cur CURSOR FOR

    SELECT

      CustomerID,

      InvoiceID,

      InvoiceDetailsID,

      PaymentAmount,

      WriteoffAmount,

      BillableAmount,

      IFNULL(Quantity, 0.0) as Quantity,

      Insurance1_ID,

      Insurance2_ID,

      Insurance3_ID,

      Insurance4_ID,

      InsuranceCompany1_ID,

      InsuranceCompany2_ID,

      InsuranceCompany3_ID,

      InsuranceCompany4_ID,

      Insurances,

      PendingSubmissions,

      Payments,

      CurrentPayer

  FROM view_invoicetransaction_statistics

  WHERE (InvoiceID = P_InvoiceID) OR (P_InvoiceID IS NULL); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  SET V_PendingSubmissionID = NULL; --



  SELECT ID

  INTO V_PendingSubmissionID

  FROM tbl_invoice_transactiontype

  WHERE (Name = 'Pending Submission'); --



  SET V_WriteoffID = NULL; --



  SELECT ID

  INTO V_WriteoffID

  FROM tbl_invoice_transactiontype

  WHERE (Name = 'Writeoff'); --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

      V_CustomerID,

      V_InvoiceID,

      V_InvoiceDetailsID,

      V_PaymentAmount,

      V_WriteoffAmount,

      V_BillableAmount,

      V_Quantity,

      V_Insurance1_ID,

      V_Insurance2_ID,

      V_Insurance3_ID,

      V_Insurance4_ID,

      V_Company1_ID,

      V_Company2_ID,

      V_Company3_ID,

      V_Company4_ID,

      V_Insurances,

      V_PendingSubmissions,

      V_Payments,

      V_CurrentPayer; --



    IF NOT done THEN

      IF (V_CurrentPayer = 'Ins1') AND (V_Insurance1_ID IS NOT NULL) AND (V_PendingSubmissions & 01 = 00) THEN -- first insurance requires billing but do not have 'pending submission'

        INSERT INTO `tbl_invoice_transaction`

          (`InvoiceDetailsID`, `InvoiceID`, `CustomerID`, `InsuranceCompanyID`, `CustomerInsuranceID`, `TransactionTypeID`, `TransactionDate`, `Comments`, `Amount`, `Quantity`)

        VALUES

          (V_InvoiceDetailsID, V_InvoiceID, V_CustomerID,        V_Company1_ID,       V_Insurance1_ID, V_PendingSubmissionID,    CURRENT_DATE(), 'Ins1',

           V_BillableAmount, V_Quantity); --



      ELSEIF (V_CurrentPayer = 'Ins2') AND (V_Insurance2_ID IS NOT NULL) AND (V_PendingSubmissions & 02 = 00) THEN -- second insurance requires billing but do not have 'pending submission'

        INSERT INTO `tbl_invoice_transaction`

          (`InvoiceDetailsID`, `InvoiceID`, `CustomerID`, `InsuranceCompanyID`, `CustomerInsuranceID`, `TransactionTypeID`, `TransactionDate`, `Comments`, `Amount`, `Quantity`)

        VALUES

          (V_InvoiceDetailsID, V_InvoiceID, V_CustomerID,        V_Company2_ID,       V_Insurance2_ID, V_PendingSubmissionID,    CURRENT_DATE(), 'Ins2',

           V_BillableAmount - V_PaymentAmount - V_WriteoffAmount, V_Quantity); --



      ELSEIF (V_CurrentPayer = 'Ins3') AND (V_Insurance3_ID IS NOT NULL) AND (V_PendingSubmissions & 04 = 00) THEN -- third insurance requires billing but do not have 'pending submission'

        INSERT INTO `tbl_invoice_transaction`

          (`InvoiceDetailsID`, `InvoiceID`, `CustomerID`, `InsuranceCompanyID`, `CustomerInsuranceID`, `TransactionTypeID`, `TransactionDate`, `Comments`, `Amount`, `Quantity`)

        VALUES

          (V_InvoiceDetailsID, V_InvoiceID, V_CustomerID,        V_Company3_ID,       V_Insurance3_ID, V_PendingSubmissionID,    CURRENT_DATE(), 'Ins3',

           V_BillableAmount - V_PaymentAmount - V_WriteoffAmount, V_Quantity); --



      ELSEIF (V_CurrentPayer = 'Ins4') AND (V_Insurance4_ID IS NOT NULL) AND (V_PendingSubmissions & 08 = 00) THEN -- fourth insurance requires billing but do not have 'pending submission'

        INSERT INTO `tbl_invoice_transaction`

          (`InvoiceDetailsID`, `InvoiceID`, `CustomerID`, `InsuranceCompanyID`, `CustomerInsuranceID`, `TransactionTypeID`, `TransactionDate`, `Comments`, `Amount`, `Quantity`)

        VALUES

          (V_InvoiceDetailsID, V_InvoiceID, V_CustomerID,        V_Company4_ID,       V_Insurance4_ID, V_PendingSubmissionID,    CURRENT_DATE(), 'Ins4',

           V_BillableAmount - V_PaymentAmount - V_WriteoffAmount, V_Quantity); --



      ELSEIF (V_CurrentPayer = 'Patient') AND (V_PendingSubmissions & 16 = 00) THEN -- patient requires billing but do not have 'pending submission'

        INSERT INTO `tbl_invoice_transaction`

          (`InvoiceDetailsID`, `InvoiceID`, `CustomerID`, `InsuranceCompanyID`, `CustomerInsuranceID`, `TransactionTypeID`, `TransactionDate`, `Comments`, `Amount`, `Quantity`)

        VALUES

          (V_InvoiceDetailsID, V_InvoiceID, V_CustomerID,                 null,                  null, V_PendingSubmissionID,    CURRENT_DATE(), 'Patient',

           V_BillableAmount - V_PaymentAmount - V_WriteoffAmount, V_Quantity); --



      END IF; --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_Reflag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_Reflag`(P_InvoiceID INT, P_Extra TEXT, P_LastUpdateUserID SMALLINT)
BEGIN

  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, NULL); --

  CALL Invoice_InternalReflag                    (P_InvoiceID, P_Extra, P_LastUpdateUserID); --

  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, NULL); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_UpdateBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_UpdateBalance`(P_InvoiceID INT, P_Recursive BOOL)
BEGIN

  IF P_Recursive THEN

    CALL `InvoiceDetails_RecalculateInternals_Single`(P_InvoiceID, null); --

  END IF; --



  CALL `Invoice_InternalUpdateBalance`(P_InvoiceID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Invoice_UpdatePendingSubmissions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Invoice_UpdatePendingSubmissions`(P_InvoiceID INT)
BEGIN

  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, null); --

  CALL Invoice_InternalUpdatePendingSubmissions  (P_InvoiceID); --

  CALL InvoiceDetails_RecalculateInternals_Single(P_InvoiceID, null); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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

  CALL mir_update_facility(null); --

  CALL mir_update_insurancecompany(null); --

  CALL mir_update_customer_insurance(null); --

  CALL mir_update_doctor(null); --

  CALL mir_update_customer(null); --

  CALL mir_update_cmnform(null); --

  CALL mir_update_orderdetails('ActiveOnly'); --

  CALL mir_update_order('ActiveOnly'); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_cmnform` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_cmnform`(P_CMNFormID INT)
BEGIN

  UPDATE tbl_cmnform

         LEFT JOIN tbl_customer as tbl_customer ON tbl_cmnform.CustomerID = tbl_customer.ID

         LEFT JOIN tbl_doctor   as tbl_doctor   ON tbl_cmnform.DoctorID   = tbl_doctor  .ID

         LEFT JOIN tbl_facility as tbl_facility ON tbl_cmnform.FacilityID = tbl_facility.ID

  SET tbl_cmnform.`MIR` =

      CONCAT_WS(',',

          IF(IFNULL(tbl_cmnform.CMNType              , '') = '', 'CMNType'              , null),

          IF(IFNULL(tbl_cmnform.Signature_Name       , '') = '', 'Signature_Name'       , null),

          IF(tbl_cmnform.InitialDate    is null, 'InitialDate'   , null),

          IF(tbl_cmnform.POSTypeID      is null, 'POSTypeID'     , null),

          IF(tbl_cmnform.Signature_Date is null, 'Signature_Date', null),

          CASE WHEN tbl_cmnform.EstimatedLengthOfNeed is null THEN 'EstimatedLengthOfNeed'

               WHEN tbl_cmnform.EstimatedLengthOfNeed <= 0    THEN 'EstimatedLengthOfNeed'

               ELSE null END,

          IF(tbl_customer.ID IS NULL, 'CustomerID', null),

          IF(tbl_customer.MIR != '' , 'Customer'  , null),

          IF(tbl_doctor  .ID IS NULL, 'DoctorID'  , null),

          IF(tbl_doctor  .MIR != '' , 'Doctor'    , null))

  WHERE (tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_icd9 as icd_1 ON tbl_cmnform.Customer_ICD9_1 = icd_1.Code

         LEFT JOIN tbl_icd9 as icd_2 ON tbl_cmnform.Customer_ICD9_2 = icd_2.Code

         LEFT JOIN tbl_icd9 as icd_3 ON tbl_cmnform.Customer_ICD9_3 = icd_3.Code

         LEFT JOIN tbl_icd9 as icd_4 ON tbl_cmnform.Customer_ICD9_4 = icd_4.Code

  SET tbl_cmnform.`MIR` =

      CONCAT_WS(',',

          tbl_cmnform.`MIR`,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_1, '') = ''  THEN 'ICD9_1.Required'

               WHEN icd_1.Code is null                            THEN 'ICD9_1.Unknown'

               WHEN icd_1.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_1.Inactive'

               ELSE null END,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_2, '') = ''  THEN null

               WHEN icd_2.Code is null                            THEN 'ICD9_2.Unknown'

               WHEN icd_2.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_2.Inactive'

               ELSE null END,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_3, '') = ''  THEN null

               WHEN icd_3.Code is null                            THEN 'ICD9_3.Unknown'

               WHEN icd_3.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_3.Inactive'

               ELSE null END,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_4, '') = ''  THEN null

               WHEN icd_4.Code is null                            THEN 'ICD9_4.Unknown'

               WHEN icd_4.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_4.Inactive'

               ELSE null END)

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.Customer_UsingICD10 != 1 OR tbl_cmnform.Customer_UsingICD10 IS NULL); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_icd10 as icd_1 ON tbl_cmnform.Customer_ICD9_1 = icd_1.Code

         LEFT JOIN tbl_icd10 as icd_2 ON tbl_cmnform.Customer_ICD9_2 = icd_2.Code

         LEFT JOIN tbl_icd10 as icd_3 ON tbl_cmnform.Customer_ICD9_3 = icd_3.Code

         LEFT JOIN tbl_icd10 as icd_4 ON tbl_cmnform.Customer_ICD9_4 = icd_4.Code

  SET tbl_cmnform.`MIR` =

      CONCAT_WS(',',

          tbl_cmnform.`MIR`,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_1, '') = ''  THEN 'ICD9_1.Required'

               WHEN icd_1.Code is null                            THEN 'ICD9_1.Unknown'

               WHEN icd_1.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_1.Inactive'

               ELSE null END,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_2, '') = ''  THEN null

               WHEN icd_2.Code is null                            THEN 'ICD9_2.Unknown'

               WHEN icd_2.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_2.Inactive'

               ELSE null END,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_3, '') = ''  THEN null

               WHEN icd_3.Code is null                            THEN 'ICD9_3.Unknown'

               WHEN icd_3.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_3.Inactive'

               ELSE null END,

          CASE WHEN IFNULL(tbl_cmnform.Customer_ICD9_4, '') = ''  THEN null

               WHEN icd_4.Code is null                            THEN 'ICD9_4.Unknown'

               WHEN icd_4.InactiveDate <= tbl_cmnform.InitialDate THEN 'ICD9_4.Inactive'

               ELSE null END)

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.Customer_UsingICD10 = 1); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0102a ON tbl_cmnform.ID = tbl_cmnform_0102a.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 01.02A')

    AND (IFNULL(tbl_cmnform_0102a.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102a.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102a.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102a.Answer5, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102a.Answer6, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102a.Answer7, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0102b ON tbl_cmnform.ID = tbl_cmnform_0102b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 01.02B')

    AND (IFNULL(tbl_cmnform_0102b.Answer12, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer13, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer14, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer15, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer16, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer19, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer20, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0102b.Answer22, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0203a ON tbl_cmnform.ID = tbl_cmnform_0203a.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 02.03A')

    AND (IFNULL(tbl_cmnform_0203a.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203a.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203a.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203a.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203a.Answer6, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203a.Answer7, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0203b ON tbl_cmnform.ID = tbl_cmnform_0203b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 02.03B')

    AND (IFNULL(tbl_cmnform_0203b.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203b.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203b.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203b.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203b.Answer8, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0203b.Answer9, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0302 ON tbl_cmnform.ID = tbl_cmnform_0302.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 03.02')

    AND (IFNULL(tbl_cmnform_0302.Answer14, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0403b ON tbl_cmnform.ID = tbl_cmnform_0403b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 04.03B')

    AND (IFNULL(tbl_cmnform_0403b.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403b.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403b.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403b.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403b.Answer5, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0403c ON tbl_cmnform.ID = tbl_cmnform_0403c.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 04.03C')

    AND (IFNULL(tbl_cmnform_0403c.Answer6a , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403c.Answer7a , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403c.Answer8  , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403c.Answer9a , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403c.Answer10a, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0403c.Answer11a, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0602b ON tbl_cmnform.ID = tbl_cmnform_0602b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 06.02B')

    AND (IFNULL(tbl_cmnform_0602b.Answer1 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0602b.Answer3 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0602b.Answer6 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0602b.Answer7 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0602b.Answer11, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0702a ON tbl_cmnform.ID = tbl_cmnform_0702a.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 07.02A')

    AND (IFNULL(tbl_cmnform_0702a.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702a.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702a.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702a.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702a.Answer5, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0702b ON tbl_cmnform.ID = tbl_cmnform_0702b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 07.02B')

    AND (IFNULL(tbl_cmnform_0702b.Answer6 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702b.Answer7 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702b.Answer8 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702b.Answer12, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702b.Answer13, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0702b.Answer14, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0902 ON tbl_cmnform.ID = tbl_cmnform_0902.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 09.02')

    AND (IFNULL(tbl_cmnform_0902.Answer7, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_1002a ON tbl_cmnform.ID = tbl_cmnform_1002a.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 10.02A')

    AND (IFNULL(tbl_cmnform_1002a.Answer1, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_1002b ON tbl_cmnform.ID = tbl_cmnform_1002b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 10.02B')

    AND (IFNULL(tbl_cmnform_1002b.Answer7 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_1002b.Answer8 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_1002b.Answer14, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_4842 ON tbl_cmnform.ID = tbl_cmnform_4842.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DMERC 484.2')

    AND (IFNULL(tbl_cmnform_4842.Answer2 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_4842.Answer5 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_4842.Answer8 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_4842.Answer9 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_4842.Answer10, '') != 'Y'); --



  -- new forms



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0404b ON tbl_cmnform.ID = tbl_cmnform_0404b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DME 04.04B')

    AND (IFNULL(tbl_cmnform_0404b.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404b.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404b.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404b.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404b.Answer5, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0404c ON tbl_cmnform.ID = tbl_cmnform_0404c.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DME 04.04C')

    AND (IFNULL(tbl_cmnform_0404c.Answer6  , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404c.Answer7a , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404c.Answer8  , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404c.Answer9a , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404c.Answer10a, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404c.Answer11 , '') != 'Y')

    AND (IFNULL(tbl_cmnform_0404c.Answer12 , '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0603b ON tbl_cmnform.ID = tbl_cmnform_0603b.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DME 06.03B')

    AND (IFNULL(tbl_cmnform_0603b.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0603b.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0603b.Answer5, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_0703a ON tbl_cmnform.ID = tbl_cmnform_0703a.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DME 07.03A')

    AND (IFNULL(tbl_cmnform_0703a.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0703a.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0703a.Answer3, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0703a.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_0703a.Answer5, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_1003 ON tbl_cmnform.ID = tbl_cmnform_1003.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DME 10.03')

    AND (IFNULL(tbl_cmnform_1003.Answer1, '') != 'Y')

    AND (IFNULL(tbl_cmnform_1003.Answer2, '') != 'Y')

    AND (IFNULL(tbl_cmnform_1003.Answer7, '') != 'Y'); --



  UPDATE tbl_cmnform

         LEFT JOIN tbl_cmnform_48403 ON tbl_cmnform.ID = tbl_cmnform_48403.CMNFormID

  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

    AND (tbl_cmnform.CMNType = 'DME 484.03')

    AND ((tbl_cmnform_48403.Answer1a is null) OR

         (tbl_cmnform_48403.Answer1b is null) OR

         (IFNULL(tbl_cmnform_48403.Answer1c, '0000-00-00') = '0000-00-00'))

    AND (IFNULL(tbl_cmnform_48403.Answer2, '')  = '')

    AND (IFNULL(tbl_cmnform_48403.Answer3, '')  = '')

    AND (IFNULL(tbl_cmnform_48403.Answer4, '') != 'Y')

    AND (IFNULL(tbl_cmnform_48403.Answer7, '') != 'Y')

    AND (IFNULL(tbl_cmnform_48403.Answer8, '') != 'Y')

    AND (IFNULL(tbl_cmnform_48403.Answer9, '') != 'Y'); --



--  `Answer1a` int(11) default NULL,

--  `Answer1b` int(11) default NULL,

--  `Answer1c` date default NULL,

--  `Answer2` enum('1','2','3') NOT NULL default '1',

--  `Answer3` enum('1','2','3') NOT NULL default '1',

--  `Answer4` enum('Y','N','D') NOT NULL default 'D',

--  `Answer5` varchar(10) default NULL,

--  `Answer6a` int(11) default NULL,

--  `Answer6b` int(11) default NULL,

--  `Answer6c` date default NULL,

--  `Answer7` enum('Y','N') NOT NULL default 'Y',

--  `Answer8` enum('Y','N') NOT NULL default 'Y',

--  `Answer9` enum('Y','N') NOT NULL default 'Y',



--  UPDATE tbl_cmnform

--         LEFT JOIN tbl_cmnform_drorder ON tbl_cmnform.ID = tbl_cmnform_drorder.CMNFormID

--  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

--  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

--    AND (tbl_cmnform.CMNType = 'DMERC DRORDER')

--    AND  (1 != 1); --



--  UPDATE tbl_cmnform

--         LEFT JOIN tbl_cmnform_uro ON tbl_cmnform.ID = tbl_cmnform_uro.CMNFormID

--  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

--  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

--    AND (tbl_cmnform.CMNType = 'DMERC URO')

--    AND  (1 != 1); --



--  UPDATE tbl_cmnform

--         LEFT JOIN tbl_cmnform_0903 ON tbl_cmnform.ID = tbl_cmnform_0903.CMNFormID

--  SET tbl_cmnform.MIR = CONCAT_WS(',', 'Answers', IF(tbl_cmnform.MIR != '', tbl_cmnform.MIR, null))

--  WHERE ((tbl_cmnform.ID = P_CMNFormID) OR (P_CMNFormID IS NULL))

--    AND (tbl_cmnform.CMNType = 'DME 09.03')

--    AND (1 != 1); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_customer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_customer`(P_CustomerID INT)
BEGIN

  UPDATE tbl_customer

         LEFT JOIN tbl_doctor ON tbl_customer.Doctor1_ID = tbl_doctor.ID

  SET tbl_customer.`MIR` =

      IF(tbl_customer.CommercialAccount = 0

        ,CONCAT_WS(','

                  ,IF(IFNULL(tbl_customer.AccountNumber   , '') = '', 'AccountNumber'   , null)

                  ,IF(IFNULL(tbl_customer.FirstName       , '') = '', 'FirstName'       , null)

                  ,IF(IFNULL(tbl_customer.LastName        , '') = '', 'LastName'        , null)

                  ,IF(IFNULL(tbl_customer.Address1        , '') = '', 'Address1'        , null)

                  ,IF(IFNULL(tbl_customer.City            , '') = '', 'City'            , null)

                  ,IF(IFNULL(tbl_customer.State           , '') = '', 'State'           , null)

                  ,IF(IFNULL(tbl_customer.Zip             , '') = '', 'Zip'             , null)

                  ,IF(IFNULL(tbl_customer.EmploymentStatus, '') = '', 'EmploymentStatus', null)

                  ,IF(IFNULL(tbl_customer.Gender          , '') = '', 'Gender'          , null)

                  ,IF(IFNULL(tbl_customer.MaritalStatus   , '') = '', 'MaritalStatus'   , null)

                  ,IF(IFNULL(tbl_customer.MilitaryBranch  , '') = '', 'MilitaryBranch'  , null)

                  ,IF(IFNULL(tbl_customer.MilitaryStatus  , '') = '', 'MilitaryStatus'  , null)

                  ,IF(IFNULL(tbl_customer.StudentStatus   , '') = '', 'StudentStatus'   , null)

                  ,IF(IFNULL(tbl_customer.MonthsValid     ,  0) =  0, 'MonthsValid'     , null)

                  ,IF(tbl_customer.DateofBirth     IS NULL, 'DateofBirth'    , null)

                  ,IF(tbl_customer.SignatureOnFile IS NULL, 'SignatureOnFile', null)

                  ,IF(tbl_doctor.ID IS NULL, 'Doctor1_ID', null)

                  ,IF(tbl_doctor.MIR != '' , 'Doctor1'   , null)

                  )

        ,'')

  WHERE (tbl_customer.ID = P_CustomerID) OR (P_CustomerID IS NULL); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_customer_insurance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_customer_insurance`(P_CustomerID INT)
BEGIN

  UPDATE tbl_customer_insurance as policy

         LEFT JOIN tbl_customer ON policy.CustomerID = tbl_customer.ID

         LEFT JOIN tbl_insurancecompany ON policy.InsuranceCompanyID = tbl_insurancecompany.ID

  SET policy.`MIR` =

      IF(tbl_customer.CommercialAccount = 0

        ,CONCAT_WS(','

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.FirstName, '') = ''), 'FirstName'  , null)

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.LastName , '') = ''), 'LastName'   , null)

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.Address1 , '') = ''), 'Address1'   , null)

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.City     , '') = ''), 'City'       , null)

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.State    , '') = ''), 'State'      , null)

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.Zip      , '') = ''), 'Zip'        , null)

                  ,IF((policy.RelationshipCode != '18') AND (IFNULL(policy.Gender   , '') = ''), 'Gender'     , null)

                  ,IF((policy.RelationshipCode != '18') AND (policy.DateofBirth IS NULL       ), 'DateofBirth', null)

                  ,IF(IFNULL(policy.InsuranceType   , '') = '', 'InsuranceType'   , null)

                  ,IF(IFNULL(policy.PolicyNumber    , '') = '', 'PolicyNumber'    , null)

                  ,IF(IFNULL(policy.RelationshipCode, '') = '', 'RelationshipCode', null)

                  ,IF(tbl_insurancecompany.ID IS NULL, 'InsuranceCompanyID', null)

                  ,IF(tbl_insurancecompany.MIR != '' , 'InsuranceCompany'  , null)

                  )

        ,'')

  WHERE (policy.CustomerID = P_CustomerID) OR (P_CustomerID IS NULL); --

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

  CALL `dmeworks`.`mir_update_doctor`(P_DoctorID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_facility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_facility`(P_FacilityID INT)
BEGIN

  UPDATE tbl_facility

  SET `MIR` =

      CONCAT_WS(',',

          IF(IFNULL(Name      , '') = '', 'Name'      , null),

          IF(IFNULL(Address1  , '') = '', 'Address1'  , null),

          IF(IFNULL(City      , '') = '', 'City'      , null),

          IF(IFNULL(State     , '') = '', 'State'     , null),

          IF(IFNULL(Zip       , '') = '', 'Zip'       , null),

          IF(IFNULL(POSTypeID , '') = '', 'POSTypeID' , null),

          IF(NPI REGEXP '[[:digit:]]{10}[[:blank:]]*', null, 'NPI')

               )

  WHERE (ID = P_FacilityID) OR (P_FacilityID IS NULL); --

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

  CALL `dmeworks`.`mir_update_insurancecompany`(P_InsuranceCompanyID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_order` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_order`(P_OrderID varchar(10))
BEGIN

  DECLARE V_OrderID INT; --

  DECLARE V_ActiveOnly BIT; --



  -- P_OrderID

  -- 'ActiveOnly' - all orders that have details with State != 'Closed'

  -- number - just one

  -- all details regardless of state



  IF (P_OrderID = 'ActiveOnly') THEN

    SET V_OrderID = null; --

    SET V_ActiveOnly = 1; --

  ELSEIF (P_OrderID REGEXP '^(\\-|\\+){0,1}([0-9]+)$') THEN

    SET V_OrderID = CAST(P_OrderID as signed); --

    SET V_ActiveOnly = 0; --

  ELSE

    SET V_OrderID = null; --

    SET V_ActiveOnly = 0; --

  END IF; --



  IF (V_OrderID IS NOT NULL) THEN

    UPDATE tbl_order

    SET `MIR` =

      CONCAT_WS(','

      ,IF(CustomerID   IS NULL, 'CustomerID'  , null)

      ,IF(DeliveryDate IS NULL, 'DeliveryDate', null)

      ,IF(BillDate     IS NULL, 'BillDate'    , null)

      )

    WHERE (ID = V_OrderID); --

  ELSEIF (V_ActiveOnly != 1) THEN

    UPDATE tbl_order

    SET `MIR` =

      CONCAT_WS(','

      ,IF(CustomerID   IS NULL, 'CustomerID'  , null)

      ,IF(DeliveryDate IS NULL, 'DeliveryDate', null)

      ,IF(BillDate     IS NULL, 'BillDate'    , null)

      ); --

  ELSE

    UPDATE tbl_order as o

    INNER JOIN

           (SELECT DISTINCT CustomerID, OrderID

            FROM view_orderdetails

            WHERE (IsActive = 1)

           ) as d on d.CustomerID = o.CustomerID and d.OrderID = o.ID

    SET o.`MIR` =

      CONCAT_WS(','

      ,IF(o.CustomerID   IS NULL, 'CustomerID'  , null)

      ,IF(o.DeliveryDate IS NULL, 'DeliveryDate', null)

      ,IF(o.BillDate     IS NULL, 'BillDate'    , null)

      ); --

  END IF; --



  UPDATE tbl_order as o

  INNER JOIN

         (SELECT CustomerID, OrderID

          , SUM(0 < FIND_IN_SET('Customer.Inactive', `MIR.ORDER`)) AS `Customer.Inactive`

          , SUM(0 < FIND_IN_SET('Customer.MIR'     , `MIR.ORDER`)) AS `Customer.MIR`

          , SUM(0 < FIND_IN_SET('Policy1.Required' , `MIR.ORDER`)) AS `Policy1.Required`

          , SUM(0 < FIND_IN_SET('Policy1.MIR'      , `MIR.ORDER`)) AS `Policy1.MIR`

          , SUM(0 < FIND_IN_SET('Policy2.Required' , `MIR.ORDER`)) AS `Policy2.Required`

          , SUM(0 < FIND_IN_SET('Policy2.MIR'      , `MIR.ORDER`)) AS `Policy2.MIR`

          , SUM(0 < FIND_IN_SET('Facility.MIR'     , `MIR.ORDER`)) AS `Facility.MIR`

          , SUM(0 < FIND_IN_SET('PosType.Required' , `MIR.ORDER`)) AS `PosType.Required`

          , SUM(0 < FIND_IN_SET('ICD9.Required'    , `MIR.ORDER`)) AS `ICD9.Required`

          , SUM(0 < FIND_IN_SET('ICD9.1.Unknown'   , `MIR.ORDER`)) AS `ICD9.1.Unknown`

          , SUM(0 < FIND_IN_SET('ICD9.1.Inactive'  , `MIR.ORDER`)) AS `ICD9.1.Inactive`

          , SUM(0 < FIND_IN_SET('ICD9.2.Unknown'   , `MIR.ORDER`)) AS `ICD9.2.Unknown`

          , SUM(0 < FIND_IN_SET('ICD9.2.Inactive'  , `MIR.ORDER`)) AS `ICD9.2.Inactive`

          , SUM(0 < FIND_IN_SET('ICD9.3.Unknown'   , `MIR.ORDER`)) AS `ICD9.3.Unknown`

          , SUM(0 < FIND_IN_SET('ICD9.3.Inactive'  , `MIR.ORDER`)) AS `ICD9.3.Inactive`

          , SUM(0 < FIND_IN_SET('ICD9.4.Unknown'   , `MIR.ORDER`)) AS `ICD9.4.Unknown`

          , SUM(0 < FIND_IN_SET('ICD9.4.Inactive'  , `MIR.ORDER`)) AS `ICD9.4.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.Required'   , `MIR.ORDER`)) AS `ICD10.Required`

          , SUM(0 < FIND_IN_SET('ICD10.01.Unknown' , `MIR.ORDER`)) AS `ICD10.01.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.01.Inactive', `MIR.ORDER`)) AS `ICD10.01.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.02.Unknown' , `MIR.ORDER`)) AS `ICD10.02.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.02.Inactive', `MIR.ORDER`)) AS `ICD10.02.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.03.Unknown' , `MIR.ORDER`)) AS `ICD10.03.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.03.Inactive', `MIR.ORDER`)) AS `ICD10.03.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.04.Unknown' , `MIR.ORDER`)) AS `ICD10.04.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.04.Inactive', `MIR.ORDER`)) AS `ICD10.04.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.05.Unknown' , `MIR.ORDER`)) AS `ICD10.05.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.05.Inactive', `MIR.ORDER`)) AS `ICD10.05.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.06.Unknown' , `MIR.ORDER`)) AS `ICD10.06.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.06.Inactive', `MIR.ORDER`)) AS `ICD10.06.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.07.Unknown' , `MIR.ORDER`)) AS `ICD10.07.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.07.Inactive', `MIR.ORDER`)) AS `ICD10.07.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.08.Unknown' , `MIR.ORDER`)) AS `ICD10.08.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.08.Inactive', `MIR.ORDER`)) AS `ICD10.08.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.09.Unknown' , `MIR.ORDER`)) AS `ICD10.09.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.09.Inactive', `MIR.ORDER`)) AS `ICD10.09.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.10.Unknown' , `MIR.ORDER`)) AS `ICD10.10.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.10.Inactive', `MIR.ORDER`)) AS `ICD10.10.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.11.Unknown' , `MIR.ORDER`)) AS `ICD10.11.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.11.Inactive', `MIR.ORDER`)) AS `ICD10.11.Inactive`

          , SUM(0 < FIND_IN_SET('ICD10.12.Unknown' , `MIR.ORDER`)) AS `ICD10.12.Unknown`

          , SUM(0 < FIND_IN_SET('ICD10.12.Inactive', `MIR.ORDER`)) AS `ICD10.12.Inactive`

          FROM view_orderdetails

          WHERE IF(V_OrderID IS NOT NULL, OrderID = V_OrderID, V_ActiveOnly != 1 or IsActive = 1)

            AND (0 < FIND_IN_SET('Customer.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('Customer.MIR'     , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('Policy1.Required' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('Policy1.MIR'      , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('Policy2.Required' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('Policy2.MIR'      , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('Facility.MIR'     , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('PosType.Required' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.Required'    , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.1.Unknown'   , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.1.Inactive'  , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.2.Unknown'   , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.2.Inactive'  , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.3.Unknown'   , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.3.Inactive'  , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.4.Unknown'   , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD9.4.Inactive'  , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.Required'   , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.01.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.01.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.02.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.02.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.03.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.03.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.04.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.04.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.05.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.05.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.06.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.06.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.07.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.07.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.08.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.08.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.09.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.09.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.10.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.10.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.11.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.11.Inactive', `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.12.Unknown' , `MIR.ORDER`)

              OR 0 < FIND_IN_SET('ICD10.12.Inactive', `MIR.ORDER`))

          GROUP BY CustomerID, OrderID

         ) as d on d.CustomerID = o.CustomerID and d.OrderID = o.ID

  SET o.`MIR` = CONCAT_WS(','

    ,o.MIR

    ,IF(0 < d.`Customer.Inactive`, 'Customer.Inactive', NULL)

    ,IF(0 < d.`Customer.MIR`     , 'Customer.MIR'     , NULL)

    ,IF(0 < d.`Policy1.Required` , 'Policy1.Required' , NULL)

    ,IF(0 < d.`Policy1.MIR`      , 'Policy1.MIR'      , NULL)

    ,IF(0 < d.`Policy2.Required` , 'Policy2.Required' , NULL)

    ,IF(0 < d.`Policy2.MIR`      , 'Policy2.MIR'      , NULL)

    ,IF(0 < d.`Facility.MIR`     , 'Facility.MIR'     , NULL)

    ,IF(0 < d.`PosType.Required` , 'PosType.Required' , NULL)

    ,IF(0 < d.`ICD9.Required`    , 'ICD9.Required'    , NULL)

    ,IF(0 < d.`ICD9.1.Unknown`   , 'ICD9.1.Unknown'   , NULL)

    ,IF(0 < d.`ICD9.1.Inactive`  , 'ICD9.1.Inactive'  , NULL)

    ,IF(0 < d.`ICD9.2.Unknown`   , 'ICD9.2.Unknown'   , NULL)

    ,IF(0 < d.`ICD9.2.Inactive`  , 'ICD9.2.Inactive'  , NULL)

    ,IF(0 < d.`ICD9.3.Unknown`   , 'ICD9.3.Unknown'   , NULL)

    ,IF(0 < d.`ICD9.3.Inactive`  , 'ICD9.3.Inactive'  , NULL)

    ,IF(0 < d.`ICD9.4.Unknown`   , 'ICD9.4.Unknown'   , NULL)

    ,IF(0 < d.`ICD9.4.Inactive`  , 'ICD9.4.Inactive'  , NULL)

    ,IF(0 < d.`ICD10.Required`   , 'ICD10.Required'   , NULL)

    ,IF(0 < d.`ICD10.01.Unknown` , 'ICD10.01.Unknown' , NULL)

    ,IF(0 < d.`ICD10.01.Inactive`, 'ICD10.01.Inactive', NULL)

    ,IF(0 < d.`ICD10.02.Unknown` , 'ICD10.02.Unknown' , NULL)

    ,IF(0 < d.`ICD10.02.Inactive`, 'ICD10.02.Inactive', NULL)

    ,IF(0 < d.`ICD10.03.Unknown` , 'ICD10.03.Unknown' , NULL)

    ,IF(0 < d.`ICD10.03.Inactive`, 'ICD10.03.Inactive', NULL)

    ,IF(0 < d.`ICD10.04.Unknown` , 'ICD10.04.Unknown' , NULL)

    ,IF(0 < d.`ICD10.04.Inactive`, 'ICD10.04.Inactive', NULL)

    ,IF(0 < d.`ICD10.05.Unknown` , 'ICD10.05.Unknown' , NULL)

    ,IF(0 < d.`ICD10.05.Inactive`, 'ICD10.05.Inactive', NULL)

    ,IF(0 < d.`ICD10.06.Unknown` , 'ICD10.06.Unknown' , NULL)

    ,IF(0 < d.`ICD10.06.Inactive`, 'ICD10.06.Inactive', NULL)

    ,IF(0 < d.`ICD10.07.Unknown` , 'ICD10.07.Unknown' , NULL)

    ,IF(0 < d.`ICD10.07.Inactive`, 'ICD10.07.Inactive', NULL)

    ,IF(0 < d.`ICD10.08.Unknown` , 'ICD10.08.Unknown' , NULL)

    ,IF(0 < d.`ICD10.08.Inactive`, 'ICD10.08.Inactive', NULL)

    ,IF(0 < d.`ICD10.09.Unknown` , 'ICD10.09.Unknown' , NULL)

    ,IF(0 < d.`ICD10.09.Inactive`, 'ICD10.09.Inactive', NULL)

    ,IF(0 < d.`ICD10.10.Unknown` , 'ICD10.10.Unknown' , NULL)

    ,IF(0 < d.`ICD10.10.Inactive`, 'ICD10.10.Inactive', NULL)

    ,IF(0 < d.`ICD10.11.Unknown` , 'ICD10.11.Unknown' , NULL)

    ,IF(0 < d.`ICD10.11.Inactive`, 'ICD10.11.Inactive', NULL)

    ,IF(0 < d.`ICD10.12.Unknown` , 'ICD10.12.Unknown' , NULL)

    ,IF(0 < d.`ICD10.12.Inactive`, 'ICD10.12.Inactive', NULL)

    ); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mir_update_orderdetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mir_update_orderdetails`(P_OrderID varchar(10))
BEGIN

  DECLARE V_OrderID INT; --

  DECLARE V_ActiveOnly BIT; --



  --  now we make field tbl_order.SaleType informative only

  --  now we make field view_orderdetails.IsRetail informative only -

  --  user should use BillIns1 .. BillIns4 for the same purpose



  -- P_OrderID

  -- 'ActiveOnly' - all details with State != 'Closed'

  -- number - just one

  -- all details regardless of state



  IF (P_OrderID = 'ActiveOnly') THEN

    SET V_OrderID = null; --

    SET V_ActiveOnly = 1; --

  ELSEIF (P_OrderID REGEXP '^(\\-|\\+){0,1}([0-9]+)$') THEN

    SET V_OrderID = CAST(P_OrderID as signed); --

    SET V_ActiveOnly = 0; --

  ELSE

    SET V_OrderID = null; --

    SET V_ActiveOnly = 0; --

  END IF; --



  UPDATE view_orderdetails_core as details

         INNER JOIN tbl_order as _order ON details.OrderID    = _order.ID

                                       AND details.CustomerID = _order.CustomerID

         LEFT JOIN tbl_pricecode_item as pricing ON pricing.InventoryItemID = details.InventoryItemID

                                                AND pricing.PriceCodeID     = details.PriceCodeID

         LEFT JOIN tbl_inventoryitem as item ON details.InventoryItemID = item.ID

  SET details.`MIR` = CONCAT_WS(','

    , IF(item.ID IS NULL, 'InventoryItemID', null)

    , IF(pricing.ID IS NULL, 'PriceCodeID', null)

    , CASE WHEN details.SaleRentType = 'Medicare Oxygen Rental' AND details.IsOxygen != 1

           THEN 'SaleRentType'

           WHEN details.ActualSaleRentType = '' THEN 'SaleRentType' ELSE null END

    , CASE WHEN details.ActualBillItemOn   = '' THEN 'BillItemOn'   ELSE null END

    , CASE WHEN details.ActualBilledWhen   = '' THEN 'BilledWhen'   ELSE null END

    , CASE WHEN details.ActualOrderedWhen  = '' THEN 'OrderedWhen'  ELSE null END

    , IF((details.IsActive = 1) AND (details.EndDate < _order.BillDate), 'EndDate.Invalid', null)

    , IF((details.State = 'Pickup') AND (details.EndDate IS NULL), 'EndDate.Unconfirmed', null)

    , IF((details.SaleRentType IN ('Capped Rental', 'Parental Capped Rental')) AND (IFNULL(details.Modifier1, '') = ''), 'Modifier1', null)

    , IF((details.SaleRentType IN ('Capped Rental', 'Parental Capped Rental')) AND (_order.DeliveryDate < '2006-01-01') AND (details.BillingMonth BETWEEN 12 AND 13) AND (details.Modifier3 NOT IN ('BP', 'BR', 'BU')), 'Modifier3', null)

    , IF((details.SaleRentType IN ('Capped Rental', 'Parental Capped Rental')) AND (_order.DeliveryDate < '2006-01-01') AND (details.BillingMonth BETWEEN 14 AND 15) AND (details.Modifier3 NOT IN ('BR', 'BU')), 'Modifier3', null)

    , null)

  , details.`MIR.ORDER` = ''

  WHERE IF(V_OrderID IS NOT NULL, _order.ID = V_OrderID, V_ActiveOnly != 1 or details.IsActive = 1); --



  -- common part, no ICD9 or ICD10

  UPDATE view_orderdetails_core as details

         INNER JOIN tbl_order as _order ON details.OrderID    = _order.ID

                                       AND details.CustomerID = _order.CustomerID

         INNER JOIN tbl_customer as customer ON customer.ID = _order.CustomerID

         INNER JOIN tbl_pricecode_item as pricing ON pricing.InventoryItemID = details.InventoryItemID

                                                 AND pricing.PriceCodeID     = details.PriceCodeID

         LEFT JOIN tbl_customer_insurance as policy1 ON _order.CustomerInsurance1_ID = policy1.ID

                                                    AND _order.CustomerID            = policy1.CustomerID

         LEFT JOIN tbl_customer_insurance as policy2 ON _order.CustomerInsurance2_ID = policy2.ID

                                                    AND _order.CustomerID            = policy2.CustomerID

         LEFT JOIN tbl_cmnform as cmnform ON cmnform.ID         = details.CMNFormID

                                         AND cmnform.CustomerID = details.CustomerID

         LEFT JOIN tbl_facility as facility ON _order.FacilityID = facility.ID

         LEFT JOIN tbl_postype as postype ON _order.POSTypeID = postype.ID

  SET details.`MIR` = CONCAT_WS(','

    , details.`MIR`

    , IF(IFNULL(details.OrderedQuantity  ,  0) =  0, 'OrderedQuantity'  , null)

    , IF(IFNULL(details.OrderedUnits     , '') = '', 'OrderedUnits'     , null)

    , IF(IFNULL(details.OrderedConverter ,  0) =  0, 'OrderedConverter' , null)

    , IF(IFNULL(details.BilledQuantity   ,  0) =  0, 'BilledQuantity'   , null)

    , IF(IFNULL(details.BilledUnits      , '') = '', 'BilledUnits'      , null)

    , IF(IFNULL(details.BilledConverter  ,  0) =  0, 'BilledConverter'  , null)

    , IF(IFNULL(details.DeliveryQuantity ,  0) =  0, 'DeliveryQuantity' , null)

    , IF(IFNULL(details.DeliveryUnits    , '') = '', 'DeliveryUnits'    , null)

    , IF(IFNULL(details.DeliveryConverter,  0) =  0, 'DeliveryConverter', null)

    , IF(IFNULL(details.BillingCode      , '') = '', 'BillingCode'      , null)

    , CASE WHEN '2015-10-01' <= details.DOSFrom THEN null

           WHEN IFNULL(details.DXPointer  , '') REGEXP '[1-4](,[1-4])*' THEN null

           ELSE 'DXPointer9' END

    , CASE WHEN details.DOSFrom < '2015-10-01' THEN null

           WHEN IFNULL(details.DXPointer10, '') REGEXP '([1-9]|1[0-2])(,([1-9]|1[0-2]))*' THEN null

           ELSE 'DXPointer10' END

    , IF((IFNULL(pricing.DefaultCMNType, '') != '') AND (cmnform.ID IS NULL), 'CMNForm.Required', null)

    , IF((IFNULL(pricing.DefaultCMNType, '') != '') AND (cmnform.MIR != '' ), 'CMNForm.MIR'     , null)

    , IF((cmnform.CmnType = 'DMERC DRORDER') AND (cmnform.MIR != ''), 'CMNForm.MIR', null)

    , CASE WHEN cmnform.InitialDate           is null THEN null

           WHEN cmnform.EstimatedLengthOfNeed is null THEN null

           WHEN cmnform.EstimatedLengthOfNeed < 0     THEN null

           WHEN 99 <= cmnform.EstimatedLengthOfNeed   THEN null -- 99 = LIFETIME

           WHEN (cmnform.CMNType     IN ('DMERC 484.2', 'DME 484.03'))

            AND (DATE_ADD(cmnform.InitialDate, INTERVAL 12 MONTH) <= details.DOSFrom)

            AND (cmnform.RecertificationDate is null)

           THEN 'CMNForm.RecertificationDate'

           WHEN (cmnform.CMNType     IN ('DMERC 484.2', 'DME 484.03'))

            AND (DATE_ADD(cmnform.InitialDate, INTERVAL 12 MONTH) <= details.DOSFrom)

            AND (DATE_ADD(cmnform.RecertificationDate, INTERVAL 12 MONTH) <= details.DOSFrom)

           THEN 'CMNForm.FormExpired'

           WHEN (cmnform.CMNType NOT IN ('DMERC 484.2', 'DME 484.03'))

            AND (DATE_ADD(cmnform.InitialDate, INTERVAL cmnform.EstimatedLengthOfNeed MONTH) <= details.DOSFrom)

           THEN 'CMNForm.FormExpired'

           ELSE null END

    , CASE WHEN details.AuthorizationNumber is null THEN null

           WHEN details.AuthorizationNumber = ''    THEN null

           WHEN details.AuthorizationExpirationDate < details.DOSFrom THEN 'AuthorizationNumber.Expired'

           WHEN details.AuthorizationExpirationDate <= details.DOSTo  THEN 'AuthorizationNumber.Expires'

           ELSE null END

    , null) -- MIR

  , details.`MIR.ORDER` = CONCAT_WS(','

    , IF((details.BillIns1 = 1) AND (policy1.ID IS NULL), 'Policy1.Required', null)

    , IF((details.BillIns1 = 1) AND (policy1.MIR != '' ), 'Policy1.MIR'     , null)

    , IF((details.BillIns1 = 2) AND (policy2.MIR != '' ), 'Policy2.MIR'     , null)

    , IF(customer.InactiveDate < Now(), 'Customer.Inactive', null)

    , IF(customer.MIR != '', 'Customer.MIR', null)

    , IF(facility.MIR != '', 'Facility.MIR', null)

    , IF(postype.ID IS NULL, 'PosType.Required', null)

    , null)

  WHERE IF(V_OrderID IS NOT NULL, _order.ID = V_OrderID, V_ActiveOnly != 1 or details.IsActive = 1)

    AND (customer.CommercialAccount = 0)

    AND (details.IsZeroAmount = 0)

    AND ((details.BillIns1 = 1) OR (details.BillIns2 = 1) OR (details.BillIns3 = 1) OR (details.BillIns4 = 1)); --



  -- ICD9 is only for orders before 2015-10-01

  UPDATE view_orderdetails_core as details

         INNER JOIN tbl_order as _order ON details.OrderID    = _order.ID

                                       AND details.CustomerID = _order.CustomerID

         INNER JOIN tbl_customer as customer ON customer.ID = _order.CustomerID

         LEFT JOIN tbl_icd9 as icd9_1 ON _order.ICD9_1 = icd9_1.Code

         LEFT JOIN tbl_icd9 as icd9_2 ON _order.ICD9_2 = icd9_2.Code

         LEFT JOIN tbl_icd9 as icd9_3 ON _order.ICD9_3 = icd9_3.Code

         LEFT JOIN tbl_icd9 as icd9_4 ON _order.ICD9_4 = icd9_4.Code

  SET details.`MIR.ORDER` = CONCAT_WS(','

    , details.`MIR.ORDER`

    , CASE WHEN _order.ICD9_1 != ''                THEN null

           WHEN _order.ICD9_2 != ''                THEN null

           WHEN _order.ICD9_3 != ''                THEN null

           WHEN _order.ICD9_4 != ''                THEN null

           ELSE 'ICD9.Required' END

    , CASE WHEN IFNULL(_order.ICD9_1, '') = ''          THEN null

           WHEN icd9_1.Code IS NULL                     THEN 'ICD9.1.Unknown'

           WHEN icd9_1.InactiveDate <= _order.OrderDate THEN 'ICD9.1.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD9_2, '') = ''          THEN null

           WHEN icd9_2.Code IS NULL                     THEN 'ICD9.2.Unknown'

           WHEN icd9_2.InactiveDate <= _order.OrderDate THEN 'ICD9.2.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD9_3, '') = ''          THEN null

           WHEN icd9_3.Code IS NULL                     THEN 'ICD9.3.Unknown'

           WHEN icd9_3.InactiveDate <= _order.OrderDate THEN 'ICD9.3.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD9_4, '') = ''          THEN null

           WHEN icd9_4.Code IS NULL                     THEN 'ICD9.4.Unknown'

           WHEN icd9_4.InactiveDate <= _order.OrderDate THEN 'ICD9.4.Inactive'

           ELSE null END

    , null)

  WHERE IF(V_OrderID IS NOT NULL, _order.ID = V_OrderID, V_ActiveOnly != 1 or details.IsActive = 1)

    AND (customer.CommercialAccount = 0)

    AND (details.IsZeroAmount = 0)

    AND (details.DOSFrom < '2015-10-01')

    AND (details.DXPointer != '')

    AND ((details.BillIns1 = 1) OR (details.BillIns2 = 1) OR (details.BillIns3 = 1) OR (details.BillIns4 = 1)); --



  -- ICD10 is only for orders after 2015-10-01

  UPDATE view_orderdetails_core as details

         INNER JOIN tbl_order as _order ON details.OrderID    = _order.ID

                                       AND details.CustomerID = _order.CustomerID

         INNER JOIN tbl_customer as customer ON customer.ID = _order.CustomerID

         LEFT JOIN tbl_icd10 as icd10_01 ON _order.ICD10_01 = icd10_01.Code

         LEFT JOIN tbl_icd10 as icd10_02 ON _order.ICD10_02 = icd10_02.Code

         LEFT JOIN tbl_icd10 as icd10_03 ON _order.ICD10_03 = icd10_03.Code

         LEFT JOIN tbl_icd10 as icd10_04 ON _order.ICD10_04 = icd10_04.Code

         LEFT JOIN tbl_icd10 as icd10_05 ON _order.ICD10_05 = icd10_05.Code

         LEFT JOIN tbl_icd10 as icd10_06 ON _order.ICD10_06 = icd10_06.Code

         LEFT JOIN tbl_icd10 as icd10_07 ON _order.ICD10_07 = icd10_07.Code

         LEFT JOIN tbl_icd10 as icd10_08 ON _order.ICD10_08 = icd10_08.Code

         LEFT JOIN tbl_icd10 as icd10_09 ON _order.ICD10_09 = icd10_09.Code

         LEFT JOIN tbl_icd10 as icd10_10 ON _order.ICD10_10 = icd10_10.Code

         LEFT JOIN tbl_icd10 as icd10_11 ON _order.ICD10_11 = icd10_11.Code

         LEFT JOIN tbl_icd10 as icd10_12 ON _order.ICD10_12 = icd10_12.Code

  SET details.`MIR.ORDER` = CONCAT_WS(','

    , details.`MIR.ORDER`

    , CASE WHEN _order.ICD10_01 != '' THEN null

           WHEN _order.ICD10_02 != '' THEN null

           WHEN _order.ICD10_03 != '' THEN null

           WHEN _order.ICD10_04 != '' THEN null

           WHEN _order.ICD10_05 != '' THEN null

           WHEN _order.ICD10_06 != '' THEN null

           WHEN _order.ICD10_07 != '' THEN null

           WHEN _order.ICD10_08 != '' THEN null

           WHEN _order.ICD10_09 != '' THEN null

           WHEN _order.ICD10_10 != '' THEN null

           WHEN _order.ICD10_11 != '' THEN null

           WHEN _order.ICD10_12 != '' THEN null

           ELSE 'ICD10.Required' END

    , CASE WHEN IFNULL(_order.ICD10_01, '') = ''          THEN null

           WHEN icd10_01.Code IS NULL                     THEN 'ICD10.01.Unknown'

           WHEN icd10_01.InactiveDate <= _order.OrderDate THEN 'ICD10.01.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_02, '') = ''          THEN null

           WHEN icd10_02.Code IS NULL                     THEN 'ICD10.02.Unknown'

           WHEN icd10_02.InactiveDate <= _order.OrderDate THEN 'ICD10.02.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_03, '') = ''          THEN null

           WHEN icd10_03.Code IS NULL                     THEN 'ICD10.03.Unknown'

           WHEN icd10_03.InactiveDate <= _order.OrderDate THEN 'ICD10.03.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_04, '') = ''          THEN null

           WHEN icd10_04.Code IS NULL                     THEN 'ICD10.04.Unknown'

           WHEN icd10_04.InactiveDate <= _order.OrderDate THEN 'ICD10.04.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_05, '') = ''          THEN null

           WHEN icd10_05.Code IS NULL                     THEN 'ICD10.05.Unknown'

           WHEN icd10_05.InactiveDate <= _order.OrderDate THEN 'ICD10.05.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_06, '') = ''          THEN null

           WHEN icd10_06.Code IS NULL                     THEN 'ICD10.06.Unknown'

           WHEN icd10_06.InactiveDate <= _order.OrderDate THEN 'ICD10.06.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_07, '') = ''          THEN null

           WHEN icd10_07.Code IS NULL                     THEN 'ICD10.07.Unknown'

           WHEN icd10_07.InactiveDate <= _order.OrderDate THEN 'ICD10.07.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_08, '') = ''          THEN null

           WHEN icd10_08.Code IS NULL                     THEN 'ICD10.08.Unknown'

           WHEN icd10_08.InactiveDate <= _order.OrderDate THEN 'ICD10.08.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_09, '') = ''          THEN null

           WHEN icd10_09.Code IS NULL                     THEN 'ICD10.09.Unknown'

           WHEN icd10_09.InactiveDate <= _order.OrderDate THEN 'ICD10.09.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_10, '') = ''          THEN null

           WHEN icd10_10.Code IS NULL                     THEN 'ICD10.10.Unknown'

           WHEN icd10_10.InactiveDate <= _order.OrderDate THEN 'ICD10.10.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_11, '') = ''          THEN null

           WHEN icd10_11.Code IS NULL                     THEN 'ICD10.11.Unknown'

           WHEN icd10_11.InactiveDate <= _order.OrderDate THEN 'ICD10.11.Inactive'

           ELSE null END

    , CASE WHEN IFNULL(_order.ICD10_12, '') = ''          THEN null

           WHEN icd10_12.Code IS NULL                     THEN 'ICD10.12.Unknown'

           WHEN icd10_12.InactiveDate <= _order.OrderDate THEN 'ICD10.12.Inactive'

           ELSE null END

    , null)

  WHERE IF(V_OrderID IS NOT NULL, _order.ID = V_OrderID, V_ActiveOnly != 1 or details.IsActive = 1)

    AND (customer.CommercialAccount = 0)

    AND (details.IsZeroAmount = 0)

    AND ('2015-10-01' <= details.DOSFrom)

    AND (details.DXPointer10 != '')

    AND ((details.BillIns1 = 1) OR (details.BillIns2 = 1) OR (details.BillIns3 = 1) OR (details.BillIns4 = 1)); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `move_serial_on_hand` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `move_serial_on_hand`(P_SerialID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --



  -- cursor variables

  DECLARE cur_SerialID    INT(11); --

  DECLARE cur_WarehouseID INT(11); --

  DECLARE cur_TranType    VARCHAR(50); --



  DECLARE cur CURSOR FOR

  SELECT

    st2.SerialID

  , st2.WarehouseId

  , stt2.Name as TranType

  FROM (SELECT *

        FROM tbl_serial_transaction

        WHERE ID IN (SELECT Max(ID) FROM tbl_serial_transaction GROUP BY SerialID)) AS st

  INNER JOIN tbl_serial_transaction_type as stt ON stt.ID   = st.TypeID

                                               AND stt.Name = 'Returned'

  INNER JOIN (SELECT *

              FROM tbl_serial_transaction

              WHERE ID IN (SELECT Max(ID) FROM tbl_serial_transaction WHERE WarehouseId IS NOT NULL GROUP BY SerialID)) AS st2

          ON st2.SerialID = st.SerialID

  INNER JOIN tbl_serial_transaction_type AS stt2 ON stt2.Name = 'In from Maintenance'

  WHERE (P_SerialID IS NULL OR st2.SerialID = P_SerialID); --



  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

      cur_SerialID

    , cur_WarehouseID

    , cur_TranType; --



    IF (done = 0) THEN

      CALL serial_add_transaction(

        cur_TranType       -- P_TranType         VARCHAR(50)

      , NOW()              -- P_TranTime         DATETIME

      , cur_SerialID       -- P_SerialID         INT,

      , cur_WarehouseID    -- P_WarehouseID      INT,

      , null               -- P_VendorID         INT,

      , null               -- P_CustomerID       INT,

      , null               -- P_OrderID          INT,

      , null               -- P_OrderDetailsID   INT,

      , null               -- P_LotNumber        VARCHAR(50),

      , 1                  -- P_LastUpdateUserID INT

      ); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Order_ConvertDepositsIntoPayments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Order_ConvertDepositsIntoPayments`(P_OrderID INT)
    MODIFIES SQL DATA
BEGIN

  -- for given OrderId we select all order lines with deposits that have invoice lines without "deposit" payments

  DECLARE V_InvoiceDetailsID INT; --

  DECLARE V_Amount, V_Billable DECIMAL(18, 2); --

  DECLARE V_Date DATE; --

  DECLARE V_PaymentMethod VARCHAR(20); --

  DECLARE V_Template, V_Extra TEXT; --

  DECLARE V_Element VARCHAR(100); --

  DECLARE V_Result VARCHAR(50); --

  DECLARE done INT DEFAULT 0; --

  DECLARE cur CURSOR FOR

    SELECT il.ID, dd.Amount, d.Date, d.PaymentMethod, il.BillableAmount

    FROM tbl_order AS o

         INNER JOIN tbl_orderdetails AS od ON od.CustomerID = o.CustomerID

                                          AND od.OrderID    = o.ID

         INNER JOIN tbl_deposits AS d ON d.CustomerID = od.CustomerID

                                     AND d.OrderID    = od.OrderID

         INNER JOIN tbl_depositdetails AS dd ON dd.CustomerID     = od.CustomerID

                                            AND dd.OrderID        = od.OrderID

                                            AND dd.OrderDetailsID = od.ID

         INNER JOIN tbl_invoice AS i ON i.CustomerID = o.CustomerID

                                    AND i.OrderID    = o.ID

         INNER JOIN tbl_invoicedetails AS il ON il.CustomerID     = i.CustomerID

                                            AND il.InvoiceID      = i.ID

                                            AND il.BillingMonth   = 1 -- only first billing month

                                            AND il.OrderID        = od.OrderID

                                            AND il.OrderDetailsID = od.ID

         INNER JOIN tbl_invoice_transactiontype as tt ON tt.Name = 'Payment'

         LEFT JOIN tbl_invoice_transaction as p ON p.CustomerID       = il.CustomerID

                                               AND p.InvoiceID        = il.InvoiceID

                                               AND p.InvoiceDetailsID = il.ID

                                               AND p.InsuranceCompanyID IS NULL

                                               AND p.CustomerInsuranceID IS NULL

                                               AND p.TransactionTypeID = tt.ID

                                               AND p.TransactionDate   = d.Date

                                               AND p.Amount            = dd.Amount

    WHERE (o.ID = P_OrderID)

      AND (p.ID is null); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  SET V_Template = '<values>

  <v n="Billable">0.00</v>

  <v n="CheckDate">00/00/0000</v>

  <v n="Paid">0.00</v>

  <v n="PaymentMethod">Check</v>

</values>'; --



  OPEN cur; --



  DEPOSITS_LOOP: LOOP

    FETCH cur INTO V_InvoiceDetailsID, V_Amount, V_Date, V_PaymentMethod, V_Billable; --



    IF done THEN

      LEAVE DEPOSITS_LOOP; --

    END IF; --



    SET V_Extra = V_Template; --

    SET V_Element = CONCAT('<v n="Billable">', IFNULL(CAST(V_Billable as CHAR), ''), '</v>'); --

    SET V_Extra = UpdateXML(V_Extra, 'values/v[@n="Billable"]' COLLATE latin1_general_ci, V_Element COLLATE latin1_general_ci); --

    SET V_Element = CONCAT('<v n="CheckDate">', IFNULL(DATE_FORMAT(V_Date, '%m/%d/%Y'), ''), '</v>'); --

    SET V_Extra = UpdateXML(V_Extra, 'values/v[@n="CheckDate"]' COLLATE latin1_general_ci, V_Element COLLATE latin1_general_ci); --

    SET V_Element = CONCAT('<v n="Paid">', IFNULL(CAST(V_Amount as CHAR), ''), '</v>'); --

    SET V_Extra = UpdateXML(V_Extra, 'values/v[@n="Paid"]' COLLATE latin1_general_ci, V_Element COLLATE latin1_general_ci); --

    SET V_Element = CONCAT('<v n="PaymentMethod">', IFNULL(CAST(V_PaymentMethod as CHAR), 'Check'), '</v>'); --

    SET V_Extra = UpdateXML(V_Extra, 'values/v[@n="PaymentMethod"]' COLLATE latin1_general_ci, V_Element COLLATE latin1_general_ci); --



    CALL `InvoiceDetails_AddPayment`

    ( V_InvoiceDetailsID

    , NULL -- P_InsuranceCompanyID

    , V_Date

    , V_Extra

    , 'Deposit' -- P_Comments

    , '' -- P_Options

    , IFNULL(@UserId, 1)

    , V_Result); --

  END LOOP DEPOSITS_LOOP; --



  CLOSE cur; --



  CALL `Order_InternalUpdateBalance`(P_OrderID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Order_InternalProcess` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Order_InternalProcess`(P_OrderID INT, P_BillingMonth INT, P_BillingFlags INT, P_InvoiceDate DATE, OUT P_InvoiceID INT)
BEGIN

  DECLARE V_DetailsCount, V_ICD10Count INT; --



  SET P_InvoiceID = NULL; --



  SELECT COUNT(*), SUM(CASE WHEN '2015-10-01' <= details.DosFrom THEN 1 ELSE 0 END)

  INTO V_DetailsCount, V_ICD10Count

  FROM tbl_order

       INNER JOIN view_orderdetails_core as details ON tbl_order.ID = details.OrderID

                                                   AND tbl_order.CustomerID = details.CustomerID

       INNER JOIN tbl_pricecode_item as pricecode ON details.PriceCodeID = pricecode.PriceCodeID

                                                 AND details.InventoryItemID = pricecode.InventoryItemID

  WHERE (details.OrderID = P_OrderID)

    AND (details.IsActive = 1)

    -- we should generate invoices before end date and should not generate invoices after end date

    AND ((details.EndDate IS NULL) OR (details.DosFrom <= details.EndDate))

    AND (IF(details.BillingMonth <= 0, 1, details.BillingMonth) = P_BillingMonth)

    AND ((IF((tbl_order.CustomerInsurance1_ID IS NOT NULL) AND (details.BillIns1 = 1), 1, 0) +

          IF((tbl_order.CustomerInsurance2_ID IS NOT NULL) AND (details.BillIns2 = 1), 2, 0) +

          IF((tbl_order.CustomerInsurance3_ID IS NOT NULL) AND (details.BillIns3 = 1), 4, 0) +

          IF((tbl_order.CustomerInsurance4_ID IS NOT NULL) AND (details.BillIns4 = 1), 8, 0) +

          IF((details.EndDate IS NOT NULL), 32, 0) +

          IF((details.AcceptAssignment = 1), 16, 0)) = P_BillingFlags)

    AND (IFNULL(details.MIR, '') = '')

    AND (OrderMustBeSkipped  (tbl_order.DeliveryDate, details.DosFrom, details.ActualSaleRentType, details.BillingMonth, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4) = 0)

    AND (InvoiceMustBeSkipped(tbl_order.DeliveryDate, details.DosFrom, details.ActualSaleRentType, details.BillingMonth, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4) = 0)

    -- check for zero amount was moved out of function InvoiceMustBeSkipped

    AND (details.IsZeroAmount = 0); --



  IF 0 < V_DetailsCount THEN

    -- create invoice

    INSERT INTO tbl_invoice

    ( CustomerID

    , OrderID

    , Approved

    , AcceptAssignment

    , ClaimNote

    , InvoiceDate

    , DoctorID

    , POSTypeID

    , FacilityID

    , ReferralID

    , SalesrepID

    , CustomerInsurance1_ID

    , CustomerInsurance2_ID

    , CustomerInsurance3_ID

    , CustomerInsurance4_ID

    , ICD9_1

    , ICD9_2

    , ICD9_3

    , ICD9_4

    , ICD10_01

    , ICD10_02

    , ICD10_03

    , ICD10_04

    , ICD10_05

    , ICD10_06

    , ICD10_07

    , ICD10_08

    , ICD10_09

    , ICD10_10

    , ICD10_11

    , ICD10_12

    , TaxRateID

    , TaxRatePercent

    , Discount

    , LastUpdateUserID)

    SELECT

      tbl_order.CustomerID

    , tbl_order.ID

    , tbl_order.Approved

    , IF(P_BillingFlags & 16 = 16, 1, 0) as AcceptAssignment

    , ClaimNote

    , P_InvoiceDate as InvoiceDate

    , tbl_order.DoctorID

    , tbl_order.POSTypeID

    , tbl_order.FacilityID

    , tbl_order.ReferralID

    , tbl_order.SalesrepID

    , tbl_order.CustomerInsurance1_ID

    , tbl_order.CustomerInsurance2_ID

    , tbl_order.CustomerInsurance3_ID

    , tbl_order.CustomerInsurance4_ID

    , IF(V_ICD10Count = V_DetailsCount, '', tbl_order.ICD9_1) as ICD9_1

    , IF(V_ICD10Count = V_DetailsCount, '', tbl_order.ICD9_2) as ICD9_2

    , IF(V_ICD10Count = V_DetailsCount, '', tbl_order.ICD9_3) as ICD9_3

    , IF(V_ICD10Count = V_DetailsCount, '', tbl_order.ICD9_4) as ICD9_4

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_01) as ICD10_01

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_02) as ICD10_02

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_03) as ICD10_03

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_04) as ICD10_04

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_05) as ICD10_05

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_06) as ICD10_06

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_07) as ICD10_07

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_08) as ICD10_08

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_09) as ICD10_09

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_10) as ICD10_10

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_11) as ICD10_11

    , IF(V_ICD10Count = 0, '', tbl_order.ICD10_12) as ICD10_12

    , view_taxrate.ID

    , view_taxrate.TotalTax

    , tbl_order.Discount

    , IFNULL(@UserId, 1) as LastUpdateUserID

    FROM tbl_order

         LEFT JOIN tbl_customer ON tbl_order.CustomerID = tbl_customer.ID

         LEFT JOIN tbl_company ON tbl_company.ID = 1

         LEFT JOIN view_taxrate ON IFNULL(tbl_customer.TaxRateID, tbl_company.TaxRateID) = view_taxrate.ID

    WHERE (tbl_order.ID = P_OrderID); --



    SELECT LAST_INSERT_ID() INTO P_InvoiceID; --



    -- add line items to invoice

    INSERT INTO tbl_invoicedetails

    ( CustomerID

    , InvoiceID

    , InventoryItemID

    , PriceCodeID

    , OrderID

    , OrderDetailsID

    , Balance

    , BillableAmount

    , AllowableAmount

    , Taxes

    , Quantity

    , Hardship

    , AcceptAssignment

    , InvoiceDate

    , DOSFrom

    , DOSTo

    , ShowSpanDates

    , BillingCode

    , Modifier1

    , Modifier2

    , Modifier3

    , Modifier4

    , DXPointer

    , DXPointer10

    , DrugNoteField

    , DrugControlNumber

    , BillingMonth

    , SendCMN_RX_w_invoice

    , SpecialCode

    , ReviewCode

    , MedicallyUnnecessary

    , BillIns1

    , BillIns2

    , BillIns3

    , BillIns4

    , NopayIns1

    , CMNFormID

    , AuthorizationTypeID

    , AuthorizationNumber

    , HaoDescription)

    SELECT

      details.CustomerID

    , P_InvoiceID

    , details.InventoryItemID

    , details.PriceCodeID

    , details.OrderID

    , details.ID

    , (1 - IFNULL(tbl_order.Discount, 0) / 100) *

      GetAmountMultiplier(details.DOSFrom, details.DOSTo, details.EndDate, details.ActualSaleRentType, details.ActualOrderedWhen, details.ActualBilledWhen) *

      IF((details.Taxable = 1) AND (view_taxrate.ID IS NOT NULL)

        ,GetAllowableAmount(details.ActualSaleRentType, details.BillingMonth, details.AllowablePrice, details.BilledQuantity, pricecode.Sale_AllowablePrice, details.FlatRate) * (1 + IFNULL(view_taxrate.TotalTax, 0) / 100)

        ,GetBillableAmount (details.ActualSaleRentType, details.BillingMonth, details.BillablePrice , details.BilledQuantity, pricecode.Sale_BillablePrice, details.FlatRate))

      as Balance

    , (1 - IFNULL(tbl_order.Discount, 0) / 100) *

      GetAmountMultiplier(details.DOSFrom, details.DOSTo, details.EndDate, details.ActualSaleRentType, details.ActualOrderedWhen, details.ActualBilledWhen) *

      IF((details.Taxable = 1) AND (view_taxrate.ID IS NOT NULL)

        ,GetAllowableAmount(details.ActualSaleRentType, details.BillingMonth, details.AllowablePrice, details.BilledQuantity, pricecode.Sale_AllowablePrice, details.FlatRate) * (1 + IFNULL(view_taxrate.TotalTax, 0) / 100)

        ,GetBillableAmount (details.ActualSaleRentType, details.BillingMonth, details.BillablePrice , details.BilledQuantity, pricecode.Sale_BillablePrice, details.FlatRate))

      as BillableAmount

    , (1 - IFNULL(tbl_order.Discount, 0) / 100) *

      GetAmountMultiplier(details.DOSFrom, details.DOSTo, details.EndDate, details.ActualSaleRentType, details.ActualOrderedWhen, details.ActualBilledWhen) *

      GetAllowableAmount(details.ActualSaleRentType, details.BillingMonth, details.AllowablePrice, details.BilledQuantity, pricecode.Sale_AllowablePrice, details.FlatRate)

      as AllowableAmount

    , (1 - IFNULL(tbl_order.Discount, 0) / 100) *

      GetAmountMultiplier(details.DOSFrom, details.DOSTo, details.EndDate, details.ActualSaleRentType, details.ActualOrderedWhen, details.ActualBilledWhen) *

      IF((details.Taxable = 1) AND (view_taxrate.ID IS NOT NULL)

        ,GetAllowableAmount(details.ActualSaleRentType, details.BillingMonth, details.AllowablePrice, details.BilledQuantity, pricecode.Sale_AllowablePrice, details.FlatRate) * (0 + IFNULL(view_taxrate.TotalTax, 0) / 100)

        ,0.00) as Taxes

    , details.BilledQuantity *

      GetQuantityMultiplier(details.DOSFrom, details.DOSTo, details.EndDate, details.ActualSaleRentType, details.ActualOrderedWhen, details.ActualBilledWhen)

      as Quantity

    , IFNULL(tbl_customer.Hardship, 0)

    , IFNULL(details.AcceptAssignment, 0) as AcceptAssignment

    , P_InvoiceDate

    , details.DOSFrom

    , details.ActualDosTo as DOSTo

    , details.ShowSpanDates

    , details.BillingCode

    , GetInvoiceModifier(tbl_order.DeliveryDate, details.ActualSaleRentType, details.BillingMonth, 1, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4)

    , GetInvoiceModifier(tbl_order.DeliveryDate, details.ActualSaleRentType, details.BillingMonth, 2, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4)

    , GetInvoiceModifier(tbl_order.DeliveryDate, details.ActualSaleRentType, details.BillingMonth, 3, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4)

    , GetInvoiceModifier(tbl_order.DeliveryDate, details.ActualSaleRentType, details.BillingMonth, 4, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4)

    , details.DXPointer

    , details.DXPointer10

    , details.DrugNoteField

    , details.DrugControlNumber

    , IF(details.BillingMonth <= 0, 1, details.BillingMonth)

    , IF(details.BillingMonth <= 1, details.SendCMN_RX_w_invoice, 0)

    , details.SpecialCode

    , details.ReviewCode

    , details.MedicallyUnnecessary

    , details.BillIns1

    , details.BillIns2

    , details.BillIns3

    , details.BillIns4

    , details.NopayIns1

    , details.CMNFormID

    , details.AuthorizationTypeID

    , details.AuthorizationNumber

    , details.HaoDescription

    FROM tbl_order

         INNER JOIN view_orderdetails_core as details ON tbl_order.ID = details.OrderID

                                                     AND tbl_order.CustomerID = details.CustomerID

         INNER JOIN tbl_pricecode_item as pricecode ON details.PriceCodeID = pricecode.PriceCodeID

                                                   AND details.InventoryItemID = pricecode.InventoryItemID

         LEFT JOIN tbl_customer ON tbl_order.CustomerID = tbl_customer.ID

         LEFT JOIN tbl_company ON tbl_company.ID = 1

         LEFT JOIN view_taxrate ON IFNULL(tbl_customer.TaxRateID, tbl_company.TaxRateID) = view_taxrate.ID

    WHERE (details.OrderID = P_OrderID)

      AND (details.IsActive = 1)

      -- we should generate invoices before end date and should not generate invoices after end date

      AND ((details.EndDate IS NULL) OR (details.DosFrom <= details.EndDate))

      AND (IF(details.BillingMonth <= 0, 1, details.BillingMonth) = P_BillingMonth)

      AND ((IF((tbl_order.CustomerInsurance1_ID IS NOT NULL) AND (details.BillIns1 = 1), 1, 0) +

            IF((tbl_order.CustomerInsurance2_ID IS NOT NULL) AND (details.BillIns2 = 1), 2, 0) +

            IF((tbl_order.CustomerInsurance3_ID IS NOT NULL) AND (details.BillIns3 = 1), 4, 0) +

            IF((tbl_order.CustomerInsurance4_ID IS NOT NULL) AND (details.BillIns4 = 1), 8, 0) +

            IF((details.EndDate IS NOT NULL), 32, 0) +

            IF((details.AcceptAssignment = 1), 16, 0)) = P_BillingFlags)

      AND (IFNULL(details.MIR, '') = '')

      AND (OrderMustBeSkipped  (tbl_order.DeliveryDate, details.DosFrom, details.ActualSaleRentType, details.BillingMonth, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4) = 0)

      AND (InvoiceMustBeSkipped(tbl_order.DeliveryDate, details.DosFrom, details.ActualSaleRentType, details.BillingMonth, details.Modifier1, details.Modifier2, details.Modifier3, details.Modifier4) = 0)

      -- check for zero amount was moved out of function InvoiceMustBeSkipped

      AND (details.IsZeroAmount = 0); --

  END IF; --



  -- update order line items

  UPDATE tbl_order AS o

         INNER JOIN view_orderdetails_core AS od ON o.ID = od.OrderID

                                                AND o.CustomerID = od.CustomerID

  SET

    o.BillDate = od.DOSFrom

  , od.DOSTo     = GetNextDosTo  (od.DOSFrom, od.DOSTo, od.ActualBilledWhen)

  , od.DOSFrom   = GetNextDosFrom(od.DOSFrom, od.DOSTo, od.ActualBilledWhen)

  , od.Modifier1 = GetInvoiceModifier(o.DeliveryDate, od.ActualSaleRentType, od.BillingMonth, 1, od.Modifier1, od.Modifier2, od.Modifier3, od.Modifier4)

  , od.Modifier2 = GetInvoiceModifier(o.DeliveryDate, od.ActualSaleRentType, od.BillingMonth, 2, od.Modifier1, od.Modifier2, od.Modifier3, od.Modifier4)

  , od.State     = CASE WHEN (od.EndDate IS NOT NULL) AND (od.EndDate < od.InvoiceDate)

                        THEN 'Closed'

                        WHEN OrderMustBeClosed(o.DeliveryDate, od.DOSFrom, od.ActualSaleRentType, od.BillingMonth, od.Modifier1, od.Modifier2, od.Modifier3, od.Modifier4) = 1

                        THEN 'Closed'

                        ELSE od.State END

  , od.EndDate   = CASE WHEN od.EndDate IS NOT NULL

                        THEN od.EndDate

                        WHEN OrderMustBeClosed(o.DeliveryDate, od.DOSFrom, od.ActualSaleRentType, od.BillingMonth, od.Modifier1, od.Modifier2, od.Modifier3, od.Modifier4) = 1

                        THEN P_InvoiceDate

                        ELSE od.EndDate END

  , od.BillingMonth = IF(od.BillingMonth <= 0, 1, od.BillingMonth) + 1

  WHERE (od.OrderID = P_OrderID)

    AND (od.IsActive = 1)

    AND (IF(od.BillingMonth <= 0, 1, od.BillingMonth) = P_BillingMonth)

    AND ((IF((o.CustomerInsurance1_ID IS NOT NULL) AND (od.BillIns1 = 1), 1, 0) +

          IF((o.CustomerInsurance2_ID IS NOT NULL) AND (od.BillIns2 = 1), 2, 0) +

          IF((o.CustomerInsurance3_ID IS NOT NULL) AND (od.BillIns3 = 1), 4, 0) +

          IF((o.CustomerInsurance4_ID IS NOT NULL) AND (od.BillIns4 = 1), 8, 0) +

          IF((od.EndDate IS NOT NULL), 32, 0) +

          IF((od.AcceptAssignment = 1), 16, 0)) = P_BillingFlags)

    AND (IFNULL(od.MIR, '') = '')

    AND (OrderMustBeSkipped(o.DeliveryDate, od.DosFrom, od.ActualSaleRentType, od.BillingMonth, od.Modifier1, od.Modifier2, od.Modifier3, od.Modifier4) = 0); --



  IF P_BillingMonth = 1 THEN

    CALL Order_ConvertDepositsIntoPayments(P_OrderID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Order_InternalUpdateBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Order_InternalUpdateBalance`(P_OrderID INT)
BEGIN

  UPDATE tbl_invoice as i

  INNER JOIN tbl_order as o ON i.CustomerID = o.CustomerID

                           AND i.OrderID    = o.ID

  LEFT JOIN (SELECT tbl_invoicedetails.InvoiceID, Sum(tbl_invoicedetails.Balance) as Balance

             FROM tbl_order

                  INNER JOIN tbl_invoice ON tbl_invoice.CustomerID = tbl_order.CustomerID

                                        AND tbl_invoice.OrderID    = tbl_order.ID

                  INNER JOIN tbl_invoicedetails ON tbl_invoicedetails.CustomerID = tbl_invoice.CustomerID

                                               AND tbl_invoicedetails.InvoiceID  = tbl_invoice.ID

             WHERE (tbl_order.ID = P_OrderID)

             GROUP BY tbl_invoicedetails.InvoiceID) as b

         ON b.InvoiceID = i.ID

  SET i.InvoiceBalance = IFNULL(b.Balance, 0)

  WHERE (o.ID = P_OrderID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `order_process` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `order_process`(P_OrderID INT, P_BillingMonth INT, P_BillingFlags INT, P_InvoiceDate DATE, OUT P_InvoiceID INT)
BEGIN

  CALL `Order_InternalProcess`(P_OrderID, P_BillingMonth, P_BillingFlags, P_InvoiceDate, P_InvoiceID); --

  IF (P_InvoiceID IS NOT NULL) THEN

    CALL `InvoiceDetails_RecalculateInternals_Single`(P_InvoiceID, null); --

    CALL `Invoice_InternalUpdatePendingSubmissions`  (P_InvoiceID); --

    CALL `InvoiceDetails_RecalculateInternals_Single`(P_InvoiceID, null); --

    CALL `Invoice_InternalUpdateBalance`             (P_InvoiceID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `order_process_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `order_process_2`(P_OrderID INT, P_BillingMonth INT, P_BillingFlags INT, P_InvoiceDate DATE)
BEGIN

  DECLARE V_InvoiceID INT; --

  SET V_InvoiceID = null; --



  CALL `Order_InternalProcess`(P_OrderID, P_BillingMonth, P_BillingFlags, P_InvoiceDate, V_InvoiceID); --

  IF (V_InvoiceID IS NOT NULL) THEN

    CALL `InvoiceDetails_RecalculateInternals_Single`(V_InvoiceID, null); --

    CALL `Invoice_InternalUpdatePendingSubmissions`  (V_InvoiceID); --

    CALL `InvoiceDetails_RecalculateInternals_Single`(V_InvoiceID, null); --

    CALL `Invoice_InternalUpdateBalance`             (V_InvoiceID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `order_update_dos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `order_update_dos`(P_OrderID INT, P_DOSFrom DATE)
BEGIN

  IF P_DOSFrom IS NOT NULL THEN

    UPDATE view_orderdetails as details

           INNER JOIN tbl_order ON details.CustomerID = tbl_order.CustomerID

                               AND details.OrderID    = tbl_order.ID

    SET

      details.DosFrom = P_DOSFrom

    , details.DosTo   = GetNewDosTo(P_DOSFrom, details.DosFrom, details.DosTo, details.ActualBilledWhen)

    -- ordered quantity will not change

    , details.BilledQuantity = OrderedQty2BilledQty(P_DOSFrom, GetNewDosTo(P_DOSFrom, details.DosFrom, details.DosTo, details.ActualBilledWhen),

        details.OrderedQuantity, details.OrderedWhen, details.BilledWhen,

        details.OrderedConverter, details.DeliveryConverter, details.BilledConverter)

    , details.DeliveryQuantity = OrderedQty2DeliveryQty(P_DOSFrom, GetNewDosTo(P_DOSFrom, details.DosFrom, details.DosTo, details.ActualBilledWhen),

        details.OrderedQuantity, details.OrderedWhen, details.BilledWhen,

        details.OrderedConverter, details.DeliveryConverter, details.BilledConverter)

    WHERE (tbl_order.ID = P_OrderID)

      AND (tbl_order.Approved = 0); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `process_reoccuring_order` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `process_reoccuring_order`(P_OrderID INT, P_BilledWhen VARCHAR(50), P_BillItemOn VARCHAR(50))
BEGIN

  -- reoccuring sales support

  -- tbl_orderdetails.ReoccuringID - source line item

  DECLARE V_DetailsCount INT; --

  DECLARE V_NewOrderID INT; --

  DECLARE V_NewOrderDate DATETIME; --



  SELECT

     Count(*) as `Count`

    ,MAX(IF(details.BillingMonth <= 1, GetNextDosFrom(details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosFrom)) as NewOrderDate

  INTO

     V_DetailsCount

    ,V_NewOrderDate

  FROM view_orderdetails AS details

       INNER JOIN tbl_order ON details.CustomerID = tbl_order.CustomerID

                           AND details.OrderID    = tbl_order.ID

  WHERE (details.OrderID = P_OrderID)

    AND (details.BilledWhen = P_BilledWhen)

    AND (details.BilledWhen != 'One Time')

    AND (details.ActualBillItemOn = P_BillItemOn)

    AND (details.SaleRentType = 'Re-occurring Sale'); --



  IF 0 < V_DetailsCount THEN

    -- create order

    INSERT INTO tbl_order

    (CustomerID

    ,Approved

    ,OrderDate

    ,DeliveryDate

    ,BillDate

    ,EndDate

    ,TakenBy

    ,ShippingMethodID

    ,SpecialInstructions

    ,CustomerInsurance1_ID

    ,CustomerInsurance2_ID

    ,CustomerInsurance3_ID

    ,CustomerInsurance4_ID

    ,ICD9_1

    ,ICD9_2

    ,ICD9_3

    ,ICD9_4

    ,ICD10_01

    ,ICD10_02

    ,ICD10_03

    ,ICD10_04

    ,ICD10_05

    ,ICD10_06

    ,ICD10_07

    ,ICD10_08

    ,ICD10_09

    ,ICD10_10

    ,ICD10_11

    ,ICD10_12

    ,DoctorID

    ,POSTypeID

    ,FacilityID

    ,ReferralID

    ,SalesrepID

    ,LocationID

    ,ClaimNote

    ,UserField1

    ,UserField2

    ,LastUpdateUserID)

    SELECT

     CustomerID

    ,0 as Approved

    ,V_NewOrderDate

    ,null as DeliveryDate

    ,null as BillDate

    ,null as EndDate

    ,'AutoGenerated' as TakenBy

    ,ShippingMethodID

    ,SpecialInstructions

    ,CustomerInsurance1_ID

    ,CustomerInsurance2_ID

    ,CustomerInsurance3_ID

    ,CustomerInsurance4_ID

    ,ICD9_1

    ,ICD9_2

    ,ICD9_3

    ,ICD9_4

    ,ICD10_01

    ,ICD10_02

    ,ICD10_03

    ,ICD10_04

    ,ICD10_05

    ,ICD10_06

    ,ICD10_07

    ,ICD10_08

    ,ICD10_09

    ,ICD10_10

    ,ICD10_11

    ,ICD10_12

    ,DoctorID

    ,POSTypeID

    ,FacilityID

    ,ReferralID

    ,SalesrepID

    ,LocationID

    ,ClaimNote

    ,UserField1

    ,UserField2

    ,1 as LastUpdateUserID

    FROM tbl_order

    WHERE (ID = P_OrderID); --



    SELECT LAST_INSERT_ID() INTO V_NewOrderID; --



    -- add line items to order

    INSERT INTO tbl_orderdetails

    (CustomerID

    ,OrderID

    ,InventoryItemID

    ,PriceCodeID

    ,SaleRentType

    ,BillablePrice

    ,AllowablePrice

    ,Taxable

    ,FlatRate

    ,DOSFrom

    ,DOSTo

    ,SerialNumber

    ,PickupDate

    ,ShowSpanDates

    -- ordered

    ,OrderedQuantity

    ,OrderedUnits

    ,OrderedWhen

    ,OrderedConverter

    -- billed

    ,BilledQuantity

    ,BilledUnits

    ,BilledWhen

    ,BilledConverter

    -- delivery

    ,DeliveryQuantity

    ,DeliveryUnits

    ,DeliveryConverter

    -- other

    ,BillingMonth

    ,BillingCode

    ,Modifier1

    ,Modifier2

    ,Modifier3

    ,Modifier4

    ,DXPointer

    ,DXPointer10

    ,DrugNoteField

    ,DrugControlNumber

    ,BillItemOn

    ,AuthorizationNumber

    ,AuthorizationTypeID

    ,AuthorizationExpirationDate

    ,ReasonForPickup

    ,SendCMN_RX_w_invoice

    ,MedicallyUnnecessary

    ,SpecialCode

    ,ReviewCode

    ,ReoccuringID

    ,HaoDescription

    ,CMNFormID

    ,WarehouseID

    ,BillIns1

    ,BillIns2

    ,BillIns3

    ,BillIns4

    ,NopayIns1

    ,AcceptAssignment

    ,UserField1

    ,UserField2)

    SELECT

     CustomerID

    ,OrderID

    ,InventoryItemID

    ,PriceCodeID

    ,SaleRentType

    ,BillablePrice

    ,AllowablePrice

    ,Taxable

    ,FlatRate

    ,DOSFrom

    ,DOSTo

    ,SerialNumber

    ,PickupDate

    ,ShowSpanDates

    -- ordered

    ,OrderedQuantity

    ,OrderedUnits

    ,OrderedWhen

    ,OrderedConverter

    -- billed

    ,BilledQuantity

    ,BilledUnits

    ,BilledWhen

    ,BilledConverter

    -- delivery

    ,DeliveryQuantity

    ,DeliveryUnits

    ,DeliveryConverter

    -- other

    ,BillingMonth

    ,BillingCode

    ,Modifier1

    ,Modifier2

    ,Modifier3

    ,Modifier4

    ,DXPointer

    ,DXPointer10

    ,DrugNoteField

    ,DrugControlNumber

    ,BillItemOn

    ,AuthorizationNumber

    ,AuthorizationTypeID

    ,AuthorizationExpirationDate

    ,ReasonForPickup

    ,SendCMN_RX_w_invoice

    ,MedicallyUnnecessary

    ,SpecialCode

    ,ReviewCode

    ,ReoccuringID

    ,HaoDescription

    ,CMNFormID

    ,WarehouseID

    ,BillIns1

    ,BillIns2

    ,BillIns3

    ,BillIns4

    ,NopayIns1

    ,AcceptAssignment

    ,UserField1

    ,UserField2

    FROM (

        SELECT

         details.CustomerID

        ,V_NewOrderID as OrderID

        ,details.InventoryItemID

        ,details.PriceCodeID

        ,'Re-occurring Sale' as SaleRentType

        ,details.BillablePrice

        ,details.AllowablePrice

        ,details.Taxable

        ,details.FlatRate

        ,IF(details.BillingMonth <= 1, GetNextDosFrom(details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosFrom) as DOSFrom

        ,IF(details.BillingMonth <= 1, GetNextDosTo  (details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosTo  ) as DOSTo

        ,null as SerialNumber

        ,null as PickupDate

        ,details.ShowSpanDates

        -- ordered

        ,details.OrderedQuantity

        ,details.OrderedUnits

        ,details.OrderedWhen

        ,details.OrderedConverter

        -- billed

        -- ,details.BilledQuantity

        ,OrderedQty2BilledQty(

            IF(details.BillingMonth <= 1, GetNextDosFrom(details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosFrom),

            IF(details.BillingMonth <= 1, GetNextDosTo  (details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosTo  ),

            details.OrderedQuantity, details.OrderedWhen, details.BilledWhen,

            details.OrderedConverter, details.DeliveryConverter, details.BilledConverter) as BilledQuantity

        ,details.BilledUnits

        ,details.BilledWhen

        ,details.BilledConverter

        -- delivery

        -- ,details.DeliveryQuantity

        ,OrderedQty2DeliveryQty(

            IF(details.BillingMonth <= 1, GetNextDosFrom(details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosFrom),

            IF(details.BillingMonth <= 1, GetNextDosTo  (details.DosFrom, details.DosTo, details.ActualBilledWhen), details.DosTo  ),

            details.OrderedQuantity, details.OrderedWhen, details.BilledWhen,

            details.OrderedConverter, details.DeliveryConverter, details.BilledConverter) as DeliveryQuantity

        ,details.DeliveryUnits

        ,details.DeliveryConverter

        -- other

        ,1 as BillingMonth

        ,details.BillingCode

        ,details.Modifier1

        ,details.Modifier2

        ,details.Modifier3

        ,details.Modifier4

        ,details.DXPointer

        ,details.DXPointer10

        ,details.DrugNoteField

        ,details.DrugControlNumber

        ,details.BillItemOn

        ,details.AuthorizationNumber

        ,details.AuthorizationTypeID

        ,details.AuthorizationExpirationDate

        ,null as ReasonForPickup

        ,details.SendCMN_RX_w_invoice

        ,details.MedicallyUnnecessary

        ,details.SpecialCode

        ,details.ReviewCode

        ,details.ID as ReoccuringID

        ,details.HaoDescription

        ,details.CMNFormID

        ,details.WarehouseID

        ,details.BillIns1

        ,details.BillIns2

        ,details.BillIns3

        ,details.BillIns4

        ,details.NopayIns1

        ,details.AcceptAssignment

        ,details.UserField1

        ,details.UserField2

        FROM view_orderdetails as details

             INNER JOIN tbl_order ON details.CustomerID = tbl_order.CustomerID

                                 AND details.OrderID    = tbl_order.ID

        WHERE (details.OrderID = P_OrderID)

          AND (details.BilledWhen = P_BilledWhen)

          AND (details.BilledWhen != 'One Time')

          AND (details.ActualBillItemOn = P_BillItemOn)

          AND (details.SaleRentType = 'Re-occurring Sale')

    ) as `tmp`; --

  END IF; --



  -- update source line items -- mark them as one time sales

  UPDATE view_orderdetails as details

         INNER JOIN tbl_order ON details.CustomerID = tbl_order.CustomerID

                             AND details.OrderID    = tbl_order.ID

  SET details.SaleRentType = 'One Time Sale'

  WHERE (details.OrderID = P_OrderID)

    AND (details.BilledWhen = P_BilledWhen)

    AND (details.ActualBillItemOn = P_BillItemOn)

    AND (details.SaleRentType = 'Re-occurring Sale'); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `process_reoccuring_purchaseorder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `process_reoccuring_purchaseorder`(P_PurchaseOrderID INT)
BEGIN

    -- reoccuring purchase order support

    DECLARE V_NewOrderID INT; --



    -- create order

    INSERT INTO tbl_purchaseorder

      (Approved

      ,Reoccuring

      ,Cost

      ,Freight

      ,Tax

      ,TotalDue

      ,VendorID

      ,ShipToName

      ,ShipToAddress1

      ,ShipToAddress2

      ,ShipToCity

      ,ShipToState

      ,ShipToZip

      ,ShipToPhone

      ,OrderDate

      ,CompanyName

      ,CompanyAddress1

      ,CompanyAddress2

      ,CompanyCity

      ,CompanyState

      ,CompanyZip

      ,ShipVia

      ,FOB

      ,VendorSalesRep

      ,Terms

      ,CompanyPhone

      ,TaxRateID

      ,LastUpdateUserID)

    SELECT

       Approved

      ,Reoccuring

      ,Cost

      ,Freight

      ,Tax

      ,TotalDue

      ,VendorID

      ,ShipToName

      ,ShipToAddress1

      ,ShipToAddress2

      ,ShipToCity

      ,ShipToState

      ,ShipToZip

      ,ShipToPhone

      ,OrderDate

      ,CompanyName

      ,CompanyAddress1

      ,CompanyAddress2

      ,CompanyCity

      ,CompanyState

      ,CompanyZip

      ,ShipVia

      ,FOB

      ,VendorSalesRep

      ,Terms

      ,CompanyPhone

      ,TaxRateID

      ,LastUpdateUserID

    FROM

    (

        SELECT

             0 as Approved

            ,1 as Reoccuring

            ,Cost

            ,Freight

            ,Tax

            ,TotalDue

            ,VendorID

            ,ShipToName

            ,ShipToAddress1

            ,ShipToAddress2

            ,ShipToCity

            ,ShipToState

            ,ShipToZip

            ,ShipToPhone

            ,DATE_ADD(OrderDate, INTERVAL 1 MONTH) as OrderDate

            ,CompanyName

            ,CompanyAddress1

            ,CompanyAddress2

            ,CompanyCity

            ,CompanyState

            ,CompanyZip

            ,ShipVia

            ,FOB

            ,VendorSalesRep

            ,Terms

            ,CompanyPhone

            ,TaxRateID

            ,0 as LastUpdateUserID

        FROM tbl_purchaseorder

        WHERE (Reoccuring = 1)

          AND (ID = P_PurchaseOrderID)

    ) as `tmp`; --



    SELECT LAST_INSERT_ID() INTO V_NewOrderID; --



  IF V_NewOrderID <> 0 THEN

    -- add line items to order

    INSERT INTO tbl_purchaseorderdetails

      (BackOrder

      ,Ordered

      ,Received

      ,Price

      ,Customer

      ,DatePromised

      ,DateReceived

      ,DropShipToCustomer

      ,InventoryItemID

      ,PurchaseOrderID

      ,WarehouseID

      ,LastUpdateUserID

      ,LastUpdateDatetime

      ,VendorSTKNumber

      ,ReferenceNumber)

    SELECT

       BackOrder

      ,Ordered

      ,Received

      ,Price

      ,Customer

      ,DatePromised

      ,DateReceived

      ,DropShipToCustomer

      ,InventoryItemID

      ,PurchaseOrderID

      ,WarehouseID

      ,LastUpdateUserID

      ,LastUpdateDatetime

      ,VendorSTKNumber

      ,ReferenceNumber

    FROM (

        SELECT

           0 as BackOrder

          ,Ordered as Ordered

          ,0 as Received

          ,Price

          ,Customer

          ,DATE_ADD(DatePromised, INTERVAL 1 MONTH) as DatePromised

          ,null as DateReceived

          ,DropShipToCustomer

          ,InventoryItemID

          ,V_NewOrderID as PurchaseOrderID

          ,WarehouseID

          ,LastUpdateUserID

          ,CURRENT_DATE as LastUpdateDatetime

          ,VendorSTKNumber

          ,ReferenceNumber

        FROM tbl_purchaseorderdetails

        WHERE (PurchaseOrderID = P_PurchaseOrderID)

    ) as `tmp`; --



    -- update source -- mark them as one time sales

    UPDATE tbl_purchaseorder

    SET Reoccuring = 0

    WHERE (Reoccuring = 1)

      AND (ID = P_PurchaseOrderID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PurchaseOrder_UpdateTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PurchaseOrder_UpdateTotals`(P_PurchaseOrderID INT)
BEGIN

  DECLARE V_Cost double; --



  SELECT Sum(Price * Ordered)

  INTO V_Cost

  FROM tbl_purchaseorderdetails

  WHERE (PurchaseOrderID = P_PurchaseOrderID); --



  UPDATE tbl_purchaseorder

  SET Cost = IfNull(V_Cost, 0),

      TotalDue = IfNull(V_Cost, 0) + IfNull(Freight, 0) + IfNull(Tax, 0)

  WHERE (ID = P_PurchaseOrderID); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `retailinvoice_addpayments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `retailinvoice_addpayments`( P_InvoiceID INT

, P_TransactionDate DATETIME

, P_Extra TEXT

, P_LastUpdateUserID SMALLINT)
BEGIN

  DECLARE V_InvoiceDetailsID INT; --

  DECLARE V_Amount DECIMAL(18, 2); --

  DECLARE V_Extra TEXT; --

  DECLARE V_NewXml VARCHAR(50); --

  DECLARE V_Result VARCHAR(50); --

  DECLARE done INT DEFAULT 0; --

  DECLARE cur CURSOR FOR

    SELECT ID, BillableAmount FROM tbl_invoicedetails WHERE (InvoiceID = P_InvoiceID); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  DETAILS_LOOP: LOOP

    FETCH cur INTO V_InvoiceDetailsID, V_Amount; --



    IF done THEN

      LEAVE DETAILS_LOOP; --

    END IF; --



    SET V_NewXml = CONCAT('<v n="Paid">', CAST(V_Amount as CHAR), '</v>'); --

    SET V_Extra = UpdateXML(P_Extra, 'values/v[@n="Paid"]' COLLATE latin1_general_ci, V_NewXml COLLATE latin1_general_ci); --



    CALL `InvoiceDetails_AddPayment`

    ( V_InvoiceDetailsID

    , NULL -- P_InsuranceCompanyID

    , P_TransactionDate

    , V_Extra

    , '' -- P_Comments

    , '' -- P_Options

    , P_LastUpdateUserID

    , V_Result); --

  END LOOP DETAILS_LOOP; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serials_fix` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serials_fix`()
BEGIN

  DECLARE V_Count, V_WarehouseID INT; --

  DECLARE cur_ID, cur_WarehouseID INT; --

  DECLARE done INT DEFAULT 0; --



  DECLARE cur CURSOR FOR

    SELECT

      tbl_serial.ID

    , tbl_warehouse.ID as WarehouseID

    FROM tbl_serial

         LEFT JOIN tbl_warehouse ON tbl_serial.WarehouseID = tbl_warehouse.ID

    WHERE tbl_serial.ID NOT IN (SELECT SerialID FROM tbl_serial_transaction); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  SELECT Count(*), Min(ID)

  INTO V_Count, V_WarehouseID

  FROM tbl_warehouse; --



  IF V_Count = 0 THEN

    INSERT INTO tbl_warehouse SET

      `Address1` = '',

      `Address2` = '',

      `City`     = '',

      `Contact`  = '',

      `Fax`      = '',

      `Name`     = 'Default warehouse',

      `Phone`    = '',

      `Phone2`   = '',

      `State`    = '',

      `Zip`      = '',

      `LastUpdateUserID` = 1; --



    SELECT LAST_INSERT_ID()

    INTO V_WarehouseID; --

  END IF; --



  OPEN cur; --



  REPEAT

    FETCH cur

    INTO cur_ID, cur_WarehouseID; --



    IF NOT done THEN

      SET cur_WarehouseID = IFNULL(cur_WarehouseID, V_WarehouseID); --



      CALL serial_add_transaction(

         'Transferred In' -- P_TranType         VARCHAR(50),

        ,Now()            -- P_TranTime         DATETIME,

        ,cur_ID           -- P_SerialID         INT,

        ,cur_WarehouseID  -- P_WarehouseID      INT,

        ,null             -- P_VendorID         INT,

        ,null             -- P_CustomerID       INT,

        ,null             -- P_OrderID          INT,

        ,null             -- P_OrderDetailsID   INT,

        ,null             -- P_LotNumber        VARCHAR(50),

        ,null             -- P_LastUpdateUserID INT

        ); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serials_po_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serials_po_refresh`(P_PurchaseOrderID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --

  DECLARE V_SerialID, V_VendorID, V_InventoryItemID, V_WarehouseID INT; --

  DECLARE V_ReceivedDate DATETIME; --

  DECLARE V_ReceivedQuantity, V_SerialCount INT; --

  DECLARE V_PurchasePrice decimal(18, 2); --

  DECLARE cur CURSOR FOR

      SELECT

        tbl_purchaseorder.VendorID,

        tbl_purchaseorderdetails.InventoryItemID,

        tbl_purchaseorderdetails.WarehouseID,

        MAX(tbl_purchaseorderdetails.DateReceived) as ReceivedDate,

        SUM(tbl_purchaseorderdetails.Received) as ReceivedQuantity,

        tbl_purchaseorderdetails.Price as PurchasePrice

      FROM tbl_purchaseorder

           INNER JOIN tbl_purchaseorderdetails ON tbl_purchaseorder.ID = tbl_purchaseorderdetails.PurchaseOrderID

           INNER JOIN tbl_inventoryitem ON tbl_purchaseorderdetails.InventoryItemID = tbl_inventoryitem.ID

      WHERE (tbl_purchaseorder.ID = P_PurchaseOrderID)

        AND (tbl_inventoryitem.Serialized = 1)

      GROUP BY tbl_purchaseorder.VendorID, tbl_purchaseorderdetails.InventoryItemID, tbl_purchaseorderdetails.WarehouseID; --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  DROP TABLE IF EXISTS `{A890A925-A355-44AA-AA99-D28A52F7DF0D}`; --



  CREATE TEMPORARY TABLE `{A890A925-A355-44AA-AA99-D28A52F7DF0D}` (SerialID INT); --



  IF EXISTS (SELECT * FROM tbl_purchaseorder WHERE Approved = 1 AND ID = P_PurchaseOrderID) THEN

    OPEN cur; --



    REPEAT

      FETCH cur INTO

        V_VendorID,

        V_InventoryItemID,

        V_WarehouseID,

        V_ReceivedDate,

        V_ReceivedQuantity,

        V_PurchasePrice; --



      IF NOT done THEN

        SET V_SerialCount = V_ReceivedQuantity; --



        SELECT Count(*)

        INTO V_SerialCount

        FROM tbl_serial

        WHERE (WarehouseID = V_WarehouseID)

          AND (InventoryItemID = V_InventoryItemID)

          AND (VendorID = V_VendorID)

          AND (PurchaseOrderID = P_PurchaseOrderID); --



        WHILE (V_SerialCount < V_ReceivedQuantity) DO

          INSERT INTO tbl_serial (WarehouseID, InventoryItemID, VendorID, PurchaseOrderID, PurchaseDate, PurchaseAmount, Status)

          VALUES (V_WarehouseID, V_InventoryItemID, V_VendorID, P_PurchaseOrderID, V_ReceivedDate, V_PurchasePrice, 'On Hand'); --



          SELECT LAST_INSERT_ID() INTO V_SerialID; --



          INSERT INTO `{A890A925-A355-44AA-AA99-D28A52F7DF0D}` (SerialID) VALUES (V_SerialID); --



          SET V_SerialCount = V_SerialCount + 1; --

        END WHILE; --

      END IF; --

    UNTIL done END REPEAT; --



    CLOSE cur; --

  END IF; --



  SELECT SerialID FROM `{A890A925-A355-44AA-AA99-D28A52F7DF0D}`; --



  DROP TABLE `{A890A925-A355-44AA-AA99-D28A52F7DF0D}`; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serials_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serials_refresh`()
BEGIN

  DECLARE V_SerialID INT; --

  DECLARE done INT DEFAULT 0; --



  DECLARE cur CURSOR FOR

    SELECT ID

    FROM tbl_serial

    WHERE (1 = 1); --

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

      V_SerialID; --



    IF NOT done THEN

      CALL serial_refresh(V_SerialID); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serial_add_transaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serial_add_transaction`( P_TranType         VARCHAR(50)

, P_TranTime         DATETIME

, P_SerialID         INT

, P_WarehouseID      INT

, P_VendorID         INT

, P_CustomerID       INT

, P_OrderID          INT

, P_OrderDetailsID   INT

, P_LotNumber        VARCHAR(50)

, P_LastUpdateUserID INT

)
BEGIN

  DECLARE done INT DEFAULT 0; --



  -- cursor variables

  DECLARE cur_TranID             int(11); --

  DECLARE cur_TranExists         int(11); --

  DECLARE cur_TranTypeID         int(11); --

  DECLARE cur_TranType           varchar(50); --

  DECLARE cur_TranTime           datetime; --

  DECLARE cur_VendorID           int(11); --

  DECLARE cur_WarehouseID        int(11); --

  DECLARE cur_CustomerID         int(11); --

  DECLARE cur_OrderID            int(11); --

  DECLARE cur_OrderDetailsID     int(11); --

  DECLARE cur_LotNumber          varchar(50); --

  DECLARE cur_LastUpdateUserID   smallint(6); --

  DECLARE cur_LastUpdateDatetime timestamp; --



  -- variables for update

  DECLARE V_Status            varchar(20); --

  DECLARE V_VendorID          int(11); --

  DECLARE V_WarehouseID       int(11); --

  DECLARE V_LotNumber         varchar(50); --

  DECLARE V_SoldDate          date; --

  DECLARE V_CurrentCustomerID int(11); --

  DECLARE V_LastCustomerID    int(11); --

  DECLARE V_LastUpdateUserID  smallint(6); --

  DECLARE V_AcceptableTran    bool; --



  DECLARE cur CURSOR FOR

   (SELECT

     st.ID    as TranID

    ,1        as TranExists

    ,stt.ID   as TranTypeID

    ,stt.Name as TranType

    ,st.TransactionDatetime

    ,st.VendorID

    ,st.WarehouseID

    ,st.CustomerID

    ,st.OrderID

    ,st.OrderDetailsID

    ,st.LotNumber

    ,st.LastUpdateUserID

    ,st.LastUpdateDatetime

    FROM tbl_serial_transaction AS st

         INNER JOIN tbl_serial_transaction_type as stt ON st.TypeID = stt.ID

    WHERE st.SerialID = P_SerialID)

   UNION ALL

   (SELECT

     NULL                      as TranID

    ,0                         as TranExists

    ,ID                        as TranTypeID

    ,Name                      as TranType

    ,IFNULL(P_TranTime, Now()) as TransactionDatetime

    ,P_VendorID         as VendorID

    ,P_WarehouseID      as WarehouseID

    ,P_CustomerID       as CustomerID

    ,P_OrderID          as OrderID

    ,P_OrderDetailsID   as OrderDetailsID

    ,P_LotNumber        as LotNumber

    ,P_LastUpdateUserID as LastUpdateUserID

    ,Now()              as LastUpdateDatetime

    FROM tbl_serial_transaction_type

    WHERE Name = P_TranType)

   ORDER BY TranExists desc, TransactionDatetime asc, TranID asc; --



  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  IF (P_SerialID IS NOT NULL) THEN

    -- init / reinit

    SET V_Status            = 'Unknown'; --

    SET V_VendorID          = null; --

    SET V_WarehouseID       = null; --

    SET V_LotNumber         = null; --

    SET V_SoldDate          = null; --

    SET V_LastCustomerID    = null; --

    SET V_CurrentCustomerID = null; --

    SET V_LastUpdateUserID  = null; --



    OPEN cur; --



    REPEAT

      FETCH cur INTO

       cur_TranID

      ,cur_TranExists

      ,cur_TranTypeID

      ,cur_TranType

      ,cur_TranTime

      ,cur_VendorID

      ,cur_WarehouseID

      ,cur_CustomerID

      ,cur_OrderID

      ,cur_OrderDetailsID

      ,cur_LotNumber

      ,cur_LastUpdateUserID

      ,cur_LastUpdateDatetime; --



      IF (done = 0)

      AND (cur_TranTypeID IS NOT NULL)

      THEN

        SET V_AcceptableTran = 1; --



        IF (V_Status IN ('Unknown', 'On Hand')) AND (cur_TranType = 'Reserved') THEN

          -- ( 1, 'Reserved'                ), -- means that we added serial to not approved order

          SET cur_VendorID        = null; --

          SET cur_WarehouseID     = null; --

          -- SET cur_CustomerID      = null; -- we need to know for whom did we reserved that serial

          -- SET cur_OrderID         = null; --

          -- SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Reserved'; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'Reserved')) AND (cur_TranType = 'Reserve Cancelled') THEN

          -- ( 2, 'Reserve Cancelled'       ), -- means that we removed serial from not approved order

          SET cur_VendorID        = null; --

          SET cur_WarehouseID     = null; --

          SET cur_CustomerID      = null; --

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'On Hand'; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'On Hand', 'Reserved') AND cur_TranType IN ('Rented', 'Sold'))

            OR (V_Status IN ('Rented') AND cur_TranType IN ('Sold')) THEN

          -- ( 3, 'Rented'                  ), -- means that RENT order was approved

          -- ( 4, 'Sold'                    ), -- means that SALE order or RENT-TO-PURCHASE order was approved

          SET cur_VendorID        = null; --

          SET cur_WarehouseID     = null; --

          -- SET cur_CustomerID      = null; -- we need to know who rented or bought that serial

          -- SET cur_OrderID         = null; --

          -- SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = CASE WHEN cur_TranType = 'Sold' THEN cur_TranTime ELSE null END; --

          SET V_Status            = CASE cur_TranType WHEN 'Rented' THEN 'Rented' WHEN 'Sold' THEN 'Sold' ELSE null END; --

          SET V_WarehouseID       = null; --

          SET V_LastCustomerID    = V_CurrentCustomerID; --

          SET V_CurrentCustomerID = cur_CustomerID; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status != 'Maintenance') AND (cur_TranType IN ('Returned')) THEN

          -- ( 5, 'Returned'                ), -- means that user return RENTED serial

          --                                   -- but serial must be cleaned out prior to re-using

          SET cur_VendorID        = null; --

          -- SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          -- SET cur_CustomerID      = null; -- we need to know whom we returned that serial from

          -- SET cur_OrderID         = null; --

          -- SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Maintenance'; --

          SET V_WarehouseID       = cur_WarehouseID; --

          SET V_LastCustomerID    = V_CurrentCustomerID; --

          SET V_CurrentCustomerID = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (cur_TranType IN ('Lost', 'Junked')) THEN

          -- ( 6, 'Lost'                    ), -- can be added only manually to mark serial as 'Lost'

          -- ( 7, 'Junked'                  ), -- can be added only manually to mark serial as 'Junked'

          SET cur_VendorID        = null; --

          SET cur_WarehouseID     = null; --

          SET cur_CustomerID      = null; --

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = CASE cur_TranType WHEN 'Lost' THEN 'Lost' WHEN 'Junked' THEN 'Junked' ELSE null END; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'Empty')) AND (cur_TranType = 'O2 Tank out for filling') THEN

          -- ( 8, 'O2 Tank out for filling' ), -- Send    : "Empty"   -> "Sent"

          -- SET cur_VendorID        = null; -- we need to know whom we sent that serial

          SET cur_WarehouseID     = null; --

          SET cur_CustomerID      = null; --

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Sent'; --

          SET V_VendorID          = cur_VendorID; --

          SET V_WarehouseID       = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'Sent')) AND (cur_TranType = 'O2 Tank in from filling') THEN

          -- ( 9, 'O2 Tank in from filling' ), -- Receive : "Sent"    -> "On Hand"

          SET cur_VendorID        = null; --

          -- SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          SET cur_CustomerID      = null; --

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          -- SET cur_LotNumber       = null; --we need to know lot number assigned



          SET V_SoldDate          = null; --

          SET V_Status            = 'On Hand'; --

          SET V_WarehouseID       = cur_WarehouseID; --

          SET V_LotNumber         = cur_LotNumber; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'On Hand')) AND (cur_TranType = 'O2 Tank out to customer') THEN

          -- (10, 'O2 Tank out to customer' ), -- Rent    : "On Hand" -> "Rented"

          SET cur_VendorID        = null; --

          SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          -- SET cur_CustomerID      = null; -- we need to know whom we sent that serial

          -- SET cur_OrderID         = null; --

          -- SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Rented'; --

          SET V_WarehouseID       = null; --

          SET V_CurrentCustomerID = cur_CustomerID; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'Rented')) AND (cur_TranType = 'O2 Tank in from customer') THEN

          -- (11, 'O2 Tank in from customer'), -- Pickup  : "Rented"  -> "Empty"

          SET cur_VendorID        = null; --

          -- SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          SET cur_CustomerID      = null; --

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Empty'; --

          SET V_WarehouseID       = cur_WarehouseID; --

          SET V_LastCustomerID    = V_CurrentCustomerID; --

          SET V_CurrentCustomerID = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'On Hand')) AND (cur_TranType = 'Transferred Out') THEN

          -- (14, 'Transferred Out' ), -- Transferred Out  : "On Hand" -> "Transferred Out"

          SET cur_VendorID        = null; --

          SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          SET cur_CustomerID      = null; -- we need to know whom we sent that serial

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Transferred Out'; --

          SET V_WarehouseID       = null; --

          SET V_CurrentCustomerID = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'Transferred Out')) AND (cur_TranType = 'Transferred In') THEN

          -- (15, 'Transferred In' ) -- Transferred In  : "Transferred Out" -> "On Hand"

          --                                            :       <NULL>      -> "On Hand"

          -- only way to assign warehouse to serial

          SET cur_VendorID        = null; --

          -- SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          SET cur_CustomerID      = null; -- we need to know whom we sent that serial

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'On Hand'; --

          SET V_WarehouseID       = cur_WarehouseID; --

          SET V_CurrentCustomerID = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'On Hand')) AND (cur_TranType = 'Out for Maintenance') THEN

          -- (12, 'Out for Maintenance' ), -- Out for Maintenance  : "On Hand" -> "Maintenance"

          SET cur_VendorID        = null; --

          -- SET cur_WarehouseID     = null; -- we need to know where we sent that serial

          SET cur_CustomerID      = null; -- we do not need to know whom we sent that serial

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'Maintenance'; --

          SET V_WarehouseID       = cur_WarehouseID; --

          SET V_CurrentCustomerID = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSEIF (V_Status IN ('Unknown', 'Maintenance')) AND (cur_TranType = 'In from Maintenance') THEN

          -- (13, 'In from Maintenance' ) -- In from Maintenance  : "Maintenance" -> "On Hand"

          --                                                      :     <NULL>    -> "On Hand"

          -- another way to assign warehouse to serial

          SET cur_VendorID        = null; --

          -- SET cur_WarehouseID     = null; -- we need to know where we returned that serial

          SET cur_CustomerID      = null; -- we do not need to know whom we sent that serial

          SET cur_OrderID         = null; --

          SET cur_OrderDetailsID  = null; --

          SET cur_LotNumber       = null; --



          SET V_SoldDate          = null; --

          SET V_Status            = 'On Hand'; --

          SET V_WarehouseID       = cur_WarehouseID; --

          SET V_CurrentCustomerID = null; --

          SET V_LastUpdateUserID  = cur_LastUpdateUserID; --



        ELSE

          SET V_AcceptableTran = 0; --



        END IF; --



        IF (V_AcceptableTran = 1) AND (cur_TranExists = 0) THEN

          INSERT INTO tbl_serial_transaction SET

           TypeID              = cur_TranTypeID

          ,SerialID            = P_SerialID

          ,TransactionDatetime = cur_TranTime

          ,VendorID            = cur_VendorID

          ,WarehouseID         = cur_WarehouseID

          ,CustomerID          = cur_CustomerID

          ,OrderID             = cur_OrderID

          ,OrderDetailsID      = cur_OrderDetailsID

          ,LotNumber           = IFNULL(cur_LotNumber, '')

          ,LastUpdateDatetime  = IFNULL(cur_LastUpdateDatetime, Now())

          ,LastUpdateUserID    = IFNULL(cur_LastUpdateUserID, 1); -- root

        END IF; --



      END IF; --

    UNTIL done END REPEAT; --



    CLOSE cur; --



    -- save into db

    UPDATE tbl_serial SET

      Status            = CASE WHEN V_Status = 'Unknown' THEN 'On Hand' ELSE V_Status END

    , VendorID          = V_VendorID

    , WarehouseID       = V_WarehouseID

    , LotNumber         = IFNULL(V_LotNumber, '')

    , SoldDate          = V_SoldDate

    , CurrentCustomerID = V_CurrentCustomerID

    , LastCustomerID    = V_LastCustomerID

    , LastUpdateUserID  = IFNULL(V_LastUpdateUserID, 1) -- root

    WHERE (ID = P_SerialID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serial_order_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serial_order_refresh`(P_OrderID INT)
BEGIN

  DECLARE done INT DEFAULT 0; --



  -- cursor variables

  DECLARE cur_Priority         int(11); --

  DECLARE cur_CustomerID       int(11); --

  DECLARE cur_OrderID          int(11); --

  DECLARE cur_OrderDetailsID   int(11); --

  DECLARE cur_SerialID         int(11); --

  DECLARE cur_WarehouseID      int(11); --

  DECLARE cur_TranType         varchar(50); --

  DECLARE cur_TranTime         datetime; --



  DECLARE cur CURSOR FOR

    (

     SELECT

      1 as Priority

     ,view_orderdetails.CustomerID

     ,view_orderdetails.OrderID

     ,view_orderdetails.ID as OrderDetailsID

     ,view_orderdetails.SerialID

     ,null as WarehouseID

     ,'Reserved' as TranType

     ,IFNULL(tbl_order.OrderDate, Now()) as TranTime

     FROM tbl_order

          INNER JOIN view_orderdetails ON view_orderdetails.CustomerID = tbl_order.CustomerID

                                      AND view_orderdetails.OrderID    = tbl_order.ID

          INNER JOIN tbl_serial ON view_orderdetails.SerialID        = tbl_serial.ID -- serial exists

                               AND view_orderdetails.InventoryItemID = tbl_serial.InventoryItemID

          INNER JOIN tbl_serial_transaction_type as stt ON stt.Name = 'Reserved'

          LEFT JOIN tbl_serial_transaction as LastTran ON LastTran.CustomerID     = view_orderdetails.CustomerID

                                                      AND LastTran.OrderID        = view_orderdetails.OrderID

                                                      AND LastTran.OrderDetailsID = view_orderdetails.ID

                                                      AND LastTran.TypeID         = stt.ID

          LEFT JOIN (SELECT SerialID, Max(ID) as MaxID

                     FROM tbl_serial_transaction

                     GROUP BY SerialID) as TranHistory ON LastTran.SerialID = TranHistory.SerialID

                                                      AND LastTran.ID       = TranHistory.MaxID

     WHERE (tbl_order.Approved = 0) -- we reserve only for not approved orders

       AND ((LastTran.ID IS NULL) OR (TranHistory.SerialID IS NULL))

       AND ((tbl_order.ID = P_OrderID) OR (P_OrderID IS NULL))

    ) UNION ALL (

     SELECT

      2 as Priority

     ,LastTran.CustomerID

     ,LastTran.OrderID

     ,LastTran.OrderDetailsID

     ,LastTran.SerialID

     ,null as WarehouseID

     ,'Reserve Cancelled' as TranType

     ,Now() as TranTime

     FROM (SELECT SerialID, Max(ID) as MaxID

           FROM tbl_serial_transaction

           GROUP BY SerialID) as TranHistory

          INNER JOIN tbl_serial_transaction as LastTran ON LastTran.SerialID = TranHistory.SerialID

                                                       AND LastTran.ID       = TranHistory.MaxID

          INNER JOIN tbl_serial_transaction_type ON tbl_serial_transaction_type.ID   = LastTran.TypeID

                                                AND tbl_serial_transaction_type.Name = 'Reserved'

          INNER JOIN tbl_serial ON TranHistory.SerialID = tbl_serial.ID

          LEFT JOIN view_orderdetails ON LastTran.CustomerID     =  view_orderdetails.CustomerID

                                     AND LastTran.OrderID        =  view_orderdetails.OrderID

                                     AND LastTran.OrderDetailsID =  view_orderdetails.ID

          LEFT JOIN tbl_order ON view_orderdetails.CustomerID = tbl_order.CustomerID

                             AND view_orderdetails.OrderID    = tbl_order.ID

     WHERE ((view_orderdetails.SerialID IS NULL) OR (view_orderdetails.SerialID != LastTran.SerialID))

       AND ((LastTran.OrderID = P_OrderID) OR (P_OrderID IS NULL))

    ) UNION ALL (

     SELECT DISTINCT

      3 as Priority

     ,view_orderdetails.CustomerID

     ,view_orderdetails.OrderID

     ,view_orderdetails.ID as OrderDetailsID

     ,view_orderdetails.SerialID

     ,null as WarehouseID

     ,'Rented' as TranType

     ,IFNULL(tbl_order.DeliveryDate, IFNULL(tbl_order.OrderDate, Now())) as TranTime

     FROM tbl_order

          INNER JOIN view_orderdetails ON view_orderdetails.CustomerID = tbl_order.CustomerID

                                      AND view_orderdetails.OrderID    = tbl_order.ID

          INNER JOIN tbl_serial ON view_orderdetails.SerialID        = tbl_serial.ID -- serial exists

                               AND view_orderdetails.InventoryItemID = tbl_serial.InventoryItemID

          INNER JOIN tbl_serial_transaction_type as stt ON stt.Name = 'Rented'

          LEFT JOIN tbl_serial_transaction as st ON st.CustomerID     = view_orderdetails.CustomerID

                                                AND st.OrderID        = view_orderdetails.OrderID

                                                AND st.OrderDetailsID = view_orderdetails.ID

                                                AND st.SerialID       = view_orderdetails.SerialID

                                                AND st.TypeID         = stt.ID

     WHERE (tbl_order.Approved = 1)

       AND (view_orderdetails.IsRented = 1)

       AND (st.ID IS NULL)

       AND ((tbl_order.ID = P_OrderID) OR (P_OrderID IS NULL))

    ) UNION ALL (

     SELECT DISTINCT

      3 as Priority

     ,view_orderdetails.CustomerID

     ,view_orderdetails.OrderID

     ,view_orderdetails.ID as OrderDetailsID

     ,view_orderdetails.SerialID

     ,null as WarehouseID

     ,'Sold' as TranType

     ,IFNULL(tbl_order.DeliveryDate, IFNULL(tbl_order.OrderDate, Now())) as TranTime

     FROM tbl_order

          INNER JOIN view_orderdetails ON view_orderdetails.CustomerID = tbl_order.CustomerID

                                      AND view_orderdetails.OrderID    = tbl_order.ID

          INNER JOIN tbl_serial ON view_orderdetails.SerialID        = tbl_serial.ID -- serial exists

                               AND view_orderdetails.InventoryItemID = tbl_serial.InventoryItemID

          INNER JOIN tbl_serial_transaction_type as stt ON stt.Name = 'Sold'

          LEFT JOIN tbl_serial_transaction as st ON st.CustomerID     = view_orderdetails.CustomerID

                                                AND st.OrderID        = view_orderdetails.OrderID

                                                AND st.OrderDetailsID = view_orderdetails.ID

                                                AND st.SerialID       = view_orderdetails.SerialID

                                                AND st.TypeID         = stt.ID

     WHERE (tbl_order.Approved = 1)

       AND (view_orderdetails.IsSold = 1)

       AND (st.ID IS NULL)

       AND ((tbl_order.ID = P_OrderID) OR (P_OrderID IS NULL))

    ) UNION ALL (

     SELECT DISTINCT

      4 as Priority

     ,view_orderdetails.CustomerID

     ,view_orderdetails.OrderID

     ,view_orderdetails.ID as OrderDetailsID

     ,view_orderdetails.SerialID

     ,view_orderdetails.WarehouseID

     ,'Returned' as TranType

     ,IFNULL(view_orderdetails.EndDate, Now()) as TranTime

     FROM tbl_order

          INNER JOIN view_orderdetails ON view_orderdetails.CustomerID = tbl_order.CustomerID

                                      AND view_orderdetails.OrderID    = tbl_order.ID

          INNER JOIN tbl_serial ON view_orderdetails.SerialID        = tbl_serial.ID -- serial exists

                               AND view_orderdetails.InventoryItemID = tbl_serial.InventoryItemID

          INNER JOIN tbl_serial_transaction_type as stt ON stt.Name = 'Returned'

          LEFT JOIN tbl_serial_transaction as st ON st.CustomerID     = view_orderdetails.CustomerID

                                                AND st.OrderID        = view_orderdetails.OrderID

                                                AND st.OrderDetailsID = view_orderdetails.ID

                                                AND st.SerialID       = view_orderdetails.SerialID

                                                AND st.TypeID         = stt.ID

     WHERE (tbl_order.Approved = 1)

       AND (view_orderdetails.IsCanceled = 0)

       AND (view_orderdetails.IsPickedup = 1)

       AND (view_orderdetails.IsRented = 1)

       AND (st.ID IS NULL)

       AND ((tbl_order.ID = P_OrderID) OR (P_OrderID IS NULL))

    ) UNION ALL (

     SELECT DISTINCT

      5 as Priority

     ,view_orderdetails.CustomerID

     ,view_orderdetails.OrderID

     ,view_orderdetails.ID as OrderDetailsID

     ,view_orderdetails.SerialID

     ,null as WarehouseID

     ,'Sold' as TranType

     ,IFNULL(view_orderdetails.EndDate, Now()) as TranTime

     FROM tbl_order

          INNER JOIN view_orderdetails ON view_orderdetails.CustomerID = tbl_order.CustomerID

                                      AND view_orderdetails.OrderID    = tbl_order.ID

          INNER JOIN tbl_serial ON view_orderdetails.SerialID        = tbl_serial.ID -- serial exists

                               AND view_orderdetails.InventoryItemID = tbl_serial.InventoryItemID

          INNER JOIN tbl_serial_transaction_type as stt ON stt.Name = 'Sold'

          LEFT JOIN tbl_serial_transaction as st ON st.CustomerID     = view_orderdetails.CustomerID

                                                AND st.OrderID        = view_orderdetails.OrderID

                                                AND st.OrderDetailsID = view_orderdetails.ID

                                                AND st.SerialID       = view_orderdetails.SerialID

                                                AND st.TypeID         = stt.ID

     WHERE (tbl_order.Approved = 1)

       AND (view_orderdetails.IsActive = 0)

       AND (view_orderdetails.IsCanceled = 0)

       AND (view_orderdetails.IsPickedup = 0)

       AND (view_orderdetails.IsRented = 1)

       AND (st.ID IS NULL)

       AND ((tbl_order.ID = P_OrderID) OR (P_OrderID IS NULL))

    ) ORDER BY SerialID, Priority, TranTime; --



  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; --



  OPEN cur; --



  REPEAT

    FETCH cur INTO

     cur_Priority

    ,cur_CustomerID

    ,cur_OrderID

    ,cur_OrderDetailsID

    ,cur_SerialID

    ,cur_WarehouseID

    ,cur_TranType

    ,cur_TranTime; --



    IF (done = 0) THEN

      CALL serial_add_transaction(

          cur_TranType       -- P_TranType         VARCHAR(50)

        , cur_TranTime       -- P_TranTime         DATETIME

        , cur_SerialID       -- P_SerialID         INT,

        , cur_WarehouseID    -- P_WarehouseID      INT,

        , null               -- P_VendorID         INT,

        , cur_CustomerID     -- P_CustomerID       INT,

        , cur_OrderID        -- P_OrderID          INT,

        , cur_OrderDetailsID -- P_OrderDetailsID   INT,

        , null               -- P_LotNumber        VARCHAR(50),

        , 1                  -- P_LastUpdateUserID INT

      ); --

    END IF; --

  UNTIL done END REPEAT; --



  CLOSE cur; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serial_refresh` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serial_refresh`(P_SerialID INT)
BEGIN

  CALL serial_add_transaction

  ( null       -- P_TranType         VARCHAR(50)

  , null       -- P_TranTime         DATETIME

  , P_SerialID -- P_SerialID         INT

  , null       -- P_WarehouseID      INT

  , null       -- P_VendorID         INT

  , null       -- P_CustomerID       INT

  , null       -- P_OrderID          INT

  , null       -- P_OrderDetailsID   INT

  , null       -- P_LotNumber        VARCHAR(50)

  , null       -- P_LastUpdateUserID INT

  ); --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serial_transfer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serial_transfer`(

  P_SerialID INT

, P_SrcWarehouseID   INT

, P_DstWarehouseID   INT

, P_LastUpdateUserID INT

)
BEGIN

  DECLARE V_SerialID, V_InventoryItemID, V_CountBefore, V_CountAfter INT; --



  SELECT tbl_serial.ID, tbl_serial.InventoryItemID

  INTO V_SerialID, V_InventoryItemID

  FROM tbl_serial

  WHERE ID = P_SerialID; --



  IF (V_SerialID IS NOT NULL) THEN

    SELECT Count(*)

    INTO V_CountBefore

    FROM tbl_serial_transaction

    WHERE SerialID = V_SerialID; --



    CALL serial_add_transaction(

       'Transferred Out'  -- P_TranType         VARCHAR(50),

      ,Now()              -- P_TranTime         DATETIME,

      ,V_SerialID         -- P_SerialID         INT,

      ,P_SrcWarehouseID   -- P_WarehouseID      INT,

      ,null               -- P_VendorID         INT,

      ,null               -- P_CustomerID       INT,

      ,null               -- P_OrderID          INT,

      ,null               -- P_OrderDetailsID   INT,

      ,null               -- P_LotNumber        VARCHAR(50),

      ,P_LastUpdateUserID -- P_LastUpdateUserID INT

      ); --



    CALL serial_add_transaction(

       'Transferred In'   -- P_TranType         VARCHAR(50),

      ,Now()              -- P_TranTime         DATETIME,

      ,V_SerialID         -- P_SerialID         INT,

      ,P_DstWarehouseID   -- P_WarehouseID      INT,

      ,null               -- P_VendorID         INT,

      ,null               -- P_CustomerID       INT,

      ,null               -- P_OrderID          INT,

      ,null               -- P_OrderDetailsID   INT,

      ,null               -- P_LotNumber        VARCHAR(50),

      ,P_LastUpdateUserID -- P_LastUpdateUserID INT

      ); --



    SELECT Count(*)

    INTO V_CountAfter

    FROM tbl_serial_transaction

    WHERE SerialID = V_SerialID; --



    IF V_CountAfter - V_CountBefore = 2 THEN

      CALL internal_inventory_transfer(

        V_InventoryItemID

      , P_SrcWarehouseID

      , P_DstWarehouseID

      , 1

      , CONCAT('Serial #', V_SerialID, ' Transfer')

      , P_LastUpdateUserID); --

    END IF; --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `serial_update_transaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `serial_update_transaction`( P_TransactionID    INT

, P_TranTime         DATETIME

, P_WarehouseID      INT

, P_VendorID         INT

, P_CustomerID       INT

, P_LotNumber        VARCHAR(50)

, P_LastUpdateUserID INT

)
BEGIN

  DECLARE V_SerialID INT; --



  SELECT SerialID

  INTO V_SerialID

  FROM tbl_serial_transaction

  WHERE ID = P_TransactionID; --



  IF V_SerialID IS NOT NULL THEN

    UPDATE tbl_serial_transaction SET

      TransactionDatetime = IFNULL(P_TranTime, Now())

    , VendorID            = P_VendorID

    , WarehouseID         = P_WarehouseID

    , CustomerID          = IF(OrderID IS NOT NULL OR OrderDetailsID IS NOT NULL, CustomerID, P_CustomerID)

    , LotNumber           = IFNULL(P_LotNumber, '')

    , LastUpdateDatetime  = Now()

    , LastUpdateUserID    = IFNULL(P_LastUpdateUserID, 1) -- root

    WHERE ID = P_TransactionID; --



    CALL serial_refresh(V_SerialID); --

  END IF; --

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `tbl_ability_eligibility_payer`
--

/*!50001 DROP VIEW IF EXISTS `tbl_ability_eligibility_payer`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_ability_eligibility_payer` AS select `dmeworks`.`tbl_ability_eligibility_payer`.`Id` AS `Id`,`dmeworks`.`tbl_ability_eligibility_payer`.`Code` AS `Code`,`dmeworks`.`tbl_ability_eligibility_payer`.`Name` AS `Name`,`dmeworks`.`tbl_ability_eligibility_payer`.`Comments` AS `Comments`,`dmeworks`.`tbl_ability_eligibility_payer`.`SearchOptions` AS `SearchOptions`,`dmeworks`.`tbl_ability_eligibility_payer`.`AllowsSubmission` AS `AllowsSubmission` from `dmeworks`.`tbl_ability_eligibility_payer` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_doctor`
--

/*!50001 DROP VIEW IF EXISTS `tbl_doctor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_doctor` AS select `dmeworks`.`tbl_doctor`.`Address1` AS `Address1`,`dmeworks`.`tbl_doctor`.`Address2` AS `Address2`,`dmeworks`.`tbl_doctor`.`City` AS `City`,`dmeworks`.`tbl_doctor`.`Contact` AS `Contact`,`dmeworks`.`tbl_doctor`.`Courtesy` AS `Courtesy`,`dmeworks`.`tbl_doctor`.`Fax` AS `Fax`,`dmeworks`.`tbl_doctor`.`FirstName` AS `FirstName`,`dmeworks`.`tbl_doctor`.`ID` AS `ID`,`dmeworks`.`tbl_doctor`.`LastName` AS `LastName`,`dmeworks`.`tbl_doctor`.`LicenseNumber` AS `LicenseNumber`,`dmeworks`.`tbl_doctor`.`LicenseExpired` AS `LicenseExpired`,`dmeworks`.`tbl_doctor`.`MedicaidNumber` AS `MedicaidNumber`,`dmeworks`.`tbl_doctor`.`MiddleName` AS `MiddleName`,`dmeworks`.`tbl_doctor`.`OtherID` AS `OtherID`,`dmeworks`.`tbl_doctor`.`FEDTaxID` AS `FEDTaxID`,`dmeworks`.`tbl_doctor`.`DEANumber` AS `DEANumber`,`dmeworks`.`tbl_doctor`.`Phone` AS `Phone`,`dmeworks`.`tbl_doctor`.`Phone2` AS `Phone2`,`dmeworks`.`tbl_doctor`.`State` AS `State`,`dmeworks`.`tbl_doctor`.`Suffix` AS `Suffix`,`dmeworks`.`tbl_doctor`.`Title` AS `Title`,`dmeworks`.`tbl_doctor`.`TypeID` AS `TypeID`,`dmeworks`.`tbl_doctor`.`UPINNumber` AS `UPINNumber`,`dmeworks`.`tbl_doctor`.`Zip` AS `Zip`,`dmeworks`.`tbl_doctor`.`LastUpdateUserID` AS `LastUpdateUserID`,`dmeworks`.`tbl_doctor`.`LastUpdateDatetime` AS `LastUpdateDatetime`,`dmeworks`.`tbl_doctor`.`MIR` AS `MIR`,`dmeworks`.`tbl_doctor`.`NPI` AS `NPI`,`dmeworks`.`tbl_doctor`.`PecosEnrolled` AS `PecosEnrolled` from `dmeworks`.`tbl_doctor` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_doctortype`
--

/*!50001 DROP VIEW IF EXISTS `tbl_doctortype`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_doctortype` AS select `dmeworks`.`tbl_doctortype`.`ID` AS `ID`,`dmeworks`.`tbl_doctortype`.`Name` AS `Name`,`dmeworks`.`tbl_doctortype`.`LastUpdateUserID` AS `LastUpdateUserID`,`dmeworks`.`tbl_doctortype`.`LastUpdateDatetime` AS `LastUpdateDatetime` from `dmeworks`.`tbl_doctortype` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_icd10`
--

/*!50001 DROP VIEW IF EXISTS `tbl_icd10`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_icd10` AS select `dmeworks`.`tbl_icd10`.`Code` AS `Code`,`dmeworks`.`tbl_icd10`.`Description` AS `Description`,`dmeworks`.`tbl_icd10`.`Header` AS `Header`,`dmeworks`.`tbl_icd10`.`ActiveDate` AS `ActiveDate`,`dmeworks`.`tbl_icd10`.`InactiveDate` AS `InactiveDate`,`dmeworks`.`tbl_icd10`.`LastUpdateUserID` AS `LastUpdateUserID`,`dmeworks`.`tbl_icd10`.`LastUpdateDatetime` AS `LastUpdateDatetime` from `dmeworks`.`tbl_icd10` where (`dmeworks`.`tbl_icd10`.`Header` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_icd9`
--

/*!50001 DROP VIEW IF EXISTS `tbl_icd9`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_icd9` AS select `dmeworks`.`tbl_icd9`.`Code` AS `Code`,`dmeworks`.`tbl_icd9`.`Description` AS `Description`,`dmeworks`.`tbl_icd9`.`ActiveDate` AS `ActiveDate`,`dmeworks`.`tbl_icd9`.`InactiveDate` AS `InactiveDate`,`dmeworks`.`tbl_icd9`.`LastUpdateUserID` AS `LastUpdateUserID`,`dmeworks`.`tbl_icd9`.`LastUpdateDatetime` AS `LastUpdateDatetime` from `dmeworks`.`tbl_icd9` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_insurancecompany`
--

/*!50001 DROP VIEW IF EXISTS `tbl_insurancecompany`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_insurancecompany` AS select `dmeworks`.`tbl_insurancecompany`.`Address1` AS `Address1`,`dmeworks`.`tbl_insurancecompany`.`Address2` AS `Address2`,`dmeworks`.`tbl_insurancecompany`.`Basis` AS `Basis`,`dmeworks`.`tbl_insurancecompany`.`City` AS `City`,`dmeworks`.`tbl_insurancecompany`.`Contact` AS `Contact`,`dmeworks`.`tbl_insurancecompany`.`ECSFormat` AS `ECSFormat`,`dmeworks`.`tbl_insurancecompany`.`ExpectedPercent` AS `ExpectedPercent`,`dmeworks`.`tbl_insurancecompany`.`Fax` AS `Fax`,`dmeworks`.`tbl_insurancecompany`.`ID` AS `ID`,`dmeworks`.`tbl_insurancecompany`.`Name` AS `Name`,`dmeworks`.`tbl_insurancecompany`.`Phone` AS `Phone`,`dmeworks`.`tbl_insurancecompany`.`Phone2` AS `Phone2`,`dmeworks`.`tbl_insurancecompany`.`PriceCodeID` AS `PriceCodeID`,`dmeworks`.`tbl_insurancecompany`.`PrintHAOOnInvoice` AS `PrintHAOOnInvoice`,`dmeworks`.`tbl_insurancecompany`.`PrintInvOnInvoice` AS `PrintInvOnInvoice`,`dmeworks`.`tbl_insurancecompany`.`State` AS `State`,`dmeworks`.`tbl_insurancecompany`.`Title` AS `Title`,`dmeworks`.`tbl_insurancecompany`.`Type` AS `Type`,`dmeworks`.`tbl_insurancecompany`.`Zip` AS `Zip`,`dmeworks`.`tbl_insurancecompany`.`MedicareNumber` AS `MedicareNumber`,`dmeworks`.`tbl_insurancecompany`.`OfficeAllyNumber` AS `OfficeAllyNumber`,`dmeworks`.`tbl_insurancecompany`.`ZirmedNumber` AS `ZirmedNumber`,`dmeworks`.`tbl_insurancecompany`.`LastUpdateUserID` AS `LastUpdateUserID`,`dmeworks`.`tbl_insurancecompany`.`LastUpdateDatetime` AS `LastUpdateDatetime`,`dmeworks`.`tbl_insurancecompany`.`InvoiceFormID` AS `InvoiceFormID`,`dmeworks`.`tbl_insurancecompany`.`MedicaidNumber` AS `MedicaidNumber`,`dmeworks`.`tbl_insurancecompany`.`MIR` AS `MIR`,`dmeworks`.`tbl_insurancecompany`.`GroupID` AS `GroupID`,`dmeworks`.`tbl_insurancecompany`.`AvailityNumber` AS `AvailityNumber`,`dmeworks`.`tbl_insurancecompany`.`AbilityNumber` AS `AbilityNumber`,`dmeworks`.`tbl_insurancecompany`.`AbilityEligibilityPayerId` AS `AbilityEligibilityPayerId` from `dmeworks`.`tbl_insurancecompany` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_insurancecompanygroup`
--

/*!50001 DROP VIEW IF EXISTS `tbl_insurancecompanygroup`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_insurancecompanygroup` AS select `dmeworks`.`tbl_insurancecompanygroup`.`ID` AS `ID`,`dmeworks`.`tbl_insurancecompanygroup`.`Name` AS `Name`,`dmeworks`.`tbl_insurancecompanygroup`.`LastUpdateUserID` AS `LastUpdateUserID`,`dmeworks`.`tbl_insurancecompanygroup`.`LastUpdateDatetime` AS `LastUpdateDatetime` from `dmeworks`.`tbl_insurancecompanygroup` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_insurancecompanytype`
--

/*!50001 DROP VIEW IF EXISTS `tbl_insurancecompanytype`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_insurancecompanytype` AS select `dmeworks`.`tbl_insurancecompanytype`.`ID` AS `ID`,`dmeworks`.`tbl_insurancecompanytype`.`Name` AS `Name` from `dmeworks`.`tbl_insurancecompanytype` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tbl_zipcode`
--

/*!50001 DROP VIEW IF EXISTS `tbl_zipcode`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tbl_zipcode` AS select `dmeworks`.`tbl_zipcode`.`Zip` AS `Zip`,`dmeworks`.`tbl_zipcode`.`State` AS `State`,`dmeworks`.`tbl_zipcode`.`City` AS `City` from `dmeworks`.`tbl_zipcode` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_billinglist`
--

/*!50001 DROP VIEW IF EXISTS `view_billinglist`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_billinglist` AS select distinct `details`.`OrderID` AS `OrderID`,if((`details`.`BillingMonth` <= 0),1,`details`.`BillingMonth`) AS `BillingMonth`,(((((if(((`tbl_order`.`CustomerInsurance1_ID` is not null) and (`details`.`BillIns1` = 1)),1,0) + if(((`tbl_order`.`CustomerInsurance2_ID` is not null) and (`details`.`BillIns2` = 1)),2,0)) + if(((`tbl_order`.`CustomerInsurance3_ID` is not null) and (`details`.`BillIns3` = 1)),4,0)) + if(((`tbl_order`.`CustomerInsurance4_ID` is not null) and (`details`.`BillIns4` = 1)),8,0)) + if((`details`.`EndDate` is not null),32,0)) + if((`details`.`AcceptAssignment` = 1),16,0)) AS `BillingFlags`,`tbl_customer`.`BillingTypeID` AS `BillingTypeID` from ((`view_orderdetails_core` `details` join `tbl_order` on(((`tbl_order`.`ID` = `details`.`OrderID`) and (`tbl_order`.`CustomerID` = `details`.`CustomerID`)))) left join `tbl_customer` on((`tbl_customer`.`ID` = `tbl_order`.`CustomerID`))) where (((`details`.`InvoiceDate` <= curdate()) or (`details`.`EndDate` <= curdate())) and (`details`.`MIR` = '') and (`details`.`IsActive` = 1) and (isnull(`details`.`EndDate`) or (`tbl_order`.`BillDate` < `details`.`EndDate`)) and (`tbl_order`.`MIR` = '') and (`tbl_order`.`Approved` = 1) and (`tbl_order`.`OrderDate` is not null) and (`tbl_order`.`BillDate` is not null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_invoicetransaction_statistics`
--

/*!50001 DROP VIEW IF EXISTS `view_invoicetransaction_statistics`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_invoicetransaction_statistics` AS select sql_small_result `detail`.`CustomerID` AS `CustomerID`,`detail`.`OrderID` AS `OrderID`,`detail`.`InvoiceID` AS `InvoiceID`,`detail`.`ID` AS `InvoiceDetailsID`,`detail`.`BillableAmount` AS `BillableAmount`,`detail`.`AllowableAmount` AS `AllowableAmount`,`detail`.`Quantity` AS `Quantity`,`detail`.`Hardship` AS `Hardship`,`detail`.`BillingCode` AS `BillingCode`,`detail`.`InventoryItemID` AS `InventoryItemID`,`detail`.`DOSFrom` AS `DOSFrom`,`detail`.`DOSTo` AS `DOSTo`,`insurance1`.`ID` AS `Insurance1_ID`,`insurance2`.`ID` AS `Insurance2_ID`,`insurance3`.`ID` AS `Insurance3_ID`,`insurance4`.`ID` AS `Insurance4_ID`,`insurance1`.`InsuranceCompanyID` AS `InsuranceCompany1_ID`,`insurance2`.`InsuranceCompanyID` AS `InsuranceCompany2_ID`,`insurance3`.`InsuranceCompanyID` AS `InsuranceCompany3_ID`,`insurance4`.`InsuranceCompanyID` AS `InsuranceCompany4_ID`,(case when (ifnull(`insurance1`.`PaymentPercent`,0) < 0) then 0 when (100 < ifnull(`insurance1`.`PaymentPercent`,0)) then 100 else ifnull(`insurance1`.`PaymentPercent`,0) end) AS `Percent`,ifnull(`insurance1`.`Basis`,'Bill') AS `Basis`,`detail`.`PaymentAmount` AS `PaymentAmount`,`detail`.`WriteoffAmount` AS `WriteoffAmount`,((((if((`insurance1`.`ID` is not null),1,0) + if((`insurance2`.`ID` is not null),2,0)) + if((`insurance3`.`ID` is not null),4,0)) + if((`insurance4`.`ID` is not null),8,0)) + if((1 = 1),16,0)) AS `Insurances`,((((if((`insurance1`.`ID` is not null),(`detail`.`Pendings` & 1),0) + if((`insurance2`.`ID` is not null),(`detail`.`Pendings` & 2),0)) + if((`insurance3`.`ID` is not null),(`detail`.`Pendings` & 4),0)) + if((`insurance4`.`ID` is not null),(`detail`.`Pendings` & 8),0)) + if((1 = 1),(`detail`.`Pendings` & 16),0)) AS `PendingSubmissions`,((((if((`insurance1`.`ID` is not null),(`detail`.`Submits` & 1),0) + if((`insurance2`.`ID` is not null),(`detail`.`Submits` & 2),0)) + if((`insurance3`.`ID` is not null),(`detail`.`Submits` & 4),0)) + if((`insurance4`.`ID` is not null),(`detail`.`Submits` & 8),0)) + if((1 = 1),(`detail`.`Submits` & 16),0)) AS `Submits`,((((if((`insurance1`.`ID` is not null),(`detail`.`Payments` & 1),0) + if((`insurance2`.`ID` is not null),(`detail`.`Payments` & 2),0)) + if((`insurance3`.`ID` is not null),(`detail`.`Payments` & 4),0)) + if((`insurance4`.`ID` is not null),(`detail`.`Payments` & 8),0)) + if((1 = 1),(`detail`.`Payments` & 16),0)) AS `Payments`,`detail`.`CurrentCustomerInsuranceID` AS `CurrentInsuranceID`,`detail`.`CurrentInsuranceCompanyID` AS `CurrentInsuranceCompanyID`,`detail`.`Submitted` AS `InvoiceSubmitted`,`detail`.`SubmittedDate` AS `SubmittedDate`,`detail`.`CurrentPayer` AS `CurrentPayer`,`detail`.`NopayIns1` AS `NopayIns1` from (((((`tbl_invoicedetails` `detail` join `tbl_invoice` `invoice` on(((`invoice`.`CustomerID` = `detail`.`CustomerID`) and (`invoice`.`ID` = `detail`.`InvoiceID`)))) left join `tbl_customer_insurance` `insurance1` on(((`insurance1`.`ID` = `invoice`.`CustomerInsurance1_ID`) and (`insurance1`.`CustomerID` = `invoice`.`CustomerID`) and (`detail`.`BillIns1` = 1)))) left join `tbl_customer_insurance` `insurance2` on(((`insurance2`.`ID` = `invoice`.`CustomerInsurance2_ID`) and (`insurance2`.`CustomerID` = `invoice`.`CustomerID`) and (`detail`.`BillIns2` = 1)))) left join `tbl_customer_insurance` `insurance3` on(((`insurance3`.`ID` = `invoice`.`CustomerInsurance3_ID`) and (`insurance3`.`CustomerID` = `invoice`.`CustomerID`) and (`detail`.`BillIns3` = 1)))) left join `tbl_customer_insurance` `insurance4` on(((`insurance4`.`ID` = `invoice`.`CustomerInsurance4_ID`) and (`insurance4`.`CustomerID` = `invoice`.`CustomerID`) and (`detail`.`BillIns4` = 1)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_mir`
--

/*!50001 DROP VIEW IF EXISTS `view_mir`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_mir` AS select `tbl_details`.`ID` AS `OrderDetailsID`,`c02`.`tbl_order`.`ID` AS `OrderID`,`c02`.`tbl_order`.`Approved` AS `OrderApproved`,`c02`.`tbl_customer`.`ID` AS `CustomerID`,concat(`c02`.`tbl_customer`.`LastName`,' ',`c02`.`tbl_customer`.`FirstName`) AS `CustomerName`,`policy1`.`ID` AS `CustomerInsuranceID_1`,`insco1`.`ID` AS `InsuranceCompanyID_1`,`policy2`.`ID` AS `CustomerInsuranceID_2`,`insco2`.`ID` AS `InsuranceCompanyID_2`,`c02`.`tbl_cmnform`.`ID` AS `CMNFormID`,`c02`.`tbl_facility`.`ID` AS `FacilityID`,`tbl_doctor`.`ID` AS `DoctorID`,`tbl_details`.`SaleRentType` AS `SaleRentType`,`tbl_details`.`BillingCode` AS `BillingCode`,concat_ws(', ',if((`tbl_details`.`BillIns1` = 1),'Ins1',NULL),if((`tbl_details`.`BillIns2` = 1),'Ins2',NULL),if((`tbl_details`.`BillIns3` = 1),'Ins3',NULL),if((`tbl_details`.`BillIns4` = 1),'Ins4',NULL),'Patient') AS `Payers`,`c02`.`tbl_inventoryitem`.`Name` AS `InventoryItem`,`c02`.`tbl_pricecode`.`Name` AS `PriceCode`,concat_ws(', ',if((`c02`.`tbl_order`.`MIR` <> ''),'order',NULL),if((`tbl_details`.`MIR` <> ''),'details',NULL),if((0 < find_in_set('CustomerID',`c02`.`tbl_order`.`MIR`)),'customer required',NULL),if((0 < find_in_set('Customer.Inactive',`c02`.`tbl_order`.`MIR`)),'customer inactive',NULL),if((0 < find_in_set('Customer.MIR',`c02`.`tbl_order`.`MIR`)),'customer',NULL),if((0 < find_in_set('Facility.MIR',`c02`.`tbl_order`.`MIR`)),'facility',NULL),if((0 < find_in_set('Policy1.Required',`c02`.`tbl_order`.`MIR`)),'policy1 required',NULL),if((0 < find_in_set('Policy1.MIR',`c02`.`tbl_order`.`MIR`)),'policy1',NULL),if((0 < find_in_set('Policy2.Required',`c02`.`tbl_order`.`MIR`)),'policy2 required',NULL),if((0 < find_in_set('Policy2.MIR',`c02`.`tbl_order`.`MIR`)),'policy2',NULL),if((0 < find_in_set('CMNForm.Required',`tbl_details`.`MIR`)),'cmn form required',NULL),if((0 < find_in_set('CMNForm.MIR',`tbl_details`.`MIR`)),'cmn form',NULL),if((0 < find_in_set('Answers',`c02`.`tbl_cmnform`.`MIR`)),'cmn answers',NULL),NULL) AS `MIR`,concat_ws('\r\n',if((`c02`.`tbl_order`.`MIR` <> ''),replace(concat('Order: ',cast(`c02`.`tbl_order`.`MIR` as char charset latin1)),',',', '),NULL),if((`tbl_details`.`MIR` <> ''),replace(concat('Details: ',cast(`tbl_details`.`MIR` as char charset latin1)),',',', '),NULL),if((`c02`.`tbl_customer`.`MIR` <> ''),replace(concat('Customer: ',cast(`c02`.`tbl_customer`.`MIR` as char charset latin1)),',',', '),NULL),if((`tbl_doctor`.`MIR` <> ''),replace(concat('Doctor: ',cast(`tbl_doctor`.`MIR` as char charset latin1)),',',', '),NULL),if((`policy1`.`MIR` <> ''),replace(concat('Policy 1: ',cast(`policy1`.`MIR` as char charset latin1)),',',', '),NULL),if((`insco1`.`MIR` <> ''),replace(concat('Ins Co 1: ',cast(`insco1`.`MIR` as char charset latin1)),',',', '),NULL),if((`policy2`.`MIR` <> ''),replace(concat('Policy 2: ',cast(`policy2`.`MIR` as char charset latin1)),',',', '),NULL),if((`insco2`.`MIR` <> ''),replace(concat('Ins Co 2: ',cast(`insco2`.`MIR` as char charset latin1)),',',', '),NULL),if((`c02`.`tbl_cmnform`.`MIR` <> ''),replace(concat('CMN Form: ',cast(`c02`.`tbl_cmnform`.`MIR` as char charset latin1)),',',', '),NULL),if((`c02`.`tbl_facility`.`MIR` <> ''),replace(concat('Facility: ',cast(`c02`.`tbl_facility`.`MIR` as char charset latin1)),',',', '),NULL),NULL) AS `Details` from ((((((((((((`c02`.`view_orderdetails_core` `tbl_details` join `c02`.`tbl_order` on(((`tbl_details`.`OrderID` = `c02`.`tbl_order`.`ID`) and (`tbl_details`.`CustomerID` = `c02`.`tbl_order`.`CustomerID`)))) join `c02`.`tbl_customer` on((`tbl_details`.`CustomerID` = `c02`.`tbl_customer`.`ID`))) left join `c02`.`tbl_doctor` on((`c02`.`tbl_customer`.`Doctor1_ID` = `tbl_doctor`.`ID`))) left join `c02`.`tbl_facility` on((`c02`.`tbl_order`.`FacilityID` = `c02`.`tbl_facility`.`ID`))) left join `c02`.`tbl_cmnform` on(((`tbl_details`.`CMNFormID` = `c02`.`tbl_cmnform`.`ID`) and (`tbl_details`.`CustomerID` = `c02`.`tbl_cmnform`.`CustomerID`)))) left join `c02`.`tbl_inventoryitem` on((`tbl_details`.`InventoryItemID` = `c02`.`tbl_inventoryitem`.`ID`))) left join `c02`.`tbl_pricecode` on((`tbl_details`.`PriceCodeID` = `c02`.`tbl_pricecode`.`ID`))) left join `c02`.`tbl_customer_insurance` `policy1` on(((`policy1`.`CustomerID` = `c02`.`tbl_order`.`CustomerID`) and (`policy1`.`ID` = `c02`.`tbl_order`.`CustomerInsurance1_ID`)))) left join `c02`.`tbl_insurancecompany` `insco1` on((`insco1`.`ID` = `policy1`.`InsuranceCompanyID`))) left join `c02`.`tbl_customer_insurance` `policy2` on(((`policy2`.`CustomerID` = `c02`.`tbl_order`.`CustomerID`) and (`policy2`.`ID` = `c02`.`tbl_order`.`CustomerInsurance2_ID`) and (`tbl_details`.`BillIns2` = 1)))) left join `c02`.`tbl_insurancecompany` `insco2` on((`insco2`.`ID` = `policy2`.`InsuranceCompanyID`))) join `c02`.`tbl_company` on((`c02`.`tbl_company`.`ID` = 1))) where (((`c02`.`tbl_company`.`Show_InactiveCustomers` = 1) or isnull(`c02`.`tbl_customer`.`InactiveDate`) or (now() < `c02`.`tbl_customer`.`InactiveDate`)) and (`tbl_details`.`IsActive` = 1) and ((`tbl_details`.`MIR` <> '') or (`c02`.`tbl_order`.`MIR` <> ''))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_orderdetails`
--

/*!50001 DROP VIEW IF EXISTS `view_orderdetails`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_orderdetails` AS select `det`.`ID` AS `ID`,`det`.`OrderID` AS `OrderID`,`det`.`CustomerID` AS `CustomerID`,`det`.`SerialNumber` AS `SerialNumber`,`det`.`InventoryItemID` AS `InventoryItemID`,`det`.`PriceCodeID` AS `PriceCodeID`,`det`.`SaleRentType` AS `SaleRentType`,`det`.`SerialID` AS `SerialID`,`det`.`BillablePrice` AS `BillablePrice`,`det`.`AllowablePrice` AS `AllowablePrice`,`det`.`Taxable` AS `Taxable`,`det`.`FlatRate` AS `FlatRate`,`det`.`DOSFrom` AS `DOSFrom`,`det`.`DOSTo` AS `DOSTo`,`det`.`PickupDate` AS `PickupDate`,`det`.`ShowSpanDates` AS `ShowSpanDates`,`det`.`OrderedQuantity` AS `OrderedQuantity`,`det`.`OrderedUnits` AS `OrderedUnits`,`det`.`OrderedWhen` AS `OrderedWhen`,`det`.`OrderedConverter` AS `OrderedConverter`,`det`.`BilledQuantity` AS `BilledQuantity`,`det`.`BilledUnits` AS `BilledUnits`,`det`.`BilledWhen` AS `BilledWhen`,`det`.`BilledConverter` AS `BilledConverter`,`det`.`DeliveryQuantity` AS `DeliveryQuantity`,`det`.`DeliveryUnits` AS `DeliveryUnits`,`det`.`DeliveryConverter` AS `DeliveryConverter`,`det`.`BillingCode` AS `BillingCode`,`det`.`Modifier1` AS `Modifier1`,`det`.`Modifier2` AS `Modifier2`,`det`.`Modifier3` AS `Modifier3`,`det`.`Modifier4` AS `Modifier4`,`det`.`DXPointer` AS `DXPointer`,`det`.`BillingMonth` AS `BillingMonth`,`det`.`BillItemOn` AS `BillItemOn`,`det`.`AuthorizationNumber` AS `AuthorizationNumber`,`det`.`AuthorizationTypeID` AS `AuthorizationTypeID`,`det`.`ReasonForPickup` AS `ReasonForPickup`,`det`.`SendCMN_RX_w_invoice` AS `SendCMN_RX_w_invoice`,`det`.`MedicallyUnnecessary` AS `MedicallyUnnecessary`,`det`.`Sale` AS `Sale`,`det`.`SpecialCode` AS `SpecialCode`,`det`.`ReviewCode` AS `ReviewCode`,`det`.`NextOrderID` AS `NextOrderID`,`det`.`ReoccuringID` AS `ReoccuringID`,`det`.`CMNFormID` AS `CMNFormID`,`det`.`HAOCode` AS `HAOCode`,`det`.`State` AS `State`,`det`.`BillIns1` AS `BillIns1`,`det`.`BillIns2` AS `BillIns2`,`det`.`BillIns3` AS `BillIns3`,`det`.`BillIns4` AS `BillIns4`,`det`.`EndDate` AS `EndDate`,`det`.`MIR` AS `MIR`,`det`.`NextBillingDate` AS `NextBillingDate`,`det`.`WarehouseID` AS `WarehouseID`,`det`.`AcceptAssignment` AS `AcceptAssignment`,`det`.`DrugNoteField` AS `DrugNoteField`,`det`.`DrugControlNumber` AS `DrugControlNumber`,`det`.`NopayIns1` AS `NopayIns1`,`det`.`PointerICD10` AS `PointerICD10`,`det`.`DXPointer10` AS `DXPointer10`,`det`.`MIR.ORDER` AS `MIR.ORDER`,`det`.`HaoDescription` AS `HaoDescription`,`det`.`UserField1` AS `UserField1`,`det`.`UserField2` AS `UserField2`,`det`.`AuthorizationExpirationDate` AS `AuthorizationExpirationDate`,`det`.`IsActive` AS `IsActive`,`det`.`IsCanceled` AS `IsCanceled`,`det`.`IsSold` AS `IsSold`,`det`.`IsRented` AS `IsRented`,`det`.`ActualSaleRentType` AS `ActualSaleRentType`,`det`.`ActualBillItemOn` AS `ActualBillItemOn`,`det`.`ActualOrderedWhen` AS `ActualOrderedWhen`,`det`.`ActualBilledWhen` AS `ActualBilledWhen`,`det`.`ActualDosTo` AS `ActualDosTo`,`det`.`InvoiceDate` AS `InvoiceDate`,`det`.`IsOxygen` AS `IsOxygen`,`det`.`IsZeroAmount` AS `IsZeroAmount`,(case when (((`det`.`State` = 'Pickup') and (`det`.`EndDate` is not null)) or ((`det`.`State` = 'Closed') and (`det`.`ActualSaleRentType` = 'One Time Rental')) or ((`det`.`State` = 'Closed') and (`det`.`ActualSaleRentType` = 'Medicare Oxygent Rental')) or ((`det`.`State` = 'Closed') and (`det`.`ActualSaleRentType` = 'Monthly Rental')) or ((`det`.`State` = 'Closed') and (`OrderMustBeClosed`(`ord`.`DeliveryDate`,`det`.`DOSFrom`,`det`.`ActualSaleRentType`,`det`.`BillingMonth`,`det`.`Modifier1`,`det`.`Modifier2`,`det`.`Modifier3`,`det`.`Modifier4`) = 0))) then 1 else 0 end) AS `IsPickedup` from (`view_orderdetails_core` `det` join `tbl_order` `ord` on(((`det`.`CustomerID` = `ord`.`CustomerID`) and (`det`.`OrderID` = `ord`.`ID`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_orderdetails_core`
--

/*!50001 DROP VIEW IF EXISTS `view_orderdetails_core`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_orderdetails_core` AS select `det`.`ID` AS `ID`,`det`.`OrderID` AS `OrderID`,`det`.`CustomerID` AS `CustomerID`,`det`.`SerialNumber` AS `SerialNumber`,`det`.`InventoryItemID` AS `InventoryItemID`,`det`.`PriceCodeID` AS `PriceCodeID`,`det`.`SaleRentType` AS `SaleRentType`,`det`.`SerialID` AS `SerialID`,`det`.`BillablePrice` AS `BillablePrice`,`det`.`AllowablePrice` AS `AllowablePrice`,`det`.`Taxable` AS `Taxable`,`det`.`FlatRate` AS `FlatRate`,`det`.`DOSFrom` AS `DOSFrom`,`det`.`DOSTo` AS `DOSTo`,`det`.`PickupDate` AS `PickupDate`,`det`.`ShowSpanDates` AS `ShowSpanDates`,`det`.`OrderedQuantity` AS `OrderedQuantity`,`det`.`OrderedUnits` AS `OrderedUnits`,`det`.`OrderedWhen` AS `OrderedWhen`,`det`.`OrderedConverter` AS `OrderedConverter`,`det`.`BilledQuantity` AS `BilledQuantity`,`det`.`BilledUnits` AS `BilledUnits`,`det`.`BilledWhen` AS `BilledWhen`,`det`.`BilledConverter` AS `BilledConverter`,`det`.`DeliveryQuantity` AS `DeliveryQuantity`,`det`.`DeliveryUnits` AS `DeliveryUnits`,`det`.`DeliveryConverter` AS `DeliveryConverter`,`det`.`BillingCode` AS `BillingCode`,`det`.`Modifier1` AS `Modifier1`,`det`.`Modifier2` AS `Modifier2`,`det`.`Modifier3` AS `Modifier3`,`det`.`Modifier4` AS `Modifier4`,`det`.`DXPointer` AS `DXPointer`,`det`.`BillingMonth` AS `BillingMonth`,`det`.`BillItemOn` AS `BillItemOn`,`det`.`AuthorizationNumber` AS `AuthorizationNumber`,`det`.`AuthorizationTypeID` AS `AuthorizationTypeID`,`det`.`ReasonForPickup` AS `ReasonForPickup`,`det`.`SendCMN_RX_w_invoice` AS `SendCMN_RX_w_invoice`,`det`.`MedicallyUnnecessary` AS `MedicallyUnnecessary`,`det`.`Sale` AS `Sale`,`det`.`SpecialCode` AS `SpecialCode`,`det`.`ReviewCode` AS `ReviewCode`,`det`.`NextOrderID` AS `NextOrderID`,`det`.`ReoccuringID` AS `ReoccuringID`,`det`.`CMNFormID` AS `CMNFormID`,`det`.`HAOCode` AS `HAOCode`,`det`.`State` AS `State`,`det`.`BillIns1` AS `BillIns1`,`det`.`BillIns2` AS `BillIns2`,`det`.`BillIns3` AS `BillIns3`,`det`.`BillIns4` AS `BillIns4`,`det`.`EndDate` AS `EndDate`,`det`.`MIR` AS `MIR`,`det`.`NextBillingDate` AS `NextBillingDate`,`det`.`WarehouseID` AS `WarehouseID`,`det`.`AcceptAssignment` AS `AcceptAssignment`,`det`.`DrugNoteField` AS `DrugNoteField`,`det`.`DrugControlNumber` AS `DrugControlNumber`,`det`.`NopayIns1` AS `NopayIns1`,`det`.`PointerICD10` AS `PointerICD10`,`det`.`DXPointer10` AS `DXPointer10`,`det`.`MIR.ORDER` AS `MIR.ORDER`,`det`.`HaoDescription` AS `HaoDescription`,`det`.`UserField1` AS `UserField1`,`det`.`UserField2` AS `UserField2`,`det`.`AuthorizationExpirationDate` AS `AuthorizationExpirationDate`,(case when (`det`.`State` in ('Closed','Canceled')) then 0 else 1 end) AS `IsActive`,(case when (`det`.`State` = 'Canceled') then 1 else 0 end) AS `IsCanceled`,(case when (`det`.`SaleRentType` in ('One Time Sale','Re-occurring Sale')) then 1 else 0 end) AS `IsSold`,(case when (`det`.`SaleRentType` in ('Capped Rental','Medicare Oxygen Rental','Parental Capped Rental','Rent to Purchase','Monthly Rental','One Time Rental')) then 1 else 0 end) AS `IsRented`,ifnull(`det`.`SaleRentType`,'') AS `ActualSaleRentType`,(case when (`det`.`BillItemOn` not in ('Day of Delivery','Last day of the Period')) then '' when ((`det`.`SaleRentType` = 'One Time Rental') and (`det`.`BillItemOn` <> 'Last day of the Period')) then '' else ifnull(`det`.`BillItemOn`,'') end) AS `ActualBillItemOn`,(case when ((`det`.`SaleRentType` = 'Capped Rental') and (`det`.`OrderedWhen` in ('One time','Monthly'))) then `det`.`OrderedWhen` when ((`det`.`SaleRentType` = 'Medicare Oxygen Rental') and (`det`.`OrderedWhen` in ('One time','Monthly'))) then `det`.`OrderedWhen` when ((`det`.`SaleRentType` = 'Parental Capped Rental') and (`det`.`OrderedWhen` in ('One time','Monthly'))) then `det`.`OrderedWhen` when ((`det`.`SaleRentType` = 'Rent to Purchase') and (`det`.`OrderedWhen` in ('One time','Monthly'))) then `det`.`OrderedWhen` when ((`det`.`SaleRentType` = 'One Time Sale') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually'))) then '' when ((`det`.`SaleRentType` = 'Re-occurring Sale') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually'))) then '' when ((`det`.`SaleRentType` = 'Monthly Rental') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually'))) then '' when ((`det`.`SaleRentType` = 'One Time Rental') and (`det`.`OrderedWhen` in ('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually'))) then `det`.`OrderedWhen` when ((`det`.`BilledWhen` = 'One time') and (`det`.`OrderedWhen` <> 'One time')) then '' when ((`det`.`BilledWhen` = 'Daily') and (`det`.`OrderedWhen` not in ('One time','Daily'))) then '' when ((`det`.`BilledWhen` = 'Weekly') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly'))) then '' when ((`det`.`BilledWhen` = 'Monthly') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly'))) then '' when ((`det`.`BilledWhen` = 'Calendar Monthly') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly'))) then '' when ((`det`.`BilledWhen` = 'Quarterly') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly','Quarterly'))) then '' when ((`det`.`BilledWhen` = 'Semi-Annually') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually'))) then '' when ((`det`.`BilledWhen` = 'Annually') and (`det`.`OrderedWhen` not in ('One time','Daily','Weekly','Monthly','Quarterly','Semi-Annually','Annually'))) then '' when ((`det`.`BilledWhen` = 'Custom') and (`det`.`OrderedWhen` not in ('One time','Daily'))) then '' else ifnull(`det`.`OrderedWhen`,'') end) AS `ActualOrderedWhen`,(case when ((`det`.`SaleRentType` = 'Capped Rental') and (`det`.`BilledWhen` <> 'Monthly')) then '' when ((`det`.`SaleRentType` = 'Medicare Oxygen Rental') and (`det`.`BilledWhen` <> 'Monthly')) then '' when ((`det`.`SaleRentType` = 'Parental Capped Rental') and (`det`.`BilledWhen` <> 'Monthly')) then '' when ((`det`.`SaleRentType` = 'Rent to Purchase') and (`det`.`BilledWhen` <> 'Monthly')) then '' when ((`det`.`SaleRentType` = 'One Time Sale') and (`det`.`BilledWhen` not in ('One time','Daily','Weekly','Monthly','Calendar Monthly','Quarterly','Semi-Annually','Annually','Custom'))) then '' when ((`det`.`SaleRentType` = 'Re-occurring Sale') and (`det`.`BilledWhen` not in ('Daily','Weekly','Monthly','Calendar Monthly','Quarterly','Semi-Annually','Annually','Custom'))) then '' when ((`det`.`SaleRentType` = 'Monthly Rental') and (`det`.`BilledWhen` not in ('Daily','Weekly','Monthly','Calendar Monthly','Quarterly','Semi-Annually','Annually','Custom'))) then '' when ((`det`.`SaleRentType` = 'One Time Rental') and (`det`.`BilledWhen` <> 'One time')) then '' else ifnull(`det`.`BilledWhen`,'') end) AS `ActualBilledWhen`,(case when (`det`.`SaleRentType` = 'Capped Rental') then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when (`det`.`SaleRentType` = 'Medicare Oxygen Rental') then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when (`det`.`SaleRentType` = 'Parental Capped Rental') then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when (`det`.`SaleRentType` = 'Rent to Purchase') then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when (`det`.`SaleRentType` = 'One Time Sale') then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,`det`.`BilledWhen`) when (`det`.`SaleRentType` = 'Re-occurring Sale') then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,`det`.`BilledWhen`) when (`det`.`SaleRentType` = 'Monthly Rental') then `GetPeriodEnd2`(`det`.`DOSFrom`,`det`.`DOSTo`,`det`.`EndDate`,`det`.`BilledWhen`) when (`det`.`SaleRentType` = 'One Time Rental') then `det`.`EndDate` else `det`.`DOSFrom` end) AS `ActualDosTo`,(case when ((`det`.`SaleRentType` = 'Capped Rental') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when ((`det`.`SaleRentType` = 'Medicare Oxygen Rental') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when ((`det`.`SaleRentType` = 'Parental Capped Rental') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when ((`det`.`SaleRentType` = 'Rent to Purchase') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,'Monthly') when ((`det`.`SaleRentType` = 'One Time Sale') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,`det`.`BilledWhen`) when ((`det`.`SaleRentType` = 'Re-occurring Sale') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,`det`.`BilledWhen`) when ((`det`.`SaleRentType` = 'Monthly Rental') and (`det`.`BillItemOn` = 'Last day of the Period')) then `GetPeriodEnd`(`det`.`DOSFrom`,`det`.`DOSTo`,`det`.`BilledWhen`) when ((`det`.`SaleRentType` = 'One Time Rental') and (`det`.`BillItemOn` = 'Last day of the Period')) then `det`.`EndDate` else `det`.`DOSFrom` end) AS `InvoiceDate`,(case when (`det`.`BillingCode` in ('A4606','A4608','A4616','E0424','E0430','E0431','E0434','E0435','E0439')) then 1 when (`det`.`BillingCode` in ('E0440','E0441','E0442','E0443','E0444','E0445','E0455','E1390','E1391')) then 1 when (`det`.`BillingCode` = 'E1392') then 1 else 0 end) AS `IsOxygen`,if(((abs(ifnull(`det`.`BillablePrice`,0)) <= 1e-5) and (abs(ifnull(`det`.`AllowablePrice`,0)) <= 1e-5)),1,0) AS `IsZeroAmount` from `tbl_orderdetails` `det` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_pricecode`
--

/*!50001 DROP VIEW IF EXISTS `view_pricecode`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_pricecode` AS select sql_small_result `tbl_pricecode`.`ID` AS `ID`,`tbl_pricecode`.`Name` AS `Name`,if((`tbl_pricecode`.`Name` like '%RETAIL%'),1,0) AS `IsRetail` from `tbl_pricecode` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_reoccuringlist`
--

/*!50001 DROP VIEW IF EXISTS `view_reoccuringlist`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_reoccuringlist` AS select `tbl_order`.`ID` AS `OrderID`,`details`.`BilledWhen` AS `BilledWhen`,`details`.`ActualBillItemOn` AS `BillItemOn` from (`view_orderdetails` `details` join `tbl_order` on(((`details`.`CustomerID` = `tbl_order`.`CustomerID`) and (`details`.`OrderID` = `tbl_order`.`ID`)))) where ((`details`.`SaleRentType` = 'Re-occurring Sale') and if((`details`.`BillingMonth` <= 1),((`GetNextDosFrom`(`details`.`DOSFrom`,`details`.`DOSTo`,`details`.`ActualBilledWhen`) + interval -(1) month) <= now()),((`details`.`DOSFrom` + interval -(1) month) <= now()))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_sequence`
--

/*!50001 DROP VIEW IF EXISTS `view_sequence`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_sequence` AS select ((16 * `s2`.`num`) + `s1`.`num`) AS `num` from (`view_sequence_core` `s1` join `view_sequence_core` `s2`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_sequence_core`
--

/*!50001 DROP VIEW IF EXISTS `view_sequence_core`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_sequence_core` AS select cast(0 as unsigned) AS `num` union all select cast(1 as unsigned) AS `num` union all select cast(2 as unsigned) AS `num` union all select cast(3 as unsigned) AS `num` union all select cast(4 as unsigned) AS `num` union all select cast(5 as unsigned) AS `num` union all select cast(6 as unsigned) AS `num` union all select cast(7 as unsigned) AS `num` union all select cast(8 as unsigned) AS `num` union all select cast(9 as unsigned) AS `num` union all select cast(10 as unsigned) AS `num` union all select cast(11 as unsigned) AS `num` union all select cast(12 as unsigned) AS `num` union all select cast(13 as unsigned) AS `num` union all select cast(14 as unsigned) AS `num` union all select cast(15 as unsigned) AS `num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_taxrate`
--

/*!50001 DROP VIEW IF EXISTS `view_taxrate`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=MERGE */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_taxrate` AS select sql_small_result `tbl_taxrate`.`ID` AS `ID`,`tbl_taxrate`.`CityTax` AS `CityTax`,`tbl_taxrate`.`CountyTax` AS `CountyTax`,`tbl_taxrate`.`Name` AS `Name`,`tbl_taxrate`.`OtherTax` AS `OtherTax`,`tbl_taxrate`.`StateTax` AS `StateTax`,`tbl_taxrate`.`LastUpdateUserID` AS `LastUpdateUserID`,`tbl_taxrate`.`LastUpdateDatetime` AS `LastUpdateDatetime`,(((ifnull(`tbl_taxrate`.`CityTax`,0) + ifnull(`tbl_taxrate`.`CountyTax`,0)) + ifnull(`tbl_taxrate`.`OtherTax`,0)) + ifnull(`tbl_taxrate`.`StateTax`,0)) AS `TotalTax` from `tbl_taxrate` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-23 23:54:26
