#!/bin/bash

docker compose down -v
docker compose up -d


sleep 2

###
# Инициализируем сервер конфигурации
###

docker compose exec -T configSrv mongosh --quiet --port 27019 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
        members: [
          { _id : 0, host : "configSrv:27019" }
        ]
  }
);
EOF

###
# Инициализируем шарды
###

docker compose exec -T shard1 mongosh --quiet --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" }
      ]
    }
);
EOF

docker compose exec -T shard2 mongosh --quiet --port 27020 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27020" }
      ]
    }
  );
EOF


sleep 2

###
# Инициализируем роутер
###

docker compose exec -T mongos_router mongosh ---quiet --port 27017 <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27020");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

sleep 2

###
# Наполняем коллекцию данными
###
docker compose exec -T mongos_router mongosh --port 27017 <<EOF

use somedb

for(let i = 0; i < 1500; i++) {
  db.helloDoc.insert({
    age: i,
    name: "ly" + i
  })
}

db.helloDoc.countDocuments() 
EOF