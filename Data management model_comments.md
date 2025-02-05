# Data Management System for AI Chatbot: Analysis and Overview

## 1. Introduction
This document outlines the design of a data management system for an AI chatbot that generates news and creates analysis reports. The goal is to structure the database efficiently while maintaining flexibility and scalability. The initial entity design has been reviewed, and the following refinements are proposed based on logical grouping, reducing redundancy, and ensuring efficient data retrieval.

---

## 2. Core Entities & Restructuring

### 2.1. User, Role & Organization  
#### Proposed Change: Merge `User`, `Role`, and `Org` into a single table called `User_Information` but retain `Role` as a separate entity.

#### Rationale:
- A user always belongs to an organization (tenant), so merging `User` and `Org` eliminates unnecessary joins.
- Keeping `Role` separate ensures users can have multiple roles without complicating the schema.

#### Final Schema:
**User_Information**
- user_id (UUID, primary key)
- username (string)
- email (string)
- name (string)
- org_id (UUID, foreign key, nullable for global users)
- organization_name (string)
- organization_domain (string, optional)
- configuration (JSON) – Org-specific settings
- role_id (UUID, foreign key) – Links to Role
- created_at (datetime)
- updated_at (datetime)

**Role** (Separate Table)
- role_id (UUID, primary key)
- name (string) (e.g., Admin, Analyst, User)
- permissions (JSON) (General and row-level permissions)
- created_at (datetime)
- updated_at (datetime)

---

### 2.2. Data Storage: Content, Analysis & Reporting
#### Proposed Change: Merge `Analysis_Result` into `Content` but keep reports separate if necessary.

#### Rationale:
- `Content` and `Analysis_Result` are tightly linked, making sense to store analysis metadata within `Content` rather than creating a separate table.
- Reports aggregate multiple content pieces, so keeping them separate avoids data duplication.

#### Final Schema:
**Content**
- content_id (UUID, primary key)
- source_id (UUID, foreign key)
- external_id (string)
- url_id (UUID, foreign key)
- title (string)
- author (string)
- published_at (datetime)
- content (text) – Raw content text
- content_formatted (text) – Formatted text for UI
- content_summary (text) – General LLM-generated summary
- short_snippet (text) – UI snippet
- language (string, ISO code)
- analysis_results (JSON) – Stores classification, keywords, misinformation ratio, hate degree, violations, rebuttals, etc.
- created_at (datetime)
- updated_at (datetime)

**Report** (Optional, if aggregation is needed)
- report_id (UUID, primary key)
- name (string)
- description (string)
- org_id (UUID, foreign key)
- configuration (JSON) – Report-specific settings
- created_at (datetime)
- updated_at (datetime)

---

### 2.3. Data Ingestion & Logging
#### Proposed Change: Merge `Scheduled_Task` into `Ingestion_Log` by adding scheduling metadata.

#### Rationale:
- A scheduled task’s execution will always produce an ingestion log, making them conceptually similar.
- Eliminating redundancy while tracking scheduling.

#### Final Schema:
**Ingestion_Log**
- log_id (UUID, primary key)
- source_id (UUID, foreign key)
- timestamp (datetime)
- query_name (string)
- query_params (JSON, optional)
- ingestion_type (string)
- status (string) (Success, Failure, etc.)
- message (text) (Error description, if any)
- records_processed (integer)
- data_volume (integer, bytes)
- scheduled (boolean)
- schedule_metadata (JSON) (Stores cron expression, next run timestamp, etc.)
- created_at (datetime)

---

### 2.4. Supporting Entities
#### Kept Separate for Functionality & Tracking

**Prompt_Config** – Essential for managing LLM prompt versions.
- prompt_config_id (UUID, primary key)
- system_message (text)
- temperature (float)
- templated_question_format (text)
- prompt_type (string)
- few_shot_examples (JSON)
- function_calling_config (JSON)
- version (integer)
- org_id (UUID, foreign key, optional)
- created_at (datetime)
- updated_at (datetime)

**Audit_Log** – Tracks system actions.
- log_id (UUID, primary key)
- user_id (UUID, foreign key)
- action (string)
- timestamp (datetime)
- details (JSON)
- ip_address (string)

**Feedback** – Allows users to provide input on analysis accuracy.
- feedback_id (UUID, primary key)
- analysis_result_id (UUID, foreign key)
- user_id (UUID, foreign key)
- rating (integer)
- comment (text)
- created_at (datetime)

---

## 3. Summary of Changes

| **Original Entity**         | **Action Taken**                      | **Final Design**                     |
|-----------------------------|--------------------------------------|--------------------------------------|
| User, Role, Org             | Merged `User` & `Org`, kept `Role` separate | `User_Information` & `Role`          |
| Analysis_Result & Content   | Merged into one table                 | `Content` with `analysis_results` JSON |
| Scheduled_Task & Ingestion_Log | Merged into one table                 | `Ingestion_Log` with scheduling metadata |
| Prompt_Config               | Kept Separate                        | `Prompt_Config`                      |
| Audit_Log                   | Kept Separate                        | `Audit_Log`                          |
| Feedback                    | Kept Separate                        | `Feedback`                           |

---

## 4. Conclusion
This revised schema enhances efficiency by reducing redundant joins, minimizing unnecessary data duplication, and improving maintainability. The key adjustments include:
- **Merging related entities** to streamline data retrieval (e.g., `User & Org`, `Analysis & Content`).
- **Maintaining key functional entities** to ensure flexibility (`Prompt_Config`, `Audit_Log`, etc.).
- **Optimizing scheduled tasks** by embedding them within ingestion logs.

This approach ensures a scalable and maintainable system while aligning with best practices for AI-driven data management.

### **Next Steps:**
- Implement and validate the schema with sample datasets.
- Optimize queries for fast retrieval.
- Ensure role-based access control (RBAC) is properly configured.
- Evaluate performance and iterate based on system load.

**What are your thoughts on this final structure?**
