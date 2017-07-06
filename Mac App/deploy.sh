#!/bin/bash
project_name="Transfer Me It"
project_type=".xcworkspace"
project_path="/Users/maxmitch/Documents/transfermeit/Mac App/"
dev_team="3H49MXS325"
dmg_project_output="/Users/maxmitch/Documents/transfermeit/transferme.it/public_html/${project_name}.dmg"
scp_command="scp -P 606 '"$dmg_project_output"' root@transferme.it:/var/www/transferme.it/public_html/"
sparkle_path="https://transferme.it/sparkle/updates.php"
sign_key="D3C88D1DD4AF92989F7744557D5B185FC75B6849" # `security find-identity -v -p codesigning` ->> "Mac Developer"

~/deploy.sh "$project_name" "$project_type" "$project_path" "$dev_team" "$dmg_project_output" "$scp_command" "$sparkle_path" "$sign_key"
