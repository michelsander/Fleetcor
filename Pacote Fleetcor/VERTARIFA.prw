#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} VerTarifa
Tela para consulta dos valores de ped�gio

@author 	Michel Sander
@since 	02/02/2023
@version P12
/*/

User function VerTarifa(nEixos,lTela,aRegs)

	LOCAL nLin 		:= nCol:= nLinLab := nColLab:= nOpcA :=0
	LOCAL bOk 		:= {|| nOpcA := 1, oDlg:End()}
	LOCAL bCancel	:= {|| nOpcA := 0, oDlg:End()}
   LOCAL nCusto   := 0

	DEFAULT nEixos := 0 
   DEFAULT lTela  := .T.
   DEFAULT aRegs  := {}

   If !lTela
      nCusto := ConsultaTar(@nEixos,@lTela,@aRegs)
      Return ( nCusto )
   EndIf 

   If FWIsInCallStack("U_MNUFLEETCOR") .Or. FWIsInCallStack("U_CADROTAS")
      If SZJ->ZJ_STATUS != 'S'
         ApMsgInfo("Consultar tarifas na Fleetcor s� � permitido para rotas previamente integradas. Transmita a rota primeiramente e tente novamente.")
         Return ( nCusto )
      EndIf 
      If Len(aRegs) == 0
         AADD(aRegs,SZJ->(Recno()))
      EndIf
   EndIf 

   If SetMdiChild()
      nLin:= 25
      nCol:= 61
      nLinLab:= 5.5
      nColLab:= 25
   Else
      nLin:= 25.5
      nCol:= 61
      nLinLab:= 5.5
      nColLab:= 25.5
   EndIf

   DEFINE MsDialog oDlg Title "Ped�gio" FROM 08,10 TO nLin, nCol OF oMainWnd
   oPanel:= TPanel():New(0, 0, "",oDlg,, .F., .F.,,, 40.5, 7.5)
   
   @ 1, 0.5 TO nLinLab, nColLab LABEL " Digite a Qtde. de Eixos do ve�culo " Of oPanel
   @ 30,30 SAY oSay PROMPT "N�mero de Eixos" SIZE 60,10 Of oPanel PIXEL
   @ 28,80 MSGET oEixos VAR nEixos Size 25, 10 Picture "999" Valid nEixos >= 0 Of oPanel	PIXEL
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   oSay:lTransparent := .T.
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   
   If nOpcA == 1 
      nCusto := ConsultaTar(@nEixos,@lTela,@aRegs)
   EndIf 

Return ( nCusto )

/*/{Protheus.doc} ConsultaTar
Processamento da consulta de tarifas

