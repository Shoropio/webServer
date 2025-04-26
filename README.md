# WebServer-Setup for Windows (Git Bash Edition)

¡Bienvenido a **WebServer-Setup**! 🚀

Este script te permite montar un **servidor web completo** en tu máquina local utilizando **Git Bash para Windows** (o compatible con Bash en Windows).
Automatiza la instalación de **Apache/Nginx, PHP, MariaDB/MySQL, Node.js, Python, Composer**, extensiones populares, configuración de **SSL**, **Virtual Hosts** y más.

---

## 📋 Características principales

- Instala PHP, Node.js, Python, MariaDB/MySQL, Apache, Nginx, Composer.
- Generación de certificados SSL locales con `mkcert`.
- Configuración de Virtual Hosts personalizados.
- Descarga automática de binarios oficiales.
- Crea estructura organizada de carpetas.
- Scripts de arranque y control de servicios.
- Compatible **solo con Windows** vía **Git Bash**.
- Menú interactivo para facilitar la instalación.
- Registro de logs detallados.

---

## 📦 Requisitos

- Windows 10 o superior
- [Git Bash](https://gitforwindows.org/) instalado
- [Chocolatey](https://chocolatey.org/) recomendado para mkcert
- Conexión a internet

---

## 🚀 Instalación y uso

1. Clona el repositorio:

   ```bash
   git clone https://github.com/tu-usuario/webserver-setup.git
   cd webserver-setup
   ```

2. Da permisos de ejecución (por si los requiere Git Bash):

   ```bash
   chmod +x webServer-setup.sh
   ```

3. Ejecuta el script:

   ```bash
   ./webServer-setup.sh
   ```

4. Sigue el menú interactivo para instalar los componentes que desees.

---

## 📸 Capturas de ejemplo

![Menú Principal](docs/screenshots/main-menu.png)
![Resumen Instalación](docs/screenshots/installation-summary.png)

_(Capturas opcionales que puedes agregar)_

---

## 💬 Ejemplos rápidos

- **Instalar solo PHP**: selecciona opción `[2]`.
- **Instalar todo el entorno completo**: selecciona opción `[10]`.
- **Crear un Virtual Host seguro con SSL**: opciones `[13]` + `[14]`.
- **Ver resumen de la instalación**: opción `[15]`.

---

## 🤝 Contribuciones

¡Este proyecto es completamente libre!
Siéntete libre de:

- Sugerir mejoras (pull requests).
- Reportar bugs (issues).
- Adaptarlo a tu flujo de trabajo.
- Hacer forks para personalizarlo.

🔧 ¡Toda colaboración es bienvenida!

---

## ☕ ¡Invítame un café!

Si te fue útil este script y quieres apoyar su desarrollo:

> **[Buy me a Coffee ☕](https://buymeacoffee.com/shoropio)**

_(o simplemente deja una ⭐️ en el repositorio, ¡ayuda mucho!)_

---

## 📄 Licencia

Este proyecto se distribuye bajo la **Licencia MIT**.
Eres libre de usarlo, modificarlo, compartirlo y adaptarlo para tus propios proyectos.

---

**Hecho con ❤️ por Shoropio Corporation**
