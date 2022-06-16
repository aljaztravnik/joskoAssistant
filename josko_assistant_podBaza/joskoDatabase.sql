-- phpMyAdmin SQL Dump
-- version 4.9.5deb2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 16, 2022 at 09:06 PM
-- Server version: 10.3.34-MariaDB-0ubuntu0.20.04.1
-- PHP Version: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `joskoDatabase`
--

-- --------------------------------------------------------

--
-- Table structure for table `Task`
--

CREATE TABLE `Task` (
  `TaskID` int(11) NOT NULL,
  `PinNum` int(11) NOT NULL,
  `TypeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Task`
--

INSERT INTO `Task` (`TaskID`, `PinNum`, `TypeID`) VALUES
(19, 21, 1),
(21, 99, 3),
(22, 99, 2),
(23, 99, 2),
(24, 99, 3),
(25, 4858585, 1),
(26, 151, 1),
(27, 878485, 2),
(28, 32, 1);

-- --------------------------------------------------------

--
-- Table structure for table `Type`
--

CREATE TABLE `Type` (
  `TypeID` int(11) NOT NULL,
  `TypeName` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Type`
--

INSERT INTO `Type` (`TypeID`, `TypeName`) VALUES
(1, 'Toggle pin'),
(2, 'Tell the time'),
(3, 'Toggle music');

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

CREATE TABLE `User` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(100) NOT NULL,
  `Password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `User`
--

INSERT INTO `User` (`UserID`, `Username`, `Password`) VALUES
(1, 'aljaz', '$2y$10$YnVeqlvGEQtQqwC1.C59ZOBpMMpIdD4QVbn1CHOmtppf18wMO72yy'),
(2, 'aljaz2', '$2y$10$uKhqfvReizMXmzTFsgW5A.QVRXIBOKai/zbIG4zUvYLblHYvszCom'),
(3, 'rooot', '$2y$10$gVTtXYCqcxkCp2Wm7RF/Zui5h0NQksyeIkufBpl7.DSRHA9vA2B2O');

-- --------------------------------------------------------

--
-- Table structure for table `User_has_Task`
--

CREATE TABLE `User_has_Task` (
  `UserID` int(11) NOT NULL,
  `TaskID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `User_has_Task`
--

INSERT INTO `User_has_Task` (`UserID`, `TaskID`) VALUES
(1, 19),
(1, 21),
(1, 28);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Task`
--
ALTER TABLE `Task`
  ADD PRIMARY KEY (`TaskID`),
  ADD KEY `fk_Task_Type_idx` (`TypeID`);

--
-- Indexes for table `Type`
--
ALTER TABLE `Type`
  ADD PRIMARY KEY (`TypeID`);

--
-- Indexes for table `User`
--
ALTER TABLE `User`
  ADD PRIMARY KEY (`UserID`);

--
-- Indexes for table `User_has_Task`
--
ALTER TABLE `User_has_Task`
  ADD PRIMARY KEY (`UserID`,`TaskID`),
  ADD KEY `fk_User_has_Task_Task1_idx` (`TaskID`),
  ADD KEY `fk_User_has_Task_User1_idx` (`UserID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Task`
--
ALTER TABLE `Task`
  ADD CONSTRAINT `fk_Task_Type` FOREIGN KEY (`TypeID`) REFERENCES `Type` (`TypeID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `User_has_Task`
--
ALTER TABLE `User_has_Task`
  ADD CONSTRAINT `fk_User_has_Task_Task1` FOREIGN KEY (`TaskID`) REFERENCES `Task` (`TaskID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_User_has_Task_User1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
