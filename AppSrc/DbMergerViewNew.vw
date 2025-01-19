Use DFClient.pkg
Use cCJCommandBarSystem.pkg
Use cCJGridColumnRowIndicator.pkg
Use cCJGridColumn.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use cTextEdit.pkg         
Use cRDCSlideButton.pkg
Use cRDCDbForm.pkg
Use cRDCDbCJGrid.pkg
Use cRDCDbCJGridColumn.pkg
Use cRDCRichEditor.pkg
Use cRDCDbRichEditor.pkg
Use cRDCDbSuggestionForm.pkg
Use cRDCButton.pkg  
Use cRDCDbReadOnlyForm.pkg
Use cRDCDbFormOrDbSuggestionForm.pkg
Use cRDCDbGroup.pkg
Use cRDCHeaderDbGroup.pkg
Use cManifestFunctionLibrary.pkg
Use cManifestIniFile.pkg
Use oDEOEditContextMenuManifest.pkg
Use Symdef.pkg
Use vWin32fh.pkg

Use oRichEditFind.dg
Use oRichEditFindReplace.dg
Use COMComponents.dg
//Use Setup2.dg
Use ProgramSetup.dg
Use DownloadFiles.dg

Use cManHdrDataDictionary.dd
Use cManDetManDataDictionary.dd
Use Windows.pkg

Register_Object oManHdrManifestFileName_fm
Register_Object oManHdrPath_fm

Activate_View Activate_oDbMerger_vw for oDbMerger_vw
Object oDbMerger_vw is a dbView
    Set Size to 279 400
    Set Location to 0 0 
    Set Label to "Main view"  
