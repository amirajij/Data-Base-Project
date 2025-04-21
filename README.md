# 📄 SGD - Document Management System (Database Project)

This project consists of designing and implementing a **Document Management System (SGD)** for a company, supporting both traditional and digital communication. It was developed as part of the **Databases course** at Universidade Lusófona (2024/2025), guided by professors João Caldeira and Luís Alexandre Gomes.

---

## 🎯 Project Goals

- Digitally manage the receipt, cataloging, classification, routing, and archiving of institutional documents.
- Handle multiple document types (e.g., invoices, certificates, memos) and their workflows.
- Ensure traceability of actions through system logs and notifications.
- Support process rules, deadlines, escalations, and conditional actions.
- Comply with normalization principles and relational database standards.

---

## 🧱 Project Structure

### 📌 Phase 1 — Data Modeling

- ✅ **Entity identification** with descriptions
- ✅ **E-R Diagram** (Chen notation)
- ✅ **Relational model** (physical schema)
- ✅ **Normalization** up to 3NF
- ✅ **DDL SQL script** to create the database
- ✅ **Constraints** to enforce business rules

### 📌 Phase 2 — Data Population and Queries

- ✅ **Static data** insertion (document types, users, organizational units, etc.)
- ✅ **Sample documents** with different states and workflows
- ✅ **Custom rules** for invoices and certificates
- ✅ **SQL SELECT statements** for:
  - Filtering by date, state, UO
  - Listing complete document workflows
  - Viewing logs and notifications

### 📌 Phase 3 — Advanced Logic (Views, Functions, Procedures, Triggers)

- ✅ **Views**:
  - Archived documents
  - Recent documents (last 30 days)
  - Documents by type and department
- ✅ **Functions**:
  - Retrieve full history of a document
  - Get last known state
  - Count documents per state
- ✅ **Stored Procedures**:
  - List confidential documents
  - List current documents by department
  - Count historical actions
- ✅ **Triggers**:
  - Soft delete (flag hidden = true)
  - Logging changes automatically
  - Blockchain-like chaining of entries

---

## 💾 Technologies Used

- **MySQL / MariaDB**  
- SQL (DDL, DML, Views, Functions, Procedures, Triggers)  
- E-R Diagram: Drawn in Canvas and Miro.
- PDF and PNG files for diagrams and deliverables
