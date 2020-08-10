-- Hosts Table 
create table hosts (
	id			int auto_increment,
    name        varchar(100) not null,
    key (id),
    primary key (name)
);

-- Conferences Table
create table conference (
    id           varchar(20) not null,
    topic        varchar(100) not null,
    start_Date   Date not null,
    end_Date     Date not null,
	start_time	 time (0),
	end_time	 time (0),
    host_n    	 varchar(100) not null,
    url          varchar(2048) not null,
    primary key (id, topic),
    foreign key (host_n) references hosts (name) on update cascade
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
    fname       varchar(100) not null,
	lname		varchar(100) not null,
    email       varchar(100) not null,
	conf_id		varchar(20) not null,
    telephone   varchar(11) not null,
    key (id),
	primary key (fname, lname),
	foreign key (conf_id) references conference (id) on update cascade
);

-- Guests TABLE
create table guests (
	id		int auto_increment,
	fname	varchar(100) not null,
	lname	varchar(100) not null,
	primary key(id,fname,lname)
);

-- Login Table
create table logins (
    username varbinary(20) not null,
    login_time timestamp not null default NOW(),
    primary key (username),
    foreign key (username) references AdminAcc (username) on delete cascade
);

-- Add Conference Function and Host info
delimiter //
create function addConference (
    id varchar(20), topic varchar(100), start_Date Date, end_Date Date, start_time time (0), end_time time (0), host_n varchar(100), url varchar(100))
    returns char(64)
    begin
	declare res char(64);
			if (select count(*) from conference as c where (c.id=id) and (c.topic=topic) and (c.start_Date=start_Date) and (c.end_Date=end_Date) and (c.start_time=start_time) and (c.end_time=end_time) and (c.host_n=host_n)) = 0 then
				insert into conference values (id, topic, start_Date, end_Date, start_time, end_time, host_n, url);
				set res = 'Data is saved';
			else
				set res = 'Data Duplication';
			end if;
			if (select count(*) from hosts as t where t.name=host_n) = 0 then
				insert into hosts values (host_n);
			end if;
    return res;
end
//
delimiter ;

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
create function deleteHost ()
end
//
delimiter ;

-- Trigger for checking timeoverlap of conferences
delimiter //
create trigger overlap
before insert on conference
for each row
begin
	if exists (select count(*) from conference
				where (start_Date=new.start_Date) and (end_Date=new.end_Date) 
				and (start_time <= new.end_time) and (end_time >= new.start_time)) then
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Overlap';
	end if;
end;


