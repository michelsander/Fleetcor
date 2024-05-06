#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} GFEA523
Integração Fleetcor

@author    Michel Sander
@since     19/01/2023
@version 1.0		
*/

User Function MnuFleetcor()

	Local aCoors := FWGetDialogSize(oMainWnd)

	Private oFWLayer, oPnlFilters, oPnlBrowses
	Private oPnlArquivos 
	Private oDlgOPC, oBtnPadrao, oBtnInstr, cPlaca, oPanelEntr
	Private aLMostrarDefault := {.T., .F., .F., .F. }
	Private aLMostrar		 := {.T., .F., .F., .F. }
	Private cCodUsr 		 := RetCodUsr() //Código usuario
	Private aGrpUsr 		 := UsrRetGrp() //Grupos do qual o usuário faz parte.
	Private aPontos 		 := {"Viagens","Localidades","Transportadoras","Motoristas","Rotas","Veículos"}
	Private cProcessos 	 := "1" //Ponto de controle selecionado
   Private cCadastro     := cFil_Ok := cFil_Err := cFil_Wait := cFiltro := cAliasBrw := ""
	Private oFWLayerPri
	Private oPanelSair
	Private oBrowse

	DEFINE MsDialog oDlgOPC Title "Monitor de Integrações- FLEETCOR" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oDlgOPC:Activate(,,,.T.,,,{|| CriaTela() })
	
Return Nil

/*{Protheus.doc} CriaTela
Monta a tela de apresentação da integração Fleetcor

@author    Michel Sander
@since     19/01/2023
@version 1.0		
*/

Static Function CriaTela()

	Local oCombo, oPanel

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgOPC,.F.)

	oFWLayer:AddLine('LINE_ALL',100,.F.)
	oFWLayer:AddCollumn('COL_LEFT',22,.T.,'LINE_ALL')
	oFWLayer:AddWindow('COL_LEFT', 'Win_left', 'Opções', 100, .F., .F.,{|| },'LINE_ALL',{|| })
	oFWLayer:AddCollumn('COL_RIGHT',78,.T.,'LINE_ALL')
	oFWLayer:AddWindow('COL_RIGHT', 'Win_Right', 'Integrações Fleetcor', 100, .F., .F.,{|| },'LINE_ALL',{|| })

	oPnlFilters := oFWLayer:GetWinPanel('COL_LEFT', 'Win_left','LINE_ALL')
   oPnlBrowses := oFWLayer:GetColPanel('COL_RIGHT', 'LINE_ALL')
   oPnlBrowses := oFWLayer:GetWinPanel('COL_RIGHT', 'Win_Right','LINE_ALL')
	oPnlArquivos := TPanel():New(0,0,,oPnlBrowses,,,,,,oPnlBrowses:NWIDTH,oPnlBrowses:NHEIGHT,,)
	oPnlArquivos:Align := CONTROL_ALIGN_ALLCLIENT

	// -- Margens Esquerda x Direita
	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),2,2,,)
	oPanel:Align := CONTROL_ALIGN_LEFT

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),2,2,,)
	oPanel:Align := CONTROL_ALIGN_RIGHT

	oPnlFilters := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,5,,)
	oPnlFilters:Align := CONTROL_ALIGN_ALLCLIENT

	// ----- Margem Superior
	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,5,,)
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanelSair := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),60,10,,)
	oPanelSair:Align := CONTROL_ALIGN_BOTTOM

	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,10,,)
	oPanel:Align := CONTROL_ALIGN_BOTTOM

	oQuit := TButton():New(0, 0, "Sair", oPanelSair, {|| oDlgOPC:End() }, 23, 10, , )
	oQuit:Align := CONTROL_ALIGN_RIGHT
	oQuit:SetColor(RGB(002,070,112),)

	// ----- Combo de Processos
   oPanel := TPanel():New(0,0,,oPnlFilters,,,,,RGB(239,243,247),100,15,,)
   oPanel:Align := CONTROL_ALIGN_TOP
   oCombo := TComboBox():New(0,0, {|u|If(PCount()>0,cProcessos:=u,cProcessos)},aPontos,150,15,oPanel,,{|| ItChgCombo(@oCombo)})

   oPanel := TPanel():New(0,60,,oPanel,,,,,RGB(239,243,247),25,10,,)
   oPanel:Align := CONTROL_ALIGN_RIGHT

	// ----- Botão Trocar
	oPanelEntr := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),100,20,,)
	oPanelEntr:Align := CONTROL_ALIGN_TOP
	
	oFont := TFont():New ("Arial", , -12, , .T., , , , , .F., .F. )
	oSay := TSay():New (010, 0, {|| "Filtrar" }, oPanelEntr, , oFont, , , , .T., CLR_BLUE, , 100, 10, ,,,,, .T. )
	oSay:lTransparent := .T.

	// ---- Checkboxes
	oPanel := TPanel():New(0,60,,oPnlFilters,,,,,RGB(239,243,247),20,150,,)
	oPanel:Align := CONTROL_ALIGN_TOP

	oFontChk := TFont():New ("Tahoma", , -11, , .F., , , , , .F., .F. )
	oChk := TCheckBox():New( 010, 0, "Todos", {|u| If(PCount()>0,aLMostrar[1]:=u,aLMostrar[1]) }, oPanel, 100,10,,{|| Checkbox_Click() },,,,,,.T.)
	oChk := TCheckBox():New( 025, 0, "Aguardando Transmissão", {|u| If(PCount()>0,aLMostrar[2]:=u,aLMostrar[2]) }, oPanel, 100,10,,{|| Checkbox_Click() },,,,,,.T.)
	oChk := TCheckBox():New( 040, 0, "Transmitidos", {|u| If(PCount()>0,aLMostrar[3]:=u,aLMostrar[3]) }, oPanel, 100,10,,{|| Checkbox_Click() },,,,,,.T.)
	oChk := TCheckBox():New( 055, 0, "Erros", {|u| If(PCount()>0,aLMostrar[4]:=u,aLMostrar[4]) }, oPanel, 100,10,,{|| Checkbox_Click() },,,,,,.T.)
	oBtnPadrao := TButton():New(070,0, "Aplicar", oPanel, {|| BtnAplicar(@oCombo,@aLMostrar) }, 50, 10,,,,.T.,,,,)

	// ------- Browses
   FwMsgRun(NIL, {|| CriaBrw(1) }, 'Aguarde....', 'Carregando browse' )
	
