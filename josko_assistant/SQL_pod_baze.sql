CREATE TABLE User(
    UserID int not null,
    Username varchar(45) not null,
    Password varchar(45) not null,
    Primary key(UserID),
);

CREATE TABLE Type(
    TypeID int not null,
    TypeName varchar(45),
    Primary key(TypeID),
);

CREATE TABLE Task(
    TaskID int not null,
    TypeID int not null,
    PinNum int,
    Primary key(TaskID),
    Foreign key(TypeID) references Type(TypeID),
);

CREATE TABLE SeznamUserTaskov(
    UserID int not null,
    TaskID int not null,
    Primary key(UserID, TaskID),
    
    Foreign key(TaskID) references Task(TaskID),
    Foreign key(UserID) references User(UserID),
);



_______________________________________________________________________________________________
_______________________________________________________________________________________________





CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;

-- -----------------------------------------------------
-- Table `mydb`.`User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`User` (
  `UserID` INT NOT NULL,
  `Username` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  PRIMARY KEY(`UserID`)
)ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Type` (
  `TypeID` INT NOT NULL,
  `TypeName` VARCHAR(45) NOT NULL,
  PRIMARY KEY(`TypeID`)
)ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Task`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Task` (
  `TaskID` INT NOT NULL,
  `PinNum` INT,
  `TypeID` INT NOT NULL,
  PRIMARY KEY(`TaskID`, `TypeID`),
  INDEX `fk_Task_Type1_idx` (`TypeID` ASC) VISIBLE,
  CONSTRAINT `fk_Task_Type1`
    FOREIGN KEY(`TypeID`)
    REFERENCES `mydb`.`Type` (`TypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`User_has_Task`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`User_has_Task` (
  `UserID` INT NOT NULL,
  `TaskID` INT NOT NULL,
  PRIMARY KEY(`UserID`, `TaskID`),
  INDEX `fk_User_has_Task_Task1_idx` (`TaskID` ASC) VISIBLE,
  INDEX `fk_User_has_Task_User_idx` (`UserID` ASC) VISIBLE,
  CONSTRAINT `fk_User_has_Task_User`
    FOREIGN KEY(`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_User_has_Task_Task1`
    FOREIGN KEY(`TaskID`)
    REFERENCES `mydb`.`Task` (`TaskID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;