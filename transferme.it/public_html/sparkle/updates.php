<?php
$settings = yaml_parse_file("../config.yaml");

$version = "1.00";
$file = $_SERVER["DOCUMENT_ROOT"]."/Transfer Me It.dmg";
$domain = $_SERVER['HTTP_HOST'];

header('Content-type: text/xml');

echo '<?xml version="1.1" encoding="utf-8"?>
<rss version="1.1" xmlns:sparkle="https://'.$domain.'/xml-namespaces/sparkle" xmlns:dc="https://'.$domain.'/dc/elements/1.1/">
  <channel>
    <item>
    <title>Version '.$version.'</title>
    <description><![CDATA[
        <h2>New Features</h2>
		
		<h2>Bugs</h2>
		
		<h4>Untested Release</h4>
		Thank you for testing!<br><br>
		Maximilian Mitchell
    ]]>
    </description>
	<sparkle:version>'.$version.'</sparkle:version>
    <pubDate>'.date ("r", filemtime($file)).'</pubDate>
    <enclosure url="https://'.$domain.'/download.php"
               sparkle:version="'.$version.'"/>
	</item>
  </channel>
</rss>
';

