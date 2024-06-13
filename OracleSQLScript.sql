-- Object Relational Database Script 
DROP TABLE coffee_sale;
DROP TYPE CoffeeSaleType;
DROP SEQUENCE coffee_sale_no_seq;
DROP TABLE coffee;
DROP TYPE CoffeeType; 
DROP TABLE barista;
DROP TYPE ManagerType;
DROP TYPE BaristaType; 
DROP TABLE cafe; 
DROP TYPE CafeType; 
DROP TYPE AddressType; 

CREATE TYPE AddressType as Object(
	street VARCHAR2(30), 
	town VARCHAR2(20), 
	postcode VARCHAR2(8)
);
/

CREATE TYPE CafeType as OBJECT(
	cafe_name VARCHAR2(20),
	address AddressType
);
/

CREATE TABLE cafe OF CafeType
(
	cafe_name PRIMARY KEY
);
/

CREATE TYPE BaristaType as OBJECT(
	barista_id NUMBER(4),
	barista_surname VARCHAR2(20), 
	barista_forname VARCHAR2(20), 
	dob DATE,
	salary NUMBER(6), 
	address AddressType, 
	cafe REF CafeType,
	length_of_service INTERVAL YEAR TO MONTH,
	MEMBER FUNCTION get_fullname RETURN VARCHAR2, 
	MEMBER FUNCTION calc_age RETURN NUMBER
)NOT FINAL;
/

-- function to calculate age based on DOB 
CREATE OR REPLACE TYPE BODY BaristaType AS 
	MEMBER FUNCTION calc_age RETURN NUMBER IS 
	BEGIN 
		RETURN MONTHS_BETWEEN(SYSDATE, dob)/12;
	END;
	MEMBER FUNCTION get_fullname RETURN VARCHAR2 IS  
	BEGIN 
		RETURN barista_forname||' '||barista_surname;
	END;
END; 
/

