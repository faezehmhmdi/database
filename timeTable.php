<!DOCTYPE HTML>
<html>
	<?php
        $hostname = "localhost";
        $username = "root";
        $password = "";
        $db = "rah";
        $dbconnect=mysqli_connect($hostname,$username,$password,$db);
        if ($dbconnect->connect_error) {
            die("Database connection failed: " . $dbconnect->connect_error);
        }
		$return_arr = array();
        $query = mysqli_query($dbconnect, "SELECT * FROM Conference");
		while ($row = mysqli_fetch_assoc($query)) {
			$row_array['topic'] = $row['topic'];
			$row_array['start_Date'] = $row['start_Date'];
			$row_array['end_Date'] = $row['end_Date'];

			array_push($return_arr,$row_array);
		}

		//echo json_encode($return_arr);
    ?>
  <head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
	google.charts.load('current', {'packages':['timeline']});
    google.charts.setOnLoadCallback(drawChart);
	function drawChart() {
        var container = document.getElementById('timeline');
        var chart = new google.visualization.Timeline(container);
        var dataTable = new google.visualization.DataTable();
		dataTable.addColumn({ type: 'string', id: 'name' });
        dataTable.addColumn({ type: 'date', id: 'Start' });
        dataTable.addColumn({ type: 'date', id: 'End' });
        dataTable.addRows([<?php $return_arr?>]);

        chart.draw(dataTable);
      }
    </script>
  </head>
  <body>
    <div id="timeline" style="height: 180px;"></div>
  </body>
</html>
