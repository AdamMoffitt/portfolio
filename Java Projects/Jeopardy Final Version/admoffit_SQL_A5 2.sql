DROP TABLE IF EXISTS `Jeopardy`.`User`;
DROP SCHEMA IF EXISTS `Jeopardy`;
CREATE SCHEMA `Jeopardy` ;
CREATE TABLE `Jeopardy`.`User` (
  `user_id` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC));