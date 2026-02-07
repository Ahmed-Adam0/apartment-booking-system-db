--Group 2: Customer & Booking Business Logic
--Focus: Stored Procedures, Functions, Subqueries, Error Handling
--1 Stored procedure to retrieve customer booking history with input/output parameters and
--TRY-CATCH.
CREATE OR ALTER PROCEDURE sp_customer_booking_history
(
    @customer_id INT,
    @booking_count INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Output value
        SELECT @booking_count = COUNT(*)
        FROM bookings
        WHERE user_id = @customer_id;

        -- Result set
        SELECT 
            b.id AS booking_number,
            r.type AS booked_unit_type,
            b.createdate AS booked_At,
            p.status,
            p.amount AS paid_amount
        FROM bookings b
        INNER JOIN rentable_units r
            ON r.id = b.unit_id
        LEFT JOIN payments p
            ON p.booking_id = b.id
        WHERE b.user_id = @customer_id
        ORDER BY b.createdate;
    END TRY

    BEGIN CATCH
        SET @booking_count = 0;

        PRINT 'Error while retrieving booking history';
        PRINT ERROR_MESSAGE();
    END CATCH
END
--calling
        
DECLARE @bookingco INT;
 exec sp_customer_booking_history @customer_id=3,@booking_count=@bookingco output
  select @bookingco as 'Total Bookings for Customer ';

--2 Scalar function to calculate total customer spending
create or alter function fn_total_customer_spending
(
    @customer_id INT
)
returns decimal(10,2)
as
begin
    declare @total_spending decimal(10,2);
    select @total_spending = sum(p.amount)
    from bookings b
    inner join payments p
        on p.booking_id = b.id
    where b.user_id = @customer_id
        and p.status = 'paid';
    return isnull(@total_spending, 0);
end

SELECT dbo.fn_total_customer_spending(3) AS TotalSpending;

--3 Inline table-valued function to identify active and inactive customers.
create or alter function fn_active_inactive_customers
(
      @customer_id INT
)
returns table
as 
return
(
select u.id as customer_number,u.fname,
case 
when exists(
select 1
from bookings b 
where u.id =b.user_id
)then 'active'
else 'inactive'
end as status
from users u
where @customer_id=u.id
);

SELECT * 
FROM dbo.fn_active_inactive_customers(3);

--4 Stored procedure to analyze cancelled bookings with return values.
create or alter procedure sp_cancelled_bookings
(@customer_id int,@cancelledCount INT output)
as
begin
    SET NOCOUNT ON;
select @cancelledCount=count(b.user_id)
from bookings b
where b.user_id=@customer_id and b.status='cancelled'
if (@cancelledCount>0)
return 1
else
return 0
end
--calling
DECLARE @count INT;
DECLARE @status INT;

EXEC @status = sp_cancelled_bookings
    @customer_id = 3,
    @cancelledCount = @count OUTPUT;

SELECT @count AS CancelledBookingsCount,
       @status AS ReturnStatus;

--5 Correlated and non-correlated subqueries for customer insights.

--last activity Correlated Subquery for renter

DECLARE @customer_id INT = 3;
select top 1
    b.id AS BookingID,
    b.createdate AS LastBookingDate,
    r.type AS UnitType,
    p.status AS PaymentStatus
from bookings b 
inner join rentable_units r
on r.id=b.unit_id
left join
payments p
on p.booking_id=b.id
where b.user_id=@customer_id
order by b.createdate desc

--Total spending Non-Correlated Subquery for renter   
DECLARE @customer_id INT = 3;

SELECT u.id, u.fname,
    (
        SELECT ISNULL(SUM(p.amount),0)
        FROM bookings b
        INNER JOIN payments p
        ON p.booking_id = b.id
        WHERE b.user_id = @customer_id AND p.status = 'paid'  ) AS TotalSpending
        FROM users u
WHERE u.id = @customer_id;


