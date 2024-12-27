## Initializing the cloned repository:

After cloning the repository, start the Studio with Administrator rights and compile the "VmdCmdUtil.src" program. Then restart the Studio without Administrator rights and compile "WriteDateTimeHeaderFile.src", "DoTouchExeFile.src" and lastly the main app: "COMManifestStudio.src".

IMPORTANT NOTE: These programs needs to compiled as 32-bit! Else the intercommunication with COM components won't work.

NOTE 2: The repository uses the DbUpdateFramework repository as a library(!) So if you want to use both the COMManifestStudio and DbUpdateFramework repositories, you only need to clone the COMManifestStudio repository.


