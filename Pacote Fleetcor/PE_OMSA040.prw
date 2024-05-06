#INCLUDE "Protheus.ch"

/*/{Protheus.doc} OMSA040
Ponto de Entrada após a gravação do cadastro de motoristas

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function OMSA040()

	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ''
	Local cIdPonto := ''
	Local cIdModel := ''
   Local aAreas := { GetArea(), DA4->(GetArea()) }

	If aParam <> NIL
		oObj 		:= aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		If cIdPonto == 'FORMCOMMITTTSPOS'  .And. ( INCLUI .Or. ALTERA )
         If ApMsgYesNo("Deseja transmitir o cadastro desse motorista para a Fleetcor nesse momento?","Integração Fleetcor")
			   xRet := U_intFleetcor("DA4")
         EndIf
		EndIf
	EndIf 

   AEval( aAreas, {|x| RestArea(x)})

Return xRet
