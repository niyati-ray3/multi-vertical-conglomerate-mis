-- ============================================================
-- Adani Group MIS Dashboard — SQL Layer
-- 03_business_queries.sql
--
-- 18 business questions solved with:
--   JOINS (INNER, LEFT, SELF)  |  GROUP BY / HAVING  |  SUBQUERIES
--   (scalar, IN, correlated, derived table)  |  CASE WHEN
--
-- Run after 01_schema.sql and 02_sample_data.sql
-- ============================================================
USE adani_business_analytics;


-- ------------------------------------------------------------
-- SECTION A: JOINS
-- ------------------------------------------------------------

-- Q1. List every employee with their vertical name and sector.
-- (INNER JOIN)
SELECT e.full_name, e.designation, v.vertical_name, v.sector
FROM employees e
INNER JOIN verticals v ON e.vertical_id = v.vertical_id
ORDER BY v.vertical_name, e.designation;


-- Q2. List all projects with their vertical name and project lead's name.
-- (INNER JOIN across 3 tables)
SELECT p.project_name, v.vertical_name, e.full_name AS project_lead, p.status, p.budget_cr
FROM projects p
INNER JOIN verticals v ON p.vertical_id = v.vertical_id
INNER JOIN employees e ON p.project_lead_id = e.employee_id
ORDER BY p.budget_cr DESC;


-- Q3. Show every vertical, including any that currently have zero ongoing projects.
-- (LEFT JOIN — highlights verticals with no matching rows in projects)
SELECT v.vertical_name, COUNT(p.project_id) AS ongoing_project_count
FROM verticals v
LEFT JOIN projects p ON v.vertical_id = p.vertical_id AND p.status = 'Ongoing'
GROUP BY v.vertical_name
ORDER BY ongoing_project_count DESC;


-- Q4. Self-join: show each employee alongside their manager's name.
SELECT e.full_name AS employee, e.designation, m.full_name AS manager, m.designation AS manager_designation
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY m.full_name IS NULL DESC, m.full_name;


-- Q5. For each vertical, find the delayed projects along with the lead's department.
-- (INNER JOIN + WHERE)
SELECT v.vertical_name, p.project_name, e.department AS lead_department, p.budget_cr
FROM projects p
JOIN verticals v ON p.vertical_id = v.vertical_id
JOIN employees e ON p.project_lead_id = e.employee_id
WHERE p.status = 'Delayed'
ORDER BY p.budget_cr DESC;


-- ------------------------------------------------------------
-- SECTION B: GROUP BY / HAVING / AGGREGATES
-- ------------------------------------------------------------

-- Q6. Headcount and average salary (in LPA) per vertical.
SELECT v.vertical_name, COUNT(e.employee_id) AS headcount,
       ROUND(AVG(e.annual_salary_lpa),2) AS avg_salary_lpa
FROM employees e
JOIN verticals v ON e.vertical_id = v.vertical_id
GROUP BY v.vertical_name
ORDER BY headcount DESC;


-- Q7. Departments with more than 8 employees company-wide.
-- (GROUP BY + HAVING)
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 8
ORDER BY employee_count DESC;


-- Q8. Total project budget committed per vertical, only where total budget exceeds 1500 Cr.
-- (GROUP BY + HAVING on aggregated sum)
SELECT v.vertical_name, SUM(p.budget_cr) AS total_committed_cr, COUNT(p.project_id) AS project_count
FROM projects p
JOIN verticals v ON p.vertical_id = v.vertical_id
GROUP BY v.vertical_name
HAVING SUM(p.budget_cr) > 1500
ORDER BY total_committed_cr DESC;


-- Q9. Yearly revenue vs target achievement % per vertical (2025 only).
SELECT v.vertical_name,
       SUM(mp.revenue_cr) AS total_revenue_cr,
       SUM(mp.target_cr)  AS total_target_cr,
       ROUND(SUM(mp.revenue_cr) / SUM(mp.target_cr) * 100, 1) AS achievement_pct
FROM monthly_performance mp
JOIN verticals v ON mp.vertical_id = v.vertical_id
WHERE mp.perf_year = 2025
GROUP BY v.vertical_name
ORDER BY achievement_pct DESC;


-- Q10. Project status breakdown (count and % share) across the whole group.
SELECT status,
       COUNT(*) AS project_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM projects), 1) AS pct_of_total
