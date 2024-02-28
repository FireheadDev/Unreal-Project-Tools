To use this batch file correctly, place the folder from inside the zip into the root of your Unreal Project.

BEFORE USE:
- You must set your engine path, and project name in the included .properties file.
- The UnrealEnginePath should be where the engine itself is installed. It should include the folder UE_MajorVersion.MinorVersion, but should NOT have a slash at the end.
- Your project name should match exactly with your .uproject file name, without the extension.

OPTIONS:
- There is an optional property, WaitOnEnd included in the properties file. It is set to true by default, but if you don't want the batch to pause upon completion you can set this to false.