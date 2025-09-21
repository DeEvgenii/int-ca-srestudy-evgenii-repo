variable "project_id" {
  description = "devプロジェクトのID"
  type        = string
}

variable "mig_id" {
    description = "インスタンスグループのID"
    type        = string
}

variable "health_check_id" {
    description = "ヘルスチェックのID"
    type        = string
}