FROM projects
GROUP BY status
ORDER BY project_count DESC;


-- ------------------------------------------------------------
-- SECTION C: SUBQUERIES
-- ------------------------------------------------------------

-- Q11. Employees earning above the company-wide average salary.
-- (Scalar subquery in WHERE)
SELECT full_name, department, designation, annual_salary_lpa
FROM employees
WHERE annual_salary_lpa > (SELECT AVG(annual_salary_lpa) FROM employees)
ORDER BY annual_salary_lpa DESC;


-- Q12. Verticals that currently have at least one delayed project.
-- (Subquery with IN)
SELECT vertical_name, sector
FROM verticals
WHERE vertical_id IN (
    SELECT vertical_id FROM projects WHERE status = 'Delayed'
);


-- Q13. Employees who earn more than the average salary *within their own vertical*.
-- (Correlated subquery)
SELECT e.full_name, v.vertical_name, e.annual_salary_lpa
FROM employees e
JOIN verticals v ON e.vertical_id = v.vertical_id
WHERE e.annual_salary_lpa > (
    SELECT AVG(e2.annual_salary_lpa)
    FROM employees e2
    WHERE e2.vertical_id = e.vertical_id
)
ORDER BY v.vertical_name, e.annual_salary_lpa DESC;


-- Q14. Top 3 verticals by FY2025 total revenue, using a derived table (subquery in FROM).
SELECT vertical_name, total_revenue_cr
FROM (
    SELECT v.vertical_name, SUM(mp.revenue_cr) AS total_revenue_cr
    FROM monthly_performance mp
    JOIN verticals v ON mp.vertical_id = v.vertical_id
    WHERE mp.perf_year = 2025
    GROUP BY v.vertical_name
) AS vertical_revenue
ORDER BY total_revenue_cr DESC
LIMIT 3;


-- Q15. The single vertical with the highest total project budget (nested subquery).
SELECT vertical_name
FROM verticals
WHERE vertical_id = (
    SELECT vertical_id
    FROM projects
    GROUP BY vertical_id
    ORDER BY SUM(budget_cr) DESC
    LIMIT 1
);


-- Q16. Projects whose budget exceeds the average budget of projects in the SAME vertical.
-- (Correlated subquery, useful for flagging outlier/high-cost projects)
SELECT p.project_name, v.vertical_name, p.budget_cr
FROM projects p
JOIN verticals v ON p.vertical_id = v.vertical_id
WHERE p.budget_cr > (
    SELECT AVG(p2.budget_cr)
    FROM projects p2
    WHERE p2.vertical_id = p.vertical_id
)
ORDER BY v.vertical_name, p.budget_cr DESC;


-- ------------------------------------------------------------
-- SECTION D: CASE WHEN / RAG STATUS (bridges to your Excel Variance Tracker)
-- ------------------------------------------------------------

-- Q17. RAG-flag each vertical's June 2026 performance vs target.
SELECT v.vertical_name, mp.revenue_cr, mp.target_cr,
       ROUND((mp.revenue_cr - mp.target_cr) / mp.target_cr * 100, 1) AS variance_pct,
       CASE
           WHEN mp.revenue_cr >= mp.target_cr THEN 'Green'
           WHEN mp.revenue_cr >= mp.target_cr * 0.9 THEN 'Amber'
           ELSE 'Red'
       END AS rag_status
FROM monthly_performance mp
JOIN verticals v ON mp.vertical_id = v.vertical_id
WHERE mp.perf_month = 6 AND mp.perf_year = 2026
ORDER BY variance_pct;


-- Q18. Employee tenure in years, bucketed, with manager info (self-join + CASE + date math).
SELECT e.full_name, v.vertical_name, e.join_date,
       TIMESTAMPDIFF(YEAR, e.join_date, CURDATE()) AS tenure_years,
       CASE
           WHEN TIMESTAMPDIFF(YEAR, e.join_date, CURDATE()) >= 5 THEN 'Veteran (5+ yrs)'
           WHEN TIMESTAMPDIFF(YEAR, e.join_date, CURDATE()) >= 2 THEN 'Established (2-4 yrs)'
           ELSE 'New Joiner (<2 yrs)'
       END AS tenure_bucket,
       m.full_name AS manager
FROM employees e
JOIN verticals v ON e.vertical_id = v.vertical_id
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY tenure_years DESC;
