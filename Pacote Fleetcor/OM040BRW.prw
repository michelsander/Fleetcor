#INCLUDE "Protheus.CH"

/*/{Protheus.doc} OM040BRW
Opção no browse para Transmissão Fleetcor

@type       Function
@author     Michel Sander
@since      19/01/2023
/*/

User Function OM040BRW()

   LOCAL aRotInc := {}

   If FindFunction("U_intFleetcor")
      aAdd( aRotInc, { "Transmitir"  , 'U_intFleetcor("DA4")' , 0, 2, 0, .T. } )
   EndIf

Return aRotInc
