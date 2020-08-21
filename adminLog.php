<?php
$hostname = "localhost";
$username = "root";
$password = "";
$db = "rah";
$dbconnect=mysqli_connect($hostname,$username,$password,$db);
if ($dbconnect->connect_error) {
    die("Database connection failed: " . $dbconnect->connect_error);
}

$userName = $_POST['username'];
$pass = $_POST['pass'];
$q = "SELECT login('".$userName. "','" .$pass."');";
$query = mysqli_query($dbconnect, $q)
   or die (mysqli_error($dbconnect));
while ($row = mysqli_fetch_array($query)) {
    if($row[0] != 'Logged in') {
        echo $row[0];
    }
    else{
        include('mainPage.html');
		exit;
    }
}
?>