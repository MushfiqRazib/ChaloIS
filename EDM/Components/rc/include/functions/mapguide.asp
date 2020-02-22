<%
'*******************************************************************************
'***                                                                         ***
'*** File       : mapguide.asp                                               ***
'*** Author     : Edwin Poldervaart                                          ***
'*** Date       : 13-03-2006                                                 ***
'*** Copyright  : (C) 2006 HawarIT BV                                        ***
'*** Email      : info@hawarIT.com                                           ***
'***                                                                         ***
'*** Description: MapGuide Definitions and Functions                         ***
'***                                                                         ***
'*******************************************************************************

'*******************************************************************************
'*** MapGuide Objects
'*******************************************************************************
Dim gMapLayer, gThemeList


'*******************************************************************************
'*** MapGuide Color Translation Table
'*******************************************************************************
Dim MGColor(256)

MGColor(0)   = ""
MGColor(1)   = "FFFFFF"
MGColor(2)   = "C0C0C0"
MGColor(3)   = "808080"
MGColor(4)   = "000000"
MGColor(5)   = "FF0000"
MGColor(6)   = "FFFF00"
MGColor(7)   = "00FF00"
MGColor(8)   = "00FFFF"
MGColor(9)   = "0000FF"
MGColor(10)  = "FF00FF"
MGColor(11)  = "800000"
MGColor(12)  = "808000"
MGColor(13)  = "008000"
MGColor(14)  = "008080"
MGColor(15)  = "000080"
MGColor(16)  = "800080"
MGColor(17)  = "500000"
MGColor(18)  = "700000"
MGColor(19)  = "900000"
MGColor(20)  = "C00000"
MGColor(21)  = "E00000"
MGColor(22)  = "FF0000"
MGColor(23)  = "FF2020"
MGColor(24)  = "FF4040"
MGColor(25)  = "FF5050"
MGColor(26)  = "FF6060"
MGColor(27)  = "FF8080"
MGColor(28)  = "FF9090"
MGColor(29)  = "FFA0A0"
MGColor(30)  = "FFB0B0"
MGColor(31)  = "FFD0D0"
MGColor(32)  = "501400"
MGColor(33)  = "701C00"
MGColor(34)  = "902400"
MGColor(35)  = "A02800"
MGColor(36)  = "C03000"
MGColor(37)  = "E03800"
MGColor(38)  = "FF4000"
MGColor(39)  = "FF5820"
MGColor(40)  = "FF7040"
MGColor(41)  = "FF7C50"
MGColor(42)  = "FF9470"
MGColor(43)  = "FFA080"
MGColor(44)  = "FFB8A0"
MGColor(45)  = "FFC4B0"
MGColor(46)  = "FFDCD0"
MGColor(47)  = "502800"
MGColor(48)  = "603000"
MGColor(49)  = "804000"
MGColor(50)  = "A05000"
MGColor(51)  = "B05800"
MGColor(52)  = "D06800"
MGColor(53)  = "E07000"
MGColor(54)  = "FF8000"
MGColor(55)  = "FF9830"
MGColor(56)  = "FFA850"
MGColor(57)  = "FFB060"
MGColor(58)  = "FFC080"
MGColor(59)  = "FFD0A0"
MGColor(60)  = "FFD8B0"
MGColor(61)  = "FFE8D0"
MGColor(62)  = "503C00"
MGColor(63)  = "604800"
MGColor(64)  = "806000"
MGColor(65)  = "906C00"
MGColor(66)  = "A07800"
MGColor(67)  = "C09000"
MGColor(68)  = "D09C00"
MGColor(69)  = "F0B400"
MGColor(70)  = "FFC000"
MGColor(71)  = "FFD040"
MGColor(72)  = "FFD860"
MGColor(73)  = "FFDC70"
MGColor(74)  = "FFE490"
MGColor(75)  = "FFECB0"
MGColor(76)  = "FFF4D0"
MGColor(77)  = "505000"
MGColor(78)  = "606000"
MGColor(79)  = "707000"
MGColor(80)  = "909000"
MGColor(81)  = "A0A000"
MGColor(82)  = "B0B000"
MGColor(83)  = "C0C000"
MGColor(84)  = "F4F400"
MGColor(85)  = "F0F000"
MGColor(86)  = "FFFF00"
MGColor(87)  = "FFFF40"
MGColor(88)  = "FFFF70"
MGColor(89)  = "FFFF90"
MGColor(90)  = "FFFFB0"
MGColor(91)  = "FFFFD0"
MGColor(92)  = "305000"
MGColor(93)  = "3A6000"
MGColor(94)  = "4D8000"
MGColor(95)  = "569000"
MGColor(96)  = "60A000"
MGColor(97)  = "73C000"
MGColor(98)  = "7DD000"
MGColor(99)  = "90F000"
MGColor(100) = "9AFF00"
MGColor(101) = "B3FF40"
MGColor(102) = "C0FF60"
MGColor(103) = "CDFF80"
MGColor(104) = "D3FF90"
MGColor(105) = "E0FFB0"
MGColor(106) = "EDFFD0"
MGColor(107) = "005000"
MGColor(108) = "006000"
MGColor(109) = "008000"
MGColor(110) = "00A000"
MGColor(111) = "00B000"
MGColor(112) = "00D000"
MGColor(113) = "00E000"
MGColor(114) = "00FF00"
MGColor(115) = "50FF50"
MGColor(116) = "60FF60"
MGColor(117) = "70FF70"
MGColor(118) = "90FF90"
MGColor(119) = "A0FFA0"
MGColor(120) = "B0FFB0"
MGColor(121) = "D0FFD0"
MGColor(122) = "005028"
MGColor(123) = "006030"
MGColor(124) = "008040"
MGColor(125) = "00A050"
MGColor(126) = "00B058"
MGColor(127) = "00D068"
MGColor(128) = "00F470"
MGColor(129) = "00FF80"
MGColor(130) = "50FFA8"
MGColor(131) = "60FFB0"
MGColor(132) = "70FFB8"
MGColor(133) = "90FFC8"
MGColor(134) = "A0FFD0"
MGColor(135) = "B0FFD8"
MGColor(136) = "D0FFE8"
MGColor(137) = "005050"
MGColor(138) = "006060"
MGColor(139) = "008080"
MGColor(140) = "009090"
MGColor(141) = "00A0A0"
MGColor(142) = "00C0C0"
MGColor(143) = "00D0D0"
MGColor(144) = "00F0F0"
MGColor(145) = "00FFFF"
MGColor(146) = "50FFFF"
MGColor(147) = "70FFFF"
MGColor(148) = "80FFFF"
MGColor(149) = "A0FFFF"
MGColor(150) = "B0FFFF"
MGColor(151) = "D0FFFF"
MGColor(152) = "003550"
MGColor(153) = "004B70"
MGColor(154) = "006090"
MGColor(155) = "006BA0"
MGColor(156) = "0080C0"
MGColor(157) = "0095E0"
MGColor(158) = "00ABFF"
MGColor(159) = "40C0FF"
MGColor(160) = "50C5FF"
MGColor(161) = "60CBFF"
MGColor(162) = "80D5FF"
MGColor(163) = "90DBFF"
MGColor(164) = "A0E0FF"
MGColor(165) = "B0E5FF"
MGColor(166) = "D0F0FF"
MGColor(167) = "001B50"
MGColor(168) = "002570"
MGColor(169) = "001C90"
MGColor(170) = "0040C0"
MGColor(171) = "004BE0"
MGColor(172) = "0055FF"
MGColor(173) = "3075FF"
MGColor(174) = "4080FF"
MGColor(175) = "508BFF"
MGColor(176) = "70A0FF"
MGColor(177) = "80ABFF"
MGColor(178) = "90B5FF"
MGColor(179) = "A0C0FF"
MGColor(180) = "C0D5FF"
MGColor(181) = "D0E0FF"
MGColor(182) = "000050"
MGColor(183) = "000080"
MGColor(184) = "0000A0"
MGColor(185) = "0000D0"
MGColor(186) = "0000FF"
MGColor(187) = "2020FF"
MGColor(188) = "1C1CFF"
MGColor(189) = "5050FF"
MGColor(190) = "6060FF"
MGColor(191) = "7070FF"
MGColor(192) = "8080FF"
MGColor(193) = "9090FF"
MGColor(194) = "A0A0FF"
MGColor(195) = "C0C0FF"
MGColor(196) = "D0D0FF"
MGColor(197) = "280050"
MGColor(198) = "380070"
MGColor(199) = "480090"
MGColor(200) = "6000C0"
MGColor(201) = "7000E0"
MGColor(202) = "8000FF"
MGColor(203) = "9020FF"
MGColor(204) = "A040FF"
MGColor(205) = "A850FF"
MGColor(206) = "B060FF"
MGColor(207) = "C080FF"
MGColor(208) = "C890FF"
MGColor(209) = "D0A0FF"
MGColor(210) = "D8B0FF"
MGColor(211) = "E8D0FF"
MGColor(212) = "500050"
MGColor(213) = "700070"
MGColor(214) = "900090"
MGColor(215) = "A000A0"
MGColor(216) = "C000C0"
MGColor(217) = "E000E0"
MGColor(218) = "FF00FF"
MGColor(219) = "FF20FF"
MGColor(220) = "FF40FF"
MGColor(221) = "FF50FF"
MGColor(222) = "FF70FF"
MGColor(223) = "FF80FF"
MGColor(224) = "FFA0FF"
MGColor(225) = "FFB0FF"
MGColor(226) = "FFD0FF"
MGColor(227) = "500028"
MGColor(228) = "700060"
MGColor(229) = "900048"
MGColor(230) = "C00060"
MGColor(231) = "E00070"
MGColor(232) = "FF008A"
MGColor(233) = "FF2090"
MGColor(234) = "FF40A0"
MGColor(235) = "FF50A8"
MGColor(236) = "FF60B0"
MGColor(237) = "FF80C0"
MGColor(238) = "FF90C8"
MGColor(239) = "FFA0D0"
MGColor(240) = "FFB0D8"
MGColor(241) = "FFD0E8"
MGColor(242) = "000000"
MGColor(243) = "101010"
MGColor(244) = "202020"
MGColor(245) = "303030"
MGColor(246) = "404040"
MGColor(247) = "505050"
MGColor(248) = "606060"
MGColor(249) = "707070"
MGColor(250) = "909090"
MGColor(251) = "A0A0A0"
MGColor(252) = "B0B0B0"
MGColor(253) = "C0C0C0"
MGColor(254) = "D0D0D0"
MGColor(255) = "E0E0E0"
MGColor(256) = "F0F0F0"


