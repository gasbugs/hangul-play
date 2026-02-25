---
name: ci_pipeline_guidelines
description: "CI 파이프라인 구성 지침: 단위, 통합, 보안 테스트 수행 및 자동화 표준"
---

# CI 파이프라인 가이드라인 (CI Pipeline Guidelines)

이 스킬은 안정적인 소프트웨어 배포와 품질 유지를 위한 지속적 통합(Continuous Integration) 파이프라인의 필수 구성 요소를 정의합니다.

## 1. 테스트 자동화 원칙 (Test Automation Principles)

모든 코드 변경 사항은 다음 세 가지 단계의 테스트를 반드시 통과해야 합니다.

- **단위 테스트(Unit Tests)**: 개별 함수 및 클래스의 로직을 검증합니다. 가장 빠른 피드백 루프(Feedback Loop)를 제공해야 합니다.
- **통합/연합 테스트(Integration Tests)**: 모듈 간의 상호작용 및 외부 서비스(DB, API)와의 연결성을 검증합니다.
- **보안 테스트(Security Tests)**: 취약점 스캔(Scanning), 비밀 정보 노출(Secret Leakage), 컨테이너 보안 설정을 검사합니다.

## 2. 파이프라인 운영 지침 (Pipeline Operation)

- **상시 실행(Always Running)**: 모든 커밋(Commit) 또는 풀 리퀘스트(Pull Request) 발생 시 CI 파이프라인이 자동 실행되어야 합니다.
- **실패 시 즉시 중단(Fail Fast)**: 어느 한 단계라도 실패하면 전체 프로세스를 중단하고 개발자에게 즉시 알림을 보내야 합니다.
- **로컬 재현성(Local Reproducibility)**: CI 서버에서 수행되는 모든 검증 단계는 개발자의 로컬 환경(예: `Makefile`)에서도 동일하게 재현 가능해야 합니다.

## 3. 성공 기준 (Success Criteria)

- 코드 커버리지(Code Coverage) 유지 및 향상.
- 정적 분석(Static Analysis) 및 린트(Lint) 에러 제로(Zero) 유지.
- 보안 감사(Security Audit) 통과 및 취약점 없음 확인.

---

**이 가이드라인의 효과:** 휴먼 에러(Human Error) 감소, 코드 품질 상향 평준화, 보안 위협 사전 차단.
