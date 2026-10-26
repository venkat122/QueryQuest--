# QueryQuest (Database Design)

**Author:** Venkata Sai Koppala
**Duration:** May '26 - Jul '26
**Organization:** ACA, IITK

## Project Overview

QueryQuest is a comprehensive database engineering project focused on designing, normalizing, and optimizing data schemas for two distinct domains: a Relational Hospital Management System and a NoSQL E-Commerce backend.

The primary objective was to ensure robust data integrity (ACID compliance where applicable), eliminate data redundancy through strict normalization, and achieve significant latency reductions under high query loads.

## Key Achievements & Outcomes

*   **Optimized Schemas:** Delivered robust relational models (PostgreSQL) and flexible document models (MongoDB Atlas).
*   **Performance Tuning:** Successfully benchmarked SQL queries, reducing overall query execution times by **up to 20%** by leveraging advanced indexing and structured CTEs.
*   **Scalability:** Designed a NoSQL architecture capable of handling high-write commerce operations by strategically applying CAP theorem principles.

## Repository Structure

### 1. `Hospital_PostgreSQL/`
Contains the artifacts for the Relational database design:
*   `ER_Diagram.md`: Visual representation of the entities and relationships.
*   `01_schema_normalized.sql`: DDL scripts creating tables normalized to 3NF/BCNF.
*   `02_performance_indexes.sql`: Indexing strategies to speed up data retrieval.
*   `03_advanced_queries.sql`: Complex analytical queries utilizing Window functions and CTEs.

### 2. `Commerce_MongoDB/`
Contains the artifacts for the NoSQL database design:
*   `collections_schema.js`: Document schema validation rules for MongoDB.
*   `cap_theorem_evaluation.md`: Architectural analysis justifying the NoSQL approach for high-write scenarios.

## Technical Stack
*   **Database Systems:** PostgreSQL, MongoDB Atlas
*   **Modeling Tools:** draw.io, Mermaid.js
*   **Concepts Applied:** 3NF/BCNF Normalization, ACID Compliance, CAP Theorem, Query Execution Plans, B-Tree/Hash Indexing, Window Functions, CTEs.
