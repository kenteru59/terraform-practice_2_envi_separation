#!/bin/bash

cat > index.html <<EOF
<h1>Hello, MyWorld!</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
<p>こちらは ${env_name} 環境です。</p>
EOF

nohup busybox httpd -f -p ${server_port} &