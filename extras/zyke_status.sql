CREATE TABLE IF NOT EXISTS `zyke_status` (
  `identifier` VARCHAR(255) NOT NULL,
  `data` mediumtext,
  UNIQUE (`identifier`)
);