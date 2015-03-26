<?php
    require("../iOS/connectionString.php");
    
    
    $strSQL = "SELECT * FROM Project WHERE project_ID = 46";
    
    if($result = $mysqli->query($strSQL))
    {
        $row = $result->fetch_assoc();
        
        echo $row['project_name'];
        
    }
    
?>