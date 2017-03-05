<?php
header('Content-type: text/xml'); 
$version = "1.048"; //and build 

echo '<?xml version="1.1" encoding="utf-8"?>
<rss version="1.1" xmlns:sparkle="https://transferme.it/xml-namespaces/sparkle"  xmlns:dc="https://transferme.it/dc/elements/1.1/">
  <channel>
    <item>
    <title>Version '.$version.'</title>
    <description><![CDATA[
        <h2>New Features</h2>
		
        <li>Updated Security/Validation</li>
		<li>Fixed cancelling download and upload</li>
		<li>Better quality icon</li>
		<li>Fixed alert menubar icon not showing up</li>
		<li>Enter key can be used to submit codes entered</li>
		<li>Alerts if file already exists > adds "copy" to filename</li>
		<li>Two servers one for pro and one for everyone else</li>
		<li>Now using sockets (reduced the cpu usage by 300%)</li>
		<li>Added "new file" sound</li>
		<li>Added $_SESSION security</li>
		<li>Fixed app not closing properly</li>
		<li>Re designed the "enter friends code"</li>
		
		<h2>Bugs</h2>
		<li>Sometimes when creating a new user it creates a loop of creating new user that takes 20+ seconds to fix itself</li>
		<li>Sending more than one file before the user downloads the first one will cause app to not be able to decrypt</li>
		
		<h4>Untested Release</h4>
		Expect bugs.<br><br>
		Thank you for testing!<br><br>
		Maximilian Mitchell
    ]]>
    </description>
	<sparkle:version>'.$version.'</sparkle:version>
    <pubDate>'.date("r",filemtime("Transfer Me It.zip")).'</pubDate>
    <enclosure url="https://transferme.it/download.php"
               sparkle:version="'.$version.'"/>
	</item>
  </channel>
</rss>
';

