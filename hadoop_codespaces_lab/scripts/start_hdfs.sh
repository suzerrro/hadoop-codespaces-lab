#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! docker info >/dev/null 2>&1; then
  echo '[ERROR] docker info 실패: Codespaces 개발환경을 먼저 확인하세요.' >&2
  exit 1
fi
echo '[1/3] Hadoop 이미지 받기'
docker compose pull namenode datanode1 datanode2
echo '[2/3] HDFS 3개 컨테이너 기동'
docker compose up -d namenode datanode1 datanode2
echo '[3/3] DataNode 등록 확인'
bash scripts/check_cluster.sh
