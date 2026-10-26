SHOW TABLES IN workspace.default;
DESCRIBE workspace.default.sizwe_sales_orders;


/* TASK 1 - Channel Performance */

SELECT
    sales_orders.channel,

    SUM(
        CASE
            WHEN sales_orders.order_date <= DATE '2024-06-30'
            THEN sales_lines.line_revenue
            ELSE 0
        END
    ) AS revenue_2024,

    SUM(
        CASE
            WHEN sales_orders.order_date > DATE '2024-06-30'
            THEN sales_lines.line_revenue
            ELSE 0
        END
    ) AS revenue_2025,

    ROUND(
        (
            SUM(
                CASE
                    WHEN sales_orders.order_date > DATE '2024-06-30'
                    THEN sales_lines.line_revenue
                    ELSE 0
                END
            )
            -
            SUM(
                CASE
                    WHEN sales_orders.order_date <= DATE '2024-06-30'
                    THEN sales_lines.line_revenue
                    ELSE 0
                END
            )
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN sales_orders.order_date <= DATE '2024-06-30'
                    THEN sales_lines.line_revenue
                    ELSE 0
                END
            ),
            0
        ) * 100,
        2
    ) AS growth_rate

FROM workspace.default.sizwe_sales_orders AS sales_orders

JOIN workspace.default.sizwe_sales_lines AS sales_lines
    ON sales_orders.order_id = sales_lines.order_id

GROUP BY sales_orders.channel
ORDER BY sales_orders.channel;


/* TASK 2 - Where the profit actually comes from */
SELECT
    products.product_line,
    SUM(sales_lines.line_revenue) AS total_revenue,
    SUM(sales_lines.cogs) AS total_costs,
    SUM(sales_lines.line_revenue) - SUM(sales_lines.cogs) AS gross_profit,
    ROUND(
        (
            SUM(sales_lines.line_revenue) - SUM(sales_lines.cogs)
        ) / NULLIF(SUM(sales_lines.line_revenue), 0) * 100,
        2
    ) AS gross_margin
FROM workspace.default.sizwe_products AS products
JOIN workspace.default.sizwe_sales_lines AS sales_lines
    ON sales_lines.sku = products.sku
GROUP BY products.product_line
ORDER BY gross_profit DESC
/*
House Blend generated the highest gross profit, at approximately R107.15 million. However, Single Origin had the highest gross margin of 44.27%. This shows that even though House Blend brings in the most gross profit, Single Origin makes more profit as a percentage of its revenue.
*/


/* TASK 3 - The collections problem */
SELECT
    customers.channel,

    COUNT(DISTINCT ar_ledger.invoice_no) AS number_of_invoices,

    COUNT(DISTINCT CASE
        WHEN ar_ledger.settlement_date IS NULL
        THEN ar_ledger.invoice_no
    END) AS still_open,

    COUNT(DISTINCT CASE
        WHEN ar_ledger.settlement_date IS NOT NULL
        THEN ar_ledger.invoice_no
    END) AS settled,

    ROUND(
        AVG(
            CASE
                WHEN ar_ledger.settlement_date IS NOT NULL
                THEN DATE_DIFF(
                    DAY,
                    ar_ledger.invoice_date,
                    ar_ledger.settlement_date
                )
            END
        ),
        2
    ) AS average_days_to_settle,

    ROUND(
        SUM(
            COALESCE(ar_ledger.invoice_amount, 0)
            - COALESCE(ar_ledger.amount_settled, 0)
        ),
        2
    ) AS total_outstanding

FROM workspace.default.sizwe_ar_ledger AS ar_ledger

JOIN workspace.default.sizwe_customers AS customers
    ON ar_ledger.customer_id = customers.customer_id

GROUP BY customers.channel

ORDER BY customers.channel;
/*
Subscription has 44 open invoices, with R751,178.89 still outstanding. Its average settlement time is 3.85 days. Wholesale, on the other hand, has 3,454 open invoices and R87,848,227.20 outstanding, with an average settlement time of 68.68 days. I would recommend that Sizwe Coffee focuses on Wholesale first because it has a much higher outstanding balance and takes longer to receive payments. The business could follow up with customers who still owe money to improve collections.
*/


/* TASK 4 - The ten accounts that matter most */
SELECT
    customers.trading_name,
    customers.segment,
    customers.province,ancial_year;
    reps.rep_name,
    SUM(sales_lines.line_revenue) AS fy2025_revenue
FROM workspace.default.sizwe_customers AS customers
JOIN workspace.default.sizwe_sales_orders AS sales_orders
    ON customers.customer_id = sales_orders.customer_id
JOIN workspace.default.sizwe_sales_lines AS sales_lines
    ON sales_orders.order_id = sales_lines.order_id
LEFT JOIN workspace.default.sizwe_reps AS reps
    ON sales_orders.rep_id = reps.rep_id
WHERE sales_orders.order_date > DATE '2024-06-30'
  AND sales_orders.order_date <= DATE '2025-06-30'
GROUP BY
    customers.trading_name,
    customers.segment,
    customers.province,
    reps.rep_name
ORDER BY fy2025_revenue DESC
LIMIT 10;


/* TASK 5 -  A commercial gap */
SELECT
    customers.trading_name,
    customers.segment,
    customers.province,
    SUM(sales_lines.line_revenue) AS total_revenue
FROM workspace.default.sizwe_customers AS customers
JOIN workspace.default.sizwe_sales_orders AS sales_orders
    ON customers.customer_id = sales_orders.customer_id
JOIN workspace.default.sizwe_sales_lines AS sales_lines
    ON sales_orders.order_id = sales_lines.order_id
