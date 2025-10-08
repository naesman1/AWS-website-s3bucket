# 🚀 Práctica AWS: Website Estático con Terraform en S3
Este repositorio contiene la solución a la Práctica Final del Bootcamp de AWS. Se utiliza Terraform para desplegar un sitio web estático simple alojado en un bucket de AWS S3.

La plantilla utiliza:

Nombre de Bucket Aleatorio: Usa el recurso random_pet para generar un nombre único, evitando conflictos de estado y errores de timeout (Error: creating S3 Bucket).

Seguridad Moderna: Implementa los estándares actuales de S3 (BucketOwnerEnforced y BlockPublicPolicy=false) para asegurar que el despliegue de la política pública se realice sin errores 403 AccessDenied.

📋 Requisitos Previos
Asegúrate de tener instalado y configurado lo siguiente:

Terraform CLI: Versión 1.0 o superior.

AWS CLI: Configurado y autenticado con un usuario que tenga permisos para crear recursos S3 en la región elegida.

````
.
├── main.tf             # Plantilla principal con la lógica del despliegue y el nombre aleatorio.
├── terraform.tfvars    # Archivo que define la variable de región (por defecto, us-east-1).
├── index.html          # Página principal del sitio web con estilo Pico.css.
├── error.html          # Página personalizada de error 404.
└── README.md           # Este documento.
````

⚙️ Configuración y Despliegue
Sigue estos pasos en tu terminal para desplegar la infraestructura.

1. Clonación del Repositorio
Clona este repositorio de GitHub y navega al directorio del proyecto:

````
git clone https://github.com/naesman1/AWS-website-s3bucket.git
cd AWS-website-s3bucket
````

2. Configuración de la Región (Nota Importante)
La plantilla está configurada por defecto para desplegarse en N. Virginia (us-east-1), leyendo el valor del archivo **terraform.tfvars**.

Si **NO** deseas cambiar la región: No necesitas hacer nada; continúa al paso 3.

Si deseas anular la región (ej: Europa): Puedes editar el archivo terraform.tfvars o usar la línea de comandos.

````
# Ejemplo para desplegar en Irlanda (eu-west-1):
terraform apply -var 'aws_region=eu-west-1'
````

3. Inicialización
Inicializa Terraform para descargar el proveedor de AWS.

````
terraform init
````
✅ Evaluación y Acceso
Una vez que la aplicación finalice exitosamente, Terraform imprimirá los Endpoints de conexión.

Outputs (Ejemplos)
````
#bucket_final_name = "kcmikelab-quick-chamois"
#website_endpoint = "kcmikelab-quick-chamois.s3-website-us-east-1.amazonaws.com"
#website_url = "http://kcmikelab-quick-chamois.s3-website-us-east-1.amazonaws.com"
````
Cómo Acceder y Probar

1.- Página Principal (index.html):
 + Copiar en tu navegador el **website_url** obtenido en los outputs despues de la ejecución y comprobar la pagina principal
 + verificar que te muestre la pagina home 

2.- Página de Error (error.html - Prueba de 404):
 + Añadir a la URL **/test404**
 + verificar que muestre la paginar de error


🗑️ Limpieza (Destrucción de Recursos)
Para eliminar todos los recursos creados por esta práctica y evitar costos en tu cuenta de AWS, ejecuta:

````
terraform destroy
````
Confirma con **yes**.

