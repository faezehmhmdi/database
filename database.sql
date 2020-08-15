-- Hosts Table 
create table Hosts (
	id	int auto_increment,
	name	varchar(100) not null,
	manager	varchar(100) not null,
	key (id),
	primary key(name,manager)
);

-- Conferences Table
create table Conference (
	id	int auto_increment,
    request_number	varchar(100) not null,
	request_sentDate	Date not null,
    topic	varchar(100) not null,
    start_Date	Date not null,
    end_Date	Date not null,
	start_time	time (0) not null default '08:00:00',
	end_time	time (0) not null default '08:00:00',
	placeId	int,
    hostId	int,
	platformId	int,	
	supporterId	int,
	isCanceled	boolean default 0,
	isHost	boolean	default	1, --if 0 we are guest if 1 we are host
    key(id),
	primary key(request_number, topic),
	check (start_time <= end_time),
	check (start_Date <= end_Date ),
    foreign key (hostId) references Hosts (id)
	on update cascade 
	on delete cascade,
	foreign key (supporterId) references Supporter (id)
	on update cascade 
	on delete cascade,
	foreign key (platformId) references Platform (id) 
	on update cascade
	on delete cascade,
	foreign key (placeId) references Place (id)
	on update cascade
	on delete cascade
);

--Supporter TABLE
create table Supporter (
	id int auto_increment,
	name	varchar(100) not null,
	telephone varchar(11) not null,
	key(id),
	primary key(id, name),
	constraint valid_telephone_number check (telephone REGEXP '^09[0-9]{9}$')
);

--platform Table
create table Platform (
	id int auto_increment,
	name	varchar(100) not null,
	url	varchar(2048) not null,
	description	varchar(512) not null,
	key (id),
	primary key(id, name)
);

--Place Table
create table Place (
	id int auto_increment,
	name	varchar(100) not null,
	isEmpty	boolean not null default 1,
	key(id),
	primary key(id, name)
);

-- Admin Account Table
create table AdminAcc (
    username    varbinary(20),
    pass        binary(64) not null,
    primary key (username)
);

-- Participators Table
create table participator (
    id          int auto_increment,  
    name	varchar(100) not null,
	confId		int,
    key (id),
	primary key (fnam),
	foreign key (conf_id) references conference (id) on update cascade on delete cascade
);


-- Login Table
create table logins (
    username varbinary(20) not null,
    login_time timestamp not null default NOW(),
    primary key (username),
    foreign key (username) references AdminAcc (username) on delete cascade
);

--Add Host Function 
delimiter //
create function addHost (
	hostName varchar(100), manager varchar(100))
	returns char(64)
	begin
	declare res char(64);
	if(select count(*) from Hosts as h where (h.name = hostName) and (h.manager = manager)) = 0 then
		insert into Hosts values ('',hostName, manager);
		set res = 'Host added.';
	else
		set res = 'Host with the same manager exists.';
	end if;
	return res;
end
//
delimiter ;

-- Edit Host info Function
delimiter //
create function editHost (
	name varchar(100) ,manager varchar(100))
	returns char(64)
	begin
	declare res char(64)
	if ()
end
//
delimiter ;

-- Add Supporter Function
delimiter //
create function addSupporter (
	SupporterName varchar(100), telephone varchar(11))
	returns char(64)
	begin
	declare res char(64);
	if(select count(*) from Supporter as s where (s.name = supporterName) and (s.telephone = telephone)) = 0 then
		insert into Supporter values ('', supporterName, telephone);
		set res = 'Supporter added.';
	else
		set res = 'Supporter with same telephone exists.';
	end if;
	return res;
end
//
delimiter ;

-- Add Platform Function
delimiter //
create function addPlatform (
	platName varchar(100),url varchar(2048),description	varchar(512))
	returns char(64)
	begin
	declare res char(64);
	if (select count(*) from Platform as p where (p.name = platName) and (p.url = url) and (p.description = description)) = 0 then
		insert into Platform values ('', platName, url, description);
		set res = 'Platform added.';
	else
		set res = 'Already exists.';
	end if;
	return res;
end
//
delimiter ;

/* -- fix defaul beging 1
-- fix defaul beging 1
-- fix defaul beging 1*/
-- Add Place Function
delimiter //
create function addPlace (
	placName varchar(100), isEmp boolean)
	returns char(64)
	begin
	declare res char(64);
	if (select count(*) from Place as p where (p.name = placName)) = 0 then
		insert into Place values ('', placName, coalesce(isEmp, 1));
		set res = 'Place added.';
	else
		update Place as p set p.isEmpty = isEmp where p.name = placName;
		set res = 'Updated.';
	end if;
	return res;
