/*System information*/
CREATE TABLE system_information (
    username    VARBINARY(20),
    pass        BINARY(64) NOT NULL,
    date_created   TIMESTAMP NOT NULL default NOW(),
    telephone   VARCHAR(11) NOT NULL,
    constraint unique_username PRIMARY KEY (username),
    constraint valid_username CHECK (username REGEXP '^[A-Za-z0-9]{6,}$'),
    constraint valid_telephone_number CHECK (telephone REGEXP '^09[0-9]{9}$')
);

/*Personal information*/
CREATE TABLE personal_information (
    iden_number VARCHAR(10),
    username    VARBINARY(20) NOT NULL,
    fname   VARCHAR(20) NOT NULL,
    lname   VARCHAR(20),
    nickname   VARCHAR(20),
    mobile  VARCHAR(11),
    date_of_birth   Date NOT NULL,
    default_access_level VARCHAR(30) not null DEFAULT 'Access granted',
    addr    VARCHAR(512),
    constraint unique_iden_number PRIMARY KEY (iden_number),
    FOREIGN KEY (username) REFERENCES system_information (username) ON DELETE CASCADE,
    constraint valid_default_access_level CHECK (default_access_level in ('Access granted', 'Access denied')),
    constraint valid_iden_number check (iden_number regexp '^[0-9]{10}$'),
    constraint valid_personal_mobile CHECK (mobile REGEXP '^09[0-9]{9}$')
);

/*Data visibility*/
CREATE TABLE data_visibility (
    username VARBINARY(20),
    exception_user VARBINARY(20),
    access_level VARCHAR(30) not null,
    PRIMARY KEY (username, exception_user),
    FOREIGN KEY (username) REFERENCES system_information (username) on delete cascade, 
    FOREIGN KEY (exception_user) REFERENCES system_information (username) on delete cascade, 
    constraint valid_access_level CHECK(access_level IN ('Access granted', 'Access denied')));

/*Notifications*/
CREATE TABLE notifications (
    notif_id INT AUTO_INCREMENT,
    username VARBINARY(20) not null,
    time_recieved TIMESTAMP not null default NOW(),
    notif_context    VARCHAR(512),
    PRIMARY KEY (notif_id),
    FOREIGN KEY (username) REFERENCES system_information (username) on delete cascade
);

/*Emails*/
CREATE TABLE emails (
    email_id INT AUTO_INCREMENT,
    sender  VARBINARY(20),
    subj VARCHAR(300),
    sending_time TIMESTAMP not null default NOW(),
    email_context VARCHAR(512),
    unread  BOOLEAN default 1,
    PRIMARY KEY (email_id),
    constraint valid_sender FOREIGN KEY (sender) REFERENCES system_information (username) on delete set null -- to keep emails if user deleted account
);

/*receivers*/
CREATE TABLE receivers (
	email_id INT,
	dest_username VARBINARY(20),
    unread  BOOLEAN default 1,
	PRIMARY KEY (email_id, dest_username),
	constraint valid_receiver_email FOREIGN KEY (dest_username) REFERENCES system_information (username) on delete cascade,
	FOREIGN KEY (email_id) REFERENCES emails (email_id)
);
	
/*receiversCC*/
CREATE TABLE receiversCC (
	email_id INT,
	dest_cc_username VARBINARY(20),
    unread  BOOLEAN default 1,
	PRIMARY KEY (email_id, dest_cc_username),
	constraint valid_receiverCC_email FOREIGN KEY (dest_cc_username) REFERENCES system_information (username) on delete cascade,
    FOREIGN KEY (email_id) REFERENCES emails (email_id)
);

create table logins (
    username VARBINARY(20) not null,
    login_time TIMESTAMP not null default NOW(),
    primary key (username),
    FOREIGN KEY (username) REFERENCES system_information (username) on delete cascade
);

-- Get Email Function
create function user_to_email(username varchar(20))
returns varchar(32)
return concat(username, '@foofle.com');

-- Get Username from E-mail Function
create function email_to_user(email varchar(32))
returns varchar(20)
return replace(email, '@foofle.com', '');

