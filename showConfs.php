<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <link rel="stylesheet" type="text/css" href="style.css">
        <link rel="stylesheet" type="text/css" href="038%20Grid.css">
        <link rel='stylesheet' type='text/css' href='https://cdn.fontcdn.ir/Font/Persian/Nazanin/Nazanin.css'>
    </head>
    <?php
        $hostname = "localhost";
        $username = "root";
        $password = "";
        $db = "rah";
        $dbconnect=mysqli_connect($hostname,$username,$password,$db);
        if ($dbconnect->connect_error) {
            die("Database connection failed: " . $dbconnect->connect_error);
        }
        $query = mysqli_query($dbconnect, "CALL showConfs()");
    ?>
    <body>
        <table class="myTable">
            <tr>
            <td>آیدی</td>
            <td>شماره درخواست</td>
            <td>موضوع</td>
            <td>لغو شده</td>
            <td>تاریخ شروع</td>
			<td>ساعت شروع</td>
			<td>ساعت پایان</td>
            <td>نام میزبان</td>
            <td>محل برگزاری</td>
            <td>نام نرم افزار</td>
            <td>لینک نرم افزار</td>
            <td>مشخصات فنی</td>
            <td>رابط</td>
            <td>شماره تلفن</td>
            <td>لغو</td>
            <td>برقراری</td>
            </tr>
        <?php
            while ($row = mysqli_fetch_assoc($query)) {
                echo "<tr id ='detailsRow'>";
                foreach ($row as $field => $value) {
                    echo "<td>" . $value . "</td>"; 
                }
                echo '<td><input  type="button"  name="cancel" value ="لغو جلسه" onclick="cancel(\''.$row['id'].'\')"></td>';
                echo '<td><input  type="button"  name="undoCancel" value ="برقراری جلسه" onclick="undoCancel(\''.$row['id'].'\')"></td>';
                echo "</tr>";
            }      
        ?>   
        </table>
    </body>
    <script>
        function cancel(id) {
        const XHR = new XMLHttpRequest();
        XHR.open( "GET", "http://localhost:81/cancel.php?id="+id , false);
        XHR.send( '' );
        alert(XHR.responseText);
        location.reload();
        }
        
        function undoCancel(id) {
        const XHR = new XMLHttpRequest();
        XHR.open( "GET", "http://localhost:81/undoCancel.php?id="+id , false);
        XHR.send( '' );
        alert(XHR.responseText);
        location.reload();
        }
    </script>
</html>
<?php
?> 
