// C:\Projects\DF18\ManifestSideBySide\AppSrc\DigitalCerts.dg
// DigitalCerts
//
Use Dfclient.pkg
Use DFEntry.pkg
Use DFEnChk.pkg
Use cCJStandardCommandBarSystem.pkg
Use cCJCommandBarSystem.pkg
Use cRDCIniFileCheckbox.pkg
Use cRDCDbForm.pkg
Use cRDCButton.pkg
Use oDEOEditContextMenu.pkg               
Use vWin32fh.pkg
Use cDigitalCertsDataDictionary.dd

Procedure Activate_oDigitalCerts
    Register_Object oDigitalCerts_dg
    Send Popup of oDigitalCerts_dg
End_Procedure

// NOTE: We cannot use the cRDCDbModal panel class here
// as it alreay is using a cCJCommandbarSystem!
Activate_View Activate_oDigitalCerts_vw for oDigitalCerts_vw
Object oDigitalCerts_vw is a dbView
    Set Location to 5 6
    Set Size to 209 372
    Set Label to "Edit Digital Certificates"
    Set Auto_Clear_DEO_State to False
//    Set Icon to "DigitalCert.ico"
    Set pbAutoActivate to True

    Object oDigitalCerts_DD is a cDigitalCertsDataDictionary
    End_Object

    Set Main_DD To oDigitalCerts_DD
    Set Server  To oDigitalCerts_DD

