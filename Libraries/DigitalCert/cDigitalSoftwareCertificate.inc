//
// ***** Constants & Struct Declarations for cDigitalSoftwareCertifiate.pkg *****

// Language specific text constants shown to user:
// English:
Define CS_DigitalCertificateInvalid for "The Digital Certificate for the program is invalid!\n\nThis means that the program is unsafe to run as it might be infected by viruses. The program will now be closed."
Define CS_NotDigitallySigned        for "The program has not been digitally signed. Do you still want to run the program?"
Define CS_DitigalWarningHeader      for ("Warning" + Character(33))
Define CS_DitigalStopHeader         for ("Stop" + Character(33))
//
// Swedish:
//Define CS_DigitalCertificateInvalid for "Det digitala certificatet f”r programmet „r ogiltigt!\n\nDetta inneb„r att programmet „r os„kert att k”ra eftersom det kan vara infekterat av ett virus. Programmet kommer nu att avslutas."
//Define CS_NotDigitallySigned        for "Programmet saknar ett digitalt certifikat. Vill du k”ra programmet „nd†?"
//Define CS_DitigalWarningHeader      for "Varning!"

// Other text constants:
Define CS_DoTouchExeFileExe               for "DoTouchExeFile.exe"
Define CS_ManifestExtension               for ".manifest"
Define CS_VerifyCredentials               for "verify"
Define CS_SignCredentials                 for "sign"
Define CS_TimeStampCredentials            for "timestamp"
Define CS_DefAuthVerPolicy                for "/pa"
Define CS_VerifyFileParam                 for "/a"
Define CS_SignCommonNameParam             for "/n"
Define CS_AppendSignature                 for "/as"
Define CS_VerboseParam                    for "/v"
Define CS_FileParam                       for "/f"
Define CS_TimeStampParam                  for "/t"
Define CS_TimeStampParamSHA256            for "/tr"
Define CS_DescriptionParam                for "/d"
Define CS_WebURLParam                     for "/du"
Define CS_PasswordParam                   for "/p"
Define CS_DefAuthVerPolicy                for "/pa"
Define CS_SHA256TimeServerURLSwitch       for "/tr"
Define CS_DigestAlgorithm                 for "/fd"
Define CS_DigestAlgorithmSHA256           for "/td"
Define CS_URLTimeStampDefaultSHA1    for "http://timestamp.comodoca.com"
Define CS_URLTimeStampDefaultSHA256  for "http://timestamp.comodoca.com/rfc3161"
Define CS_SHA1                            for "sha1"
Define CS_SHA256                          for "sha256"

// Text constants used by/with the signtool.exe program.
Define CS_CredentialsProgram              for "Signtool.exe"
Define CS_CredentialsPwError              for "SignTool Error: The specified PFX password is not correct."
Define CS_Capicom20NotInstalled           for "Error: Store IsDiskFile() failed."
Define CS_CapicomDownloadPage             for "http://www.microsoft.com/en-us/download/details.aspx?id=25281"
Define CS_NumberOfFiles                   for "number of files"
Define CS_VerifyNumbersOf                 for "number of "
Define CS_SuccessfullyVerified            for "Successfully verified"
Define CS_ProgramNotSignedText            for "No signature found."
Define CS_ProgramtamperedWith             for "The digital signature of the object did not verify"
Define CS_NoSignatureFound                for "No signature found"
Define CS_TimeStampSHA1Text               for "sha1"
Define CS_TimeStampHashText               for "hash"
Define CS_TimestampSignatureText          for "the signature is timestamped:"
Define CS_FileMustBeSigned                for "the file must be signed before it can"
Define CS_CertificateVerified             for "verified"
Define CS_BeTimestamped                   for "be timestamped"
Define CS_SignatureIsTimeStamped          for "the signature is timestamped:"
Define CS_TimeStampVerifiedBy             for "timestamp verified by:"

#IFNDEF CI_SimpleNullMember
    Define CI_SimpleNullMember for 0
#ENDIF

#IFNDEF CI_Generic_Read
    Define CI_Generic_Read for            |CI$80000000
#ENDIF
#IFNDEF CI_Generic_Write
    Define CI_Generic_Write for           |CI$40000000
#ENDIF
#IFNDEF CI_Generic_Random
    Define CI_Generic_Random for          (CI_Generic_Read + CI_Generic_Write)
#ENDIF
#IFNDEF CI_Open_Existing
    Define CI_Open_Existing for           |CI$00000003
#ENDIF
#IFNDEF CI_Open_Always
    Define CI_Open_Always for             |CI$00000004
#ENDIF
#IFNDEF CI_File_Attribute_Normal
    Define CI_File_Attribute_Normal for   |CI$00000080
#ENDIF
#IFNDEF CI_File_Share_Read
    Define CI_File_Share_Read for         |CI$1
#ENDIF
#IFNDEF CI_File_Share_Write
    Define CI_File_Share_Write for        |CI$2
#ENDIF
#IFNDEF CI_File_Share_Random
    Define CI_File_Share_Random for      (CI_File_Share_Read + CI_File_Share_Write)
#ENDIF
#IFNDEF CI_FNull
    Define CI_FNull for                   |CI$0
#ENDIF

