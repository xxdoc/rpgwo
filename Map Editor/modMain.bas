Attribute VB_Name = "modMain"
Global MapLoaded As Boolean
Global MapName As String
Global MapNotes As String
Global MapSaved As Boolean
Global SelectedTool As String
Global SelectedItem As Integer
Global SelectedMonster As Integer
Global SelectedFlat As Integer
Global RefreshMini As Boolean
Global WaterOn As Boolean
Global ElevationOn As Boolean

Public Type MapData
    TileX As Integer
    TileY As Integer
    TileType As Integer
    ImageNumber As Integer
    ImageFile As Integer
End Type
Public Type ItemData
    TileX As Integer
    TileY As Integer
    TileType As String  'Is now class
    ImageNumber As Integer
    ItemId As Integer
    ImageFile As Integer
    Data1 As Integer
    Data2 As Integer
    Data3 As Integer
    Data4 As Integer
    Data5 As Integer
    Data6 As Integer  ''Item Reset
    Data7 As Integer ''Item Trigger
    ItemText As String
    ItemSpawn As Byte
    ItemTimeOut As Integer
End Type
Public Type MonsterData
    TileX As Integer
    TileY As Integer
    ImageNumber As Integer
    MonsterId As Integer
    ImageFile As Integer
    SpawnSeconds As Integer
    ImageType As Integer
End Type
Global viewXpos As Integer
Global viewYpos As Integer
Global RangeX As Integer
Global RangeY As Integer
Public MapRange() As MapData
Public ItemMapRange() As ItemData
Public MonsterMapRange() As MonsterData
Public Map() As MapData 'Stores map info
Public ItemMap() As ItemData
Public MonsterMap() As MonsterData
'API to Blit a picture to the screen
Public Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long
Public Const SRCAND = &H8800C6
Public Const SRCCOPY = &HCC0020
Public Const SRCPAINT = &HEE0086


Public Type BITMAPINFOHEADER
    biSize As Long
    biWidth As Long
    biHeight As Long
    biPlanes As Integer
    biBitCount As Integer
    biCompression As Long
    biSizeImage As Long
    biXPelsPerMeter As Long
    biYPelsPerMeter As Long
    biClrUsed As Long
    biClrImportant As Long
End Type

Public Type RGBQUAD
    rgbBlue As Byte
    rgbGreen As Byte
    rgbRed As Byte
    rgbReserved As Byte
End Type

Public Type BITMAPINFO
    bmiHeader As BITMAPINFOHEADER
    bmiColors As RGBQUAD
End Type

Private Type WaterBox
    TileX As Integer
    TileY As Integer
    ImageFile As Integer
    ImageNumber As Integer

End Type
Private Type WaterListType
    Image As Integer
   
End Type
Global WaterList() As WaterListType
Global WaterSelect() As WaterBox

'Public Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long
Public Declare Function GetDIBits Lib "gdi32" (ByVal aHDC As Long, ByVal hBitmap As Long, ByVal nStartScan As Long, ByVal nNumScans As Long, lpBits As Any, lpBI As BITMAPINFO, ByVal wUsage As Long) As Long
Public Declare Function GetObject Lib "gdi32" Alias "GetObjectA" (ByVal hObject As Long, ByVal nCount As Long, lpObject As Any) As Long
Public Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hdc As Long) As Long
Public Declare Function CreateCompatibleBitmap Lib "gdi32" (ByVal hdc As Long, ByVal nWidth As Long, ByVal nHeight As Long) As Long
Public Declare Function DeleteDC Lib "gdi32" (ByVal hdc As Long) As Long
Public Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Public Declare Function SetDIBits Lib "gdi32" (ByVal hdc As Long, ByVal hBitmap As Long, ByVal nStartScan As Long, ByVal nNumScans As Long, lpBits As Any, lpBI As BITMAPINFO, ByVal wUsage As Long) As Long
Public Declare Function SetDIBitsToDevice Lib "gdi32" (ByVal hdc As Long, ByVal x As Long, ByVal y As Long, ByVal dx As Long, ByVal dy As Long, ByVal SrcX As Long, ByVal SrcY As Long, ByVal Scan As Long, ByVal NumScans As Long, Bits As Any, BitsInfo As BITMAPINFO, ByVal wUsage As Long) As Long
Public Declare Function SelectObject Lib "gdi32" (ByVal hdc As Long, ByVal hObject As Long) As Long

Public Sub RedrawMap()
If MapLoaded = False Then Exit Sub
frmMain.pbxView.Cls
   For y = viewYpos To viewYpos + frmMain.pbxView.ScaleHeight \ 32
   For x = viewXpos To viewXpos + frmMain.pbxView.ScaleWidth \ 32
    BitBlt frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.Picture1.hdc, 0, 0, SRCCOPY
    Next x
