CREATE TABLE IF NOT EXISTS `zyke_status` (
  `identifier` tinytext,
  `data` mediumtext,
  UNIQUE (`identifier`)
);