'*******************************************************************************
'*** MapGuide Theme list functions
'*******************************************************************************
Sub ThemeList_Clear()
  '*** Clear theme list.
  Call gThemeList.RemoveAll()
  
  '*** Write ThemeList to session.
  Call ThemeList_ToSession()
End Sub


Function ThemeList_Count()
  '*** Return theme item count..
  ThemeList_Count = gThemeList.Count
End Function


Sub ThemeList_FromDatabase(source, maxItems)
  Dim rs, colorList, mgColor, numItems
  
  '*** Clear theme list.
  Call gThemeList.RemoveAll()
  
  '*** Try to create database connection.
  If RSOpen(rs, gDBConn, source, True) Then
    '*** Reset color number.
    numItems = 0
    mgColor  = 1
    
    While ((Not rs.EOF) And (numItems < maxItems))
      '*** Add key-value pair to dictionary.
      Call gThemeList.Add(ToString(rs(0)), mgColor)
      
      numItems = numItems + 1
      mgColor  = mgColor  + 1
      
      rs.MoveNext()
    Wend
  End If
  
  '*** Cleanup.
  Call RSClose(rs)
  
  '*** Too much items?
  If (numItems > maxItems) Then Call gThemeList.RemoveAll()
  
  '*** Write ThemeList to session.
  Call ThemeList_ToSession()
End Sub


Sub ThemeList_FromSession()
  If IsObject(Session(BROWSER_PREFIX & "ThemeList")) Then
    '*** Get existing ThemeList.
    Set gThemeList = Session(BROWSER_PREFIX & "ThemeList")
  Else
    '*** Create new ThemeList object.
    Set gThemeList = Nothing
    Set gThemeList = Server.CreateObject("Scripting.Dictionary")
    
    '*** Write ThemeList to session.
    Call ThemeList_ToSession()
  End If
End Sub


Sub ThemeList_ToSession()
  '*** Write Report object to session.
  Set Session(BROWSER_PREFIX & "ThemeList") = gThemeList
End Sub



'*******************************************************************************
'*** MapGuide Layer functions
'*******************************************************************************
Function CreateMapLayer()
  '*** Create MapLayer object.
  Set gMapLayer = Nothing
  Set gMapLayer = Server.CreateObject("Scripting.Dictionary")
  
  '*** Add parameters to list.
  Call gMapLayer.Add("ServerURL",            "")
  Call gMapLayer.Add("MapLayerGroupName",    "CustomThemes")
  Call gMapLayer.Add("MapLayerGroupLegend",  "Custom Themes")
  Call gMapLayer.Add("MapLayerType",         "")
  Call gMapLayer.Add("MapLayerName",         "CustomTheme")
  Call gMapLayer.Add("MapLayerLegendLabel",  "Custom Theme")
  Call gMapLayer.Add("FeatureDataSource",    "")
  Call gMapLayer.Add("FeatureTable",         "")
  Call gMapLayer.Add("SQLWhereClause",       "")
  Call gMapLayer.Add("SecondaryDataSource",  "")
  Call gMapLayer.Add("SecondaryTable",       "")
  Call gMapLayer.Add("SecondaryKeyColumn",   "")
  Call gMapLayer.Add("SecondaryNameColumn",  "")
  Call gMapLayer.Add("SecondaryThemeColumn", "")
  
  '*** Return succes/failure object creation.
  CreateMapLayer = IsObject(gMapLayer)
