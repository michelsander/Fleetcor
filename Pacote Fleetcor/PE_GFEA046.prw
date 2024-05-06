#INCLUDE "Protheus.ch"

/*/{Protheus.doc} GFEA046
Ponto de Entrada após a gravação do veículo no GFE

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function GFEA046()

	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ''
	Local cIdPonto := ''
	Local cIdModel := ''
   Local aAreas := { GetArea(), GU8->(GetArea()) }

	If aParam <> NIL
		oObj 		:= aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		If cIdPonto == 'FORMCOMMITTTSPOS' .And. ( INCLUI .Or. ALTERA )
         If ApMsgYesNo("Deseja transmitir o veículo para Fleetcor nesse momento?","Integração Fleetcor")
			   xRet := U_intFleetcor("GU8")
         EndIf
		EndIf
	EndIf 

   AEval( aAreas, {|x| RestArea(x)})

Return xRet