@author 	Michel Sander
@since 	02/02/2023
@version P12
/*/

Static Function ConsultaTar(nEixos,lTela,aRegs)

	LOCAL oIntegra
	LOCAL nCount    := 0
	LOCAL aNodes    := {}
	LOCAL IMAGE1    := "" 	// Imagem quando n�vel estiver fechado
	LOCAL IMAGE2    := "" 	// Imagem quando n�vel estiver aberto
   LOCAL nQ        := 0
   LOCAL aValores  := {}
   LOCAL aTotRotas := {}
   LOCAL nTotPedag := 0 

   For nQ := 1 to Len(aRegs)
      SZJ->(dbGoto(aRegs[nQ]))
      oIntegra := IntegFleetcor():New()
      aValores := oIntegra:IntegTarifas(nEixos)
      If Len(aValores) > 0 
         AADD(aTotRotas, { SZJ->(Recno()), aValores})
      EndIf 
   Next 

   If Len(aTotRotas) == 0
      Help( ' ', 1, "Aten��o", , "N�o foram encontradas rotas transmitidas para esse emitente. N�o ser�o retornados valores de ped�gio", 2, 0, , , , , , {"Verifique se as rotas da tabela de frete est�o transmitidas para a Fleetcor."} )
      Return      
   EndIf 

   IMAGE1  := "" 	// Imagem quando n�vel estiver fechado
   IMAGE2  := "" 	// Imagem quando n�vel estiver aberto

   // Cria a �rvore com o conjunto dos campos da coleta
   If Len(aTotRotas) == 1
      SZJ->(dbGoto(aTotRotas[1,1]))
      nCount++
      IMAGE1 := "TMSIMG32"
      aadd( aNodes, {'00', StrZero(nCount,4), "", "Nome da Rota: "+AllTrim(SZJ->ZJ_NOME), IMAGE1, IMAGE1} )
      nCount++
      IMAGE1 := "PRINT02"
      aadd( aNodes, {'01', StrZero(nCount,4), "", "Qtde. Cupons: "+AllTrim(aTotRotas[1,2,1]), IMAGE1, IMAGE2} )
      nCount++
      IMAGE1 := "ENGINE"
      aadd( aNodes, {'01', StrZero(nCount,4), "", "Qtde. Eixos: "+AllTrim(aTotRotas[1,2,2]), IMAGE1, IMAGE2} )
      nCount++
      IMAGE1 := "CSAIMG32"
      aadd( aNodes, {'01', StrZero(nCount,4), "", "Total de Pedagio: R$ "+AllTrim(Transform(Val(aTotRotas[1,2,3]),X3Picture("E1_VALOR"))), IMAGE1, IMAGE2} )
      nTotPedag := Val(aTotRotas[1,2,3])
   Else 
      nCount++
      IMAGE1 := "TMSIMG32"
      aadd( aNodes, {'00', StrZero(nCount,4), "", "Rotas dispon�veis", IMAGE1, IMAGE1} )
      For nQ := 1 to Len(aTotRotas)
         SZJ->(dbGoto(aRegs[nQ]))
         If Len(aTotRotas[nQ,2]) == 0
            Loop 
         EndIf
         nCount++
         IMAGE1 := "TMSIMG32"
         aadd( aNodes, {'01', StrZero(nCount,4), "", "Nome da Rota: "+AllTrim(SZJ->ZJ_NOME), IMAGE1, IMAGE1} )
         nCount++
         IMAGE1 := "PRINT02"
         aadd( aNodes, {'01', StrZero(nCount,4), "", "Qtde. Cupons: "+AllTrim(aTotRotas[nQ,2,1]), IMAGE1, IMAGE2} )
         nCount++
         IMAGE1 := "ENGINE"
         aadd( aNodes, {'01', StrZero(nCount,4), "", "Qtde. Eixos: "+AllTrim(aTotRotas[nQ,2,2]), IMAGE1, IMAGE2} )
         nCount++
         IMAGE1 := "CSAIMG32"
         aadd( aNodes, {'01', StrZero(nCount,4), "", "Total de Pedagio: R$ "+AllTrim(Transform(Val(aTotRotas[nQ,2,3]),X3Picture("E1_VALOR"))), IMAGE1, IMAGE2} )
         nTotPedag += Val(aTotRotas[nQ,2,3])
      Next 
   EndIf 

   If lTela
   
      DEFINE DIALOG oDlgTar TITLE "Valores de Ped�gio" FROM 180,180 TO 750,1000 PIXEL

      // Cria o objeto Tree
      oTree := DbTree():New(0,0,260,405,oDlgTar,,,.T.)

      // M�todo para carga dos itens da Tree
      oTree:PTSendTree( aNodes )
      oTree:TreeSeek( StrZero(nCount,4) )


      @ 265 , 320 BUTTON oBtn PROMPT "Concluir" SIZE 080, 015 OF oDlgTar ACTION { || oDlgTar:End() } PIXEL
      //oBtn:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")

      ACTIVATE DIALOG oDlgTar CENTERED
   
   Else
      
      ASize(aNodes,0)
      ASize(aTotRotas,0)

   EndIf 

Return nTotPedag
