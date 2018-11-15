use yelp_ETL;

SET SQL_SAFE_UPDATES = 0;
    
 create table users_new (
	user_id varchar(200) PRIMARY KEY,
    review_count INT,
    useful iNT,
    funny INT,
    fans INT
    );    
    
create table reviews_new1 (
		user_id varchar(200),
        stars INT
        );
        
select * from users_new;
select * from reviews_new1;

select u.user_id, review_count, useful, funny, fans, r.stars  from users_new AS u
	join reviews_new1 AS r ON u.user_id = r.user_id;