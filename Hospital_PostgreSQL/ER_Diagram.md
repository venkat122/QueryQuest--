# Entity-Relationship Diagram: Hospital Management System

This diagram visualizes the relational schema designed in `01_schema_normalized.sql`. It illustrates the entities, their attributes, and the cardinalities of their relationships, adhering to 3NF/BCNF normalization standards.

```mermaid
erDiagram
    PATIENTS {
        uuid PatientID PK
        string FirstName
        string LastName
        date DateOfBirth
        string Gender
        string ContactNumber
    }
    
    DEPARTMENTS {
        int DepartmentID PK
        string DepartmentName UK
        int LocationFloor
    }
    
    DOCTORS {
        uuid DoctorID PK
        string FirstName
        string LastName
        string Specialty
        int DepartmentID FK
    }
    
    APPOINTMENTS {
        uuid AppointmentID PK
        uuid PatientID FK
        uuid DoctorID FK
        datetime AppointmentDateTime
        string Status
        string ReasonForVisit
    }
    
    MEDICAL_RECORDS {
        uuid RecordID PK
        uuid AppointmentID FK "UK - One-to-One"
        string Diagnosis
        string TreatmentPlan
        string PrescribedMedication
    }

    %% Relationships
    DEPARTMENTS ||--|{ DOCTORS : "employs"
    PATIENTS ||--|{ APPOINTMENTS : "books"
    DOCTORS ||--|{ APPOINTMENTS : "conducts"
    APPOINTMENTS ||--|| MEDICAL_RECORDS : "generates"
```

## Relationship Details
*   **One-to-Many (1:N):** One Department can have many Doctors.
*   **One-to-Many (1:N):** One Patient can have many Appointments over time.
*   **One-to-Many (1:N):** One Doctor conducts many Appointments.
*   **One-to-One (1:1):** One completed Appointment generates exactly one Medical Record. (This isolates diagnosis data from the scheduling data, preserving BCNF).
