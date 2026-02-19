<?php
include "db.php";
?>

<!DOCTYPE html>
<html>
<head>
    <title>Add Student</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h3>Add Student</h3>

    <form method="post">
        <input type="text" name="name" placeholder="Student Name" required>
        <input type="text" name="class" placeholder="Class" required>
        <button type="submit" name="save">Save</button>
        <a href="index.php" class="back-btn">← Back to Home</a>
    </form>

<?php
if (isset($_POST['save'])) {

    $name  = $_POST['name'];
    $class = $_POST['class'];

    $sql = "INSERT INTO student(name, class)
            VALUES ('$name', '$class')";

    if (mysqli_query($conn, $sql)) {

        // ✅ Get auto-generated student ID
        $new_id = mysqli_insert_id($conn);

        echo "<p style='color:green'>
                Student added successfully <br>
                <b>Student ID: $new_id</b>
              </p>";
    } else {
        echo "<p style='color:red'>Error adding student</p>";
    }
}
?>

</div>

</body>
</html>
