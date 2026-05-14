# SafeAgent Manager 설치 및 반영 가이드

## 1) 설치 방식

현재 배포 번들은 오프라인 설치(`docker load`)를 기본으로 합니다.

- 필요 환경: Docker Engine, Docker Compose
- PostgreSQL 별도 설치 불필요 (compose의 `postgres` 서비스 사용)

## 2) 압축 해제 후 필수 파일 확인

아래 파일이 모두 있어야 합니다.

- `.env.release.example`
- `docker-compose.release.yml`
- `install.bat` (Windows)
- `install.sh` (Linux/macOS)
- `safeagent-api-v0.2.0.tar`
- `safeagent-dashboard-v0.2.0.tar`

## 3) `.env` 파일 준비

### Windows

```powershell
Copy-Item .env.release.example .env
notepad .env
```

### Linux/macOS

```bash
cp .env.release.example .env
```

필수 수정 항목:

- `POSTGRES_PASSWORD`
- `DATABASE_URL`의 비밀번호 (위 값과 동일해야 함)

예시:

```env
POSTGRES_PASSWORD=MyStrongPassword123
DATABASE_URL=postgresql://safeagent_app:MyStrongPassword123@postgres:5432/safeagent
```

## 4) 설치 실행

### Windows

```bat
install.bat
```

### Linux/macOS

```bash
chmod +x install.sh
./install.sh
```

## 5) 수동 설치(스크립트 대신 직접 실행)

```bash
docker load -i safeagent-api-v0.2.0.tar
docker load -i safeagent-dashboard-v0.2.0.tar
docker compose -f docker-compose.release.yml up -d
docker compose -f docker-compose.release.yml exec api python -c "from src.database.connection import init_db; print(init_db())"
docker compose -f docker-compose.release.yml exec api python -m scripts.run_migrations
```

## 6) 최초 1회 Agent 등록 (필수)

챗봇 기능은 활성 agent가 있어야 동작합니다.

1. Swagger 접속: `http://localhost:8000/docs`
2. `POST /v1/auth/login` 실행 후 `access_token` 복사
3. `POST /api/agents` 실행
   - `authorization`: `Bearer <access_token>`
   - Request body:

```json
{
  "id": "AGENT-SECURITY-01",
  "name": "Security Guard Agent",
  "description": "사내 보안 정책 질의 응답 에이전트",
  "policy_id": null,
  "department_group_id": null,
  "policy_group_ids": [],
  "status": "ACTIVE"
}
```

4. `GET /api/agents`에서 생성 확인

참고:

- 위 단계는 설치 후 최초 1회만 필요합니다.
- `docker compose down -v`로 DB 볼륨을 삭제하면 다시 등록해야 합니다.

## 7) 정상 동작 확인

- 대시보드: `http://localhost:3000`
- API Health: `http://localhost:8000/health`
- Swagger: `http://localhost:8000/docs`

## 8) 자주 발생하는 이슈

### 챗봇이 "게이트웨이와 통신할 수 없습니다"로 실패

- `GET /api/agents`가 비어 있으면 Agent를 먼저 등록해야 합니다.
- `POST /v1/proxy/chat`가 504면 LLM 응답 지연(nginx timeout)일 수 있습니다.

### DB 인증 실패

- `.env`의 `POSTGRES_PASSWORD`와 `DATABASE_URL` 비밀번호가 같은지 확인합니다.
- 비밀번호를 바꾼 경우 `down -v` 후 재기동이 필요할 수 있습니다.
