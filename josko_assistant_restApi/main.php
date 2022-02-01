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
    $deleteTask = isset($_GET["deletetask"]) && isset($_GET["userid"]);
    $addTask = isset($_GET["addtask"]) && isset($_GET["pinnum"]) && isset($_GET["typeid"]) && isset($_GET["userid"]);
    $getTaskTypes = isset($_GET["gettasktypes"]);






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
    else if($deleteTask)
    {
        $taskID = intval($_GET["deletetask"]);
        $userID = intval($_GET["userid"]);

        //$taskID = mysqli_real_escape_string($link, $taskID);
        //$userID = mysqli_real_escape_string($link, $userID);

        //$sql = "DELETE FROM USER_has_Task WHERE UserID='$userID' AND TaskID='$taskID'";
        $sql = "DELETE FROM `User_has_Task` WHERE `User_has_Task`.`UserID` = '$userID' AND `User_has_Task`.`TaskID` = '$taskID'";
        $res = mysqli_query($link, $sql);


        if($res)
        {
            $return["message"] = "delete task success";
        }
        else
        {
            $return["error"] = true;
            $return["message"] = "delete task failure";
        }
    }
    else if($addTask)
    {
        $taskID = intval($_GET["addtask"]);
        $pinNum = intval($_GET["pinnum"]);
        $typeID = intval($_GET["typeid"]);
        $userID = intval($_GET["userid"]);
    
        
        $sql = "INSERT INTO `Task` (`TaskID`, `PinNum`, `TypeID`) VALUES ('$taskID', '$pinNum', '$typeID')";
        $sql2 = "INSERT INTO `User_has_Task` (`UserID`, `TaskID`) VALUES ('$userID', '$taskID')";
        $res = mysqli_query($link, $sql);
        $res2 = mysqli_query($link, $sql2);

        if($res && $res2)
        {
            $return["message"] = "add task success";
        }
        else
        {
            $return["error"] = true;
            $return["message"] = "add task failure";
        }
    }
    else if($getTaskTypes)
    {
        $sql = "SELECT TypeName FROM Type";
        $res = mysqli_query($link, $sql);

        if(mysqli_num_rows($res) >= 1)
        {
            
            while($row = mysqli_fetch_assoc($res))
            {
                $return["message"] .= $row["TypeName"] . ',';
            }
        }
        else
        {
            $return["error"] = true;
            $return["message"] = "type return failure";
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