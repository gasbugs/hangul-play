---
name: container_security_guidelines
description: "클라우드 네이티브 12 Factor 및 컨테이너 보안 가이드라인: 설정 관리, 무상태성, 최소 권한 및 이미지 최적화 지침"
---

# 컨테이너 보안 및 12 Factor 가이드라인 (Container Security & 12 Factor Guidelines)

이 스킬은 클라우드 네이티브(Cloud Native) 환경에서 애플리케이션의 보안성과 운영 효율성을 극대화하기 위한 설계 및 구현 원칙을 정의합니다.

## 1. 클라우드 네이티브 12 Factor 원칙 (12 Factor App Principles)

현대적인 애플리케이션 운영을 위해 다음 원칙을 준수해야 합니다.

- **설정(Config)**: 설정 정보(Credentials, API Endpoints 등)를 코드에서 엄격히 분리하고 환경 변수(Environment Variables)를 통해 주입하세요.
- **무상태성(Stateless processes)**: 애플리케이션 프로세스는 무상태(Stateless)여야 하며, 공유해야 하는 데이터는 외부 백엔드 서비스(Backing Services, 예: DB, Redis)에 저장하세요.
- **엄격한 분리(Build, Release, Run)**: 빌드(Build), 릴리스(Release), 실행(Run) 단계를 엄격히 분리하여 배포 아티팩트(Artifact)의 변조를 방지하세요.

## 2. 컨테이너 인프라 보안 (Container Infrastructure Security)

컨테이너 환경에서 발생할 수 있는 보안 위협을 최소화하기 위한 지침입니다.

- **최소 권한 원칙(Principle of Least Privilege)**: 컨테이너 내부 프로세스는 절대로 루트(Root) 사용자로 실행하지 마세요. Dockerfile에서 `USER` 명령어를 사용해 비특권 사용자(Non-privileged User)를 지정하세요.
- **이미지 최적화(Image Optimization)**: 공격 표면(Attack Surface)을 줄이기 위해 `alpine`이나 `distroless`와 같은 최소한의 베이스 이미지(Minimal Base Image)를 사용하세요. 불필요한 패키지나 쉘(Shell) 도구를 제거하세요.
- **비밀 정보 관리(Secret Management)**: API 키나 비밀번호와 같은 민감 정보는 이미 안에 포함(Hard-coded)시키지 마세요. Kubernetes Secrets나 Vault와 같은 외부 관리 도구를 활용하세요.
- **네트워크 격리(Network Isolation)**: 필요한 포트(Port)만 노출(Expose)하고, 서비스 간 통신은 최소한의 경로만 허용하도록 설정하세요.

## 3. 지속적인 가상화 보안 (Continuous Security)

- **취약점 스캔(Vulnerability Scanning)**: 이미지 빌드 및 배포 파이프라인(CI/CD)에서 지속적으로 이미지 취약점을 검사하세요.
- **불변 인프라(Immutable Infrastructure)**: 실행 중인 컨테이너에 직접 접속하여 수정하지 마세요. 변경이 필요하면 항상 새로운 이미지를 빌드하여 배포하세요.

---

**이 가이드라인의 효과:** 보안 취약점 노출 방지, 배포 및 확장성(Scalability) 향상, 클라우드 환경으로의 이식성(Portability) 극대화.
