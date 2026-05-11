#!/usr/bin/env sh
set -eu

echo "[SafeAgent] Linux 오프라인 배포를 시작합니다."

if [ ! -f ".env" ]; then
  if [ -f ".env.release.example" ]; then
    cp .env.release.example .env
    echo "[SafeAgent] .env 파일을 생성했습니다. 비밀번호와 LLM 주소를 먼저 확인하세요."
  else
    echo "[SafeAgent] .env.release.example 파일이 없습니다."
    exit 1
  fi
fi

if [ ! -f "safeagent-api-v0.2.0.tar" ]; then
  echo "[SafeAgent] safeagent-api-v0.2.0.tar 파일이 없습니다."
  echo "[SafeAgent] 번들을 다시 받았는지 확인하세요."
  exit 1
fi

if [ ! -f "safeagent-portal-v0.2.0.tar" ]; then
  echo "[SafeAgent] safeagent-portal-v0.2.0.tar 파일이 없습니다."
  echo "[SafeAgent] 번들을 다시 받았는지 확인하세요."
  exit 1
fi

echo "[SafeAgent] API 이미지를 Docker에 등록합니다."
docker load -i safeagent-api-v0.2.0.tar

echo "[SafeAgent] 포털 이미지를 Docker에 등록합니다."
docker load -i safeagent-portal-v0.2.0.tar

docker compose -f docker-compose.release.yml up -d

echo "[SafeAgent] 컨테이너를 올렸습니다. 마이그레이션을 진행합니다."
docker compose -f docker-compose.release.yml exec api python -m scripts.run_migrations

echo "[SafeAgent] 오프라인 배포가 완료되었습니다."
