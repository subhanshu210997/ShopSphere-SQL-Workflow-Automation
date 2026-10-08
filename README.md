# ShopSphere SQL Workflow Automation

## Project Overview

ShopSphere SQL Workflow Automation is an SQL-based e-commerce order and payment workflow project developed using Microsoft SQL Server.

The project analyzes customer orders, order items, products, and payment information to calculate order values, validate payments, identify exceptions, and generate automated workflow statuses.

## Objective

The main objective of this project is to build a SQL-based workflow that can:

- Connect orders with payment records
- Calculate gross and net order values
- Apply product-level discounts
- Validate payment status and payment amounts
- Identify payment issues and exceptions
- Generate automated order workflow statuses
- Create reusable SQL views
- Generate order and customer summaries
- Perform data validation
- Prepare the workflow for scheduled automation

## Database Structure

The project uses the following tables:

| Table | Purpose |
|---|---|
| Customers | Stores customer information |
| Products | Stores product and pricing information |
| Orders | Stores customer order information |
| Order_Items | Stores products and quantities within orders |
| Payments | Stores payment information |

## Workflow

The project follows a 13-step SQL workflow:

1. Identify Order & Payment Status
2. Connect Orders with Payments
3. Calculate Gross Order Value
4. Apply Product Discount
5. Validate Payment
6. Generate Automated Workflow Status
7. Create Reusable SQL View
8. Generate Order Status Summary
9. Customer Order Analysis
10. Automated Exception Check
11. Final Workflow Summary
12. Final Data Validation
13. SQL Server Agent Automation Preparation

## Key SQL Concepts Used

The project demonstrates practical use of:

- SELECT
- DISTINCT
- INNER JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- ORDER BY
- Aggregate Functions
- SUM()
- COUNT()
- AVG()
- ROUND()
- CASE statements
- Conditional logic
- Data validation
- SQL Views
- Stored Procedures
- Exception checking
- SQL Server Agent workflow automation

## Key Calculations

### Gross Order Value

Gross order value is calculated before applying discounts:

`Quantity × Product Price`

### Net Order Value

Net order value is calculated after applying the product discount:

`Quantity × Product Price × (1 − Discount)`

### Payment Difference

The project compares the calculated net order value with the recorded payment amount:

`Net Order Value − Payment Amount`

## Workflow Status Logic

The workflow generates statuses based on order and payment conditions.

Examples include:

- Completed
- In Transit
- Processing
- Payment Issue
- Cancelled
- Review Required

## Payment Validation

The workflow checks whether:

- The payment status is Paid
- The payment amount matches the calculated order value
- A payment record exists
- A payment issue or mismatch needs attention

## Exception Detection

The workflow identifies records requiring further investigation, including:

- Payment issues
- Amount mismatches
- Missing payment records
- Review-required orders
- Duplicate order checks

## Automation

The workflow is structured for SQL Server automation using reusable SQL objects such as views and stored procedures.

The final workflow can be executed through SQL Server Agent on a scheduled basis.

## Tools Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Agent
- SQL

## Project Files

### SQL Workflow Script

The complete consolidated SQL workflow is available here:

`ShopSphere_Workflow_Automation_13_Steps.sql`

The SQL file contains the queries covering the complete 13-step workflow.

## Skills Demonstrated

This project demonstrates practical SQL skills in:

**Data Analysis | Joins | Aggregation | Conditional Logic | Payment Validation | Data Quality Checks | SQL Views | Stored Procedures | Workflow Automation**

---

### Author

**Subhanshu Kumar**

GitHub: [Your GitHub Profile]
