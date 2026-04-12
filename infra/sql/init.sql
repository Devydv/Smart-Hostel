CREATE TABLE IF NOT EXISTS students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  roll_no VARCHAR(50),
  name VARCHAR(120) NOT NULL,
  gender VARCHAR(20),
  department VARCHAR(120),
  year VARCHAR(20),
  phone VARCHAR(30),
  email VARCHAR(150) UNIQUE,
  address TEXT
);

CREATE TABLE IF NOT EXISTS wardens (
  warden_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id VARCHAR(50),
  name VARCHAR(120) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(30),
  department VARCHAR(120),
  designation VARCHAR(120),
  joined_date DATE,
  address TEXT
);

CREATE TABLE IF NOT EXISTS admins (
  admin_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id VARCHAR(50),
  name VARCHAR(120) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(30),
  designation VARCHAR(120),
  joined_date DATE,
  address TEXT
);

CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('STUDENT', 'WARDEN', 'ADMIN') NOT NULL,
  linked_student_id INT NULL,
  linked_warden_id INT NULL,
  linked_admin_id INT NULL,
  CONSTRAINT fk_users_student FOREIGN KEY (linked_student_id) REFERENCES students(student_id) ON DELETE SET NULL,
  CONSTRAINT fk_users_warden FOREIGN KEY (linked_warden_id) REFERENCES wardens(warden_id) ON DELETE SET NULL,
  CONSTRAINT fk_users_admin FOREIGN KEY (linked_admin_id) REFERENCES admins(admin_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS rooms (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  room_number VARCHAR(20) NOT NULL UNIQUE,
  room_type VARCHAR(50),
  capacity INT NOT NULL,
  block VARCHAR(50),
  status ENUM('Available', 'Occupied', 'Maintenance') DEFAULT 'Available'
);

CREATE TABLE IF NOT EXISTS room_allocation (
  allocation_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  room_id INT NOT NULL,
  status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
  allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ra_room_status (room_id, status),
  INDEX idx_ra_student_status (student_id, status),
  UNIQUE KEY uq_ra_single_approved_per_student ((CASE WHEN status='Approved' THEN student_id ELSE NULL END)),
  UNIQUE KEY uq_ra_single_pending_per_student ((CASE WHEN status='Pending' THEN student_id ELSE NULL END)),
  CONSTRAINT fk_ra_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  CONSTRAINT fk_ra_room FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS complaints (
  complaint_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('Pending', 'Resolved', 'Escalated', 'Closed') DEFAULT 'Pending',
  level ENUM('Warden', 'Admin') DEFAULT 'Warden',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_complaints_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS fees (
  fee_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  amount DECIMAL(10, 2) DEFAULT 0,
  due_date DATE,
  payment_date DATE,
  payment_status ENUM('Pending', 'Paid') DEFAULT 'Pending',
  CONSTRAINT fk_fees_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('Present', 'Absent') NOT NULL,
  CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS food_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  partner_id VARCHAR(50),
  order_details TEXT,
  order_status ENUM('Pending', 'Accepted', 'Delivered', 'Cancelled') DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_food_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS announcements (
  announcement_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT IGNORE INTO students (roll_no, name, gender, department, year, phone, email, address)
VALUES ('STU001', 'Demo Student', 'Female', 'CSE', '2', '9000000001', 'student@smarthostel.com', 'Campus Hostel');

INSERT IGNORE INTO wardens (employee_id, name, email, phone, department, designation, joined_date, address)
VALUES ('WRD001', 'Demo Warden', 'warden@smarthostel.com', '9000000002', 'Boys Hostel', 'Hostel Warden', CURDATE(), 'Campus Quarters');

INSERT IGNORE INTO admins (employee_id, name, email, phone, designation, joined_date, address)
VALUES ('ADM001', 'Demo Admin', 'admin@smarthostel.com', '9000000003', 'Administrator', CURDATE(), 'Admin Block');

INSERT IGNORE INTO users (username, password, role, linked_student_id)
SELECT 'student@smarthostel.com', '123456', 'STUDENT', s.student_id
FROM students s WHERE s.email = 'student@smarthostel.com';

INSERT IGNORE INTO users (username, password, role, linked_warden_id)
SELECT 'warden@smarthostel.com', '123456', 'WARDEN', w.warden_id
FROM wardens w WHERE w.email = 'warden@smarthostel.com';

INSERT IGNORE INTO users (username, password, role, linked_admin_id)
SELECT 'admin@smarthostel.com', '123456', 'ADMIN', a.admin_id
FROM admins a WHERE a.email = 'admin@smarthostel.com';

INSERT IGNORE INTO rooms (room_number, room_type, capacity, block, status)
VALUES ('A-101', 'Double', 2, 'A', 'Available');

INSERT IGNORE INTO room_allocation (student_id, room_id, status)
SELECT s.student_id, r.room_id, 'Approved'
FROM students s, rooms r
WHERE s.email = 'student@smarthostel.com' AND r.room_number = 'A-101';

INSERT IGNORE INTO fees (student_id, amount, due_date, payment_date, payment_status)
SELECT s.student_id, 12000.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 'Pending'
FROM students s WHERE s.email = 'student@smarthostel.com';

INSERT IGNORE INTO announcements (title, message)
VALUES ('Welcome to SmartHostel', 'Your hostel portal is set up and ready to use.');
