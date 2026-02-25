# 한글 놀이 개발 워크플로우 가이드 (Hangul Play Development Workflow Guide)

이 문서는 프로젝트의 가이드라인(`.agent/skills`)을 준수하며 효율적으로 개발하고 로컬 CI를 수행하는 방법을 설명합니다.

## 1. 개발 전 준비 (Pre-development)
- **가이드라인 숙지**: `.agent/skills` 폴더의 다음 스킬들을 먼저 확인하세요.
    - `karpathy_guidelines`: 코딩 전 사고 및 단순성 유지.
    - `plan_guidelines`: 계획 수립 시 한국어/영어 병기 규칙.

## 2. 개발 및 커밋 (Development & Commit)
- **작은 수술 (Surgical Changes)**: 한 번에 하나의 기능이나 버그만 수정하고, 불필요한 포맷 변경은 피합니다.
- **로컬 검증**: 커밋 전 반드시 다음 명령을 통해 로컬 CI를 수행하세요.
    ```bash
    make check    # 정적 분석 (Lint)
    make test     # 단위 테스트
    make security # 컨테이너 보안 및 12 Factor 감사
    ```
- **전체 검증**: 배포 또는 PR 전에는 `make all`을 실행하여 모든 단계를 확인합니다.

## 3. 컨테이너 보안 및 배포 (Security & Deployment)
- **비전권 사용자**: `Dockerfile` 수정 시 루트(Root) 사용자로 실행되지 않도록 주의하세요 (`container_security_guidelines` 준수).
- **환경 변수**: 중요한 설정값은 `lib/services/config_service.dart`가 참조하는 설정 파일이나 환경 변수를 통해 주입합니다.

## 4. CI/CD 파이프라인 (CI/CD Pipeline)
- **필수 테스트**: 모든 파이프라인은 `ci_pipeline_guidelines`에 따라 단위/통합/보안 테스트를 포함해야 합니다.
- **Fail Fast**: CI 단계 중 하나라도 실패하면 즉시 수정 후 다시 수행합니다.

---
**문의 사항**: 가이드라인 내용이 불분명할 경우 기존 스킬 파일을 업데이트하거나 질문해 주세요.
