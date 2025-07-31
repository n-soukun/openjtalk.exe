@echo off
REM Release creation script for OpenJTalk (Windows)

if "%1"=="" (
    echo Usage: %0 ^<tag_name^>
    echo Example: %0 v1.0.0
    exit /b 1
)

set TAG_NAME=%1

REM Basic validation
echo %TAG_NAME% | findstr /R "^v[0-9]*\.[0-9]*\.[0-9]*$" >nul
if errorlevel 1 (
    echo Error: Tag name must follow semantic versioning format (e.g., v1.0.0)
    exit /b 1
)

echo Creating release for tag: %TAG_NAME%

REM Check if tag already exists
git tag -l | findstr /C:"%TAG_NAME%" >nul
if not errorlevel 1 (
    echo Error: Tag %TAG_NAME% already exists
    exit /b 1
)

REM Create and push tag
echo Creating and pushing tag...
git tag -a %TAG_NAME% -m "Release %TAG_NAME%"
git push origin %TAG_NAME%

echo Tag %TAG_NAME% has been created and pushed.
echo GitHub Actions will automatically build and create the release.
echo Check the Actions tab in your GitHub repository for build progress.
