create database if not exists dnssecfight;

use dnssecfight;

create table if not exists secure_delegation (
	hoster varchar(255),
	day date,
	num integer,
	unique index (hoster, day)
);
