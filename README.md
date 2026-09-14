**COM Manifest Studio**

**Program Purpose:**

COMManifestStudio is a specialized tool designed for the efficient management of Registration-Free Component Object Model (COM) components, specifically OCX and DLL files, which are used in isolated applications. The primary function of this software is to create .manifest project files tailored for selected COM/DLL components. This tool is developed using DataFlex, a highly efficient programming language known for its data handling capabilities.

![Sample: COMManifestStudio Program Interface](Bitmaps/COMManifestStudio.png)

**Important Note:** Compiling the program as a 32-bit application is crucial. Failure to do so may lead to ineffective communication with the COM components, resulting in errors or malfunctions in the application. Ensuring that the correct compilation settings are in place will promote smooth operation and prevent potential issues.

This is a DataFlex 26 workspace. It leverages various additional libraries hosted on [NilsSve's GitHub page](https://github.com/NilsSve). You do not need to fetch or manage any of them — the Studio does it for you the first time it opens the workspace.

## Opening the workspace

Open **`COMManifestStudio.sws`** in DataFlex 26 and build. That is the whole
procedure; there is no setup step to run first.

The five libraries this workspace uses — Filesystem, DUF, DFAbout, RDCToolsLib
and vwin32fh — are not stored in this repository. They are dependencies of the
workspace, each pinned to an exact commit in `COMManifestStudio.sws.lock`, and
the Studio's package handler fetches them into `DfPkg\` when the workspace is
first opened. Give it a moment before the first compile. `DfPkg\` is local-only
and is never committed; the lock file is committed, and is what makes your clone
build the same library versions as everyone else's.

Remember to compile as 32-bit — see the note above.

### If you are going to commit here

Run **`setup.bat`** once. It does one thing: it calls `skip-local-data.cmd`, so
that git ignores your own changes to the baseline database under `Data\` and you
cannot push them by accident. If you are only running the program, you can skip
it.
