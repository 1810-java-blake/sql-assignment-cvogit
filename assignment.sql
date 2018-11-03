-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
Ok

-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM employee;

-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee
WHERE lastname = 'King';

-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee
WHERE firstname = 'Andrew' AND 
reportsto IS NULL;

-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album
ORDER BY title DESC;

-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer
ORDER BY city ASC;

-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO genre (genreid, name)
VALUES (26, 'Youtube');

-- Task – Insert two new records into Employee table
INSERT INTO employee VALUES(9, 'K', 'Priya', 'Yo', null, 
	TIMESTAMP '2018-05-16 15:36:38', TIMESTAMP '2018-05-16 15:36:38', 
	'address', 'city', 'random state', 'that one country', 76013, 1234567890, 
	'fax adress', 'real@email.com');
INSERT INTO employee VALUES(10, 'K', 'Priya 2', 'Hello', null, 
	TIMESTAMP '2018-05-16 15:36:38', TIMESTAMP '2018-05-16 15:36:38', 
	'address', 'Riverside', 'this state', 'this one country', 76013, 1234567890, 
	'fax adress', 'thisone@email.com');
-- Task – Insert two new records into Customer table
INSERT INTO customer VALUES(60, 'Priya', 'K', 'Awesome Company', 'address', 
	'Riverside', 'California', 'US', 76013, 1234567890, 
	'fax adress', 'thisone@email.com', 1);
INSERT INTO customer VALUES(61, 'Priya 2', 'K', 'Awesome Company', 'address', 
	'Riverside', 'California', 'US', 76013, 1234567890, 
	'fax adress', 'thissecond@email.com', 1);

-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer
SET firstname = 'Robert',
    lastname = 'Walter'
WHERE
 firstname = 'Aaron' AND 
 lastname = 'Mitchell';

-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist
SET name = 'CCR'
WHERE name = 'Creedence Clearwater Revival';

-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice
WHERE billingaddress LIKE 'T%';

-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice
WHERE total > 15 AND total < 50;

-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee
WHERE hiredate::date > date '2003-06-1' AND hiredate::date < '2004-03-1';

-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM invoiceline
WHERE invoiceid IN (
	SELECT invoiceid FROM invoice
	WHERE customerid IN (
		SELECT customerid FROM customer
		WHERE firstname = 'Robert' AND lastname = 'Walter'
		)
	);
DELETE FROM invoice
WHERE customerid IN (
	SELECT customerid FROM customer
	WHERE firstname = 'Robert' AND lastname = 'Walter'
	);
DELETE FROM customer
WHERE firstname = 'Robert' AND lastname = 'Walter';
-- 3.0	SQL Functions
-- In this section you will be using the Postgres system functions, as well as your own functions, to perform various actions against the database

-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE FUNCTION get_current_time() 
RETURNS timestamp as $$
   	BEGIN
      	RETURN NOW()::timestamp;
   	END; 
$$ LANGUAGE plpgsql;

-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION get_media_length(
 a TEXT)
RETURNS integer as $$
   	BEGIN
		RETURN length(a) FROM mediatype
				WHERE mediatype.name = a;
	END;
$$ LANGUAGE plpgsql;

-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION get_invoice_avg() 
RETURNS decimal as $$
   	BEGIN
		RETURN avg(total) FROM invoice;
	END;
$$ LANGUAGE plpgsql;

-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION get_track_max_price() 
RETURNS decimal as $$
	BEGIN
		RETURN max(unitprice) FROM track;
	END;
$$ LANGUAGE plpgsql;

-- 3.3 User Defined 
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION get_invoiceline_price_avg() 
RETURNS decimal as $$
	BEGIN
		RETURN avg(unitprice) FROM invoiceline;
	END;	
$$ LANGUAGE plpgsql;

-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION get_employees_dob_after_1968() 
RETURNS TABLE(employeeid integer, lastname VARCHAR(20), firstname VARCHAR(20),
			  title VARCHAR(20), reportsto integer, birthdate timestamp,
			  hiredate timestamp, address VARCHAR(20), city VARCHAR(20), state VARCHAR(20),
			  country VARCHAR(20), postalcode VARCHAR(20), phone VARCHAR(20), 
			  fax VARCHAR(20), email VARCHAR(20)) as $$
	BEGIN
		RETURN QUERY 
		SELECT * FROM employee
		WHERE employee.birthdate > '1968-01-01'::date;
	END;
$$ LANGUAGE plpgsql;

-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION get_employees_first_and_last_name()
RETURNS TABLE(firstname VARCHAR(20), lastname VARCHAR(20)) as $$
	BEGIN
		RETURN QUERY
		SELECT employee.firstname, employee.lastname FROM employee;
	END;
$$ LANGUAGE plpgsql;

