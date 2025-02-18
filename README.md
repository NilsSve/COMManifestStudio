# **COMManifestStudio**

**Purpose:** This tool is designed for managing Registration-Free COM (OCX/DLL) components for isolated applications. COMManifestStudio creates .manifest project files for selected COM/DLL components and is built as a DataFlex project.

## Initializing the Cloned Repository

After cloning the repository, follow these steps:

1. Launch the Studio with Administrator rights and compile the `VmdCmdUtil.src` program.
2. Restart the Studio with normal user rights and compile the following programs in this order:
   - `WriteDateTimeHeaderFile.src`
   - `DoTouchExeFile.src`
   - `COMManifestStudio.src` (main application)

![Sample: COM Manifest Studio Program Interface](Bitmaps/COMManifestStudio.png)

**IMPORTANT NOTE:** These programs must be compiled as 32-bit. If not, intercommunication with COM components will not function correctly.

The workspace also utilizes other libraries published on [NilsSve's GitHub page](https://github.com/NilsSve). However, this should not be a concern, as these libraries will be automatically handled when cloning the repository. They are included as git submodules.
