#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
printf '경고: 모든 Hadoop 컨테이너와 HDFS 실습 데이터를 삭제합니다.\n'
printf '계속하려면 RESET을 입력하세요: '
read -r reply
if [ "$reply" != RESET ]; then echo '취소'; exit 1; fi
docker compose --profile mapreduce down --remove-orphans
printf '완료. 다시 시작하려면 bash scripts/start_hdfs.sh 를 실행하세요.\n'
