inherited SMViewForm: TSMViewForm
  Caption = 'SM View'
  ClientHeight = 543
  ClientWidth = 965
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  ExplicitWidth = 981
  ExplicitHeight = 581
  PixelsPerInch = 96
  TextHeight = 13
  object Viewer: TGLSceneViewer
    Left = 205
    Top = 0
    Width = 760
    Height = 543
    Camera = Camera
    Buffer.BackgroundColor = 4210752
    Buffer.FaceCulling = False
    FieldOfView = 143.320144653320300000
    Align = alClient
    OnMouseDown = ViewerMouseDown
    OnMouseMove = ViewerMouseMove
    OnMouseUp = ViewerMouseUp
    TabOrder = 0
  end
  object Splitter: TSpTBXSplitter
    Left = 200
    Top = 0
    Height = 543
    Cursor = crSizeWE
    MinSize = 200
  end
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 543
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinWidth = 200
    TabOrder = 2
    object MeshList: TVirtualStringTree
      Left = 0
      Top = 59
      Width = 200
      Height = 484
      Align = alClient
      Ctl3D = True
      DragMode = dmAutomatic
      DragOperations = [doMove]
      Header.AutoSizeIndex = -1
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Height = 24
      Header.MainColumn = -1
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs]
      Images = ResourcesForm.Images16x16
      ParentCtl3D = False
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoTristateTracking]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseExplorerTheme]
      TreeOptions.SelectionOptions = [toMultiSelect, toRightClickSelect]
      OnChange = MeshListChange
      OnFreeNode = MeshListFreeNode
      OnGetText = MeshListGetText
      OnGetImageIndex = MeshListGetImageIndex
      OnGetNodeDataSize = MeshListGetNodeDataSize
      Columns = <>
    end
    object ToolDock: TSpTBXDock
      Left = 0
      Top = 0
      Width = 200
      Height = 59
      object ToolbarViewMode: TSpTBXToolbar
        Left = 0
        Top = 25
        BorderStyle = bsNone
        DockMode = dmCannotFloatOrChangeDocks
        DragHandleStyle = dhNone
        FullSize = True
        Images = Images
        Stretch = True
        TabOrder = 0
        Caption = 'ToolbarViewMode'
        object SpTBXItem1: TSpTBXItem
          Action = DrawWireframe
        end
        object SpTBXItem5: TSpTBXItem
          Action = DrawMesh
        end
        object SpTBXItem4: TSpTBXItem
          Action = DrawEdges
        end
        object SpTBXItem2: TSpTBXItem
          Action = DrawEdgeVertices
        end
        object SpTBXItem3: TSpTBXItem
          Action = DrawVertices
        end
        object SpTBXSeparatorItem1: TSpTBXSeparatorItem
        end
        object SpTBXItem6: TSpTBXItem
          Action = DrawTextures
        end
      end
      object ToolbarControlMode: TSpTBXToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        DockMode = dmCannotFloatOrChangeDocks
        DragHandleStyle = dhNone
        FullSize = True
        Images = Images
        Stretch = True
        TabOrder = 1
        Visible = False
        Caption = 'Toolbar'
        object SpTBXItem11: TSpTBXItem
          Action = ModeCamera
        end
        object SpTBXSeparatorItem2: TSpTBXSeparatorItem
        end
        object SpTBXItem9: TSpTBXItem
          Action = ControlMove
        end
        object SpTBXItem8: TSpTBXItem
          Action = ControlRotate
        end
        object SpTBXItem7: TSpTBXItem
          Action = ControlScale
        end
      end
    end
  end
  object Scene: TGLScene
    Left = 8
    Top = 56
    object SkyDome: TGLSkyDome
      Direction.Coordinates = {000000000000803F0000000000000000}
      Up.Coordinates = {00000000000000000000803F00000000}
      Bands = <
        item
          StartColor.Color = {0000803E0000803E0000803E0000803F}
          StopAngle = 15.000000000000000000
          StopColor.Color = {6666263F6666263F6666263F0000803F}
        end
        item
          StartAngle = 15.000000000000000000
          StartColor.Color = {6666263F6666263F6666263F0000803F}
          StopAngle = 90.000000000000000000
          StopColor.Color = {CFBC3C3ECFBC3C3EA19E9E3E0000803F}
          Stacks = 4
        end>
      Stars = <>
    end
    object DummyCube: TGLDummyCube
      CubeSize = 1.000000000000000000
      EdgeColor.Color = {029F1F3FBEBEBE3E999F1F3F0000803F}
    end
    object Camera: TGLCamera
      DepthOfView = 10000.000000000000000000
      FocalLength = 90.000000000000000000
      TargetObject = CameraTarget
      Position.Coordinates = {F9D6134300004041000013430000803F}
      object CamLight: TGLLightSource
        ConstAttenuation = 1.000000000000000000
        Diffuse.Color = {8D8C0C3F8D8C0C3F8D8C0C3F0000803F}
        SpotCutOff = 180.000000000000000000
      end
    end
    object CameraTarget: TGLDummyCube
      CubeSize = 1.000000000000000000
    end
    object FreeMesh: TGLFreeForm
      MaterialLibrary = GLMaterialLibrary
    end
    object Grid: TGLXYZGrid
      AntiAliased = True
      LineColor.Color = {FBFAFA3EFBFAFA3EFBFAFA3E0000803F}
      XSamplingScale.Min = -100.000000000000000000
      XSamplingScale.Max = 100.000000000000000000
      XSamplingScale.Step = 5.000000000000000000
      YSamplingScale.Step = 1.000000000000000000
      ZSamplingScale.Min = -100.000000000000000000
      ZSamplingScale.Max = 100.000000000000000000
      ZSamplingScale.Step = 5.000000000000000000
      Parts = [gpX, gpZ]
    end
    object LightBack: TGLLightSource
      ConstAttenuation = 1.000000000000000000
      Diffuse.Color = {9695153F9695153F9695153F0000803F}
      Position.Coordinates = {0000204100002041000020410000803F}
      SpotCutOff = 180.000000000000000000
    end
    object LightFront: TGLLightSource
      ConstAttenuation = 1.000000000000000000
      Diffuse.Color = {9695153F9695153F9695153F0000803F}
      Position.Coordinates = {0000204100002041000020410000803F}
      SpotCutOff = 180.000000000000000000
    end
    object GLDirect: TGLDirectOpenGL
      UseBuildList = False
      OnRender = GLDirectRender
      Blend = False
    end
    object RootTemp: TGLDummyCube
      CubeSize = 1.000000000000000000
    end
  end
  object GLMaterialLibrary: TGLMaterialLibrary
    Left = 8
    Top = 120
  end
  object WindowsBitmapFont: TGLWindowsBitmapFont
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 8
    Top = 152
  end
  object Actions: TActionList
    Images = Images
    Left = 40
    Top = 56
    object DrawWireframe: TAction
      AutoCheck = True
      Caption = 'DrawWireframe'
      GroupIndex = 1
      ImageIndex = 0
      OnExecute = DrawWireframeExecute
    end
    object DrawMesh: TAction
      AutoCheck = True
      Caption = 'DrawMesh'
      GroupIndex = 1
      ImageIndex = 1
      OnExecute = DrawMeshExecute
    end
    object DrawEdges: TAction
      AutoCheck = True
      Caption = 'DrawEdges'
      GroupIndex = 1
      ImageIndex = 2
      OnExecute = DrawEdgesExecute
    end
    object DrawVertices: TAction
      AutoCheck = True
      Caption = 'DrawVertices'
      GroupIndex = 1
      ImageIndex = 4
      OnExecute = DrawVerticesExecute
    end
    object DrawEdgeVertices: TAction
      AutoCheck = True
      Caption = 'DrawEdgeVertices'
      GroupIndex = 1
      ImageIndex = 3
      OnExecute = DrawEdgeVerticesExecute
    end
    object DrawTextures: TAction
      AutoCheck = True
      Caption = 'DrawTextures'
      ImageIndex = 5
      OnExecute = DrawTexturesExecute
    end
    object ControlSelect: TAction
      Caption = 'S'
      OnExecute = ControlSelectExecute
    end
    object ControlMove: TAction
      Caption = 'M'
      OnExecute = ControlMoveExecute
    end
    object ControlRotate: TAction
      Caption = 'R'
      OnExecute = ControlRotateExecute
    end
    object ControlScale: TAction
      Caption = 'S'
      OnExecute = ControlScaleExecute
    end
    object ModeCamera: TAction
      Caption = 'C'
      OnExecute = ModeCameraExecute
    end
  end
  object Images: TPngImageList
    Height = 24
    Width = 24
    PngImages = <
      item
        Background = clWindow
        Name = 'draw-wireframe'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000000473424954080808087C086488000000097048597300000DD700000D
          D70142289B780000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000005F14944415478DA95950B5094551480CFB9F7
          DFFD77818D87298F2C7BEA645961A8059284842988486994A9539926498195E9
          8CD368333D46CB4C7374CCD1D2225BC746449968A1F041848D360A5A0A8E28F9
          0491641FECE3BFA7B32865240DDD997FFEF9EF7FCEF9CEF35E2422E8CD5A8BF3
          C303A1EDD63CE7AA73BD52B8BAB027C0169C2C5BAC31C324E11805988E422420
          4A2F197E048206006A008456166D53207790F4D65F0FFE0FC01A6BE1AD02543A
          10A613C204DE0AF0D388007BC5C01121183DE0B4CF51F21E5ADD2F20E1744031
          08A5768C02BE7696BB8B1FBD138E50DF64B43BBD7E6301AE8075376926CF7A14
          E7060A749AD95B070B3A7414BBFCA8FA29050F08A478D04373C8EB8E864E87A8
          8D7DABD40627DD4552FF60C6BEAC4D41075747E44536BA3D8BD9785EB3724B2B
          9ADEC395F0ED5B80C67C0065269002D1D982D87118C05FA169AECD024FDCAA48
          CD664FC7625474ADBAF0FB229260E328E36544F44CF547338252789E5C178E04
          5AFB7B28608A16D68D278C76133B52851FC377331044523E8D7E6EB579D53045
          FA64509647082C8344D8E970E16F21F2F7B948B69816ADEF0DBFF98F354E7D99
          F29C418F3FCBAAAB395CBDA9F2546BFD4C2E4ED82DC2F67DBB619AB08136743C
          86195B59A4882328CFE6A09F674056F7027D94F4559176D1D7221A8C4834878D
          555E3D9C94454374399DE25CD3215135D0157051B4B07CEE37AC738286BB741F
          C3719504623147E018C9455C924F6989FF028CDCBC5133879EB4D96ED339F5D3
          782B4CB93B7E091C3FE33D74AA665887EE0E4948C88C9FBD7B745D775D061C92
          A0A6E247E0B85B026C63C0A0E08F95E31A749BF48C5602B23DCEDF7385B0D4EB
          D61B5702E26041C8E5801F48AAE1FB776D2BD03473D403891967B8E055845403
          246A02E0393073FB836E069C16603CC45D54DA17C0F4AB6D7CF42B1C52361766
          284754C9452C6E6B3B3491EB573DB72AF7D3F513EA16051D78BEF8DECEF7342C
          A80C8F8A498C4F1E972848DE09A44610E1706ED1FB14048E7FBD63E13D1612E1
          6807BB3CDB27C447833B1AA534DB9D015C327F4FE6A52B292A5A0D200E16EECD
          5D733D404454CCC811239E8C9A527AE7E5AED43CFDD0D4213E8F7FEBE5DACBB7
          3B54A9D639682B4545AB31F4E21CB21A137950D27854CB00E4E7442A13051E29
          D893BBEABA803EB18F24A78EB74CB20FF605F7B2E39FC803456F07DCF481B7C1
          FB8A834AE3AE00B0FC9800CC7C99461F7B3FB9285227F114A78A8B4AF7737E6B
          08456144D43D13AF054CC74206C48CFAB8E54DCCB93FA79F4258CFF2714AC967
          7CB54EDD00F105038674017E64C06B0CA8FE4717257FB59E7FF747848188269B
          598F386508312DBF2CB576BA28DCCD35483A79F3BE2C36B28E23DF6436B485F6
          3ABB2F0D331FE5C15D544EA5A33A012BB0BC84C7716D3EA597FC757ACEDA6FF2
          1E6D2A923264803534EE367FA0FD8CAFE3526CC0EFBC514A8BEB70DD3EE30F71
          E1868EB88BE70CA267B71FFCE6FB2EDD341CF72437CA148E60E2D5082A363071
          973E33EA4BEDAC996B8093586EBCDB75DA0D14F845B70D9835A3F8DEF341E5A5
          238B6D565D2BA83BB267419B6A36A726BCE43649CB296ED11FF880AC0C806997
          BDE4D527D8C67006BCD009F844562CD7622DA9FAD0F038B651C73FED01A4ADCE
          D6DA7C3EEC3C73AB9E7EA7FB20058B1C7CDF91929DD63FACDF50212885D394C2
          7548FCB976DBD9FAC6EA1207ED9C7705808E0430C9ED64A81652F86E2CB46E99
          44938C65C9458B8412545095BBB827C0465A9E72EDFEE332235B11AC43829C32
          DAB9FBEFFB80DD5E01E559DCA2F3B8F7E30868997AB8B9AF120873F7E6BED51B
          403A66BCCA7A6F081013CA68C7FE1E6F348E288900E7A99B5D69146A1C90BF59
          73F2696C734F80C97CFB5D02E772FE1CC5C743461995355DF746EBBE96C5EE18
          25DB4D79C225C7048F5E8EECC37C4A3D7E2DA0090E666A10B2999B447AC03C79
          2F15B75F6B037B73E973449C322C60F1196CA8428158B21F4A967AC1656B053E
          D300AA23212CDF4E76A3BB6EAF007FCD069687FB0067719E0B7E851F23EBE127
          9DC1AF97D3CE653DE9FC2F40D75A8C5BCC081D2F1E85AAB35FD29A6FFE4BF64F
          DF24EDC06C41C7020000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'draw-normal'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000000473424954080808087C086488000000097048597300000DD700000D
          D70142289B780000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A0000045C4944415478DAADD67F4C1B551C00F0F7DE
          DDF5AEBF28A5945F03E71C4EE68F4DB6690853962881045D747133464D309B8B
          3F893AA7FE6116E11F63A231BACD0D367F6032A74BFC43B3296D192B32A71B41
          F8C3A199A36563A594425B4AAFEDDDBDBBF73C4A48D0C0ACDA6FF2CDBDDCBDFB
          7EF2DEE5F27D90520AB28976D39E1548C3565981A32D74BF9CD54B7AC0E58023
          F01913E5853AC8C10710439BF469C58C4092AAC8E44396C4104BFD5443BFA90A
          1C86048D408A2FDB9542FF0EFA96B23400213C6A7E793D21B491E1C156A2806A
          C1A9051D1BE548516D6ACAB1299180881888AA0AE2186B4B5ED1739CB3A6023C
          275EE31939CC0BAAC85A1147A27AFA7D29319AD4F00BF043D059C9F1A9AF109A
          AC648DF154FE5A75A4A846192F6D9043824D81846A3C25AA9EFA3533C63CA184
          074459B8672073CFA9CA6B3215FA0E973ACEF4B2C22C568140D9B7E141E0DA67
          AEE05B29C0203D01106B4DCAAC311ACB5B1D1D2FAB0F8E96378C4F67039CFDAC
          A0C47392B3614E85B69A9814F7F16A72C4BC171E00A777553E6AFBA0F19880A4
          58589DFC3986823F496CF02C8322172D9CA62060B0CE48BC231277AC0F4E9737
          8D844D2BE3DA02E0EDB0DD70FA7B54A4702A70D626A2C6AA8488313107BE29E4
          A400FFB4BE45DD0F956F31776EEBB61A28092B400B63AA2720F3397309B2C173
          45E660BFD3181E70F2B363768EE1259232F995F3621FA7721894D4A50279778A
          21AC1033C69A790E18FBB2985522EC23FA0A3C9BEDB7194F3D3E94BF24403551
          0154D3C7040340B026432D78CE696F7FCD5C19B25CC637354FF6624CCD2A26A6
          C5C0E8E725BC9A60EA74C05D652CE5FB775E7530D90080D2CCB8ADB1AC7AC230
          AE556C0F5F982BF877C07FA4CCA22ADC1AF81EF0169A4C5AE0D999622D9780EF
          A37287482D56D80A5A91036EC6CFA74A24007303C8696AF17794D9BB491797F9
          D10E197BC4A77C4E2438A6E55C00A908CA1B3B5EC478B0CB9E013A6CDEE0F61F
          0BECF6351129178038CEDA02DF16263C92EBC60C70D4E1BDD8F4B56D7569ED4C
          4E80B88FB387DC0557DC92BB7A1E707A7BEF6BCFAB59F5603C9D0B203A2C144C
          FF903FE0925CF5F35B54E03D71CF3B9687D7362752B900A67F311546CEE79D74
          CBAE27E63FB270E6FD5B77092DF7BE2B8910FC7F20D4672D9A19B27478B4AE57
          33C07EE8B99DCF634E702650B161AF08AA9E1C13396152F92FC0D420EF9CECB5
          995495D6F75057FF5F1ACE01D8BD85B38236BDC85D77EC0E48EB9E1B8A1BED91
          74B6C055B7B93C3A64444465EEEFA6A77E5FB6A3655664A1FB340CB7566EF3CF
          6E7C69306A5B154B2E07C86962BD74DC5A298E71D3009306377587FFB165CEC5
          21E8A94046FA3AD1C0CEB2DA89F8A65706A64AEE0ECE2C068A1BA7067FFDD8BA
          4E8EA17E45951EF352AF94554F5E1C87E177768D35BC8810D9937F732CBDA165
          20F4C5C1D44A5FFA1A130B6195C8F0538FEA7A832E512C2B60213A61AF9040B8
          99E5B53787E5FE157FD00B50EFD3BBDD6AD727FFFA5471BD68836DC8006ED931
          0C7A268FD1A3BDD79BFB276F1A9DCA6CD5F0560000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'draw-edges'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000000473424954080808087C086488000000097048597300000DD700000D
          D70142289B780000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A0000062B4944415478DA95D67B705C551D07F073CE
          7DEEDE7DDEDD4D366992364D8A2969915694CE560BA54C33D3CA00028E620545
          D13F84519119FF70185A6764FC43C516E455C43A8382A37FA82D349BB46C0AA5
          A4B1A4834DC0B6799074B3D9BD9BDDED76EFDEC7B9E79EE34D3A9989DA96F89B
          397FDDC7E79EEFF9DD7B2E648C81E5D40BFEC75620D709DA184E3ECAF6D9CBBA
          C82B7835E025F85D3F93E42D50803B11C77630805A391FC4E41215204F2B8867
          13D4E18A2E01C390A261C89CF3511C9FB88F3D89AF0C4008F72B3FF834A5AC87
          93C01D14830D72C2CDC53E63971A5246516C09AF423CE144393B35F99ADA5138
          166A212612826BEA154747AEAD4932D1F9201268D91B13E3865EAEBBCEF7E05E
          70A053908CD7112A74F2BEAA11594BC61A36E199A6ED765E0E6348992B314AA4
          DC60F3E6C211102F0DC240B0D3AAAED8A11512A9721D402252EF386344726D26
          BFFD7C53ECAD015EBEE4102033FE29F82CE87D4269957633E0007316203E58B7
          795FB912EA28CF24B7E63E766BD5E04C5A5E6FCD09F1F866526DBFE7C207BE15
          2605147BB08733770178E7776AB2EFA010760402C39B2A56755C22F531E571F8
          0C38F2ADCE2F877FDDF3AA8CAC8A460AEF5550EE84C5E7DEE19036ED88A83209
          3851C552126175FD9CD1B6F3CC887F65D55D04322F86DB8EBC891AB040402255
          2BFBBA6ABAE35025FBD7B86065A56F7B11F5DFD9728B72E0EEFEA0C8A88681AB
          39CC1B806ACE1B3F6B501B5BCA96DF71416EA821ACBD9FE02F4D45102759D4F0
          4FE041FD6D81080E486E31B2A11BF5BC83A9E238AE320F4CBFD6C8E3127F8F37
          83BECDD16EDFA1FB4F47FE0738FC54426DBABE883B6FD680ADCB61EA40C42835
          AAFF92F181DD2034AB9CC71D0F143298503F71A87F2930F9FBA4446ADC160F48
          77F99AA4A187A662DC3CC088468839C711B322657E13911B3BCA56F7F609CD31
          042F12E08A3EA388754979FAEBA1550551E356DF16A036A8D66C50336D5A2398
          185E2F1379E2A5E600C1C275F0172013F7FBDDEC774A8D90D84544ED390858D1
          E4B8827E746FC49F682FD56FBCE3BC562F0513CC4B3E102B4F004A9D3D3DCD1B
          66C519B7ED4BE5616AC94982B91871589838AEDF742C30F967155D2CCB0ADC0D
          7623954B3989874CB83A8570D7365D57229A3D1F51FFAFD448ACB5626CB8F3DC
          5581D67BB593F3912C46A4CF096A6924D168E5213A34F577B4F0A23DE73BAAF7
          1C54F8B1F7F270FC5D5348743A78ED56AD76E10324C45A2F9A1BEF3A5BF84400
          337F6134B4AA9A55E24A53C5281CF6BB7D4E6F740178319CC9DD7B5C8D46AF2B
          59C4D0C8B9812AF7D11124CF8EFAE5686BCD4AEDFA30176F337D8CB22B02F50A
          8A4D9F54D7014091DAAD95AD1253B27F8BD7FAACDE550BC0FE586664C75FC21D
          4DA98BD6D22EEAFF652CA29738A4CFC9023605B17D63D1EEBE7D6CAC61B5A62D
          02D20DF56C7E24B82ED2A6E7231D95AA4388521D17A2F9B4FA71DA4A6FB80C24
          3203B7BD10DAD4FEC5AAB90830B7488E3D1789893E9B5BBB7556A8CCC8C6F889
          A438F97E5C54A2984D9D2FB051F734A332759A6F2A7D28474CB2D8A6E551599D
          3B1639D56BF5DE7E392235F3A7CFFF3C70D7DA076AA66B17A1639445AF4DC57F
          BC2ECFB7A5B9E9FE9129085CEF134D3D1890B3C756C60F3EDDBA66D43D01BB6F
          0D11CAD9C09A6F557AC9B65D9D1687A548693074306DF77EEDF222FBDFDA77FD
          37E4476EFEA90D202862083483E30BFAF197030AE23049ED1A999DCF7D1E008C
          39FFBD06AE25245C5B6A703154BD360D640729280FCB7BFBDCC33F5A00F6C1BE
          7592CABF29882CBAF1719D75ED9AD605B9808FBF12080297B89B1F3C93BB16B0
          B44DBDA74F1406C20A216CDB51D63BF41F1BCE33B0FF162108F67837F9ECFA87
          B3166E28418030F9C237FFB92C602AADB4944FFB1025DCB67E76E8A3ABEE680B
          330AB02770DCBC3BDC55C53B9F7C773ADC5EA95F0DB04D1A3CFBC760A73E2DCC
          01876E4FB3B4F6895BE6C28C9287D6F336F77D66A0AF36A766AB37FDF05431F9
          B9DCC5A540634F71F8CCCBC11BEC0A1AC2C4FA4A8665AC65EDC94BEB79F846D4
          E5C54710A28F45D654CC8D8F9ECAFFE15963E5B87981ABE41D426DF84A1FE9FD
          31BBC2CD96052CD6013820D790F3202FB93F19B587569C63272144F4E13439FC
          DBFFFBAFE25AB507EE4122F8D47DA3E068E155B67FE05AE7FE1BF93639CAF5F9
          418E0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'draw-vertex-edge'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000000473424954080808087C086488000000097048597300000DD700000D
          D70142289B780000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000006AD4944415478DA95D67D5014E71D07F0E7D9
          BDDDBDE3B83BEE8D3BE425724045CF37C4021195D4A6BE62B5C5A40D716A2635
          6DFF8AB69D34334DE34B6B93A6D3694463125F263193D438B5ADE3348D1EA848
          31185E841AF00D01E180835BB8BD3BD9BBDB97679FA777B4CCA4331AEDEF9F9D
          D979F6F799F9EE6FF6B79010021E563059BFD69F68FC50D9A7FC163F5DFD14D9
          ADA4EEDB619159007DC6648FB1073EFB20E008FC711AE1F42B210337204ADD70
          3AC1E777601F799D7B4EA575200C7478404E7CBBE4A4FA16B300821716529E16
          876CBD3B8367C339C501D03B083DC063990491B95120B41E35EE5C8431594373
          6023564089DEA505EC2572C8B52CC647D39922862594DB191AE8FFD85A186C32
          E7BC3BD1C6F5829BE4B582CD936CC8C222516782AC161A208968B6F283A257E4
          9A2EB8577FF2E60DDC56CC91BEC44A7381609DA7F66756A8A3B3D64AE3AC51A1
          30D638421017B8E2AE1C3F0F1DA156CA642E9422D9EBF9A0739910439ACA5194
          C6A6CE6832D1FFF39D2CFB471743FA38D1837EAD73142EA19EB8D30FBA0B9FB3
          ED2445D132C89A62B22E2D2C486EBF101ACC7DEC3C7D54DD665D2413C1607754
          A2687ECDF03543760203AC70641AD7588C11D7FCBECD5DFF77C6823804CC8F0B
          D2480F269ADFF2323C00EAB7676E02FB9F3E9505A5308F8257C254A045D2FDED
          543723059CF419F530A84DAB56BDB905B27D8110CFABFEA21B592294EF778BE7
          FF2BDECA2CCE6694CE4B46BBCAAAC0B17C2A64281263AA8A8D23A71D8C34CA6D
          8775A061534E95F1F8771A4C2CC1BC02345E255A501D19E9C735D517DDB33239
          F49B9A7553E3ED2E0B7FD5A9BB3794410D305DC409BCF053F57D20E86EE1AA6F
          B9FDE98B441E29384D5535630AF07FECD229215D0D3C08EA2BAD5EC327B55D19
          FF0300CCAB675FCBB465CD9B500ACB79208B7A0B56292A194BFC5A5342FBD1EE
          264B90F8414DADA7C5536896534DBF0CDC3DEEE69048AF4C02BE624316D7F6FC
          909D4E0104F1082526689408738D87AC7A57812079570FF06A9C49660E34D610
          9F5044CEF8C6B386D9E3BA203D77B50D2B303A25817B92AC89AA82E2302622C3
          CD0FAC6645C573E166DD4F566552390DCF9ECDD3CA4B7320962721207C82A683
          E2853A6B9A333F145BBCF10E1F0B999C440338DD2E0C008CD5BD6B66958CB1A3
          5ADE77854E2CE9DD48A51D482166A46A69F2A74B293C6A8747D45FFD016E645E
          3891049EE9747D02DEDDBB4B2EFEA6281A3382722AA2863FDA33ECB9E178C9A6
          DE0702B95BF8D65424331189938CADF56C3C6B881F87539AB00D02A0ABF4D2A5
          4D2FEDABC56E358FF47F96609C85AA92F3F561D1B79F98C7322F2B873EB2F43D
          14508891BF6E7E2C3A627418B38478E0AC1E5F501B32A63F15872D8D812D976D
          56EBD742128AF3A8F75294FE53DD40BAA1B594F940DD07DEAC9B3F5CB5CA987C
          47E4BE402C4CD9FD6DB6F9C95E947DDEB82009C03872C631552F9D9B3D0D1CB5
          37F6ACFF8BA5206B59449A99A2DEDE5B64C3DA7F64990C46FC62C50EA4491C9B
          BF6442F63ED9D7E7CCE7F91DCBEDE57DE036F6AC6407F81B66AF75B6389E911F
          89AA0819A3FD8C75DC671BF449BE92FF008EC64BAB0E9B2BF2ABA3891980683C
          6A7ADB66670D323DF71B634C78541FEF6F71B377AF3A58411E0173DAB7C223CA
          2F8190734359516DFA82B524F0CC980AD7F5B6C9A68C8E73D2B927A781572C87
          1B56FCC255B5FAE7E6B8264F40353EC9A244846D3F69488D65A2A2B66708024D
          0600276180DEF93D997DFA6D2AF7BAF63978FC893C5456EAD1241011653C951A
          553CDCACB7F9AFA9CD1D6ADB3A389F295BBA873DD5BE1B3D052EDCDC452CA698
          0241304EEBC6C5CBC7CC468A56D0B2AD3D63A9DC530020248960F57B15F1F209
          8A27553FE49A298DB36B0AEBD264CA3A1551D2CBFF7C903E20FF8C5C45E73DC9
          29029E3974E9F50930C2BCEE389E287B4926C55B8744461F542EBF6732010D69
          95DBBA035F06BE6A4C036DBACCF6E6B87310DF8E6844F54C47945C58E62424D5
          81FA159C09EE21042FF16EF74B1DA377B83035ACED3AA8DD7D14C0EF33660B5D
          064A44D2BA1670E956B2B77CDF8D7610FA160DE97B0E2DA4D6541E50768257F7
          1B06376CD14F3E089013D874FB84A950F4339340C5AB7DC4C73F746542C8798B
          686FD720BE41BD4A1F53172C47E1A53FED987097052229604F120830235AD6DA
          C9CEEE63A68572986A5390F4FD46D2283DD24EFEEFB277262FE82D709E023AF4
          22A4E08E8C22219EF3CC67A18B6F2C997741F92BD4A8F03D936A3E528FCEBD4C
          EED30C3ECA5FC54CBD09AF18684A7CFE96EEF37D1CB466346BA7815FEB39C3E3
          E0E6FFFBAFE2ABCA055D990AD49A1220A69389B43ED9E3CE83CEFE1BC6994832
          E6DDAF230000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'draw-vertex-only'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000000473424954080808087C086488000000097048597300000DD700000D
          D70142289B780000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000006784944415478DA95966B6C54C715C767EE73
          DFCFEBF59BB860128809C4226030B40E2425401ED04249A18DD254E6131F2ADA
          3CA4144420AD0AEA8B1A290D245288228143084DD22AF503706342828D131381
          91C138B1D7BBB677EDDDF5EEDEBB7BEFCCDC99DE7562A9ADE2849EF97047A3B9
          E7A773E63FE70C648C816F3368D901DBC98E37F08BE8B7E6B6477EC4F6A1C27A
          25AC0C4440C46DF9189EF5DFD9002FC15D2E41961AA04C376240369EC98FDFD1
          43DBD821F929C28B20450573C8C86D5EDC8C9BE47B20D8B9849B775131FC5FCC
          C0CBE15D0B46C1CD2158016A026930BA703D78F0D25A7BC55208E93A5E640F53
          0C97D88BCD68B0D64884EAB5B816D21CA2C4849082B4549F1CCCF6CB813D6FF6
          DFD1AF0D0A07E76F9E10131E09674417279AA95B349FA9C04F56EF357ED80BF7
          DB9A6F5EA7DDF3453660ACF15427FC0BF160D14A1C295BAF8F4B4EC4516ACA8C
          11391FB795E593D06966F38C7761CE16D4A0E0423CC644E638532AEC2106B59D
          FF7385D27C7142CE01097C6E5E89C25AEEFE814170B5BA31B49BCE4B2EE34497
          66088E54325F3C944C0E5555B53B5ECEFDEEE9AA8F79EC08D88A307396A6B240
          2422A04866D37053320991CFFD3558DED12EB8A99D30CFCAA41EB9469919F63E
          079B405B63E8317078DBE95288D4188977A7B8B18F74FEF489ABA2365224BC87
          8F821DEEC78D9AB25056593C999AF3E8F561EC4EF36D07EF5DD49BEB126B8212
          B9F29123406D9829ABB309FB7C55C3983A237F53443D2A37C2BF80F64D150DCE
          E33F68774B8CC61130E39899311C890CD29F35FE3D18F2DACD3D1B1ED362DDC5
          AE584F9194FE3C200EF29F5105DCCDBD8F5F0329E1066DF87E49D8B5448D1344
          1D189BCE02207CB2584009610B3C02DA56F96BECFFD8D1EBFB2F00A0713C35A2
          02415489EC44D434388E51600D6A5CFA27713DF54C4F559C85D9961D733F9E5B
          ED310A4EFF13F0C5F11299A8FCF72C40EB027B89DCFDF370909F0198284E2999
          045361154AB6ACEE0C682A45105892263C8F35D39ABFB8C95F1315C6C09D9BE8
          2D44751E998675E086883096B58CE9EA7FC3E7CE61B4086E12763D50C295B5ED
          68A924F575E5889109139831CB455C4F8F66A9286575874FD3892E08803222C8
          7ADA8A02EF7FA8AC764C8A9A73B64C5C2688F3610C3C0431672102F25E43808D
          2AC231BCE78FF05171E78922AE7CFB70DD59FACEC97DAACD356940F8558AA259
          260859E4F4E7F2B3012AB7C6BB0A29994991A13357577BBA74E046465669EA49
          08805877AFB0E2C303AF3D61AE5E5565E85309539012584711FCD6F39C6F44E9
          40BFFF5365F876007A86F3181A70A33CB50F9FF2F1E770BB6FBA541CF5768C6E
          BDE0F3FBEF4AE90CC7713E3D619E68EAB38F37ADF1BE8E7F038E9F9933B0ACD6
          876603209DB9D514EFA7C4B403C910B531DE137957C9B6E92D55D38057821DD7
          369EF6CE2BAD9FD2675474F3663FDBBCF54C28181471F3E10D518065C1521376
          2BE984281BB95FAC56EA6E817EBAF427B4CBC8F23E206201F2582C9C417A50F4
          8FB706865AF5D6DA2F014AC7BFD61EF5ACF8CE23E9FC0CC052144E475401529D
          DADC06253A40B9B40472291BFFE92555067FD8577E0C3D0FD0F2AEC1FAB54AD4
          64A66D46A6C93E5B60F2035F4F8BDEF2E034E0D7DEA3EDDF7DB6B861DDAF3C1A
          2371FAA54C134C8B654CC8A9794F51260B18B5AA24B5C00C9F6A4E055F793650
          D347BBC0D2359EE1152B2BB206D5394BA602C6481EB9E050C29FE10B3DB87B03
          5C242EBFEF05E9D4E57D641BF860704FCEEBC9212B8282920C753C4329CD218F
          A2E60B792F00ACCB604548F1F6957A5D1CC65843A3D40928E7C698F39988B932
          49E2A96F7E553962FC927D42CECDB55404E6DEC9D7F64D80287F50795D5FFE8C
          0116FC7458156D31941D4F3340F3C8F53F806F92E9D86521D4D59953C2F44682
          303C7F3A4556C3F25820DD2A1BCB442F3BC04CB6A2A671441F717CC232CE01D4
          B83318BF1D40B8D5599EECB5733A21EB3AC1D9FEC2CDFFDA8E76189E5D3862BF
          F2D262F8D0FD47D06EB0F7B07DE8E1ADB6C9D900469EBA6F9C7057AB61711260
          BAAE95B5C6BFB5654228D754F30B7B87693FDC2B1C43F7ACA2E9FB76F74C942C
          1F9D2A005EB000A362C42C5D3FF9E9D557DD8B8D14D78D88FEE30ED6A1DF564F
          FEAAD917591FD204DE373981DFC509F469EFBC29A362FBC5C4F9434BEF3E8FDE
          86844B66DCD873AC8DB43CC7BEC619BC9D57C58CED876F4941DEFBC475FED221
          19FA839DE63B60C4BCF66E9CC636FFDFAF8A6F3237742B3C943A7590130DA66F
          B47C0CCCB6F7DFA69A612EAF200BE80000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'draw-textures'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000000473424954080808087C086488000000097048597300000DD700000D
          D70142289B780000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000005314944415478DA95957B4C535718C0BF7B6F
          DB5B68A122AFA1130A32214142792C4871A2309581402058A386447166231890
          61708465640966FF19FEDA92FDA10989336070313346E431709D980D844528C8
          C3022DAF807D4A4B1FF7DE7DBD4C09A3A03BC949DA73BFF3FDCEF726388E83F7
          59F1F1F17B088290B02CFB726868C8F95E9770115B015252527C9D4EE7619148
          74422010E4318C285822097299CD3362918832E1D94B97CB356CB3D99E23789C
          24C9718661B4FF85BF05A010111717974051D46752A9B4C86EB7C74745ED7304
          0767F8E974326266C60E1E51922460D72E120A0A76004D1B616A6ACA313939B9
          AAD7EB2993C9E4830F32E07EB9B4B464B05AAD5F10F8D27D486F41D33FF2F7F7
          6732323244070E1CA0150A05F8F8F8F070ABD509131366181E7E052323CB70E2
          4424C4C50583BFBF6883D568115CBB760D5A5B5BF18E15506703919494544FD3
          E9DF328C9070BB9F123B76889990901062FFFEFDE49123473CBE87D151235E9A
          808E8E19703ADD6885C7620E02026890CB65B8FDC06EEF833B777E62030303A1
          A1A1816C6969B13537375F261213132F040535FCD0D39383960144475B213454
          8BF43F588BA58D2408038844312C4D87E3EF0FC0641280C3C120844308A0BB1C
          3036769B954A77C3D5AB9F932AD531DE9AC2C2424B4747C779025D51B07367E5
          CF6AF5395F6FC1BE7B770984C201181C1C64FBFBFBB9A9A9694A280CE1483214
          16168639994C41C8E5558446E3445939C4C448F87B870E1D320D0C0C147A00E9
          3259715B6F6F9DC41BA0AB0B203D7DFD3F660A8C8F8F435959195AFA15CCCC64
          A345067E3F781009E1E1625E0E5D6CC104F884484E4E8EA5E98FFBFAFA7EF40A
          686FF7BC66F37971713106F932BC78A17C0BE8EA8A84E06021FF3D3C3C7C6579
          7939C60308A2A830FDE0E0AFB437C0C3870018EB2D01636307DF029E3C8904A9
          94E2BF63B05D068341866102323131C53532F217C9B29B15DDBF0F70F4E8F600
          A7D38400233C7B26E7EBE4C68D11B87245E9361A8D42BED030EF5F9797774A1E
          3F96F02E999F5F5774EF1E4076F6F60097CB93F346E8ECDC03353513F0F4E930
          26C097A6858585001E80119F6B6A6A0A93CBE5FCE5E7CF011E3D5ADB151500B9
          B9DB03DCEE15AC173B2A1562024C4250D01C4C4F974DEB743A390FC0821A6A6C
          6C8C4B4848D8A428379703838183CC4C0EB2B208502A49108BD7015AED41B870
          C18D7202387EDC8215AC85DDBBF558F9E57F6316297840666666777D7D3D7689
          8C4D80FC7C0E03CD621F5ADB34CDF269BBBAFA3D281489505959087BF7023E02
          202767850744444C814673A913019FF20054DC5C5D5DADCACFCFDF04387992C3
          38AC03D63603B1B1BF4049891E6A6B6B79B9A525CF6356794054D4280C0C54DC
          46179DE101696969D78B8A8AAA108259406E009C3DCB618F79376071D1D31E5C
          3C2032F24FE8EDADBA8E1DB59A0760C34B904824CDBEBEBE1F5EBC78D1372F2F
          8FA0E9B5B2387F9E835BB7DE0D989BF358CB4258583FA75617BF5E5D351FC6F6
          FD6CC3C0415016CE82EFF02CB9A4A44478EAD429AAA6C61F6EDE7C3740A7E3A0
          AEEE31D3DE7E7AD1665B396C369BC73DE75E27DABF16D5BBDDEE9CE8E81AAAA7
          2757303F4F6C0970381C505A5A6AEFEEEE1EC13970CC62B1BC7AA38BD86E2623
          28422C167FCD30E4B9C0C04BE4E464AE686242B001802EF5B4E615AD56DB363B
          3B7B1AF5791F99DBADD4D4D44094ABA02841959FDF49E1F2F219B1C3F108CF7F
          03B55A6DC3173762D5D679BBFB5E80374BA954FAA03B4A71947E333B6B0E3599
          F48033FC1C76CDA6ADEEFC2FC09BA552A9288D46A3C234D42F2E2EFEBE9DEC3F
          17CCDD165D3D23700000000049454E44AE426082}
      end>
    Left = 40
    Top = 88
    Bitmap = {}
  end
end
