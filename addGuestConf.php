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

/**
     * Persian to Gregorian Convertor
     *
     * @author farsiweb.info
     * @access public
     * @param   int $j_y    year
     * @param   int $j_y    month
     * @param   int $j_y    day
     * @return  array   converted time
     */
     function p2g($j_y, $j_m, $j_d)
    {
        $g_days_in_month = array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
        $j_days_in_month = array(31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);
        $jy = $j_y-979;
        $jm = $j_m-1;
        $jd = $j_d-1;
        $j_day_no = 365*$jy + floor($jy/33)*8 + floor(($jy%33+3)/4);
        for ($i=0; $i < $jm; ++$i){
            $j_day_no += $j_days_in_month[$i];
        }
        $j_day_no += $jd;
        $g_day_no = $j_day_no+79;
        $gy = 1600 + 400*floor($g_day_no/146097);
        $g_day_no = $g_day_no % 146097;
        $leap = true;
        if ($g_day_no >= 36525){
            $g_day_no--;
            $gy += 100*floor($g_day_no/36524);
            $g_day_no = $g_day_no % 36524;
            if ($g_day_no >= 365){
                $g_day_no++;
            }else{
                $leap = false;
            }
        }
        $gy += 4*floor($g_day_no/1461);
        $g_day_no %= 1461;
        if ($g_day_no >= 366){
            $leap = false;
            $g_day_no--;
            $gy += floor($g_day_no/365);
            $g_day_no = $g_day_no % 365;
        }
        for ($i = 0; $g_day_no >= $g_days_in_month[$i] + ($i == 1 && $leap); $i++){
            $g_day_no -= $g_days_in_month[$i] + ($i == 1 && $leap);
        }
        $gm = $i+1;
        $gd = $g_day_no+1;

        return array($gy, $gm, $gd);
    }

$requestNumber = $_POST['requestNumber'];

$requestDate = $_POST['requestDate'];
$req_arr = explode ("/", $requestDate);
$greq_arr = p2g((int)$req_arr[0], (int)$req_arr[1], (int)$req_arr[2]);
$myStr = $greq_arr[0] . "/" .$greq_arr[1]. "/". $greq_arr[2];
$reqTime = strtotime($myStr);
$newReqDate = date('Y-m-d',$reqTime);

$place = $_POST['place'];

$topic = $_POST['topic'];

$hostManager = $_POST['hostManager'];

$host = $_POST['host'];

$endDate = $_POST['endDate'];
$end_arr = explode ("/", $endDate);
$gend_arr = p2g((int)$end_arr[0], (int)$end_arr[1], (int)$end_arr[2]);
$myStr2 = $gend_arr[0] . "/" .$gend_arr[1]. "/". $gend_arr[2];
$endTime1 = strtotime($myStr2);
$newEndDate = date('Y-m-d',$endTime1);

$startDate = $_POST['startDate'];
$start_arr = explode ("/", $startDate);
$gstart_arr = p2g((int)$start_arr[0], (int)$start_arr[1], (int)$start_arr[2]);
$myStr3 = $gstart_arr[0] . "/" .$gstart_arr[1]. "/". $gstart_arr[2];
$startTime1 = strtotime($myStr3);
$newStartDate = date('Y-m-d',$startTime1);

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

$q = "SELECT addConference('".$requestNumber. "','" .$newReqDate. "','" .$topic. "','" .$newStartDate. "','" .$newEndDate. "','" .$startTime. "','" .$endTime. "','" .$isCanceled. "','" .$isHost. "','" .$host. "','" .$hostManager. "','" .$place. "','" .$isEmpty. "','" .$platform. "','" .$platformUrl. "','" .$platformDesc. "','" .$supporter. "','" .$supporterTel."');";
$query = mysqli_query($dbconnect, $q)
   or die (mysqli_error($dbconnect));
while ($row = mysqli_fetch_array($query)) {
    if($row[0] == 0) {
        echo "Something is wrong";
    }
    else{
        include('mainPage.html');
		exit;
    }
}
?>
