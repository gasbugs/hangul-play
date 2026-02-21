# 🎨 한글 놀이 (Hangul Play) - Official Docker Image

[![Docker Image Size](https://img.shields.io/docker/image-size/gasbugs/hangul-play/latest)](https://hub.docker.com/r/gasbugs/hangul-play)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**아이들의 상상력을 자극하는 한글 학습 플랫폼, "한글 놀이"의 공식 도커 이미지입니다.**  
이 이미지는 보안 최적화 및 런타임 설정 주입 기술이 적용되어, 어떠한 환경에서도 안전하고 유연하게 실행 가능합니다.

---

## 🚀 Quick Start (빠른 시작)

가장 간단하게 서비스를 시작하는 명령입니다:

```bash
docker run -d \
  --name hangul-play \
  -p 8080:8080 \
  -e FIREBASE_API_KEY="YOUR_API_KEY" \
  -e FIREBASE_PROJECT_ID="YOUR_PROJECT_ID" \
  gasbugs/hangul-play:latest
```

이제 브라우저에서 `http://localhost:8080`으로 접속하세요!

---

## ⚙️ Configuration (환경 설정)

본 이미지는 **Dynamic Configuration Injection** 형식을 사용합니다. 컨테이너 실행 시 다음 환경 변수를 주입하여 자신의 Firebase 프로젝트와 연동할 수 있습니다.

### 필수 환경 변수 (Required)
| 변수명 | 설명 | 예시 |
| :--- | :--- | :--- |
| `FIREBASE_API_KEY` | Firebase API 키 | `AIzaSyB...` |
| `FIREBASE_PROJECT_ID` | 프로젝트 ID | `hangul-nori-kids` |
| `FIREBASE_AUTH_DOMAIN` | 인증 도메인 | `[프로젝트].firebaseapp.com` |
| `FIREBASE_APP_ID` | 애플리케이션 ID | `1:796391589568:web:...` |

### 선택 환경 변수 (Optional)
| 변수명 | 설명 | 기본값 |
| :--- | :--- | :--- |
| `API_URL` | 백엔드 API 주소 | `http://localhost:8080` |
| `ENVIRONMENT` | 실행 환경 모드 | `production` |
| `FIREBASE_STORAGE_BUCKET` | 스토리지 버킷 | `-` |
| `FIREBASE_MESSAGING_SENDER_ID` | 메시징 발신자 ID | `-` |

---

## 🛡️ Security Features (보안 기능)

1. **Non-Root Execution**: 프로세스가 `nginx` 비권한 유저로 실행되어 호스트 시스템을 안전하게 보호합니다.
2. **Minimal Image**: Alpine Linux 기반으로 제작되어 공격 표면을 최소화했습니다.
3. **Runtime Asset Injection**: 소스 코드 내에 비밀 키를 저장하지 않고, 실행 시점에만 메모리와 임시 실정에 주입됩니다.

---

## 📖 Open Source Notice

본 프로젝트는 **GNU GPLv3** 라이선스를 준수합니다.  
전체 소스 코드와 상세 개발 가이드는 [GitHub 저장소](https://github.com/gasbugs/hangul-play)에서 확인하실 수 있습니다.

---

**Developed with ❤️ for kids everywhere.**  
문의 사항이나 기여는 GitHub Issue를 통해 남겨주세요.
