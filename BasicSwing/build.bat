@echo off
:: Recibir el nombre del proyecto como parámetro desde IntelliJ
rem set PROYECTO_NAME=%1
SET JAVA_HOME=C:\Users\25707045Z\AppData\Local\graalvm-jdk-25
for %%I in (%cd%) do set PROYECTO_NAME=%%~nxI

if "%PROYECTO_NAME%"=="" (
    echo [ERROR] No se ha proporcionado el nombre del proyecto.
    echo Uso manual: build-native.bat NombreDelProyecto
    pause
    exit /b
)

echo =======================================================
echo  AUTOMATIZACION GRAALVM - PROYECTO: %PROYECTO_NAME%
echo =======================================================

:: 1. Limpieza de binarios previos en la raiz
echo [1/5] Limpiando binarios antiguos...
del /q *.exe *.obj *.pdb *.lib *.exp *.dll 2>nul
if not exist out\native mkdir out\native
if not exist out\native\lib mkdir out\native\lib

:: 2. Cargar las variables de entorno de Visual Studio 2022 (MSVC)
echo [2/5] Cargando entorno de Visual Studio 2022...
:: Usamos /v:off para evitar que vcvars64 altere el flujo del script
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul

:: 3. Ejecutar el java y el Agente de GraalVM
echo [3/5] Ejecutar el jar con el Agente de GraalVM
java -agentlib:native-image-agent=config-output-dir=src\META-INF\native-image -jar out\artifacts\%PROYECTO_NAME%.jar

echo [4/5] Copiando recursos de fuentes (JDK 25)...

copy /Y "%JAVA_HOME%\lib\fontconfig.bfc" "out\native\lib"
copy /Y "%JAVA_HOME%\lib\fontconfig.properties.src" "out\native\lib"

:: 4. Compilar la aplicación nativa usando GraalVM detectando el JAR dinámicamente
echo [5/5] Compilando imagen nativa con GraalVM...

rem native-image -Os -Djava.awt.headless=false -H:ConfigurationFileDirectories=src\META-INF\native-image -H:Path=out\native -H:NativeLinkerOption=/ENTRY:mainCRTStartup -H:Name=%PROYECTO_NAME% -jar out\artifacts\%PROYECTO_NAME%.jar
native-image -Os -Djava.awt.headless=false -H:ConfigurationFileDirectories=src\META-INF\native-image -H:Path=out\native -H:NativeLinkerOption=/ENTRY:mainCRTStartup -H:NativeLinkerOption=/SUBSYSTEM:WINDOWS -H:Name=%PROYECTO_NAME% -jar out\artifacts\%PROYECTO_NAME%.jar

echo =======================================================
echo ¡Proceso finalizado con exito! Puedes cerrar esta ventana.
echo =======================================================
pause