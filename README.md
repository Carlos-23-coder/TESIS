# LectoPlay

LectoPlay es una aplicacion movil educativa desarrollada en Flutter para apoyar la comprension lectora en ninos mediante actividades interactivas, niveles, recompensas, seguimiento del progreso y acompanamiento de tutores.

El proyecto esta orientado a estudiantes con dificultades de lectura, baja motivacion o necesidades de apoyo en la atencion, incluyendo caracteristicas asociadas al TDAH. La aplicacion combina lectura, juegos cognitivos, estrellas, recompensas y paneles diferenciados para administrador, tutor y alumno.

## Caracteristicas principales

- Inicio de sesion por roles: Admin, Tutor y Alumno.
- Registro de alumnos.
- Creacion de tutores desde el modulo administrador.
- Visualizacion de tutores y alumnos registrados.
- Actividades de lectura por niveles.
- Juego de Idea Principal.
- Juego de Preguntas Rapidas con temporizador.
- Narrador de texto mediante TTS.
- Sistema de estrellas por desempeno.
- Recompensas administradas por el tutor.
- Solicitudes de recompensas por parte del alumno.
- Panel del tutor con estadisticas, ranking y progreso.
- Personalizacion de historias y preguntas.
- Accesibilidad: modo oscuro, tamano de letra, musica de fondo y volumen.
- Alto contraste y escalado de texto hasta 200%.
- Usabilidad y accesibilidad documentadas con WCAG 2.2 AA, ISO 9241-11:2018 e ISO/IEC 25010:2011.
- Funcionamiento hibrido online/offline con SQLite y Firebase.

## Roles del sistema

### Administrador

El administrador gestiona la estructura general del sistema.

Funciones:

- Crear cuentas de tutores.
- Ver tutores registrados.
- Ver alumnos registrados.
- Acceder al panel administrativo.

Credenciales locales de prueba:

```text
Rol: Admin
Correo: admin@lectoplay.com
Contrasena: Admin1234
PIN: 0000
```

### Tutor

El tutor acompana el proceso de aprendizaje del alumno.

Funciones:

- Gestionar recompensas.
- Aprobar o revisar solicitudes de recompensas.
- Ver el progreso de alumnos.
- Consultar estadisticas y ranking.
- Personalizar historias y preguntas.
- Editar su perfil.

Credenciales locales de prueba:

```text
Rol: Tutor
Correo: tutorjohn@gmail.com
Contrasena: John1234
PIN: 1234
```

### Alumno

El alumno realiza las actividades lectoras y gana estrellas.

Funciones:

- Acceder a juegos de lectura.
- Completar niveles.
- Ganar estrellas.
- Solicitar recompensas.
- Editar perfil.
- Usar opciones de accesibilidad.

## Tecnologias utilizadas

| Elemento | Tecnologia |
|---|---|
| Framework | Flutter |
| Lenguaje principal | Dart |
| Android | Kotlin / Gradle |
| iOS | Swift / Xcode |
| Autenticacion | Firebase Authentication |
| Base de datos online | Cloud Firestore |
| Base de datos local | SQLite con sqflite |
| Sincronizacion | connectivity_plus |
| Imagenes | image_picker |
| Audio | audioplayers |
| Texto a voz | flutter_tts |
| Graficos | fl_chart |
| PDF / impresion | pdf, printing |

## Funcionamiento online y offline

LectoPlay funciona bajo una modalidad hibrida online/offline.

En modo online:

- Inicia sesion con Firebase Authentication.
- Guarda usuarios en Cloud Firestore.
- Sincroniza progreso, recompensas, solicitudes e historias.
- Permite consultar datos actualizados desde la nube.

En modo offline:

- Permite iniciar sesion con usuarios guardados localmente.
- Guarda progreso en SQLite.
- Conserva configuraciones de accesibilidad por usuario.
- Permite continuar actividades disponibles.
- Guarda datos pendientes para sincronizarlos cuando vuelva la conexion.

Nota: las imagenes guardadas como rutas locales solo existen en el dispositivo donde fueron creadas. Para que una foto se vea en todos los celulares, debe subirse a Firebase Storage y guardarse una URL publica o de descarga en Firestore.

## Accesibilidad y usabilidad

LectoPlay toma como referencia WCAG 2.2 nivel AA para accesibilidad, ISO 9241-11:2018 para usabilidad e ISO/IEC 25010:2011 como apoyo de calidad de software. La app implementa modo oscuro, alto contraste, escalado de texto hasta 200%, controles tactiles amplios, retroalimentacion inmediata, narrador de texto y preferencias persistidas por usuario.

La justificacion tecnica esta documentada en `docs/accesibilidad_usabilidad.md`.

## Estructura del proyecto

