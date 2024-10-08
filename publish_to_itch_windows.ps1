﻿# Settings -------------------------------
$BUTLER_PATH = "$ENV:AppData\itch\apps\butler\butler.exe"
$GODOT_PATH = "C:\stuff\Godot_v4.3-stable_win64.exe"
$ITCH_USER = "enweave"
$ITCH_GAME = "stranded-post-jam"
$ITCH_CHANNEL = "windows"
$GODOT_TEMPLATE = "`"Windows Desktop`""
$EXPORT = "--export-release" # "--export-debug" or "--export-release"
$BUILD_DIR = "build"

# settings end ---------------------------

# building

$VERSION = git log -1 --format="%h"
$EXECUTABLE = "$BUILD_DIR/stranded.exe"

# create directory if doesn't exist
if (!(Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory -Path $BUILD_DIR
}
else
{
    Remove-Item -Recurse -Force $BUILD_DIR
    New-Item -ItemType Directory -Path $BUILD_DIR
}

$godotStartParams = @{
    FilePath     = $GODOT_PATH
    ArgumentList = $EXPORT, '--headless', $GODOT_TEMPLATE, $EXECUTABLE
    Wait         = $true
    PassThru     = $true
}
$proc = Start-Process @godotStartParams
$proc.ExitCode

echo "Build done, uploading to itch.io"

$butlerStartParams = @{
    FilePath     = $BUTLER_PATH
    ArgumentList = "push", $BUILD_DIR, "$ITCH_USER/$ITCH_GAME`:$ITCH_CHANNEL", "--userversion", $VERSION
    Wait         = $true
    PassThru     = $true
}
$proc = Start-Process @butlerStartParams
$proc.ExitCode

echo "Uploading done"