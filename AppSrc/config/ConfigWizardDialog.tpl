Use cConfigureWizard.pkg
Use cRDCButton.pkg

Object oSetupNew is a cConfigureDbModalPanel
    Set Icon to "Settings.ico"

    Object oConfigureLeftHeader_tb is a cConfigureSmall_tb
        Set Size to 11 77
        Set Location to 7 5
        Set Label to "Program Settings"
        Set FontWeight to fw_Bold
    End_Object  

    Object oRigthHandImage is a cConfigureRightImage
    End_Object

    Object oConfigureRightHeader_tb is a cConfigureRightHeader_tb
        Set Label to "Right Header Text"
    End_Object
    
    Object oRightTop_grp is a Container3d
        Set Size to 144 280
        Set Location to 20 125
        Set Border_Style to Border_Normal
        Set peAnchors to anAll

            Object oScrollingContainerRight is a cScrollingContainer
                
                Object oScrollingClientAreaRight is a cScrollingClientArea
//                    Set pbAutoScrollFocus to False
                    
                    Object oConfigureRigthWizardPane is a cConfigureRightSidePane  
                        
                        Object o1_tp is a cConfigurePage
                            Set Location to 0 0
                            Set Label to "Page 1"

                        End_Object

                        Object o2_tp is a cConfigurePage
                            Set Location to 0 1
                            Set Label to "Page 2"
                        End_Object

                        Object o3_tp is a cConfigurePage
                            Set Label to "Page 3"

                        End_Object

                        Object o4_tp is a cConfigurePage
                            Set Label to "Page 4"

                        End_Object              

                        Object o5_tp is a cConfigurePage
                            Set Label to "Page 5"
                        End_Object

                        Object o6_tp is a cConfigurePage
                            Set Label to "Page 6"

                        End_Object

                    End_Object
                    
                End_Object
                
            End_Object

        Procedure End_Construct_Object
            Forward Send End_Construct_Object
            Set Border_Style to Border_None
        End_Procedure
        
    End_Object    

    Object oConfigureLeftSideButtons is a cConfigureLeftSideButtons
        Object oScrollingContainerLeft is a cScrollingContainer
            
            Object oScrollingClientAreaLeft is a cScrollingClientArea
                Set pbAutoScrollFocus to False
                Set piAutoScrollMarginX to 0
                Set piAutoScrollMarginY to 0  
                Set pbShowDisabledScrollBar to False

                Object o1_btn is a cConfigureButton
                    Set Location to 2 1
                    Set Label to "Button 1"
                End_Object

                Object o2_btn is a cConfigureButton
                    Set Location to 25 1
                    Set Label to "Button 2"
                End_Object

                Object o3_btn is a cConfigureButton
                    Set Location to 47 1
                    Set Label to "Button 3"
                End_Object

                Object o4_btn is a cConfigureButton
                    Set Location to 70 1
                    Set Label to "Button 4"
                End_Object

                Object o5_btn is a cConfigureButton
                    Set Location to 93 1
                    Set Label to "Button 5"
                End_Object

                Object o6_btn is a cConfigureButton
                    Set Location to 116 1
                    Set Label to "Button 6"
                End_Object
                               
            End_Object
            
        End_Object
    
    End_Object
    
    Object oLeftButtonLineControl is a LineControl
        Set Size to 171 3
        Set Location to 20 122
        Set Horizontal_State to False
        Set peAnchors to anTopBottomLeft
        Set Bottom_Line_Color to clGray
    End_Object
        
    Object oOK_Btn is a cRDCButton
        Set Size to 14 50
        Set Label    to "&OK"
        Set Location to 177 302
        Set peAnchors to anBottomRight
        Set Default_State to True

        Procedure OnClick
            String sProgram
            Boolean bRestart
            Integer iRetval

            // This will make all values to be written to the ini-file:
            Broadcast Recursive Send WriteIniValue of (phoWizardPanelHandle(Self))

            Delegate Get pbRestart to bRestart
            If (bRestart = True) Begin
                Send DoChangeToolbars of ghoCommandBars
                Get YesNo_Box "The program needs to be restarted. Restart now?" to iRetval
                If (iRetval = MBR_Yes) Begin
                    // First save skin settings
                    If (ghoSkinFramework <> 0) Begin
                        Send SaveSkinPreference of ghoSkinFramework
                    End
                    // then sizes & locations of the ghoApplication object etc.
                    // We pass the object id of the oMain object and True to actually save changes.
                    Send DoSaveEnvironment of ghoApplication (Parent(Client_Id(ghoCommandBars))) True
                    Move (Module_Name(Desktop)) to sProgram
                    // and restart the program.
                    Runprogram (sProgram + ".exe")
                End
            End

            Send Close_Panel
        End_Procedure
    End_Object  
    
    Object oCancel_Btn is a cRDCButton
        Set Size to 14 50
        Set Label    to "&Cancel"
        Set Status_Help to "Close Panel"
        Set Location to 177 358
        Set peAnchors to anBottomRight
        Procedure OnClick
            Send Close_Panel
        End_Procedure
    End_Object

    Procedure Page Integer iPageObject
        Set Icon to "Settings.ico"
        Forward Send Page iPageObject
    End_Procedure  
    
    Procedure Activating
        Forward Send Activating
        Set pbRestart to False
    End_Procedure

    Procedure Deactivating
        Forward Send Deactivating
        Set pbRestart to False
    End_Procedure

    On_Key kCancel Send Close_Panel
End_Object
