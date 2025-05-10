#!/bin/bash

echo "Общее число документов в базе:"


docker compose exec -T mongos_router mongosh --port 27017 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF


echo "Число документов в shard1:"


docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF


echo "Число документов в shard2:"


docker compose exec -T shard2 mongosh --port 27020 --quiet <<EOF
use somedb

db.helloDoc.countDocuments()
EOF
