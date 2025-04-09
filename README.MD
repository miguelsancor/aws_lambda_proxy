# Proyecto de Infraestructura - API Gateway con Lambda Authorizer

Este proyecto en Terraform crea una arquitectura de microservicios expuesta por **API Gateway HTTP v2** protegida mediante un **Lambda Authorizer** personalizado (JWT con Auth0), y expone tres endpoints:

- `GET /hello`
- `GET /hola1`
- `GET /hola2`

Todos los endpoints están protegidos mediante autorización por token JWT.

---

## 🚀 Requisitos Previos

- Cuenta en AWS con permisos suficientes (IAM, Lambda, API Gateway, ACM).
- Terraform >= 1.0
- Node.js >= 18 (para desarrollo local de Lambdas)
- Auth0 (u otro proveedor JWT compatible con JWKS)

---

## 🌐 Recursos que se crean

- 4 Lambdas:
  - `helloLambda`: responde "Hola mundo"
  - `hola1Lambda`: responde "Hola mundo 1"
  - `hola2Lambda`: responde "Hola mundo 2"
  - `authorizerLambda`: valida tokens JWT

- API Gateway HTTP v2
  - 3 rutas protegidas por Lambda Authorizer

- IAM Role para ejecución de Lambdas
- Permisos para invocación desde API Gateway
- Etapa `$default` para despliegue automático

---

## 🔧 Estructura de archivos

```
├── lambda/
│   ├── index.js
│   ├── hola1.js
│   ├── hola2.js
│   └── authorizer.js
├── main.tf
└── variables.tf (opcional)
```

---

## ⚡ Cómo usar este proyecto

### 1. Inicializa Terraform

```bash
terraform init
```

### 2. Empaqueta tus funciones Lambda

```bash
cd lambda
npm init -y
npm install jsonwebtoken jwks-rsa

Compress-Archive -Path lambda/index.js -DestinationPath lambda/index.zip -Force
Compress-Archive -Path lambda/hola1.js -DestinationPath lambda/hola1.zip -Force
Compress-Archive -Path lambda/hola2.js -DestinationPath lambda/hola2.zip -Force
Compress-Archive -Path lambda/authorizer.js -DestinationPath lambda/authorizer.zip -Force
```

### 3. Aplica la infraestructura

```bash
terraform apply -auto-approve
```

### 4. Prueba con Postman

Realiza peticiones GET a:

```
https://<tu-api-id>.execute-api.<region>.amazonaws.com/hello
https://<tu-api-id>.execute-api.<region>.amazonaws.com/hola1
https://<tu-api-id>.execute-api.<region>.amazonaws.com/hola2
```

Incluyendo el header:

```
Authorization: Bearer <tu_token_jwt>
```

---

## 📅 Personalizar con dominio propio (opcional)

Para usar un dominio como `https://api.tudominio.com`, descomenta el bloque de "Dominio Personalizado" en el `main.tf`.

Pasos:

1. Proveer tu dominio (ej: `api.tudominio.com`)
2. Validar el certificado SSL generado en ACM (por DNS)
3. Crear el registro en tu proveedor DNS o usar el bloque de `aws_route53_record`

---

## 🔐 Seguridad

- El Lambda Authorizer valida tokens JWT emitidos por Auth0 (se puede adaptar a otros emisores)
- Se utiliza RS256 con JWKS

---

## 🚫 Eliminación de recursos

Para eliminar todo:

```bash
terraform destroy -auto-approve
```

---

## ✉️ Soporte

Para soporte técnico, dudas o sugerencias, contacta con el desarrollador del proyecto.

---

**Desarrollado con ❤ por [TuNombre o TuEmpresa]**

