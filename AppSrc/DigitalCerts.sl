// DigitalCerts.sl
// DigitalCerts Lookup List

Use cRDCDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cRDCDbCJGridColumn.pkg
Use cRDCButton.pkg

Use cDigitalCertsDataDictionary.dd

Cd_Popup_Object oDigitalCerts_sl is a cRDCDbModalPanel
    Set Location to 100 50
    Set Size to 134 610
    Set Label To "DigitalCerts Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
    Set Icon to "DigitalCert.ico"
    Set Locate_Mode to SMART_LOCATE

    Object oDigitalCerts_DD is a cDigitalCertsDataDictionary
    End_Object

    Set Main_DD To oDigitalCerts_DD
    Set Server  To oDigitalCerts_DD

    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 600
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "oDigitalCerts_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oDigitalCerts_ID is a cRDCDbCJGridColumn
            Entry_Item DigitalCerts.ID
            Set piWidth to 101
            Set psCaption to "ID"
        End_Object

        Object oDigitalCerts_FileName is a cRDCDbCJGridColumn
            Entry_Item DigitalCerts.FileName
            Set piWidth to 315
            Set psCaption to "Filename"
        End_Object

        Object oDigitalCerts_Description is a cRDCDbCJGridColumn
            Entry_Item DigitalCerts.Description
            Set piWidth to 316
            Set psCaption to "Description (optional)"
        End_Object

        Object oDigitalCerts_WebLocation is a cRDCDbCJGridColumn
            Entry_Item DigitalCerts.WebLocation
            Set piWidth to 210
            Set psCaption to "Web Location (optional)"
        End_Object

        Object oDigitalCerts_DefaultDigitalCert is a cRDCDbCJGridColumn
            Entry_Item DigitalCerts.DefaultDigitalCert
            Set piWidth to 139
            Set psCaption to "Default Certificate"
            Set pbCheckbox to True
        End_Object

        Object oDigitalCerts_AddTimeStamp is a cRDCDbCJGridColumn
            Entry_Item DigitalCerts.AddTimeStamp
            Set piWidth to 119
            Set psCaption to "Add Timestamp"
            Set pbCheckbox to True
        End_Object


    End_Object

    Object oOk_bn is a cRDCButton
        Set Label to "&Ok"
        Set Location to 115 447
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a cRDCButton
        Set Label to "&Cancel"
        Set Status_Help to "Close Panel"
        Set Location to 115 501
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a cRDCButton
        Set Label to "&Search..."
        Set Status_Help to "Show search panel..."
        Set Location to 115 555
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn
Cd_End_Object
