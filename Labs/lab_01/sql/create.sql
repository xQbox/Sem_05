-- Active: 1730230325476@@127.0.0.1@5432@medicine_center@public
CREATE SCHEMA nsMed;

CREATE TABLE IF NOT EXISTS nsMed.Patients (
    patientId SERIAL PRIMARY KEY,
    patientSurname VARCHAR(30) NOT NULL,
    patientName VARCHAR(30) NOT NULL,
    patientSecondSurname VARCHAR(30),
    patientDateOfBirthday DATE,
    patientAddress VARCHAR(50),
    patientProfession VARCHAR(30),
    patientSex CHAR(1) CHECK (patientSex IN ('М', 'Ж'))
);
CREATE TABLE IF NOT EXISTS nsMed.Doctors (
    doctorId SERIAL PRIMARY KEY,
    doctorSurname VARCHAR(30) NOT NULL,
    doctorName VARCHAR(30) NOT NULL,
    doctorSecondSurname VARCHAR(30),
    doctorDateOfBirthday DATE,
    doctorSpeciality VARCHAR(30) NOT NULL,
    doctorExperience INTEGER
);

CREATE TABLE IF NOT EXISTS nsMed.Disease (
    diseaseId SERIAL PRIMARY KEY,
    diseaseName VARCHAR(30) NOT NULL,
    diseaseClass VARCHAR(30) NOT NULL,
    diseaseType VARCHAR(30) NOT NULL,
    diseaseTreatment VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS nsMed.patientsCard (
    patientCard SERIAL PRIMARY KEY,
    patientId INT REFERENCES nsMed.Patients(patientId) ON DELETE CASCADE,
    doctorId INT REFERENCES nsMed.Doctors(doctorId) ON DELETE SET NULL,
    diseaseId INT REFERENCES nsMed.Disease(diseaseId) ON DELETE SET NULL,
    dataOfVisit DATE DEFAULT CURRENT_DATE,
    symptoms TEXT,
    degreeOfSeverity INTEGER,
    UNIQUE (patientId, doctorId, diseaseId, dataOfVisit) 
);