WHERE sales_orders.channel = 'Wholesale'
  AND NOT EXISTS (
      SELECT 1
      FROM workspace.default.sizwe_trade_promotions AS trade_promotions
      WHERE trade_promotions.customer_id = customers.customer_id
  )
GROUP BY
    customers.trading_name,
    customers.segment,
    customers.province
ORDER BY total_revenue DESC
LIMIT 15;
/*
I would recommend looking at Umhlanga Fresh 108, Ridgeway Foods 308 and Kalahari Kitchen 42 for possible promotions. These are the three highest-revenue Wholesale customers in the results that have not received any recorded promotions, generating approximately R6.22 million, R4.45 million and R4.45 million in revenue respectively. Offering them promotions could help encourage more purchases and strengthen the business relationship. However, Sizwe Coffee should first consider whether the promotions would be profitable and whether these customers have the potential to increase their spending.
*/


/* TASK 6 - Are the sales representatives hitting target? */
WITH fy2025_rep_revenue AS (
    SELECT
        sales_orders.rep_id,
        SUM(sales_lines.line_revenue) AS total_fy2025_revenue
    FROM workspace.default.sizwe_sales_orders AS sales_orders
    JOIN workspace.default.sizwe_sales_lines AS sales_lines
        ON sales_orders.order_id = sales_lines.order_id
    WHERE sales_orders.order_date > DATE '2024-06-30'
      AND sales_orders.order_date <= DATE '2025-06-30'
    GROUP BY sales_orders.rep_id
)
SELECT
    reps.rep_name,
    reps.territory,
    reps.target_monthly,
    ROUND(COALESCE(fy2025_rep_revenue.total_fy2025_revenue, 0) / 12, 2) AS fy2025_monthly_average,
    ROUND(
        (COALESCE(fy2025_rep_revenue.total_fy2025_revenue, 0) / 12)
        / NULLIF(reps.target_monthly, 0) * 100,
        2
    ) AS percentage_of_target
FROM workspace.default.sizwe_reps AS reps
LEFT JOIN fy2025_rep_revenue
    ON reps.rep_id = fy2025_rep_revenue.rep_id
ORDER BY percentage_of_target DESC NULLS LAST;


/* TASK 7 - The shape of the year */
WITH monthly_total AS (
    SELECT
        DATE_TRUNC('month', sales_orders.order_date) AS sales_month,
        SUM(sales_lines.line_revenue) AS monthly_revenue
    FROM workspace.default.sizwe_sales_orders AS sales_orders
    JOIN workspace.default.sizwe_sales_lines AS sales_lines
        ON sales_orders.order_id = sales_lines.order_id
    WHERE sales_orders.order_date >= DATE '2023-07-01'
      AND sales_orders.order_date < DATE '2025-07-01'
    GROUP BY DATE_TRUNC('month', sales_orders.order_date)
),
monthly_comparison AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue, 1) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue,
        AVG(monthly_revenue) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS three_month_avg
    FROM monthly_total
)
SELECT
    sales_month,
    monthly_revenue,
    previous_month_revenue,
    ROUND(
        (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS percentage_change,
    ROUND(three_month_avg, 2) AS three_month_avg
FROM monthly_comparison
ORDER BY sales_month;
/*
The results show that revenue tends to decrease towards the end of the year and then starts recovering in the new year. December 2023 was the quietest month, with revenue of approximately R29.87 million, which was a 13.09% decrease from the previous month. A similar pattern occurred in December 2024, when revenue decreased by 12.89%. This could suggest that customers purchase less during December. Sizwe Coffee could look into the reasons for this pattern and plan its sales activities around these quieter months.
*/


/* TASK 8 - Why has the margin moved? */
WITH product_year_revenue AS (
    SELECT
        products.product_line,
        CASE
            WHEN sales_orders.order_date <= DATE '2024-06-30'
                THEN 'FY2024'
            ELSE 'FY2025'
        END AS financial_year,
        SUM(sales_lines.line_revenue) AS revenue,
        SUM(sales_lines.cogs) AS total_cogs
    FROM workspace.default.sizwe_sales_orders AS sales_orders
    JOIN workspace.default.sizwe_sales_lines AS sales_lines
        ON sales_orders.order_id = sales_lines.order_id
    JOIN workspace.default.sizwe_products AS products
        ON sales_lines.sku = products.sku
    WHERE sales_orders.order_date <= DATE '2025-06-30'
    GROUP BY
        products.product_line,
        CASE
            WHEN sales_orders.order_date <= DATE '2024-06-30'
                THEN 'FY2024'
            ELSE 'FY2025'
        END
)
SELECT
    product_year_revenue.product_line,
    product_year_revenue.financial_year,
    ROUND(product_year_revenue.revenue, 2) AS revenue,
    ROUND(
        (
            product_year_revenue.revenue - product_year_revenue.total_cogs
        ) / NULLIF(product_year_revenue.revenue, 0) * 100,
        2
    ) AS gross_margin_pct,
    ROUND(
        product_year_revenue.revenue
        / NULLIF(
            SUM(product_year_revenue.revenue) OVER (
                PARTITION BY product_year_revenue.financial_year
            ),
            0
        ) * 100,
        2
    ) AS share_of_total_revenue_pct
FROM product_year_revenue
ORDER BY
    product_year_revenue.product_line,
    product_year_revenue.financial_year;
/*
Sizwe Coffee's overall gross margin decreased from 34.7% in FY2024 to 33.0% in FY2025, even though revenue grew by almost 9%. One possible reason for this is the increase in Bulk Commercial's share of total revenue, which grew from 25.02% to 33.65%. Bulk Commercial has a much lower gross margin of around 19.9%, compared to the other product lines. This means that selling a larger proportion of Bulk Commercial products could have contributed to the decrease in the overall gross margin. However, other factors may also have played a role.
*/