CREATE TYPE ManagerType UNDER BaristaType(
	annual_bonus NUMBER(4), 
	MEMBER FUNCTION calc_annual_salary RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY ManagerType AS 
	MEMBER FUNCTION calc_annual_salary RETURN NUMBER IS 
	BEGIN 
		RETURN salary + annual_bonus; 
	END; 
END;
/

CREATE TABLE barista OF BaristaType
(
	barista_id PRIMARY KEY
);
/


CREATE TYPE CoffeeType as OBJECT(
	coffee_name VARCHAR2(15),
	price NUMBER(3, 1)
);
/

CREATE TABLE coffee OF CoffeeType
(
	coffee_name PRIMARY KEY
);
/

--sequence to auto increment coffee sales id 
CREATE SEQUENCE coffee_sale_no_seq START WITH 1; 

CREATE TYPE CoffeeSaleType as OBJECT(
	coffee_sale_no NUMBER(6), 
	barista REF BaristaType,
	coffee REF CoffeeType,
	sale_date DATE
);
/

CREATE TABLE coffee_sale OF CoffeeSaleType
(
	coffee_sale_no PRIMARY KEY
);
/

--create trigger to auto increment when new sale is made and check 
-- valid date has been given 
CREATE OR REPLACE TRIGGER coffee_sale_trigger
	BEFORE INSERT ON coffee_sale 
	FOR EACH ROW 
DECLARE	
	invalid_entry EXCEPTION;
BEGIN 
	IF :new.sale_date > SYSDATE THEN
		RAISE
			invalid_entry;
	END IF;
	SELECT coffee_sale_no_seq.NEXTVAL
		INTO :new.coffee_sale_no
		FROM dual; 
EXCEPTION
	WHEN invalid_entry THEN 
		RAISE_APPLICATION_ERROR(-20001, 'Sale date cannot be after today''s date');
END;
/ 

	

INSERT INTO cafe VALUES('Cool Coffee', 
	AddressType('305, West Road', 'Whitley Bay', 'NE26 4XX'));
INSERT INTO cafe VALUES('Johns Brew Co', 
	AddressType('12 Loft Road', 'Sunderland', 'SS22 7TG'));
INSERT INTO cafe VALUES('Brewed Beanz', 
	AddressType('77 Tipton Lane', 'Whitley Bay', 'NE26 9TH'));
INSERT INTO cafe VALUES('Espresso Lounge', 
	AddressType('5 Grainger Road', 'Durham', 'DD4 7TG'));
	
INSERT INTO barista VALUES(1, 'Smith', 'Fred', '01-JAN-1980', 20000, 
	AddressType('1 Fleetwood Road', 'Durham', 'DH5 9ZZ'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Espresso Lounge'), 
	INTERVAL '2-5' YEAR to MONTH);
	
INSERT INTO barista VALUES(2, 'Johnson', 'Justin', '01-JAN-1999', 18000, 
	AddressType('6 Loft Road', 'Sunderland', 'SS22 7TG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Johns Brew Co'), 
	INTERVAL '1-8' YEAR to MONTH);
	
INSERT INTO barista VALUES(3, 'Taylor', 'Martin', '16-JUN-2000', 10000, 
	AddressType('4 Tipley Road', 'Durham', 'DH5 7HH'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Espresso Lounge'), 
	INTERVAL '2-3' YEAR to MONTH);
	
INSERT INTO barista VALUES(4, 'Hudley', 'Janet', '20-MAY-1987', 20000, 
	AddressType('6 Just Lane', 'Sunderland', 'SS6 9UG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Johns Brew Co'), 
	INTERVAL '5-9' YEAR to MONTH);	
	
INSERT INTO barista VALUES(5, 'Broman', 'Fred', '16-JUL-1967', 20000, 
	AddressType('99 Helper Road', 'Durham', 'DH4 3HU'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Espresso Lounge'), 
	INTERVAL '9' MONTH);
	
INSERT INTO barista VALUES(6, 'Godley', 'Sarah', '01-NOV-1999', 18000, 
	AddressType('7 Regent Road', 'Whitley Bay', 'NE25 7TG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Cool Coffee'), 
	INTERVAL '3' MONTH);
	
INSERT INTO barista VALUES(7, 'Smith', 'Hannah', '16-JAN-1985', 20000, 
	AddressType('1 Fleetwood Road', 'Durham', 'DH5 9ZZ'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Espresso Lounge'), 
	INTERVAL '6' YEAR);	
	
INSERT INTO barista VALUES(8, 'Galaway', 'Garry', '01-MAY-2003', 18000, 
	AddressType('78 Gill Road', 'Whitley Bay', 'NE25 6HG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Brewed Beanz'), 
	INTERVAL '1-1' YEAR to MONTH);
	
INSERT INTO barista VALUES(ManagerType(9, 'Goulding', 'Robert', '01-APR-1977', 24000, 
	AddressType('86 Just Way', 'Whitley Bay', 'NE25 4AG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Brewed Beanz'), 
	INTERVAL '9-5' YEAR to MONTH, 3000));	
	
INSERT INTO barista VALUES(ManagerType(10, 'Crank', 'David', '01-JUN-1979', 24000, 
	AddressType('101 Gibson Way', 'Sunderland', 'SS2 4YG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Johns Brew Co'),
	INTERVAL '9' MONTH, 5000));	
	
INSERT INTO barista VALUES(ManagerType(11, 'Davison', 'Robert', '01-APR-1977', 24000, 
	AddressType('86 Just Way', 'Whitley Bay', 'NE25 4AG'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Cool Coffee'), 
	INTERVAL '2-2' YEAR to MONTH, 3000));
	
INSERT INTO barista VALUES(ManagerType(12, 'Goldberg', 'Jason', '16-APR-1998', 24000, 
	AddressType('221 Saville Street', 'Durham', 'DD65 4TV'), 
	(SELECT ref(c) FROM cafe c WHERE c.cafe_name = 'Espresso Lounge'), 
	INTERVAL '1-5' YEAR to MONTH, 2000));
INSERT INTO coffee VALUES('V60', 4);
INSERT INTO coffee VALUES('Espresso', 2);
INSERT INTO coffee VALUES('Latte', 3.5);
INSERT INTO coffee VALUES('Americano', 3);
INSERT INTO coffee VALUES('Flat White', 3.5);
INSERT INTO coffee VALUES('Cappuccino', 3.5);
INSERT INTO coffee VALUES('Cortado', 3);
INSERT INTO coffee VALUES('Iced Latte', 3.5);
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 1), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'V60'), 
	to_date('06-MAY-2024:10:30', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 2), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Latte'), 
	to_date('06-MAY-2024:09:55', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 3), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Flat White'), 
	to_date('06-MAY-2024:11:30', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 5), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'V60'), 
	to_date('07-MAY-2024:08:30', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 6), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Espresso'), 
	to_date('07-MAY-2024:08:35', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 8), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'V60'), 
	to_date('07-MAY-2024:08:40', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 1), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Cappuccino'), 
	to_date('07-MAY-2024:09:20', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 2), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Iced Latte'), 
	to_date('07-MAY-2024:09:15', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 2), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Iced Latte'), 
	to_date('08-MAY-2024:09:15', 'dd-mon-yyyy:HH24:MI')); 
INSERT INTO coffee_sale VALUES(NULL,
	(SELECT ref(b) FROM barista b WHERE b.barista_id = 2), 
	(SELECT ref(c) FROM coffee c WHERE c.coffee_name = 'Iced Latte'), 
	to_date('09-MAY-2024:09:30', 'dd-mon-yyyy:HH24:MI')); 
	
-- to show insert query have been successful 
SELECT * FROM barista;

SELECT * FROM cafe;

SELECT * FROM coffee; 

SELECT * FROM coffee_sale; 


--Oracle Queries 

-- QUERY A
-- query to show barista's name, the cafe name and address they work in and 
-- the number of sales they have made. Barista with most sales appears at the top.
-- only shows baristas which do not live in Durham  
SELECT b.get_fullname() AS name, b.address.town AS town, c.cafe_name, COUNT(s.coffee_sale_no) AS sales
FROM barista b
INNER JOIN cafe c 
ON b.cafe.cafe_name = c.cafe_name
LEFT JOIN coffee_sale s 
ON s.barista.barista_id = b.barista_id
WHERE NOT b.address.town = 'Durham'
GROUP BY b.get_fullname(), c.cafe_name, b.address.town
ORDER BY sales DESC; 

-- QUERY B
-- query to show all streets which baristas and cafes 
-- are located in whitley bay 
SELECT b.address.street
FROM barista b
WHERE b.address.town = 'Whitley Bay'
UNION 
SELECT c.address.street
FROM cafe c 
WHERE c.address.town = 'Whitley Bay'
; 

-- QUERY C 
-- view annual bonuses for Managers, displaying highest bonus at the top 
SELECT barista_id, TREAT(VALUE(b) AS ManagerType).annual_bonus bonus
FROM barista b
WHERE VALUE(b) IS OF (ManagerType)
ORDER BY bonus DESC; 

-- QUERY D 
-- Query to show the month and year each barista started their role for baristas which 
-- have been in their role longer than a year 
SELECT barista_id, LTRIM(to_char(CURRENT_DATE - length_of_service, 'MON-YYYY'), '0') AS start_date
FROM barista
WHERE barista_id in
(SELECT barista_id 
FROM barista 
WHERE length_of_service > INTERVAL '1' YEAR)
ORDER BY CURRENT_DATE - length_of_service ASC;

-- QUERY E 
-- for each barista, the different coffees sold with the number of 
-- each type of coffee sold and overall number of coffees sold by each 
-- barista and total number of sales by all baristas 
SELECT c.barista.barista_id, c.coffee.coffee_name, COUNT(c.coffee_sale_no)
FROM coffee_sale c
GROUP BY ROLLUP(c.barista.barista_id, c.coffee.coffee_name)
ORDER BY c.barista.barista_id; 