//    Set Icon to "COMManifestManager.ico"
    // Saves in header should not clear the view
    Set Auto_Clear_DEO_State to False
    Set Verify_Save_Msg to (RefFunc(No_Confirmation))
    Set pbAcceptDropFiles to True
    Set pbAutoActivate to True

    Property String[] pArrayOfDroppedFiles

    Object oManHdr_DD is a cManHdrDataDictionary
        Set Allow_Foreign_New_Save_State to True
    End_Object

    Object oManDet_DD is a cManDetManDataDictionary
        Set DDO_Server To oManHdr_DD
        Set Constrain_File To ManHdr.File_Number
    End_Object

    Set Main_DD to oManHdr_DD
    Set Server  to oManHdr_DD

    Object oCompile_Info_tb is a TextBox
        Set Size to 10 33
        Set Location to 2 12
        Set Label to "NOTE: This program needs to compiled as 32-bit to function properly!"
        Set FontWeight to fw_Bold
    End_Object

    Object oAppManifest_grp is a cRDCHeaderDbGroup //cRDCDbGroup
        Set Size to 68 376
        Set Location to 16 12
        Set Label to "Manifest File"
        Set psNote to "Select manifest file for your Windows program (.exe) file"  
        Set psImage to "Program.ico"
        Set peAnchors to anTopLeftRight

       Object oManHdrManifestFileName_fm is a cRDCDbSuggestionForm
            Entry_Item ManHdr.ManifestFileName
            Set Size to 13 301
            Set Location to 29 16
            Set peAnchors to anTopLeftRight
            Set psToolTip to "This is the application manifest file. It has the same name as the executable, with an added '.manifest' word at the end. To select an application manifest file press the 'Browse...' button or press. Or press (F4) to display a selection list with previously created records. Note: A filename in red denotes it is missing!"
            Set Floating_Menu_Object to oDEOEditContextMenuManifest
            Set pbFullText to True
            Set phoMainPromptObject of ghoApplication to Self

            // Augment method to add further info to the Suggestion List.
            // Note that the Forward is _after_ the augmentation.
            Procedure ShowSuggestion tSuggestion SuggestionData String sSearch
                Integer iPos iLen iLineNum
                String sManifestFileName

                Send ReadByRowId to (Server(Self)) (Data_File(Self)) (DeserializeRowID(SuggestionData.sRowId))
                Move ManHdr.ManifestFileName   to SuggestionData.aValues[0]
                Move ManHdr.Path to SuggestionData.aValues[1]
                Forward Send ShowSuggestion SuggestionData sSearch
            End_Procedure

            Procedure Refresh Integer notifyMode
                String sManifestFile sPath
                Boolean bExists

                Forward Send Refresh notifyMode
                Get Field_Current_Value of oManHdr_DD Field ManHdr.Path             to sPath
                Get vFolderFormat sPath to sPath
                Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sManifestFile
                Send SetApplicationStrings of ghoManifestFunctionLibrary (sPath + sManifestFile)

                Get vFilePathExists (sPath + sManifestFile) to bExists
                // If either the file or folder doesn't exist change the form text to red, to denote it is missing.
                If (bExists = False and sPath <> "" and sManifestFile <> "") Begin
                    Set TextColor to clRed
                End
                Else Begin
                    Set TextColor to clBlack
                End
            End_Procedure

            Procedure OnChange
                Boolean bExists
                String sFileName sPath

                Forward Send OnChange
                Get Value of (phoManifestPathObject(ghoApplication)) to sPath
                Get vFolderFormat sPath to sPath
                Get Value to sFileName
                Get vFilePathExists sFileName to bExists

                If (bExists = False) Begin
                    Set TextColor to clRed
                End
                Else Begin
                    Set TextColor to clWindowText
                End
            End_Procedure

            On_Key Key_F6 Send Activate of oManifest_grid
        End_Object

        Object oSelectManifest_btn is a cRDCButton
            Set Size to 13 44
            Set Location to 29 321
            Set Label to "Browse..."
            Set psToolTip to "Click to show an Open dialog for you to select an application manifest file from. The file has the same name as the executable file, with an added '.manifest' keyword. (Ctrl+O)"
            Set peAnchors to anTopRight           
            Set psImage to "FolderOpen.ico"

            Procedure OnClick
                Handle ho hoPath
                Get phoMainPromptObject    of ghoApplication to ho
                Get phoManifestPathObject  of ghoApplication to hoPath
                Send SelectAppManifestFile of ghoManifestFunctionLibrary ho hoPath
            End_Procedure
        End_Object

        Object oManHdrPath_fm is a cRDCDbForm
            Entry_Item ManHdr.Path
            Set Size to 13 301
            Set Location to 44 16
            Set peAnchors to anTopLeftRight
            Set phoManifestPathObject of ghoApplication to Self
            Set Enabled_State to False
        End_Object

        Procedure Mouse_Down2 Integer iWindowNumber Integer iPosition
            Forward Send Mouse_Down2 iWindowNumber iPosition
            Send Popup of oViewContextMenu
        End_Procedure

        Object oEditPath_btn is a cRDCButton
            Set Size to 13 44
            Set Location to 44 321
            Set Label to "Enable"
            Set psToolTip to "Makes the path window accessable for edit."
            Set peAnchors to anTopRight

            Procedure OnClick
                Boolean bEnabled
                Get Enabled_State of oManHdrPath_fm to bEnabled
                Set Enabled_State of oManHdrPath_fm to (not(bEnabled))
                Set Label to (If(bEnabled, "Enable", "Disable"))
            End_Procedure
        End_Object

    End_Object

    Procedure Refresh Integer eMode
        String sPath sFileName
        Boolean bExists
        Forward Send Refresh eMode
        Get Field_Current_Value of oManHdr_DD Field ManHdr.Path to sPath
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFileName

        Get vFilePathExists (sPath + sFileName) to bExists
        // If either the file or folder doesn't exist change the form text to red, to denote it is missing.
        If (bExists = False and sPath <> "" and sFileName <> "") Begin
            Set TextColor to clRed
        End
        Else Begin
            Set TextColor to clBlack
        End

        Send SetApplicationStrings of ghoManifestFunctionLibrary (sPath + sFileName)
    End_Procedure

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete entire header and all details?" to bFail
        Function_Return bFail
    End_Function
    Set Verify_Delete_MSG to (RefFunc(ConfirmDeleteHeader))

    Object oManifestFragmentFileGrid_grp is a cRDCHeaderDbGroup
        Set Size to 94 376
        Set Location to 92 12
        Set Label to "Manifest Fragment Files"                 
        Set psNote to "Select one fragment file for each *.ocx/*.dll ActiveX component"
        Set psImage to "FragmentFile.ico"
        Set peAnchors to anAll

        Object oManifest_grid is a cRDCDbCJGrid
            Set Server to oManDet_DD
            Set Ordering to 3
            Set Size to 57 347
            Set Location to 30 16
            Set pbAllowDeleteRow to True
            Set Verify_Delete_Msg to (RefFunc(No_Confirmation))
            Set Verify_Data_Loss_Msg to (RefFunc(No_Confirmation))
            Set Verify_Save_msg to (RefFunc(No_Confirmation))

            Set phoManifest_grid of ghoApplication to Self

            Object oCJGridColumnRowIndicator is a cCJGridColumnRowIndicator
                Set piWidth to 27
            End_Object

            Object oFragmentFileCol is a cRDCDbCJGridColumn
                Entry_Item ManDet.ManifestFragmentFile
                Set piWidth to 256
                Set psCaption to "Click to select components (F4)"
                Set psToolTip to "Click the header or press (F4) from the grid to select manifest fragment files."
                Set Status_Help to (psToolTip(Self))
                Set Prompt_Button_Mode to PB_PromptOn
                Set psImage to "ActionPrompt.ico"
                Set pbMultiLine to True

                Procedure Prompt
                    String[] sFileNames sRetvalsArray
                    Integer i iRows iID iRetval

                    Get Field_Current_Value of oManHdr_DD Field ManHdr.ID to iID
                    If (iID = 0) Begin
                        Procedure_Return
                    End

                    // Get the current grid fragment files
                    Get SelectedItems to sFileNames
                    // Popup the selection list!
                    Get ActivateFragmentFiles_sl (&sFileNames) to sRetvalsArray
                    // Get the selection from the popup list and add them to the grid:
                    Move (SizeOfArray(sRetvalsArray)) to iRows
                    If (iRows = 0) ;
                        Procedure_Return

                    // Create new records from the returned sRetvalsArray values
                    Decrement iRows
                    Lock
                        For i from 0 to iRows
                            Clear ManDet
                            Get GlobalAutoCreateNewID File_Field ManDet.ID False to iRetval
                            Move iRetval to ManDet.ID
                            Move iID to ManDet.ManHdrID
                            Move sRetvalsArray[i] to ManDet.ManifestFragmentFile
                            SaveRecord ManDet
                        Loop
                    Unlock

                    // Refresh grid from the database table's records
                    Send RefreshDataFromExternal of oManifest_grid 0
                    Send MovetoFirstRow
                End_Procedure

                // Check if the manifest fragment file is missing; in case we set the textcolor to red
                Procedure OnSetDisplayMetrics Handle hoMetrics Integer iRow String ByRef sValue
                    String sPath
                    Boolean bExists
                    If (sValue <> "") Begin
                        Get psManifestFragmentLibrary of ghoManifestFunctionLibrary to sPath
                        Get vFolderFormat sPath to sPath
                        Get vFilePathExists (sPath + sValue) to bExists
                        If (bExists = False) Begin
                            Set ComForeColor of hoMetrics to clRed
                        End
                    End
                End_Procedure

                // Check if the manifest fragment file is missing; in case we set the textcolor to red
                // Else show tooltip about right-click context sensitive menu.
                Function OnGetTooltip Integer iRow String sValue String sText Returns String
                    Boolean bExists
                    String sPath
                    If (sValue <> "") Begin
                        Get psManifestFragmentLibrary of ghoManifestFunctionLibrary to sPath
                        Get vFolderFormat sPath to sPath
                        Get vFilePathExists (sPath + sValue) to bExists
                        If (bExists = False) Begin
                            Move "Filenames with red text indicates that the file is missing from the Manifest Fragment Library OR the pathing to the 'Manifest Fragment Library' settings is incorrect. You can correct the pathing from the 'Configure' dialog." to sText
                        End
                        Else Begin
                            Move (sValue + ".  Right-click grid row for menu options") to sText
                        End
                    End
                    Function_Return sText
                End_Function

            End_Object

            Object oComment_Column is a cRDCDbCJGridColumn 
                Set piWidth to 411
                Set psCaption to "Description"
                Set psToolTip to "Click the header or press (F4) from the grid to select manifest fragment files."
                Set pbMultiLine to True
                Set Status_Help to (psCaption(Self))
                Set Prompt_Button_Mode to PB_PromptOn
                Set Prompt_Object to oFragmentFiles_sl

                Procedure Prompt
                    Send Prompt of oFragmentFileCol
                End_Procedure

                // Show the comment from the current row's manifest fragment file in this column:
                Procedure OnSetCalculatedValue String ByRef sValue
                    Forward Send OnSetCalculatedValue sValue
                    Move (Trim(ManDet.ManifestFragmentFile)) to sValue
                    If (sValue contains ".txt") Begin
                        Get ExtractManifestFragmentFileComment of ghoManifestFunctionLibrary sValue to sValue
                    End
                End_Procedure

                Function OnGetTooltip Integer iRow String sValue String sText Returns String
                    String sRetVal
                    Forward Get OnGetTooltip iRow sValue sText to sRetVal
                    Move "Right-click grid rows for menu options" to sRetVal
                    Function_Return sRetVal
                End_Function

            End_Object

            // Grid messages:
            //
            // Always show the manifest fragment files prompt list, no matter
            // what column header is clicked. It just makes sense here.
            Procedure OnHeaderClick Integer iCol
                Send Prompt of oFragmentFileCol
            End_Procedure

            // Send by grid subclass Refresh message.
            Procedure DoSetCurrentRow
                Handle hoDataSource
                Integer iRows

                Forward Send DoSetCurrentRow

                Get phoDataSource to hoDataSource
                Get RowCount      of hoDataSource to iRows
                Set psFooterText of oFragmentFileCol to (" No of Components:" * String(iRows))
            End_Procedure

            Function SelectedItems Returns String[]
                Integer i iRows iFileName_Col
                Handle hoDataSource
                tDataSourceRow[] TheData
                String[] sFilesArray
                String sFileName

                Get phoDataSource              to hoDataSource
                Get DataSource of hoDataSource to TheData
                Move (SizeOfArray(TheData))    to iRows
                Get piColumnId of oFragmentFileCol to iFileName_Col
                Decrement iRows
                For i from 0 to iRows
                    Move TheData[i].sValue[iFileName_Col] to sFileName
                    Move sFileName to sFilesArray[i]
                Loop

                Function_Return sFilesArray
            End_Function

            // Contect sensitive menu for the grid object
            // Right mouse button click.
            Object oGridContextMenu is a cCJContextMenu

                Object oOpenGridItem_MenuItem is a cCJMenuItem
                    Set psCaption to "Edit File Under Cursor"
                    Set psDescription to "Opens the file under the cursor in the editor"
                    Set psImage to "FragmentEdit.ico"
                    Set psShortcut to "Double-Click"
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send OpenCurrentGridItem of ghoManifestFunctionLibrary
                    End_Procedure
                    Function IsEnabled Returns Boolean
                        String sManifestFile
                        Get psManifestFileName of ghoManifestFunctionLibrary to sManifestFile
                        Function_Return (sManifestFile <> "")
                    End_Function
                End_Object

                Object oCreateFragmentFiles_MenuItem is a cCJMenuItem
                    Set psCaption to "&Create New Fragment File"
                    Set psToolTip to "Create a new manifest fragment file (Alt+C)"
                    Set psDescription to "If you cannot find a manifest fragment file for your COM (OCX/DLL) component you can create one here."
                    Set peControlStyle to xtpButtonIconAndCaption
                    Set psImage to "FragmentNew.ico"
                    Set psShortcut to "Alt+C"
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send Popup of (oCreateManifestFragmentFile(Client_Id(ghoCommandBars)))
                    End_Procedure
                End_Object

                Object oDownloadFragmentFiles_MenuItem is a cCJMenuItem
                    Set psCaption to "&Download New Fragment Files"
                    Set psDescription to "Download new manifest fragment files from the vdf-guidance global repository"
                    Set psImage to "FragmentDownload.ico"
                    Set psShortcut to "Alt+D"
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send DownloadManifestFragmentFiles of ghoManifestFunctionLibrary
                    End_Procedure
                End_Object

                Object oShareFragmentFiles_MenuItem is a cCJMenuItem
                    Set psCaption to "&Share New Fragment Files"
                    Set psDescription to "E-mail manifest fragment files that you have created"
                    Set psShortcut to "Alt+S"
                    Set psImage to "FragmentShare.ico"
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send DoShareManifestFragmentFiles of (Client_Id(ghoCommandBars))
                    End_Procedure
                End_Object

                Object oPromptMenuItem is a cCJPromptMenuItem
                    Set pbControlBeginGroup to True
                End_Object

                Object oDeleteMenuItem is a cCJDeleteMenuItem
                End_Object

                Object oCheckIfCOMComponentIsRegisteredMenuItem is a cCJMenuItem
                    Set psCaption to "&Check if COM Component is registered"
                    Set psDescription to "Is the COM (OCX/DLL) component registered with Windows?"
                    Set pbControlBeginGroup to True
                    Set psImage to "COMCheck.ico" 
                    Procedure OnExecute Variant vCommandBarControl
                        String sManifestFragmentFile sResult sCOMFileName
                        Boolean bRegistered
                        Forward Send OnExecute vCommandBarControl
                        Get Field_Current_Value of oManDet_DD Field ManDet.ManifestFragmentFile to sManifestFragmentFile
                        Get CheckCOMRegistrationFromManifestFragmentFile of ghoManifestFunctionLibrary sManifestFragmentFile to bRegistered
                        Get ExtractCOMFileName of ghoManifestFunctionLibrary sManifestFragmentFile to sCOMFileName
                        If (bRegistered = True) Begin
                            Move ("Yes, the" * sCOMFileName * "component is registered with Windows.") to sResult
                        End
                        Else Begin
                            Move ("No, the" * sCOMFileName * "component is not registered with Windows.") to sResult
                        End
                        Send Info_Box sResult
                    End_Procedure

                End_Object

                Object oRegisterCOMComponentMenuItem is a cCJMenuItem
                    Set psCaption to "&Register COM Component"
                    Set psDescription to "Registers the COM (OCX/DLL) Component corresponding to the manifest fragment file under the cursor in Windows registry"
                    Set psImage to "RegisterDLL.ico"
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send RegisterOrUnregister of ghoManifestFunctionLibrary True
                    End_Procedure

                End_Object

                Object oUnRegisterCOMComponentMenuItem is a cCJMenuItem
                    Set psCaption to "&UnRegister COM Component"
                    Set psDescription to "Unregisters the COM (OCX/DLL) Component corresponding to the manifest fragment file under the cursor, from Windows registry"
                    Set psImage to "UnRegisterDLL.ico"
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send RegisterOrUnregister of ghoManifestFunctionLibrary False
                    End_Procedure
                End_Object

                Procedure OnCreate
                    Forward Send OnCreate
                    Send ComSetIconSize 24 24
                End_Procedure

                Delegate Set phoContextMenu to Self
            End_Object

            // Make the enter key activate the check & merge button
            Procedure OnEnterKey
                String sFileName
                Forward Send OnEnterKey
                String[] sFilesArray
                Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFileName
                Get SelectedItems of oManifest_grid to sFilesArray
                Send BuildManifestFile of ghoManifestFunctionLibrary sFileName sFilesArray
            End_Procedure

            // Make mouse double-click of left button open the current
            // grid item.
