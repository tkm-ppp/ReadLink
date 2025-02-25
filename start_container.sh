docker stop $(docker ps -q) # 全てのコンテナを停止
docker compose up
wait
open "http://localhost:3000/"