# Sizwe Coffee SQL Database

## Project Overview

For this assignment, I used SQL in Databricks to analyse Sizwe Coffee's business data and answer eight business questions. The analysis focuses on revenue, product profitability, customer payments, customer relationships, promotions, sales representative performance and monthly sales trends.

Sizwe Coffee is a South African coffee roastery and wholesale supplier operating from Isando, Johannesburg, and Epping, Cape Town. The business supplies coffee through two main channels: Wholesale and Subscription.

The aim of this project was to use SQL to understand the business's performance and identify areas where it could improve.

## Business Questions

The analysis covers the following eight questions:

1. Compare revenue by channel between FY2024 and FY2025.
2. Compare revenue, cost of goods sold (COGS), gross profit and gross margin by product line.
3. Analyse invoice payments, settlement times and outstanding balances by channel.
4. Identify the top 10 customers by FY2025 revenue.
5. Find high-revenue Wholesale customers who have not received a recorded trade promotion.
6. Compare sales representatives' monthly revenue against their targets.
7. Analyse monthly revenue trends, percentage changes and rolling three-month averages.
8. Compare product line performance across financial years and investigate the decrease in overall gross margin.

## Dataset

The project uses nine tables available in the Databricks `workspace.default` schema.

| Table | Description |
|---|---|
| `sizwe_customers` | Customer details, including trading name, segment, province, channel and assigned representative. |
| `sizwe_products` | Product details and product line information. |
| `sizwe_sales_orders` | Sales order information, including order dates and customer details. |
| `sizwe_sales_lines` | Sales line details, including revenue and cost of goods sold. |
| `sizwe_ar_ledger` | Accounts receivable information, including invoices, amounts settled and outstanding balances. |
| `sizwe_reps` | Sales representative information, including territories and monthly targets. |
| `sizwe_rep_visits` | Records of sales representative visits to customers. |
| `sizwe_trade_promotions` | Records of trade promotions associated with customers. |
| `sizwe_vendors` | Supplier and vendor information. |

### Table Relationships

The tables were connected using their relevant keys:

- `sizwe_sales_orders` was joined to `sizwe_customers` using `customer_id`.
- `sizwe_sales_orders` was joined to `sizwe_sales_lines` using `order_id`.
- `sizwe_sales_lines` was joined to `sizwe_products` using `sku`.
- Sales orders and customers were linked to `sizwe_reps` using `rep_id`.
- `sizwe_ar_ledger` was joined to `sizwe_customers` using `customer_id` to analyse invoice payments by channel.
- `sizwe_rep_visits` and `sizwe_trade_promotions` were connected to customers using `customer_id`.

These relationships allowed me to combine information from different tables to answer the business questions.

## SQL Skills Used

The project gave me an opportunity to practise several SQL concepts in Databricks.

| SQL concept | How I used it |
|---|---|
| `JOIN` and `LEFT JOIN` | Combined information from related tables while retaining customers or representatives where needed. |
| Aggregate functions | Used `SUM()`, `COUNT()`, `AVG()`, `MIN()` and `MAX()` to calculate business measures. |
| `GROUP BY` | Grouped results by channel, product line, customer, representative and month. |
| `CASE WHEN` | Categorised invoices as settled or open and calculated conditional results. |
| `ORDER BY` | Sorted results to identify the highest-revenue customers and best-performing representatives. |
| `COALESCE()` and `NULLIF()` | Handled null values and avoided division by zero. |
| `NOT EXISTS` | Identified Wholesale customers without recorded trade promotions. |
| Common Table Expressions (CTEs) | Organised more complex queries into smaller, more readable steps. |
| Window functions | Used functions such as `LAG()` and rolling averages to compare monthly results. |
| Date functions | Grouped revenue by month and calculated the time taken to settle invoices. |

## Key Business Insights

### Task 1: Revenue Growth by Channel

Both Subscription and Wholesale revenue increased from FY2024 to FY2025.

| Channel | FY2024 Revenue | FY2025 Revenue | Growth |
|---|---:|---:|---:|
| Subscription | R132.83 million | R144.57 million | 8.84% |
| Wholesale | R308.17 million | R335.43 million | 8.85% |

