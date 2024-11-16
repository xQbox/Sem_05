-- 1 
SELECT DISTINCT P1.patientSurname AS Patient1, P2.patientSurname AS Patient2, D.doctorSurname
FROM nsMed.patientsCard PC1
JOIN nsMed.patientsCard PC2 ON PC1.doctorId = PC2.doctorId
JOIN nsMed.Patients P1 ON PC1.patientId = P1.patientId
JOIN nsMed.Patients P2 ON PC2.patientId = P2.patientId
JOIN nsMed.Doctors D ON PC1.doctorId = D.doctorId
WHERE P1.patientId <> P2.patientId
AND PC1.dataOfVisit <> PC2.dataOfVisit
ORDER BY D.doctorSurname, P1.patientSurname, P2.patientSurname;

-- 2
SELECT PC.patientCard, P.patientSurname, P.patientName, PC.dataOfVisit
FROM nsMed.patientsCard PC
JOIN nsMed.Patients P ON PC.patientId = P.patientId
WHERE PC.dataOfVisit BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY PC.dataOfVisit;

-- 3
SELECT DISTINCT diseaseName
FROM nsMed.Disease
WHERE diseaseName LIKE '%Hairy_tongue%';

-- 4
SELECT PC.patientCard, P.patientSurname, D.doctorSurname, PC.dataOfVisit
FROM nsMed.patientsCard PC
JOIN nsMed.Patients P ON PC.patientId = P.patientId
JOIN nsMed.Doctors D ON PC.doctorId = D.doctorId
WHERE P.patientAddress IN (
    SELECT patientAddress
    FROM nsMed.Patients
    WHERE patientAddress LIKE '%Москва%'
)
AND D.doctorSpeciality = 'Кардиолог';


-- 5
SELECT P.patientId, P.patientSurname, P.patientName
FROM nsMed.Patients P
WHERE EXISTS (
    SELECT 1
    FROM nsMed.Patients P1
    LEFT JOIN nsMed.patientsCard PC ON P1.patientId = PC.patientId
    WHERE PC.patientId IS NULL
    AND P.patientId = P1.patientId
);
-- 6
SELECT doctorId, doctorSurname, doctorExperience
FROM nsMed.Doctors
WHERE doctorExperience > ALL (
    SELECT doctorExperience
    FROM nsMed.Doctors
    WHERE doctorSpeciality = 'Хирург'
);

-- 7 
SELECT patientId,
       AVG(degreeOfSeverity) AS "Average Severity",
       MIN(degreeOfSeverity) AS "Minimum Severity",
       MAX(degreeOfSeverity) AS "Maximum Severity"
FROM nsMed.patientsCard
GROUP BY patientId;

-- 8 
SELECT diseaseId, diseaseName,
       (SELECT AVG(degreeOfSeverity)
        FROM nsMed.patientsCard PC
        WHERE PC.diseaseId = D.diseaseId) AS AvgSeverity,
       (SELECT MAX(degreeOfSeverity)
        FROM nsMed.patientsCard PC
        WHERE PC.diseaseId = D.diseaseId) AS MaxSeverity
FROM nsMed.Disease D;

-- 9
SELECT P.patientSurname, PC.dataOfVisit,
       CASE 
           WHEN EXTRACT(YEAR FROM PC.dataOfVisit) = EXTRACT(YEAR FROM CURRENT_DATE) THEN 'This Year'
           WHEN EXTRACT(YEAR FROM PC.dataOfVisit) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN 'Last Year'
           ELSE (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM PC.dataOfVisit)) || ' years ago'
       END AS "When"
FROM nsMed.Patients P
JOIN nsMed.patientsCard PC ON P.patientId = PC.patientId;


-- 10 
SELECT patientSurname, patientName, 
       CASE 
           WHEN patientDateOfBirthday IS NULL THEN 'Unknown Age'
           WHEN AGE(patientDateOfBirthday)::text < '20 years' THEN 'Young'
           WHEN AGE(patientDateOfBirthday)::text < '60 years' THEN 'Adult'
           ELSE 'Senior'
       END AS "Age Group"
FROM nsMed.Patients;


-- 11
SELECT doctorId, COUNT(patientId) AS "PatientsCount",
       SUM(degreeOfSeverity) AS "TotalSeverity"
INTO TEMP DoctorsStats
FROM nsMed.patientsCard
GROUP BY doctorId;


