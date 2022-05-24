//RETORNO DE CLIENTES

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

WSRESTFUL wsc DESCRIPTION "Consulta de Clientes" 
    WSDATA id AS STRING OPTIONAL

    WSMETHOD GET DESCRIPTION "Retorno de Clientes";
    PATH "/wsc"

    WSMETHOD GET GetbyId DESCRIPTION "Retorna Apenas um Cliente";
    WSSYNTAX "/wsc/{id}";
    PATH "/wsc/{id}"


END WSRESTFUL


// Retorno de Todos os Clientes 
WSMETHOD GET WSSERVICE wsc
    local lRet              := .T.  // Deixa a Mensagem de 
    //local cErro             := ""
    
    local aTasks            := {}

    ::SetContentType("application/json")
    

    cAlias := GetNextAlias()
    cQuery := " SELECT "
    cQuery += "    SA1.A1_COD, "
    cQuery += "    SA1.A1_NOME "
    cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
    cQuery += " WHERE "
    cQuery += "        SA1.A1_FILIAL   = '" + xFilial("SA1") + "' "
    cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery(cQuery,cAlias)

    if(cAlias)->(!Eof())
        While(cAlias)->(!Eof())
            oTask:=JsonObject():New()
            oTask['code']:= (cAlias)->A1_COD
            oTask['description']:= (cAlias)->A1_NOME
            AAdd(aTasks,oTask)

            (cAlias)->(DbSkip())
            
        ENDDO
        cResponse := FWJsonSerialize(aTasks, .F.,.F.,.T.)
        ::SetResponse(cResponse)
        
    ELSE
        cResponse := FWJsonSerialize(aTasks, .F.,.F.,.T.)
        ::SetResponse(cResponse)
    ENDIF

    (cAlias)->(DbCloseArea())
Return lRet
    

    




