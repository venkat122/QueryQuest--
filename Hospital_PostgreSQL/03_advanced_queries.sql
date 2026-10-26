-- ==============================================================================
-- QueryQuest: Advanced Query Tuning
-- Demonstrating the use of Window Functions and Structured CTEs.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 1: Structured CTE for hierarchical reporting
-- Goal: Find the total number of appointments per department for the current month,
--       and highlight departments that have above-average appointment volume.
-- ------------------------------------------------------------------------------

WITH MonthlyAppointments AS (
    -- CTE 1: Aggregate appointments by doctor for the current month
    SELECT 
        DoctorID,
        COUNT(AppointmentID) AS ApptCount
    FROM Appointments
    WHERE DATE_TRUNC('month', AppointmentDateTime) = DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY DoctorID
),
DepartmentVolume AS (
    -- CTE 2: Join with Doctors and Departments to aggregate at the department level
    SELECT 
        d.DepartmentName,
        SUM(ma.ApptCount) AS TotalDepartmentAppointments
    FROM MonthlyAppointments ma
    JOIN Doctors doc ON ma.DoctorID = doc.DoctorID
    JOIN Departments d ON doc.DepartmentID = d.DepartmentID
    GROUP BY d.DepartmentName
),
AverageVolume AS (
    -- CTE 3: Calculate the overall average across all departments
    SELECT AVG(TotalDepartmentAppointments) AS AvgAppts FROM DepartmentVolume
)
-- Main Query: Combine the CTEs to output the final analytical report
SELECT 
    dv.DepartmentName,
    dv.TotalDepartmentAppointments,
    CASE 
        WHEN dv.TotalDepartmentAppointments > av.AvgAppts THEN 'High Volume'
        ELSE 'Normal Volume'
    END AS Status
FROM DepartmentVolume dv
CROSS JOIN AverageVolume av
ORDER BY dv.TotalDepartmentAppointments DESC;


-- ------------------------------------------------------------------------------
-- Query 2: Window Functions for moving analytics without self-joins
-- Goal: For every doctor, list their appointments and show the running total 
--       of appointments they've had this week, alongside their rank by volume.
-- ------------------------------------------------------------------------------

SELECT 
    doc.FirstName || ' ' || doc.LastName AS DoctorName,
    a.AppointmentDateTime,
    p.FirstName || ' ' || p.LastName AS PatientName,
    
    -- Window Function 1: Running total of appointments per doctor ordered by time
    COUNT(a.AppointmentID) OVER (
        PARTITION BY doc.DoctorID 
        ORDER BY a.AppointmentDateTime
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal_Appts,
    
    -- Window Function 2: Rank doctors based on their total appointment volume
    -- Using DENSE_RANK so there are no gaps in ranking values if there's a tie
    DENSE_RANK() OVER (
        ORDER BY (
            SELECT COUNT(*) FROM Appointments sub_a WHERE sub_a.DoctorID = doc.DoctorID
        ) DESC
    ) AS OverallDoctorRank

FROM Appointments a
JOIN Doctors doc ON a.DoctorID = doc.DoctorID
JOIN Patients p ON a.PatientID = p.PatientID
WHERE a.AppointmentDateTime >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY OverallDoctorRank, a.AppointmentDateTime;
