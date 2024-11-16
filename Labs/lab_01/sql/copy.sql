COPY nsMed.Disease(diseaseId, diseaseName, diseaseClass, diseaseType, diseaseTreatment)
FROM 'E:\\Baumana\\Baumana\\SEM_5\\Databases\\Labs\\lab_01\\data\\diseases.csv' DELIMITER ',' CSV HEADER;

COPY nsMed.Doctors (doctorId, doctorSurname, doctorName, doctorSecondSurname, doctorDateOfBirthday, doctorSpeciality, doctorExperience)
FROM 'E:/Baumana/Baumana/SEM_5/Databases/Labs/lab_01/data/doctors.csv' DELIMITER ',' CSV HEADER;

COPY nsMed.Patients (patientId, patientSurname, patientName, patientSecondSurname, patientDateOfBirthday, patientAddress, patientProfession, patientSex)
FROM 'E:/Baumana/Baumana/SEM_5/Databases/Labs/lab_01/data/patients.csv' DELIMITER ',' CSV HEADER;


COPY nsMed.patientsCard (patientId, doctorId, diseaseId, dataOfVisit, symptoms, degreeOfSeverity)
FROM 'E:/Baumana/Baumana/SEM_5/Databases/Labs/lab_01/data/patientsCard.csv' DELIMITER ',' CSV HEADER;