Return Nil

/*{Protheus.doc} Checkbox_Click
Valida o checkbox

@author    Michel Sander
@since     19/01/2023
@version 1.0		
*/

Static Function Checkbox_Click()

	If  aLMostrar[1] == aLMostrarDefault[1] .AND. ;
		aLMostrar[2] == aLMostrarDefault[2] .AND. ;
		aLMostrar[3] == aLMostrarDefault[3] .And. ;
      aLMostrar[4] == aLMostrarDefault[4] .And. ;      
		oBtnPadrao:Disable()
	Else
		oBtnPadrao:Enable()
	EndIf

Return Nil

/*{Protheus.doc} BtnAplicar
Aplicar filtro no browse

@author    Michel Sander
@since     19/01/2023
@version 1.0		
*/

Static Function BtnAplicar(oCombo,aLMostrar)

	If aLMostrar[1] .Or. ( aLMostrar[2] .And. aLMostrar[3] .And. aLMostrar[4])
		cFiltro := cFil_Wait + ".OR. " + cFil_Ok + " .OR. " + cFil_Err
	Else
		If aLMostrar[2] .And. aLMostrar[3]
			cFiltro := cFil_Wait + ".OR. " + cFil_Ok
		ElseIf aLMostrar[2] .And. aLMostrar[4]
			cFiltro := cFil_Wait + ".OR. " + cFil_Err
		ElseIf aLMostrar[3] .And. aLMostrar[4]	
			cFiltro := cFil_Ok + ".OR. " + cFil_Err
		ElseIf aLMostrar[2] .And. ( !aLMostrar[3] .And. !aLMostrar[4] )
			cFiltro := cFil_Wait
		ElseIf aLMostrar[3] .And. ( !aLMostrar[2] .And. !aLMostrar[4] )
			cFiltro := cFil_Ok
		ElseIf aLMostrar[4] .And. ( !aLMostrar[2] .And. !aLMostrar[3] )
			cFiltro := cFil_Err
		EndIf 
	EndIf

	// -- Remonta Browses
	oBrowse:Destroy()
	FreeObj( oBrowse )
   FwMsgRun(NIL, {|| CriaBrw(oCombo:nAt)}, 'Aguarde....', 'Carregando browse' )

