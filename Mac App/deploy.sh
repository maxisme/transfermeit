#!/bin/bash
project_name="Transfer Me It"
project_type=".xcworkspace"
project_path="/Users/maxmitch/Documents/work/transfermeit/Mac App/"
dev_team="3H49MXS325"
dmg_project_output="/Users/maxmitch/Documents/work/transferme.it/public_html/${project_name}.dmg"
scp_command="scp '"$dmg_project_output"' root@transferme.it:/var/www/transferme.it/public_html/"
sparkle_path="https://transferme.it/version.php"
# `security find-identity -v -p codesigning` ->> "Mac Developer"
# can be recreated with xcode preferences > + > mac Developer
sign_key="92FE8FE7E7A291030E292B8129AD99F72E65F585"

~/deploy.sh "$project_name" "$project_type" "$project_path" "$dev_team" "$dmg_project_output" "$scp_command" "$sparkle_path" "$sign_key"
