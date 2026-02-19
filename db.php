<?php
$conn = mysqli_connect("localhost", "root", "", "student_result", 3307);

if (!$conn) {
    die("Database connection failed: " . mysqli_connect_error());
}
?>