End Function


Function CreatePolygonMWX(tmpFile, themeList)
  Dim grpKeys, grpKey, i
  
  '*** Write common MWX header.
  Call writeMWXHeader(tmpFile)
  
  tmpFile.WriteLine "    <PolygonLayer>"
  
  '*** Write general layer properties.
  Call writeGeneralLayerProperties(tmpFile)
  
  '*** Write datasources properties.
  Call writeLayerDataSources(tmpFile, "Polygon")
  
  tmpFile.WriteLine "      <PolygonLayerStyles>"
  tmpFile.WriteLine "        <PolygonLayerStyle>"
  tmpFile.WriteLine "          <MinDisplayRange>0</MinDisplayRange>"
  tmpFile.WriteLine "          <MaxDisplayRange>1000000000000</MaxDisplayRange>"
  
  If (themeList.Count > 0) Then
    '*** Write theme.
    tmpFile.WriteLine "          <PolygonThemeProperties Type=""2"">"
    tmpFile.WriteLine "            <OLEDBThemeDataSource>"
    tmpFile.WriteLine "              <DataSource>" & LayerProperty("SecondaryDataSource") & "</DataSource>"
    tmpFile.WriteLine "              <Table>" & LayerProperty("SecondaryTable") & "</Table>"
    tmpFile.WriteLine "              <KeyColumn>" & LayerProperty("SecondaryKeyColumn") & "</KeyColumn>"
    tmpFile.WriteLine "              <ThemeValueColumn>" & LayerProperty("SecondaryThemeColumn") & "</ThemeValueColumn>"
    tmpFile.WriteLine "              <ThemeValueColumnType>1</ThemeValueColumnType>"
    tmpFile.WriteLine "              <ExpandInLegend>1</ExpandInLegend>"
    tmpFile.WriteLine "            </OLEDBThemeDataSource>"
    tmpFile.WriteLine "            <PolygonThemeCategories>"
    
    '*** Get the keys.
    grpKeys = themeList.Keys
    
    For i = 0 To (themeList.Count - 1)
      '*** Get single key.
      grpKey = grpKeys(i)
      
      tmpFile.WriteLine "              <PolygonThemeCategory>"
      tmpFile.WriteLine "                <LegendLabel>" & EchoXHTML(grpKey, "") & "</LegendLabel>"
      tmpFile.WriteLine "                <MinThemeValue>" & EchoXHTML(grpKey, "") & "</MinThemeValue>"
      tmpFile.WriteLine "                <MaxThemeValue>" & EchoXHTML(grpKey, "") & "</MaxThemeValue>"
      tmpFile.WriteLine "                <PolygonStyle>"
      tmpFile.WriteLine "                  <FillStyle>Solid</FillStyle>"
      tmpFile.WriteLine "                  <FillColorIndex>" & themeList.Item(grpKey) & "</FillColorIndex>"
      tmpFile.WriteLine "                  <FillBackgroundColorIndex>0</FillBackgroundColorIndex>"
      tmpFile.WriteLine "                  <LineStyle>Solid</LineStyle>"
      tmpFile.WriteLine "                  <LineColorIndex>4</LineColorIndex>"
      tmpFile.WriteLine "                  <LineThickness>1</LineThickness>"
      tmpFile.WriteLine "                </PolygonStyle>"
      tmpFile.WriteLine "              </PolygonThemeCategory>"
    Next
    
    tmpFile.WriteLine "            </PolygonThemeCategories>"
    tmpFile.WriteLine "          </PolygonThemeProperties>"
  Else
    '*** No theme.
    tmpFile.WriteLine "          <PolygonStyle>"
    tmpFile.WriteLine "            <FillStyle>Solid</FillStyle>"
    tmpFile.WriteLine "            <FillColorIndex>2</FillColorIndex>"
    tmpFile.WriteLine "            <FillBackgroundColorIndex>0</FillBackgroundColorIndex>"
    tmpFile.WriteLine "            <LineStyle>Solid</LineStyle>"
    tmpFile.WriteLine "            <LineColorIndex>4</LineColorIndex>"
    tmpFile.WriteLine "            <LineThickness>1</LineThickness>"
    tmpFile.WriteLine "          </PolygonStyle>"
  End If
  
  tmpFile.WriteLine "        </PolygonLayerStyle>"
  tmpFile.WriteLine "      </PolygonLayerStyles>"
  tmpFile.WriteLine "    </PolygonLayer>"
  
  '*** Write common MWX footer.
  Call writeMWXFooter(tmpFile)
End Function


Function CreatePolylineMWX(tmpFile, themeList)
  Dim grpKeys, grpKey, i
  
  '*** Write common MWX header.
  Call writeMWXHeader(tmpFile)
  
  tmpFile.WriteLine "    <PolylineLayer>"
  
  '*** Write general layer properties.
  Call writeGeneralLayerProperties(tmpFile)
  
  '*** Write datasources properties.
  Call writeLayerDataSources(tmpFile, "Polyline")
  
  tmpFile.WriteLine "      <PolylineLayerStyles>"
  tmpFile.WriteLine "        <PolylineLayerStyle>"
  tmpFile.WriteLine "          <MinDisplayRange>0</MinDisplayRange>"
  tmpFile.WriteLine "          <MaxDisplayRange>1000000000000</MaxDisplayRange>"
  
  If (themeList.Count > 0) Then
    '*** Write theme.
    tmpFile.WriteLine "          <PolylineThemeProperties Type=""2"">"
    tmpFile.WriteLine "            <OLEDBThemeDataSource>"
    tmpFile.WriteLine "              <DataSource>" & LayerProperty("SecondaryDataSource") & "</DataSource>"
    tmpFile.WriteLine "              <Table>" & LayerProperty("SecondaryTable") & "</Table>"
    tmpFile.WriteLine "              <KeyColumn>" & LayerProperty("SecondaryKeyColumn") & "</KeyColumn>"
    tmpFile.WriteLine "              <ThemeValueColumn>" & LayerProperty("SecondaryThemeColumn") & "</ThemeValueColumn>"
    tmpFile.WriteLine "              <ThemeValueColumnType>1</ThemeValueColumnType>"
    tmpFile.WriteLine "              <ExpandInLegend>1</ExpandInLegend>"
    tmpFile.WriteLine "            </OLEDBThemeDataSource>"
    tmpFile.WriteLine "            <PolylineThemeCategories>"
    
    '*** Get the keys.
    grpKeys = themeList.Keys
    
    For i = 0 To (themeList.Count - 1)
      '*** Get single key.
      grpKey = grpKeys(i)
      
      tmpFile.WriteLine "              <PolylineThemeCategory>"
      tmpFile.WriteLine "                <LegendLabel>" & EchoXHTML(grpKey, "") & "</LegendLabel>"
      tmpFile.WriteLine "                <MinThemeValue>" & EchoXHTML(grpKey, "") & "</MinThemeValue>"
      tmpFile.WriteLine "                <MaxThemeValue>" & EchoXHTML(grpKey, "") & "</MaxThemeValue>"
      tmpFile.WriteLine "                <PolylineStyle>"
      tmpFile.WriteLine "                  <LineStyle>Solid</LineStyle>"
      tmpFile.WriteLine "                  <LineColorIndex>" & themeList.Item(grpKey) & "</LineColorIndex>"
      tmpFile.WriteLine "                  <LineThickness>2</LineThickness>"
      tmpFile.WriteLine "                </PolylineStyle>"
      tmpFile.WriteLine "              </PolylineThemeCategory>"
    Next
    
    tmpFile.WriteLine "            </PolylineThemeCategories>"
    tmpFile.WriteLine "          </PolylineThemeProperties>"
  Else
    '*** No theme.
    tmpFile.WriteLine "          <PolylineStyle>"
    tmpFile.WriteLine "            <LineStyle>Solid</LineStyle>"
    tmpFile.WriteLine "            <LineColorIndex>4</LineColorIndex>"
    tmpFile.WriteLine "            <LineThickness>2</LineThickness>"
    tmpFile.WriteLine "          </PolylineStyle>"
  End If
  
  tmpFile.WriteLine "        </PolylineLayerStyle>"
  tmpFile.WriteLine "      </PolylineLayerStyles>"
  tmpFile.WriteLine "    </PolylineLayer>"
  
  '*** Write common MWX footer.
  Call writeMWXFooter(tmpFile)
