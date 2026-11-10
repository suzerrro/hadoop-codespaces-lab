#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f data/orders.csv ] || python3 scripts/generate_data.py

echo '[1/4] 클라이언트 컨테이너(/tmp)로 데이터 복사'
docker compose cp data/words.txt namenode:/tmp/words.txt
docker compose cp data/orders.csv namenode:/tmp/orders.csv

echo '[2/4] HDFS 디렉터리 생성'
docker compose exec -T namenode hdfs dfs -mkdir -p /lab/input

echo '[3/4] HDFS로 업로드 (-f 는 파일 덮어쓰기)'
docker compose exec -T namenode hdfs dfs -put -f /tmp/words.txt /lab/input/words.txt
docker compose exec -T namenode hdfs dfs -put -f /tmp/orders.csv /lab/input/orders.csv

echo '[4/4] HDFS 목록 출력'
docker compose exec -T namenode hdfs dfs -ls -h /lab/input
