-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 19, 2026 at 03:41 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `student_result`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_marks` (IN `sid` INT, IN `sub` VARCHAR(30), IN `m` INT)   BEGIN
    -- Exception handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error while inserting marks';
    END;

    INSERT INTO marks(student_id, subject, marks)
    VALUES (sid, sub, m);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `class_result` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE sid INT;

    DECLARE cur CURSOR FOR
        SELECT student_id FROM student;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO sid;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SELECT * FROM result WHERE student_id = sid;
    END LOOP;

    CLOSE cur;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `calculate_grade` (`p` DECIMAL(5,2)) RETURNS VARCHAR(5) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE g VARCHAR(5);

    IF p >= 75 THEN
        SET g = 'A';
    ELSEIF p >= 60 THEN
        SET g = 'B';
    ELSEIF p >= 40 THEN
        SET g = 'C';
    ELSE
        SET g = 'F';
    END IF;

    RETURN g;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_grade` (`p_percent` DECIMAL(5,2)) RETURNS VARCHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE g VARCHAR(2);

    IF p_percent >= 75 THEN
        SET g = 'A';
    ELSEIF p_percent >= 60 THEN
        SET g = 'B';
    ELSEIF p_percent >= 40 THEN
        SET g = 'C';
    ELSE
        SET g = 'F';
    END IF;

    RETURN g;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `marks`
--

CREATE TABLE `marks` (
  `mark_id` int(11) NOT NULL,
  `student_id` int(11) DEFAULT NULL,
  `subject` varchar(30) DEFAULT NULL,
  `marks` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `marks`
--

INSERT INTO `marks` (`mark_id`, `student_id`, `subject`, `marks`) VALUES
(1, 2, 'DBMS', 99),
(2, 2, 'Java', 88),
(3, 2, 'ERP', 67),
(4, 2, 'Python', 77),
(5, 2, 'Maths', 99),
(6, 4, 'DBMS', 87),
(7, 4, 'Java', 88),
(8, 4, 'ERP', 77),
(9, 4, 'Python', 67),
(10, 4, 'Maths', 90);

--
-- Triggers `marks`
--
DELIMITER $$
CREATE TRIGGER `after_marks_insert` AFTER INSERT ON `marks` FOR EACH ROW BEGIN
    DECLARE total_marks INT;
    DECLARE percent DECIMAL(5,2);

    SELECT SUM(marks)
    INTO total_marks
    FROM marks
    WHERE student_id = NEW.student_id;

    SET percent = (total_marks / 500) * 100;

    INSERT INTO result(student_id, total, percentage, grade)
    VALUES (
        NEW.student_id,
        total_marks,
        percent,
        get_grade(percent)
    )
    ON DUPLICATE KEY UPDATE
        total = total_marks,
        percentage = percent,
        grade = get_grade(percent);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_marks_insert` BEFORE INSERT ON `marks` FOR EACH ROW BEGIN
    DECLARE sub_count INT;

    SELECT COUNT(*)
    INTO sub_count
    FROM marks
    WHERE student_id = NEW.student_id;

    IF sub_count >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only 5 subjects allowed per student';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `generate_result` AFTER INSERT ON `marks` FOR EACH ROW BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE m INT;
    DECLARE total_marks INT DEFAULT 0;
    DECLARE subject_count INT DEFAULT 0;
    DECLARE percent DECIMAL(5,2);
    DECLARE final_grade VARCHAR(5);

    -- Cursor declaration
    DECLARE mark_cursor CURSOR FOR
        SELECT marks FROM marks WHERE student_id = NEW.student_id;

    -- Handler for cursor end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN mark_cursor;

    read_loop: LOOP
        FETCH mark_cursor INTO m;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET total_marks = total_marks + m;
        SET subject_count = subject_count + 1;
    END LOOP;

    CLOSE mark_cursor;

    SET percent = (total_marks / (subject_count * 100)) * 100;
    SET final_grade = calculate_grade(percent);

    INSERT INTO result(student_id, total, percentage, grade)
    VALUES (NEW.student_id, total_marks, percent, final_grade)
    ON DUPLICATE KEY UPDATE
        total = total_marks,
        percentage = percent,
        grade = final_grade;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `result`
--

CREATE TABLE `result` (
  `student_id` int(11) NOT NULL,
  `total` int(11) DEFAULT NULL,
  `percentage` decimal(5,2) DEFAULT NULL,
  `grade` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `result`
--

INSERT INTO `result` (`student_id`, `total`, `percentage`, `grade`) VALUES
(2, 430, 86.00, 'A'),
(4, 409, 81.80, 'A');

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `student_id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `class` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`student_id`, `name`, `class`) VALUES
(1, 'Nishan', 'SYBCA-B'),
(2, 'Nishan', 'TYBCA-C'),
(3, 'Nishan', 'SYBCA-B'),
(4, 'karan', 'TYBCA-C'),
(5, 'Sumit', 'TYBCA-C');

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `subject_id` int(11) NOT NULL,
  `subject_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`subject_id`, `subject_name`) VALUES
(1, 'DBMS'),
(3, 'ERP'),
(2, 'Java'),
(5, 'Maths'),
(4, 'Python');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `marks`
--
ALTER TABLE `marks`
  ADD PRIMARY KEY (`mark_id`);

--
-- Indexes for table `result`
--
ALTER TABLE `result`
  ADD PRIMARY KEY (`student_id`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`student_id`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`subject_id`),
  ADD UNIQUE KEY `subject_name` (`subject_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `marks`
--
ALTER TABLE `marks`
  MODIFY `mark_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `student`
--
ALTER TABLE `student`
  MODIFY `student_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
