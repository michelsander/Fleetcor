#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GRVVIAGEM
Grava a viagem para integração com Fleetcor

@type    function
@author  Michel Sander
@since   08/02/2023
/*/

User Function GRVVIAGEM()

   LOCAL oIntegra 
   LOCAL aAreas := { GetArea(), SF2->(GetArea()), SA1->(GetArea()) }
   
   //Gravação da viagem caso haja carga no pedido
   If SC5->C5_TPCARGA == "1"
      oIntegra := IntegFleetcor():New()
      oIntegra:GravaViagem()
   EndIf

   AEval( aAreas, {|x| RestArea(x)})

Return
