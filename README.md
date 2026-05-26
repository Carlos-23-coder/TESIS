# lectoplay

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



### Para instalar las dependecias se hace con 
flutter pub get

## En Fedora GNOME 44

Si usas Fedora 44 con GNOME, primero asegúrate de tener Flutter instalado y agregado al `PATH`.

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
flutter --version
cd ~/TESIS
flutter pub get
```

Si todavía no tienes Flutter instalado, puedes hacerlo así:

```bash
sudo dnf install git curl unzip xz
mkdir -p ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## En Windows

Para compilar o ejecutar en Windows sí necesitas tener activado el modo desarrollador.