End Function


Function LayerProperty(propertyKey)
  '*** Return property value if key exists.
  If gMapLayer.Exists(propertyKey) Then
    LayerProperty = Server.HTMLEncode(gMapLayer.Item(propertyKey))
  Else
    LayerProperty = ""
  End If
End Function


'*******************************************************************************
'*** Private MapGuide Layer Functions
'*******************************************************************************
Sub writeGeneralLayerProperties(tmpFile)
  '*** Write 'GeneralLayerProperties' part.
  tmpFile.WriteLine "      <GeneralLayerProperties>"
  tmpFile.WriteLine "        <Name>" & LayerProperty("MapLayerName") & "</Name>"
  tmpFile.WriteLine "        <Visible>1</Visible>"
  tmpFile.WriteLine "        <LegendLabel>" & LayerProperty("MapLayerLegendLabel") & "</LegendLabel>"
  tmpFile.WriteLine "        <ShowInLegend>1</ShowInLegend>"
  tmpFile.WriteLine "        <DrawPriority>100</DrawPriority>"
  tmpFile.WriteLine "        <Selectable>1</Selectable>"
  tmpFile.WriteLine "        <Static>0</Static>"
  tmpFile.WriteLine "        <AccessKey></AccessKey>"
  tmpFile.WriteLine "        <AccessGeometry>1</AccessGeometry>"
  tmpFile.WriteLine "        <AccessGeometryPasskey></AccessGeometryPasskey>"
  tmpFile.WriteLine "        <AccessLayerSetupAPI>1</AccessLayerSetupAPI>"
  tmpFile.WriteLine "        <AccessLayerSetupAPIPasskey></AccessLayerSetupAPIPasskey>"
  tmpFile.WriteLine "        <AccessLayerSetupAPIAdvancedSettings>0</AccessLayerSetupAPIAdvancedSettings>"
  tmpFile.WriteLine "      </GeneralLayerProperties>"
