#!/bin/bash

echo "Общее число документов в базе:"


docker compose exec -T mongos_router mongosh --port 27017 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF


echo "Число документов в shard1_main:"


docker compose exec -T shard1_main mongosh --port 27018 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF

echo "Число документов в shard1_repl1:"


docker compose exec -T shard1_repl1 mongosh --port 27021 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF

echo "Число документов в shard1_repl2:"


docker compose exec -T shard1_repl2 mongosh --port 27022 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF

echo "Число документов в shard1_repl3:"


docker compose exec -T shard1_repl3 mongosh --port 27023 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF


echo "Число документов в shard2_main:"


docker compose exec -T shard2_main mongosh --port 27020 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF

echo "Число документов в shard2_repl1:"


docker compose exec -T shard2_repl1 mongosh --port 27024 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF


echo "Число документов в shard2_repl2:"


docker compose exec -T shard2_repl2 mongosh --port 27025 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF


echo "Число документов в shard2_repl3:"


docker compose exec -T shard2_repl3 mongosh --port 27026 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF