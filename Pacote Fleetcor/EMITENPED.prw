#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} EmitenPed
Rotina para varrer rotas do emitente da tabela de frete

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function EmitenPed()

   LOCAL cChave      := GV9->GV9_CDEMIT
   LOCAL aRecno      := {}
   
   PRIVATE nCustoPed := 0

   // Varre as rotas para atualiza��o Fleetcor
   U_VarreRotas(@cChave,@aRecno)
   FWMsgRun(, {|| nCustoPed := U_VerTarifa(,.T.,@aRecno) }, "Aguarde", "Consultando FLEETCOR...")

   If nCustoPed > 0
      If ApMsgYesNo("Deseja atualizar as tarifas do ped�gio?","FLEETCOR")
         FWExecView('Altera��o de Tarifas','GFEA061F', MODEL_OPERATION_UPDATE )
      EndIf 
   EndIf 

Return
