#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GFEA061A
Ponto de Entrada para adicionar opção na tarifa da negociação de frete

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function GFEA61F1()
   
   LOCAL aItem := {}

   Aadd(aItem,	{ OemToAnsi("Pedágios"), "U_EmitenPed()" , 0, 4, 0, NIL} )

Return aItem
