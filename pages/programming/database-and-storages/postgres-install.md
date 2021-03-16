# postgres 安装

##### 从 yum 安装并启动

```shell
yum install postgresql-server
service postgresql initdb
chkconfig postgresql on
service postgresql start
su - postgres
psql
\password postgres
\q
exit
```

##### 创建用户

```shell
su - postgres
psql
create user nap_admin WITH PASSWORD 'r00tme';
\q
```

##### 进入操作命令行并创建 db

```shell
psql
CREATE DATABASE nap OWNER nap_admin;
GRANT ALL PRIVILEGES ON DATABASE nap to nap_admin;
```

##### 删除 db

```shell
\q
dropdb -U postgres nap
```

##### 修改访问控制

```shell
su - postgres
vim data/pg_hba.conf
local all all  peer
host all all 192.168.10.0/24 md5
host all all 127.0.0.1/32 md5
#注释掉其他权限控制
```
##### 修改监听 ip

```shell
su - postgres
vim data/postgresql.conf
#修改 listen 为 *
```

##### mac 下的一些运维命令

```shell
psql -U postgres  -h 127.0.0.1 -p 5432 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nap_admin"
psql -U postgres  -h 127.0.0.1 -p 5432 -c "create database nap"
psql -U postgres -d postgres -h 127.0.0.1 -p 5432 -c "drop database nap"
```
