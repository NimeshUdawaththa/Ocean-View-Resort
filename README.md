# 🌊 OceanView Resort Hotel Management System

![CI](https://github.com/NimeshUdawaththa/Ocean-View-Resort/actions/workflows/ci.yml/badge.svg)

> 🔗 GitHub Repository: https://github.com/NimeshUdawaththa/Ocean-View-Resort

A dynamic web-based *Hotel Management System* designed for the *OceanView Resort*.  
The system streamlines operations for three key roles: *Admin, Manager, and Reception*, providing role-based dashboards and full hotel management functionalities.

## 🚀 Key Features
- 🔑 *Role Management* – Admin, Manager, and Reception dashboards  
- 👥 *Guest Management* – Register, update, search, and manage guest records  
- 🛏️ *Room Management* – Add and manage rooms (Standard, Deluxe, Suite, Ocean View)  
- 📅 *Reservation System* – Create reservations, check-in, check-out, and cancel bookings  
- 🧾 *Billing System* – Auto-calculated bills with 10% tax and printable invoice  
- 📧 *Email Notifications* – Automated emails on booking confirmation and cancellation  
- ⏰ *Auto-Expiry Scheduler* – Automatically marks expired reservations at midnight  
- 📊 *Reports* – Occupancy and revenue reports (Admin/Manager only)  
- ✅ *Testing & CI/CD* – 83 unit tests with JUnit 5, GitHub Actions for automated workflow  

## 🛠️ Tech Stack
- *Backend:* Java 21, Jakarta Servlets 6.1, JSP 3.1, JDBC  
- *Database:* MySQL 8.0  
- *Libraries:* Jakarta Mail (Email), Gson (JSON)  
- *Architecture:* MVC + DAO + Service pattern  
- *Testing:* JUnit Jupiter 5.13.2, Mockito 5.11.0  
- *Tools:* Apache Maven, Apache Tomcat 10, GitHub Actions (CI/CD)  

## 📂 Project Structure
- `src/main/java/` → controller, dao, dto, model, service, util  
- `src/main/webapp/` → `index.jsp` (login), `views/` (role dashboards), `WEB-INF/`  
- `src/test/java/` → model, dto, and service validation tests  
- `src/main/resources/db/schema.sql` → Database schema  
- `.github/workflows/ci.yml` → CI/CD pipeline  

## 👥 Role-Based Access
- *Admin* – Full access: users, rooms, guests, reservations, reports  
- *Manager* – Rooms, guests, reservations, reports (no user management)  
- *Reception* – Guests and reservations only  

## 🧪 Unit Tests (83 Tests — All Passing)
- *Model Tests:* GuestTest, RoomTest, ReservationModelTest, UserModelTest  
- *DTO Tests:* BillDTOTest  
- *Service Validation Tests:* GuestServiceValidationTest, RoomServiceValidationTest, ReservationServiceValidationTest  
- *Annotations used:* `@Test`, `@BeforeEach`, `@DisplayName`  

## ⚙️ CI/CD Pipeline
Configured in `.github/workflows/ci.yml` — triggers on every push/PR to `main` or `dev`:  
1. Spins up a MySQL 8.0 service container  
2. Sets up JDK 21 (Temurin)  
3. Initialises the database schema  
4. Runs `./mvnw test`     
