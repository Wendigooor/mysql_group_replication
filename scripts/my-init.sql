
DROP PROCEDURE IF EXISTS set_as_master_force;

DELIMITER $$
CREATE PROCEDURE set_as_master_force ()
BEGIN
  SET @@global.read_only=0;
  SET @@GLOBAL.group_replication_bootstrap_group=1;

  STOP GROUP_REPLICATION;
  RESET MASTER;

  create user IF NOT EXISTS 'repl'@'%';
  GRANT REPLICATION SLAVE ON *.* TO repl@'%';
  flush privileges;
  change master to master_user='root' for channel 'group_replication_recovery';

  START GROUP_REPLICATION;
  -- SELECT * FROM performance_schema.replication_group_members;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS set_as_slave_force;

DELIMITER $$
CREATE PROCEDURE set_as_slave_force ()
BEGIN
  SET @@GLOBAL.group_replication_bootstrap_group=0;
  SET @@global.read_only=0;

  STOP GROUP_REPLICATION;
  RESET MASTER;
  RESET SLAVE;

  change master to master_user='repl' for channel 'group_replication_recovery';

  STOP GROUP_REPLICATION;
  START GROUP_REPLICATION;

  SET @@global.read_only=1;
  -- SELECT * FROM performance_schema.replication_group_members;
END $$
DELIMITER ;

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
