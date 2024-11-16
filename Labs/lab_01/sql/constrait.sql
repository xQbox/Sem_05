alter table nsmed.Patients 
add constraint ck_patientData 
check (patientAddress is not null and patientProfession is not null);

alter table nsmed.Patients
add constraint ck_patientBirthday
check (patientDateOfBirthday <= current_date)

alter table nsmed.Doctors
add constraint ck_doctorsData
check (doctorExperience >= 1 and doctorExperience <= 110);

ALTER TABLE nsmed.Doctors
ADD CONSTRAINT ck_doctorsYear
CHECK (doctorDateOfBirthday + INTERVAL '22 years' <= CURRENT_DATE);

alter table nsmed.patientsCard
add constraint ck_patientsdegree
check (degreeOfSeverity >= 1 and degreeOfSeverity <= 5)

