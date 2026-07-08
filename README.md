# SDL3Template

Минимальный шаблон проекта использующий SDL3.
Проект состоит из приложения Game и двух статических библиотек: 3rdparty, Engine.
В зависимости включены: SDL3, STB image, nlohmann json.
Проект компилируется: Visual Studio 2026 и GCC через build.bat
Проект можно скомпилировать под emscripten через build_web.bat и протестировать через server_web.bat