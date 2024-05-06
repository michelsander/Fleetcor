#INCLUDE "protheus.ch"
#INCLUDE 'FwMvcDef.ch'

#DEFINE MVC_TITLE "Rotas "
#DEFINE MVC_ALIAS "SZJ"
#DEFINE MVC_VIEWDEF_NAME "VIEWDEF.CADROTAS"
#DEFINE MVC_MAIN_ID "CADROTAS"
#DEFINE MODEL_CABEC "SZJMASTER"
#DEFINE MOD_DADOS 1
#DEFINE MOD_INTER 2

/*/{Protheus.doc} CADROTAS
Cadastro de Rotas de Viagem 

@author Michel Sander
@since  25/09/2022
@version 1.0
/*/

User Function CADROTAS()

	Private oBrowse
	Private aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( MVC_ALIAS )
   oBrowse:AddLegend("Empty(ZJ_STATUS)" ,'YELLOW' ,'Não enviada')
   oBrowse:AddLegend("ZJ_STATUS == 'N'" ,'RED' ,'Erro de Envio')
   oBrowse:AddLegend("ZJ_STATUS == 'S'" ,'GREEN' ,'Rota Integrada')
   oBrowse:SetMenuDef("CADROTAS")
	oBrowse:SetDescription( MVC_TITLE )
	oBrowse:Activate()

Return

/*/{Protheus.doc} MENUDEF
Menu principal

@author Michel Sander
@since  25/09/2022
@version 1.0
/*/

Static Function MenuDef()

	Local aRotina   := {}

	ADD OPTION aRotina TITLE "Pesquisar"   ACTION "VIEWDEF.Pesq" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"  ACTION MVC_VIEWDEF_NAME OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"     ACTION MVC_VIEWDEF_NAME OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"     ACTION MVC_VIEWDEF_NAME OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"     ACTION MVC_VIEWDEF_NAME OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Transmitir"  ACTION "U_INTROTA()"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Pedagios" 	ACTION "U_VERTARIFA()" OPERATION 2 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Montagem do modelo dados para MVC

