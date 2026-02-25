# 한글 놀이 (Hangul Play) 🎨🧒

아이들을 위한 쉽고 재미있는 한글 학습 웹 애플리케이션입니다.

## 🌟 주요 기능
- **마법 캔버스**: AI 기반 필기 인식 및 채점 시스템으로 한글 쓰기를 연습합니다.
- **낱말 숲**: 단어를 직접 써보고 음성 가이드를 통해 발음을 익힙니다.
- **월드 맵**: 다양한 테마의 학습 공간을 탐험하며 즐겁게 공부합니다.
- **보안 배포**: Docker 및 비권한 유저 설정을 통한 안전한 서비스 제공.

## 🛠 로컬 개발 환경 설정
1.  **환경 변수 설정**: `.env.example` 파일을 복사하여 `.env` 파일을 만들고 Firebase 키를 입력합니다.
2.  **설정 동기화**:
    ```bash
    ./sync_env.sh
    ```
3.  **Flutter 실행**:
    ```bash
    flutter run -d chrome
    ```

## 🐳 Docker 배포
1.  **이미지 빌드**:
    ```bash
    docker build -t hangul-play .
    ```
2.  **컨테이너 실행** (Docker Hub 이미지 사용):
    ```bash
    docker run -d -p 8080:8080 \
      -e FIREBASE_API_KEY="your_api_key" \
      -e FIREBASE_PROJECT_ID="your_project_id" \
      gasbugs/hangul-play:latest
    ```

## 📜 라이선스
이 프로젝트는 **GNU General Public License v3.0 (GPLv3)** 하에 배포됩니다. 모든 수정 및 배포 시 소스 코드를 공개해야 합니다. 상세 내용은 [LICENSE](./LICENSE) 파일을 확인하세요.

---
**Repository**: [https://github.com/gasbugs/hangul-play.git](https://github.com/gasbugs/hangul-play.git)