Next y

'For y = viewYpos To viewYpos + 13
   ' For x = viewXpos To viewXpos + 15
   For y = viewYpos To viewYpos + frmMain.pbxView.ScaleHeight \ 32
   For x = viewXpos To viewXpos + frmMain.pbxView.ScaleWidth \ 32
   ' BitBlt frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.Picture1.hdc, 0, 0, SRCCOPY
    ' frmMain.pbxView.ForeColor = vbRed
    ' frmMain.pbxView.Line (Snap2(y, 32), y)-(Snap2(y, 32), frmMain.pbxView.Height)
     'frmMain.pbxView.Line (y, Snap2(x, 32))-(frmMain.pbxView.Width, Snap2(x, 32))
    If x > UBound(Map) Or y > UBound(Map) Then Exit For
  
    If x < LBound(Map) Or y < LBound(Map) Then

    Else
   
    'Draw Surface
    If frmMain.mnuViewSurface.Checked = True Then
        BitBlt frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.pbxGround(Map(x, y).ImageFile).hdc, Map(x, y).TileX, Map(x, y).TileY, SRCCOPY
        
        If Map(x, y).ImageNumber <> 0 And frmMain.mnuViewSurfaceType.Checked = True Then
            frmMain.pbxView.ForeColor = vbWhite
            frmMain.pbxView.CurrentX = Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "f"
        End If
    End If
    If ItemMap(x, y).ItemId <> 0 And frmMain.mnuViewItem.Checked = True Then

    'Draw Items
    Call TransBMP(frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.pbxItem(ItemMap(x, y).ImageFile).hdc, ItemMap(x, y).TileX, ItemMap(x, y).TileY, vbWhite)
        If ItemMap(x, y).ItemSpawn = 1 And frmMain.mnuViewItemType.Checked = True Then
            frmMain.pbxView.ForeColor = vbYellow
            frmMain.pbxView.CurrentX = Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "S"
        End If
        If frmMain.mnuViewItemType.Checked = True And ItemMap(x, y).Data1 <> 0 Or ItemMap(x, y).Data2 <> 0 Or ItemMap(x, y).Data3 <> 0 Or ItemMap(x, y).Data4 <> 0 Or ItemMap(x, y).Data4 <> 0 Then
            frmMain.pbxView.ForeColor = vbBlue
            frmMain.pbxView.CurrentX = 16 + Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "D"
        End If
        If frmMain.mnuViewItemType.Checked = True And ItemMap(x, y).Data7 <> 0 Then
            frmMain.pbxView.ForeColor = &HC0&
            frmMain.pbxView.CurrentX = Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = 16 + Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "T"
        End If
    End If

    
    If MonsterMap(x, y).ImageNumber <> 0 And frmMain.mnuViewMonster.Checked = True Then
        Call TransBMP(frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.pbxMonster(MonsterMap(x, y).ImageFile).hdc, MonsterMap(x, y).TileX, MonsterMap(x, y).TileY, vbWhite)

    End If
          
    
    End If
    
   Next
Next

Call frmMain.RedrawMiniMap

End Sub
Public Function Snap(Cordinate As Variant, Dimension As Integer) As Integer
Snap = (Cordinate \ Dimension) * Dimension 'Small algorithm that snaps to grid sort of
End Function

