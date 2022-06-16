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
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
        exit();
    }

    $loginAttempt = isset($_POST["username"]) && isset($_POST["password"]);
    $registrationAttempt = isset($_POST["registration"]) && isset($_POST["username"]) && isset($_POST["password"]);
    $getTaskTypes = isset($_POST["gettasktypes"]);
    $getTaskList = isset($_POST["gettasklist"]) && isset($_POST["userid"]);
    $addTask = isset($_POST["addtask"]) && isset($_POST["pinnum"]) && isset($_POST["typeid"]) && isset($_POST["userid"]);
    $deleteTask = isset($_POST["deletetask"]) && isset($_POST["userid"]);


    if($registrationAttempt)
    {
        $uname = mysqli_real_escape_string($link, $_POST["username"]);
        $pword = mysqli_real_escape_string($link, $_POST["password"]);
        $hashedPword = password_hash($pword, PASSWORD_DEFAULT);
        
        $getLastUserIDsql = "SELECT UserID FROM User ORDER BY UserID DESC LIMIT 1";
        $resUserID = mysqli_query($link, $getLastUserIDsql);
        if(mysqli_num_rows($resUserID) == 1)
        {
            $row = mysqli_fetch_assoc($resUserID);
            $userID = $row["UserID"] + 1;

            $sql = "INSERT INTO `User` (`UserID`, `Username`, `Password`) VALUES ('$userID', '$uname', '$hashedPword')";
            $res = mysqli_query($link, $sql);

            if($res)
            {
                $return["message"] = "registration success";
            }
            else
            {
                $return["error"] = true;
                $return["message"] = "registration failure";
            }
        }
        else
        {
            $return["error"] = true;
            $return["message"] = "error at userid select";
        }
    }
    else if($loginAttempt)
    {
        $uname = mysqli_real_escape_string($link, $_POST["username"]);
        $pword = mysqli_real_escape_string($link, $_POST["password"]);

        if($return["error"] == false && strlen($uname) < 5){
            $return["error"] = true;
            $return["message"] = "Username has to be atleast 5 characters long.";
        }

        if($return["error"] == false)
        {   
            $sql = "SELECT * FROM User WHERE Username='$uname'"; // KASNEJE PREVENTEJ REPLIKE VNOSOV, TKO DA BO TO VEDNO VRNL EN REZULTAT
            $res = mysqli_query($link, $sql);

            if(mysqli_num_rows($res) == 1)
            {
                $row = mysqli_fetch_assoc($res);
                if(password_verify($pword, $row["Password"])) {
                    $return["message"] = $row["UserID"];
                }
                else
                {
                    $return["error"] = true;
                    $return["message"] = "login failure";
                }
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
        $taskID = intval(mysqli_real_escape_string($link, $_POST["deletetask"]));
        $userID = intval(mysqli_real_escape_string($link, $_POST["userid"]));

        $sql = "DELETE FROM `User_has_Task` WHERE `User_has_Task`.`UserID` = '$userID' AND `User_has_Task`.`TaskID` = '$taskID'";
        $sql2 = "DELETE FROM `Task` WHERE `Task`.`TaskID` = '$taskID'";
        $res = mysqli_query($link, $sql);
        $res = mysqli_query($link, $sql2);

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
        $pinNum = intval(mysqli_real_escape_string($link, $_POST["pinnum"]));
        $typeID = intval(mysqli_real_escape_string($link, $_POST["typeid"]));
        $userID = intval(mysqli_real_escape_string($link, $_POST["userid"]));
        
        $getLastTaskIDsql = "SELECT TaskID FROM Task ORDER BY TaskID DESC LIMIT 1";
        $resTaskID = mysqli_query($link, $getLastTaskIDsql);
        if(mysqli_num_rows($resTaskID) == 1)
        {
            $row = mysqli_fetch_assoc($resTaskID);
            $taskID = $row["TaskID"] + 1;

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
        else
        {
            $return["error"] = true;
            $return["message"] = "error at taskid select";
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
        // OBLIKA: TaskID:PinNum:TypeID,   ...
        $userID = intval(mysqli_real_escape_string($link, $_POST["userid"]));

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