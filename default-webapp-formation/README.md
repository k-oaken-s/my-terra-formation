# Terraform Template

Webアプリケーション向けAWSインフラ構築Terraformテンプレート

## アーキテクチャ

- Multi AZ Public VPC
- ECS Fargate
- RDS（MySQL）
- Auto Scale
- CloudWatch


## クイックスタート

1. リポジトリのクローン：
```bash
git clone https://github.com/k-oaken-s/my-terra-formation.git
```

2. Terraformの初期化：
```bash
terraform init
```

3. 実行プランの確認：
```bash
terraform plan -var-file="terraform.tfvars"
```

4. 設定の適用：
```bash
terraform apply -var-file="terraform.tfvars"
```

## ディレクトリ構成

```
.
├── main.tf          # プロバイダー設定
├── variables.tf     # 変数定義
├── outputs.tf       # 出力定義
├── vpc.tf           # VPCリソース
├── rds.tf           # RDSリソース
├── ecs.tf           # ECSリソース
├── iam.tf           # IAMリソース
├── monitoring.tf    # モニタリングリソース
└── terraform.tfvars # 変数値設定
```
