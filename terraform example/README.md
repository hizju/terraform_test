
# Terraform을 사용한 AWS 3티어 아키텍처 구축

이 프로젝트는 Terraform을 사용하여 AWS에 3티어 아키텍처를 구축하는 방법을 설명합니다. 
3티어 아키텍처는 일반적으로 웹 계층, 애플리케이션 계층, 데이터베이스 계층으로 나뉩니다.

## 프로젝트 구조

```
terraform-aws-3tier-with-provider/
├── main.tf                 # 루트 모듈, 네트워크, 애플리케이션 및 데이터베이스 모듈 호출
├── network/                # 네트워크 계층
│   └── main.tf             # VPC, 서브넷, 보안 그룹, IGW, NAT 게이트웨이, ALB 보안 그룹 설정
├── app/                    # 애플리케이션 계층
│   └── main.tf             # EC2 인스턴스, ALB 및 관련 설정
├── database/               # 데이터베이스 계층
│   └── main.tf             # RDS 인스턴스 및 관련 설정
├── provider.tf             # AWS 프로바이더 설정 (환경 변수 사용)
└── README.md               # 프로젝트 설명
```

## 구성 요소

### 네트워크 계층 (`network/main.tf`)

- **VPC**: 10.0.0.0/16 CIDR 블록을 사용하여 AWS 내에서 격리된 네트워크를 생성합니다.
- **퍼블릭 서브넷**: 퍼블릭 IP가 할당되어 인터넷 접근이 가능한 서브넷입니다.
- **프라이빗 서브넷**: 인터넷 접근이 불가능한 서브넷입니다. NAT 게이트웨이를 통해 인터넷에 접근할 수 있습니다.
- **인터넷 게이트웨이 (IGW)**: 퍼블릭 서브넷이 외부 인터넷과 통신할 수 있도록 해줍니다.
- **NAT 게이트웨이**: 프라이빗 서브넷에서 외부 인터넷으로 나가는 트래픽을 허용합니다.
- **라우팅 테이블**: 퍼블릭 서브넷은 IGW를, 프라이빗 서브넷은 NAT 게이트웨이를 통해 라우팅됩니다.
- **보안 그룹**: 웹 서버와 ALB, 데이터베이스 서버의 인바운드 및 아웃바운드 트래픽을 제어합니다.

### 애플리케이션 계층 (`app/main.tf`)

- **EC2 인스턴스**: AMI와 인스턴스 유형을 지정하여 웹 서버를 생성하며, private 서브넷에 배치됩니다.
- **보안 그룹**: EC2 인스턴스는 ALB에서만 접근 가능하도록 설정됩니다.
- **키 페어**: EC2 인스턴스에 접근하기 위한 SSH 키를 설정합니다.
- **PEM 키 파일**: 로컬 파일로 생성된 PEM 키를 저장하고, 이를 사용하여 SSH 접속을 허용합니다.
- **ALB (Application Load Balancer)**: 퍼블릭 서브넷에 배치되어 웹 트래픽을 관리하며, EC2 인스턴스에 트래픽을 전달합니다.

### 데이터베이스 계층 (`database/main.tf`)

- **RDS 인스턴스**: MySQL, PostgreSQL 등 다양한 데이터베이스 엔진을 선택할 수 있습니다.
- **DB 서브넷 그룹**: 다중 가용 영역을 커버하는 서브넷 그룹을 정의합니다.
- **보안 그룹**: 데이터베이스 접근을 제한하여 보안을 강화합니다.

## 사용 방법

1. **프로젝트 초기화**
    ```bash
    terraform init
    ```

2. **계획 확인**
    ```bash
    terraform plan
    ```

3. **인프라 적용**
    ```bash
    terraform apply
    ```

4. **인프라 삭제**
    ```bash
    terraform destroy
    ```

## AWS 자격 증명 설정

AWS에 접근하기 위해서는 `AWS_ACCESS_KEY_ID`와 `AWS_SECRET_ACCESS_KEY` 환경 변수를 설정하거나, 
`~/.aws/credentials` 파일에 자격 증명 정보를 설정해야 합니다.

환경 변수 설정 예시:
```bash
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
```

## 참고 자료

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS VPC](https://docs.aws.amazon.com/vpc)
