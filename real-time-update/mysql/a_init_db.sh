#!/bin/bash
###############################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
mysql --defaults-extra-file=/tpch/dbgen/mycreds.cnf -v -e "
    SET GLOBAL local_infile=true;
    DROP DATABASE IF EXISTS ${MYSQL_DATABASE};
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

    USE ${MYSQL_DATABASE};

    CREATE USER 'flink' IDENTIFIED WITH mysql_native_password BY 'flink';

    GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'flink';

    FLUSH PRIVILEGES;

    -- Create Base Table

    CREATE TABLE lineitem ( 
        l_orderkey    INTEGER NOT NULL,
        l_partkey     INTEGER NOT NULL,
        l_suppkey     INTEGER NOT NULL,
        l_linenumber  INTEGER NOT NULL,
        l_quantity    DECIMAL(15,2) NOT NULL,
        l_extendedprice  DECIMAL(15,2) NOT NULL,
        l_discount    DECIMAL(15,2) NOT NULL,
        l_tax         DECIMAL(15,2) NOT NULL,
        l_returnflag  CHAR(1) NOT NULL,
        l_linestatus  CHAR(1) NOT NULL,
        l_shipdate    DATE NOT NULL,
        l_commitdate  DATE NOT NULL,
        l_receiptdate DATE NOT NULL,
        l_shipinstruct CHAR(25) NOT NULL,
        l_shipmode     CHAR(10) NOT NULL,
        l_comment      VARCHAR(44) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    -- Add PK Constraint

    ALTER TABLE lineitem ADD PRIMARY KEY (l_orderkey, l_linenumber);

    -- Create Delta Table

    CREATE TABLE update_lineitem LIKE lineitem; 
    
    CREATE TABLE delete_lineitem (
        l_orderkey    INTEGER NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    ALTER TABLE delete_lineitem ADD PRIMARY KEY (l_orderkey);
   
    -- Disable Check

    SET UNIQUE_CHECKS = 0;"
