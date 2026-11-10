#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo '[1/4] YARN 두 서비스 실행 (심화: 리소스 더 소모)'
docker compose --profile mapreduce up -d resourcemanager nodemanager

echo '[2/4] NodeManager 등록 확인'
ready=0
for i in $(seq 1 45); do
  if docker compose exec -T resourcemanager yarn node -list 2>/dev/null | grep -Eq 'Total Nodes:[[:space:]]*[1-9]'; then
    ready=1
    break
  fi
  sleep 3
done
if [ "$ready" -ne 1 ]; then
  echo '[ERROR] YARN 노드 등록 실패' >&2
  docker compose logs --tail=40 resourcemanager nodemanager >&2
  exit 1
fi

echo '[3/4] 기존 출력 경로 제거 (MapReduce는 기존 디렉터리에 쓰지 못함)'
docker compose exec -T namenode hdfs dfs -rm -r -f /lab/output/wordcount || true

echo '[4/4] Hadoop examples.jar WordCount 실행'
docker compose exec -T namenode sh -lc '
  JAR=$(find /opt/hadoop/share/hadoop/mapreduce -maxdepth 1 -name "hadoop-mapreduce-examples-*.jar" | head -n 1)
  if [ -z "$JAR" ]; then echo "WordCount JAR를 찾지 못했습니다" >&2; exit 1; fi
  hadoop jar "$JAR" wordcount /lab/input/words.txt /lab/output/wordcount
'
docker compose exec -T namenode hdfs dfs -cat /lab/output/wordcount/part-r-00000
