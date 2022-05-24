//PEDIDOS DE VENDA POR CLIENTE

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'RESTFUL.CH'

WSRESTFUL prorest DESCRIPTION "Pedido de Venda por Cliente"




	WSMETHOD GET;
		DESCRIPTION "Pedido por Cliente";
		PATH "pedidos/";
		WSSYNTAX "pedidos/"





END WSRESTFUL

WSMETHOD GET WSSERVICE prorest


	local lRet          :=  .T.
	local aAray         := {}
    local cResponse     := ""






	cAlias        := GetNextAlias()
    BeginSql Alias cAlias


        
        SELECT A1_COD,A1_NOME,A1_LOJA,COUNT(C5_NUM) C5_NUM,SUM(C6_QTDVEN) C6_QTDVEN,SUM(C6_VALOR) C6_VALOR
         
        FROM %table:SA1% SA1

        INNER JOIN %table:SC5% SC5 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI
	    INNER JOIN %table:SC6% SC6 ON C5_NUM = C6_NUM
        WHERE SC5.%notdel% AND SA1.%notdel% AND SC6.%notdel%	    
	    GROUP BY A1_COD,A1_NOME,A1_LOJA

    EndSql

    IF SetRestFault([200])
        IF (cAlias)->(!Eof())
    	    (cAlias)->(DbGoTop())
    	    While(cAlias)->(!Eof())
    			oObjeto:=JsonObject():New()
                oObjeto['Codigo Produto']:= (cAlias)->A1_COD
    			oObjeto['Nome']:= (cAlias)->A1_NOME
                oObjeto['Loja']:= (cAlias)->A1_LOJA
                oObjeto['Numero Pedido']:= (cAlias)->C5_NUM
                oObjeto['Quantidade Vendida']:= (cAlias)->C6_QTDVEN     
                
    			Aadd(aAray, oObjeto)               

    			(cAlias)->(DbSkip())

    		ENDDO
        
    	    self:SetContentType('application/json')
    		cResponse := FWJsonSerialize(aAray, .F.,.F.,.T.)
    		::SetResponse(cResponse)

    		(cAlias)->(DbCloseArea())
            
            
        ENDIF
    
    ELSE        
        SetRestFault(404,"Digitou errado")            
        lRet := .F.
        
    	
    ENDIF



Return lRet
