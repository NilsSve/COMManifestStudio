//****************************************************************************
// $Module type: View
// $Module name: DbMergerViewNew
// $Author     : Nils Svedmyr, RDC Tools International, <mailto:support@rdctools.com>
//
// Description : The main view: one manifest - its file, its fragment files, its notes - and the dashboard of the
//               steps that make and deploy it.
//
//               ALL OF IT FLEXTRON WEB CONTROLS (RDCFlexTron), since 2026-11-14: ONE data-aware host
//               (cFTDbGridHost) on the manifest's data dictionary fills the view. Native controls could not take
//               the dark theme - Windows paints their borders, tab headers and buttons in its own light colours -
//               and the web controls take either theme. The selection lists and the dialogs stay native.
//
//               The host is a data-entry object, as a Windows view's forms are: the toolbar's and the menus'
//               Find, Save, Clear, Delete and Prompt act on it when the focus is in it, and Save moves what was
//               typed - the manifest file's name, the path, the notes - into the data dictionary.
//
// This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//****************************************************************************
Use cRDCDbView.pkg
Use cFTDbGridHost.pkg               // the data-aware host on a grid of 8 px columns (RDCFlexTron) - Used before the web controls
Use FTAllWebControlClasses.pkg      // cFTWebForm, cFTWebList, cFTWebButton(Row), cFTWebHtmlBox, cWebSuggestionForm, cWebEdit, the tabs
Use cFTDeferTimer.pkg               // the dashboard drawn a moment after a change, once
Use FTPageIsUp.pkg                  // FTHostPageIsUp - can the host's page take a live push now?
Use FTMarkupBuilders.pkg            // DivOpen, TagText, ButtonHtml, IconLabel ...
Use FTDashIcons.pkg                 // DashIcon and its CS_Glyph* names
Use cManifestFunctionLibrary.pkg
Use cManifestIniFile.pkg
Use Symdef.pkg
Use vWin32fh.pkg

Use COMComponents.dg
Use ProgramSetup.dg
Use DownloadFiles.dg

Use cManHdrDataDictionary.dd        // and, with it, ManHdr.sl - the list of manifests (Select...)
Use cManDetManDataDictionary.dd     // and, with it, FragmentFilesSelection.sl - the fragment files to add
Use Windows.pkg

// What the dashboard's timer does: draw all of it, draw the selected row's panel, or add a file dropped on the page.
Define CI_DashAll  for 1
Define CI_DashRow  for 2
Define CI_DashDrop for 3