end
//
delimiter ;


-- Add Conference and Supporter and platform and place and host info in their tables
delimiter //
create function addAllDetails (
	request_number varchar(100), request_sentDate Date, topic varchar(100), start_Date Date, end_Date Date, start_time time (0),
	end_time time (0),isCanceled bit default 0, isHost bit default 0, hostName varchar(100), manager varchar(100),supporterName varchar(100),
	telephone varchar(11), platformName varchar(100),url varchar(2048), description varchar(512), placeName varchar(100), isEmpty bit default 1)
	returns char(64)
	begin
	declare res char(64);
	insert into Hosts values (hostName, manager);
	insert into Platform values (platformName, url, description);
	if (select count(*) from Supporter as s where (s.name = supporterName) and (s.telephone = telephone)) = 0 then
		insert into Supporter values (supporterName, telephone);
	else
		set res = 'Supporter Exists';
	if (select count(*) from Place as plac where plac.name = placeName) = 0 then
		insert into Place values (placeName, isEmpty);
	else
		update Place as p set p.isEmpty = isEmpty where plac.name = placeName;
	if (select count(*) from Conference as c from)
		
end
//
delimiter :


-- Login Admin Function
delimiter //
create function login (
    username varbinary(20), pass_text varbinary(20))
    returns char(64)
    begin
    declare res char(64);
    if (select count(*) from AdminAcc as temp where(temp.username=username) and (SHA2(pass_text, 256)=pass))= 1 then
            if (select count(*) from logins where logins.username=username) = 0 then
                insert into logins values (username, NOW());
            else
                update logins set login_time=now() where logins.username=username;
            end if;
        set res = 'Logged in';
    else
        set res = 'Wrong username or password';
    end if;
    return res;
end
//
delimiter ;

-- Add Admin Function
delimiter //
create function addAdmin (
	username varbinary(20), pass varbinary(20))
	returns char(64)
	begin
	declare res char(64);
    if (select count(*) from AdminAcc as t where t.username=username) = 0 then
	   insert into AdminAcc values (username, SHA2(pass, 256));
	   set res = 'Admin account saved';
    else
        set res = 'Account Duplication';
    end if;
	return res;
end
//
delimiter ;

-- Add Participator Function
delimiter //
create function addPartic (
	fname varchar(100), lname varchar(100), email varchar(100), conf_id varchar(20), telephone varchar(11))
	returns char(64)
	begin
	declare res char(64);
	if(select count(*) from conference as c where c.id=conf_id) = 1 then
		insert into participator values ('',fname, lname, email, conf_id, telephone);
		set res = 'Information saved';
	else
		set res = 'conference does not exist';
	end if;
	return res;
end
//
delimiter ;

-- Edit Conference Info Function
-- if no result change to procedure
delimiter //
create function editConf ()
end
//
delimiter ;

-- Edit Participators Info Function
-- if no result change to procedure
delimiter //
create function editPartic ()
end
//
delimiter ;

-- Edit Guest Info Function
-- if no result change to procedure
delimiter //
create function editGuest ()
end
delimiter ;

-- Cancel Conference Function
-- if no result change to procedure
delimiter //
create function cancelConf ()
end
//
delimiter ;

-- Delete Participator Function
-- if no result change to procedure
delimiter //
create function deletePartic ()
end
//
delimiter ;

-- Delete Guest Function
-- if no result change to procedure
delimiter //
create function deleteGuest ()
end
//
delimiter ;

-- Delete Host Function 
-- if no result change to procedure
delimiter //
create function deleteHost (
	name varchar(100))
	returns char(64)
	begin
	declare res char(64);
	if(select count(*) from hosts as h where h.name=name) = 1 then
		delete from hosts where name=name;
		set res = 'Deleted';
	else
		set res ='Data does not exist';
	end if;
end
//
delimiter ;


-- Trigger for checking timeoverlap of conferences
delimiter //
create trigger overlap
before insert on conference
for each row
begin
	if exists (select count(*)
			    from conference as c1, from conference as c2
				where (c1.start_Date=c2.start_Date) and (c1.end_Date=c2.end_Date) 
				and (c1.start_time <= c2.end_time) and (c1.end_time >= c2.start_time)) then
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Overlap';
	end if;
end
//
delimiter ;


