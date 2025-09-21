variable "project_id" {
    description = "devプロジェクトのID"
    type        = string
}

variable "region" {
    description = "GCPリージョン"
    type        = string
}

variable "network_self_link" {
    description = "VPCネットワークのセルフリンク"
    type        = string
}

variable "service_networking_connection_id" {
    description = "VPCコネクションID"
    type        = string
}
