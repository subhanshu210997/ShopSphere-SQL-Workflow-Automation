/*
============================================================
ShopSphere Workflow Automation
13-Step SQL Project
============================================================
IMPORTANT:
Steps 1-6 are based on the recovered SQLQuery1-6 file.
Steps 7-13 are reconstructed from the documented workflow
and are clearly marked as reconstructed.
============================================================
*/

USE ShopSphere_Analysis;
GO

/* =========================================================
STEP 1 - Identify Order & Payment Status
========================================================= */

SELECT DISTINCT order_status
FROM Orders;

SELECT DISTINCT payment_status
FROM Payments;
GO


/* =========================================================
STEP 2 - Connect Orders with Payments
========================================================= */

SELECT
    o.order_id,
    o.order_status,
    p.payment_status,
    p.payment_amount
FROM Orders o
LEFT JOIN Payments p
    ON o.order_id = p.order_id;
GO


/* =========================================================
STEP 3 - Calculate Gross Order Value
========================================================= */

SELECT
    oi.order_id,
    SUM(oi.quantity * p.price) AS gross_order_value
FROM Order_Items oi
JOIN Products p
    ON oi.product_id = p.product_id
GROUP BY oi.order_id;
GO


/* =========================================================
STEP 4 - Apply Product Discount
========================================================= */

SELECT
    oi.order_id,
    SUM(oi.quantity * p.price) AS gross_order_value,
    SUM(oi.quantity * p.price * (1 - oi.discount)) AS net_order_value
FROM Order_Items oi
JOIN Products p
    ON oi.product_id = p.product_id
GROUP BY oi.order_id;
GO


/* =========================================================
STEP 5 - Validate Payment
========================================================= */

SELECT
    o.order_id,

    SUM(
        oi.quantity * p.price * (1 - oi.discount)
    ) AS net_order_value,

    py.payment_amount,
    py.payment_status,

    CASE
        WHEN py.payment_status = 'Paid'
             AND py.payment_amount =
                 SUM(oi.quantity * p.price * (1 - oi.discount))
            THEN 'Payment Verified'

        WHEN py.payment_status = 'Paid'
             AND py.payment_amount <>
                 SUM(oi.quantity * p.price * (1 - oi.discount))
            THEN 'Amount Mismatch'

        WHEN py.payment_status <> 'Paid'
            THEN 'Payment Issue'

        ELSE 'Pending Review'
    END AS payment_validation

FROM Orders o
JOIN Order_Items oi
    ON o.order_id = oi.order_id
JOIN Products p
    ON oi.product_id = p.product_id
LEFT JOIN Payments py
    ON o.order_id = py.order_id

GROUP BY
    o.order_id,
    py.payment_amount,
    py.payment_status;
GO


/* =========================================================
STEP 6 - Generate Automated Workflow Status
========================================================= */

SELECT
    o.order_id,
    o.order_status,
    py.payment_status,
    py.payment_amount,

    ROUND(
        SUM(
            oi.quantity * p.price * (1 - oi.discount)
        ), 2
    ) AS net_order_value,

    ROUND(
        SUM(
            oi.quantity * p.price * (1 - oi.discount)
        ) - py.payment_amount,
        2
    ) AS payment_difference,

    CASE
        WHEN o.order_status = 'Cancelled'
            THEN 'Cancelled'

        WHEN py.payment_status IS NULL
            THEN 'Payment Issue'

        WHEN py.payment_status <> 'Paid'
            THEN 'Payment Issue'

        WHEN o.order_status = 'Delivered'
             AND py.payment_status = 'Paid'
            THEN 'Completed'

        WHEN o.order_status = 'Shipped'
             AND py.payment_status = 'Paid'
            THEN 'In Transit'

        WHEN o.order_status = 'Pending'
             AND py.payment_status = 'Paid'
            THEN 'Processing'

        ELSE 'Review Required'
    END AS workflow_status

FROM Orders o
JOIN Order_Items oi
    ON o.order_id = oi.order_id
JOIN Products p
    ON oi.product_id = p.product_id
LEFT JOIN Payments py
    ON o.order_id = py.order_id

GROUP BY
    o.order_id,
    o.order_status,
    py.payment_status,
    py.payment_amount;
GO


/* =========================================================
STEP 7 - Create Reusable SQL View
RECONSTRUCTED FROM DOCUMENTED WORKFLOW
========================================================= */