Return 

/*{Protheus.doc} CriaBrw
Cria o browse no segundo painel

@author    Michel Sander
@since     19/01/2023
@version 1.0		
*/

Static Function CriaBrw(nBrowse)

   Do Case 
      Case nBrowse == 1 
           cCadastro := "Viagens"
           cAliasBrw := "SZV"
			  cFil_Ok   := "SZV->ZV_INTEGRA == 'I'"
			  cFil_Err  := "SZV->ZV_INTEGRA == 'E'"
			  cFil_Wait := "Empty(SZV->ZV_INTEGRA) .Or. SZV->ZV_INTEGRA == 'N'"
      Case nBrowse == 2 
           cCadastro := "Localidades"
           cAliasBrw := "CC2"
			  cFil_Ok   := "!Empty(CC2->CC2_ZZCODL)"
			  cFil_Err  := "Empty(CC2->CC2_ZZCODL)"
			  cFil_Wait := "Empty(CC2->CC2_ZZCODL)"
      Case nBrowse == 3 
           cCadastro := "Transportadoras"
           cAliasBrw := "SA4"
			  cFil_Err  := "SA4->A4_ZZINTEG == 'N'"
			  cFil_Ok   := "SA4->A4_ZZINTEG == 'S'"
			  cFil_Wait := "Empty(SA4->A4_ZZINTEG)"
      Case nBrowse == 4 
           cCadastro := "Motoristas"
           cAliasBrw := "DA4"
			  cFil_Err  := "DA4->DA4_ZZINTE == 'N'"
			  cFil_Ok   := "DA4->DA4_ZZINTE == 'S'"
			  cFil_Wait := "Empty(DA4->DA4_ZZINTE)"
      Case nBrowse == 5 
           cCadastro := "Rotas"
           cAliasBrw := "SZJ"
			  cFil_Err  := "SZJ->ZJ_STATUS == 'N'"
			  cFil_Ok   := "SZJ->ZJ_STATUS == 'S'"
			  cFil_Wait := "Empty(SZJ->ZJ_STATUS)"
      Case nBrowse == 6 
           cCadastro := "Veículos"
           cAliasBrw := "GU8"
			  cFil_Ok   := "GU8->GU8_ZZINTE == 'S'"
		 	  cFil_Err  := "GU8->GU8_ZZINTE == 'N'"
			  cFil_Wait := "GU8->GU8_ZZINTE == ' '"
   End Case

	If Empty(cFiltro)
	   cFiltro := cFil_Wait + " .OR. " + cFil_Ok + " .OR. " + cFil_Err
	EndIf 

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias(cAliasBrw)
	oBrowse:DisableDetails()
	oBrowse:DisableConfig()
	oBrowse:DisableLocate()
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetFilterDefault(cFiltro)
   oBrowse:SetDescription(cCadastro)

	If nBrowse == 1 			// Viagens
		oBrowse:AddLegend("Empty(ZV_SITUACA) .or. ZV_SITUACA == 'ABE'" ,'GREEN' ,'Viagem em Aberto')
		oBrowse:AddLegend("ZV_SITUACA == 'PRO'" ,'BLUE' 	,'Viagem Programada')
		oBrowse:AddLegend("ZV_SITUACA == 'AGE'" ,'YELLOW' 	,'Viagem Agendada')
		oBrowse:AddLegend("ZV_SITUACA == 'AND'" ,'VIOLET' 	,'Viagem em Andamento')
		oBrowse:AddLegend("ZV_SITUACA == 'CAN'" ,'RED' 		,'Viagem Cancelada')
		oBrowse:AddLegend("ZV_SITUACA == 'ENC'" ,'BLACK' 	,'Viagem Encerrada')
      oBrowse:AddButton( "Visualizar", { || (cAliasBrw)->(AxVisual(cAliasBrw,(cAliasBrw)->(Recno()),2)) },,2,, .F., 2 )
		oBrowse:AddButton( "Transmitir", { || U_intFleetcor("SZV"), oBrowse:Refresh() },,2,, .F., 2 )
	ElseIf nBrowse == 2		// Localidades
		oBrowse:AddLegend("Empty(CC2_ZZCODL)"  ,'RED'   ,'Não enviada ou Erro de Transmissão')
		oBrowse:AddLegend("!Empty(CC2_ZZCODL)" ,'GREEN' ,'Localidade Integrada')
      oBrowse:AddButton( "Visualizar", { || (cAliasBrw)->(AxVisual(cAliasBrw,(cAliasBrw)->(Recno()),2)) },,2,, .F., 2 )
		oBrowse:AddButton( "Transmitir", { || U_intFleetcor("CC2") },,2,, .F., 2 )
		oBrowse:AddButton( "Transm. Lote", { || U_intFleetcor("CC2",.T.), oBrowse:Refresh() },,2,, .F., 2 )
	ElseIf nBrowse == 3		// Transportadoras
		oBrowse:AddLegend("Empty(A4_ZZINTEG)",'YELLOW' ,'Não enviada')
		oBrowse:AddLegend("A4_ZZINTEG == 'N'" ,'RED' ,'Erro de Envio')
		oBrowse:AddLegend("A4_ZZINTEG == 'S'" ,'GREEN' ,'Transportadora Integrada')
      oBrowse:AddButton( "Visualizar", { || (cAliasBrw)->(AxVisual(cAliasBrw,(cAliasBrw)->(Recno()),2)) },,2,, .F., 2 )
		oBrowse:AddButton( "Transmitir", { || U_intFleetcor("SA4"),oBrowse:Refresh() },,2,, .F., 2 )
	ElseIf nBrowse == 4		// Motoristas
		oBrowse:AddLegend("Empty(DA4_ZZINTE)",'YELLOW' ,'Não enviada')
		oBrowse:AddLegend("DA4_ZZINTE == 'N'" ,'RED' ,'Erro de Envio')
		oBrowse:AddLegend("DA4_ZZINTE == 'S'" ,'GREEN' ,'Motorista Integrado')
      oBrowse:AddButton( "Visualizar", { || (cAliasBrw)->(AxVisual(cAliasBrw,(cAliasBrw)->(Recno()),2)) },,2,, .F., 2 )
		oBrowse:AddButton( "Transmitir", { || U_intFleetcor("DA4"), oBrowse:Refresh() },,2,, .F., 2 )
	ElseIf nBrowse == 5 		// Rotas
		oBrowse:AddLegend("Empty(ZJ_STATUS)" ,'YELLOW' ,'Não enviada')
		oBrowse:AddLegend("ZJ_STATUS == 'N'" ,'RED' ,'Erro de Envio')
		oBrowse:AddLegend("ZJ_STATUS == 'S'" ,'GREEN' ,'Rota Integrada')
      oBrowse:AddButton( "Visualizar", { || (cAliasBrw)->(AxVisual(cAliasBrw,(cAliasBrw)->(Recno()),2)) },,2,, .F., 2 )
		oBrowse:AddButton( "Transmitir", { || U_intFleetcor("SZJ"), oBrowse:Refresh() },,2,, .F., 2 )
		oBrowse:AddButton( "Pedágios"  , { || U_VerTarifa(), oBrowse:Refresh() },,2,, .F., 2 )
	ElseIf nBrowse == 6 		// Veículos
      oBrowse:AddLegend("GU8->GU8_ZZINTE=='S'", "GREEN",  "Transmitido")
      oBrowse:AddLegend("GU8->GU8_ZZINTE=='N'", "RED"  ,  "Erro de Transmissão")
      oBrowse:AddLegend("GU8->GU8_ZZINTE==' '", "YELLOW", "Aguardando Transmissão")
      oBrowse:AddButton( "Visualizar", { || (cAliasBrw)->(AxVisual(cAliasBrw,(cAliasBrw)->(Recno()),2)) },,2,, .F., 2 )
		oBrowse:AddButton( "Transmitir", { || U_intFleetcor("GU8"), oBrowse:Refresh() },,2,, .F., 2 )
   EndIf 

	oBrowse:SetOwner(oPnlArquivos)
	oBrowse:Activate()

Return

/*{Protheus.doc} ItChgCombo
Remonta o browse de acordo com a escolha do usuário

@author    Michel Sander
@since     19/01/2023
@version 1.0		
*/

Static Function ItChgCombo(oCombo)

	// -- Remonta Browses
	oBrowse:Destroy()
	FreeObj( oBrowse )
   FwMsgRun(NIL, {|| CriaBrw(oCombo:nAt)}, 'Aguarde....', 'Carregando browse' )
	
Return
