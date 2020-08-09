/* Host Table */ 
create table host (
    name        varchar(100) not null,
    constraint p_name primary key (name)
);

/* Conference Table */
create table conference (
    id           varchar(20) not null,
    topic        varchar(100) not null,
    start_time   Date not null,
    end_time     Date not null,
    host_n    varchar(100) not null,
    url          varchar(2048) not null,
    constraint unique_id primary key (id),
    foreign key (host_n) references host (name)
);

/* Admin Accounts Table */
create table accounts (
    username    varbinary(20),
    pass        binary(64) not null,
    constraint user_primary primary key (username)
);

/*Participators Table */
create table participator (
    id          varbinary(20),  
    name        varchar(100) not null,
    email       varchar(100) not null,
    telephone   varchar(11) not null,
    constraint unique_id primary key (id)
);

/* Logins Table */
create table logins (
    username varbinary(20) not null,
    login_time timestamp not null default NOW(),
    primary key (username),
    foreign key (username) references accounts (username) on delete cascade
);

-- Add Conference Function and Host info
delimiter //
create function addConference (
    id varchar(20), topic varchar(100), start_time Date, end_time Date, host_n varchar(100), url varchar(100))
    returns char(64)
    begin
	declare res char(64);
            insert into host values (host_name);
            insert into conference values (id, topic, start_time, end_time, host_n, url);
            set res = '.اطلاعات ویدئو کنفرانس با موفقیت وارد شد';
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
    if (select count(*) from accounts where SHA2(pass_text, 256)=pass) = 1 THEN
            if (select count(*) from logins where logins.username=username) = 0 then
                insert into logins values (username, NOW());
            else
                update logins set login_time=now() where logins.username=username;
            end if;
        set res = '.ورود با موفقیت انجام شد'
    else
        set res = '.نام کاربری و یا رمز اشتباه است'
    end if;
    return res;
end
//
delimiter ;
