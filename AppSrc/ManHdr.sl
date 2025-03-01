// ManHdr.sl
// ManHdr Lookup List
Use cRDCDbModalPanel.pkg
Use cRDCDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg   
Use cRDCButton.pkg

Use cManHdrDataDictionary.dd

Object oManHdr_sl is a cRDCDbModalPanel
    Set Size to 173 487
    Set Label to "Open an Application Manifest Project"
    Set Minimize_Icon to False
    Set Icon to "FolderOpen.ico"

    Object oManHdr_DD is a cManHdrDataDictionary
    End_Object

    Set Main_DD To oManHdr_DD
    Set Server  To oManHdr_DD

    Object oSelList is a cRDCDbCJGridPromptList
        Set Size to 139 477
        Set Location to 5 5
        Set peAnchors to anAll
        Set Ordering to 1
        Set pbAutoServer to True

//        Object oManHdr_ID is a cRDCDbCJGridColumn
//            Entry_Item ManHdr.ID
//            Set piWidth to 47
//            Set psCaption to "ID"
//        End_Object

        Object oManHdr_ManifestFileName is a cRDCDbCJGridColumn
            Entry_Item ManHdr.ManifestFileName
            Set piWidth to 196
            Set psCaption to "Program Manifest File"
        End_Object

        Object oManHdr_Path is a cRDCDbCJGridColumn
            Entry_Item ManHdr.Path
            Set piWidth to 591
            Set psCaption to "Path"
        End_Object

    End_Object

    Object oOk_bn is a cRDCButton
        Set Label to "&Ok"
        Set Location to 151 324
        Set peAnchors to anBottomRight
        Set Default_State to True

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a cRDCButton
        Set Label to "&Cancel"
        Set Status_Help to "Close Panel"
        Set Location to 151 378
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a cRDCButton
        Set Label to "&Search..."
        Set Status_Help to "Show popup search panel..."
        Set Location to 151 432
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object
