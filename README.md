# Mysql Group Replication

via docker containers and docker-compose

Running as default compose files:

    docker-compose up --build

Config for all mysql services (8.x version) (it's identical for all of them except "--loose-group-replication-local-address={ some uniq name }:6606" command)
located in /configs/my-cnf file (with comments).

!! Be sure that you're running first master node than slaves !!

setup master node (run next commands in mysql. Explanation of this procedure located in scripts/my-init.sql):

    CALL set_as_master;

Which call next commands:

    SET @@GLOBAL.group_replication_bootstrap_group=1;
    create user IF NOT EXISTS 'repl'@'%';
    GRANT REPLICATION SLAVE ON *.* TO repl@'%';
    flush privileges;
    change master to master_user='root' for channel 'group_replication_recovery';
    START GROUP_REPLICATION;

and the next command

    SELECT * FROM performance_schema.replication_group_members;

should return next result:

    group_replication_applier	74f3c403-f3fe-11ea-a955-0242ac130003	alpha	3306	ONLINE	PRIMARY	8.0.21

setup slave node (run next commands in mysql. Explanation of this procedure located in scripts/my-init.sql):

    CALL set_as_slave;

Which call next commands:

    change master to master_user='repl' for channel 'group_replication_recovery';
    START GROUP_REPLICATION;
    SET @@global.read_only=1;

and the next command

    SELECT * FROM performance_schema.replication_group_members;

should return next result:

    group_replication_applier	74f3c403-f3fe-11ea-a955-0242ac130003	alpha	3306	ONLINE	PRIMARY	8.0.21
    group_replication_applier	7500e656-f3fe-11ea-8b39-0242ac130002	beta	3306	ONLINE	SECONDARY	8.0.21

In this implementation works auto failover. So if master will go down or becoma unreachable, some of the slaves
will become the master.