Wholesale generated more revenue than Subscription in both financial years. It also remained the larger channel in FY2025, generating approximately R335.43 million compared with R144.57 million from Subscription.

Both channels grew at almost the same rate, showing consistent revenue growth across the two channels. Sizwe Coffee should continue supporting both channels while looking for opportunities to increase sales and retain existing customers.

### Task 2: Product Line Profitability

House Blend generated the highest gross profit at approximately **R107.15 million**, while Single Origin had the highest gross margin at **44.27%**.

This shows that the product line generating the most gross profit is not necessarily the one with the highest profit margin. Gross profit measures the amount earned after deducting the cost of goods sold, while gross margin shows the percentage of revenue retained after those costs.

Sizwe Coffee should consider both measures when making decisions about its product range. House Blend is important for the overall gross profit it generates, while Single Origin performs well in terms of margin.

### Task 3: Invoice Payments and Outstanding Balances

The payment analysis showed a clear difference between the Subscription and Wholesale channels.

| Measure | Subscription | Wholesale |
|---|---:|---:|
| Total invoices | 19,200 | 28,944 |
| Open invoices | 44 | 3,454 |
| Settled invoices | 19,156 | 25,490 |
| Average days to settle | 3.85 days | 68.68 days |
| Total outstanding balance | R751,178.89 | R87,848,227.20 |

Subscription had very few open invoices and an average settlement time of 3.85 days. Wholesale had 3,454 open invoices and an average settlement time of 68.68 days.

The outstanding Wholesale balance was approximately R87.85 million, compared with approximately R751,178.89 for Subscription. This makes Wholesale the main area of concern when it comes to outstanding payments.

Sizwe Coffee should review overdue Wholesale invoices, follow up with customers who have not paid and investigate whether payment terms or credit-control processes need to be improved. The business should also continue monitoring Subscription payments to maintain its strong settlement performance.

*The average settlement time was calculated using settled invoices only. Open invoices were excluded from this calculation.*

### Task 4: Top 10 Customers by FY2025 Revenue

Halvane Retail Group was the highest-revenue customer in FY2025, generating approximately **R38.40 million**. The next highest customer in the results was Highveld Deli 85, with approximately R3.38 million in revenue.

The top 10 customers included grocery chains, restaurant groups, independent cafés and hotel groups across several provinces. The results also showed that these customers were managed by different sales representatives.

The difference between Halvane Retail Group and the other customers is worth noting. Maintaining a strong relationship with this customer is important because of the revenue it generates. At the same time, Sizwe Coffee should continue developing its relationships with other high-value customers to support growth and reduce reliance on a small number of major accounts.

### Task 5: High-Revenue Wholesale Customers Without Recorded Promotions

The analysis identified high-revenue Wholesale customers who had not received a recorded trade promotion. The top three recommendations were:

| Customer | FY2025 Revenue |
|---|---:|
| Umhlanga Fresh 108 | Approximately R6.22 million |
| Ridgeway Foods 308 | Approximately R4.45 million |
| Kalahari Kitchen 42 | Approximately R4.45 million |

These customers are potential candidates for future trade promotions because they already generate significant revenue despite having no recorded promotion.

Sizwe Coffee could consider targeted promotions for these customers to encourage repeat purchases, strengthen customer relationships and potentially increase sales. Before introducing a promotion, the business should assess the expected cost and whether the additional sales would justify the investment.

The absence of a recorded promotion does not necessarily mean that a customer has never received one outside the available records.

### Task 6: Sales Representative Performance

The results showed that most sales representatives exceeded their monthly revenue targets.

**Karabo van Wyk** achieved the highest percentage of target at 250.32%, with average monthly revenue of approximately R2.25 million against a target of R900,000.

**Kagiso Mkhize** generated the highest average monthly revenue at approximately R5.00 million, achieving 249.82% of the monthly target of R2 million. Johan Maluleke also performed strongly, achieving 242.77% of target.

Two representatives did not meet their targets:

- **Sipho Steyn:** 97.99% of target, with average monthly revenue of approximately R1.96 million against a R2 million target.
- **Johan Naidoo:** 77.63% of target, with average monthly revenue of approximately R1.16 million against a R1.5 million target.

