-- ==============================================================================
-- QueryQuest: Hospital Management System Schema
-- Database: PostgreSQL
-- Normalization Target: 3NF / BCNF
-- ==============================================================================

-- 1. Patients Table
-- Primary entity for patient demographic data.
CREATE TABLE Patients (
    PatientID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10),
    ContactNumber VARCHAR(20),
    EmergencyContact VARCHAR(100)
);

-- 2. Departments Table
-- Lookup table to prevent transitive dependencies in the Doctors table.
-- E.g., instead of having DepartmentName and DepartmentFloor in Doctors, we link it.
CREATE TABLE Departments (
    DepartmentID SERIAL PRIMARY KEY,
    DepartmentName VARCHAR(100) UNIQUE NOT NULL,
    LocationFloor INT
);

-- 3. Doctors Table
-- Associates doctors with their specific department.
CREATE TABLE Doctors (
    DoctorID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialty VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    -- Foreign Key ensures referential integrity
    CONSTRAINT fk_department
      FOREIGN KEY(DepartmentID) 
      REFERENCES Departments(DepartmentID)
);

-- 4. Appointments Table
-- Represents the many-to-many relationship between Patients and Doctors over time.
-- This table is in 3NF as all attributes depend solely on AppointmentID.
CREATE TABLE Appointments (
    AppointmentID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    PatientID UUID NOT NULL,
    DoctorID UUID NOT NULL,
    AppointmentDateTime TIMESTAMP NOT NULL,
    Status VARCHAR(20) DEFAULT 'Scheduled', -- Scheduled, Completed, Canceled
    ReasonForVisit TEXT,
    CONSTRAINT fk_patient
      FOREIGN KEY(PatientID) 
      REFERENCES Patients(PatientID),
    CONSTRAINT fk_doctor
      FOREIGN KEY(DoctorID) 
      REFERENCES Doctors(DoctorID)
);

-- 5. MedicalRecords Table
-- Stores specific diagnoses tied to an appointment.
-- Separating this from Appointments keeps the schema in BCNF (preventing update anomalies if diagnoses change).
CREATE TABLE MedicalRecords (
    RecordID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    AppointmentID UUID UNIQUE NOT NULL, -- One-to-one relationship with a completed appointment
    Diagnosis TEXT NOT NULL,
    TreatmentPlan TEXT,
    PrescribedMedication TEXT,
    CONSTRAINT fk_appointment
      FOREIGN KEY(AppointmentID) 
      REFERENCES Appointments(AppointmentID)
);

-- Note on Normalization:
-- This schema adheres to BCNF because for every non-trivial functional dependency X -> Y, X is a superkey.
-- For example, in Appointments, (AppointmentDateTime, PatientID, DoctorID) are non-key attributes that depend entirely on the AppointmentID candidate key. There are no transitive dependencies (like having DoctorName inside the Appointments table).