```text
lib/
  core/
    accessibility/
    game_engine/
    widgets/
  data/
    database/
    models/
    repositories/
    services/
  games/
    idea_principal/
    preguntas_rapidas/
  presentation/
    admin/
    profile/
    screens/
    tutor/

assets/
  images/
  sounds/

android/
ios/
web/
windows/
linux/
macos/
```

## Requisitos previos

Antes de ejecutar el proyecto se necesita:

- Flutter SDK instalado.
- Dart incluido con Flutter.
- Android Studio o Android SDK configurado.
- Un dispositivo Android fisico o emulador.
- Firebase configurado para Android.

Verificar el entorno:

```bash
flutter doctor
```

Si aparece un error de Visual Studio en Windows, no afecta la generacion de APK para Android. Solo afecta si se desea compilar la version de escritorio para Windows.

## Instalacion del proyecto

Clonar o abrir el proyecto:

```bash
cd C:\Users\Usuario\Desktop\lectoplay
```

Instalar dependencias:

```bash
flutter pub get
```

Limpiar compilaciones anteriores:

```bash
flutter clean
flutter pub get
```

## Ejecutar en Android

Conectar un celular Android con depuracion USB activada o abrir un emulador.

Ver dispositivos disponibles:

```bash
flutter devices
```

Ejecutar la app:

```bash
flutter run
```

## Generar APK para compartir

Crear APK en modo release:

```bash
flutter build apk --release
```

El archivo generado queda en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Ruta completa en este proyecto:

```text
C:\Users\Usuario\Desktop\lectoplay\build\app\outputs\flutter-apk\app-release.apk
```

Ese archivo se puede compartir por cable USB, Google Drive, WhatsApp, correo u otro medio.

Para instalarlo en otro celular Android:

1. Copiar o enviar `app-release.apk` al celular.
2. Abrir el archivo desde el celular.
3. Permitir la instalacion desde fuentes desconocidas si Android lo solicita.
4. Instalar y abrir LectoPlay.

Nota: actualmente el proyecto usa firma de depuracion para release en Android. Esto sirve para pruebas y distribucion manual. Para publicar en Play Store se debe crear una firma release oficial.

## Compatibilidad con Android e iOS

LectoPlay es un proyecto Flutter multiplataforma y contiene estructura para Android e iOS.

Android:

- Se puede compilar desde Windows.
- Se puede generar APK.
- Se puede instalar manualmente en celulares Android.

iOS:

- El proyecto es compatible con iOS.
- Para compilar en iPhone se necesita macOS.
- Se requiere Xcode.
- Se requiere configurar firma con una cuenta de Apple.
- Para distribuir formalmente se necesita generar un IPA desde Xcode o Flutter en macOS.

Comando de referencia en macOS:

```bash
flutter build ios --release
```

## Firebase

El proyecto utiliza:

- Firebase Authentication.
- Cloud Firestore.

En Android, el archivo de configuracion se encuentra en:

```text
android/app/google-services.json
```

Si se configura iOS, se debe agregar el archivo correspondiente:

```text
ios/Runner/GoogleService-Info.plist
```

## Base de datos local

La app usa SQLite para almacenamiento local.

Base local:

```text
lectoplay.db
```

Tablas principales:

- users
- progress
- rewards
- rapid_questions
- story_overrides
- reward_claims
- app_settings

## Modulos principales

### Modulo de administrador

Permite crear tutores y visualizar usuarios registrados.

### Modulo de autenticacion

Permite iniciar sesion por rol y registrar alumnos.

### Modulo de lectura

Incluye actividades de comprension mediante historias y preguntas.

### Modulo de juegos cognitivos

Incluye Preguntas Rapidas con temporizador y retroalimentacion.

### Sistema de puntos

Otorga estrellas segun el desempeno del alumno.

### Sistema de recompensas

Permite canjear o solicitar recompensas segun estrellas acumuladas.

### Panel del tutor

Muestra estadisticas, ranking y progreso de alumnos.

### Accesibilidad

Incluye modo oscuro, tamano de letra, musica de fondo y volumen.

## Recursos del proyecto

Imagenes:

```text
assets/images/
```

Sonidos:

```text
assets/sounds/
```

## Comandos utiles

Instalar dependencias:

```bash
flutter pub get
```

Analizar el proyecto:

```bash
flutter analyze
```

Ejecutar pruebas:

```bash
flutter test
```

Ejecutar app:

```bash
flutter run
```

Crear APK:

```bash
flutter build apk --release
```

Limpiar proyecto:

```bash
flutter clean
```

## Estado del proyecto

LectoPlay se encuentra en desarrollo academico. La aplicacion ya cuenta con funcionalidades principales para administrador, tutor y alumno, integracion con Firebase, almacenamiento local SQLite, actividades lectoras, recompensas, progreso y accesibilidad.

## Autor

Proyecto desarrollado como parte de un trabajo academico orientado al apoyo de la comprension lectora mediante tecnologia movil.