-- 12 
SELECT 'By Avg Severity' AS "Criteria", D.doctorSurname AS "Top Doctor"
FROM nsMed.Doctors D
JOIN (
    SELECT doctorId, AVG(degreeOfSeverity) AS AvgSeverity
    FROM nsMed.patientsCard
    GROUP BY doctorId
    ORDER BY AvgSeverity DESC
    LIMIT 1
) AS TopDoctor ON TopDoctor.doctorId = D.doctorId
UNION
SELECT 'By Total Visits' AS "Criteria", D.doctorSurname AS "Top Doctor"
FROM nsMed.Doctors D
JOIN (
    SELECT doctorId, COUNT(patientId) AS TotalVisits
    FROM nsMed.patientsCard
    GROUP BY doctorId
    ORDER BY TotalVisits DESC
    LIMIT 1
) AS TopDoctor ON TopDoctor.doctorId = D.doctorId;

-- 13
SELECT patientId
FROM nsMed.Patients
WHERE patientId = (
    SELECT patientId
    FROM nsMed.patientsCard
    GROUP BY patientId
    HAVING COUNT(DISTINCT diseaseId) = (
        SELECT MAX(diseaseCount)
        FROM (
            SELECT COUNT(DISTINCT diseaseId) AS diseaseCount
            FROM nsMed.patientsCard
            GROUP BY patientId
        ) AS SubQuery
    )
);


-- 14
SELECT patientId, AVG(degreeOfSeverity) AS avgSeverity
FROM nsMed.patientsCard
GROUP BY patientId;


-- 15 
SELECT patientId, AVG(degreeOfSeverity) AS avgSeverity
FROM nsMed.patientsCard
GROUP BY patientId
HAVING AVG(degreeOfSeverity) > (SELECT AVG(degreeOfSeverity) FROM nsMed.patientsCard);


-- 16
INSERT INTO nsMed.Patients (patientSurname, patientName, patientSecondSurname, patientDateOfBirthday, patientAddress, patientProfession, patientSex)
VALUES ('Иванов', 'Иван', 'Иванович', '1990-05-15', 'ул. Ленина, д. 10', 'Инженер', 'М');

-- 17
INSERT INTO nsMed.patientsCard (patientId, doctorId, diseaseId, symptoms, degreeOfSeverity)
SELECT p.patientId, d.doctorId, dis.diseaseId, 'Головная боль', 3
FROM nsMed.Patients p
JOIN nsMed.Doctors d ON d.doctorSpeciality = 'Невролог'
JOIN nsMed.Disease dis ON dis.diseaseName = 'Мигрень'
WHERE p.patientSurname = 'Петров';


-- 18
UPDATE nsMed.Patients
SET patientProfession = 'Программист'
WHERE patientId = 1;


-- 19
UPDATE nsMed.patientsCard
SET degreeOfSeverity = (
    SELECT AVG(degreeOfSeverity)
    FROM nsMed.patientsCard
)
WHERE patientCard = 1;


-- 20 
DELETE FROM nsMed.Patients
WHERE patientAddress IS NULL;


-- 21
DELETE FROM nsMed.Disease
WHERE diseaseId IN (
    SELECT dis.diseaseId
    FROM nsMed.Disease dis
    LEFT JOIN nsMed.patientsCard pc ON pc.diseaseId = dis.diseaseId
    WHERE pc.diseaseId IS NULL
);


-- 22 
WITH VisitCounts (doctorId, visitCount) AS (
    SELECT doctorId, COUNT(patientCard) AS visitCount
    FROM nsMed.patientsCard
    GROUP BY doctorId
)
SELECT doctorId, AVG(visitCount) AS avgVisits
FROM VisitCounts;


-- 23 
WITH PatientHierarchy (doctorId, patientId, level) AS (
    SELECT doctorId, patientId, 0 AS level
    FROM nsMed.patientsCard
    WHERE doctorId IS NOT NULL
    UNION ALL
    SELECT pc.doctorId, pc.patientId, ph.level + 1
    FROM nsMed.patientsCard pc
    INNER JOIN PatientHierarchy ph ON pc.doctorId = ph.patientId
)
SELECT doctorId, patientId, level
FROM PatientHierarchy;


-- 24 
SELECT doctorId,
       AVG(degreeOfSeverity) OVER (PARTITION BY doctorId) AS avgSeverity,
       MIN(degreeOfSeverity) OVER (PARTITION BY doctorId) AS minSeverity,
       MAX(degreeOfSeverity) OVER (PARTITION BY doctorId) AS maxSeverity
FROM nsMed.patientsCard;


-- 25 
WITH RankedCards AS (
    SELECT patientCard, patientId, doctorId, diseaseId, dataOfVisit,
           ROW_NUMBER() OVER (PARTITION BY patientId, doctorId, diseaseId, dataOfVisit ORDER BY patientCard) AS rowNum
    FROM nsMed.patientsCard
)
DELETE FROM nsMed.patientsCard
WHERE patientCard IN (
    SELECT patientCard
    FROM RankedCards
    WHERE rowNum > 1
);
