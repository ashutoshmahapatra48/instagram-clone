use ig_clone;
/*We want to reward our users who have been around the longest.  
Find the 5 oldest users.*/
select *  from users order by created_at limit 5;

/*What day of the week do most users register on?
We need to figure out when to schedule an ad campgain*/
select dayname(created_at) as days,count(username) as total_users from users group by dayname(created_at) order by total_users desc;

/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/
 select username from users u 
 left join photos p on u.id= p.user_id 
 where p.id is null;
 
 /*We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/

select u.username,l.photo_id,count(l.user_id) total_likes from users u 
join photos p on u.id= p.user_id
join likes l on p.id=l.photo_id
group by l.photo_id
order by total_likes desc;

/*Our Investors want to know...
How many times does the average user post?*/
/*total number of photos/total number of users*/
select (select count(*) from photos)/count(*) as avg_post from users;
SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2);

/*user ranking by postings higher to lower*/
select user_id,users.username,count(photos.id) total_post from photos 
join users on photos.user_id=users.id 
group by user_id
order by 3 desc;

/*Total Posts by users (longer versionof SELECT COUNT(*)FROM photos) */
select sum(total_post) from (select user_id,users.username,count(photos.id) total_post from photos 
join users on photos.user_id=users.id 
group by user_id
order by 3 desc) as post_count;

/*total numbers of users who have posted at least one time */
select count(distinct user_id) as users_at_least_one_post from photos;

SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
JOIN photos ON users.id = photos.user_id;

/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/

select pt.tag_id,t.tag_name,count(pt.photo_id) total_post from photo_tags pt 
join tags t on pt.tag_id=t.id
group by pt.tag_id
order by total_post desc
limit 5;

/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/

select l.user_id,u.username,count(l.photo_id) total_photos from likes l 
join users u on l.user_id=u.id
group by user_id
having total_photos = (select count(*) from photos)
;

/*We also have a problem with celebrities
Find users who have never commented on a photo*/
select username,c.comment_text from users u 
left join comments c on u.id=c.user_id
group by u.id
having c.comment_text is null;



/*Mega Challenges
Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/
select table1.total_celebrities as no_of_celebrities,
       (table1.total_celebrities/(select count(*) from users))*100 as '% of total users',
       table2.total_bots as no_of_bots,
       (table2.total_bots/(select count(*) from users))*100 as '% of total users' 
from
		(
			select count(*) as total_celebrities from
				(select username,c.comment_text from users u 
						left join comments c on u.id=c.user_id
						group by u.id
						having c.comment_text is null) as celebrities
		 )table1
	join
		(
			select count(*) as total_bots from
				(select u.username,count(c.user_id) as total_comments from users u 
						join comments c on u.id=c.user_id
						group by c.user_id
						having total_comments >=(select count(*) from photos)) as bots
		) table2
;

/*Find users who have ever commented on a photo*/
select count(*) as users_ever_commented from
				(select u.username from users u 
					join comments c on u.id=c.user_id
					group by c.user_id
                    ) as total_users_ever_commented;
				
/*Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on photos before*/

select table1.total_celebrities as no_of_users_not_commented,
       (table1.total_celebrities/(select count(*) from users))*100 as '% of total users',
       table2.users_ever_commented as no_of_users_commented,
       (table2.users_ever_commented/(select count(*) from users))*100 as '% of total users' 
from
		(
			select count(*) as total_celebrities from
				(select username,c.comment_text from users u 
						left join comments c on u.id=c.user_id
						group by u.id
						having c.comment_text is null) as celebrities
		 )table1
	join
		(
			select count(*) as users_ever_commented from
				(select u.username from users u 
					join comments c on u.id=c.user_id
					group by c.user_id
                    ) as total_users_ever_commented
            
		) table2
;