//            Procedure OnComRowDblClick Variant llRow Variant llItem
//                Forward Send OnComRowDblClick llRow llItem
//                Send OpenCurrentGridItem of ghoManifestFunctionLibrary
//            End_Procedure

            Function OnPostEntering Returns Boolean
                Boolean bRetVal
                Handle hoSrvr
                Boolean bErr

                Forward Get OnPostEntering to bRetVal

                Delegate Get Server to hoSrvr
                Get Request_Validate of hoSrvr to bErr
                If (bErr = False) Begin
                    Delegate Send Request_Save
                    If (Err = True) Begin
                        Send Info_Box "The manifest filename and path needs to be unique and there already exist a record with these values. Please adjust and try again."
                    End
                End

                Function_Return (Err)
            End_Function

            // Returns number of items.
            Function ItemCount Returns Integer
                Integer iItems
                Handle hoDataSource
                tDataSourceRow[] TheData
        
                Get phoDataSource to hoDataSource
                Get DataSource of hoDataSource to TheData
                Move (SizeOfArray(TheData)) to iItems
        
                Function_Return iItems
            End_Function

            Procedure OnEntering
                Handle hoSrvr
                Boolean bChanged
                Delegate Get Server to hoSrvr
                Get Should_Save of hoSrvr to bChanged
                If (bChanged = True) Begin
                    Set pbNeedPostEntering to True
                End
            End_Procedure

            // In this grid it doesn't make any to clear if the "Clear" menu
            // button is pressed. Make it clear all instead.
            Procedure Request_Clear
                Send Request_Clear_All
            End_Procedure

            Procedure ProcessDroppedFiles String[] ArrayOfDroppedFiles
                Integer iItems iCount iID
                String sFileName
                Handle hoDD
                Boolean bErr

                Get Server to hoDD
                Get File_Field_Current_Value of hoDD File_Field ManHdr.ID               to iID
                Get File_Field_Current_Value of hoDD File_Field ManHdr.ManifestFileName to sFileName
                If (sFileName = "") Begin
                    Send Stop_Box "You need to select a .manifest file first."
                    Procedure_Return
                End

                // If the parent record isn't created yet, try saving/creating now.
                If (iID = 0) Begin
                    Send Request_Save of (Parent(Self))
                    If (Err) Begin
                        Send Stop_Box "Couldn't save the new header record. Try saving the header manually, then try dropping files on the grid."
                        Procedure_Return
                    End
                End

                Move (SizeOfArray(ArrayOfDroppedFiles)) to iItems
                Decrement iItems

                For iCount from 0 to iItems
                    Move ArrayOfDroppedFiles[iCount] to sFileName
                    Get ParseFileName sFileName to sFileName
                    Send Clear of hoDD
                    Set Field_Changed_Value of hoDD Field ManDet.ManifestFragmentFile to sFileName
                    Get Request_Validate of hoDD to bErr
                    If (bErr = False) Begin
                        Send Request_Save of hoDD
                    End
                Loop

                Send RefreshDataFromSelectedRow
            End_Procedure

            Procedure OnComRowDblClick Variant llRow Variant llItem
                Forward Send OnComRowDblClick llRow llItem
                Send OpenCurrentGridItem of ghoManifestFunctionLibrary
            End_Procedure

            Procedure End_Construct_Object                                                                          
                String sColor
                Forward Send End_Construct_Object
                Get IniFileValue of ghoManifestIniFile (psSectionName(ghoManifestIniFile)) CS_HighlightColorText clNone to sColor
                Set piSelectedRowBackColor to sColor
                Set piHighlightBackColor   to sColor 
            End_Procedure
        
            On_Key Key_Delete Send Request_Delete
        End_Object

        Procedure Mouse_Down2 Integer iWindowNumber Integer iPosition
            Forward Send Mouse_Down2 iWindowNumber iPosition
            Send Popup of oViewContextMenu
        End_Procedure
            
    End_Object

    Object oDbTabDialog is a dbTabDialog
        Set Size to 81 377
        Set Location to 191 12
        Set peAnchors to anBottomLeftRight
        Set Rotate_Mode to RM_Rotate_in_Ring
        Set Skip_Button_Mode to SBM_Never

