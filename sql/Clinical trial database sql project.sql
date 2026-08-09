CREATE TABLE Patients(
 patient_id SERIAL PRIMARY KEY,
 patient_name VARCHAR (100) NOT NULL,
 gender VARCHAR (10) NOT NULL,
 age INTEGER NOT NULL CHECK (age BETWEEN 18 AND 80),
 city VARCHAR(50) NOT NULL,
 country VARCHAR(50) DEFAULT 'India',
 enrollment_date DATE NOT NULL
);

CREATE TABLE study_sites(
 site_id SERIAL PRIMARY KEY,
 site_name VARCHAR (100) NOT NULL,
 city VARCHAR (50) NOT NULL,
 country VARCHAR (50) DEFAULT 'India',
 principal_investigator VARCHAR (100) NOT NULL
);
 SELECT * FROM patients;

CREATE TABLE visits (
 visit_id SERIAL PRIMARY KEY,
 patient_id INT NOT NULL,
 site_id INT NOT NULL,
 visit_date DATE NOT NULL,
 visit_type VARCHAR (20) NOT NULL CHECK (
    visit_type IN (
          'Screening',
		  'Baseline',
		  'Week 4',
		  'Week 8',
		  'Week 12'
	)
 ),
 visit_status VARCHAR(20) NOT NULL
 FOREIGN KEY (patient_id)
   REFERENCES patients(patient_id),

   FOREIGN KEY (site_id)
   REFERENCES study_sites(site_id)
   );

CREATE TABLE lab_results(
 lab_id SERIAL PRIMARY KEY,
 patient_id INT NOT NULL,
 visit_type INT NOT NULL,
 test_name VARCHAR(50) NOT NULL,
 result_value DECIMAL (6,2)
 FOREIGN KEY (patient_id)
   REFERENCES patients(patient_id),
 FOREIGN KEY (visit_id)
   REFERENCES visits(visit_id));

CREATE TABLE medications(
 medication_id SERIAL PRIMARY KEY,
 patient_id INT NOT NULL,
 medication_name VARCHAR(100) NOT NULL,
 dosage VARCHAR(30) NOT NULL,
 duration_date INT NOT NULL
 FOREIGN KEY (patient_id)
  REFERENCES patients(patient_id));
 

CREATE TABLE adverse_events(
 event_id SERIAL PRIMARY KEY,
 patient_id INT NOT NULL,
 event_name VARCHAR(100) NOT NULL,
 severity VARCHAR (20),
 event_date DATE NOT NULL,
 OUTCOME VARCHAR(50) NOT NULL
 CHECK (severity IN('Mild','Moderate','Severe')),
 FOREIGN KEY (patient_id)
  REFERENCES patients (patient_id)
);
---QUERIES 1-6 Data validation.
---1)How many records are available in each table of the clinical trial database?
SELECT 'patients' AS table_name, COUNT(*) AS total_records
FROM patients
UNION ALL
SELECT 'study_sites', COUNT(*)
FROM study_sites
UNION ALL
SELECT 'visits',COUNT(*)
FROM visits
UNION ALL
SELECT 'lab_results',COUNT(*)
FROM lab_results
UNION ALL
SELECT 'medications',COUNT(*)
FROM medications
UNION ALL
SELECT 'adverse_events',COUNT(*)
FROM adverse_events;

---2)Display sample records from the patients table to verify that the imported data is correct.
SELECT * FROM patients
LIMIT 5;

---3)Display sample records from visit table.
SELECT * FROM visits
LIMIT 5;

---4)Find are there any duplicate patient IDs exist.
SELECT
	patient_id,
	COUNT(*) AS Total_records
FROM patients
GROUP BY patient_id
HAVING COUNT(*) > 1;

---5)count the number of patient by gender.
SELECT 
	gender,
	COUNT(*) AS total_patients
FROM patients
GROUP BY gender;

---6)validate visit id.
SELECT 
	MIN(visit_id) AS Minimum_visit_id,
	MAX(visit_id) AS Maximum_visit_id,
	COUNT(*) AS Total_visits,
	COUNT(DISTINCT visit_id) AS unique_visit_ids
FROM visits;

---PHASE 2 SQL Analysis
---7)Display the ten oldest patients enrolled in the study.
SELECT 
	patient_id,
	patient_name,
	gender,
	age,
	city
FROM patients
ORDER BY age DESC
LIMIT 10;

---8)Display the five youngest patient enrolled in the study.
SELECT
	patient_id,
	patient_name,
	gender,
	age,
	city
FROM patients
ORDER BY age ASC
LIMIT 5;

---9)Count the number of visit for each visit type.
SELECT
	visit_type,
	COUNT(*) AS total_visits
