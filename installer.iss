; ============================================================================
; installer.iss — اسکریپت Inno Setup برای ساخت یک نصب‌کننده‌ی واقعی ویندوزی،
; دقیقاً همان تجربه‌ی "Next, Next, Install" که در نسخه‌ی پایتونی هم داشتید.
;
; نحوه‌ی استفاده:
;   1) اول build_windows.bat را اجرا کنید تا پوشه‌ی
;      build\windows\x64\runner\Release ساخته شود.
;   2) نرم‌افزار رایگان Inno Setup را از innosetup.org دانلود و نصب کنید
;      (اگر قبلاً برای نسخه‌ی پایتونی نصب کرده بودید، همان کافی‌ست).
;   3) همین فایل (installer.iss) را با Inno Setup باز کنید و "Compile" بزنید
;      (یا کلید F9).
;   4) خروجی: یک فایل ClinicAccounting-Setup.exe در پوشه‌ی Output —
;      همین یک فایل را به کلینیک بدهید؛ نه پوشه‌ی build و نه سورس Flutter.
;
; نکته: اگر اسم پروژه‌تان چیزی غیر از clinic_accounting شد (مثلاً موقع
; flutter create اسم دیگری دادید)، خط MyAppExeName پایین را با اسم واقعیِ
; فایل exe داخل پوشه‌ی build\windows\x64\runner\Release هماهنگ کنید.
; ============================================================================

#define MyAppName "نرم‌افزار حسابداری کلینیک"
#define MyAppVersion "1.0"
#define MyAppPublisher "نوراژ"
#define MyAppExeName "clinic_accounting.exe"
#define MyBuildDir "build\windows\x64\runner\Release"

[Setup]
AppId={{9F2C4A1D-7B3E-4C2F-A8D1-CLINICFLTR01}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=ClinicAccounting-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
; اگه فایل آیکون دارید (icon.ico از پروژه‌ی قبلی)، همین‌جا کنار این iss
; بگذارید تا هم نصب‌کننده هم میان‌برها آیکون درست داشته باشند.
;SetupIconFile=icon.ico
;UninstallDisplayIcon={app}\{#MyAppExeName}
; رمز برای نصب‌کننده (اختیاری) — اگر می‌خواهید حتی خودِ Setup.exe هم قبل از
; اجرا رمز بخواهد، خط زیر را از حالت کامنت خارج و رمز دلخواه را بگذارید:
;Password=20232508
;Encryption=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "ایجاد میان‌بر روی دسکتاپ"; GroupDescription: "میان‌برهای اضافی:"

[Files]
; کل خروجیِ ساخته‌شده‌ی Flutter (exe + dll های لازم + پوشه‌ی data) را کپی می‌کند
Source: "{#MyBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "اجرای برنامه"; Flags: nowait postinstall skipifsilent
