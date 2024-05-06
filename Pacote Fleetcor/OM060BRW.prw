#INCLUDE "Protheus.CH"

/*/{Protheus.doc} OM060BRW
Op��o no browse para Transmiss�o Fleetcor

@type       Function
@author     Michel Sander
@since      19/01/2023
/*/

User Function OM060BRW()

   LOCAL aRotInc := {}

   If FindFunction("U_intFleetcor")
      aAdd( aRotInc, { "Transmitir"  , 'U_intFleetcor("GU8")' , 0, 2, 0, .T. } )
   EndIf

Return aRotInc