//    Object oLocalCJCommandBarSystem is a cCJCommandBarSystem
//        Set pbSyncFloatingToolbars to False
//        Set Skip_state to True
//
//        Procedure OnCreateCommandBars
//            Handle hoOptions
//
//            Forward Send OnCreateCommandBars
//            Get OptionsObject to hoOptions
//            Send ComSetIconSize of hoOptions False 24 24  // Set icon size for Toolbar buttons.
//        End_Procedure
//
//        Object oFind_ToolBar is a cCJToolbar
//            Set psTitle to "Finding Toolbar"
//            Set piBarID to 1
//            Set pbEnableDocking to False
//            Set pbCloseable to False
//            Set pbCustomizable to False
//            Set pbHideWrap to False
//
//            Object oFindFirstTool is a cCJFindFirstMenuItem
//            End_Object
//
//            Object oFindPreviousTool is a cCJFindPreviousMenuItem
//            End_Object
//
//            Object oFindMenuTool is a cCJFindMenuItem
//            End_Object
//
//            Object oFindNextTool is a cCJFindNextMenuItem
//            End_Object
//
//            Object oFindLastTool is a cCJFindLastMenuItem
//            End_Object
//
//        End_Object
//
//        Object oFile_ToolBar is a cCJToolbar
//            Set psTitle to "Data Entry Toolbar"
//            Set piBarID to 2
//            Set pbEnableDocking to False
//            Set pbCloseable to False
//            Set pbCustomizable to False
//            Set pbHideWrap to True
//
//            Object oSaveToolItem is a cCJSaveMenuItem
//                Set psCaption to "Save"
//                Set psToolTip to "Save (Ctrl+S or F2)"
//                Set psDescription to "Save changes"
//            End_Object
//
//            Object oClearToolItem is a cCJClearMenuItem
//                Set psCaption to "Clear"
//                Set psToolTip to "Clear (F5)"
//                Set psDescription to "Clear data"
//            End_Object
//
//            Object oDeleteToolItem is a cCJDeleteMenuItem
//                Set psCaption to "Delete"
//                Set psToolTip to "Delete (Shift+F2)"
//            End_Object
//
//        End_Object
//
//    End_Object

    Object oDigitalCertsID_fm is a cRDCDbForm
        Entry_Item DigitalCerts.ID
        Set Size to 13 54
        Set Location to 15 108
        Set Label to "ID"
        On_Key kCancel Send Close_Panel
    End_Object

    Object oDigitalCerts_DefaultDigitalCert_cb is a dbCheckBox
        Entry_Item DigitalCerts.DefaultDigitalCert
        Set Location to 31 108
        Set Size to 10 60
        Set Label to "This is the default Digital Certificate"
    End_Object

    Object oDigitalCertsFileName_fm is a cRDCDbForm
        Entry_Item DigitalCerts.FileName
        Set Size to 13 250
        Set Location to 42 108
        Set peAnchors to anTopLeftRight
        Set Label to "Software Credential File"
        Set Label to "Software Credentials File"
        Set psToolTip to "Select the Software Publishing Credential File to be used to digitally sign your exe programs. Note: The credential file MUST be a .pfx file. Click the 'Browse' button or press (F4)."
        Set Floating_Menu_Object to oDEOEditContextMenu

        Procedure Prompt
            String sTitle sCurrentValue sValue sFileMask

            Move "Please select a *.pfx file" to sTitle
            Move "Software Credentials Files (*.pfx)|*.pfx" to sFileMask

            Get Value to sCurrentValue
            Get ParseFolderName sCurrentValue to sCurrentValue

            Get vSelect_File sFileMask sTitle sCurrentValue to sValue
            If (sValue <> "") Begin
                Set Changed_Value 0 to sValue
            End
        End_Procedure

        On_Key kCancel Send Close_Panel
    End_Object

    Object oDigitalCertsPw_fm is a cRDCDbForm
        Entry_Item DigitalCerts.Pw
        Set Size to 13 186
        Set Location to 57 108
        Set peAnchors to anTopLeftRight
        Set Label to "Password"
        Set Prompt_Button_Mode to PB_PromptOff
        Set Password_State to True
        Set Floating_Menu_Object to oDEOEditContextMenu
    End_Object

    Object oDigitallySigningInfo_tb is a TextBox
        Set Auto_Size_State to False
        Set Size to 16 248
        Set Location to 81 108
        Set Label to "You can add a description of the data you are signing and a Web location containing a description."
        Set Justification_Mode to JMode_Left
    End_Object

    Object oDigitalCertsDescription_fm is a cRDCDbForm
        Entry_Item DigitalCerts.Description
        Set Size to 13 250
        Set Location to 99 108
        Set peAnchors to anTopLeftRight
        Set Label to "Description (optional)"
        Set Prompt_Button_Mode to PB_PromptOff
        Set Floating_Menu_Object to oDEOEditContextMenu
    End_Object

    Object oDigitalCertsWebLocation_fm is a cRDCDbForm
        Entry_Item DigitalCerts.WebLocation
        Set Size to 13 250
        Set Location to 114 108
        Set peAnchors to anTopLeftRight
        Set Label to "Web Location (optional)"
        Set Prompt_Button_Mode to PB_PromptOff
        Set Floating_Menu_Object to oDEOEditContextMenu
    End_Object

    Object oDigitalCertsAddTimeStamp_cb is a dbCheckBox
        Entry_Item DigitalCerts.AddTimeStamp
        Set Size to 13 72
        Set Location to 139 108
        Set peAnchors to anTopLeftRight
        Set Label to "Add a Timestamp"
        Set psToolTip to ("It is STRONGLY advised to add a timestamp. In many cases, an expired certificate means that the signature validation will fail and a trust warning will appear." * ;
                          "Time-stamping was designed to alleviate this problem. The idea is that at the time, at which the code is signed," * ;
                          "the certificate was confirmed to be valid and, therefore, the signature is valid. This is much the same as a handwritten signature." * ;
                          "The main benefit is that it extends code trust beyond the validity period of the certificate. The code stays good as" * ;
                          "long as you can run it. Also, down the road the certificate may be revoked and the code will still be trusted.")
        Procedure OnChange
            Boolean bChecked
            Forward Send OnChange
            Get Checked_State to bChecked
            Set Enabled_State of oDigitalCertsTimeStampServiceSHA1_fm   to (bChecked = True)
            Set Enabled_State of oDigitalCertsTimeStampServiceSHA256_fm to (bChecked = True)
        End_Procedure
    End_Object

    Object oDigitalCertsTimeStampServiceSHA1_fm is a cRDCDbForm
        Entry_Item DigitalCerts.TimeStampServiceSHA1
        Set Size to 13 250
        Set Location to 152 108
        Set peAnchors to anTopLeftRight
        Set Label to "Timestamp service for SHA1"
        Set Floating_Menu_Object to oDEOEditContextMenu
    End_Object

    Object oDigitalCertsTimeStampServiceSHA256_fm is a cRDCDbForm
        Entry_Item DigitalCerts.TimeStampServiceSHA256
        Set Size to 13 250
        Set Location to 167 108
        Set peAnchors to anTopLeftRight
        Set Label to "Timestamp service for SHA256"
        Set Floating_Menu_Object to oDEOEditContextMenu
    End_Object

    Object oExportCertificateHelp_btn is a cRDCButton
        Set Location to 186 308
        Set Label to "Help"
        Set Status_Help to "Certificate Export Help. Explains how to export your digital software certificate to a .pfx file."
        Set psImage to "ActionHelp.ico"
        Set peAnchors to anBottomRight
        
        Procedure OnClick
            Send vShellExecute "open" CS_ExportCertificateHelp "" ""
        End_Procedure
    End_Object

    Object oSave_btn is a cRDCButton
        Set Location to 186 253
        Set Label to "Save"
        Set Status_Help to "Save changes."
        Set peAnchors to anBottomRight
        Set pbAutoEnable to True 
        Set psImage to "ActionSaveRecord.ico"

        Procedure OnClick
            Boolean bShouldSavePre bShouldSaveAft bCheckBoxChange

            Get Changed_State of oUseCertificateStore_cb to bCheckBoxChange
            If (bCheckBoxChange = True) Begin
                Send WriteIniValue of oUseCertificateStore_cb
                Set Changed_State of oUseCertificateStore_cb to False
            End
            Get Should_Save of (Main_DD(Self)) to bShouldSavePre
            Send Request_Save_No_Clear
            Get Should_Save of (Main_DD(Self)) to bShouldSaveAft
            If ((bShouldSavePre = True and bShouldSaveAft = False) or bCheckBoxChange= True) Begin
                Send Info_Box "Changes saved."
            End
            Else Begin
                Send Info_Box "Nothing had changed and nothing to save"
            End
        End_Procedure   
        
        Function IsEnabled Returns Boolean
            Boolean bState 
            Get Should_Save of oDigitalCerts_DD to bState
            Function_Return (bState = True)
        End_Function

    End_Object