@return 	oModel - Objeto do modelo de dados
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function ModelDef()
	
   LOCAL aOrigem  := aDestino := {}
	Local oStruSZJ := FWFormStruct(MOD_DADOS,"SZJ", /*bAvalCampo*/,/*lViewUsado*/ )
	local oModel := MPFormModel():New('MCADROTAS', ,{|oModel| ValidPos(oModel)} ,/*{|oModel| SZJCommit(oModel)}*/, )	
	
	aOrigem := FwStruTrigger(;
		"ZJ_MUNORI" ,;
		"ZJ_DESORI" ,;
		"CC2->CC2_MUN",;
		.T. ,;
		"CC2" ,;
		1 ,;
		"xFilial('CC2')+M->ZJ_UFORIGE+M->ZJ_MUNORI" ,;
		NIL ,;
		"01" )

	aDestino := FwStruTrigger(;
		"ZJ_MUNDES" ,;
		"ZJ_DESCDES" ,;
		"CC2->CC2_MUN",;
		.T. ,;
		"CC2" ,;
		1 ,;
		"xFilial('CC2')+M->ZJ_UFDESTI+M->ZJ_MUNDES" ,;
		NIL ,;
		"01" )


	oStruSZJ:AddTrigger( aOrigem[1] , 	aOrigem[2] , aOrigem[3] , aOrigem[4] )
	oStruSZJ:AddTrigger( aDestino[1] ,	aDestino[2] , aDestino[3] , aDestino[4] )
	oStruSZJ:SetProperty("ZJ_DESORI",MODEL_FIELD_INIT, { || If(!INCLUI,Posicione("CC2",1, xFilial("CC2")+SZJ->ZJ_UFORIGE+PadR(SZJ->ZJ_MUNORI,TamSx3("CC2_CODMUN")[1]),"CC2_MUN"),"")})
	oStruSZJ:SetProperty("ZJ_DESCDES",MODEL_FIELD_INIT, { || If(!INCLUI,Posicione("CC2",1, xFilial("CC2")+SZJ->ZJ_UFDESTI+PadR(SZJ->ZJ_MUNDES,TamSx3("CC2_CODMUN")[1]),"CC2_MUN"),"")})

	oModel:AddFields('SZJMASTER', /*cOwner*/, oStruSZJ, /*ValidPre*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( MVC_TITLE )
	oModel:GetModel( 'SZJMASTER' ):SetDescription( MVC_TITLE )
	oModel:SetPrimaryKey({'ZJ_FILIAL', 'ZJ_CODIGO' })

Return oModel

/*/{Protheus.doc} ViewDef
Visão dos Dados

@return 	oView - Objeto da view, interface
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/
Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'CADROTAS' )
	Local oStruSZJ := FWFormStruct( MOD_INTER, 'SZJ' )
	Local oView    := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "VIEW_SZJ", oStruSZJ, 'SZJMASTER')

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oStrSZJ:SetProperty('ZJ_DESORI', MVC_VIEW_INIBROW ,Posicione("CC2",1, xFilial("CC2")+SZJ->ZJ_UFORIGE+PadR(SZJ->ZJ_MUNORI,TamSx3("CC2_CODMUN")[1]),"CC2_MUN"))
		oStrSZJ:SetProperty('ZJ_DESCDES', MVC_VIEW_INIBROW ,Posicione("CC2",1, xFilial("CC2")+SZJ->ZJ_UFDESTI+PadR(SZJ->ZJ_MUNDES,TamSx3("CC2_CODMUN")[1]),"CC2_MUN"))
	EndIf

	oView:CreateHorizontalBox( "TELA" , 100 )
	oView:SetOwnerView( "VIEW_SZJ","TELA" )
	oView:SetDescription( MVC_TITLE )

Return oView

/*/{Protheus.doc} ValidPos
Função para validação do municipio

@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function ValidPos(oModel)

	LOCAL lValid  := .T.
	LOCAL nOper   := oModel:GetOperation()
   LOCAL cUFOri  := oModel:GetValue('SZJMASTER','ZJ_UFORIGE')
   LOCAL cUFDes  := oModel:GetValue('SZJMASTER','ZJ_UFDESTI')   
	LOCAL cMunOri := oModel:GetValue('SZJMASTER','ZJ_MUNORI')
	LOCAL cMunDes := oModel:GetValue('SZJMASTER','ZJ_MUNDES')

   If nOper == 3 .Or. nOper == 4
      CC2->(dbSetOrder(1))
      If !CC2->(dbSeek(xFilial()+cUfOri+cMUnOri)) .And. !Empty(cUfOri) .And. !Empty(cMunOri)
         Help( ' ', 1, "Atenção", , "Esse município de ORIGEM não pertence a esse estado ou o registro não existe no cadastro de municípios.", 2, 0, , , , , , {"Verifique o cadastro de municípios tabela CC2."} )
         lValid := .F.
      EndIf
      CC2->(dbSetOrder(1))
      If !CC2->(dbSeek(xFilial()+cUfDes+cMUnDes)) .And. !Empty(cUfDes) .And. !Empty(cMunDes)
         Help( ' ', 1, "Atenção", , "Esse município de DESTINO não pertence a esse estado ou o registro não existe no cadastro de municípios.", 2, 0, , , , , , {"Verifique o cadastro de municípios tabela CC2."} )
         lValid := .F.
      EndIf
   EndIf

Return lValid

/*/{Protheus.doc} INTROTA
Função para integração da Rota

@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

User Function INTROTA()

	If ApMsgYesNo("Deseja transmitir essa rota para a FLEETCOR?","FLEETCOR")
		FWMsgRun(, { || U_intFleetcor("SZJ") }, "FLEETCOR", "Integrando Rota..." )
	EndIf

Return
