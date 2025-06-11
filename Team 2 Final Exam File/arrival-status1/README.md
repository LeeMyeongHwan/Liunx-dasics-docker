# ✈️ 입국장 혼잡도 실시간 시각화 웹서비스

> 공공데이터 API를 활용한 자동 갱신 웹 페이지 구성 프로젝트  
> Docker + Nginx + Shell + Cron 조합으로 **1분마다 실시간 갱신**

---

## 📌 프로젝트 개요

- **목표**: 입국장 혼잡도 정보를 실시간으로 웹에 보여주는 자동화 시스템 구축
- **사용 API**: [공공데이터포털 - 입국장 혼잡도 API](https://www.data.go.kr/tcs/dss/selectApiDataDetailView.do?publicDataPk=15058243)
- **기술 스택**:
  - 🐚 Shell Script (`update_html.sh`)
  - ⏰ Cron (1분마다 자동 실행)
  - 🌐 Nginx (정적 웹 서버)
  - 🐳 Docker (컨테이너화)

---

## 🛠️ 시스템 구조 및 흐름

1. `cron`이 매 1분마다 `update_html.sh`를 실행
2. API 호출 후 실시간 데이터를 이용해 `index.html` 생성
3. 기존 HTML은 `/backups/` 폴더에 타임스탬프 버전으로 자동 백업
4. Nginx는 `/` 경로에서 최신 HTML 제공, `/backups/`에서 백업 목록 확인 가능

---

## 📁 주요 파일 구성

| 파일명                | 설명 |
|------------------------|------|
| `update_html.sh`       | API 호출 및 HTML 파일 생성, 백업 |
| `mycron`               | 크론 실행 설정 파일 (`* * * * *`) |
| `nginx.conf`           | Nginx 설정 파일 (`/`, `/backups/` 라우팅 포함) |
| `Dockerfile`           | 전체 서비스 Docker 이미지 빌드 정의 |
| `작동법.txt`           | 실행 및 접속 방법 설명 |
| `기획, 구현.txt`       | 기획 배경 및 기술 설명 |
| `팀원들 참여 목록.txt` | 각 팀원 역할 설명 |

---

## 🚀 실행 방법 (Docker)

```bash
# 1. 기존 컨테이너 및 이미지 삭제 (선택 사항)
docker rm -f arrival-status1
docker rmi arrival-status1

# 2. 이미지 빌드
docker build -t arrival-status1 .

# 3. 컨테이너 실행
docker run -d -p 8080:80 --name arrival-status1 arrival-status1

# 4. 접속 주소
http://localhost:8080
```

> `http://localhost:8080/backups/` 에서 백업 목록 확인 가능

---

## 👥 팀원

| 이름     | 역할 |
|----------|------|
| 이명환 | 1분 자동 갱신 로직, 백업 사이트 구성, 전체 문서 작성 |
| 최경욱 | API 구조 설계 및 전체 웹 구성 |
| 임진용 | 발표자료 제작 및 발표 |

---

## 📝 참고 사항

- API KEY는 개인 인증키로 발급받아 사용해야 합니다 (보안상 본 저장소에 미포함)
- 테스트 시 공공데이터포털 가입 및 인증키 등록 필수

---

## 📌 결과 예시

> ![예시 스크린샷](https://user-images.githubusercontent.com/your-image-url/preview.png)