Overall, the results suggest that the sales team performed well against its targets. Sizwe Coffee could review the approaches used by the highest-performing representatives and identify practices that could help the rest of the team. Representatives below target may benefit from additional support, coaching or a review of their territories and targets.

### Task 7: Monthly Revenue Trends

The monthly revenue analysis covered the period from July 2023 to June 2025. It included month-on-month percentage changes and a rolling three-month average to help identify changes in sales performance over time.

December 2023 was the quietest month in the results, with revenue of approximately **R29.87 million**. Revenue decreased by 13.09% compared with the previous month.

December 2024 also showed a decrease, with revenue falling by 12.89%. Revenue recovered in January and February 2025.

These results suggest that December may be a quieter sales period for Sizwe Coffee. The business could investigate whether this pattern is linked to seasonal demand, customer purchasing behaviour or changes in business activity during the holiday period.

Understanding these trends could help Sizwe Coffee plan inventory, sales activities and cash flow more effectively. The rolling three-month average also helps smooth out individual monthly fluctuations and makes broader trends easier to identify.

### Task 8: Product Line Performance Across Financial Years

The analysis showed that overall gross margin decreased from **34.7% in FY2024 to 33.0% in FY2025**, even though revenue grew by nearly 9%.

Bulk Commercial's share of total revenue increased from 25.02% in FY2024 to 33.65% in FY2025. However, its gross margin remained relatively low at approximately 19.89% in FY2024 and 19.91% in FY2025.

Over the same period, House Blend's share of total revenue decreased from 32.14% to 28.71%, while Single Origin's share decreased from 19.45% to 17.57%.

One possible explanation for the decrease in overall gross margin is the increase in Bulk Commercial's share of total revenue. Since Bulk Commercial has a lower margin than some of the other product lines, a larger share of sales coming from this product line could place downward pressure on the overall margin.

However, this does not prove that the change in product mix was the only reason for the decrease. Sizwe Coffee should also consider changes in product costs, selling prices and the performance of the other product lines.

## How to Run the Queries

1. Open the project in Databricks.
2. Make sure the tables are available in the `workspace.default` schema.
3. Open the `queries.sql` file in the repository.
4. Run each task's query separately.
5. Review the result tables and compare them with the business insights documented in this README.

The written findings are included to explain what the SQL results mean for the business, rather than only presenting the numbers.

## Conclusion

This project helped me practise using SQL to analyse business data and turn query results into useful findings.

The analysis showed that both Subscription and Wholesale revenue grew by almost 9% from FY2024 to FY2025. It also highlighted differences in product profitability, customer payment behaviour and sales representative performance.

One of the main findings was the large outstanding balance in Wholesale, along with its longer average settlement time. The analysis also showed that Bulk Commercial's growing share of revenue may be contributing to the decrease in overall gross margin.

Overall, the project helped me understand how SQL can be used to answer business questions, identify areas that need attention and support decision-making using data.
This project contains SQL queries used to analyze sales, profitability, collections, customer performance, and sales rep productivity for Sizwe's Coffee Shop.

## Project Purpose

The analysis explores several business questions, including:

- Channel performance and revenue growth
- Product lines driving profit
- Accounts receivable collection issues
- Top performing customers and revenue concentration
- Commercial gaps for wholesale customers
- Sales representative performance against targets
- Monthly revenue trends across the financial year

## Files

- `queries.sql` — SQL script containing the analysis queries and business commentary

## Database Context

The queries reference multiple warehouse tables, including:

- `sizwe_sales_orders`
- `sizwe_sales_lines`
- `sizwe_products`
- `sizwe_customers`
- `sizwe_ar_ledger`
- `sizwe_reps`
- `sizwe_trade_promotions`

## Notes

The SQL includes several business insights and recommendations based on the results, such as:

- identifying profit and margin drivers
- spotting collection risk in wholesale accounts
- prioritizing high-value customer opportunities
- evaluating representative performance and target attainment

## How to Use

1. Open the SQL file in your SQL client or IDE.
2. Run the queries against the relevant database schema.
3. Review the results for each task and compare findings against the commentary included in the script.

## Learning Focus

This project is designed to practice:

- SQL joins and aggregations
- conditional logic and financial calculations
- window functions and time-based analysis
- customer and sales performance interpretation
- translating data insights into business recommendations
