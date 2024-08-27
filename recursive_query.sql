CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

INSERT INTO employees (employee_id, full_name, manager_id) VALUES 
(1, 'Иванов Иван Иванович', 3),
(2, 'Петров Петр Петрович', 3),
(3, 'Сидорова Марина Сергеевна', 5),
(4, 'Петрова Ольга Юрьевна', 5),
(5, 'Юрьев Максим Олегович', 6),
(6, 'Сергеев Олег Алексеевич', NULL);

WITH RECURSIVE employee_hierarchy AS (
    -- Anchor member
    SELECT
        e.employee_id,
        e.full_name,
        e.manager_id,
        CAST('' AS TEXT) AS managers
    FROM 
        employees e
    WHERE 
        e.manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT 
        e.employee_id,
        e.full_name,
        e.manager_id,
        eh.managers || CASE WHEN eh.managers = '' THEN '' ELSE '\' END || e.manager_id::TEXT
    FROM 
        employees e
    JOIN 
        employee_hierarchy eh ON e.manager_id = eh.employee_id
)
-- Final output
SELECT 
    employee_id,
    full_name,
    managers
FROM 
    employee_hierarchy
ORDER BY 
    employee_id;
