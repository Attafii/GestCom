@echo off
echo Generating Hive TypeAdapters and Riverpod providers...
flutter packages get
flutter packages pub run build_runner build --delete-conflicting-outputs
echo Build completed!