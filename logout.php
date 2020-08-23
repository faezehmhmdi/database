<?php
   session_start();
   unset($_SESSION["username"]);
   unset($_SESSION["password"]);
   echo '<script>alert("شما از سیستم خارج شدید")</script>';
   header('Refresh: 2; URL = adminLogin.html');
?>