#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GFEA061F
Ponto de Entrada na inclusão de tarifas na negociação da tabela de frete

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function GFEA061F()

	Local oModel
   Local aParam   := PARAMIXB
	Local xRet     := .T.
	Local cIdPonto := ''
	Local cIdModel := ''
   Local aAreas   := { GetArea(), GV1->(GetArea()) }
	Local nLinha   := 0

	cIdPonto := AllTrim(aParam[2])
	cIdModel := AllTrim(aParam[3])

	If aParam <> NIL

      If cIdPonto == 'MODELPRE'
			If FWIsInCallStack("U_EMITENPED")
				oModel := FWModelActive()
				oModelGrid := oModel:GetModel("DETAIL_GV1")
				For nLinha := 1 To oModelGrid:Length()
					If AllTrim(oModelGRID:GetValue("GV1_CDCOMP")) == 'PEDAGIO'
						oModelGrid:SetValue( 'GV1_VLUNIN',nCustoPed )
						oModelGrid:SetValue( 'GV1_VLFRAC',1 )
					EndIf
				Next
			EndIf 
		EndIf
	
	EndIf 

   AEval( aAreas, {|x| RestArea(x)})

Return xRet
