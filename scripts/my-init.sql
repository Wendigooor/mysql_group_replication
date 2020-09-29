DROP PROCEDURE IF EXISTS set_as_master;

DELIMITER $$
CREATE PROCEDURE set_as_master ()
BEGIN
  SET @@GLOBAL.group_replication_bootstrap_group=1;
  create user IF NOT EXISTS 'repl'@'%';
  GRANT REPLICATION SLAVE ON *.* TO repl@'%';
  flush privileges;
  change master to master_user='root' for channel 'group_replication_recovery';
  START GROUP_REPLICATION;
  -- SELECT * FROM performance_schema.replication_group_members;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS set_as_slave;

DELIMITER $$
CREATE PROCEDURE set_as_slave ()
BEGIN
  change master to master_user='repl' for channel 'group_replication_recovery';
  START GROUP_REPLICATION;
  SET @@global.read_only=1;
  -- SELECT * FROM performance_schema.replication_group_members;
END $$
DELIMITER ;