-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION update_employee(
    employeeid  INTEGER,
    lastname  	VARCHAR,
    firstname   VARCHAR,
    title  		VARCHAR,
    reportsto   INTEGER, 
    birthdate 	timestamp,
  	hiredate 	timestamp, 
  	address 	VARCHAR(20), 
  	city 		VARCHAR(20), 
  	state 		VARCHAR(20),
	country 	VARCHAR(20), 
	postalcode 	VARCHAR(20), 
	phone 		VARCHAR(20), 
	fax 		VARCHAR(20), 
	email 		VARCHAR(20)
	) 
	RETURNS BOOLEAN SECURITY DEFINER AS $$
	BEGIN
	    UPDATE employee
	       	SET title      		= COALESCE(update_employee.title, employee.title),
	       		reportsto      	= COALESCE(update_employee.reportsto, employee.reportsto),
	       		hiredate      	= COALESCE(update_employee.hiredate, employee.hiredate),
	       		address      	= COALESCE(update_employee.address, employee.address),
	       		city      		= COALESCE(update_employee.city, employee.city),
	       		state      		= COALESCE(update_employee.state, employee.state),
	       		country      	= COALESCE(update_employee.country, employee.country),
	       		postalcode      = COALESCE(update_employee.postalcode, employee.postalcode),
	       		phone      		= COALESCE(update_employee.phone, employee.phone),
	       		fax      		= COALESCE(update_employee.fax, employee.fax),
	       		email      		= COALESCE(update_employee.email, employee.email) 
			WHERE 	employee.employeeid = update_employee.employeeid;
	    RETURN FOUND;
	END;
$$ LANGUAGE plpgsql;

-- Task – Create a stored procedure that returns the manager of an employee.
CREATE OR REPLACE FUNCTION get_manager_of_employee(id INTEGER)
RETURNS TABLE(employeeid integer, lastname VARCHAR(20), firstname VARCHAR(20),
			  title VARCHAR(20), reportsto integer, birthdate timestamp,
			  hiredate timestamp, address VARCHAR(20), city VARCHAR(20), state VARCHAR(20),
			  country VARCHAR(20), postalcode VARCHAR(20), phone VARCHAR(20), 
			  fax VARCHAR(20), email VARCHAR(20)) as $$
	BEGIN
		RETURN QUERY
		SELECT * FROM employee
		WHERE employee.employeeid IN (
			SELECT employee.reportsto FROM employee 
			WHERE employee.employeeid = get_manager_of_employee.id
		);
	END;
$$ LANGUAGE plpgsql;

-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION get_customer_name_and_company(id  INTEGER)
RETURNS TABLE(firstname VARCHAR(20), lastname VARCHAR(20), company VARCHAR(20)) as $$
	BEGIN
		RETURN QUERY
		SELECT customer.firstname, customer.lastname, customer.company FROM customer
		WHERE customer.customerid =  get_customer_name_and_company.id;
	END;
$$ LANGUAGE plpgsql;

-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
CREATE OR REPLACE FUNCTION delete_invoice(invoiceid  INTEGER)
	RETURNS BOOLEAN SECURITY DEFINER AS $$
	BEGIN 
		DELETE FROM invoiceline
		WHERE invoiceline.invoiceid = delete_invoice.invoiceid;
		DELETE FROM invoice
		WHERE invoice.invoiceid = delete_invoice.invoiceid;
		RETURN FOUND;
	END;
$$ LANGUAGE plpgsql;

-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION insert_customer(
	customerid  INTEGER,
    firstname   VARCHAR,
    lastname  	VARCHAR,
    company  	VARCHAR,
  	address 	VARCHAR, 
  	city 		VARCHAR, 
  	state 		VARCHAR,
	country 	VARCHAR, 
	postalcode 	VARCHAR, 
	phone 		VARCHAR, 
	fax 		VARCHAR, 
	email 		VARCHAR,
	email 		INTEGER
	) 
	RETURNS BOOLEAN SECURITY DEFINER AS $$
	BEGIN 
		DELETE FROM invoiceline
		WHERE invoiceline.invoiceid = delete_invoice.invoiceid;
		DELETE FROM invoice
		WHERE invoice.invoiceid = delete_invoice.invoiceid;
		RETURN FOUND;
	END;
$$ LANGUAGE plpgsql;

-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR

-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE OR REPLACE FUNCTION say_hello()
  RETURNS trigger AS $$
BEGIN
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_on_employee_insert
AFTER INSERT
ON employee
FOR EACH ROW
EXECUTE PROCEDURE say_hello();

-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE OR REPLACE FUNCTION say_hello()
  RETURNS trigger AS $$
BEGIN
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_on_employee_insert
AFTER UPDATE
ON album
FOR EACH ROW
EXECUTE PROCEDURE say_hello();

-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE TRIGGER trigger_on_customer_delete
AFTER DELETE
ON customer
FOR EACH ROW
EXECUTE PROCEDURE say_hello();

-- 6.2 Before
-- Task – Create a before trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE OR REPLACE FUNCTION prevent_invoice_over_50()
  RETURNS trigger AS $$
BEGIN
	IF (NEW.total > 50) THEN
      RAISE EXCEPTION 'The invoice is over 50';
   	END IF;
   	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_on_invoice_over_50_insert
BEFORE INSERT
ON invoice
FOR EACH ROW
EXECUTE PROCEDURE prevent_invoice_over_50();

-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.

-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT customer.firstname, customer.lastname, invoice.invoiceid FROM customer
INNER JOIN invoice 
ON customer.customerid = invoice.customerid;

-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
	SELECT customer.customerid, customer.firstname, customer.lastname, invoice.invoiceid, invoice.total
	FROM customer
	FULL OUTER JOIN invoice ON customer.customerid = invoice.customerid;

-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, album.title
FROM artist
RIGHT JOIN album ON artist.artistid = album.artistid;

-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT *
FROM album 
CROSS JOIN artist
ORDER BY artist.name ASC;

-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT *
FROM employee A
INNER JOIN employee B ON A.reportsto = B.employeeid;