-- Enroll Function
DELIMITER //
CREATE FUNCTION enroll (
    username VARBINARY(20), pass_text VARBINARY(20), telephone VARCHAR(11),
    iden_number VARCHAR(10), fname VARCHAR(20), lname VARCHAR(20), nickname VARCHAR(20), mobile VARCHAR(11), date_of_birth Date, default_access_level VARCHAR(30), addr VARCHAR(512)
    )
    RETURNS CHAR(64)
    BEGIN
	DECLARE res CHAR(64);
	IF (select count(*) from system_information as t where LCASE(t.username)=username) = 0 THEN
        IF pass_text regexp '^[A-Za-z0-9]{6,}$' then
            INSERT INTO system_information VALUES (username, SHA2(pass_text, 256), NOW(), telephone);
            INSERT INTO personal_information VALUES (iden_number, username, fname, lname, nickname, mobile, date_of_birth, coalesce(default_access_level, 'Access granted'), addr);
            set res = 'signed up successfully';
        else
            set res = 'invalid password';
        end if;
	ELSE
		set res = 'Duplicate Exists';
	END IF; 
    return res;
END
//
DELIMITER ;

-- enroll usage
select enroll ('am1235', 'amamam', '09123456789', '0123465789', 'mama', 'mamy', null, null, '1301-01-01', null, null);
select enroll ('DD1235', 'amamam', '09123456789', '2123465789', 'mama', 'mamy', null, null, '1301-01-01', 'Access denied', null);
select enroll ('ZZ1235', 'amamam', '09123456789', '3123465789', 'mama', 'mamy', null, null, '1301-01-01', null, null);

-- Login Function
DELIMITER //
CREATE FUNCTION login (username VARBINARY(20), pass_text VARBINARY(20))
    RETURNS CHAR(64)
    BEGIN
	DECLARE res CHAR(64);
	IF (select count(*) from system_information as t where LCASE(t.username)=username and SHA2(pass_text, 256)=pass) = 1 THEN
        if (select count(*) from logins where logins.username=username) = 0 then
            insert into logins values (username, NOW());
        else
            update logins set login_time=now() where logins.username=username;
        END IF;
        set res = 'Logged in Successfully';
	ELSE
		set res = 'Wrong Username or Password';
	END IF; 
    return res;
END
//
DELIMITER ;

-- trigger for successful login
DELIMITER //
CREATE TRIGGER new_login_success
AFTER insert ON logins
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (new.username, 'Logged in Successfully');
END
//
CREATE TRIGGER re_login_success
AFTER update ON logins
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (new.username, 'Logged in Successfully');
END
//
DELIMITER ;

-- wrong login
select login('am1235', 'dsad');

-- correct login
select login('am1235', 'amamam');

-- set data_visibility
DELIMITER //
CREATE procedure set_data_visibility (excepted_username varchar(20), access_level varchar(30))
    BEGIN
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
	insert into data_visibility values (curr_user, excepted_username, access_level);
END;
//
DELIMITER ;

call set_data_visibility ('DD1235', 'Access denied');

-- Get current User Information Function
DELIMITER //
CREATE procedure get_my_info ()
    BEGIN
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
	select *
    from system_information natural join personal_information
    where system_information.username = curr_user;
END;
//
DELIMITER ;

-- get current user info
call get_my_info();

-- get someone else's info
DELIMITER //
CREATE procedure get_info (username varchar(20))
    BEGIN
    declare had_acces varchar(100) default 'did not have access';
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    if ((select default_access_level='Access denied' from personal_information as p_inf where p_inf.username=username)=1 
        and (select count(*) from data_visibility as d_vis where d_vis.username=username and exception_user=curr_user and access_level = 'Access granted')=1)
        or ((select default_access_level='Access granted' from personal_information as p_inf where p_inf.username=username)=1 
        and (select count(*) from data_visibility as d_vis where d_vis.username=username and exception_user=curr_user and access_level = 'Access denied')=0)
        then
        set had_acces = 'had access';
        select iden_number, fname, lname, nickname, mobile, date_of_birth, addr, default_access_level
        from  personal_information as per_inf
        where per_inf.username = username;
    else
        select '*' as iden_number,'*' as  fname,'*' as  lname,'*' as  nickname, '*' as mobile, '*' as date_of_birth, '*' as addr, '*' as default_access_level
        from  personal_information as per_inf
        where per_inf.username = username;
    end if;
    if (select count(*) from personal_information as p_inf where p_inf.username=username)=1 then
            insert into notifications(username, notif_context) values (username, concat(curr_user, ' requested your personal info and it ', had_acces));
    end if;
END;
//
DELIMITER ;

-- get other user's info
call get_info('DD1235');

