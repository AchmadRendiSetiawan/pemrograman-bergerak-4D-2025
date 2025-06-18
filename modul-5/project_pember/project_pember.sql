-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 16, 2025 at 06:52 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `project_pember`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings_fotografer`
--

CREATE TABLE `bookings_fotografer` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `photographer` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `duration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings_fotografer`
--

INSERT INTO `bookings_fotografer` (`id`, `email`, `photographer`, `date`, `time`, `duration`) VALUES
(1, 'rendi@gmail.com', 'Fotografer C', '2025-05-22', '05:25:00', 2),
(2, 'rendi0990@gmail.com', 'Fotografer B', '2025-05-23', '05:20:00', 3);

-- --------------------------------------------------------

--
-- Table structure for table `bookings_kamera`
--

CREATE TABLE `bookings_kamera` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `camera_type` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `duration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings_kamera`
--

INSERT INTO `bookings_kamera` (`id`, `email`, `camera_type`, `date`, `duration`) VALUES
(1, 'rendi@gmail.com', 'Sony A7 III', '2025-05-23', 3);

-- --------------------------------------------------------

--
-- Table structure for table `bookings_studio`
--

CREATE TABLE `bookings_studio` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `studio_name` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `duration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings_studio`
--

INSERT INTO `bookings_studio` (`id`, `email`, `studio_name`, `date`, `time`, `duration`) VALUES
(1, 'w@gmail.com', 'Studio B', '2025-05-22', '04:20:00', 5);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings_fotografer`
--
ALTER TABLE `bookings_fotografer`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bookings_kamera`
--
ALTER TABLE `bookings_kamera`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bookings_studio`
--
ALTER TABLE `bookings_studio`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings_fotografer`
--
ALTER TABLE `bookings_fotografer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `bookings_kamera`
--
ALTER TABLE `bookings_kamera`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `bookings_studio`
--
ALTER TABLE `bookings_studio`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
