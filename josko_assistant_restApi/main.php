<?php
    // POT: /var/www/html/joskoAssistant_restApi/main.php
    
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

    $loginAttempt = isset($_POST["username"]) && isset($_POST["password"]);
    $getTaskTypes = isset($_POST["gettasktypes"]);
    $getTaskList = isset($_POST["gettasklist"]) && isset($_POST["userid"]);
    $addTask = isset($_POST["addtask"]) && isset($_POST["pinnum"]) && isset($_POST["typeid"]) && isset($_POST["userid"]);
    $deleteTask = isset($_POST["deletetask"]) && isset($_POST["userid"]);





    if($loginAttempt)
    {
       $uname = $_POST["username"];
       $pword = $_POST["password"];

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
        $taskID = intval($_POST["deletetask"]);
        $userID = intval($_POST["userid"]);

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
        $taskID = intval($_POST["addtask"]);
        $pinNum = intval($_POST["pinnum"]);
        $typeID = intval($_POST["typeid"]);
        $userID = intval($_POST["userid"]);
    
        
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
    else if($getTaskTypes) // pri kreiranju novega taska
    {
        $sql = "SELECT TypeName FROM Type";
        $res = mysqli_query($link, $sql);

        if(mysqli_num_rows($res) >= 1)
        {
            while($row = mysqli_fetch_assoc($res))
            {
                $return["message"] .= $row["TypeName"] . ',';
            }
            $return["message"] = substr($return["message"], 0, -1); // odstrani zadnjo vejico iz stringa
        }
        else
        {
            $return["error"] = true;
            $return["message"] = "type return failure";
        }
    }
    else if($getTaskList) // Pošlje nazaj vse taske od določenega userja. Taski so ločeni z vejicami, podatki o tasku pa z dvopičji.
    {
        // OBLIKA: TaskID:PinNum:TypeID,   ......

        $userID = intval($_POST["userid"]);
        //$sql = "SELECT `User_has_Task`.`TaskID` FROM `User_has_Task` WHERE `User_has_Task`.`UserID` = '$userID'";
        $sql = "SELECT TaskID FROM User_has_Task WHERE UserID = '$userID'";
        $res = mysqli_query($link, $sql);

        if(mysqli_num_rows($res) >= 1)
        {
            while($row = mysqli_fetch_assoc($res))
            {
                $taskID = $row["TaskID"];
                $sql2 = "SELECT * FROM Task WHERE TaskID = '$taskID'";
                $res2 = mysqli_query($link, $sql2);

                if(mysqli_num_rows($res2) == 1)
                {
                    $row2 = mysqli_fetch_assoc($res2);

                    $return["message"] .= strval($row["TaskID"]) . ":" . strval($row2["PinNum"]) . ":" . strval($row2["TypeID"]) . ",";
                }
            }
            $return["message"] = substr($return["message"], 0, -1); // odstrani zadnjo vejico iz stringa
        }
        else
        {
            $return["error"] = true;
            $return["message"] = "task return failure";
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