CREATE OR ALTER VIEW vw_ShopSphere_OrderWorkflow
AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,

    py.payment_status,
    py.payment_amount,

    ROUND(
        SUM(
            oi.quantity * p.price * (1 - oi.discount)
        ), 2
    ) AS net_order_value,

    ROUND(
        SUM(
            oi.quantity * p.price * (1 - oi.discount)
        ) - py.payment_amount,
        2
    ) AS payment_difference,

    CASE
        WHEN o.order_status = 'Cancelled'
            THEN 'Cancelled'
        WHEN py.payment_status IS NULL
            THEN 'Payment Issue'
        WHEN py.payment_status <> 'Paid'
            THEN 'Payment Issue'
        WHEN o.order_status = 'Delivered'
             AND py.payment_status = 'Paid'
            THEN 'Completed'
        WHEN o.order_status = 'Shipped'
             AND py.payment_status = 'Paid'
            THEN 'In Transit'
        WHEN o.order_status = 'Pending'
             AND py.payment_status = 'Paid'
            THEN 'Processing'
        ELSE 'Review Required'
    END AS workflow_status

FROM Orders o
JOIN Order_Items oi
    ON o.order_id = oi.order_id
JOIN Products p
    ON oi.product_id = p.product_id
LEFT JOIN Payments py
    ON o.order_id = py.order_id

GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    py.payment_status,
    py.payment_amount;
GO

SELECT *
FROM vw_ShopSphere_OrderWorkflow;
GO


/* =========================================================
STEP 8 - Generate Order Status Summary
RECONSTRUCTED
========================================================= */

SELECT
    workflow_status,
    COUNT(*) AS total_orders
FROM vw_ShopSphere_OrderWorkflow
GROUP BY workflow_status
ORDER BY total_orders DESC;
GO


/* =========================================================
STEP 9 - Customer Order Analysis
RECONSTRUCTED
========================================================= */

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(v.net_order_value), 2
    ) AS total_order_value,

    ROUND(
        AVG(v.net_order_value), 2
    ) AS average_order_value

FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN vw_ShopSphere_OrderWorkflow v
    ON o.order_id = v.order_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.city,
    c.state

ORDER BY total_order_value DESC;
GO


/* =========================================================
STEP 10 - Automated Exception Check
RECONSTRUCTED
========================================================= */

SELECT *
FROM vw_ShopSphere_OrderWorkflow
WHERE workflow_status IN
(
    'Payment Issue',
    'Review Required',
    'Amount Mismatch'
);
GO

SELECT
    order_id,
    net_order_value,
    payment_amount,
    payment_difference,
    workflow_status
FROM vw_ShopSphere_OrderWorkflow
WHERE ABS(payment_difference) > 0.01;
GO


/* =========================================================
STEP 11 - Final Workflow Summary
RECONSTRUCTED
========================================================= */

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN workflow_status = 'Completed'
            THEN 1 ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN workflow_status = 'Payment Issue'
            THEN 1 ELSE 0
        END
    ) AS payment_issues,

    SUM(
        CASE
            WHEN workflow_status = 'Review Required'
            THEN 1 ELSE 0
        END
    ) AS review_required,

    SUM(
        CASE
            WHEN workflow_status = 'Cancelled'
            THEN 1 ELSE 0
        END
    ) AS cancelled_orders

FROM vw_ShopSphere_OrderWorkflow;
GO


/* =========================================================
STEP 12 - Final Data Validation
RECONSTRUCTED
========================================================= */

SELECT
    COUNT(*) AS total_records
FROM vw_ShopSphere_OrderWorkflow;
GO

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM vw_ShopSphere_OrderWorkflow
GROUP BY order_id
HAVING COUNT(*) > 1;
GO

SELECT
    COUNT(*) AS completed_orders
FROM vw_ShopSphere_OrderWorkflow
WHERE workflow_status = 'Completed';
GO

SELECT
    COUNT(*) AS exception_count
FROM vw_ShopSphere_OrderWorkflow
WHERE workflow_status IN
(
    'Payment Issue',
    'Review Required',
    'Amount Mismatch'
);
GO


/* =========================================================
STEP 13 - SQL Server Agent Automation Preparation
RECONSTRUCTED
========================================================= */

CREATE OR ALTER PROCEDURE sp_ShopSphere_DailyWorkflow
AS
BEGIN

    SELECT
        workflow_status,
        COUNT(*) AS total_orders
    FROM vw_ShopSphere_OrderWorkflow
    GROUP BY workflow_status
    ORDER BY total_orders DESC;

    SELECT *
    FROM vw_ShopSphere_OrderWorkflow
    WHERE workflow_status IN
    (
        'Payment Issue',
        'Review Required',
        'Amount Mismatch'
    );

    SELECT
        order_id,
        COUNT(*) AS duplicate_count
    FROM vw_ShopSphere_OrderWorkflow
    GROUP BY order_id
    HAVING COUNT(*) > 1;

END;
GO

EXEC sp_ShopSphere_DailyWorkflow;
GO

/*
After creating the procedure, configure SQL Server Agent
to execute:

EXEC sp_ShopSphere_DailyWorkflow;

on the required schedule.
*/
