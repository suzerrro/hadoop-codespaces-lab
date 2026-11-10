# GitHub Codespaces에서 Apache Hadoop 실습

**대상:** 빅데이터플랫폼개론 / **환경:** 웹브라우저 + GitHub Codespaces + Docker Compose / **기본 버전:** Apache Hadoop 3.4.3

> **중요:** 이 실습 꾸러미에는 `.devcontainer` 폴더를 일부러 넣지 않았습니다. 이전 Spark 실습에서 보았던 devcontainer 기능 설치 오류를 피하기 위해 **GitHub Codespaces의 기본 개발환경**을 먼저 사용합니다. 새 저장소 `hadoop-codespaces-lab`에 파일들을 업로드하세요. 이전 Spark 저장소에 덮어쓰지 마세요.

## 1. 빠른 시작 (정상적인 Codespaces 터미널에서)

```bash
docker --version
docker compose version
docker info
bash scripts/start_hdfs.sh
bash scripts/load_data.sh
```

**NameNode UI:** Codespaces 화면 하단 **포트(Ports)** 탭 → `9870` → 지구본 / `Open in Browser`. 기본 비공개(Private) 포트 유지.

```bash
# 접속된 DataNode 확인
docker compose exec namenode hdfs dfsadmin -report

# HDFS 파일 목록
docker compose exec namenode hdfs dfs -ls /lab/input

# 블록과 복제 위치 확인
docker compose exec namenode hdfs fsck /lab/input/orders.csv -files -blocks -locations
```

**선택 심화 (YARN + Hadoop MapReduce)**:

```bash
bash scripts/run_wordcount.sh
```

## 2. 실습 폴더

```text
hadoop-codespaces-lab/
├── docker-compose.yml     # HDFS 3개 기본 서비스, YARN 2개 선택 서비스
├── hadoop.env             # Hadoop XML 설정으로 변환할 환경 변수
├── data/
│   ├── words.txt          # WordCount 입력 6줄
│   └── orders.csv         # 가상 주문 120,000건, 약 5.8MB
├── scripts/
│   ├── start_hdfs.sh      # 다운로드·실행·노드 등록 확인
│   ├── check_cluster.sh   # Live DataNodes 확인
│   ├── load_data.sh       # 파일을 컨테이너에 복사한 뒤 HDFS 업로드
│   ├── run_wordcount.sh   # YARN에서 Hadoop Java MapReduce 예제 실행
│   ├── generate_data.py   # 주문 원본 데이터 재생성
│   └── reset_all.sh       # HDFS 실습 데이터를 포함해 초기화 (주의)
├── 학생실습교재.md
└── README.md
```

## 3. 기본 구성 설명

- NameNode 1개: 파일 이름, 파일 크기, 블록 위치 등 **메타데이터**를 관리합니다.
- DataNode 2개: 실제 **데이터 블록**을 저장합니다.
- `dfs.replication=2`: 각 HDFS 블록을 서로 다른 DataNode에 2개 복제합니다.
- `dfs.blocksize=1048576`: 학습용으로 1MiB 블록을 사용합니다. 실무 설정 권장치가 아닙니다.
- 이 실습의 세 노드는 **하나의 Codespaces 가상머신에서 실행되는 서로 다른 컨테이너**입니다. 실제 물리 서버 3대가 아닙니다.

## 4. 종료와 데이터 보존

```bash
# 컨테이너는 멈추되 삭제하지 않음 (나중에 start 가능)
docker compose stop

# 다시 시작
docker compose start

# 컨테이너까지 삭제: 실습용 HDFS 파일이 사라질 수 있음
docker compose --profile mapreduce down
```

**Codespaces 자체를 삭제하면 해당 환경에 저장된 HDFS 데이터도 사라집니다.** 중요한 결과는 `hdfs dfs -get`으로 내려받아 GitHub에 별도 보관하세요.

## 5. 문제 해결

| 현상 | 확인 / 조치 |
|---|---|
| `docker: command not found` | Codespaces가 **Recovery Mode**인지 확인. 이 프로젝트는 `.devcontainer` 없이 새 저장소에서 기본 이미지로 다시 생성하는 방식입니다. PC의 Docker Desktop 설치는 필요 없습니다. |
| `Cannot connect to Docker daemon` | `docker info` 확인. 정상 Codespaces 기본 컨테이너인지 확인하고, 이전 복구 모드와 혼동하지 않습니다. |
| `Live datanodes (0)` 또는 `(1)` | `docker compose ps`, `docker compose logs --tail=80 namenode datanode1 datanode2`, `bash scripts/check_cluster.sh` |
| `NameNode is in safe mode` | 초기 HDFS 준비 중일 수 있습니다. `hdfs dfsadmin -safemode get`으로 상태 확인; 노드 등록/블록 상태가 안정화되지 않았다면 로그를 확인합니다. |
| `Replication factor: 2`인데 복제본이 1개 | `hdfs fsck /lab/input/orders.csv -blocks -locations`로 확인, `docker compose ps`로 DataNode 상태 확인 |
| `File already exists` | HDFS 파일 업로드는 `-put -f` 옵션, MapReduce 출력 폴더는 먼저 삭제해야 합니다. |
| `Port 9870 not found` | `docker compose ps`와 **포트** 탭에서 `9870` 확인. `http://localhost:9870`을 PC에서 직접 사용하지 말고 Codespaces 포트 연결을 사용하세요. |
| 메모리가 부족하거나 Yarn 실행 실패 | 4코어/16GB Codespaces로 변경하거나 심화 MapReduce를 생략하고 HDFS 3개 서비스만 실행합니다. |

## 6. 자료 출처

- Apache Hadoop 공식 Docker 이미지: `apache/hadoop:3.4.3`
- Apache 공식 HDFS User Guide: https://hadoop.apache.org/docs/r3.4.3/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html
- GitHub Codespaces 기본 개발환경: https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers

**검증 상태:** YAML 구문, 데이터 생성/내용, Bash 문법을 검증했습니다. 현재 작업 환경에는 Docker 데몬이 없어 실제 Codespaces에서의 컨테이너 기동 및 WordCount 완료까지는 검증하지 못했습니다. 수업 전 교수자 계정에서 1회 실행을 권장합니다.
