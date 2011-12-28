<?php
    $pos = strrpos($argv[1], "/");
    $dir = substr($argv[1], 0, $pos);
    
    chdir($dir);
    require($argv[1]);

    //print "__NOTOC__\n\n";
    print "==Version $ext_version ($last_update)==\n";
    if (isset($bugarray)) {
        $msg = '';
        
        foreach ($bugarray as $b) {
            $msg .= create_mediawiki_changelog_message($b[0], $b[1], $b[2], $b[3], $b[4]) . "\n";
        }
        echo $msg;
    } else {
        foreach ($news as $n) {
            
            $type_of_bug = preg_replace('/\s*(\S*)/', '$1', $n[0]);
            $content = preg_replace("/<a href=['\"](.*)['\"]>(.*)<\\/a>/", '[$1 $2]', $n[1]);
            print "* $type_of_bug - $content\n";
        }
    }
?>