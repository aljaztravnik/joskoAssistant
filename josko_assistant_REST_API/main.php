<?php 
    $db = "test_db"; //database name
    $dbuser = "root"; //database username
    $dbpassword = "root"; //database password
    $dbhost = "localhost"; //database host

    $return["error"] = false;
    $return["message"] = "";

    $link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);
    //connecting to database server

    $val = isset($_POST["name"]) && isset($_POST["address"])
            && isset($_POST["class"]) && isset($_POST["rollno"]);

    if($val)
    {
        //checking if there is POST data

       $name = $_POST["name"]; //grabing the data from headers
       $address = $_POST["address"];
       $class = $_POST["class"];
       $rollno = $_POST["rollno"];

       //validation name if there is no error before
       if($return["error"] == false && strlen($name) < 3){
            $return["error"] = true;
            $return["message"] = "Enter name up to 3 characters.";
       }

       //add more validations here

       //if there is no any error then ready for database write
       if($return["error"] == false)
       {
            $name = mysqli_real_escape_string($link, $name);
            $address = mysqli_real_escape_string($link, $address);
            $class = mysqli_real_escape_string($link, $class);
            $rollno = mysqli_real_escape_string($link, $rollno);
            //escape inverted comma query conflict from string

            $sql = "INSERT INTO student_list SET
                                full_name = '$name',
                                address = '$address',
                                class = '$class',
                                roll_no = '$rollno'";
            //student_id is with AUTO_INCREMENT, so its value will increase automatically

            $res = mysqli_query($link, $sql);
            var_dump($res);
            if($res)
            {
                //write success
            }
            else
            {
                $return["error"] = true;
                $return["message"] = "Database error";
            }
       }
    }else
    {
        $return["error"] = true;
        $return["message"] = 'Send all parameters.';
    }

    mysqli_close($link); //close mysqli

    header('Content-Type: application/json');
    // tell browser that its a json data
    echo json_encode($return);
    //converting array to JSON string
?>