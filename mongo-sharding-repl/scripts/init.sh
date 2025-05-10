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

docker compose exec -T shard1_main mongosh --quiet --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1_main:27018" },
        { _id : 1, host : "shard1_repl1:27021" },
        { _id : 2, host : "shard1_repl2:27022" },
        { _id : 3, host : "shard1_repl3:27023" },
      ]
    }
);
EOF

docker compose exec -T shard2_main mongosh --quiet --port 27020 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2_main:27020" },
        { _id : 1, host : "shard2_repl1:27024" },
        { _id : 2, host : "shard2_repl2:27025" },
        { _id : 3, host : "shard2_repl3:27026" }
      ]
    }
  );
EOF


sleep 3

###
# Инициализируем роутер
###

docker compose exec -T mongos_router mongosh ---quiet --port 27017 <<EOF
sh.addShard( "shard1/shard1_main:27018,shard1_repl1:27021,shard1_repl2:27022,shard1_repl3:27023");
sh.addShard( "shard2/shard2_main:27020,shard2_repl1:27024,shard2_repl2:27025,shard2_repl3:27026");

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