#include 'protheus.ch'
#Include 'FWMVCDef.ch'
#include 'topconn.ch'

#DEFINE TITULO      "Monitor Viagens"
#DEFINE ALIAS_CAB   "SZV"
#DEFINE MVC_MAIN_ID "CADVIAGEM"

#DEFINE MODEL_CABEC "SZVMASTER"

//-------------------------------------------------------------------
/*/{Protheus.doc} CADVIAGEM
Monitor de Viagens

@type       Function
@author     Julio Lisboa
@since      24/06/2022
/*/
//-----------------------------------------------------------------]--
User Function CADVIAGEM()

	Private oBrowse
	Private aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( ALIAS_CAB )
	oBrowse:SetDescription( TITULO )
	oBrowse:AddLegend("Empty(ZV_SITUACA) .or. ZV_SITUACA == 'ABE'" ,'GREEN' ,'Viagem em Aberto')
	oBrowse:AddLegend("ZV_SITUACA == 'PRO'" ,'BLUE' 	,'Viagem Programada')
	oBrowse:AddLegend("ZV_SITUACA == 'AGE'" ,'YELLOW' 	,'Viagem Agendada')
	oBrowse:AddLegend("ZV_SITUACA == 'AND'" ,'VIOLET' 	,'Viagem em Andamento')
	oBrowse:AddLegend("ZV_SITUACA == 'CAN'" ,'RED' 		,'Viagem Cancelada')
	oBrowse:AddLegend("ZV_SITUACA == 'ENC'" ,'BLACK' 	,'Viagem Encerrada')
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina   := {}

	ADD OPTION aRotina Title 'Transmitir'		          Action 'U_INTVIAGEM()'			   OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'                  Action "VIEWDEF.CADVIAGEM"      OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'                  Action "VIEWDEF.CADVIAGEM"      OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'               Action "VIEWDEF.CADVIAGEM"      OPERATION 2 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCab 		:= FWFormStruct(1, ALIAS_CAB )
	Local oModel

	oModel := MPFormModel():New('PECADVIA',,,)
	oModel:AddFields( MODEL_CABEC ,, oStruCab)
	oModel:GetModel(MODEL_CABEC ):SetDescription('Cabeçalho')
	oModel:SetDescription(TITULO)
	oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 		:= FWLoadModel( MVC_MAIN_ID )
	Local oStruCab 		:= FWFormStruct(2, ALIAS_CAB )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('CABEC', oStruCab, MODEL_CABEC)
	oView:EnableTitleView('CABEC','Cabeçalho')

Return oView

/*/{Protheus.doc} INTVIAGEM
Função para integração da Viagem

@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

User Function INTVIAGEM()

	LOCAL oIntegra
	oIntegra := IntegFleetcor():New()
	FWMsgRun(, { || oIntegra:IntegViagem() }, "FLEETCOR", "Integrando Viagem..." )

Return
