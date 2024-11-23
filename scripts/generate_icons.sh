#!/bin/bash

cd "$(dirname "$0")/.."

# Source icon
SOURCE="CleanMate/Assets.xcassets/AppIcon.appiconset/icon-1024.png"

# iPhone
convert "$SOURCE" -resize 40x40 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-20@2x.png"
convert "$SOURCE" -resize 60x60 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-20@3x.png"
convert "$SOURCE" -resize 58x58 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-29@2x.png"
convert "$SOURCE" -resize 87x87 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-29@3x.png"
convert "$SOURCE" -resize 80x80 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-40@2x.png"
convert "$SOURCE" -resize 120x120 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-40@3x.png"
convert "$SOURCE" -resize 120x120 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-60@2x.png"
convert "$SOURCE" -resize 180x180 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-60@3x.png"

# iPad
convert "$SOURCE" -resize 20x20 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-20.png"
convert "$SOURCE" -resize 40x40 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-20@2x.png"
convert "$SOURCE" -resize 29x29 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-29.png"
convert "$SOURCE" -resize 58x58 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-29@2x.png"
convert "$SOURCE" -resize 40x40 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-40.png"
convert "$SOURCE" -resize 80x80 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-40@2x.png"
convert "$SOURCE" -resize 76x76 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-76.png"
convert "$SOURCE" -resize 152x152 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-76@2x.png"
convert "$SOURCE" -resize 167x167 "CleanMate/Assets.xcassets/AppIcon.appiconset/icon-83.5@2x.png"

echo "Icon generation complete!"
