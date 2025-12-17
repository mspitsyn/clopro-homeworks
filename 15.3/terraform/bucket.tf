## bucket.tf

// Переменные
variable "bucket_name" {
  description = "Name for the storage bucket"
  type        = string
  default     = "mspitsyn-bucket-2025"
}

variable "image_path" {
  description = "Local path to the image file"
  type        = string
  default     = "~/netology/clopro-homeworks/15.3/img/S3-bucket-data.jpeg"
}

variable "kms_key_name" {
  description = "Name for KMS-key"
  type        = string
  default     = "s3-encryption-key"
}


// Создаем сервисный аккаунт для backet
resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "bucket-sa"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on = [yandex_iam_service_account.sa]
}

// Создаем KMS-key 
resource "yandex_kms_symmetric_key" "s3_key" {
  name              = var.kms_key_name
  description       = "Encryption key for S3 bucket"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}


// Создание бакета Object Storage
resource "yandex_storage_bucket" "mspitsyn" {
  bucket    = var.bucket_name
  folder_id = yandex_resourcemanager_folder_iam_member.sa-editor.folder_id
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.s3_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

// Загрузка картинки в бакет
resource "yandex_storage_object" "test-picture" {
  bucket = var.bucket_name
  key    = basename(var.image_path)
  source = var.image_path
  acl    = "public-read"
  depends_on = [yandex_storage_bucket.mspitsyn]
}
