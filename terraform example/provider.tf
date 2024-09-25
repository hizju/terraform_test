
# AWS 프로바이더 설정
provider "aws" {
  region = "ap-northeast-2"
  shared_credentials_files =  ["~/.aws/credentials"]
  profile = "nsj"
  # 환경 변수를 사용하여 자격 증명 설정
  # AWS_ACCESS_KEY_ID와 AWS_SECRET_ACCESS_KEY 환경 변수를 설정해야 합니다.
  # 또는 ~/.aws/credentials 파일에 프로파일을 설정하여 사용할 수 있습니다.
}

terraform {
  required_version = ">= 1.0.0"
}
