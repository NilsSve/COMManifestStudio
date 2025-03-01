Use cRDCModalPanel.pkg
Use cRDCSpinForm.pkg
Use cCJGridColumnRowIndicator.pkg
Use cManifestCheckboxCJGrid.pkg
Use cRDCCJGridColumnSuggestion.pkg
Use cRDCRichEditor.pkg
Use cManifestFunctionLibrary.pkg

Object oFragmentFiles_sl is a cRDCModalPanel
    Set Size to 282 424
    Set Label to "Manifest Fragment Library - Local Repository"
    Set Icon to "FragmentLibrary.ico"

    // We need this string array to return the selected items.
    // This is because we cannot ask the grid after the panel is closed (after popup)
    // because the grid object is by then already destroyd.
    Property String[] psFilesArray
    Property Boolean  pbOkButton False

    Object oInfo_tb is a TextBox
        Set Size to 10 166
        Set Location to 79 23
        Set Label to "Note: The list only shows items _not_ previously selected"
        Set FontItalics to True
    End_Object

    Object oFragmentFiles_Grid is a cManifestCheckboxCJGrid
        Set Location to 90 10
        Set Size to 137 349
        Set pbReadOnly to False
        Set pbAllowEdit to True
        Set pbAllowDeleteRow to False
        Set piLayoutBuild to 4

        Object oCJGridColumnRowIndicator is a cCJGridColumnRowIndicator
            Set piWidth to 24
        End_Object

        // We want this to be the first column in navigation order.
        // That way it automatically gets the focus for the user to start writing
        // which popups the suggestion list.
        Object oFileNameFirst_Col is a cRDCCJGridColumnSuggestion
            // These lines are for the Studio only.
            Set piWidth to 588
            Set psCaption to "Select Manifest Fragment files.  Right-click grid for menu options"
            Set pbDrawFooterDivider to False
            Set piFindIndex to 1

            Set piWidth to 540
            Set psCaption to "Select Manifest Fragment files. Right-click grid for menu options. Spacebar=Select"
            Set pbDrawFooterDivider to False

            // Do _not_ set this to false. It was put here to demonstrate how the property works.
            // If false the entered search value will remain in the column when escape is pressed
            // and that doesn't make any sense in this program.
            // Set pbSearchMode to False

            Delegate Set piFileNameFirstCol to (piColumnId(Self))    // cWsCheckboxCJGrid property

            Procedure OnSelectSuggestion String sSearch tSuggestion Suggestion
                String sValue
                tDataSourceRow[] MyData
                Handle hoDataSource

                Get phoDataSource to hoDataSource
                Move Suggestion.sRowId to sValue

                Get DataSource of hoDataSource to MyData
                Send RequestFindColumnValue (piColumnId(Self)) sValue False 0
                Send ReInitializeData MyData True
            End_Procedure

        End_Object

        Object oCheckbox_Col is a cCJGridColumn
            Set piWidth to 86
            Set psCaption to "Select"
            Set pbCheckbox to True
            Set peHeaderAlignment to xtpAlignmentCenter
            Set peFooterAlignment to xtpAlignmentCenter
            Delegate Set piCheckboxCol to (piColumnId(Self)) // cWsCheckboxCJGrid property
            Set psFooterText to ("Selected:" * String(0))
        End_Object

        // Change comment text of the editor object with text from the manifest fragment file
        Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
            Forward Send OnRowChanged iOldRow iNewSelectedRow

            // When changing row, update the manifest fragment file comment object
            Send DoShowFragmentComment iNewSelectedRow
        End_Procedure

        // This does the setting of the comment editor object text.
        Procedure DoShowFragmentComment Integer iNewSelectedRow
            Handle hoDataSource
            tDataSourceRow[] TheData
            String sFileName sComment
            Integer iCol

            Get piFileNameFirstCol           to iCol
            Get phoDataSource                to hoDataSource
            Get DataSource of hoDataSource   to TheData

            Move TheData[iNewSelectedRow].sValue[iCol] to sFileName
            If (sFileName contains ".txt") Begin
                Get ExtractManifestFragmentFileComment of ghoManifestFunctionLibrary sFileName to sComment
            End

            Set Value of oComment_edt to sComment
        End_Procedure

        Procedure DoFillGrid
            Integer i iFiles
            String[] sManifestLibraryArray sFilesArray
            Integer iCheckbox_Col iFileNameFirst_Col
            tFileStruct[] FilesStructArray
            Handle hoDataSource hoCol
            tDataSourceRow[] TheData

            Forward Send DoFillGrid

            Get phoDataSource                to hoDataSource
            Get DataSource of hoDataSource   to TheData
            Get piCheckboxCol                to iCheckbox_Col
            Get piFileNameFirstCol           to iFileNameFirst_Col
            Get psFilesStructArray           to FilesStructArray
            Get FileStructArrayAsStringArray of ghoManifestFunctionLibrary FilesStructArray True to sFilesArray
            Get AllManifestFragmentFiles     of ghoManifestFunctionLibrary to sManifestLibraryArray

            Get FilesArrayDifference of ghoManifestFunctionLibrary (&sFilesArray) (&sManifestLibraryArray) to sManifestLibraryArray
            Move (SizeOfArray(sManifestLibraryArray)) to iFiles
            Decrement iFiles
            For i from 0 to iFiles
                Move False                    to TheData[i].sValue[iCheckbox_Col]
                Move sManifestLibraryArray[i] to TheData[i].sValue[iFileNameFirst_Col]
            Loop

            // Initialize Grid with new data
            Send InitializeData TheData
            Send MovetoFirstRow

            Get ColumnObject iFileNameFirst_Col to hoCol
            Set psFooterText of hoCol to ("Number of available Manifest Fragment Files:" * String(iFiles + 1))
        End_Procedure

        Procedure AutoSelectCodeJockComponents Integer iMajorVersion Integer iMinorVersion
            Handle hoDataSource
            tDataSourceRow[] TheData
            String[] sFilesArray
            String sFileName
            Integer i iCheckbox_Col iFileName_Col iItems
            Boolean bFound bSelected

            Get piCheckboxCol              to iCheckbox_Col
            Get piFileNameFirstCol         to iFileName_Col
            Get phoDataSource              to hoDataSource
            Get DataSource of hoDataSource to TheData
            Move (SizeOfArray(TheData))    to iItems
            Decrement iItems
            Move False to bSelected

            For i from 0 to iItems
                Move False to bFound
                Move TheData[i].sValue[iFileName_Col] to sFileName
                Case Begin
                    Case (iMajorVersion = 25 and iMinorVersion = 0)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "24.0.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 24 and iMinorVersion = 0)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "22.0.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 23 and iMinorVersion = 0)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "22.0.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 20 and iMinorVersion = 1)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "20.0.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 20 and iMinorVersion = 0)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "20.0.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 19 and iMinorVersion = 1)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "18.3.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 19 and iMinorVersion = 0)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "17.3.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break

                    Case (iMajorVersion = 18 and iMinorVersion = 2)
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "16.4.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 18 and (iMinorVersion = 0 or iMinorVersion = 1))
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "16.3.1") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 17 and (iMinorVersion = 0 or iMinorVersion = 1))
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "15.3.1") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 16 and (iMinorVersion = 0 or iMinorVersion = 1))
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "13.4.2") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 15 and (iMinorVersion = 0 or iMinorVersion = 1))
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "13.0.0") to bFound
                        If (bFound = True) Begin
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "REPORTCONTROL" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                    Case (iMajorVersion = 14 and (iMinorVersion = 0 or iMinorVersion = 1))
                        Move (Uppercase(sFileName) contains "CODEJOCK" and sFileName contains "12.0.2") to bFound
                        If (bFound = True) Begin
                            // Note: In this DataFlex revision the CodeJock ReportControl was _not_ yet in use.
                            Move (Uppercase(sFileName) contains "COMMANDBARS" or Uppercase(sFileName) contains "SKINFRAMEWORK") to bFound
                        End
                        Case Break
                Case End

                If (bFound = True) Begin
                    Move True to TheData[i].sValue[iCheckbox_Col]
                    Move True to bSelected
                End
            Loop

            Send ReInitializeData TheData False
            Send DoSetCheckboxFooterText
            If (bSelected = True) Begin
                Send Info_Box "One or more CodeJock components were found for the selected DataFlex version. You many now press the 'OK' button to add the selections."
            End
            Else Begin
                Send Info_Box "No CodeJock components found for the selected DataFlex revision.\n\nNote: The reason no CodeJock components were found could be because they have already been seleced, or these manifest fragment files are not available from your machines local fragment file repository; in which case you need to select [Download Fragment] button from the main program toolbar, to download them first."
            End
        End_Procedure

        On_Key kEnter Send KeyAction of oOK_Btn
    End_Object

    Object oComment_edt is a cRDCRichEditor
        Set Size to 32 349
        Set Location to 240 10
        Set Read_Only_State to True
        Set psToolTip to "Read only comment. Manifest Fragment Files can contain comments that describes what the component does etcetera. Each comment row must start with two forward slashes, the same as the Visual DataFlex language uses for code comments. Note: You need to open the file in the editor (double-click the file) to make changes to it."
        Set peAnchors to anBottomLeftRight
        Set Skip_State to True
        Set Label to "Description"
    End_Object

    Object oStudioMajorVersion_sf is a cRDCSpinForm
        Set Size to 10 27
        Set Location to 64 389
        Set Maximum_Position to 30
        Set Minimum_Position to 14
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
        Set Label to "DataFlex Major Version"
        Set psToolTip to "DataFlex main version - e.g. '17'"
        Set Value to FMAC_VERSION
        Set peAnchors to anNone
    End_Object

    Object oStudioMinorVersion_sf is a cRDCSpinForm
        Set Size to 10 27
        Set Location to 76 389
        Set Label_Col_Offset to 2
        Set Label to "Minor Version"
        Set psToolTip to "DataFlex minor version - e.g. '0'"
        Set Maximum_Position to 9
        Set Minimum_Position to 0
        Set Value to FMAC_REVISION
        Set Label_Justification_Mode to JMode_Right
        Set peAnchors to anNone
    End_Object

    Object oDataFlexAutoSelect_btn is a cRDCButton
        Set Size to 21 50
        Set Location to 90 366
        Set Label to "CodeJock Auto Select"
        Set Status_Help to "Auto selects CodeJock component fragments for the selected DataFlex version."
        Set MultiLineState to True
        Set peAnchors to anTopRight

        Procedure OnClick
            Integer iRetval iMajorVersion iMinorVersion
            Get Value of oStudioMajorVersion_sf to iMajorVersion
            Get Value of oStudioMinorVersion_sf to iMinorVersion
            Send AutoSelectCodeJockComponents of oFragmentFiles_Grid iMajorVersion iMinorVersion
        End_Procedure

    End_Object

    Object oSelectAll_btn is a cRDCButton
        Set Size to 14 50
        Set Location to 145 366
        Set Status_Help to "Select All (Ctrl+A)"
        Set Label to "All"
        Set psImage to "SelectAll.ico"
        Set MultiLineState to True
        Set peAnchors to anTopRight
        Procedure OnClick
            Set SelectItems of oFragmentFiles_Grid to cx_Select_All
        End_Procedure
    End_Object

    Object oDeSelectAll_btn is a cRDCButton
        Set Size to 14 50      
        Set Label to "None"
        Set Location to 161 366
        Set Status_Help to "Select None (Ctrl+N)"
        Set psImage to "SelectNone.ico"
        Set peAnchors to anTopRight
        Procedure OnClick
            Set SelectItems of oFragmentFiles_Grid to cx_Select_None
        End_Procedure
    End_Object

    Object oInvertSelection_btn is a cRDCButton
        Set Size to 14 50
        Set Location to 177 366
        Set Label to "Invert"
        Set Status_Help to "Invert Selection (Ctrl+I)"
        Set psImage to "SelectInvert.ico"
        Set peAnchors to anTopRight
        Procedure OnClick
            Set SelectItems of oFragmentFiles_Grid to cx_Select_Invert
        End_Procedure
    End_Object

    Object oRefresh_btn is a cRDCButton
        Set Size to 14 50
        Set Location to 194 366
        Set Label to "Refresh"
        Set Status_Help to "Refresh the grid with Manifest Fragment files. Click if the Manifest Fragment Library has been updated after the program was started (F5)"
        Set psImage to "Refresh.ico"
        Set peAnchors to anTopRight
        Procedure OnClick
            Send RefreshGrid of oFragmentFiles_Grid
        End_Procedure
    End_Object

    Object oOk_Btn is a cRDCButton
        Set Label to "Ok"
        Set Location to 240 366
        Set peAnchors to anBottomRight
        Set Default_State to True
        Procedure OnClick
            Set pbOkButton to True
            Send Close_Panel
        End_Procedure
    End_Object

    Object oCancel_Btn is a cRDCButton
        Set Label to "Cancel"
        Set Status_Help to "Close Panel"
        Set Location to 258 366
        Set peAnchors to anBottomRight

        Procedure OnClick
            Set pbOkButton to False
            Send Close_Panel
        End_Procedure

    End_Object

    Object oInfo_3d is a Container3d
        Set Size to 51 406
        Set Location to 7 10
        Set peAnchors to anTopLeftRight
        Set Color to clWhite
        Set Border_Style to Border_Normal
        Set Skip_State to True

        Object oInfo_tb is a TextBox
            Set Auto_Size_State to False
            Set Size to 44 392
            Set Location to 3 7
            Set Label to "The Manifest Fragment Files column is searchable if DataFlex 18 or later is used. While typing, suggestions are shown below the grid cell in a list. If you can't find a matching manifest fragment file you can try the 'Download' toolbar button to check if it exists in the global repository at VDF-Guidance. If it doesn't exist there it needs to be created, by clicking the 'Create' toolbar button. TIP: If the list shows items of no interest to you, delete them from the workspace Manifest Fragment Library. They can always be added later by clicking the 'Download' toolbar button."
            Set Justification_Mode to JMode_Left
            Set peAnchors to anTopLeftRight
            Set Color to clWhite
        End_Object

    End_Object

    Procedure Close_Panel
        Boolean bOkButton
        String[] sFilesArray
        Get pbOkButton to bOkButton
        If (bOkButton = False) Begin
            Set SelectItems of oFragmentFiles_Grid to cx_Select_None
        End
        Get SelectedItems of oFragmentFiles_Grid True to sFilesArray
        Set psFilesArray to sFilesArray
        Forward Send Close_Panel
    End_Procedure

    Procedure Activate_Dialog tFileStruct[] FilesStructArray
        Set psFilesStructArray of oFragmentFiles_Grid to FilesStructArray
        Send Popup
    End_Procedure

    On_Key Key_Alt+Key_C Send KeyAction of oCancel_Btn
