# COMManifestStudio

**Purpose:** Managing Registration-Free COM (OCX/DLL) Components for Isolated Applications. The program COMManifestStudio creates .manifest project files for selected COM/DLL components. This is a DataFlex project.

## Initializing the Cloned Repository

After cloning the repository, follow these steps:

1. Start the Studio with Administrator rights and compile the `VmdCmdUtil.src` program.
2. Restart the Studio with normal rights and compile the following programs in order:
   - `WriteDateTimeHeaderFile.src`
   - `DoTouchExeFile.src`
   - `COMManifestStudio.src` (main app)

![Sample: COM Manifest Studio Program Interface](Bitmaps/COMManifestStudio.png)

**IMPORTANT NOTE:** These programs need to be compiled as 32-bit! Otherwise, the intercommunication with COM components won't work.

The workspace also uses other libraries that are published on [NilsSve's GitHub page](https://github.com/NilsSve). This should not be of any concern as it should all be automatic when cloning this repository. These libraries are used as submodules in git.
