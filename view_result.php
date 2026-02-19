<?php
include "db.php";

$marks = [];
$total = 0;
$percentage = 0;
$grade = "";
$error = "";

if (isset($_POST['view'])) {

    $sid = $_POST['sid'];

    // check student
    $stu = mysqli_query($conn,
        "SELECT * FROM student WHERE student_id = '$sid'"
    );

    $student = mysqli_fetch_assoc($stu);

    $student_name = $student['name'];
    $student_class = $student['class'];

    if (mysqli_num_rows($stu) == 0) {
        $error = "Invalid Student ID";
    } else {

        // fetch marks
        $res = mysqli_query($conn,
            "SELECT subject, marks FROM marks WHERE student_id = '$sid'"
        );

        if (mysqli_num_rows($res) == 0) {
            $error = "Marks not entered yet";
        } else {

            while ($row = mysqli_fetch_assoc($res)) {
                $marks[] = $row;
                $total += $row['marks'];
            }

            $count = count($marks);
            $percentage = ($total / ($count * 100)) * 100;

            if ($percentage >= 75)
                $grade = "A";
            elseif ($percentage >= 60)
                $grade = "B";
            elseif ($percentage >= 40)
                $grade = "C";
            else
                $grade = "Fail";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>View Result</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<a href="index.php" class="back-btn">← Back to Home</a>

<div class="container">

    <h3>View Result</h3>

    <form method="post">
        <input type="number" name="sid" placeholder="Student ID" required>
        <button type="submit" name="view">View Result</button>
    </form>

    <?php if (!empty($error)) { ?>
        <p style="color:red"><?= $error ?></p>
    <?php } ?>

    <?php if (!empty($marks)) { ?>

    <div class="student-info">
    <p><strong>Student ID:</strong> <?= $sid ?></p>
    <p><strong>Student Name:</strong> <?= $student_name ?></p>
    <p><strong>Class:</strong> <?= $student_class ?></p>
    </div>


        <table class="result-table">
            <tr>
                <th>Subject</th>
                <th>Marks Obtained</th>
                <th>Maximum Marks</th>
            </tr>

            <?php foreach ($marks as $row) { ?>
                <tr>
                    <td><?= $row['subject'] ?></td>
                    <td><?= $row['marks'] ?></td>
                    <td>100</td>
                </tr>
            <?php } ?>
        </table>

        <div class="summary-box">
            <p><strong>Total Marks:</strong> <?= $total ?></p>
            <p><strong>Percentage:</strong> <?= number_format($percentage, 2) ?>%</p>
            <p><strong>Grade:</strong> <?= $grade ?></p>
        </div>

    <?php } ?>

</div>

</body>
</html>