Public Function Snap2(Cordinate As Variant, Dimension As Integer) As Integer
Snap2 = (Cordinate * Dimension) 'Small algorithm that takes a number and converts it into a pixel cord.
End Function
Public Function TransBMP(ByVal DstDC As Long, ByVal DstX As Long, ByVal DstY As Long, ByVal DstW As Long, ByVal DstH As Long, ByVal SrcDC As Long, ByVal SrcX As Long, ByVal SrcY As Long, ByVal TransColor As Long) As Long
    ' create transparent bitmap
    If DstW = 0 Or DstH = 0 Then Exit Function
    
    Dim B As Long, h As Long, F As Long, i As Long
    Dim TmpDC As Long, tmpBMP As Long, TmpObj As Long
    Dim Sr2DC As Long, Sr2Bmp As Long, Sr2Obj As Long
    Dim Data1() As Long, Data2() As Long
    Dim Info As BITMAPINFO
    
    TmpDC = CreateCompatibleDC(SrcDC)
    Sr2DC = CreateCompatibleDC(SrcDC)
    tmpBMP = CreateCompatibleBitmap(DstDC, DstW, DstH)
    Sr2Bmp = CreateCompatibleBitmap(DstDC, DstW, DstH)
    TmpObj = SelectObject(TmpDC, tmpBMP)
    Sr2Obj = SelectObject(Sr2DC, Sr2Bmp)
    ReDim Data1(DstW * DstH * 4 - 1)
    ReDim Data2(DstW * DstH * 4 - 1)
    Info.bmiHeader.biSize = Len(Info.bmiHeader)
    Info.bmiHeader.biWidth = DstW
    Info.bmiHeader.biHeight = DstH
    Info.bmiHeader.biPlanes = 1
    Info.bmiHeader.biBitCount = 32
    Info.bmiHeader.biCompression = 0

    Call BitBlt(TmpDC, 0, 0, DstW, DstH, DstDC, DstX, DstY, vbSrcCopy)
    Call BitBlt(Sr2DC, 0, 0, DstW, DstH, SrcDC, SrcX, SrcY, vbSrcCopy)
    Call GetDIBits(TmpDC, tmpBMP, 0, DstH, Data1(0), Info, 0)
    Call GetDIBits(Sr2DC, Sr2Bmp, 0, DstH, Data2(0), Info, 0)
    
    For h = 0 To DstH - 1
        F = h * DstW
        For B = 0 To DstW - 1
            i = F + B
            If (Data2(i) And &HFFFFFF) = TransColor Then
            Else
                Data1(i) = Data2(i)
            End If
        Next B
    Next h

    Call SetDIBitsToDevice(DstDC, DstX, DstY, DstW, DstH, 0, 0, 0, DstH, Data1(0), Info, 0)

    Erase Data1
    Erase Data2
    Call DeleteObject(SelectObject(TmpDC, TmpObj))
    Call DeleteObject(SelectObject(Sr2DC, Sr2Obj))
    Call DeleteDC(TmpDC)
    Call DeleteDC(Sr2DC)
End Function

Public Sub RedrawMapTileXY(x As Integer, y As Integer)


        
    If x > UBound(Map) Or y > UBound(Map) Then
    Else
    
    If x < LBound(Map) Or y < LBound(Map) Then
    Else
   
    'Draw Surface
    If frmMain.mnuViewSurface.Checked = True Then
        BitBlt frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.pbxGround(Map(x, y).ImageFile).hdc, Map(x, y).TileX, Map(x, y).TileY, SRCCOPY
        If Map(x, y).ImageNumber <> 0 And frmMain.mnuViewSurfaceType.Checked = True Then
            frmMain.pbxView.ForeColor = vbWhite
            frmMain.pbxView.CurrentX = Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "f"
        End If
    End If
    If ItemMap(x, y).ItemId <> 0 And frmMain.mnuViewItem.Checked = True Then

    'Draw Items
    Call TransBMP(frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.pbxItem(ItemMap(x, y).ImageFile).hdc, ItemMap(x, y).TileX, ItemMap(x, y).TileY, vbWhite)
        If ItemMap(x, y).ItemSpawn = 1 And frmMain.mnuViewItemType.Checked = True Then
            frmMain.pbxView.ForeColor = vbYellow
            frmMain.pbxView.CurrentX = Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "S"
        End If
        If frmMain.mnuViewItemType.Checked = True And ItemMap(x, y).Data1 <> 0 Or ItemMap(x, y).Data2 <> 0 Or ItemMap(x, y).Data3 <> 0 Or ItemMap(x, y).Data4 <> 0 Or ItemMap(x, y).Data4 <> 0 Then
            frmMain.pbxView.ForeColor = vbBlue
            frmMain.pbxView.CurrentX = 16 + Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "D"
        End If
        If frmMain.mnuViewItemType.Checked = True And ItemMap(x, y).Data7 <> 0 Then
            frmMain.pbxView.ForeColor = &HC0&
            frmMain.pbxView.CurrentX = Snap2(x, 32) - Snap2(viewXpos, 32)
            frmMain.pbxView.CurrentY = 16 + Snap2(y, 32) - Snap2(viewYpos, 32)
            frmMain.pbxView.Print "T"
        End If
    End If

    
    If MonsterMap(x, y).ImageNumber <> 0 And frmMain.mnuViewMonster.Checked = True Then
        Call TransBMP(frmMain.pbxView.hdc, Snap2(x, 32) - Snap2(viewXpos, 32), Snap2(y, 32) - Snap2(viewYpos, 32), 32, 32, frmMain.pbxMonster(MonsterMap(x, y).ImageFile).hdc, MonsterMap(x, y).TileX, MonsterMap(x, y).TileY, vbWhite)

    End If
          
    
    End If

End If

End Sub
