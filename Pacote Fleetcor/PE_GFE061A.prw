#INCLUDE "Protheus.ch"

/*/{Protheus.doc} GFEA061A
Ponto de Entrada na negociação da tabela de frete

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function GFEA061A()

	Local aParam   := PARAMIXB
	Local xRet     := .T.
	Local cIdPonto := ''
	Local cIdModel := ''
	Local aRecno   := {}
   Local aAreas   := { GetArea(), GV8->(GetArea()) }
	LOCAL oModelAtivo

	cIdPonto := aParam[2]
	cIdModel := aParam[3]

	If aParam <> NIL

		If cIdPonto == 'FORMCOMMITTTSPOS'

			oModelAtivo := FWModelActive() 
			cChave := oModelAtivo:GetValue( "GFEA061A_GV9", 'GV9_CDEMIT' )
			If Empty(cChave) 
				Return xRet 
			EndIf 

			// Varre as rotas para atualização Fleetcor
			U_VarreRotas(@cChave,@aRecno)

		EndIf
	
	EndIf 

   AEval( aAreas, {|x| RestArea(x)})

Return xRet

/*/{Protheus.doc} VarreRotas
Rotina para verificar as rotas e atualizar Fleetcor

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function VarreRotas(cChave,aRecno,nNrRota)

	LOCAL aRotas   := {}
	Local nQ 		:= 0
	LOCAL nRecno   := 0 

	If !GV8->(dbSeek(xFilial()+cChave))
		Return
	EndIf

	// Verifica as rotas da negociação do frete
	While GV8->(!Eof()) .and. GV8->GV8_FILIAL+GV8->GV8_CDEMIT == xFilial("GV8")+cChave
	   If AllTrim(GV8->GV8_NRROTA) != AllTrim(GV6->GV6_NRROTA)
			GV8->(dbSkip())
			loop
		EndIf 
		If GV8->GV8_TPORIG != '1' .And. GV8->GV8_TPDEST != '1'
			GV8->(dbSkip())
			loop
		EndIf 
		If Empty(GV8->GV8_NRCIOR) .Or. Empty(GV8->GV8_NRCIDS)
			GV8->(dbSkip())
			loop
		EndIf
		AADD(aRotas, { GV8->GV8_NRCIOR, GV8->GV8_NRCIDS, GV8->(Recno()) } )
		If GV8->GV8_DUPSEN == '1'
			AADD(aRotas, { GV8->GV8_NRCIDS, GV8->GV8_NRCIOR, GV8->(Recno()) } )
		EndIf 
		GV8->(dbSkip())
	End 

	If Len(aRotas) == 0 
		Return
	EndIf 

	For nQ := 1 to Len(aRotas)
		nRecno := fGetLocalidade(aRotas[nQ])
		If nRecno > 0 
		   AADD(aRecno,nRecno)
		EndIf 
	Next

Return

/*/{Protheus.doc} fGetLocalidade
Atualiza o cadastro de Rotas para Fleetcor

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

Static Function fGetLocalidade(aRotaUso)
	
	LOCAL aRotAux 	 := { "ORI", "", "", "", "", "DES", "", "", "", "" }
	LOCAL cAliasCC2 := GetNextAlias()
	LOCAL nRegister := 0

	BEGINSQL Alias cAliasCC2 

		SELECT "ORI" CC2_TIPO, CC2.CC2_FILIAL, CC2.R_E_C_N_O_ CC2_REC 
		FROM %Table:CC2% CC2
		WHERE CC2_FILIAL = %Exp:xFilial("CC2")%
			AND CC2_ZZCDIB = %Exp:aRotaUso[1]% 
			AND CC2_ZZCODL != ''
			AND CC2.%NotDel%
		UNION 
		SELECT "DES" CC2_TIPO, CC2_FILIAL, CC2.R_E_C_N_O_ CC2_REC 
		FROM %Table:CC2% CC2
		WHERE CC2_FILIAL = %Exp:xFilial("CC2")%
			AND CC2_ZZCDIB = %Exp:aRotaUso[2]%
			AND CC2_ZZCODL != ''
			AND CC2.%NotDel%

	ENDSQL

	If (cAliasCC2)->(Eof())
		Help( ,,"ATENÇÃO",,"Localidades não transmitidas para a Fleetcor."+CRLF+CRLF+"Localidade Origem  "+aRotaUso[1]+CRLF+"Localidade Destino "+aRotaUso[2], 1, 0 )
		(cAliasCC2)->(dbCloseArea())
		Return 
	EndIf 

	While (cAliasCC2)->(!EOf()) 
		CC2->(dbGoto((cAliasCC2)->CC2_REC))
		If (cAliasCC2)->CC2_TIPO == "ORI"
			aRotAux[2]  := CC2->CC2_EST
			aRotAux[3]  := CC2->CC2_CODMUN
			aRotAux[4]  := CC2->CC2_MUN
			aRotAux[5]  := CC2->CC2_ZZCDIB
		Else
			aRotAux[7]  := CC2->CC2_EST
			aRotAux[8]  := CC2->CC2_CODMUN
			aRotAux[9]  := CC2->CC2_MUN
			aRotAux[10] := CC2->CC2_ZZCDIB
		EndIf 
		(cAliasCC2)->(dbSkip())
	End

	BEGIN TRANSACTION 

		SZJ->(dbSetOrder(2))
		If Len(aRotAux) > 0
			If !SZJ->(dbSeek(xFilial("SZJ")+aRotAux[2]+SubStr(aRotAux[3],1,5)+aRotAux[7]+SubStr(aRotAux[8],1,5)))
				Reclock("SZJ",.T.)
				SZJ->ZJ_FILIAL  := xFilial("SZJ")
				SZJ->ZJ_UFORIGE := aRotAux[2]
				SZJ->ZJ_MUNORI	 := aRotAux[3]
				SZJ->ZJ_UFDESTI := aRotAux[7]
				SZJ->ZJ_MUNDES	 := aRotAux[8]	
				SZJ->ZJ_NOME    := AllTrim(aRotAux[4])+'-'+AllTrim(aRotAux[9])
				SZJ->ZJ_STATUS  := "N"
				SZJ->(MsUnlock())
				U_intFleetcor("SZJ")
			EndIf
			If !Empty(SZJ->ZJ_CODROT)
			   If GV8->(FieldPos("GV8_ZZNRFL")) > 0
					GV8->(dbGoto(aRotaUso[3]))
					Reclock("GV8",.F.)
					GV8->GV8_ZZNRFL := SZJ->ZJ_CODROT
					GV8->(MsUnlock())
				EndIf 
				nRegister := SZJ->(Recno())
			EndIf 
		EndIf
	
	END TRANSACTION

	(cAliasCC2)->(dbCloseArea())

Return nRegister