Register_Object oViewContextMenu

//        Object oHelpInfo_tp is a dbTabPage
//            Set Label to "Instructions"
//
//            Object oInfo_3d is a Container3d
//                Set Size to 45 347
//                Set Location to 7 16
//                Set peAnchors to anTopLeftRight
//                Set Skip_State to True
////                Set Color to clBtnFace
//                Set Color to clWindow
//                Set Border_Style to Border_ClientEdge
//
//                Object oGeneralInfo_edt is a cRDCRichEditor
//                    Set Size to 38 338
//                    Set Location to 2 7
//                    Set peAnchors to anTopLeftRight
//                    Set Read_Only_State to True
//                    Set Floating_Menu_Object to oViewContextMenu
//                    Set Border_Style to Border_None
//                    Set Skip_State to True
//
//                    // Dummy message. It is here for the compiler to embed the rtf-file
//                    // in the program.
//                    // The compiler will pick up the include_resource and read the file from
//                    // the _Help_ folder.
//                    Procedure _DummyEmbedFile
//                        Include_Resource ..\Help\TopInfoBoxNew.rtf as res_TopInfoBoxHelp Type DF_RESOURCE_TYPE_BINARY
//                    End_Procedure
//
//                    Procedure DoReadFile String sFileName Boolean bEmbedFile
//                        Move "Resource:res_TopInfoBoxHelp" to sFileName
//                        Forward Send DoReadFile sFileName bEmbedFile
//                    End_Procedure
//
//                    // This is a fix for a bug in the cRichEdit class.
//                    // When the skin changes, the color
//                    // isn't respected until the app is re-started.
//                    // When the skin changes the DoChangeSkin method is
//                    // called and it makes a broadcast send DoSetCurrentRow.
//                    Procedure DoSetCurrentRow
//                        Set Color to clBtnFace
//                    End_Procedure
//                End_Object
//
//            End_Object
//
//            Procedure Mouse_Down2 Integer iWindowNumber Integer iPosition
//                Forward Send Mouse_Down2 iWindowNumber iPosition
//                Send Popup of oViewContextMenu
//            End_Procedure
//
//        End_Object

        Object oNotes_tp is a dbTabPage
            Set Label to "Your Notes"

            Object oRTFToolbar_Container is a Container3d
                Set Size to 17 344
                Set Location to 2 15
                Set Border_Style to Border_None
                Set peAnchors to anBottomLeftRight
                Set Skip_State to True

                Object oViewCommandBarSystem is a cCJCommandBarSystem
                    Set pbTimerUpdate to True
                    Set psLayoutSection to "CommandBarsRTF"
                    Set pbAutoResizeIcons to True
                    // Note: This is work curtesy of Vincent Oorsprong Data Access Worldwide.
                    #Include oRTFButtonBand.pkg
                End_Object

            End_Object

            Object oManHdr_Comment_Edit is a cRDCDbRichEditor // Note: This is work curtesy of Vincent Oorsprong Data Access Worldwide.
                Entry_Item ManHdr.Comment
                Set Location to 22 16
                Set Size to 35 344
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
                Set peAnchors to anBottomLeftRight
                // Should skip_state be True or False? Don't know which is best...
                //Set Skip_State to True
                Procedure Activating
                    Forward Send Activating
                    Set psToolTip to (Status_Help(Self))
                End_Procedure

            End_Object

            Procedure Mouse_Down2 Integer iWindowNumber Integer iPosition
                Forward Send Mouse_Down2 iWindowNumber iPosition
                Send Popup of oViewContextMenu
            End_Procedure

        End_Object

        Object oRecordInfo_tp is a dbTabPage
            Set Label to "Record Info"

            Object oManHdrCreatedDateTime_fm is a cRDCDbReadOnlyForm
                Entry_Item ManHdr.CreatedDateTime
                Set Size to 13 122
                Set Location to 19 45
                Set peAnchors to anNone
                Set Label to "Created"
            End_Object

            Object oManHdrChangedDateTime_fm is a cRDCDbReadOnlyForm
                Entry_Item ManHdr.ChangedDateTime
                Set Size to 13 122
                Set Location to 34 45
                Set peAnchors to anNone
                Set Label to "Last Edited"
            End_Object

            Object oManHdrCreatedBy_fm is a cRDCDbReadOnlyForm
                Entry_Item ManHdr.CreatedBy
                Set Size to 13 182
                Set Location to 19 184
                Set peAnchors to anTopLeftRight
                Set Label to "By"
            End_Object

            Object oManHdrChangedBy_fm is a cRDCDbReadOnlyForm
                Entry_Item ManHdr.ChangedBy
                Set Size to 13 182
                Set Location to 34 184
                Set peAnchors to anTopLeftRight
                Set Label to "By"
            End_Object

            Procedure Mouse_Down2 Integer iWindowNumber Integer iPosition
                Forward Send Mouse_Down2 iWindowNumber iPosition
                Send Popup of oViewContextMenu
            End_Procedure

        End_Object