// Structure to set parameters when calling a digital certificate action.
#IFNDEF _struct_tCertificateParams
    Struct tCertificateParams
        String sProgramPath                 // Full path to the file. Required.
        String sFileName                    // File to act upon. Required.
        Boolean bUseCertificateStore
        // Optional parameters:
        Boolean bVerbose                    // Show verbose info (more info) of the result.
        Boolean bUseTimeStamp               // Time-stamp file Yes/No.
        String sURLTimeStamp                // An http address to a timestamp service. Default = CS_URLTimeStampDefaultSHA1
        String sSHA256URLTimeStamp          // An http address to a SHA256 timestamp service.
        String sOurWebSite                  // A website address - "http://www.mywebsite.com"
        String sDescription                 // A descriptive string, could be your company name.
    End_Struct
#ENDIF

// Optional struct for specifying credentials when signing a file.
// If no struct or a "blank" struct is passed to the SignFile procedure,
// the best digital certificate on the machine will automatically be selected.
// The parameters in this struct needs to be specified if a specific digital certificate
// should be used when signing.
#IFNDEF _struct_tCertificateCredentials
    Struct tCertificateCredentials
        String sCredentialsPath             // The path to a digital certificate file (.pfx file).
        String sCredentialsFile             // The name of the digital certificate file (.pfx file).
        String sCredentialsPw               // Password for the credential file
        UChar[] aPFXData
    End_Struct
#ENDIF

// Struct used when returning the result of a digital certificate action.
#IFNDEF _struct_tCertificateResult
    Struct tCertificateResult
        Integer iRetval
        String  sText
    End_Struct
#ENDIF

// Actions that can be performed with a digital certificate
#IFNDEF CI_ActionSignFile
    Enum_List
        Define CI_ActionSignFile
        Define CI_ActionVerifyFile
        Define CI_ActionTimeStampFile
        Define CI_ActionTimeStampFileInfo
    End_Enum_List
#ENDIF

// Error return codes from the DigitalCertificateAction sub-function.
#IFNDEF CI_SignToolMissing
    Enum_List
        Define CI_SignToolMissing          for -1
        Define CI_SignFileMissing          for 2
        Define CI_PassedFileNameMissing    for 3 
        Define CI_SignFileError            for 4 
        Define CI_VerifyFileError          for 5 
        Define CI_SignDataMissing          for 6
        Define CI_CertForCodeSigningError  for 7
    End_Enum_List
#ENDIF

// Structure to store the WinAPI file time.
Struct tWinFileTimeDC
   Integer dwLowDateTime
   Integer dwHighDateTime
   Integer iError
End_Struct

// Structure to store the systemtime
#IFNDEF _struct_tSystemTime
    Struct tSystemTime
       UShort wYear
       UShort wMonth
       UShort wDayOfWeek
       UShort wDay
       UShort wHour
       UShort wMinute
       UShort wSecond
       UShort wMilliseconds
    End_Struct
#ENDIF

// ***** EXTERNAL FUNCTION DECLARATIONS *****
//
#IFNDEF get_fGetFileTime
    External_Function fGetFileTime "GetFileTime" Kernel32.dll;
        Pointer lpFileName Pointer lpFileCreationTime Pointer lpFileAccessTime Pointer lpFileWriteTime Returns Integer
#ENDIF

#IFNDEF get_fSetFileTime
    External_Function fSetFileTime "SetFileTime" Kernel32.dll;
        Pointer lpFileName Pointer lpFileCreationTime Pointer lpFileAccessTime Pointer lpFileWriteTime Returns Integer
#ENDIF

#IFNDEF get_fCloseHandle
    External_Function fCloseHandle "CloseHandle" kernel32.dll ;
        Handle hObject ;      // Handle to object
        Returns Integer
#ENDIF

#IFNDEF get_fCreatefile
    External_Function fCreatefile "CreateFileA" kernel32.dll ;
        Pointer lpFile ;      // Filename
        DWord dwDesAccess ;   // access mode
        DWord dwShare ;       // share mode
        Pointer lpSecAtt ;    // SD
        DWord dwCrDisp ;      // how to create
        DWord dwFlags ;       // file attributes
        Handle hTempFile ;    // handle to template fil
        Returns Integer       // Returns handle that can be used to access the object
#ENDIF

#IFNDEF get_FileTimeToSystemTime
    External_Function FileTimeToSystemTime "FileTimeToSystemTime" Kernel32.Dll ;
        Pointer lpFileTime ;     // Pointer to file time to convert
        Pointer lpSystemTime ;   // Pointer to structure to receive system time
        Returns Integer
#ENDIF

#IFNDEF get_FileTimeToLocalFileTime
    External_Function FileTimeToLocalFileTime "FileTimeToLocalFileTime" Kernel32.Dll ;
        Pointer lpFileTime Pointer lpSystemTime Returns Integer
#ENDIF

#IFNDEF get_GetTimeFormat
    External_Function GetTimeFormat "GetTimeFormatA" Kernel32.Dll ;
        DWord LCID DWord dwFlags Pointer lpsSystemTime Pointer lpFormat Pointer lpTimeStr Integer cchTime Returns Integer
#ENDIF

#IFNDEF get_GetDateFormat
    External_Function GetDateFormat "GetDateFormatA" Kernel32.Dll ;
        DWord LCID DWord dwFlags Pointer lpsSystemTime Pointer lpFormat Pointer lpDateStr Integer cchDate Returns Integer
#ENDIF