FROM visits
GROUP BY visit_type
ORDER BY
CASE
	WHEN visit_type= 'Screening' THEN 1
	WHEN visit_type='Baseline' THEN 2
	WHEN visit_type='Week 4' THEN 3
	WHEN visit_type='Week 8'THEN 4
	ELSE 5
END;

---10)What is the average test for each laborartory result.
SELECT
	test_name,
	ROUND(AVG(result_value),2) AS Average_result
FROM lab_results
GROUP BY test_name
ORDER BY test_name;

---11)How many laboratory test performed for each patient.
SELECT
	patient_id,
	COUNT(*) AS total_lab_test
FROM lab_results
GROUP BY patient_id
ORDER BY total_lab_test DESC;

---12)How many patients are enrolled from each city.
SELECT
	city,
	COUNT(*) AS total_patients
FROM patients
GROUP BY city
ORDER BY total_patients DESC;

---13)Display patient details with their visit information.
SELECT
	p.patient_id,
	p.patient_name,
	p.gender,
	p.age,
	v.visit_type,
	v.visit_date,
	v.visit_status
FROM patients p
INNER JOIN visits v
ON p.patient_id=v.patient_id;

---14)Display each patient laboratory test result.
SELECT	
	p.patient_id,
	p.patient_name,
	p.gender,
	p.age,
	l.test_name,
	l.result_value
FROM patients p
INNER JOIN lab_results l
ON p.patient_id=l.patient_id;

---15)Display patients visits along with the study site.
SELECT
	p.patient_name,
	v.visit_date,
	v.visit_type,	
	s.site_name,
	s.city
FROM patients p
INNER JOIN visits v
ON p.patient_id=v.patient_id
INNER JOIN study_sites s
ON v.site_id=s.site_id
ORDER BY 
	p.patient_name,
	v.visit_date;

---16)Which patient visited which study site and what was the status of their visit.
SELECT
	p.patient_id,
	p.patient_name,
	s.site_name,
	v.visit_type,
	v.visit_date,
	v.visit_status
FROM patients p
INNER JOIN visits v
ON p.patient_id=v.patient_id
INNER JOIN study_sites s
ON v.site_id=s.site_id;

---17)Which patients completed their scheduled visit.
SELECT
	p.patient_id,
	p.patient_name,
	v.visit_type,
	v.visit_date,
	v.visit_status
FROM patients p
INNER JOIN visits v
ON p.patient_id=v.patient_id
WHERE v.visit_status='Completed';

---18)How many visits has each patient completed.
Select	
	p.patient_id,
	p.patient_name,
	COUNT(*) AS completed_visits
FROM patients p
INNER JOIN visits v
ON p.patient_id=v.patient_id
WHERE v.visit_status = 'Completed'
GROUP BY 
	p.patient_id,
	p.patient_name
ORDER BY completed_visits DESC;

---19)Show all patients who experienced an adverse events.
SELECT
	p.patient_id,
    p.patient_name,
	a.event_name,
	a.severity,
	a.outcome
FROM patients p
INNER JOIN adverse_events a
ON p.patient_id = a.patient_id;

---20)Find patients who have not experienced any adverse events.
SELECT
	p.patient_id,
	p.patient_name
FROM patients p
LEFT JOIN adverse_events a
ON p.patient_id = a.patient_id
WHERE a.patient_id IS NULL;

---21)Count the number of adverse events for each severity level.
SELECT
	Severity,
	COUNT(*) AS total_events
FROM adverse_events
GROUP BY Severity
ORDER BY total_events DESC;
	
---22)Display patients who have attended more than 4 visits.
SELECT	
	p.patient_id,
	p.patient_name,
	COUNT(*) AS total_visits
FROM patients p
INNER JOIN visits v
ON p.patient_id = v.patient_id
GROUP BY 
p.patient_id,
p.patient_name
HAVING COUNT(*) > 4;

---23)Find the average age of patients in each city.
SELECT
	city,
	ROUND(AVG(age),2) AS average_age
FROM patients
GROUP BY city
ORDER BY average_age DESC;

---24)Categorize patients into age groups(young,adult,middle age,senior).
SELECT
	patient_name,
	age,
	CASE
	WHEN age BETWEEN 18 AND 35 THEN 'Young adult'
	WHEN age BETWEEN 36 AND 55 THEN 'Middle age'
	ELSE 'Senior'
	END AS age_group
FROM patients
ORDER BY age;
	
---25)Find the highest and lowest patient age in the study
SELECT
	MAX(age) AS oldest_patient,
	MIN(age) AS youngest_patient
FROM patients;

---26)Find the average lab result for each test.
SELECT
	test_name,
	ROUND(AVG(result_value),2) AS average_result
FROM lab_results
GROUP BY test_name
ORDER BY test_name;

---27)Display all unique lab test performed.
SELECT DISTINCT
	test_name
FROM lab_results
ORDER BY test_name;

