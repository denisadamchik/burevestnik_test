CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    order_number VARCHAR(10) NOT NULL,
    department VARCHAR(4) NOT NULL
);

INSERT INTO orders (employee_id, date, order_number, department) VALUES 
(1, '2016-03-02', '345', '0111'),
(1, '2016-04-15', '232/23', '0202'),
(2, '2016-04-02', '123', '0042'),
(2, '2016-05-03', '21-2', '0111'),
(2, '2016-05-03', '34/4', '0111'),
(3, '2016-02-02', '32', '0042'),
(4, '2016-04-01', '678', '0773'),
(4, '2016-02-01', '789', '0779'),
(5, '2016-04-02', '125', '0111'),
(5, '2016-05-06', '90', '0099'),
(6, '2016-03-02', '87', '0099');

SELECT * FROM orders;

WITH department_monthly_stats AS (
    -- Stats for the specified month
    SELECT 
        employee_id, 
        department, 
        COUNT(*) AS monthly_count
    FROM 
        orders
    WHERE 
        date BETWEEN '2016-05-01' AND '2016-05-30'
    GROUP BY 
        employee_id, department
),
department_before_stats AS (
    -- Stats for the period before the specified month
    SELECT 
        employee_id, 
        department, 
        COUNT(*) AS before_count
    FROM 
        orders
    WHERE 
        date < '2016-05-01'
    GROUP BY 
        employee_id, department
),
joined_stats AS (
    SELECT 
        COALESCE(m.employee_id, b.employee_id) AS employee_id,
        COALESCE(m.department, b.department) AS department,
        COALESCE(b.before_count, 0) AS before_count,
        COALESCE(m.monthly_count, 0) AS monthly_count
    FROM 
        department_monthly_stats m
    FULL OUTER JOIN 
        department_before_stats b 
    ON 
        m.employee_id = b.employee_id AND 
        m.department = b.department
),
entry_exit_status AS (
    SELECT 
        employee_id,
        department,
        CASE
            WHEN monthly_count > 0 THEN TRUE
            ELSE NULL
        END AS entered,
        NULL AS "left"
    FROM 
        joined_stats j1
    WHERE 
        monthly_count > 0

    UNION ALL

    SELECT 
        employee_id,
        department,
        NULL AS entered,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM joined_stats j2
                WHERE j2.employee_id = j1.employee_id
                  AND j2.department <> j1.department
                  AND j2.monthly_count > 0
            ) THEN TRUE
            ELSE NULL
        END AS "left"
    FROM 
        joined_stats j1
    WHERE 
        monthly_count = 0
)

SELECT 
    department,
    COUNT(CASE WHEN entered THEN 1 END) AS entered_count,
    COUNT(CASE WHEN "left" THEN 1 END) AS left_count
FROM 
    entry_exit_status
GROUP BY 
    department
ORDER BY 
    department;