-- Edit Profile Function
DELIMITER //
CREATE FUNCTION edit_proile(pass_text VARBINARY(20), telephone VARCHAR(11), iden_number VARCHAR(10), fname VARCHAR(20), lname VARCHAR(20), nickname VARCHAR(20),
 mobile VARCHAR(11), date_of_birth Date, default_access_level VARCHAR(30), addr VARCHAR(512))
RETURNS CHAR(64)
BEGIN
	DECLARE res CHAR(64);
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    IF pass_text is null or pass_text regexp '^[A-Za-z0-9]{6,}$' then
    
        update system_information as s_info 
        set s_info.pass = coalesce(sha2(pass_text, 256), s_info.pass),
        s_info.telephone=coalesce(telephone, s_info.telephone) 
        where s_info.username=curr_user;
        
        update personal_information as p_info
        set p_info.iden_number = coalesce(iden_number, p_info.iden_number),
        p_info.fname = coalesce(fname, p_info.fname),
        p_info.lname = coalesce(lname, p_info.lname),
        p_info.nickname = coalesce(nickname, p_info.nickname),
        p_info.mobile = coalesce(mobile, p_info.mobile),
        p_info.date_of_birth = coalesce(date_of_birth, p_info.date_of_birth),
        p_info.default_access_level = coalesce(default_access_level, p_info.default_access_level),
        p_info.addr = coalesce(addr, p_info.addr)
        where p_info.username=curr_user;
        
        set res = 'edit applied successfully';
    else
        set res = 'Invalid Password';
    end if;
    return res;
END
//

-- trigger for profile update (since update is applied to both system and personal information, one trigger is enough)
CREATE TRIGGER profile_edit_notif
AFTER update ON system_information
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (new.username, 'Profile Edited');
END
//
DELIMITER ;

-- make change to profile
select edit_proile (null, null, null, 'فارسی', 'فارسییی', null, null, null, null, null);

-- send e-mail
DELIMITER //
CREATE FUNCTION send_email (
    subj VARCHAR(300),
    email_context VARCHAR(512),
    receiver1 VARBINARY(32),receiver2 VARBINARY(32),receiver3 VARBINARY(32),
    receiverCC1 VARBINARY(32),receiverCC2 VARBINARY(32),receiverCC3 VARBINARY(32)
    )
    RETURNS CHAR(64)
    BEGIN
	DECLARE res CHAR(64) default 'Mailed Successfully';
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    
	insert into emails (sender, subj, email_context) values (curr_user, subj, email_context);
    insert into receivers(email_id, dest_username) select LAST_INSERT_ID(), email_to_user(r) from (select receiver1 as r  union select receiver2 as r union select receiver3 as r ) as t where r is not null;
    insert into receiversCC(email_id, dest_cc_username) select LAST_INSERT_ID(), email_to_user(r) from (select receiverCC1 as r  union select receiverCC2 as r union select receiverCC3 as r ) as t where r is not null;
    
    return res;
END
//

-- e-mail notification trigger
CREATE TRIGGER email_recv_notif
AFTER insert ON receivers
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (new.dest_username, concat('Email received from ',(select user_to_email(sender) from emails where email_id=new.email_id)));
END
//

CREATE TRIGGER email_recvCC_notif
AFTER insert ON receiversCC
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (new.dest_cc_username, concat('EmailCC received from ',(select user_to_email(sender) from emails where email_id=new.email_id)));
END
//
DELIMITER ;

-- send email
select login('am1235', 'amamam');
select send_email('testing', 'slm, tesy?', 'DD1235@foofle.com', null, null, null, 'ZZ1235@foofle.com', null);
select send_email('testing2', 'slm, tesy2?', 'ZZ1235@foofle.com', null, null, null, 'DD1235@foofle.com', null);

-- get inbox
DELIMITER //
CREATE procedure get_my_inbox (page int UNSIGNED) -- page >= 1
    BEGIN
    declare curr_user varchar(20);
    declare start_index int UNSIGNED;
    set start_index = (page - 1) * 3;
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    select *
    from (
    select receivers.email_id, sender, subj, sending_time, email_context, receivers.unread, receivers.dest_username from receivers join emails on receivers.email_id=emails.email_id where dest_username=curr_user
    union select receiversCC.email_id, sender, subj, sending_time, email_context, receiversCC.unread, receiversCC.dest_cc_username from receiversCC join emails on receiversCC.email_id=emails.email_id where dest_cc_username=curr_user
    ) as tmp
    order by tmp.sending_time desc
    limit start_index, 3 -- starting by (page-1)*10 with offset = 1
    ;
