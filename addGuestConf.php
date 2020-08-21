<?php
$hostname = "localhost";
$username = "root";
$password = "";
$db = "rah";
$dbconnect=mysqli_connect($hostname,$username,$password,$db);
if ($dbconnect->connect_error) {
    die("Database connection failed: " . $dbconnect->connect_error);
}

function test_input($data) {
  $data = trim($data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}

$requestNumber = $_POST['requestNumber'];

$requestDate = $_POST['requestDate'];

$place = $_POST['place'];

$topic = $_POST['topic'];

$hostManager = $_POST['hostManager'];

$host = $_POST['host'];

$endDate = $_POST['endDate'];

$startDate = $_POST['startDate'];

$endTime = $_POST['endTime'];

$startTime = $_POST['startTime'];

$isHost = 0;

$isEmpty = 1;

$isCanceled = 0;

$supporter = $_POST['supporter'];

$supporterTel = $_POST['supTel'];

$platform = $_POST['platformName'];

$platformUrl = $_POST['platformLink'];

$platformDesc = $_POST['platDescription'];

if (empty($_POST['platDescription'])) {
    $participators = "empty";
  }

$q = "SELECT addConference('".$requestNumber. "','" .$requestDate. "','" .$topic. "','" .$startDate. "','" .$endDate. "','" .$startTime. "','" .$endTime. "','" .$isCanceled. "','" .$isHost. "','" .$host. "','" .$hostManager. "','" .$place. "','" .$isEmpty. "','" .$platform. "','" .$platformUrl. "','" .$platformDesc. "','" .$supporter. "','" .$supporterTel."');";

$query = mysqli_query($dbconnect, $q)
   or die (mysqli_error($dbconnect));
while ($row = mysqli_fetch_array($query)) {
    if($row[0] != 1) {
        echo "Something is wrong";
    }
    else{
        include('mainPage.html');
		exit;
    }
}
?>