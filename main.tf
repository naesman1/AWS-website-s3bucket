# -----------------------------------------------------------------------------
# 0. VARIABLES Y CONFIGURACIÓN AUTOMÁTICA
# -----------------------------------------------------------------------------

# Variable de Región: Flexible y con valor por defecto
variable "aws_region" {
  description = "La región de AWS donde se desplegará la infraestructura."
  type        = string
  default     = "us-east-1" # N. Virginia por defecto
}

# Genera un nombre de bucket único en cada ejecución 
resource "random_pet" "bucket_name" {
  prefix    = "kcmikelab"
  separator = "-"
  length    = 2
}

# -----------------------------------------------------------------------------
# 1. CONFIGURACIÓN DEL PROVEEDOR
# -----------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# 2. RECURSO DEL BUCKET S3
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "kp_bt_s3_website_static_bucket" {
  # Utiliza el nombre generado automáticamente
  bucket = random_pet.bucket_name.id

  tags = {
    Name    = "Mikelab S3 Static Website Bucket"
    Project = "KC Mikelab AWS"
  }
}

# -----------------------------------------------------------------------------
# 3. CONTROL DE PROPIEDAD DE OBJETOS (Resuelve problemas de ACL y 403)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "kp_bt_s3_ownership_controls" {
  bucket = aws_s3_bucket.kp_bt_s3_website_static_bucket.id
  rule {
    # Necesario para usar la política de bucket pública sin ACLs heredadas.
    object_ownership = "BucketOwnerEnforced"
  }
}

# -----------------------------------------------------------------------------
# 4. BLOQUEO DE ACCESO PÚBLICO (NECESARIO DESACTIVARLO para la política)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "kp_bt_s3_website_static_bucket_pab" {
  bucket = aws_s3_bucket.kp_bt_s3_website_static_bucket.id

  # TODOS deben ser 'false' para permitir la política pública
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# -----------------------------------------------------------------------------
# 5. POLÍTICA DE ACCESO AL BUCKET (PERMITIR s3:GetObject A TODO EL MUNDO)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "kp_bt_s3_website_static_bucket_policy" {
  # Asegura que la política se aplique después de que los controles de seguridad estén listos.
  depends_on = [
    aws_s3_bucket_public_access_block.kp_bt_s3_website_static_bucket_pab,
    aws_s3_bucket_ownership_controls.kp_bt_s3_ownership_controls
  ]

  bucket = aws_s3_bucket.kp_bt_s3_website_static_bucket.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"       = "PublicReadGetObject",
        "Effect"    = "Allow",
        "Principal" = "*",
        "Action"    = "s3:GetObject",
        "Resource" = [
          "${aws_s3_bucket.kp_bt_s3_website_static_bucket.arn}/*" # Aplica a todos los objetos en el bucket
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# 6. CONFIGURACIÓN DEL SITIO WEB ESTÁTICO
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_website_configuration" "kp_bt_s3_website_static_bucket_configuration" {
  bucket = aws_s3_bucket.kp_bt_s3_website_static_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# -----------------------------------------------------------------------------
# 7. CARGA DE OBJETOS (ARCHIVOS HTML)
# -----------------------------------------------------------------------------
# Archivo de índice
resource "aws_s3_object" "kp_bt_s3_website_static_bucket_object_index" {
  bucket       = aws_s3_bucket.kp_bt_s3_website_static_bucket.bucket
  key          = "index.html"
  source       = "index.html"
  source_hash  = filemd5("index.html")
  content_type = "text/html"
}

# Archivo de error
resource "aws_s3_object" "kp_bt_s3_website_static_bucket_object_error" {
  bucket       = aws_s3_bucket.kp_bt_s3_website_static_bucket.bucket
  key          = "error.html"
  source       = "error.html"
  source_hash  = filemd5("error.html")
  content_type = "text/html"
}

# -----------------------------------------------------------------------------
# 8. OUTPUTS REQUERIDOS
# -----------------------------------------------------------------------------
# Muestra el endpoint requerido por la práctica
output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.kp_bt_s3_website_static_bucket_configuration.website_endpoint
  description = "Endpoint de conexión para el Website Estático"
}

# Muestra la URL completa para fácil acceso
output "website_url" {
  value       = "http://${aws_s3_bucket_website_configuration.kp_bt_s3_website_static_bucket_configuration.website_endpoint}"
  description = "URL completa del sitio web estático"
}

# Muestra el nombre del bucket generado automáticamente
output "bucket_final_name" {
  value       = random_pet.bucket_name.id
  description = "El nombre único generado para el bucket S3"
}