Activate_View Activate_oDbMerger_vw for oDbMerger_vw
Object oDbMerger_vw is a cRDCDbView
    Set Size to 264 556
    Set Location to 0 0
    Set Label to "Main view"
    Set Icon to "COMManifestManager.ico"
    // Saves in header should not clear the view
    Set Auto_Clear_DEO_State to False
    Set Verify_Save_Msg to (RefFunc(No_Confirmation))
    Set pbAcceptDropFiles to True
    Set pbAutoActivate to True

    Property String[] pArrayOfDroppedFiles
    // The path is typed in only after Enable path (DoTogglePath).
    Property Boolean pbPathEditable False

    // The menu bar's commands reach this view through the application object (RefreshDashboard ...), and so does
    // the list of fragment files the build, the copy and the run take (SelectedItems, ItemCount).
    Set phoMainView of ghoApplication to Self
    Set phoManifest_grid of ghoApplication to Self

    Object oManHdr_DD is a cManHdrDataDictionary
        Set Allow_Foreign_New_Save_State to True
    End_Object

    Object oManDet_DD is a cManDetManDataDictionary
        Set DDO_Server To oManHdr_DD
        Set Constrain_File To ManHdr.File_Number
    End_Object

    Set Main_DD to oManHdr_DD
    Set Server  to oManHdr_DD

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete entire header and all details?" to bFail
        Function_Return bFail
    End_Function
    Set Verify_Delete_MSG to (RefFunc(ConfirmDeleteHeader))

    // Draws the dashboard one tick after it was asked for - a burst of changes draws it once - and adds a file that
    // was dropped on the page (CI_DashDrop), after the web control's event has returned.
    Object oDashboard_tmr is a cFTDeferTimer
        Procedure OnDeferredAction Integer iAction String sParam
            If (iAction = CI_DashDrop) Begin
                Send AddDroppedFileUrl sParam
            End
            Else Begin
                Send UpdateDashboard iAction
            End
        End_Procedure
    End_Object

    /* THE HOST: the whole view, on a grid of 8 px columns - column 0 takes the extra width, and the 41 after it
       (328 px) are the panels' at the right. Row 3 - the tabs and the panels - takes the extra height.

         row 0   the manifest file's name               Select... Browse...
         row 1   its folder                             Enable path
         row 2   the steps (an HTML box)
         row 3   the tabs: fragment files, notes,       the panels (an HTML box): the selected
                 record info                            component, the fragment library, folders */
    Object oMain_host is a cFTDbGridHost
        Set Location to 0 0
        Set Size to 264 556
        Set peAnchors to anAll
        Set piColumnCount to 42
        Set psColumnWidths to "0/1fr"
        Set psRowHeights to "3/1fr"
        Set Server to oManHdr_DD
        Set Auto_Clear_DEO_State to False                       // a saved manifest stays on screen
        Set Verify_Save_Msg to (RefFunc(No_Confirmation))
        Set Verify_Delete_Msg to (RefFunc(ConfirmDeleteHeader))

        // ---- row 0 and 1: the manifest file

        // Typing finds a manifest the database knows (smFind), as the native suggestion form did.
        Object oManifestName_wf is a cWebSuggestionForm
            Entry_Item ManHdr.ManifestFileName
            Set Server to oManHdr_DD
            Set piRowIndex to 0
            Set piColumnIndex to 0
            Set piColumnSpan to 18
            Set psLabel to "Manifest file:"
            Set piLabelOffset to 100
            Set pbFullText to True
            Set psToolTip to "The application manifest file: the program's name with '.manifest' added. Type to find one the program keeps, or press Select... or Browse..."

            // A manifest found, saved or cleared: the program's names and paths follow it, and the dashboard.
            Procedure Refresh Integer eMode
                Forward Send Refresh eMode
                Send OnHeaderRefresh
            End_Procedure
        End_Object

        Object oHeader_btns is a cFTWebButtonRow
            Set piRowIndex to 0
            Set piColumnIndex to 18
            Set piColumnSpan to 24

            Object oOpenManifest_btn is a cFTWebButton
                Set psCaption to "Select..."
                Set psCSSClass to "ftbtn ftg-search"
                Set psToolTip to "Choose one of the manifests this program keeps (Alt+O, F4)"

                Procedure OnButtonClick
                    Send DoOpenManifestList
                End_Procedure
            End_Object

            Object oBrowse_btn is a cFTWebButton
                Set psCaption to "Browse..."
                Set psCSSClass to "ftbtn ftg-folderopen"
                Set psToolTip to "Choose a manifest file on disk (Ctrl+O). The COM components it lists already are looked up in your fragment library."

                Procedure OnButtonClick
                    Send DoBrowseManifestFile
                End_Procedure
            End_Object
        End_Object

        Object oPath_wf is a cFTWebForm
            Entry_Item ManHdr.Path
            Set Server to oManHdr_DD
            Set piRowIndex to 1
            Set piColumnIndex to 0
            Set piColumnSpan to 18
            Set psLabel to "Folder:"
            Set piLabelOffset to 100
            Set pbEnabled to False
            Set psToolTip to "The manifest file's folder. Press Enable path to type it in."
        End_Object

        Object oPath_btns is a cFTWebButtonRow
            Set piRowIndex to 1
            Set piColumnIndex to 18
            Set piColumnSpan to 24

            Object oEnablePath_btn is a cFTWebButton
                Set psCaption to "Enable path"
                Set psCSSClass to "ftbtn ftg-unlock"
                Set psToolTip to "Lets you type in the manifest file's folder"

                Procedure OnButtonClick
                    Send DoTogglePath
                End_Procedure
            End_Object
        End_Object

        // ---- row 2: the steps

        Object oSteps_box is a cFTWebHtmlBox
            Set piRowIndex to 2
            Set piColumnIndex to 0
            Set piColumnSpan to 42
            // What the Studio's Designer draws; the program draws the steps (StepsHtml).
            Set psHtml to '<div class="ftph-cards"><b>1 Components</b><b>2 Build manifest</b><b>3 Copy COM files</b><b>4 Embed, compress</b><b>5 Test run</b></div>'

            Procedure OnHtmlClick String sId String sParam
                Send DoDashboardAction sId
            End_Procedure
        End_Object

        // ---- row 3: the tabs, and the panels at the right

        Object oTabs is a cWebTabContainer
            Set piRowIndex to 3
            Set piColumnIndex to 0
            Set piColumnSpan to 1
            Set pbFillHeight to True

            /* THE PAGES ARE GRIDS TOO: a container inherits its host's layout (peLayoutType ltInherit), and on a grid a
               row is as tall as its content unless psRowHeights gives it the rest - so each page says which row
               takes the height. Without it the list was one header high (Nils's screenshot 2026-11-14). */
            Object oFragments_tp is a cWebTabPage
                Set psCaption to "Fragment Files"
                Set piColumnCount to 1
                Set psColumnWidths to "0/1fr"
                Set psRowHeights to "1/1fr"       // row 1, the list

                Object oFragment_btns is a cFTWebButtonRow
                    Set piRowIndex to 0

                    Object oAddFragments_btn is a cFTWebButton
                        Set psCaption to "Add files..."
                        Set psCSSClass to "ftbtn ftg-add"
                        Set psToolTip to "Add fragment files from your library - one for each COM component the program uses"

                        Procedure OnButtonClick
                            Send DoAddFragmentFiles
                        End_Procedure
                    End_Object

                    Object oRemoveFragment_btn is a cFTWebButton
                        Set psCaption to "Remove"
                        Set psCSSClass to "ftbtn ftg-remove"
                        Set psToolTip to "Remove the selected fragment file from this manifest (the file stays in your library)"

                        Procedure OnButtonClick
                            Send DoRemoveFragment
                        End_Procedure
                    End_Object

                    Object oEditFragment_btn is a cFTWebButton
                        Set psCaption to "Edit fragment file"
                        Set psCSSClass to "ftbtn ftg-edit"
                        Set psToolTip to "Open the selected fragment file in the editor"

                        Procedure OnButtonClick
                            Send DoEditFragment
                        End_Procedure
                    End_Object
                End_Object

                /* THE FRAGMENT FILES, a data-aware list on the ManDet data dictionary, which the manifest's
                   constrains: the framework reads the rows, and a row chosen is the DD's record - the record the
                   menus' Edit fragment file and Register act on. The description and whether the file is in the
                   library are worked out per row (OnSetCalculatedValue). */
                Object oFragments_lst is a cFTWebList
                    Set Server to oManDet_DD
                    Set piRowIndex to 1
                    Set pbFillHeight to True
                    Set piOrdering to 3
                    Set psPlaceHolder to "No fragment files yet - Add files..."

                    Object oFragmentFile_col is a cWebColumn
                        Entry_Item ManDet.ManifestFragmentFile
                        Set psCaption to "Fragment file"
                        Set piWidth to 290
                        Set pbFixedWidth to True
                    End_Object

                    Object oDescription_col is a cWebColumn
                        Set psCaption to "Description"
                        Set piWidth to 1

                        // The comment line at the top of the fragment file.
                        Procedure OnSetCalculatedValue String ByRef sValue
                            Move (Trim(ManDet.ManifestFragmentFile)) to sValue
                            If (sValue contains ".txt") Begin
                                Get ExtractManifestFragmentFileComment of ghoManifestFunctionLibrary sValue to sValue
                            End
                        End_Procedure
                    End_Object

                    // In words, not in a colour: a fragment file missing from the library - or a wrong path to the
                    // library in Settings - says "Missing".
                    Object oInLibrary_col is a cWebColumn
                        Set psCaption to "In library"
                        Set piWidth to 80
                        Set pbFixedWidth to True

                        Procedure OnSetCalculatedValue String ByRef sValue
                            String sLibrary sFile
                            Boolean bExists
                            Move (Trim(ManDet.ManifestFragmentFile)) to sFile
                            Move "" to sValue
                            If (sFile <> "") Begin
                                Get psManifestFragmentLibrary of ghoManifestFunctionLibrary to sLibrary
                                Get vFilePathExists (vFolderFormat(sLibrary) + sFile) to bExists
                                Move (If(bExists, "Yes", "Missing")) to sValue
                            End
                        End_Procedure
                    End_Object

                    // Another row: the panel at the right names its COM component.
                    Procedure OnChangeCurrentRow String sFromRowID String sToRowID
                        Forward Send OnChangeCurrentRow sFromRowID sToRowID
                        Send ArmDashboardRow
                    End_Procedure
                End_Object
            End_Object

            // The notes: plain text since 2026-11-14 (Nils's choice) - the native editor's rich text cannot live in
            // a web page. A note saved with formatting shows its RTF codes until it is written again.
            Object oNotes_tp is a cWebTabPage
                Set psCaption to "Your Notes"
                Set piColumnCount to 1
                Set psColumnWidths to "0/1fr"
                Set psRowHeights to "0/1fr"       // the notes take it all

                Object oNotes_we is a cWebEdit
                    Entry_Item ManHdr.Comment
                    Set Server to oManHdr_DD
                    Set piRowIndex to 0
                    Set pbShowLabel to False
                    Set pbFillHeight to True
                    Set psToolTip to "Your own notes about this manifest - saved with it (Ctrl+S)"
                End_Object
            End_Object

            Object oRecordInfo_tp is a cWebTabPage
                Set psCaption to "Record Info"
                Set piColumnCount to 2
                Set psColumnWidths to "0/1fr 1/1fr"   // two halves: when, and by whom

                // The dates are filled by the view (ShowRecordDates), not bound: see there.
                Object oCreated_wf is a cFTWebForm
                    Set piRowIndex to 0
                    Set piColumnIndex to 0
                    Set psLabel to "Created:"
                    Set piLabelOffset to 80
                    Set pbReadOnly to True
                End_Object

                Object oCreatedBy_wf is a cFTWebForm
                    Entry_Item ManHdr.CreatedBy
                    Set Server to oManHdr_DD
                    Set piRowIndex to 0
                    Set piColumnIndex to 1
                    Set psLabel to "By:"
                    Set piLabelOffset to 40
                    Set pbReadOnly to True
                End_Object

                Object oChanged_wf is a cFTWebForm
                    Set piRowIndex to 1
                    Set piColumnIndex to 0
                    Set psLabel to "Last edited:"
                    Set piLabelOffset to 80
                    Set pbReadOnly to True
                End_Object

                Object oChangedBy_wf is a cFTWebForm
                    Entry_Item ManHdr.ChangedBy
                    Set Server to oManHdr_DD
                    Set piRowIndex to 1
                    Set piColumnIndex to 1
                    Set psLabel to "By:"
                    Set piLabelOffset to 40
                    Set pbReadOnly to True
                End_Object
            End_Object
        End_Object

        Object oTools_box is a cFTWebHtmlBox
            Set piRowIndex to 3
            Set piColumnIndex to 1
            Set piColumnSpan to 41
            // What the Studio's Designer draws; the program draws the panels (ToolsHtml).
            Set psHtml to '<div class="ftph-cards"><b>Selected component</b><b>Fragment Library</b><b>Folders</b></div>'

            Procedure OnHtmlClick String sId String sParam
                Send DoDashboardAction sId
            End_Procedure
        End_Object

        // The FT button family and the dashboard's own sheet, in the page's head (palette.css comes with every FT host).
        Procedure OnDefineScriptIncludes String[] ByRef aScriptHtml
            Forward Send OnDefineScriptIncludes (&aScriptHtml)
            Move (StyleSheetLink("RDCFlexTron/buttons.css")) to aScriptHtml[SizeOfArray(aScriptHtml)]
            Move (CssLink("dashboard")) to aScriptHtml[SizeOfArray(aScriptHtml)]
        End_Procedure

        /* A FILE DROPPED ON THE PAGE. WebView2 would open it - navigate to the file and leave the page. A file:/// address
           is never this page's own, so its navigation is cancelled, and the file is added as a fragment file, as one
           dropped on the native view was (AddDroppedFiles): one tick later, after this event has returned. */
        Procedure OnNavigationStarting UBigInt iNavigationId String sUrl Boolean bIsRedirected ;
                                       Boolean bIsUserInitiated Boolean ByRef bCancelnavigation
            If (Lowercase(Left(sUrl, 8)) = "file:///") Begin
                Move True to bCancelnavigation
                Send ArmAction of oDashboard_tmr CI_DashDrop sUrl
                Procedure_Return
            End
            Forward Send OnNavigationStarting iNavigationId sUrl bIsRedirected bIsUserInitiated (&bCancelnavigation)
        End_Procedure

        // F4 and the toolbar's Prompt with the focus in the page: the list of manifests, as F4 in the native name field
        // gave it. cCJPromptMenuItem asks for a Prompt_Object before it enables itself.
        Function Prompt_Object Returns Handle
            Function_Return (oManHdr_sl(Self))
        End_Function

        Procedure Prompt
            Send DoOpenManifestList
        End_Procedure

        // The program's shortcuts with the focus in the page - the menu bar shows them. The host's own are the data
        // entry keys (F2 save, F5 clear, F7/F8 find ...).
        On_Key Key_Alt+Key_O  Send DoOpenManifestList
        On_Key Key_Ctrl+Key_O Send DoBrowseManifestFile
        On_Key Key_Alt+Key_E  Send EditAppManifestFile            of ghoManifestFunctionLibrary
        On_Key Key_Alt+Key_B  Send DoPreBuildManifestFile
        On_Key Key_Ctrl+Key_P Send DoPreCopyCOMComponents
        On_Key Key_Ctrl+Key_E Send EmbedManifestInProgram         of ghoManifestFunctionLibrary
        On_Key Key_Ctrl+Key_R Send DoPreRunProgram
        On_Key Key_Ctrl+Key_L Send OpenFragmentFolder             of ghoManifestFunctionLibrary
        On_Key Key_Ctrl+Key_D Send OpenProgramsFolder             of ghoManifestFunctionLibrary
        On_Key Key_Ctrl+Key_B Send OpenCommonCOMFolder            of ghoManifestFunctionLibrary
        On_Key Key_Alt+Key_D  Send DownloadManifestFragmentFiles  of ghoManifestFunctionLibrary
        On_Key Key_Alt+Key_S  Send DoShareManifestFragmentFiles   of (Client_Id(ghoCommandBars))
        On_Key Key_Alt+Key_L  Send DoRegisterComponent
        On_Key Key_Ctrl+Key_S Send Request_Save
    End_Object

    // ---------------------------------------------------------------------------------------------------
    // The manifest's fragment files - what the old grid gave: the build, the copy, the run and the menus take them
    // through the application object (phoManifest_grid is this view).
    // ---------------------------------------------------------------------------------------------------

    // The index of ManDet that starts with its manifest's ID: the one to read a manifest's fragment files by.
    Function ManDetHeaderIndex Returns Integer
        Integer iLast iIndex iField
        String sName
        Get_Attribute DF_FILE_LAST_INDEX_NUMBER of ManDet.File_Number to iLast
        For iIndex from 1 to iLast
            Get_Attribute DF_INDEX_SEGMENT_FIELD of ManDet.File_Number iIndex 1 to iField
            Get_Attribute DF_FIELD_NAME of ManDet.File_Number iField to sName
            If (Uppercase(Trim(sName)) = "MANHDRID") Begin
                Function_Return iIndex
            End
        Loop
        Function_Return 0
    End_Function

    // The fragment files of the manifest on screen, read from the table. The record the data dictionary has - the
    // list's chosen row - is in the buffer again afterwards.
    Function SelectedItems Returns String[]
        String[] sFiles
        Integer iID iIndex
        RowID riCurrent
        Boolean bFound

        Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
        If (iID = 0) Begin
            Function_Return sFiles
        End
        Get ManDetHeaderIndex to iIndex
        If (iIndex = 0) Begin
            Function_Return sFiles
        End
        Get CurrentRowId of oManDet_DD to riCurrent

        Clear ManDet
        Move iID to ManDet.ManHdrID
        Vfind ManDet.File_Number iIndex GE
        While (Found and ManDet.ManHdrID = iID)
            If (Trim(ManDet.ManifestFragmentFile) <> "") Begin
                Move (Trim(ManDet.ManifestFragmentFile)) to sFiles[SizeOfArray(sFiles)]
            End
            Vfind ManDet.File_Number iIndex GT
        Loop

        Clear ManDet
        If (not(IsNullRowID(riCurrent))) Begin
            Move (FindByRowID(ManDet.File_Number, riCurrent)) to bFound
        End
        Function_Return sFiles
    End_Function

    // How many fragment files the manifest has - the Build menu item asks.
    Function ItemCount Returns Integer
        String[] sFiles
        Get SelectedItems to sFiles
        Function_Return (SizeOfArray(sFiles))
    End_Function

    /* THE LIST READ AGAIN. The framework's web list loads the rows AROUND ITS CURRENT ROW (cWebList.LoadData: no
       psCurrentRowId, no rows at all), so a reload needs a current row: the ManDet data dictionary's - its first one
       when bFromFirst (another manifest) or when it has none (rows just added). Stored for a page that draws the list
       later (it loads itself then), and pushed with the reload to a page that is up. Until 2026-11-14 the list was
       only read again, and after rows were added to a new manifest it stayed empty (Nils). */
    Procedure ReloadFragmentList Boolean bFromFirst
        Integer iID iIndex
        Boolean bHasRecord
        RowID riRow
        String sRowId

        Get HasRecord of oManDet_DD to bHasRecord
        If (bFromFirst or (bHasRecord = False)) Begin
            Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
            Get ManDetHeaderIndex to iIndex
            If (iID <> 0 and iIndex <> 0) Begin
                Send Find of oManDet_DD FIRST_RECORD iIndex
            End
            Else Begin
                Send Clear of oManDet_DD
            End
        End

        Get CurrentRowId of oManDet_DD to riRow
        Move "" to sRowId
        If (not(IsNullRowID(riRow))) Begin
            Move (SerializeRowID(riRow)) to sRowId
        End
        Set psCurrentRowId of oFragments_lst to sRowId
        If (FTHostPageIsUp(oMain_host)) Begin
            WebSet psCurrentRowId of oFragments_lst to sRowId
            Send GridRefresh of oFragments_lst
        End
    End_Procedure

    // The list read again after rows were added or removed outside it.
    Procedure RefreshFragments
        Send ReloadFragmentList False
    End_Procedure

    // Adds a row for each of the fragment files to the manifest with the ID iID. Used by Add files..., by a file
    // dropped on the view, and when a new manifest file's COM components fill the list (FillGridFromManifestFile).
    Procedure AddFragmentFiles Integer iID String[] sFragmentFiles
        Integer i iRows iRetval

        Move (SizeOfArray(sFragmentFiles)) to iRows
        If (iID = 0 or iRows = 0) Begin
            Procedure_Return
        End

        Lock
            For i from 0 to (iRows - 1)
                Clear ManDet
                Get GlobalAutoCreateNewID File_Field ManDet.ID False to iRetval
                Move iRetval to ManDet.ID
                Move iID to ManDet.ManHdrID
                Move sFragmentFiles[i] to ManDet.ManifestFragmentFile
                SaveRecord ManDet
            Loop
        Unlock

        Send RefreshFragments
    End_Procedure

    // Add files... - on the dashboard, in the Fragments menu and above the list: the fragment files prompt list.
    Procedure DoAddFragmentFiles
        String[] sFileNames sNewFiles
        Integer iID

        Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
        If (iID = 0) Begin
            Send Info_Box "Save the manifest first, then add its fragment files."
            Procedure_Return
        End
        Get SelectedItems to sFileNames
        Get ActivateFragmentFiles_sl (&sFileNames) to sNewFiles
        Send AddFragmentFiles iID sNewFiles
        Send ArmDashboard
    End_Procedure

    // Remove: the chosen row's fragment file out of this manifest. The file stays in the library.
    Procedure DoRemoveFragment
        Boolean bHasRecord
        Get HasRecord of oManDet_DD to bHasRecord
        If (bHasRecord = False) Begin
            Procedure_Return
        End
        Send Request_Delete of oManDet_DD
        Send RefreshFragments
        Send ArmDashboard
    End_Procedure

    // Alt+L: the chosen row's COM component registered, as the Components menu's Register. (The native view's Alt+L
    // sent RegisterOrUnregister without its argument - False - and so unregistered.)
    Procedure DoRegisterComponent
        Send RegisterOrUnregister of ghoManifestFunctionLibrary True
        Send ArmDashboard
    End_Procedure

    // Edit fragment file: the chosen row's file in the editor.
    Procedure DoEditFragment
        Boolean bHasRecord
        Get HasRecord of oManDet_DD to bHasRecord
        If (bHasRecord) Begin
            Send OpenCurrentGridItem of ghoManifestFunctionLibrary
        End
    End_Procedure

    // ---------------------------------------------------------------------------------------------------
    // The manifest
    // ---------------------------------------------------------------------------------------------------

    // A manifest found, saved or cleared (the name field's Refresh): the library's names and paths follow it.
    Procedure OnHeaderRefresh
        String sPath sFileName
        Get Field_Current_Value of oManHdr_DD Field ManHdr.Path             to sPath
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFileName
        If (Trim(sPath) <> "") Begin
            Get vFolderFormat sPath to sPath
        End
        Send SetApplicationStrings of ghoManifestFunctionLibrary (sPath + sFileName)
        Send ArmDashboard
    End_Procedure

    // Select... - the button, the File menu's Select Manifest..., Alt+O, F4: the native list of the manifests this program keeps,
    // as a list of its own (umPromptNonInvoking: no field to update), and the chosen one found here.
    Procedure DoOpenManifestList
        Handle hoPanel hoList
        RowID[] riSelected
        Boolean bCanceled

        Move (oManHdr_sl(Self)) to hoPanel
        Move (oSelList(hoPanel)) to hoList
        Set peUpdateMode of hoList to umPromptNonInvoking
        Send Popup of hoPanel
        Get pbCanceled of hoList to bCanceled
        If (bCanceled) Begin
            Procedure_Return
        End
        Get SelectedRowIds of hoList to riSelected
        If (SizeOfArray(riSelected) > 0) Begin
            Send FindByRowId of oManHdr_DD ManHdr.File_Number riSelected[0]
        End
    End_Procedure

    /* Browse... - the button, the File menu, Ctrl+O: a manifest file on disk. One the database knows is found; a new
       one is saved at once - its name and folder are all a manifest record needs - and the fragment files of the COM
       components it lists already are offered (FillGridFromManifestFile). Until 2026-11-14 a new one was left
       unsaved in the native fields; a web field shows what its data dictionary holds, so it is saved instead. */
    Procedure DoBrowseManifestFile
        String sValue sFile sPath sStartPath
        Boolean bFound

        Get psTargetPath of ghoManifestFunctionLibrary to sStartPath
        Move (vSelect_File("Program Manifest Files (*.manifest)|*.manifest", "Select a Program Manifest File", sStartPath)) to sValue
        If (sValue = "") Begin
            Procedure_Return
        End
        Move (ParseFileName(sValue))   to sFile
        Move (ParseFolderName(sValue)) to sPath
        Send SetApplicationStrings of ghoManifestFunctionLibrary sValue

        Clear ManHdr
        Move sFile to ManHdr.ManifestFileName
        Move sPath to ManHdr.Path
        Find Ge ManHdr by Index.2
        Move (Found and (Trim(ManHdr.ManifestFileName) = sFile) and (Trim(ManHdr.Path) = sPath)) to bFound
        If (bFound) Begin
            Send Request_Assign of oManHdr_DD
            Procedure_Return
        End

        Send Clear of oManHdr_DD
        Set Field_Changed_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFile
        Set Field_Changed_Value of oManHdr_DD Field ManHdr.Path             to sPath
        Send Request_Save of oManHdr_DD
        // A manifest file that already lists COM components: their fragment files, offered.
        Send FillGridFromManifestFile sPath sFile
        Send ArmDashboard
    End_Procedure

    // Enable path / Lock path: the folder field open for typing, or shut again.
    Procedure DoTogglePath
        Boolean bOn
        Get pbPathEditable to bOn
        Move (not(bOn)) to bOn
        Set pbPathEditable to bOn
        Set pbEnabled of oPath_wf to bOn
        If (FTHostPageIsUp(oMain_host)) Begin
            WebSet pbEnabled of oPath_wf to bOn
        End
        Send UpdateCaption of oEnablePath_btn (If(bOn, "Lock path", "Enable path"))
    End_Procedure

    // New Project (the wizard): the view cleared first - the wizard makes the manifest, and the view shows it after
    // (LoadManifestFromApplication).
    Procedure DoClearManifest
        Send Request_Clear_All of oMain_host
    End_Procedure

    // The manifest named by psApplicationManifestName - given on the command line (the Studio's Tools menu starts the
    // program so), or made by the New Project wizard - found and shown.
    Procedure LoadManifestFromApplication
        String sArgument sManifestFileName sPath
        Integer iRetval
        Boolean bFound

        Get psApplicationManifestName of ghoApplication to sArgument
        Move (Lowercase(sArgument)) to sArgument
        Get vFilePathExists sArgument to iRetval
        If (iRetval = False) Begin
            Move (Replace("programs", sArgument, "appsrc")) to sArgument
            Get vFilePathExists sArgument to iRetval
        End

        If (sArgument <> "" and iRetval = True) Begin
            Get ParseFileName   sArgument to sManifestFileName
            Get ParseFolderName sArgument to sPath
            Clear ManHdr
            Move sPath             to ManHdr.Path
            Move sManifestFileName to ManHdr.ManifestFileName
            Find ge ManHdr by Index.3
            Move (Found and sPath = Lowercase(ManHdr.Path) and sManifestFileName = Lowercase(ManHdr.ManifestFileName)) to bFound
            If (bFound = True) Begin
                Send Request_Assign of oManHdr_DD
            End
            Else Begin
                Send Clear of oManHdr_DD
            End
        End
    End_Procedure

    // ---------------------------------------------------------------------------------------------------
    // Files dropped on the view
    // ---------------------------------------------------------------------------------------------------

    // A file:/// address as WebView2 gives it, as a path: the slashes Windows', the %XX escapes undone (the bytes of
    // UTF-8, so a name with national characters comes back whole).
    Function FileUrlToPath String sUrl Returns String
        UChar[] ucBytes ucChar
        String sRest sChar sDigits
        Integer i iLen iHigh iLow

        Move (Right(sUrl, Length(sUrl) - 8)) to sRest
        Move (Length(sRest)) to iLen
        Move "0123456789ABCDEF" to sDigits
        Move 1 to i
        While (i <= iLen)
            Move (Mid(sRest, 1, i)) to sChar
            If (sChar = "%" and (i + 2) <= iLen) Begin
                Move (Pos(Uppercase(Mid(sRest, 1, i + 1)), sDigits) - 1) to iHigh
                Move (Pos(Uppercase(Mid(sRest, 1, i + 2)), sDigits) - 1) to iLow
                If (iHigh >= 0 and iLow >= 0) Begin
                    Move ((iHigh * 16) + iLow) to ucBytes[SizeOfArray(ucBytes)]
                    Move (i + 3) to i
                End
                Else Begin
                    Move (AppendArray(ucBytes, StringToUCharArray(sChar))) to ucBytes
                    Increment i
                End
            End
            Else Begin
                If (sChar = "/") Begin
                    Move "\" to sChar
                End
                Move (AppendArray(ucBytes, StringToUCharArray(sChar))) to ucBytes
                Increment i
            End
        Loop
        Function_Return (UCharArrayToString(ucBytes))
    End_Function

    // A file dropped on the page (oMain_host.OnNavigationStarting): added as a fragment file.
    Procedure AddDroppedFileUrl String sUrl
        String[] sFiles
        String sFile
        Get FileUrlToPath sUrl to sFile
        Move (ParseFileName(sFile)) to sFiles[0]
        Send AddDroppedFiles sFiles
    End_Procedure

    // Fragment files dropped on the view: the names, added to the manifest on screen, which must be saved first.
    Procedure AddDroppedFiles String[] sFiles
        Integer iID
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
        If (iID = 0) Begin
            Send Stop_Box "You need to select a .manifest file first - or save the new one - and then drop its fragment files on it."
            Procedure_Return
        End
        Send AddFragmentFiles iID sFiles
        Send ArmDashboard
    End_Procedure

    // Files dropped on the native view - outside the page, which covers nearly all of it.
    Procedure OnFileDropped String sFilename Boolean bLast
        Integer  iFiles
        String[] ArrayOfDroppedFiles EmptyArray

        Get pArrayOfDroppedFiles to ArrayOfDroppedFiles
        Move (SizeOfArray(ArrayOfDroppedFiles)) to iFiles
        Move (ParseFileName(sFilename)) to ArrayOfDroppedFiles[iFiles]
        If (bLast) Begin
            Send AddDroppedFiles ArrayOfDroppedFiles
            Move EmptyArray to ArrayOfDroppedFiles
        End
        Set pArrayOfDroppedFiles to ArrayOfDroppedFiles
    End_Procedure

    // ---------------------------------------------------------------------------------------------------
    // The dashboard: the steps (oSteps_box) and the panels at the right (oTools_box), drawn by oDashboard_tmr
    // a moment after a change - a manifest found, saved or cleared, rows added or removed, another row chosen,
    // a button or a menu command done. What a step says is read from the files each time.
    // ---------------------------------------------------------------------------------------------------

    // The manifest whose fragment files the list shows (its ID), so that another manifest reloads the list.
    Property Integer piListManifestID -1

    /* ANOTHER MANIFEST: ITS FRAGMENT FILES IN THE LIST. The list's own refresh did not do it - a manifest chosen
       with Select..., the toolbar's Find buttons or the name field left the list empty (Nils 2026-11-14): the
       framework's web list reloads only while its Active_State is True, and the notice reaches it through the
       constrained ManDet data dictionary. So the view reloads it itself, on the dashboard's tick - after the find,
       outside its notices: the list from the manifest's first fragment file (ReloadFragmentList), so a row is
       chosen and the panel at the right names its component. */
    Procedure LoadFragmentsForManifest
        Integer iID
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
        If (iID = piListManifestID(Self)) Begin
            Procedure_Return
        End
        Set piListManifestID to iID
        Send ReloadFragmentList True
    End_Procedure

    /* THE RECORD'S DATES on the Record Info page. ManHdr's two date columns are ASCII (20), not DateTime: the data
       dictionary stores the date and time in them as text, "2026-11-14 18:25:15", and gives them a DateTime mask. A
       data-aware web field takes the DD's mask when it has none of its own, and through that mask the text showed as
       nothing, while the user names beside them showed (Nils 2026-11-14). So the two fields are not bound: they show
       the text as it is stored, without the seconds. Saving was never the trouble - the DD's Creating and Update
       write the dates with the user names. */
    Function RecordDateText String sValue Returns String
        Move (Trim(sValue)) to sValue
        If (Length(sValue) = 19 and Mid(sValue, 1, 14) = ":" and Mid(sValue, 1, 17) = ":") Begin
            Move (Left(sValue, 16)) to sValue
        End
        Function_Return sValue
    End_Function

    // A field's text, stored for the page's next mount and pushed to a page that is up.
    Procedure SetFieldText Handle hoForm String sValue
        Set psValue of hoForm to sValue
        If (FTHostPageIsUp(oMain_host)) Begin
            WebSet psValue of hoForm to sValue
        End
    End_Procedure

    Procedure ShowRecordDates
        String sCreated sChanged
        Get Field_Current_Value of oManHdr_DD Field ManHdr.CreatedDateTime to sCreated
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ChangedDateTime to sChanged
        Send SetFieldText oCreated_wf (RecordDateText(Self, sCreated))
        Send SetFieldText oChanged_wf (RecordDateText(Self, sChanged))
    End_Procedure

    // The fragment files' tab says how many - stored for the page's next mount, pushed to a page that is up.
    Procedure SetFragmentsCaption Integer iCount
        String sCaption
        Move ("Fragment Files (" + String(iCount) + ")") to sCaption
        Set psCaption of oFragments_tp to sCaption
        If (FTHostPageIsUp(oMain_host)) Begin
            WebSet psCaption of oFragments_tp to sCaption
        End
    End_Procedure

    // The number of fragment files in the library, counted when the whole dashboard is drawn.
    Property Integer piLibraryFiles 0

    // The whole dashboard, a moment from now. The application object's RefreshDashboard sends it after a menu
    // command.
    Procedure ArmDashboard
        Send ArmAction of oDashboard_tmr CI_DashAll ""
    End_Procedure

    // The selected row's panel only - another row in the list. A whole drawing already asked for stays asked for.
    Procedure ArmDashboardRow
        Integer iPending
        Get piPendingAction of oDashboard_tmr to iPending
        If (iPending = 0) Begin
            Send ArmAction of oDashboard_tmr CI_DashRow ""
        End
    End_Procedure

    // A button of the dashboard: a glyph and its words, in the FT button family (buttons.css). The main action of
    // the next step is amber. A shut button is faded and sends nothing (ButtonHtml). No glyph: its words alone.
    Function DashButtonHtml String sId String sGlyph String sLabel String sTip Boolean bEnabled Boolean bMain Returns String
        String sCls
        Move "dfrbtn" to sCls
        If (bMain) Begin
            Move "dfrbtn amber" to sCls
        End
        If (sGlyph = "") Begin
            Function_Return (ButtonHtml("span", sCls, sId, "", sLabel, sTip, bEnabled))
        End
        Function_Return (ButtonHtml("span", sCls, sId, "", IconLabel(sGlyph, sLabel), sTip, bEnabled))
    End_Function

    // One step's card: its number - a tick once it is done - its title, its state in words, a line on where it
    // stands, and its buttons.
    Function StepCardHtml Integer iStep String sTitle String sState String sText String sButtons Boolean bDone Boolean bNext Boolean bOptional Returns String
        String sCls sMark sHtml
        Move "cms-step" to sCls
        If (bNext) Begin
            Move (sCls + " next") to sCls
        End
        If (bOptional) Begin
            Move (sCls + " opt") to sCls
        End
        If (bDone) Begin
            Move (DashIcon(CS_GlyphCheck)) to sMark
        End
        Else Begin
            Move (String(iStep)) to sMark
        End
        Move (DivOpen(sCls) + DivOpen("cms-top")) to sHtml
        Move (sHtml + TagHtml("span", "cms-num", sMark) + TagText("span", "cms-title", sTitle) + TagText("span", "cms-state", sState) + CS_DivEnd) to sHtml
        Move (sHtml + TagText("div", "cms-text", sText) + DivOpen("cms-btns") + sButtons + CS_DivEnd + CS_DivEnd) to sHtml
        Function_Return sHtml
    End_Function

    // A state in words: done, next, or still to do.
    Function StepStateText Boolean bDone Boolean bNext Returns String
        If (bDone) Begin
            Function_Return "Done"
        End
        If (bNext) Begin
            Function_Return "Next"
        End
        Function_Return "To do"
    End_Function

    // The five steps, from what the files say now.
    Function StepsHtml Returns String
        String sManifest sTargetPath sExe sListed sCOM sText sButtons sHtml sCard
        String[] sGrid sFragments
        tManifestCOMFile[] ManifestFiles
        tFileStruct[] COMFiles
        Integer iID iFragments iListed iInFolder iNext i iPos
        Boolean bManifest bBuilt bCopied bNext

        Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
        // The manifest file's name, set only while the file exists (SetApplicationStrings).
        Get psManifestFileName of ghoManifestFunctionLibrary to sManifest
        Get psTargetPath       of ghoManifestFunctionLibrary to sTargetPath
        Get psExeFileName      of ghoManifestFunctionLibrary to sExe
        Move (sManifest <> "") to bManifest

        // The fragment files in the list - a new, empty row left out.
        Get SelectedItems to sGrid
        For i from 0 to (SizeOfArray(sGrid) - 1)
            If (Trim(sGrid[i]) <> "") Begin
                Move (Trim(sGrid[i])) to sFragments[SizeOfArray(sFragments)]
            End
        Loop
        Move (SizeOfArray(sFragments)) to iFragments

        // Which of their COM files the manifest file lists, and which are in the program's folder.
        If (bManifest and iFragments > 0) Begin
            Get ManifestCOMFiles of ghoManifestFunctionLibrary (vFolderFormat(sTargetPath) + sManifest) to ManifestFiles
            Move "|" to sListed
            For i from 0 to (SizeOfArray(ManifestFiles) - 1)
                Move (sListed + ManifestFiles[i].sFileName + "|") to sListed
            Loop
            Get SelectedCOMComponents of ghoManifestFunctionLibrary (&sFragments) to COMFiles
            For i from 0 to (SizeOfArray(COMFiles) - 1)
                // The name as the manifest lists it: without a folder, in lowercase (ManifestCOMFiles).
                Move (Lowercase(Trim(COMFiles[i].sFileNameSecondCol))) to sCOM
                Move (RightPos("\", sCOM)) to iPos
                If (iPos > 0) Begin
                    Move (Right(sCOM, (Length(sCOM) - iPos))) to sCOM
                End
                If (sCOM <> "" and Pos(("|" + sCOM + "|"), sListed) > 0) Begin
                    Increment iListed
                End
                If (COMFiles[i].bExists) Begin
                    Increment iInFolder
                End
            Loop
        End
        Move (iFragments > 0 and iListed = iFragments) to bBuilt
        Move (iFragments > 0 and iInFolder = iFragments) to bCopied

        // The next step: the first that is not done. Embed and compress are optional, so after the copy it is the
        // test run.
        Move 0 to iNext
        If (bManifest) Begin
            If (iID = 0 or iFragments = 0) Begin
                Move 1 to iNext
            End
            Else If (bBuilt = False) Begin
                Move 2 to iNext
            End
            Else If (bCopied = False) Begin
                Move 3 to iNext
            End
            Else Begin
                Move 5 to iNext
            End
        End

        Move (DivOpen("cms-steps")) to sHtml

        // 1 Components
        Move (iNext = 1) to bNext
        If (bManifest = False and iID <> 0) Begin
            Move "The manifest file is missing on disk." to sText
        End
        Else If (bManifest = False) Begin
            Move "Open or make a manifest first." to sText
        End
        Else If (iID = 0) Begin
            Move "Save the manifest first." to sText
        End
        Else If (iFragments = 0) Begin
            Move "Add one for each COM component." to sText
        End
        Else Begin
            Move (String(iFragments) * "fragment" * If(iFragments = 1, "file", "files") * "selected.") to sText
        End
        If (bManifest and iID = 0) Begin
            Move (DashButtonHtml(Self, "save", CS_GlyphSave, "Save", "Save the manifest (Ctrl+S)", True, True)) to sButtons
        End
        Else Begin
            Move (DashButtonHtml(Self, "add", CS_GlyphAdd, "Add files...", "Add fragment files from your library (F4 in the list)", (iID <> 0), bNext)) to sButtons
        End
        Get StepCardHtml 1 "Components" (StepStateText(Self, (iFragments > 0), bNext)) sText sButtons (iFragments > 0) bNext False to sCard
        Move (sHtml + sCard) to sHtml

        // 2 Build manifest
        Move (iNext = 2) to bNext
        If (bManifest = False or iFragments = 0) Begin
            Move "Merges the fragment files into it." to sText
        End
        Else If (bBuilt) Begin
            Move ("It lists all" * String(iFragments) * "COM files.") to sText
        End
        Else Begin
            Move ("It lists" * String(iListed) * "of the" * String(iFragments) * "COM files.") to sText
        End
        Move (DashButtonHtml(Self, "build", CS_GlyphBolt, "Build", "Build the manifest file (Alt+B)", (bManifest and iFragments > 0), bNext)) to sButtons
        Move (sButtons + DashButtonHtml(Self, "viewmanifest", "", "View", "Open the manifest file in the editor (Alt+E)", bManifest, False)) to sButtons
        Get StepCardHtml 2 "Build manifest" (StepStateText(Self, bBuilt, bNext)) sText sButtons bBuilt bNext False to sCard
        Move (sHtml + sCard) to sHtml

        // 3 Copy COM files
        Move (iNext = 3) to bNext
        If (bManifest = False or iFragments = 0) Begin
            Move "Copies them to the program's folder." to sText
        End
        Else If (bCopied) Begin
            Move ("All" * String(iFragments) * "are in the program's folder.") to sText
        End
        Else Begin
            Move (String(iInFolder) * "of" * String(iFragments) * "are in the program's folder.") to sText
        End
        Move (DashButtonHtml(Self, "copy", CS_GlyphCopy, "Copy COM files", "Check that the COM files are in the program's folder, and copy the missing ones (Ctrl+P)", (bManifest and iFragments > 0), bNext)) to sButtons
        Get StepCardHtml 3 "Copy COM files" (StepStateText(Self, bCopied, bNext)) sText sButtons bCopied bNext False to sCard
        Move (sHtml + sCard) to sHtml

        // 4 Embed, compress - optional
        Move (DashButtonHtml(Self, "embed", "", "Embed", "Embed the manifest file in the program (Ctrl+E)", bManifest, False)) to sButtons
        Move (sButtons + DashButtonHtml(Self, "compress", "", "Compress", "Compress the program file", bManifest, False)) to sButtons
        Get StepCardHtml 4 "Embed, compress" "Optional" "Puts it in the .exe, then shrinks it." sButtons False False True to sCard
        Move (sHtml + sCard) to sHtml

        // 5 Test run
        Move (iNext = 5) to bNext
        If (sExe <> "") Begin
            Move ("Starts" * sExe + ".") to sText
        End
        Else Begin
            Move "Starts the program." to sText
        End
        Move (DashButtonHtml(Self, "run", CS_GlyphPlay, "Run program", "Start the program (Ctrl+R)", bManifest, bNext)) to sButtons
        Get StepCardHtml 5 "Test run" (StepStateText(Self, False, bNext)) sText sButtons False bNext False to sCard
        Move (sHtml + sCard + CS_DivEnd) to sHtml

        Function_Return sHtml
    End_Function

    /* The panels at the right: the COM component of the selected row, the fragment library, and the folders.
       Measured 2026-11-14 in Edge with the real style sheets: 147 units high at 216 wide, and the longest name in the
       library - Codejock.SkinFramework.Unicode.x64.v26.0.0.ocx - on one line (Nils: Codejock's Unicode builds have
       the longest names). Narrower than about 206 units, a row of buttons wraps and the panel grows taller. The window's
       first size (400 units high) gives the panel that height; a smaller window scrolls it. */
    Function ToolsHtml Returns String
        String sHtml sFragment sCOM sLibrary sExePath sState sName
        Integer iCount
        Boolean bRow bInLibrary bRegistered

        // The COM component of the fragment file in the selected row - its state in words on the heading line.
        Get Field_Current_Value of oManDet_DD Field ManDet.ManifestFragmentFile to sFragment
        Move (Trim(sFragment)) to sFragment
        Move (sFragment <> "") to bRow
        If (bRow) Begin
            Get psManifestFragmentLibrary of ghoManifestFunctionLibrary to sLibrary
            Get vFilePathExists (vFolderFormat(sLibrary) + sFragment) to bInLibrary
            If (bInLibrary) Begin
                Get ExtractCOMFileName of ghoManifestFunctionLibrary sFragment to sCOM
                Get CheckCOMRegistrationFromManifestFragmentFile of ghoManifestFunctionLibrary sFragment to bRegistered
            End
        End
        Move "" to sState
        If (bRow = False) Begin
            Move (TagText("div", "cms-name", "No fragment file is selected in the list.")) to sName
        End
        Else If (bInLibrary = False) Begin
            Move (TagHtml("span", "cms-warn", (DashIcon(CS_GlyphWarning) + "Not in library"))) to sState
            Move (TagTipText("div", "cms-name", sFragment, sFragment)) to sName
        End
        Else Begin
            If (bRegistered) Begin
                Move (TagHtml("span", "cms-ok", (DashIcon(CS_GlyphCheck) + "Registered"))) to sState
            End
            Else Begin
                Move (TagHtml("span", "cms-warn", (DashIcon(CS_GlyphWarning) + "Not registered"))) to sState
            End
            Move (TagTipText("div", "cms-name", sCOM, sCOM)) to sName
        End
        Move (DivOpen("cms-tools") + DivOpen("cms-tile") + DivOpen("cms-tile-h") + DashIcon(CS_GlyphPackage) + TagText("span", "", "Selected component") + sState + CS_DivEnd) to sHtml
        Move (sHtml + sName + DivOpen("cms-row")) to sHtml
        Move (sHtml + DashButtonHtml(Self, "check", CS_GlyphHelp, "Check", "Is the COM component registered with Windows?", bInLibrary, False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "register", CS_GlyphShield, "Register", "Register the COM component with Windows (Alt+L)", bInLibrary, False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "unregister", CS_GlyphBan, "Unregister", "Unregister the COM component from Windows", bInLibrary, False)) to sHtml
        Move (sHtml + CS_DivEnd + CS_DivEnd) to sHtml

        // The fragment library: its files counted when the whole dashboard is drawn (piLibraryFiles), and its four
        // buttons two a row - short words, the whole story in the tooltip.
        Get piLibraryFiles to iCount
        Move (sHtml + DivOpen("cms-tile") + DivOpen("cms-tile-h") + DashIcon(CS_GlyphArchive) + TagText("span", "", "Fragment Library")) to sHtml
        Move (sHtml + TagText("span", "cms-count", (String(iCount) * If(iCount = 1, "file", "files"))) + CS_DivEnd + DivOpen("cms-grid")) to sHtml
        Move (sHtml + DashButtonHtml(Self, "create", CS_GlyphFile, "Create one...", "Create a fragment file for a COM (OCX/DLL) component", True, False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "folderbatch", CS_GlyphFoldercheck, "For a folder...", "Create fragment files for all the COM (OCX) components in a folder, in one go", True, False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "download", CS_GlyphDownload, "From GitHub...", "Get the files that are new, or that differ from your copy, from the global library on GitHub (Alt+D)", True, False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "share", CS_GlyphUpload, "To GitHub...", "Share fragment files you made: upload them to the global library on GitHub (Alt+S)", True, False)) to sHtml
        Move (sHtml + CS_DivEnd + CS_DivEnd) to sHtml

        // The folders, in Windows Explorer - a tile of their own, its heading on a line above the three buttons (Nils
        // 2026-11-14). Beside the heading the row did not fit the panel's width (measured 2026-11-14).
        Get psExeFilePath of ghoManifestFunctionLibrary to sExePath
        Move (sHtml + DivOpen("cms-tile") + DivOpen("cms-tile-h") + DashIcon(CS_GlyphWindows) + TagText("span", "", "Windows Explorer") + CS_DivEnd + DivOpen("cms-row")) to sHtml
        Move (sHtml + DashButtonHtml(Self, "programfolder", CS_GlyphFolderOpen, "Programs", "Open the program's folder (Ctrl+D)", (sExePath <> ""), False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "fragmentfolder", CS_GlyphFolderOpen, "Fragments", "Open your fragment library's folder (Ctrl+L)", True, False)) to sHtml
        Move (sHtml + DashButtonHtml(Self, "comfolder", CS_GlyphFolderOpen, "COM", "Open your COM library's folder, where COM files are copied from (Ctrl+B)", True, False)) to sHtml
        Move (sHtml + CS_DivEnd + CS_DivEnd + CS_DivEnd) to sHtml

        Function_Return sHtml
    End_Function

    // Draws the dashboard: all of it (CI_DashAll), or the selected row's panel (CI_DashRow).
    Procedure UpdateDashboard Integer iWhat
        String sHtml
        String[] sLibraryFiles sFragments
        If (iWhat = CI_DashAll) Begin
            Send LoadFragmentsForManifest
            Send ShowRecordDates
            Get SelectedItems to sFragments
            Send SetFragmentsCaption (SizeOfArray(sFragments))
            Get AllManifestFragmentFiles of ghoManifestFunctionLibrary to sLibraryFiles
            Set piLibraryFiles to (SizeOfArray(sLibraryFiles))
            Get StepsHtml to sHtml
            Send UpdateHtml of oSteps_box sHtml
        End
        Get ToolsHtml to sHtml
        Send UpdateHtml of oTools_box sHtml
    End_Procedure

    // A dashboard button's work, after the web click has returned; sId is the button's data-ServerOnClick.
    // The same work as the menu command of the same name.
    Procedure DoDashboardAction String sId
        String sFragment sCOM sLibrary
        Boolean bExists bRegistered

        Case Begin
            Case (sId = "add")
                Send DoAddFragmentFiles
                Case Break
            Case (sId = "save")
                Send Request_Save of oMain_host
                Case Break
            Case (sId = "build")
                Send DoPreBuildManifestFile
                Case Break
            Case (sId = "viewmanifest")
                Send EditAppManifestFile of ghoManifestFunctionLibrary
                Case Break
            Case (sId = "copy")
                Send DoPreCopyCOMComponents
                Case Break
            Case (sId = "embed")
                Send EmbedManifestInProgram of ghoManifestFunctionLibrary
                Case Break
            Case (sId = "compress")
                Send CompressExeFile of ghoManifestFunctionLibrary
                Case Break
            Case (sId = "run")
                Send DoPreRunProgram
                Case Break
            Case (sId = "create")
                Send Popup of (oCreateManifestFragmentFile(Client_Id(ghoCommandBars)))
                Case Break
            Case (sId = "folderbatch")
                Send Activate_oCreateFragmentFilesFromFolder of (Client_Id(ghoCommandBars)) ""
                Case Break
            Case (sId = "download")
                Send DownloadManifestFragmentFiles of ghoManifestFunctionLibrary
                Case Break
            Case (sId = "share")
                Send DoShareManifestFragmentFiles of (Client_Id(ghoCommandBars))
                Case Break
            Case (sId = "check")
                // As the Components menu's Check registration, with its answer.
                Get Field_Current_Value of oManDet_DD Field ManDet.ManifestFragmentFile to sFragment
                Move (Trim(sFragment)) to sFragment
                Get psManifestFragmentLibrary of ghoManifestFunctionLibrary to sLibrary
                Get vFilePathExists (vFolderFormat(sLibrary) + sFragment) to bExists
                If (sFragment <> "" and bExists) Begin
                    Get CheckCOMRegistrationFromManifestFragmentFile of ghoManifestFunctionLibrary sFragment to bRegistered
                    Get ExtractCOMFileName of ghoManifestFunctionLibrary sFragment to sCOM
                    If (bRegistered) Begin
                        Send Info_Box ("Yes, the" * sCOM * "component is registered with Windows.")
                    End
                    Else Begin
                        Send Info_Box ("No, the" * sCOM * "component is not registered with Windows.")
                    End
                End
                Case Break
            Case (sId = "register")
                Send RegisterOrUnregister of ghoManifestFunctionLibrary True
                Case Break
            Case (sId = "unregister")
                Send RegisterOrUnregister of ghoManifestFunctionLibrary False
                Case Break
            Case (sId = "programfolder")
                Send OpenProgramsFolder of ghoManifestFunctionLibrary
                Case Break
            Case (sId = "fragmentfolder")
                Send OpenFragmentFolder of ghoManifestFunctionLibrary
                Case Break
            Case (sId = "comfolder")
                Send OpenCommonCOMFolder of ghoManifestFunctionLibrary
                Case Break
        Case End
        Send ArmDashboard
    End_Procedure

    Procedure DoPreBuildManifestFile
        String sFileName
        String[] sFilesArray
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFileName
        Get SelectedItems to sFilesArray
        Send BuildManifestFile of ghoManifestFunctionLibrary sFileName sFilesArray
    End_Procedure

    Procedure DoPreCopyCOMComponents
        String[] sSelectedFileNames
        Get SelectedItems to sSelectedFileNames
        Send CopyCOMComponents of ghoManifestFunctionLibrary sSelectedFileNames
    End_Procedure

    Procedure DoPreRunProgram
        String[] sSelectedFileNames
        Get SelectedItems to sSelectedFileNames
        Send Runprogram of ghoManifestFunctionLibrary sSelectedFileNames
    End_Procedure

    // Check to see if we should "auto-find" a record when the view is activated - the program started with a
    // program's name on its command line, as the Studio's Tools menu starts it.
    Procedure Page Integer iPageObject
        Forward Send Page iPageObject
        Send ArmDashboard
        Send LoadManifestFromApplication
    End_Procedure

    // The first drawing, once the view and its objects are built.
    Procedure End_Construct_Object
        Forward Send End_Construct_Object
        Send ArmDashboard
    End_Procedure

    // A manifest file that is not in the database yet can list COM components already - one made elsewhere, or
    // one whose record was deleted. Offer to fill the grid with the fragment files of the local library that
    // describe them (FragmentFilesForManifest), so they need not be picked one by one. The header record is saved
    // first, as a detail row needs its ID; the user is asked before anything is saved.
    Procedure FillGridFromManifestFile String sPath String sManifestFile
        String[] sFragments sMissing
        String sText sList
        Integer i iFound iMissing iRetval iID
        Boolean bHasRecord

        Send Cursor_Wait of Cursor_Control
        Get FragmentFilesForManifest of ghoManifestFunctionLibrary (vFolderFormat(sPath) + sManifestFile) (&sMissing) to sFragments
        Send Cursor_Ready of Cursor_Control
        Move (SizeOfArray(sFragments)) to iFound
        Move (SizeOfArray(sMissing))   to iMissing
        // No COM component in it: nothing to offer.
        If ((iFound + iMissing) = 0) Begin
            Procedure_Return
        End

        // The components without a fragment file, at most 15 named.
        Move "" to sList
        For i from 0 to (iMissing - 1)
            If (i < 15) Begin
                Move (sList + "\n   " + sMissing[i]) to sList
            End
        Loop
        If (iMissing > 15) Begin
            Move (sList + "\n   ... and" * String(iMissing - 15) * "more") to sList
        End
        If (iFound = 0) Begin
            Send Info_Box ("The manifest file lists" * String(iMissing) * "COM components, but none of them has a fragment file in your local 'Manifest Fragment Library':" + sList + "\n\nYou can create fragment files with 'Create a fragment file...' in the Fragments menu.")
            Procedure_Return
        End

        Move ("The manifest file lists" * String(iFound + iMissing) * "COM components. Fragment files were found in your local 'Manifest Fragment Library' for" * String(iFound) * "of them:") to sText
        For i from 0 to (iFound - 1)
            If (i < 15) Begin
                Move (sText + "\n   " + sFragments[i]) to sText
            End
        Loop
        If (iFound > 15) Begin
            Move (sText + "\n   ... and" * String(iFound - 15) * "more") to sText
        End
        If (iMissing > 0) Begin
            Move (sText + "\n\nNo fragment file was found for:" + sList + "\nYou can create them with 'Create a fragment file...' in the Fragments menu.") to sText
        End
        Move (sText + "\n\nDo you want to save the manifest record and add the found fragment files to the grid?") to sText
        Get YesNo_Box sText to iRetval
        If (iRetval <> MBR_Yes) Begin
            Procedure_Return
        End

        // Save the header at the DD (a save there does not clear the record); its ID is made as it is saved.
        Set Field_Changed_Value of oManHdr_DD Field ManHdr.ManifestFileName to sManifestFile
        Set Field_Changed_Value of oManHdr_DD Field ManHdr.Path             to sPath
        Send Request_Save of oManHdr_DD
        Get HasRecord of oManHdr_DD to bHasRecord
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
        If (bHasRecord = False or iID = 0) Begin
            Send Info_Box "The manifest record could not be saved, so the grid was not filled."
            Procedure_Return
        End
        Send AddFragmentFiles iID sFragments
    End_Procedure

    // The program's shortcuts with the focus on the view itself (the page has the same ones).
    On_Key Key_Alt+Key_O  Send DoOpenManifestList
    On_Key Key_Ctrl+Key_O Send DoBrowseManifestFile
    On_Key Key_Alt+Key_E  Send EditAppManifestFile            of ghoManifestFunctionLibrary
    On_Key Key_Alt+Key_B  Send DoPreBuildManifestFile
    On_Key Key_Ctrl+Key_P Send DoPreCopyCOMComponents
    On_Key Key_Ctrl+Key_E Send EmbedManifestInProgram         of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_R Send DoPreRunProgram
    On_Key Key_Ctrl+Key_L Send OpenFragmentFolder             of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_D Send OpenProgramsFolder             of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_B Send OpenCommonCOMFolder            of ghoManifestFunctionLibrary
    On_Key Key_Alt+Key_D  Send DownloadManifestFragmentFiles  of ghoManifestFunctionLibrary
    On_Key Key_Alt+Key_S  Send DoShareManifestFragmentFiles   of (Client_Id(ghoCommandBars))
    On_Key Key_Alt+Key_L  Send DoRegisterComponent

    On_Key Key_Ctrl+Key_S Send Request_Save
    On_Key kCancel        Send None
    On_Key kClear         Send Clear_All
    On_Key Key_Ctrl+Key_F4 Send None
    On_Key Key_F3          Send None
End_Object

// The New Project wizard's last step: the manifest it made, shown in the main view.
Procedure DoLoadDbMergerViewFromApplicationObject
    Send LoadManifestFromApplication of (phoMainView(ghoApplication))
End_Procedure
