/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
________________________________
SELECT name
FROM `Facilities`
WHERE membercost >0
________________________________







/* Q2: How many facilities do not charge a fee to members? */
________________________________
SELECT COUNT( facid )
FROM `Facilities`
WHERE membercost =0

Output: 4
________________________________





/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

________________________________
SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost >0
AND membercost < 0.2 * monthlymaintenance
________________________________






/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

________________________________
SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 )
________________________________





/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

________________________________

SELECT name, `monthlymaintenance` ,
CASE
WHEN `monthlymaintenance` >100
THEN 'Expensive'
ELSE 'Cheap'
END AS maintenance
FROM `Facilities`

________________________________




/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

________________________________
SELECT surname, firstname
FROM Members
WHERE joindate = (
    SELECT MAX( joindate ) FROM Members )
______________________________




/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
________________________________
SELECT DISTINCT CONCAT( firstname, ' ', surname ) AS member_name, subquery.name
FROM Members AS M
INNER JOIN (

SELECT name
FROM Facilities AS f
INNER JOIN (

SELECT facid
FROM Bookings
WHERE facid =1
OR facid =0
) AS B ON f.facid = B.facid
) AS subquery
ORDER BY member_name
________________________________






/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

******** Resubmitted this one ******
___________
SELECT CONCAT( firstname, ' ', surname ) AS member, name AS facility,
CASE WHEN firstname = 'GUEST'
THEN guestcost * slots
ELSE membercost * slots
END AS cost
FROM Members
INNER JOIN Bookings ON Members.memid = Bookings.memid
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE starttime >= '2012-09-14'
AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST'
THEN guestcost * slots
ELSE membercost * slots
END >30
ORDER BY cost DESC
LIMIT 0 , 30
________________________________


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
________________________________

SELECT Sub1.member_name, subquery.name, subquery.PRICE
FROM (

SELECT CONCAT( firstname, ' ', surname ) AS member_name, memid
FROM Members AS M
WHERE memid
IN (

SELECT memid
FROM Bookings
WHERE starttime LIKE '2012-09-14%'
)
) AS Sub1
INNER JOIN (

SELECT name, Bookings.bookid, Bookings.memid, Facilities.facid,
CASE WHEN Bookings.memid =0
THEN guestcost * Bookings.slots
ELSE membercost * Bookings.slots
END AS Price
FROM Facilities
JOIN Bookings ON Facilities.facid = Bookings.facid
) AS subquery ON Sub1.memid = subquery.memid
WHERE subquery.PRICE >30
ORDER BY subquery.PRICE DESC
________________________________



/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

******** This method did not work.  I've reached out for help to the TA but received no help. So I used the PHPMyAdmin interface******

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
________________________________
SELECT name, revenue
FROM (

SELECT name, SUM( Price ) AS revenue
FROM (

SELECT name, Bookings.bookid, Bookings.memid, Facilities.facid,
CASE WHEN Bookings.memid =0
THEN guestcost * Bookings.slots
ELSE membercost * Bookings.slots
END AS Price
FROM Facilities
JOIN Bookings ON Facilities.facid = Bookings.facid
) AS subquery
GROUP BY name
) AS sub2
WHERE revenue <1000
ORDER BY revenue
________________________________




/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
________________________________
SELECT a.surname, a.firstname, b.surname AS recommbysurname, b.firstname AS recommbyfirstname
FROM Members a, Members b
WHERE a.memid = b.recommendedby
AND a.memid <>0
ORDER BY a.surname, a.firstname
________________________________





/* Q12: Find the facilities with their usage by member, but not guests */
________________________________
SELECT name, bookingcount.totalbooks
FROM Facilities
JOIN (

SELECT COUNT( bookid ) AS totalbooks, facid
FROM Bookings
WHERE memid >0
GROUP BY facid
) AS bookingcount ON Facilities.facid = bookingcount.facid
________________________________





/* Q13: Find the facilities usage by month, but not guests */

___________________________
SELECT name, bookingcount.totalbooks, bookingcount.month
FROM Facilities
JOIN (

SELECT COUNT( bookid ) AS totalbooks, facid, EXTRACT(
MONTH FROM starttime ) AS
MONTH
FROM Bookings
WHERE memid >0
GROUP BY facid,
MONTH
) AS bookingcount ON Facilities.facid = bookingcount.facid
_________________________

