#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} restfor
	(WebService REST para realização de métodos GET,POST,PUT E DELETE dentro do Microsiga Protheus)
	Protheus 12.1.27 e 12.1.33
	@type  Function
	@author Marcio GOnzaga
	@since 23/05/2022
	@version 1.3	
	@return Todos os Fornecedores / Apenas um Fornecedor / Fornecedor Apartir de uma data / Fornecedor de Codigo ate Codigo
	 / Criar novo Fornecedor 	/ Alterar Fornecedor /  Deletar Fornecedor
	@example

		(Metodo GET) 				(localhost:8080/rest33/restfor/fornecedores/") 	Listar Todos os Fornecedor 
		(Metodo GET)				(localhost:8080/rest/restfor/fornecedor/00003") Retornar apenas um Fornecedor 
		(Metodo GET)				(localhost:8080/rest/restfor/fornecedor/par/000001/000090") Retornar Fornecedor do Codigo 01 a o 90
		(Metodo GET)				(localhost:8080/rest/restfor/fornecedor/data) Retornar Fornecedor de uma data ate outra data passando o Json		
		(Metodo POST Envia o JSON )	(localhost:8080/rest/restfor/fornecedor/novo") 	Criar novo Fornecedor 
		(Metodo PUT  Envia o JSON )	(localhost:8080/rest/restfor/fornecedor/00003") Atualiza Fornecedor apartir de um codigo
		(Metodo Delete ) 			(localhost:8080/rest/restfor/fornecedor/00003") Deleta o Fornecedor 
		
	@see (links_or_references)
		https://tdn.totvs.com/pages/viewpage.action?pageId=185747842
		https://tdn.totvs.com/display/framework/02.+Criando+uma+classe+REST
		https://medium.com/@rullyalves/o-que-s%C3%A3o-apis-e-requisi%C3%A7%C3%B5es-http-919238f48206
/*/


//METODOS DA API 
::SetHeader('Access-Control-Allow-Credentials' , "true")

WSRESTFUL restfor DESCRIPTION "Consulta de Fornecedores"
	::SetHeader('Access-Control-Allow-Credentials' , "true")
	WSDATA id  AS STRING OPTIONAL
	WSDATA codigo  AS INTEGER OPTIONAL
	WSDATA codigo2  AS INTEGER OPTIONAL

	WSMETHOD  GET;
		DESCRIPTION "TODOS OS FORNECEDORES";
		PATH "fornecedores/";
		WSSYNTAX "[METODO GET] - localhost:8080/rest/restfor/fornecedores/"

	WSMETHOD GET GetById;
		DESCRIPTION "Retornar apenas um Fornecedor";
		PATH "fornecedor/{id}";
		WSSYNTAX "[METODO GET] - localhost:8080/rest/restfor/fornecedor/{id}"

	WSMETHOD GET GetByData;
		Description "Retornar Fornecedores apartir de uma data";
		PATH "fornecedor/data";
		WSSYNTAX "[METODO GET] - localhost:8080/rest/restfor/fornecedor/data

		/* Precisar passar o Json pelo Body
		{
  		"DATA": "20080401",
  		"DATA2": "20090917"
		}
		*/

	WSMETHOD GET GetByPar;
		Description "Retorna Fornecedor Apartir de um codigo ate outro codigo passado via URL";
		PATH "fornecedor/par/{codigo}/{codigo2}";
		WSSYNTAX "[METODO GET] - localhost:8080/rest/restfor/fornecedor/par/{codigo}/{codigo2}"
		

	WSMETHOD POST;
		DESCRIPTION "Criar Fornecedor";
		PATH "fornecedor/novo";
		WSSYNTAX "[METODO POST ENVIAR JSON] - localhost:8080/rest/restfor/fornecedor/novo"

		/* Exemplo Envio JSON 
		localhost:8080/rest/restfor/fornecedor/novo
		{
		  "codigo": "000022",
		  "loja": "01",
		  "nome": "Camus",
		  "fantasia": "Aquario",
		  "endereco": "AVENIDA",
		  "tipo": "J",
		  "estado": "SP",
		  "municipio": "SAO PAULO"
		}
		
		*/


	WSMETHOD DELETE;
		DESCRIPTION "Excluir Fornecedor";
		PATH "fornecedor/{id}";
		WSSYNTAX "[METODO DELETE] - localhost:8080/rest/restfor/fornecedor/{id}";

	WSMETHOD PUT;
		DESCRIPTION "Atualizar Fornecedor";
		PATH "fornecedor/{id}";
		WSSYNTAX "[METODO PUT ENVIAR JSON] - localhost:8080/rest/restfor/fornecedor/{id}";

		/* Exemplo Envio JSON 
		localhost:8080/rest/restfor/fornecedor/000012
		{
  			"nome": "Degel",
  			"fantasia": "Aquario",
  			"endereco": "11 Casa",
  			"tipo": "J",
  			"estado": "SP",
  			"municipio": "SAO PAULO"
		}

		*/

END WSRESTFUL

// Retorna Fornecedor de um Codigo ate o outro Codigo
WSMETHOD GET GetByPar PATHPARAM codigo,codigo2 WSSERVICE restfor

	local lRet          :=  .T. 
	local codigo     	:= self:aURLParms[3]
    local codigo2       := self:aURLParms[4]		
	local aArray        := {}		
	local oObjParms		:=JsonObject():New()	
	local cResponse     := ""			
	local aArea 		:= GetArea()
	local cAlias		:= GetNextAlias()

	self:SetContentType('application/json')	
	        
	BeginSql Alias cAlias
        SELECT
            A2_NOME,
            A2_COD,
			A2_END,
			A2_LOJA
        FROM
        	%table:SA2% SA2
        WHERE
            A2_FILIAL = %xFilial:SA2% AND SA2.%notDel% 
			AND A2_COD >=  %Exp:codigo% AND A2_COD <=  %Exp:codigo2%
	ENDSQL

	IF (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		
		While(cAlias)->(!Eof())	
			oObjParms		:=JsonObject():New()				
			oObjParms['Codigo de: ']		:= (cAlias)->A2_COD
			oObjParms['Codigo ate: ']		:= (cAlias)->A2_COD			
			oObjParms['Nome:']				:= (cAlias)->A2_NOME
			oObjParms['Endereço:']			:= (cAlias)->A2_END
			oObjParms['Loja:']				:= (cAlias)->A2_LOJA
			Aadd(aArray, oObjParms)
			(cAlias)->(DbSkip())			
		ENDDO
		
		cResponse := FWJsonSerialize(aArray, .F.,.F.,.T.)
		self:SetResponse(EncodeUTF8(cResponse))
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	ELSE
		lRet := .F.
        SetRestFault(490,EncodeUTF8("Verifique se os Codigos informados existem "))
	ENDIF
Return lRet



//Retorna Fornecedores Apartir de uma data 
WSMETHOD GET GetByData WSSERVICE restfor

	local lRet          :=  .T. 		
	local aArray        := {}			
	local cResponse     := ""			
	local aArea 		:= GetArea()
	Local oPegaJson		:= JsonObject():New()
	local cAlias2		:= GetNextAlias()
	private cid,cid2
	
	oPegaJson:fromJson(self:GetContent())
	cid := "%" + oPegaJson['DATA'] + "%"
	cid2 := "%" + oPegaJson['DATA2'] + "%"
	

	BeginSql Alias cAlias2
            SELECT
                A2_NOME,
                A2_COD,
				A2_END,
				A2_LOJA,
				A2_DTAVA
            FROM
                %table:SA2% SA2
            WHERE
                A2_FILIAL = %xFilial:SA2% AND SA2.%notDel% 
				AND A2_DTAVA >=  %Exp:cid% AND A2_DTAVA <=  %Exp:cid2%
	ENDSQL

	IF (cAlias2)->(!Eof())
		(cAlias2)->(DbGoTop())
		
		While(cAlias2)->(!Eof())			
			private oObjDat:=JsonObject():New()
			oObjDat['Codigo']							:= (cAlias2)->A2_COD
			oObjDat['Nome']								:= (cAlias2)->A2_NOME
			oObjDat['Endereço']							:= (cAlias2)->A2_END
			oObjDat['Loja']								:= (cAlias2)->A2_LOJA
			oObjDat['Data da Avaliacao de ']			:= dtoc(sTod((cAlias2)->A2_DTAVA))
			oObjDat['Data da Avaliacao ate']			:= dtoc(sTod((cAlias2)->A2_DTAVA))
			Aadd(aArray, oObjDat)
			(cAlias2)->(DbSkip())			
		ENDDO

		self:SetContentType('application/json')
		cResponse := FWJsonSerialize(aArray, .F.,.F.,.T.)
		self:SetResponse(EncodeUTF8(cResponse))
		(cAlias2)->(DbCloseArea())
		RestArea(aArea)
	ENDIF

Return lRet



//RETORNA APENAS UM FORNECEDOR
WSMETHOD GET GetById PATHPARAM id WSSERVICE restfor
	local lRet 			:= .T.
	Local Codigo		:= Upper(AllTrim(::id))					
	local oObjId 		:= JsonObject():New() 	
	local cAlias3 		:= GetNextAlias()		 
	local aArea 		:= GetArea()			
	
	Self:SetContentType("application/json")

	cid := ::id
	If SA2->(DbSeek(XFilial("SA2") + Codigo))
							
		BeginSql Alias cAlias3
			SELECT A2_COD,A2_NOME,A2_END,A2_BAIRRO,A2_MUN,A2_CGC,A2_TEL,A2_NROCOM,A2_TEL,A2_SALDUP,A2_ULTCOM,A2_MCOMPRA,A2_SALDUP FROM %table:SA2% SA2 
			WHERE A2_FILIAL = %xFilial:SA2% AND A2_COD = %Exp:cid% AND SA2.%notDel%
		ENDSQL
	
		IF (cAlias3)->(!Eof())
			oObjId['codigo'] 				:= (cAlias3) -> A2_COD
			oObjId['nome'] 					:= (cAlias3) -> A2_NOME
			oObjId['endereco'] 				:= (cAlias3) -> A2_END
			oObjId['bairro'] 				:= (cAlias3) -> A2_BAIRRO
			oObjId['municipio'] 			:= (cAlias3) -> A2_MUN
			oObjId['cnpj'] 					:= Transform((cAlias3) -> A2_CGC, "@E 999.999.999-99")
			oObjId['telefone'] 				:= (cAlias3) -> A2_TEL	
			oObjId['qtdcompras'] 			:= (cAlias3) -> A2_NROCOM
			oObjId['ultcompra'] 			:= Transform((cAlias3) -> A2_ULTCOM, "@E 99/99/9999")					
			oObjId['maiorcompra'] 			:= AllTrim(Transform((cAlias3) -> A2_MCOMPRA, "@E 999,999,999.99"))
			oObjId['saldotitulos'] 			:= (cAlias3) -> A2_SALDUP

			cResponse :=oObjId:toJson()
			self:SetResponse(EncodeUTF8(cResponse))	
		ENDIF
	ELSE
		lRet := .F.
        SetRestFault(490,EncodeUTF8("Codigo: " + Codigo + "  Não localizado"))
	ENDIF	
	(cAlias3)->(DbCloseArea())
	RestArea(aArea)

Return lRet




//Retornar Todos os Fornecedores
WSMETHOD GET WSSERVICE restfor

	local lRet          :=  .T. 		
	local aArray        := {}			
	local cResponse     := ""			
	local aArea 		:= GetArea()
	local cAlias4       := GetNextAlias() 


	BeginSql Alias cAlias4
            SELECT 
                A2_NOME,A2_COD,A2_END,A2_LOJA 
			FROM %table:SA2% SA2
            WHERE A2_FILIAL = %xFilial:SA2% AND SA2.%notDel%
	ENDSQL

	IF (cAlias4)->(!Eof())
		(cAlias4)->(DbGoTop())
		
		While(cAlias4)->(!Eof())			
			private oObjTodos:=JsonObject():New()
			oObjTodos['Codigo:']		:= (cAlias4)->A2_COD
			oObjTodos['Nome:']			:= (cAlias4)->A2_NOME
			oObjTodos['Endereço:']		:= (cAlias4)->A2_END
			oObjTodos['Loja:']			:= (cAlias4)->A2_LOJA
			Aadd(aArray, oObjTodos)
			(cAlias4)->(DbSkip())			
		ENDDO

		self:SetContentType('application/json')
		cResponse := FWJsonSerialize(aArray, .F.,.F.,.T.)
		self:SetResponse(EncodeUTF8(cResponse))
		(cAlias4)->(DbCloseArea())
		RestArea(aArea)
	ENDIF

Return lRet


// Criando novo Fornecedor 

WSMETHOD POST WSREST restfor

    Local oResponse:= JsonObject():New()
	oRequest:= JsonObject():New()
	oRequest:fromJson(self:GetContent())
	Self:SetContentType("application/json")
	
	 

	oModel:= FwLoadModel("MATA020")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
	
    oModel:GetModel('SA2MASTER'):SetValue("A2_COD"    , oRequest["codigo"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_LOJA"   , oRequest["loja"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_NOME"   , oRequest["nome"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_NREDUZ" , oRequest["fantasia"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_END"    , oRequest["endereco"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_TIPO"   , oRequest["tipo"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_EST"    , oRequest["estado"])
    oModel:GetModel('SA2MASTER'):SetValue("A2_MUN"    , oRequest["municipio"])

    If (oModel:VldData() .and. oModel:CommitData())
        lRet := .T.
		oResponse['Codigo: ' + oRequest['codigo'] + ' || ' +  oRequest['nome'] ]:= ' incluido com Sucesso'
		Self:SetResponse(oResponse:toJSON())
        		
    Else
        lRet := .F.
        aError := oModel:GetErrorMessage()
        cRetorno := "ERRO|" + aError[4] + aError[5] + " | " + aError[6] + " | " + aError[7]
        SetRestFault(400, (EncodeUTF8(cRetorno)))
    EndIf

    oModel:DeActivate()


Return lRet


// Alterando Fornecedor
WSMETHOD PUT WSSERVICE restfor 
	local lRet 				:= .T. 							
	Local oResponse     	:= JsonObject():New()		
	Local oRequest  		:= JsonObject():New()
	Local oModel    		:= FwLoadModel("MATA020")
	local aArea 			:= GetArea()
	Local cAtFornecedor	   	:= PadL(Upper(AllTrim(::id)),6,"0")	

	Self:SetContentType('application/json')
	
	If SA2->(DbSeek(XFilial("SA2") + cAtFornecedor))
		oRequest:fromJson(self:GetContent())
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()     

    	oModel:GetModel('SA2MASTER'):SetValue("A2_NOME"   , oRequest["nome"])
    	oModel:GetModel('SA2MASTER'):SetValue("A2_NREDUZ" , oRequest["fantasia"])
    	oModel:GetModel('SA2MASTER'):SetValue("A2_END"    , oRequest["endereco"])
    	oModel:GetModel('SA2MASTER'):SetValue("A2_TIPO"   , oRequest["tipo"])
    	oModel:GetModel('SA2MASTER'):SetValue("A2_EST"    , oRequest["estado"])
    	oModel:GetModel('SA2MASTER'):SetValue("A2_MUN"    , oRequest["municipio"])
		
		If (oModel:VldData() .and. oModel:CommitData())
            lRet := .T.
			oResponse['Codigo: ' + cAtFornecedor ]:= ' Alterado com Sucesso'
			Self:SetResponse(oResponse:toJSON())

        Else
            lRet 		:= .F.
            aError 		:= oModel:GetErrorMessage()
            cRetorno 	:= "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
            SetRestFault(400, (EncodeUTF8(cRetorno)))
        EndIf
      
    Else
		oResponse['Codigo: ' + cAtFornecedor ]:= ' Não Localizado'
		Self:SetResponse(EncodeUTF8(oResponse:toJSON()))		
    EndIf

	oModel:DeActivate()
	RestArea(aArea)

Return lRet

//Deletando Fornecedor
WSMETHOD DELETE PATHPARAM id WSREST restfor
	local cDelFornecedor   := PadL(Upper(AllTrim(::id)),6,"0") 
	local oResponse 	:= JsonObject():New()				
	Local oModel    	:= FwLoadModel("MATA020")			
	local lRet			:= .T.
	local aArea 		:= GetArea()						
	
	::SetContentType("application/json")


	IF SA2->(DbSeek(xFilial("SA2") + cDelFornecedor))
		oModel:SetOperation(MODEL_OPERATION_DELETE)		
		oModel:Activate()

		if(oModel:VldData() .and. oModel:CommitData())
			lRet := .T.
			oResponse["Fornecedor | " + cDelFornecedor ]			:= "Removido com Sucesso"			
			Self:SetResponse(EncodeUTF8(oResponse:toJSON()))

		else
			lRet := .F.
			aError := oModel:GetErrorMessage()
			cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
			SetRestFault(400, cRetorno)
		EndIf
		oModel:Deactivate()
	else
		
		oResponse['Codigo: ' + cDelFornecedor ]:= ' Não Localizado'
		Self:SetResponse(EncodeUTF8(oResponse:toJSON()))
	ENDIF
	
	RestArea(aArea)					
	
		
Return lRet

