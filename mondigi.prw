#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL mondigi DESCRIPTION "Monitor MarktPlace"


    WSMETHOD GET shopee;
        DESCRIPTION "Contador de Pedidos em Processamento Shoope";
        PATH "shopee";
        WSSYNTAX "localhost/mondigi/shopee"

    WSMETHOD GET mercado;
        DESCRIPTION "Contador de Pedidos em Processamento Shoope";
        PATH "mercado";
        WSSYNTAX "localhost/mondigi/mercado"

    WSMETHOD GET magalu;
        DESCRIPTION "Contador de Pedidos em Processamento Shoope";
        PATH "magalu";
        WSSYNTAX "localhost/mondigi/magalu"

    WSMETHOD GET unipop;
        DESCRIPTION "Contador de Pedidos em Processamento Shoope";
        PATH "unipop";
        WSSYNTAX "localhost/mondigi/unipop"


    WSMETHOD GET erro;
        DESCRIPTION "Contador de Pedidos com Erro de Integracao";
        PATH "erro";
        WSSYNTAX "localhost/mondigi/erro"

    WSMETHOD GET produtos;
        DESCRIPTION "Contador de produtos mais vendidos dia "; 
        PATH "produtos";
        WSSYNTAX "localhost/mondigi/produtos"

    END WSRESTFUL


WSMETHOD GET produtos WSSERVICE mondigi

    local lRet                  := .T.
    local cAlias3               := GetNextAlias()
    local oRetorno              := ""
    local aArea                 := GetArea()
    local nposs                 := 1

              
    self:SetContentType('application/json')

    BEGINSQL Alias cAlias3

    SELECT TOP 6 D2_COD CODIGO,B1_DESC,SUM(D2_TOTAL) VALOR_TOTAL,SUM(D2_QUANT) QUANTIDADE
    FROM SD2990 AS SD2
    INNER JOIN SB1990 SB1 ON B1_COD = D2_COD
    WHERE D2_EMISSAO = '20220429'  AND D2_FILIAL = '05'
    AND D2_TIPO = 'N'
    AND SD2.D_E_L_E_T_ = ''
    GROUP BY D2_COD,B1_DESC,D2_QUANT
    ORDER BY D2_QUANT DESC
    ENDSQL


    IF (cAlias3)->(!EOF())
        (cAlias3)->(DbGoTop())

            WHILE nposs <= 1
    	        private oRecebe:=JsonObject():New()
                oRecebe['produto1']     := (cAlias3)->B1_DESC
                (cAlias3)->(DbSkip())
                oRecebe['produto2']     := (cAlias3)->B1_DESC
                (cAlias3)->(DbSkip())
                oRecebe['produto3']     := (cAlias3)->B1_DESC
                (cAlias3)->(DbSkip())
                oRecebe['produto4']     := (cAlias3)->B1_DESC
                (cAlias3)->(DbSkip())
                oRecebe['produto5']     := (cAlias3)->B1_DESC
                (cAlias3)->(DbSkip())
                oRecebe['produto6']     := (cAlias3)->B1_DESC
                nposs:= 2 
            ENDDO  
        oRetorno :=oRecebe:toJson() 
        self:SetResponse(EncodeUTF8(oRetorno))	  
        lRet := .T.
    ELSE
        lRet := .F.
    ENDIF        
        (cAlias3)->(DBCLOSEAREA())
        RestArea(aArea)


Return lRet

WSMETHOD GET erro WSSERVICE mondigi

    local lRet          := .T.
    local cResponse     := ""
    local aArea         := GetArea()
    local oObjId 		:= JsonObject():New() 
    local cAlias2       := GetNextAlias()
    local cid3          := ""

    self:SetContentType('application/json')


        cid3 := "5"
        BeginSql Alias cAlias2
            SELECT 
                COUNT(ZA8_STATUS) ZA8_STATUS
            FROM
                %table:ZA8% ZA8
            WHERE
                ZA8_STATUS = %Exp:cid3% 
            
        ENDSQL

        IF (cAlias2)->(!Eof())
            oObjId['erro'] 	:= (cAlias2) -> ZA8_STATUS
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	
        ELSE
            lRet := .F.
            SetRestFault(490,ENCODEUTF8( "Erro no Sistema Verifique se o Serviço esta ligado",))
        ENDIF
	
	    (cAlias2)->(DbCloseArea())
	    RestArea(aArea)


Return lRet
    
            

