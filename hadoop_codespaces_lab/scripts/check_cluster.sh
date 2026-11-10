#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v docker >/dev/null 2>&1; then
  echo '[ERROR] Docker 명령을 찾을 수 없습니다.' >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo '[ERROR] Docker 데몬 연결 실패.' >&2
  exit 1
fi

echo 'NameNode와 DataNode 등록 상태 확인 중...'

for i in $(seq 1 45); do
  report=$(docker compose exec -T namenode \
    hdfs dfsadmin -report 2>/dev/null) || report=""

  if printf '%s\n' "$report" |
     grep -E 'Live datanodes \([2-9][0-9]*\)' >/dev/null; then
    echo '[OK] DataNode 2개 이상 등록 완료'
    printf '%s\n' "$report" |
      grep -E 'Live datanodes|Dead datanodes|Configured Capacity' || true
    exit 0
  fi

  echo "[대기] 확인 ${i}/45"
  sleep 3
done

echo '[ERROR] DataNode 등록 확인 실패' >&2
docker compose ps
docker compose logs --tail=35 namenode datanode1 datanode2 >&2
exit 1
