-- MySQL Workbench Forward Engineering  
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;  
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;  
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';  
  
-- Drop schema if it exists  
DROP SCHEMA IF EXISTS `aoai_api`;  
  
-- Create schema  
CREATE SCHEMA IF NOT EXISTS `aoai_api` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;  
USE `aoai_api`;  
  
-- Create tables  
CREATE TABLE IF NOT EXISTS `aoai_api`.`aoaisystem` (  
  `system_id` INT NOT NULL AUTO_INCREMENT,  
  `system_prompt` MEDIUMTEXT NULL DEFAULT NULL,  
  `system_proj` VARCHAR(100) NULL DEFAULT NULL,  
  `prompt_number` INT NULL DEFAULT NULL,  
  PRIMARY KEY (`system_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
CREATE TABLE IF NOT EXISTS `aoai_api`.`python_api` (  
  `api_id` INT NOT NULL AUTO_INCREMENT,  
  `api_name` VARCHAR(2048) NOT NULL,  
  PRIMARY KEY (`api_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
CREATE TABLE IF NOT EXISTS `aoai_api`.`models` (  
  `model_id` INT NOT NULL AUTO_INCREMENT,  
  `model` VARCHAR(255) NULL DEFAULT NULL,  
  `prompt_price` DECIMAL(10,6) NULL DEFAULT NULL,  
  `completion_price` DECIMAL(10,6) NULL DEFAULT NULL,  
  `tiktoken_encoding` VARCHAR(45) NULL DEFAULT NULL,  
  PRIMARY KEY (`model_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
CREATE TABLE IF NOT EXISTS `aoai_api`.`prompt` (  
  `prompt_id` INT NOT NULL AUTO_INCREMENT,  
  `system_id` INT NULL DEFAULT NULL,  
  `user_prompt` MEDIUMTEXT NULL DEFAULT NULL,  
  `tokens` INT NULL DEFAULT NULL,  
  `price` DECIMAL(10,5) NULL DEFAULT NULL,  
  `timestamp` VARCHAR(20) NULL DEFAULT NULL,  
  PRIMARY KEY (`prompt_id`),  
  INDEX `system_id` (`system_id` ASC) VISIBLE,  
  CONSTRAINT `prompt_ibfk_1`  
    FOREIGN KEY (`system_id`)  
    REFERENCES `aoai_api`.`aoaisystem` (`system_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
CREATE TABLE IF NOT EXISTS `aoai_api`.`chat_completions` (  
  `completion_id` INT NOT NULL AUTO_INCREMENT,  
  `model_id` INT NULL DEFAULT NULL,  
  `prompt_id` INT NULL DEFAULT NULL, 
  `api_id` INT NULL DEFAULT NULL, 
  `chat_completion` MEDIUMTEXT NULL DEFAULT NULL,  
  `tokens` INT NULL DEFAULT NULL,  
  `price` DECIMAL(10,5) NULL DEFAULT NULL,  
  `timestamp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,   
  PRIMARY KEY (`completion_id`),  
  INDEX `model_id` (`model_id` ASC) VISIBLE,  
  INDEX `prompt_id` (`prompt_id` ASC) VISIBLE,  
  INDEX `api_id_idx` (`api_id` ASC) VISIBLE,  
  CONSTRAINT `api_id`  
    FOREIGN KEY (`api_id`)  
    REFERENCES `aoai_api`.`python_api` (`api_id`),  
  CONSTRAINT `chat_completions_ibfk_1`  
    FOREIGN KEY (`model_id`)  
    REFERENCES `aoai_api`.`models` (`model_id`),  
  CONSTRAINT `chat_completions_ibfk_2`  
    FOREIGN KEY (`prompt_id`)  
    REFERENCES `aoai_api`.`prompt` (`prompt_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- Create views  
DROP VIEW IF EXISTS `aoai_api`.`aoai_cost_total`;  
CREATE VIEW `aoai_api`.`aoai_cost_total` AS  
SELECT   
  SUM(`aoai_api`.`prompt`.`price`) AS `Sum total from prompt only ($)`,  
  SUM(`aoai_api`.`chat_completions`.`price`) AS `Sum total from prompt + ai response ($)`  
FROM   
  `aoai_api`.`prompt`  
JOIN   
  `aoai_api`.`chat_completions`   
ON   
  `aoai_api`.`prompt`.`prompt_id` = `aoai_api`.`chat_completions`.`prompt_id`;  
  
DROP VIEW IF EXISTS `aoai_api`.`aoai_metadata`;  
CREATE VIEW `aoai_api`.`aoai_metadata` AS  
SELECT   
  `aoaisystem`.`system_proj` AS `System prompt`,  
  `aoaisystem`.`prompt_number` AS `Prompt Number`,  
  `prompt`.`user_prompt` AS `User prompt`,  
  `prompt`.`tokens` AS `User prompt tokens`,  
  `prompt`.`price` AS `Prompt price`,  
  `prompt`.`timestamp` AS `Time asked`,  
  `chat_completions`.`chat_completion` AS `AI response`,  
  `chat_completions`.`tokens` AS `AI response tokens`,  
  `chat_completions`.`price` AS `Completion price`,  
  `chat_completions`.`timestamp` AS `Time answered`,  
  `models`.`model` AS `AI model`,  
  `python_api`.`api_name` AS `AOAI MySQL API`  
FROM   
  `aoaisystem`  
JOIN   
  `prompt` ON `aoaisystem`.`system_id` = `prompt`.`system_id`  
JOIN   
  `chat_completions` ON `prompt`.`prompt_id` = `chat_completions`.`prompt_id`  
JOIN   
  `python_api` ON `chat_completions`.`api_id` = `python_api`.`api_id`  
JOIN   
  `models` ON `chat_completions`.`model_id` = `models`.`model_id`  
ORDER BY   
  `prompt`.`timestamp` DESC;  
  
SET SQL_MODE=@OLD_SQL_MODE;  
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;  
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;  