WSMETHOD GET shopee WSSERVICE mondigi

    local lRet          := .T.
    local cResponse     := ""
    local aArea         := GetArea()
    local oObjId 		:= JsonObject():New() 
    local cAlias        := GetNextAlias()

    self:SetContentType('application/json')
    

        cid1 := "C"
        cid2 := "10072022"
        BeginSql Alias cAlias
            SELECT 
                COUNT(ZA8_STATUS) ZA8_STATUS
            FROM
                %table:ZA8% ZA8
            WHERE
                CONVERT(VARCHAR,CONVERT(DATE,ZA8_DTAPRO),103) >= %Exp:cid2% AND ZA8_STATUS = %Exp:cid1% AND ZA8_NMKT LIKE '%shopee%'      
                GROUP BY ZA8_STATUS
            
        ENDSQL

        IF (cAlias)->(!Eof())
            oObjId['shopee'] 	:= (cAlias) -> ZA8_STATUS
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	
        ELSE
            lRet := .F.
            SetRestFault(490,ENCODEUTF8( "Status não Localizado",))
        ENDIF
	
	    (cAlias)->(DbCloseArea())
	    RestArea(aArea)

Return lRet





WSMETHOD GET mercado WSSERVICE mondigi

    local lRet          := .T.
    local cResponse     := ""
    local aArea         := GetArea()
    local oObjId 		:= JsonObject():New() 
    local cAlias4        := GetNextAlias()
    local cFalha        := "NÃO TEM PEDIDO NO MOMENTO"

    self:SetContentType('application/json')
    

        cid1 := "C"
        cid2 := "10072022"
        BeginSql Alias cAlias4
            SELECT 
                COUNT(ZA8_STATUS) ZA8_STATUS
            FROM
                %table:ZA8% ZA8
            WHERE
                CONVERT(VARCHAR,CONVERT(DATE,ZA8_DTAPRO),103) >= %Exp:cid2% AND ZA8_STATUS = %Exp:cid1% AND ZA8_NMKT LIKE '%Mercado%'      
                GROUP BY ZA8_STATUS  
            
        ENDSQL

        IF (cAlias4)->(!Eof())
            oObjId['mercado'] 	:= (cAlias4) -> ZA8_STATUS
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	
        ELSE
            oObjId['mercado']   := cFalha
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	

        ENDIF
	
	    (cAlias4)->(DbCloseArea())
	    RestArea(aArea)

Return lRet


WSMETHOD GET magalu WSSERVICE mondigi

    local lRet          := .T.
    local cResponse     := ""
    local aArea         := GetArea()
    local oObjId 		:= JsonObject():New() 
    local cAlias5        := GetNextAlias()
    local cFalha        := "NÃO TEM PEDIDO NO MOMENTO"

    self:SetContentType('application/json')
    

        cid1 := "C"
        cid2 := "10072022"

        BeginSql Alias cAlias5

            SELECT 
                COUNT(ZA8_STATUS) ZA8_STATUS
            FROM
                %table:ZA8% ZA8
            WHERE 
                CONVERT(VARCHAR,CONVERT(DATE,ZA8_DTAPRO),103) >= %Exp:cid2% AND ZA8_STATUS = %Exp:cid1% AND ZA8_NMKT LIKE '%Magazine Luiza%'      
            GROUP BY ZA8_STATUS  
            
        ENDSQL

        IF (cAlias5)->(!Eof())
            oObjId['magalu'] 	:= (cAlias5) -> ZA8_STATUS
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	
        ELSE
            oObjId['magalu']   := cFalha
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	

        ENDIF
	
	    (cAlias5)->(DbCloseArea())
	    RestArea(aArea)

Return lRet



WSMETHOD GET unipop WSSERVICE mondigi

    local lRet          := .T.
    local cResponse     := ""
    local aArea         := GetArea()
    local oObjId 		:= JsonObject():New() 
    local cAlias6        := GetNextAlias()
    local cFalha        := "NÃO TEM PEDIDO NO MOMENTO"

    self:SetContentType('application/json')
    

        cid1 := "C"
        cid2 := "10072022"

        BeginSql Alias cAlias6

            SELECT 
                COUNT(ZA8_STATUS) ZA8_STATUS
            FROM
                %table:ZA8% ZA8
            WHERE 
                CONVERT(VARCHAR,CONVERT(DATE,ZA8_DTAPRO),103) >= %Exp:cid2% AND ZA8_STATUS = %Exp:cid1% AND ZA8_NMKT LIKE '%unipop%'      
            GROUP BY ZA8_STATUS  
            
        ENDSQL

        IF (cAlias6)->(!Eof())
            oObjId['unipop'] 	:= (cAlias6) -> ZA8_STATUS
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	
        ELSE
            oObjId['unipop']   := cFalha
            cResponse :=oObjId:toJson()
            self:SetResponse(EncodeUTF8(cResponse))	

        ENDIF
	
	    (cAlias6)->(DbCloseArea())
	    RestArea(aArea)

Return lRet