//
//    Object oClose_btn is a cRDCButton
//        Set Location to 192 308
//        Set Label to "Close"
//        Set peAnchors to anBottomRight
//        Set Status_Help to "Close panel"
//
//        Procedure OnClick
//            Send Close_Panel
//        End_Procedure
//
//    End_Object

    Object oUseCertificateStore_cb is a cRDCIniFileCheckbox
        Set Size to 12 97
        Set Location to 18 183
        Set Label to "Auto-select from Windows Certificate Store"
        Set peAnchors to anTopRight
        Set psKey to CS_UseCertificateStore
        Set psToolTip to "Automatically selects the best suited certificate from Windows Certificate Store on the machine. This overrules any digital certificate file selection."

        Procedure OnChange
            Boolean bChecked
            Get Checked_State to bChecked
            Set Enabled_State of oDigitalCertsFileName_fm            to (bChecked = False)
            Set Enabled_State of oDigitalCertsPw_fm                  to (bChecked = False)
            Set Enabled_State of oDigitalCerts_DefaultDigitalCert_cb to (bChecked = False)
        End_Procedure
    End_Object

    Procedure Activating
        Send FindFirstDefaultCertificate of oDigitalCerts_DD
    End_Procedure

//    Procedure Page Integer iPageObject
//        Set Icon to "DigitalCert.ico"
//        Forward Send Page iPageObject
//    End_Procedure

End_Object
