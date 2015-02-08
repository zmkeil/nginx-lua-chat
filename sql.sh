#!/bin/bash

HOSTNAME="localhost"                                           #数据库信息
PORT="3306"
USERNAME="admin"
DBNAME="binshared"

step=2

if [ $step -lt 1 ]; then
#创建数据库
echo "create database by root"
create_db_sql="create database IF NOT EXISTS ${DBNAME}"
mysql -u root -p -e "${create_db_sql}"

echo "create tables by root"
TABLENAME="test_table_test2"
create_table_sql="create table IF NOT EXISTS ${TABLENAME} (
  name varchar(20), 
  id int(11) default 0 
)"
mysql -u root -p -e "${create_table_sql}" ${DBNAME}


echo "insert into table by admin"
insert_sql="insert into $TABLENAME values(
	'jxj',
	3
)"
mysql -u admin -p -e "${insert_sql}" ${DBNAME}
fi


if [ $step -lt 2 ]; then
TABLENAME="uic"
echo "create tables by root"
create_table_sql="create table IF NOT EXISTS ${TABLENAME} (
  uid int(11) default 0,
  email varchar(50), 
  name varchar(20),
  tel varchar(30)
)"
mysql -u root -p -e "${create_table_sql}" ${DBNAME}


echo "insert into table by admin"
insert_sql="insert into $TABLENAME values(
	1,
	'805920692@qq.com',
	'MANG',
	'15850728463'
)"
mysql -u admin -p -e "${insert_sql}" ${DBNAME}
fi


if [ $step -lt 3 ]; then
TABLENAME="applist"
echo "create tables by root"
create_table_sql="create table IF NOT EXISTS ${TABLENAME} (
  appid int(11) default 0,
  appname varchar(100),
  descri  varchar(100),
  pic	varchar(100),
  uid	int(11),
  pv	int(20),
  doit  int(20),
  talk	int(20)
)"
mysql -u root -p -e "${create_table_sql}" ${DBNAME}


echo "insert into table by admin"
insert_sql="insert into $TABLENAME values(
	1,
	'splice',
	'picture splice',
	'/xds.jpg',
	1,
	0,
	0,
	0
)"
mysql -u admin -p -e "${insert_sql}" ${DBNAME}

echo "insert into table by admin"
insert_sql="insert into $TABLENAME values(
	2,
	'dox',
	'save small files with Internet',
	'/xds.jpg',
	1,
	0,
	0,
	0
)"
mysql -u admin -p -e "${insert_sql}" ${DBNAME}
fi