---28)Find all patients whose name starts with letter 'A'.
SELECT
	patient_id,
	patient_name,
	age,
	city
FROM patients
WHERE patient_name LIKE 'A%';

---29)Display all patients belonging to mumbai, delhi or pune.
SELECT	
	patient_id,
	patient_name,
	city,
	age
FROM patients
WHERE city IN ('Mumbai' , 'Delhi' , 'Pune');
	
---30)Find all patients whose age is between 30 and 50 years.
SELECT
	patient_name,
	age,
	city
FROM patients
WHERE age BETWEEN 30 AND 50;

---31)Find all patients older than the average age of all patients.
SELECT
	patient_id,
	patient_name,
	age,
	city
FROM patients
WHERE age >
( SELECT AVG(age)
FROM patients
);
	
---32)Find patients whose age is equal to the oldest patients age 
SELECT
	patient_id,
	patient_name,
	age
FROM patients
WHERE age =
(
 SELECT MAX(age)
 FROM patients
);

---33)Find lab reults that are higher then the overall average lab result
SELECT
	patient_id,
	test_name,
	result_value
FROM lab_results
WHERE result_value >
(
	SELECT AVG(result_value)
	FROM lab_results
);

---34)Find patients who have atleast one lab results.
SELECT
	patient_id,
	patient_name
FROM patients
WHERE patient_id IN
( SELECT  patient_id
FROM lab_results
     );

---35)Find patients whose age is greater than the overall average patient age.
SELECT
	patient_id,
	patient_name,
	age
FROM patients
WHERE age >
( SELECT AVG(age)
FROM patients
);

---36)Create a temporary table showing patients older than 50 years.
WITH senior_patients AS 
(      SELECT
			patient_id,
			patient_name,
			age
		FROM patients
		WHERE age > 50
     	)
		SELECT * FROM
		senior_patients
		ORDER BY age DESC;
---OR
SELECT 
	patient_id,
	patient_name,
	age
FROM patients
WHERE age > 50
ORDER BY age DESC;

---37)Find the average age using CTE.
WITH average_age AS
(  SELECT AVG(age) AS avg_age
	FROM patients)

SELECT
	p.patient_name,
	p.age,
	a.avg_age
FROM patients p
CROSS JOIN average_age a
ORDER BY p.age DESC;

---38)Find patients whose number of visit is greater then the average number of visits among all patients.
WITH patient_visits AS
(    SELECT
		patient_id,
		COUNT(*) AS total_visits
		FROM visits
		GROUP BY patient_id
		)
		SELECT * 
		FROM patient_visits
		WHERE total_visits >
		(     SELECT AVG(total_visits)
				FROM patient_visits)
				ORDER BY total_visits DESC;


---39)Find the total number of lab test perfromed by each patients.
SELECT	
	patient_id,
COUNT(*) AS total_test
FROM lab_results
GROUP BY patient_id
ORDER BY patient_id ASC;
--OR
WITH patient_lab_tests AS
(SELECT	
	patient_id,
COUNT(*) AS total_tests
FROM lab_results
GROUP BY patient_id
)
SELECT 
	patient_id,
	total_tests
FROM patient_lab_tests
ORDER BY total_tests DESC, patient_id;

---40)Find patients who have completed more lab test then the average patients.
WITH patient_lab_tests AS
(
	SELECT 
		patient_id,
		COUNT(*) AS total_tests
	FROM lab_results
	GROUP BY patient_id
)
SELECT
	patient_id,
	total_tests
FROM patient_lab_tests
WHERE total_tests >
(
	SELECT AVG(total_tests)
	FROM patient_lab_tests
)
ORDER BY total_tests DESC;

---41)Create a reusable report showing every patients vists details.
CREATE VIEW patient_visit_report AS
SELECT
	p.patient_id,
	p.patient_name,
	s.site_name,
	v.visit_type,
	v.visit_date,
	v.visit_status
FROM patients p
INNER JOIN visits v
ON p.patient_id = v.patient_id
INNER JOIN study_sites s
ON v.site_id = s.site_id;
---To view the data
SELECT * FROM patient_visit_report;

---42)Create a reusable report of lab test results.
CREATE VIEW lab_report AS
SELECT
     patient_id,
	 visit_type,
	 test_name,
	 result_value
FROM lab_results;
---To retrieve the data.
SELECT * FROM lab_report
ORDER BY patient_id,test_name;

---43)Create a reusable report showing all the adverse events along with patient details.
CREATE VIEW adverse_events_reports AS
SELECT
	p.patient_id,
	p.patient_name,
	p.age,
	a.event_name,
	a.severity,
	a.event_date,
	a.outcome
FROM patients p
INNER JOIN adverse_events a
ON p.patient_id = a.patient_id;
--TO view the data.
SELECT * FROM adverse_events_reports;