//        Object oDebugOutput_tp is a dbTabPage
//            Set Label to "Debugger"
//
//            Object oDebugOutput_edt is a cTextEdit
//                Set Size to 51 325
//                Set Location to 9 3
//                Set Label to "Debugger Output:"
//                Set peAnchors to anAll
//            End_Object
//
//            Object oStartDebugger_btn is a cRDCButton
//                Set Size to 25 38
//                Set Location to 9 332
//                Set Label to "Start Debugger"
//                Set MultiLineState to True
//                Set peAnchors to anTopRight
//
//                // ToDo: The debugger stuff needs to be finished...
//                Procedure OnClick
//                    Send DoDebug
//                End_Procedure
//
//            End_Object
//
//            // ToDo: This logic needs some more work...
//            Procedure DoDebug
//                String sText sLogFileBin sLogFileText sParams sStartTrace sParseTrace sProgramPath
//                Integer iCh
//                Get psProgramPath of (phoWorkspace(ghoApplication))     to sProgramPath
//                Get vFolderFormat sProgramPath to sProgramPath
//                Move "sxstrace Trace -logfile:sxs.bin"                  to sStartTrace
//                Move "sxstrace Parse -logfile:sxs.bin -outfile:sxs.txt" to sParseTrace
//                Runprogram Shell Background (sProgramPath + sStartTrace)
//                Runprogram Shell Background (sProgramPath + sParseTrace)
//            End_Procedure
//
//        End_Object

        // This is needed for navigational reasons. If not here the navigation
        // gets "stuck" at this object when F6 is pressed. This gently moves
        // the focus to the next group, which is the first entry form.
        On_Key Key_F6 Send Activate of (phoMainPromptObject(ghoApplication))
    End_Object

    Object oViewContextMenu is a cCJContextMenu

        Procedure OnCreate
            Forward Send OnCreate
            Send ComSetIconSize 24 24
        End_Procedure

        Object oOpenManifestFile_MenuItem is a cCJMenuItem
            Set psCaption to "Browse Application Manifest File"
            Set psDescription to "Shows an open dialog where to select an application manifest file from"
            Set psImage to "FolderOpen.ico"
            Set pbControlBeginGroup to True
            Procedure OnExecute Variant vCommandBarControl
                Handle ho hoPath
                Forward Send OnExecute vCommandBarControl
                Get phoMainPromptObject      of ghoApplication to ho
                Get phoManifestPathObject    of ghoApplication to hoPath
                Send SelectAppManifestFile of ghoManifestFunctionLibrary ho hoPath
            End_Procedure
        End_Object

        Object oCheckAndMerge_MenuItem is a cCJMenuItem
            Set psCaption to "&Build App Manifest File!"
            Set psDescription to "Checks for duplicate TypeLib declarations and merges the selected fragment files with the application manifest file."
            Set psImage to "Build.ico"
            Set psShortcut to "Alt+B"
            Procedure OnExecute Variant vCommandBarControl
                String sFileName
                String[] sFilesArray
                Forward Send OnExecute vCommandBarControl
                Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFileName
                Get SelectedItems of (phoManifest_grid(ghoApplication)) to sFilesArray
                Send BuildManifestFile of ghoManifestFunctionLibrary sFileName sFilesArray
            End_Procedure
            Function IsEnabled Returns Boolean
                String sManifestFile
                Get psManifestFileName of ghoManifestFunctionLibrary to sManifestFile
                Function_Return (sManifestFile <> "")
            End_Function
        End_Object

        Object oViewManifestFile_MenuItem is a cCJMenuItem
            Set psCaption to "Edit Application Manifest &File"
            Set psDescription to "Opens the application manifest file in the editor"
            Set psImage to "EditDocument.ico"
            Set psShortcut to "Ctrl+F"
            Procedure OnExecute Variant vCommandBarControl
                Forward Send OnExecute vCommandBarControl
                Send EditAppManifestFile of ghoManifestFunctionLibrary
            End_Procedure
            Function IsEnabled Returns Boolean
                String sManifestFile
                Get psManifestFileName of ghoManifestFunctionLibrary to sManifestFile
                Function_Return (sManifestFile <> "")
            End_Function
        End_Object

        Object oSetup_MenuItem is a cCJMenuItem
            Set psCaption to "Con&figure"
            Set psDescription to "Change program settings"
            Set psImage to "Configure032N32.ico"
            Set psShortcut to "Alt+F"
            Set pbControlBeginGroup to True
            Procedure OnExecute Variant vCommandBarControl
                Forward Send OnExecute vCommandBarControl
                Send Popup of (oProgramSetup_Panel(Client_Id(ghoCommandBars)))
                Send OnStartup of ghoManifestIniFile
            End_Procedure
        End_Object

    End_Object

    // Context sensitive menu for the view
    Procedure Mouse_Down2 Integer iWindowNumber Integer iPosition
        Forward Send Mouse_Down2 iWindowNumber iPosition
        Send Popup of oViewContextMenu
    End_Procedure

    Procedure DoPreBuildManifestFile
        String sFileName
        String[] sFilesArray
        Get Field_Current_Value of oManHdr_DD Field ManHdr.ManifestFileName to sFileName
        Get SelectedItems of oManifest_grid to sFilesArray
        Send BuildManifestFile of ghoManifestFunctionLibrary sFileName sFilesArray
    End_Procedure

    Procedure DoPreCopyCOMComponents
        String[] sSelectedFileNames
        Get SelectedItems of oManifest_grid to sSelectedFileNames
        Send CopyCOMComponents of ghoManifestFunctionLibrary sSelectedFileNames
    End_Procedure

    Procedure DoPreRunProgram
        String[] sSelectedFileNames
        Get SelectedItems of oManifest_grid to sSelectedFileNames
        Send Runprogram of ghoManifestFunctionLibrary sSelectedFileNames
    End_Procedure

    // Check to see if we should "auto-find" a record when the view is activated.
    // It should be done if the program was started from e.g. the DataFlex Studio's Tools menu
    Procedure Page Integer iPageObject
        String sArgument sManifestFileName sPath
        Integer iRetval
        Handle ho
        Boolean bAutoSign bFound

        Forward Send Page iPageObject

        // Note: The following line is essential for the resizing logic
        // to work when starting the program.
        Move (Client_Id(ghoCommandBars)) to ho
