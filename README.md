# Adani Group - Business Performance MIS Dashboard

A group-level MIS project consolidating quarterly business performance across multiple verticals into a single leadership-facing view - built as both an Excel/Power BI dashboard and a queryable MySQL backend, the kind of dual reporting layer used at a diversified infrastructure conglomerate's HQ.

**Note:** This project uses a **simulated dataset** built for portfolio purposes to mirror the structure and reporting cadence of a real multi-vertical infrastructure group. It is not sourced from or representative of any company's actual financials.

## About this project

This repo has two parts that model the same fictional conglomerate at **different levels of detail** - they tell the same kind of MIS story but aren't drawn from one shared dataset, so figures won't reconcile line-for-line between them:

- **Dashboard (Excel)** - group-level quarterly view across 4 core verticals (Ports & Logistics, Power, Green Energy, Cement): revenue, cost, EBITDA margin, budget vs. actual.
- **SQL layer (MySQL)** - a deeper relational model across 8 verticals (adds Airports, Gas, Data Centers, Defense) with employee, project, and monthly performance data, answering 18 business questions via SQL.

## Dashboard (Excel)

### Key Metrics (Latest Quarter)

| Metric | Value |
|---|---|
| Total Revenue | ₹17,040.3 Cr |
| Total Cost | ₹10,385.2 Cr |
| Group EBITDA Margin | 39.1% |
| YoY Revenue Growth | 6.5% |

### Contents

- **Dashboard** - Summary KPIs and revenue-by-vertical view (actual vs. budget, with variance %)
- **Data Dictionary** - Field definitions and project notes
- **Raw Data** - Quarterly figures by vertical: revenue, cost, budgeted revenue, operational volume (cargo MMT / generation MW / cement tonnes as applicable), and EBITDA margin %

### Fields Tracked

| Field | Description |
|---|---|
| Quarter | Fiscal quarter (Apr–Mar Indian FY) |
| Vertical | Ports & Logistics / Power / Green Energy / Cement |
| Revenue (Cr) | Quarterly revenue |
| Cost (Cr) | Quarterly operating cost |
| Budget Revenue (Cr) | Board-approved budgeted revenue |
| Volume | Operational volume metric (unit varies by vertical) |
| EBITDA Margin % | (Revenue − Cost) / Revenue |

### Tools Used

- Microsoft Excel (formulas, pivot-style summary tables, conditional formatting)
- Data modeling across multiple linked sheets (Raw Data → Dashboard)

## SQL Layer (`/sql`)

A MySQL backend modeling the same style of multi-vertical business (8 verticals: Ports & Logistics, Power, Green Energy, Cement, Airports, Gas, Data Centers, Defense) with employees, capital projects, and monthly performance tracking. Answers 18 business questions using JOINs, GROUP BY/HAVING, and subqueries - showing the same kind of MIS insights (headcount, revenue vs. target, RAG status, project budgets) built from a queryable relational database instead of pivot tables.

| File | Description |
|---|---|
| `sql/01_schema.sql` | Table definitions - verticals, employees, projects, monthly_performance |
| `sql/02_sample_data.sql` | Sample data (fictionalized, seeded for reproducibility) |
| `sql/03_business_queries.sql` | 18 business questions: JOINs, GROUP BY/HAVING, subqueries, CASE WHEN RAG logic |

**Run it:**
```bash
mysql -u root < sql/01_schema.sql
mysql -u root < sql/02_sample_data.sql
mysql -u root adani_business_analytics < sql/03_business_queries.sql
```
Tested on MySQL 8.0 / MariaDB 10.11.

**Skills demonstrated:** relational schema design, INNER/LEFT/SELF joins across up to 3 tables, aggregate functions with GROUP BY/HAVING, scalar + correlated + derived-table subqueries, and CASE WHEN logic mirroring the RAG flagging used in the Excel dashboard.

## Skills Demonstrated (overall)

- MIS/BI reporting structure for multi-business-unit organizations
- Budget vs. actual variance analysis
- KPI summarization for leadership-level dashboards
- Relational schema design and SQL query writing (joins, subqueries, aggregation)
- Data dictionary documentation practices

## Author

**Niyati Ray**
Computer Engineering Graduate | Aspiring BI/MIS Analyst
[LinkedIn](https://linkedin.com/in/niyati-ray) · [GitHub](https://github.com/niyati-ray3)