End Sub


Sub writeMWXHeader(tmpFile)
  '*** Write MWX header.
  tmpFile.WriteLine "<?xml version=""1.0"" encoding=""UTF-8""?>"
  tmpFile.WriteLine ""
  tmpFile.WriteLine "<MapWindow Version=""6.5.0.0"" xsi:noNamespaceSchemaLocation=""MapWindowXMLSchema6.5.xsd"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">"
  tmpFile.WriteLine "  <GeneralProperties></GeneralProperties>"
  tmpFile.WriteLine "  <CoordinateSystem></CoordinateSystem>"
  tmpFile.WriteLine "  <MapLayers>"
End Sub


Sub writeMWXFooter(tmpFile)
  '*** Write MWX header.
  tmpFile.WriteLine "  </MapLayers>"
  tmpFile.WriteLine ""
  tmpFile.WriteLine "</MapWindow>"
End Sub


Sub writeLayerDataSources(tmpFile, layerType)
  '*** Write 'xxxLayerDataSources' part.
  tmpFile.WriteLine "      <" & layerType & "LayerDataSources>"
  tmpFile.WriteLine "        <ServerURL>" & LayerProperty("ServerURL") & "</ServerURL>"
  tmpFile.WriteLine "        <SDPFeatureDataSource>"
  tmpFile.WriteLine "          <DataSource>" & LayerProperty("FeatureDataSource") & "</DataSource>"
  tmpFile.WriteLine "          <FeatureTable>" & LayerProperty("FeatureTable") & "</FeatureTable>"
  tmpFile.WriteLine "          <KeyColumn>FEATURE_ID</KeyColumn>"
  tmpFile.WriteLine "          <KeyColumnType>1</KeyColumnType>"
  tmpFile.WriteLine "          <GeometryColumn>FEATURE_GEOM</GeometryColumn>"
  tmpFile.WriteLine "          <GeometryFunction></GeometryFunction>"
  tmpFile.WriteLine "          <ClipEnabled>1</ClipEnabled>"
  tmpFile.WriteLine "          <ClipAdjust>0</ClipAdjust>"
  tmpFile.WriteLine "          <SpatialQuery></SpatialQuery>"
  tmpFile.WriteLine "          <PreSQLStatements></PreSQLStatements>"
  tmpFile.WriteLine "          <PostSQLStatements></PostSQLStatements>"
  tmpFile.WriteLine "          <NameSource>1</NameSource>"
  tmpFile.WriteLine "          <NameColumn>" & LayerProperty("SecondaryNameColumn") & "</NameColumn>"
  tmpFile.WriteLine "          <URLSource>0</URLSource>"
  tmpFile.WriteLine "          <URLColumn></URLColumn>"
  tmpFile.WriteLine "          <ApplySQLWhereClauseTo>1</ApplySQLWhereClauseTo>"
  tmpFile.WriteLine "          <SQLWhereClause>" & LayerProperty("SQLWhereClause") & "</SQLWhereClause>"
  tmpFile.WriteLine "        </SDPFeatureDataSource>"
  tmpFile.WriteLine "        <SecondaryDataSource>"
  tmpFile.WriteLine "          <DataSource>" & LayerProperty("SecondaryDataSource") & "</DataSource>"
  tmpFile.WriteLine "          <Table>" & LayerProperty("SecondaryTable") & "</Table>"
  tmpFile.WriteLine "          <KeyColumn>" & LayerProperty("SecondaryKeyColumn") & "</KeyColumn>"
  tmpFile.WriteLine "        </SecondaryDataSource>"
  tmpFile.WriteLine "      </" & layerType & "LayerDataSources>"
End Sub
%>