# Unreal Project Tools

## Build Tool

To use this batch file correctly, place the folder from inside the zip into the root of your Unreal Project.

### BEFORE USE

- You must set your engine path in the `settings.properties` file.
- The UnrealEnginePath variable should be where the engine itself is installed. The path should include the folder `UE_<MajorVersion>.<MinorVersion>`, but should not have a slash at the end. The default install position is located at `C:\Program Files\Epic Games\UE_<MajorVersion>.<MinorVersion>`

### OPTIONS

- There is an optional property, WaitOnEnd included in the properties file. It is set to true by default, but if you don't want the batch to pause upon completion you can set this to false.

## Submission Check

The submission check script currently only runs through the Visual Studio project which has a matching name with the project.

It currently searches for any occurences of pragma optimize, opening any files it finds containing it, and closing itself afterward.

## Other Notes

- Any logs created by the scripts can be found in the Logs folder.
- By default the folder containing these scripts should be placed in the root of your project.
- Alternatively you can call the script from another location and pass in the folder it will run from as the first parameter via command line or another batch script. (This can be useful if you want to use it in multiple projects without having to manage it in many places)
