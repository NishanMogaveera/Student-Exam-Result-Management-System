<?php
session_start();
include "db.php";

/* ---------- HANDLE FORM FIRST ---------- */

$message = "";

if (isset($_POST['set_student'])) {
    $_SESSION['student_id'] = $_POST['sid'];
}

if (isset($_POST['add_marks'])) {

    $sid = $_SESSION['student_id'];
    $subject = $_POST['subject'];
    $marks = $_POST['marks'];

    // LEVEL-2: check duplicate subject
// LEVEL-2: check duplicate subject
$checkSubject = mysqli_query($conn,
    "SELECT * FROM marks 
     WHERE student_id = '$sid'
     AND subject = '$subject'"
);

if (mysqli_num_rows($checkSubject) > 0) {

    $message = "<p style='color:red'>Marks already added for $subject</p>";

} else {

    // call stored procedure
    $sql = "CALL add_marks('$sid', '$subject', '$marks')";

    if (mysqli_query($conn, $sql)) {
        $message = "<p style='color:green'>Marks added successfully</p>";
        mysqli_next_result($conn); // VERY IMPORTANT
    } else {
        $message = "<p style='color:red'>" . mysqli_error($conn) . "</p>";
    }
}



}

if (isset($_POST['change_student'])) {
    unset($_SESSION['student_id']);
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Add Marks</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<a href="index.php" class="back-btn">← Back to Home</a>

<div class="container">
    <h3>Add Student Marks</h3>

    <?= $message ?>

    <form method="post">

    <?php if (!isset($_SESSION['student_id'])) { ?>

        <input type="number" name="sid" placeholder="Student ID" required>
        <button type="submit" name="set_student">Set Student</button>

    <?php } else { ?>

        <p><strong>Student ID:</strong> <?= $_SESSION['student_id'] ?></p>

        <select name="subject" required>
            <option value="">Select Subject</option>
            <option>DBMS</option>
            <option>Java</option>
            <option>ERP</option>
            <option>Python</option>
            <option>Maths</option>
        </select>

        <input type="number" name="marks" min="0" max="100" required>

        <button type="submit" name="add_marks">Add Marks</button>

    <?php } ?>

    </form>

    <form method="post">
        <button type="submit" name="change_student">Change Student</button>
    </form>

</div>

</body>
</html>
