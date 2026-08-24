-- ============================================================
-- Adani Group MIS Dashboard — SQL Layer
-- 01_schema.sql
-- MySQL 8.0+
--
-- Creates the database schema for a simplified, illustrative
-- model of a multi-vertical conglomerate (inspired by Adani
-- Group's business structure: Ports & Logistics, Power,
-- Green Energy, Cement, Airports, Gas, Data Centers, Defense).
--
-- NOTE: All figures used in this project are fictionalized /
-- estimated for portfolio and learning purposes only. They do
-- NOT represent actual disclosed financials of any company.
-- ============================================================

DROP DATABASE IF EXISTS adani_business_analytics;
CREATE DATABASE adani_business_analytics;
USE adani_business_analytics;

-- ------------------------------------------------------------
-- 1. VERTICALS — the business units/sectors
-- ------------------------------------------------------------
CREATE TABLE verticals (
    vertical_id       INT PRIMARY KEY AUTO_INCREMENT,
    vertical_name     VARCHAR(60)  NOT NULL,
    sector            VARCHAR(60)  NOT NULL,
    hq_city           VARCHAR(40)  NOT NULL,
    established_year  INT          NOT NULL
);

-- ------------------------------------------------------------
-- 2. EMPLOYEES — headcount across verticals
-- ------------------------------------------------------------
CREATE TABLE employees (
    employee_id       INT PRIMARY KEY AUTO_INCREMENT,
    full_name         VARCHAR(80)   NOT NULL,
    vertical_id       INT           NOT NULL,
    department        VARCHAR(40)   NOT NULL,
    designation       VARCHAR(60)   NOT NULL,
    join_date         DATE          NOT NULL,
    annual_salary_lpa DECIMAL(6,2)  NOT NULL,  -- salary in INR Lakhs Per Annum
    manager_id        INT           NULL,
    CONSTRAINT fk_emp_vertical FOREIGN KEY (vertical_id) REFERENCES verticals(vertical_id),
    CONSTRAINT fk_emp_manager  FOREIGN KEY (manager_id)  REFERENCES employees(employee_id)
);

-- ------------------------------------------------------------
-- 3. PROJECTS — capital projects/initiatives run by each vertical
-- ------------------------------------------------------------
CREATE TABLE projects (
    project_id        INT PRIMARY KEY AUTO_INCREMENT,
    project_name      VARCHAR(100)  NOT NULL,
    vertical_id       INT           NOT NULL,
    project_lead_id   INT           NULL,
    start_date        DATE          NOT NULL,
    end_date          DATE          NULL,
    budget_cr         DECIMAL(10,2) NOT NULL,  -- budget in INR Crores
    status            VARCHAR(20)   NOT NULL,  -- Ongoing / Completed / Delayed / On Hold
    CONSTRAINT fk_proj_vertical FOREIGN KEY (vertical_id) REFERENCES verticals(vertical_id),
    CONSTRAINT fk_proj_lead     FOREIGN KEY (project_lead_id) REFERENCES employees(employee_id)
);

-- ------------------------------------------------------------
-- 4. MONTHLY_PERFORMANCE — revenue vs target vs expenses by vertical
-- ------------------------------------------------------------
CREATE TABLE monthly_performance (
    perf_id       INT PRIMARY KEY AUTO_INCREMENT,
    vertical_id   INT           NOT NULL,
    perf_month    INT           NOT NULL,  -- 1-12
    perf_year     INT           NOT NULL,
    revenue_cr    DECIMAL(10,2) NOT NULL,
    target_cr     DECIMAL(10,2) NOT NULL,
    expenses_cr   DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_perf_vertical FOREIGN KEY (vertical_id) REFERENCES verticals(vertical_id)
);

-- Helpful indexes for the JOIN/GROUP BY workloads used in 03_business_queries.sql
CREATE INDEX idx_emp_vertical  ON employees(vertical_id);
CREATE INDEX idx_proj_vertical ON projects(vertical_id);
CREATE INDEX idx_perf_vertical ON monthly_performance(vertical_id);
CREATE INDEX idx_perf_period   ON monthly_performance(perf_year, perf_month);
