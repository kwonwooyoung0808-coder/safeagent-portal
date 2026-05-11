# SafeAgent Manager 설치 및 반영 가이드

## 1. 배포 파일 준비

1. `safeagent-deployment-bundle.zip` 파일을 다운로드하고 압축을 해제합니다.
2. 압축 해제 후 아래 파일이 있는지 확인합니다.
   - `.env.release.example`
   - `docker-compose.release.yml`
   - `install.bat`
   - `install.sh`
3. 설치를 시작하기 전에 `.env.release.example` 파일을 `.env`로 복사하거나 이름을 변경합니다.

예시:

### Windows
```powershell
Copy-Item .env.release.example .env
```

### Linux
```bash
cp .env.release.example .env
```

## 2. `.env` 파일에서 반드시 확인할 항목

`.env` 파일은 일반 텍스트 파일입니다. VS Code가 없어도 메모장, Notepad++, nano 등으로 열어서 수정할 수 있습니다.

### 반드시 수정할 항목

- `DATABASE_URL`
  - 예시 비밀번호 `change_me`를 실제 사용할 비밀번호로 변경해야 합니다.

예시:

```env
DATABASE_URL=postgresql://safeagent_app:MyStrongPassword123@postgres:5432/safeagent
```

### 환경에 따라 확인할 항목

- `GOVERNANCE_LLM_URL`
- `SOVEREIGN_AI_URL`
- `SAFE_RESPONSE_LLM_URL`
  - LLM 서버 주소가 현재 환경과 다르면 실제 주소로 수정해야 합니다.

- `SAFEAGENT_API_IMAGE`
- `SAFEAGENT_FRONTEND_IMAGE`
  - 다른 이미지 레지스트리나 태그를 사용할 경우 수정합니다.

### 보통 그대로 사용 가능한 항목

- `APP_NAME`
- `APP_VERSION`
- `UPDATE_CHANNEL`
- `POLICY_DIR`
- `PROMPT_DIR`
- `WORKFLOW_NAME`
- `SYSTEM_INPUT_POLICY_ID`
- `ENABLE_SELF_CONSISTENCY`

## 3. 서버 환경 준비

- Docker Engine과 Docker Compose를 설치합니다.
- `3000`, `8000`, `5432` 포트를 사용할 수 있는지 확인합니다.
- 방화벽 또는 보안 정책에서 Docker 실행과 포트 접근이 허용되는지 확인합니다.

## 4. 권장 설치 방법

### Windows 서버
```bat
install.bat
```

### Linux 서버
```bash
chmod +x install.sh
./install.sh
```

설치 스크립트는 같은 폴더에 `safeagent-api-v0.2.0.tar`, `safeagent-portal-v0.2.0.tar` 파일이 있으면 오프라인 설치를 우선 사용하고, 없으면 온라인 레지스트리에서 이미지를 내려받습니다.

## 5. 온라인 설치 방식

인터넷 연결이 가능한 환경에서는 아래 명령으로 Docker 이미지를 받아서 실행합니다.

```bash
docker compose -f docker-compose.release.yml pull
docker compose -f docker-compose.release.yml up -d
```

## 6. 오프라인 설치 방식

별도로 제공된 `.tar` 이미지 파일이 있는 경우 아래 순서로 실행합니다.

```bash
docker load -i safeagent-api-v0.2.0.tar
docker load -i safeagent-portal-v0.2.0.tar
docker compose -f docker-compose.release.yml up -d
```

## 7. 마이그레이션 실행

컨테이너가 올라온 뒤 아래 명령으로 데이터베이스 마이그레이션을 수행합니다.

```bash
docker compose -f docker-compose.release.yml exec api python -m scripts.run_migrations
```

## 8. 반영 결과 확인

- `http://<server>:3000` 에서 프론트 화면이 열리는지 확인합니다.
- `http://<server>:8000/health` 에서 API 상태를 확인합니다.
- 필요하면 `http://<server>:8000/docs` 에서 Swagger UI를 확인합니다.

## 9. 참고 사항

- 현재 배포 방식은 소스코드 수정 방식이 아니라 Docker 이미지 실행 방식입니다.
- 일반 사용자는 VS Code가 없어도 설치할 수 있습니다.
- `.env` 파일 수정은 메모장 같은 일반 텍스트 편집기로도 가능합니다.

## 10. 롤백 계획

- 직전 안정 버전의 이미지 태그를 별도로 보관합니다.
- 배포 후 health 체크에 실패하면 이전 이미지 태그로 되돌린 뒤 서비스를 다시 시작합니다.
