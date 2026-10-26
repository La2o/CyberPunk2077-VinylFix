@echo off
rem Builds red4ext\plugins\VinylFix\VinylFix.dll with the VS 2022 C++ build tools.
setlocal
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSDIR=%%i"
if not defined VSDIR (
  echo Visual Studio C++ build tools not found.
  exit /b 1
)
call "%VSDIR%\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1

cd /d "%~dp0"
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release || exit /b 1
cmake --build build || exit /b 1

if not exist red4ext\plugins\VinylFix mkdir red4ext\plugins\VinylFix
copy /y build\VinylFix.dll red4ext\plugins\VinylFix\VinylFix.dll >nul || exit /b 1
echo Built red4ext\plugins\VinylFix\VinylFix.dll