//        Set Border_Style of ho to Border_ClientEdge

        // Read the embedded info rtf file from memory & display it.
//        Move (oGeneralInfo_edt(Self)) to ho
//        If (ho <> 0) Begin
//            Set TextFile of oGeneralInfo_edt to CS_TopInfoHelp True
//        End

        // Check if program started with command line parameters, in
        // case we auto-load that record.
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
                // If true we will automatically digitally sign the executable file
                // for the found record.
                Get pbAutoSign of ghoApplication to bAutoSign
                If (bAutoSign = True) Begin
                    Send SignFileDigitally of ghoManifestFunctionLibrary
                End
            End
            Else Begin
                Send Clear of oManHdr_DD
            End
        End
    End_Procedure

    Procedure OnFileDropped String sFilename Boolean bLast
        Integer  iFiles
        String[] ArrayOfDroppedFiles EmptyArray

        Get pArrayOfDroppedFiles to ArrayOfDroppedFiles

        // Add the filename to the list of dropped files....
        Move (SizeOfArray(ArrayOfDroppedFiles)) to iFiles
        Move sFilename to ArrayOfDroppedFiles[iFiles]

        // If this was the last file, process them and clear the list
        If (bLast) Begin
            Send ProcessDroppedFiles of oManifest_grid ArrayOfDroppedFiles
            // clear the property so it is ready for next drop
            Move EmptyArray to ArrayOfDroppedFiles
        End

        Set pArrayOfDroppedFiles to ArrayOfDroppedFiles

    End_Procedure

    // ToDo: Redo in cManifestFunctionLibrary the same way as SignFileDigitally and subcall function in the cDigitalSoftwareCertificate class.
    Procedure ValidateDigitalCertificate
        String sYes
        tCertificateParams CertificateParams

        Get Value of (phoManifestPathObject(ghoApplication)) to CertificateParams.sProgramPath
        Get Value of (phoMainPromptObject(ghoApplication))   to CertificateParams.sFileName
        Get IniFileValue of ghoManifestIniFile (psSectionName(ghoManifestIniFile)) CS_UseVerboseState "" to sYes
        Move (CS_BooleanYes = sYes)                          to CertificateParams.bVerbose

        Send ValidateFile of ghoDigitalSoftwareCertificate CertificateParams
    End_Procedure

    On_Key Key_Alt+Key_O  Send Prompt                         of (phoMainPromptObject(ghoApplication))
    On_Key Key_Ctrl+Key_O Send KeyAction                      of oSelectManifest_btn
    On_Key Key_Alt+Key_E  Send EditAppManifestFile            of ghoManifestFunctionLibrary
    On_Key Key_Alt+Key_B  Send DoPreBuildManifestFile
    On_Key Key_Ctrl+Key_P Send DoPreCopyCOMComponents
    On_Key Key_Ctrl+Key_E Send EmbedManifestInProgram         of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_R Send DoPreRunProgram
    On_Key Key_Ctrl+Key_L Send OpenFragmentFolder             of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_D Send OpenProgramsFolder             of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_B Send OpenCommonCOMFolder            of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_Z Send CompressExeFile                of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_G Send SignFileDigitally              of ghoManifestFunctionLibrary
    On_Key Key_Ctrl+Key_Y Send ValidateDigitalCertificate
    On_Key Key_Alt+Key_D  Send DownloadManifestFragmentFiles  of ghoManifestFunctionLibrary
    On_Key Key_Alt+Key_R  Send Popup                          of (oCreateManifestFragmentFile(Client_Id(ghoCommandBars)))
    On_Key Key_Alt+Key_S  Send DoShareManifestFragmentFiles   of ghoApplication
    On_Key Key_Alt+Key_L  Send RegisterOrUnregister           of ghoManifestFunctionLibrary
    On_Key Key_Alt+Key_F  Send Popup                          of (oProgramSetup_Panel(Client_Id(ghoCommandBars)))

    On_Key Key_Ctrl+Key_S Send Request_Save
    On_Key kCancel        Send None
    On_Key kClear         Send Clear_All
    On_Key Key_Ctrl+Key_F4 Send None
    On_Key Key_F3          Send None
//    On_Key Key_F3 send None
End_Object

Procedure DoLoadDbMergerViewFromApplicationObject
    Send Activating of (phoMainPromptObject(ghoApplication))
End_Procedure
