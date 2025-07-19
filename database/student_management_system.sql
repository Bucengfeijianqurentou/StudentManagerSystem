-- 学生管理系统数据库表结构
-- 创建数据库

-- 1. 用户表（支持学生、教师、管理员多角色）
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码（加密存储）',
    role ENUM('STUDENT', 'TEACHER', 'ADMIN') NOT NULL COMMENT '用户角色',
    status TINYINT DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '用户表';

-- 2. 班级表
CREATE TABLE classes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '班级ID',
    class_name VARCHAR(50) NOT NULL COMMENT '班级名称',
    grade VARCHAR(20) NOT NULL COMMENT '年级',
    class_teacher_id BIGINT COMMENT '班主任ID',
    student_count INT DEFAULT 0 COMMENT '学生人数',
    description TEXT COMMENT '班级描述',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_grade (grade),
    INDEX idx_class_teacher (class_teacher_id)
) COMMENT '班级表';

-- 3. 学生表
CREATE TABLE students (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学生ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '关联用户ID',
    student_no VARCHAR(20) NOT NULL UNIQUE COMMENT '学号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    gender ENUM('MALE', 'FEMALE') NOT NULL COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    class_id BIGINT COMMENT '班级ID',
    phone VARCHAR(20) COMMENT '联系电话',
    email VARCHAR(100) COMMENT '邮箱',
    address TEXT COMMENT '家庭地址',
    enrollment_date DATE COMMENT '入学日期',
    status ENUM('ACTIVE', 'SUSPENDED', 'GRADUATED') DEFAULT 'ACTIVE' COMMENT '学籍状态',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL,
    INDEX idx_student_no (student_no),
    INDEX idx_name (name),
    INDEX idx_class (class_id)
) COMMENT '学生表';

-- 4. 教师表
CREATE TABLE teachers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '教师ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '关联用户ID',
    teacher_no VARCHAR(20) NOT NULL UNIQUE COMMENT '工号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    gender ENUM('MALE', 'FEMALE') NOT NULL COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    phone VARCHAR(20) COMMENT '联系电话',
    email VARCHAR(100) COMMENT '邮箱',
    department VARCHAR(100) COMMENT '所属部门',
    title VARCHAR(50) COMMENT '职称',
    hire_date DATE COMMENT '入职日期',
    status ENUM('ACTIVE', 'RESIGNED') DEFAULT 'ACTIVE' COMMENT '在职状态',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_teacher_no (teacher_no),
    INDEX idx_name (name)
) COMMENT '教师表';

-- 5. 科目表
CREATE TABLE subjects (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '科目ID',
    subject_name VARCHAR(50) NOT NULL COMMENT '科目名称',
    subject_code VARCHAR(20) NOT NULL UNIQUE COMMENT '科目代码',
    credits DECIMAL(3,1) DEFAULT 1.0 COMMENT '学分',
    description TEXT COMMENT '科目描述',
    status TINYINT DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_subject_code (subject_code)
) COMMENT '科目表';

-- 6. 教师任课表（教师与科目、班级的关联）
CREATE TABLE teacher_courses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    teacher_id BIGINT NOT NULL COMMENT '教师ID',
    class_id BIGINT NOT NULL COMMENT '班级ID',
    subject_id BIGINT NOT NULL COMMENT '科目ID',
    semester VARCHAR(20) NOT NULL COMMENT '学期',
    academic_year VARCHAR(20) NOT NULL COMMENT '学年',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    UNIQUE KEY uk_teacher_class_subject (teacher_id, class_id, subject_id, semester, academic_year),
    INDEX idx_teacher (teacher_id),
    INDEX idx_class (class_id),
    INDEX idx_subject (subject_id)
) COMMENT '教师任课表';

-- 7. 成绩表
CREATE TABLE scores (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成绩ID',
    student_id BIGINT NOT NULL COMMENT '学生ID',
    subject_id BIGINT NOT NULL COMMENT '科目ID',
    teacher_id BIGINT NOT NULL COMMENT '任课教师ID',
    semester VARCHAR(20) NOT NULL COMMENT '学期',
    academic_year VARCHAR(20) NOT NULL COMMENT '学年',
    score DECIMAL(5,2) COMMENT '成绩',
    grade_level ENUM('A', 'B', 'C', 'D', 'F') COMMENT '等级',
    exam_type ENUM('MIDTERM', 'FINAL', 'QUIZ', 'ASSIGNMENT') DEFAULT 'FINAL' COMMENT '考试类型',
    remarks TEXT COMMENT '备注',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    UNIQUE KEY uk_student_subject_exam (student_id, subject_id, semester, academic_year, exam_type),
    INDEX idx_student (student_id),
    INDEX idx_subject (subject_id),
    INDEX idx_semester (semester, academic_year)
) COMMENT '成绩表';

-- 8. 系统日志表
CREATE TABLE system_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT COMMENT '操作用户ID',
    operation VARCHAR(100) NOT NULL COMMENT '操作类型',
    module VARCHAR(50) NOT NULL COMMENT '操作模块',
    description TEXT COMMENT '操作描述',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_operation (operation),
    INDEX idx_created_time (created_time)
) COMMENT '系统日志表';

-- 添加班级表的外键约束
ALTER TABLE classes ADD FOREIGN KEY (class_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL;

-- 插入初始数据
-- 插入管理员用户
INSERT INTO users (username, password, role) VALUES 
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8ioctKk7Z4oc6YdCyOGGKQjKOKOGi', 'ADMIN'); -- 密码: admin123

-- 插入默认科目
INSERT INTO subjects (subject_name, subject_code, credits) VALUES 
('语文', 'CHN001', 3.0),
('数学', 'MATH001', 3.0),
('英语', 'ENG001', 3.0),
('物理', 'PHY001', 2.0),
('化学', 'CHE001', 2.0),
('生物', 'BIO001', 2.0),
('历史', 'HIS001', 2.0),
('地理', 'GEO001', 2.0),
('政治', 'POL001', 2.0);

-- 创建索引优化查询性能
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_students_status ON students(status);
CREATE INDEX idx_teachers_status ON teachers(status);
CREATE INDEX idx_scores_score ON scores(score);