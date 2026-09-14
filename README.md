**COM Manifest Studio**

**Program Purpose:**

COMManifestStudio is a specialized tool designed for the efficient management of Registration-Free Component Object Model (COM) components, specifically OCX and DLL files, which are used in isolated applications. The primary function of this software is to create .manifest project files tailored for selected COM/DLL components. This tool is developed using DataFlex, a highly efficient programming language known for its data handling capabilities.

![Sample: COMManifestStudio Program Interface](Bitmaps/COMManifestStudio.png)

**Important Note:** Compiling the program as a 32-bit application is crucial. Failure to do so may lead to ineffective communication with the COM components, resulting in errors or malfunctions in the application. Ensuring that the correct compilation settings are in place will promote smooth operation and prevent potential issues.

This is a DataFlex 26 workspace. It leverages various additional libraries hosted on [NilsSve's GitHub page](https://github.com/NilsSve). You do not need to manage them by hand — the Studio and `setup.bat` between them provide the lot, as described below.

## Setup after cloning

Open **`COMManifestStudio.sws`** in DataFlex 26. The libraries this workspace
uses (Filesystem, DUF, DFAbout, RDCToolsLib, vwin32fh) are **not** stored in
this repository, and they reach you two ways.

**DUF arrives by itself.** It is a git dependency of the workspace, pinned by
commit, and DFAbout, RDCToolsLib and vwin32fh come with it because DataFlex 26
unions a dependency's own dependencies into the workspace. The Studio fetches
all four the first time it opens the workspace and unpacks them into `DfPkg\`,
at the commits recorded in `COMManifestStudio.sws.lock`. Give it a moment
before the first compile. `DfPkg\` is local-only and never committed.

**Filesystem comes from `setup.bat`.** Run it once from the repository root:

- On a machine with the shared RDC library pool next door (a sibling
  `..\Libraries` carrying the marker file `.rdc-library-pool`), it makes
  `Libraries\` a **junction** to that pool, one shared editable copy.
- Otherwise it **clones** Filesystem into this workspace's own `Libraries\`
  folder, isolated, and it never writes anywhere outside this workspace.

It clones only Filesystem on purpose. A second copy of a library the compiler
never reads is how Go-to-Definition opens the wrong file.

It also runs `skip-local-data.cmd` so your local `Data\` database changes stay
on your machine. `Libraries\` is local-only and never committed — re-run
`setup.bat` any time it looks missing or out of date. (Because `Libraries\` may
be a junction, do not run `git clean -x` here.)