---44)Create a reusable report showing patient demographics.
CREATE VIEW patients_demographics AS
SELECT
	patient_id,
	patient_name,
	gender,
	age,
	city,
	country
FROM patients;
---To retrieve the data.
SELECT * FROM patients_demographics;

--45)List all views created in this table.
SELECT
	table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

---46)Rank patients from oldest to youngest based on age.
SELECT
	patient_id,
	patient_name,
	age,
	ROW_NUMBER() OVER(ORDER BY age DESC)AS age_rank
FROM patients;

---47)Rank lab results from highest to lowest within each lab test.
SELECT
	patient_id,
	test_name,
	result_value,
	ROW_NUMBER()OVER
	(
		PARTITION BY test_name
		ORDER BY result_value DESC
	)AS test_rank
FROM lab_results;

---48) Rank patients by age, but assign the same rank to patients who have the same age.
SELECT
	patient_id,
	patient_name,
	age,
	RANK() OVER (ORDER BY age DESC) AS age_rank
FROM patients;

---49)Rank Patients by age without skipping rank numbers when there is a tie.
SELECT
	patient_id,
	patient_name,
	age,
	DENSE_RANK() OVER(ORDER BY age DESC) AS age_dense_rank
FROM patients;

---50)Assign a sequence number to lab test results within each test type.
SELECT
	patient_id,
	test_name,
	result_value,
	ROW_NUMBER() OVER
	(
		PARTITION BY test_name
		ORDER BY result_value DESC
		) AS Test_sequence
FROM lab_results;

---51)How many patients have been enrolled in the clinical trial by gender?
SELECT
	gender,
	COUNT(*) AS total_patients
FROM patients
GROUP BY gender
ORDER BY total_patients DESC;

---52)How many patients are enrolled at each study site?
SELECT
	s.site_id,
	s.site_name,
	s.city,
	COUNT ( DISTINCT v.patient_id) AS total_patients
FROM study_sites s
INNER JOIN visits v
ON s.site_id = v.site_id
GROUP BY
s.site_id,
s.site_name,
s.city
ORDER BY total_patients DESC;

---53)How many clinicl trials visits are in each visit status.
SELECT
	visit_status,
	COUNT(*) AS total_visits
FROM visits
GROUP BY 
	visit_status
ORDER BY total_visits DESC;

---54)Calculate the total number of lab results and average result value for each test.
SELECT
	test_name,
	COUNT(*) AS total_results,
	ROUND(AVG(result_value),2) AS average_result
FROM lab_results
GROUP BY test_name
ORDER BY total_results DESC;

---55)Calculate the number of adverse events for each severity level.
SELECT
	severity,
	COUNT(*) AS total_events
FROM adverse_events
GROUP BY 	
	severity
ORDER BY total_events DESC;

---56)Calculate the number of patients who recieved each medication.
SELECT 
	medication_name,
	COUNT(DISTINCT patient_id) AS total_patients
FROM medications
GROUP BY 
medication_name
ORDER BY total_patients DESC;

---57)calculate key clinical trial KPIs.
SELECT
	(SELECT COUNT(*) FROM patients) AS total_patients,
	(SELECT COUNT(*) FROM study_sites) AS total_sites,
	(SELECT COUNT(*) FROM visits) AS total_visits,
	(SELECT COUNT(*) FROM lab_results) AS total_lab_results,
    (SELECT COUNT(*) FROM medications) AS total_medications,
	(SELECT COUNT(*) FROM adverse_events) AS total_adverse_events;
	
---58)Summarize adverse events by thier outcome.
SELECT
	outcome,
	COUNT(*) AS total_events
FROM adverse_events
GROUP BY 
	outcome
ORDER BY total_events DESC;

---59)Analyze total and completed visits for each study sites.
SELECT
	s.site_id,
	s.site_name,
	s.city,
	COUNT(v.visit_id) AS total_visits,
	COUNT(
		CASE
			WHEN v.visit_status = 'Completed' THEN 1
			END
	) AS completed_visits
FROM study_sites s 
INNER JOIN visits v
	ON s.site_id = v.site_id
GROUP BY 
	s.site_id,
	s.site_name,
	s.city
ORDER BY completed_visits DESC;

---60)Create a patients level clinical trial summary showing visits and adverse events.
SELECT
	p.patient_id,
	p.patient_name,
	COUNT (DISTINCT v.visit_id) AS total_visits,
	COUNT(DISTINCT a.event_id) AS total_adverse_events
FROM patients p
LEFT JOIN visits v
	ON p.patient_id = v.patient_id
LEFT JOIN adverse_events a
    ON p.patient_id = a.patient_id
GROUP BY 
	p.patient_id,
	p.patient_name
ORDER BY
	p.patient_id;


















































































































	































































	







































































	






























































 