END;
//

-- get notifications
DELIMITER //
CREATE procedure get_my_notifs (page int UNSIGNED) -- page >= 1
    BEGIN
    declare curr_user varchar(20);
    declare start_index int UNSIGNED;
    set start_index = (page - 1) * 3;
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    select *
    from (
    select username, time_recieved, notif_context from notifications where username=curr_user
    ) as tmp
    order by tmp.time_recieved desc
    limit start_index, 3 -- starting by (page-1)*10 with offset = 1
    ;
END;
//

-- get outbox
CREATE procedure get_my_outbox (page int UNSIGNED) -- page >= 1
    BEGIN
    declare curr_user varchar(20);
    declare start_index int UNSIGNED;
    set start_index = (page - 1) * 3;
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    select *
    from (
    select * from emails where sender=curr_user
    ) as tmp
    order by tmp.sending_time desc
    limit start_index, 3 -- starting by (page-1)*10 with offset = 1
    ;
END;
//
DELIMITER ;

-- get fist page of outbox
call get_my_outbox(1);
-- login by other user
select login('DD1235', 'amamam');
-- get fist page of inbox
call get_my_inbox(1);

-- mark as read function
DELIMITER //
CREATE FUNCTION read_email (email_id int)
RETURNS CHAR(64)
BEGIN
	DECLARE res CHAR(64) default 'Invalid e-mail access';
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    if (select sender from emails where emails.email_id=email_id)=curr_user then
        update emails set unread=0 where emails.email_id=email_id;
        set res = 'Sent Mail Marked as Read Successfully';
    end if;
    if (select dest_username from receivers where receivers.email_id=email_id)=curr_user then
        update receivers set unread=0 where receivers.email_id=email_id;
        set res = 'Received Marked as Read Successfully';
    end if;
    if (select dest_cc_username from receiversCC where receiversCC.email_id=email_id)=curr_user then
        update receiversCC set unread=0 where receiversCC.email_id=email_id;
        set res = 'ReceivedCC Marked as Read Successfully';
    end if;
    return res;
END
//
DELIMITER ;

-- read first e-mail
select read_email(2);

commit;

-- delete email function
DELIMITER //
CREATE FUNCTION delete_email (email_id int)
RETURNS CHAR(64)
BEGIN
	DECLARE res CHAR(64) default 'Deleted Successfully';
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
    if (select sender from emails where emails.email_id=email_id)=curr_user then
        SET FOREIGN_KEY_CHECKS=0;
        update ignore emails set sender=NULL where emails.email_id=email_id;
        SET FOREIGN_KEY_CHECKS=1;
    elseif (select dest_username from receivers where receivers.email_id=email_id)=curr_user then
        delete from receivers where receivers.email_id=email_id;
    elseif (select dest_cc_username from receiversCC where receiversCC.email_id=email_id)=curr_user then
        delete from receiversCC where receiversCC.email_id=email_id;
    else
        set res = 'Invalid e-mail access';
    end if;
    return res;
END
//
DELIMITER ;

-- trigger for email deletion
DELIMITER //
CREATE TRIGGER outbox_email_delete
AFTER update ON emails
FOR EACH ROW
BEGIN
    if new.sender is null then
        insert into notifications(username, notif_context) values (old.sender, concat('Email with id ', old.email_id, ' Deleted from Outbox'));
    end if;
END;
//
CREATE TRIGGER inbox_email_delete
before delete ON receivers
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (old.dest_username, concat('Email with id ', old.email_id, ' Deleted from Inbox'));
END;
//
//
CREATE TRIGGER inbox_emailCC_delete
before delete ON receiversCC
FOR EACH ROW
BEGIN
    insert into notifications(username, notif_context) values (old.dest_cc_username, concat('Email with id ', old.email_id, ' Deleted from InboxCC'));
END;
//
DELIMITER ;

-- delete from outbox
select delete_email(2);
-- delete from inbox
select login('ZZ1235', 'amamam');
select delete_email(2);

-- delete account procedure
DELIMITER //
CREATE procedure delete_my_account ()
    BEGIN
    declare curr_user varchar(20);
    set curr_user = (select logins.username from logins order by login_time desc limit 1);
	delete from system_information where username=curr_user;
END;
//
DELIMITER ;

select login('DD1235', 'amamam');
call delete_my_account();
