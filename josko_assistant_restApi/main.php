<?php 
    $dbhost = "localhost";      // database host
    $dbuser = "aljaz";          // database username
    $dbpassword = "1234";       // database password
    $db = "joskoDatabase";      // database name

    $return["error"] = false;
    $return["message"] = "";

    $link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);
    if (mysqli_connect_errno())
    {
        echo "Failed to connect to MySQL: " . mysqli_connect_error(); //////////// Failed to connect to MySQL: Access denied for user 'aljaz'@'localhost' (using password: YES)
        exit();
    }

    $loginAttempt = isset($_GET["username"]) && isset($_GET["password"]);

    if($loginAttempt)
    {
       $uname = $_GET["username"];
       $pword = $_GET["password"];

        if($return["error"] == false && strlen($uname) < 5){
            $return["error"] = true;
            $return["message"] = "Username has to be atleast 5 characters long.";
        }

       if($return["error"] == false)
        {
            //$uname = mysqli_real_escape_string($link, $uname);
            //$pword = mysqli_real_escape_string($link, $pword);
            
            $sql = "SELECT * FROM User WHERE Username='$uname' AND Password='$pword'"; // KASNEJE PREVENTEJ REPLIKE VNOSOV, TKO DA BO TO VEDNO VRNL EN REZULTAT
            $res = mysqli_query($link, $sql);


            if(mysqli_num_rows($res) == 1)
            {
                $row = mysqli_fetch_assoc($res);
                $return["message"] = "login success";
            }
            else
            {
                $return["error"] = true;
                $return["message"] = "login failure";
            }
        }
    }
    else
    {
        $return["error"] = true;
        $return["message"] = 'incorrect parameters';
    }

    mysqli_close($link);
    header('Content-Type: application/json');
    echo json_encode($return);
?>