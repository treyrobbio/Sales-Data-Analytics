-- Sales and Revenue Analysis --

	-- Top 10 Customers (total sales)
    SELECT Customer_Name, SUM(Sales) AS total_money_spent
    FROM superstore_data
    GROUP BY Customer_Name
    ORDER BY total_money_spent DESC
    LIMIT 10
    ;
    
    -- Total Sales and Profit by Region
    SELECT Region, SUM(Sales) as total_sales, SUM(Profit) as total_profit
    FROM superstore_data
    GROUP BY Region
    ORDER BY total_sales DESC
    ;

	-- Monthly Sales Trends
	SELECT 
		DATE_FORMAT(Order_Date, '%Y-%m') AS 'year_month',
		SUM(Sales) AS total_sales
	FROM superstore_data
	GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
	ORDER BY DATE_FORMAT(Order_Date, '%Y-%m') ASC;


    
    -- Profit Margin for Each Product Category
	SELECT Category, Sub_Category, 
		ROUND((SUM(Profit) / SUM(Sales)), 2) * 100 AS profit_margin
	FROM superstore_data
	GROUP BY Category, Sub_Category
	ORDER BY profit_margin DESC;
    
    
    -- Total Sales/Profit by State
	SELECT 
		State,
		SUM(Sales) AS total_sales,
		SUM(Profit) AS total_profit
	FROM superstore_data
	GROUP BY State
	ORDER BY total_sales DESC;

    -- Top 5 Products (quantity sold)
	SELECT 
		Product_Name,
		SUM(Quantity) AS total_quantity_sold
	FROM superstore_data
	GROUP BY Product_Name
	ORDER BY total_quantity_sold DESC
	LIMIT 5;
    
    -- Products with Negative Profit
	SELECT 
		Product_Name,
		Category,
		Sub_Category,
		SUM(Profit) AS total_profit,
		SUM(Sales) AS total_sales
	FROM superstore_data
	GROUP BY Product_Name, Category, Sub_Category
	HAVING total_profit < 0
	ORDER BY total_profit ASC;
    
    -- Average Discount per Sub_Category
	SELECT 
		Category,
		Sub_Category,
		ROUND(AVG(Discount), 3) * 100 AS avg_discount
	FROM superstore_data
	GROUP BY Category, Sub_Category
	ORDER BY avg_discount DESC;

	-- Average Shipping Time by Shipping Mode
	SELECT 
		Ship_Mode,
		ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS avg_shipping_days
	FROM superstore_data
	GROUP BY Ship_Mode
	ORDER BY avg_shipping_days ASC;
    
    -- Count of Orders That Shipped Later Than the Average Shipping Time in Their Region
    SELECT 
    Region,
    COUNT(*) AS late_orders
	FROM (
		SELECT 
			Region,
			DATEDIFF(Ship_Date, Order_Date) AS ship_time,
			AVG(DATEDIFF(Ship_Date, Order_Date)) 
				OVER (PARTITION BY Region) AS avg_region_ship_time
		FROM superstore_data
	) t
	WHERE ship_time > avg_region_ship_time
	GROUP BY Region
	ORDER BY late_orders DESC;
    
    -- Total Sales and Profit by Customer Segment
	SELECT 
		Segment,
		ROUND(SUM(Sales), 2) AS total_sales,
		ROUND(SUM(Profit), 2) AS total_profit
	FROM superstore_data
	GROUP BY Segment
	ORDER BY total_sales DESC;


	-- Shipping Results for each Order
	WITH ship_times AS (
		SELECT
			Order_ID,
			DATEDIFF(Ship_Date, Order_Date) AS ship_days, ship_mode, Order_Date
		FROM superstore_data
	),

	avg_ship AS (
		SELECT AVG(ship_days) AS avg_ship_days
		FROM ship_times
	),
    
	results AS (
		SELECT 
			s.Order_ID,
			s.ship_days,
			a.avg_ship_days,
			s.Order_Date,
			s.ship_mode,
			CASE 
				WHEN s.ship_days > a.avg_ship_days THEN 'Late'
				ELSE 'On Time'
			END AS shipping_status
		FROM ship_times s
		CROSS JOIN avg_ship a
		ORDER BY s.ship_days DESC
			
	),
    
    total_late_orders AS (
    SELECT COUNT(DISTINCT(Order_ID)) AS total
    FROM results
    WHERE results.shipping_status = 'Late'
	)
    
		SELECT 
			r.Order_ID,
			r.ship_days,
			r.avg_ship_days,
			r.Order_Date,
			r.ship_mode,
            t.total,
			r.shipping_status
		FROM results r, total_late_orders t
		ORDER BY r.ship_days DESC;


SELECT
	AVG(Profit / Sales) * 100 AS Avg_Profit_Margin
FROM superstore_data
;
    