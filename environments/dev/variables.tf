variable "project_id" {
    description = "devプロジェクトのID"
    type = string
    default = "ca-srestudy-evgenii-lift-dev"
}

variable "region" {
    description = "GCPリージョン"
    type = string
    default = "asia-northeast1"
}

variable "zone" {
    description = "GCPゾーン"
    type = string
    default = "asia-northeast1-a"
}