//    On_Key kCancel       Send KeyAction of oCancel_Btn
End_Object

// Public access method to this dialog
// Pass an array with the files that should appear in the grid.
// The function returns the selected files as an array.
Function ActivateFragmentFiles_sl String[] ByRef sFilesArray Returns String[]
    Integer iSize
    String[] sReturnFilesArray sManifestLibraryArray
    tFileStruct[] FilesStructArray
    Handle ho
    
    Move (oFragmentFiles_sl(Self)) to ho
    Set pbOkButton of ho to False
    Get AllManifestFragmentFiles of ghoManifestFunctionLibrary to sManifestLibraryArray
    Get FilesArrayDifference     of ghoManifestFunctionLibrary (&sFilesArray) (&sManifestLibraryArray) to sReturnFilesArray
    Move (SizeOfArray(sReturnFilesArray)) to iSize
    If (iSize = 0) Begin
        Send Info_Box "There are no more local Manifest Fragment files to select. Press the 'Download' toolbar button to check if there exist any new Manifest Fragment files in the global repository at vdf-guidance."
    End
    Else Begin
        Get StringArrayToFileStructArray of ghoManifestFunctionLibrary sFilesArray to FilesStructArray
        Send Activate_Dialog of ho FilesStructArray
        Get psFilesArray of ho to sReturnFilesArray
    End
    Function_Return sReturnFilesArray
End_Function
