#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"

/*/{Protheus.doc} M460FIM

Ponto de entrada no final da geracao da NF Saida, utilizado
para gravacao de dados adicionais.

@type function
@author Deivid A. C. de Lima
@since 19/04/2010

/*/
User Function M460FIM()

	//Executa o Wizard do Acelerador de Mensagens da NF no final da geração da NF de Saída
	If ExistBlock("MSGNF02",.F.,.T.)
		ExecBlock("MSGNF02",.F.,.T.,{})
	Endif

	// grava os dados complementares dos itens da nota fiscal de saída
	If ExistBlock("GRVCOMD2",.F.,.T.)
		ExecBlock("GRVCOMD2",.F.,.T.,{SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA})
	Endif
	
	// grava os dados complementares dos itens da nota fiscal de saída
	If ExistBlock("HISTMOEDA",.F.,.T.)
		ExecBlock("HISTMOEDA",.F.,.T.,{"SAIDA", SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA})
	Endif

	// grava os dados complementares nos títulos a receber
	If ExistBlock("GRVEXE1",.F.,.T.)
		ExecBlock("GRVEXE1",.F.,.T.,{SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_TIPO, SF2->F2_EST})
	Endif

	// Grava os dados da nota para integração da viagem com Fleetcor
	If ExistBlock("GRVVIAGEM",.F.,.T.)
		ExecBlock("GRVVIAGEM",.F.,.T.,{})
	Endif

Return
