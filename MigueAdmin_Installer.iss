; Script generado por SSisty. Finalizado para Flutter Windows.

#define MyAppName "Migue IPhones Administrador"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Migue IPhones"
#define MyAppExeName "migue_admin.exe"

[Setup]
; App ID para el Registro de Windows (no cambiar)
AppId={{30B8C2CA-B8B0-4678-A909-51EF63EFD9B9}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

; Configuración de Arquitectura x64
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes

; Configuración de Salida del Compilador
OutputDir=C:\Users\Manuel\OneDrive\Escritorio\Instaladores
OutputBaseFilename=MigueAdmin
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; --- SECCIÓN CLAVE DE ARCHIVOS ---

; 1. Archivo principal (Ejecutable)
Source: "C:\Users\Manuel\Desktop\Folder\migue-admin\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; 2. DLLs de Flutter y TODOS los Plugins (*_plugin.dll)
; Esta línea resuelve los errores de DLLs faltantes.
Source: "C:\Users\Manuel\Desktop\Folder\migue-admin\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion

; 3. Carpeta de datos (Assets, código Dart, etc.)
Source: "C:\Users\Manuel\Desktop\Folder\migue-admin\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; 4. CORRECCIÓN DE ICONO: Copiar el archivo .ico personalizado al directorio de la app
Source: "C:\Users\Manuel\Desktop\Folder\migue-admin\windows\runner\resources\app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion


[Icons]
; CORRECCIÓN DE ICONO: Forzar el 'IconFilename' para que apunte al archivo .ico
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\app_icon.ico"

[Run]
; CORRECCIÓN DOBLE EJECUCIÓN: La línea está comentada (deshabilitada)
;Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent