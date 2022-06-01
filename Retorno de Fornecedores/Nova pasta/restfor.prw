#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} restfor
	(WebService REST para realização de métodos GET,POST,PUT E DELETE dentro do Microsiga Protheus)
	Protheus 12.1.27 e 12.1.33
	@type  Function
	@author Marcio GOnzaga
	@since 23/05/2022
	@version 1.1	
	@return Todos os Fornecedores / Apenas um Fornecedor / Criar novo Fornecedor / Alterar Fornecedor /  Deletar Fornecedor
	@example

		(Metodo GET) 				(localhost:8080/rest33/restfor/fornecedores/") 	Listar Todos os Fornecedor 
		(Metodo GET)				(localhost:8080/rest/restfor/fornecedor/00003") Retornar apenas um Fornecedor 
		(Metodo POST Envia o JSON )	(localhost:8080/rest/restfor/fornecedor/novo") 	Criar novo Fornecedor 
		(Metodo PUT  Envia o JSON )	(localhost:8080/rest/restfor/fornecedor/att") 	Atualiza Fornecedor
		(Metodo Delete ) 			(localhost:8080/rest/restfor/fornecedor/00003") Deleta o FOrnecedor 
		
	@see (links_or_references)
		https://tdn.totvs.com/pages/viewpage.action?pageId=185747842
		https://tdn.totvs.com/display/framework/02.+Criando+uma+classe+REST
		https://medium.com/@rullyalves/o-que-s%C3%A3o-apis-e-requisi%C3%A7%C3%B5es-http-919238f48206
/*/


//METODOS DA API 

WSRESTFUL restfor DESCRIPTION "Consulta de Fornecedores"
	WSDATA id  AS STRING OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "TODOS OS FORNECEDORES";
		PATH "fornecedores/";
		WSSYNTAX "[METODO GET] - localhost:8080/rest/restfor/fornecedores/"

	WSMETHOD GET GetById;
		DESCRIPTION "Retornar apenas um Fornecedor";
		PATH "fornecedor/{id}";
		WSSYNTAX "[METODO GET] - ocalhost:8080/rest/restfor/fornecedor/{id}"


	WSMETHOD POST;
		DESCRIPTION "Criar Fornecedor";
		PATH "fornecedor/novo";
		WSSYNTAX "[METODO POST ENVIAR JSON] - localhost:8080/rest/restfor/fornecedor/novo"

	WSMETHOD DELETE;
		DESCRIPTION "Excluir Fornecedor";
		PATH "fornecedor/{id}";
		WSSYNTAX "[METODO DELETE] - localhost:8080/rest/restfor/fornecedor/{id}";

	WSMETHOD PUT;
		DESCRIPTION "Atualizar Fornecedor";
		PATH "fornecedor/att";
		WSSYNTAX "[METODO PUT ENVIAR JSON] - localhost:8080/rest/restfor/fornecedor/att";


END WSRESTFUL


// Retornar todos os Fornecedores
WSMETHOD GET WSSERVICE restfor

	local lRet          :=  .T. 		//Variavel de Retorno do Metodo GET
	local aArray         := {}			//Array para adicionar o Objeto Json
	local cResponse     := ""			//Variavel de Retorno para o usuário 
	local aArea 		:= GetArea()	//Mapeia a Area para não se perder

	//Inicia a Query 

	cAlias        := GetNextAlias()
	BeginSql Alias cAlias
            SELECT 
                A2_NOME,
                A2_COD,
				A2_END,
				A2_LOJA
            FROM
                %table:SA2% SA2
            WHERE
                A2_FILIAL = %xFilial:SA2%
                AND SA2.%notDel%
	ENDSQL

	// ADICIONANDO OS DADOS DA QUERY DENTRO DO OBJETO "OOBJETO"
	IF (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		
		While(cAlias)->(!Eof())			
			private oObjeto:=JsonObject():New()
			oObjeto['Codigo']		:= (cAlias)->A2_COD
			oObjeto['Nome']			:= (cAlias)->A2_NOME
			oObjeto['Endereço']		:= (cAlias)->A2_END
			oObjeto['Loja']			:= (cAlias)->A2_LOJA
			Aadd(aArray, oObjeto)
			(cAlias)->(DbSkip())			
		ENDDO

		
		// Retornando a menságem para o usuário 
		self:SetContentType('application/json')
		cResponse := FWJsonSerialize(aArray, .F.,.F.,.T.)
		self:SetResponse(EncodeUTF8(cResponse))
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	ENDIF



Return lRet


//RETORNA APENAS UM FORNECEDOR
WSMETHOD GET GetById PATHPARAM id WSSERVICE restfor
	local lRet 			:= .T.					// Variavel de Retorno do Metodo GET
	local oObjetoo 		:= JsonObject():New() 	// Criando o Objeto JSON
	local cAlias 		:= GetNextAlias()		// Alias para manipular o Banco 
	local aArea 		:= GetArea()			//Mapeia a Area para não se perder
						

	Self:SetContentType("application/json")
	// ID que sera adicionada dentro da Query, para utilizar na URL(HTTP)
	cid := "%" + ::id + "%"

	//inicia a Query								
	BeginSql Alias cAlias
		SELECT A2_COD,A2_NOME,A2_END FROM %table:SA2% SA2 
		WHERE A2_FILIAL = %xFilial:SA2% AND A2_COD = %Exp:cid% AND SA2.%notDel%
	ENDSQL


	// ADICIONANDO OS DADOS DA QUERY DENTRO DO OBJETO json "OOBJETO"
	IF (cAlias)->(!Eof())
		oObjetoo['Codigo'] 		:= (cAlias) -> A2_COD
		oObjetoo['Nome'] 		:= (cAlias) -> A2_NOME
		oObjetoo['Endereço'] 	:= (cAlias) -> A2_END		
		cResponse :=oObjetoo:toJson()
		self:SetResponse(EncodeUTF8(cResponse))
		
		
	ELSE
		lRet := .F.
		cRetorno := "Fornecedor Não encontrado"
		SetRestFault(490,(EncodeUTF8(cRetorno)))
	ENDIF

	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return lRet

// Criando novo Fornecedor 
WSMETHOD POST WSSERVICE restfor 
	local lRet 				:= .T. 						// Variavel de Retorno do Metodo POST
	local aDados 			:= {}						//Array que sera Utilizado dentro do ExcAuto
	local cAlias 			:= 'SA2'					// Manipulação do Banco
	Local cJson             := Self:GetContent()		// Pega o Conteudo da transação do Json(Conteudo da URL)	
	Local oResponse         := JsonObject():New()		// Cria o Objeto JSON 
	local aArea 			:= GetArea()				//Mapeia a Area para não se perder


	//Variavel que verificar se houve falha no EXCAuto
	Local lMsErroAuto := .F.	
	Self:SetContentType('application/json')
	oJSon := JsonObject():New() 	//Cria o Objeto JSON 
	cError := oJson:FromJson(cJson) // Retorna as informações do Objeto 

	//Se tiver algum erro no Parse, encerra a execução 
	IF ! Empty(cError)
		self:setStatus(500)
		oResponse['ERRO']			:= 'Erro ao Enviar o Json'

	else
		DbSelectArea(cAlias)
		//Adicionando os Dados dentro do EXCAUTO
		aAdd(aDados, {'A2_COD', oJson:GetJsonObject('cod'), Nil})
		aAdd(aDados, {'A2_LOJA', oJson:GetJsonObject('loja'), Nil})
		aAdd(aDados, {'A2_NOME', oJson:GetJsonObject('nome'), Nil})
		aAdd(aDados, {'A2_NREDUZ', oJson:GetJsonObject('nreduz'), Nil})
		aAdd(aDados, {'A2_END', oJson:GetJsonObject('end'), Nil})
		aAdd(aDados, {'A2_EST', oJson:GetJsonObject('est'), Nil})
		aAdd(aDados, {'A2_MUN', oJson:GetJsonObject('mun'), Nil})
		aAdd(aDados, {'A2_TIPO',   oJson:GetJsonObject('tipo'),   Nil})
		MsExecAuto({|x,y| MATA020(x,y)}, aDados,3)
		
		If lMsErroAuto
			self:setStatus(500)	
			oResponse['Erro']		:= 'Erro na inclusão do Registro'			
			lRet := .F.
		ELSE
			oResponse['Nome: ' + ADADOS[3][2]	+ ' || Codigo: ' + ADADOS[1][2]	]:= ' incluido com Sucesso'
		ENDIF 
	ENDIF	

	Self:SetResponse(oResponse:toJSON())

	
	(cAlias)->(DbCloseArea())		//Fecha a Tabela selecionada
	RestArea(aArea)					//Fecha a Area

Return lRet


// Alterando Fornecedor
WSMETHOD PUT WSSERVICE restfor 
	local lRet 				:= .T. 						// Variavel de Retorno do Metodo PUT
	local aDados 			:= {}						//Array que sera Utilizado dentro do ExcAuto
	local cAlias 			:= 'SA2'					// Manipulação do Banco
	Local cJson         	:= Self:GetContent()		// Pega o Conteudo da transação do Json(Conteudo da URL)	
	Local oResponse     	:= JsonObject():New()		// Cria o Objeto JSON 
	local aArea 			:= GetArea()				//Mapeia a Area para não se perder


	
	//Variavel que verificar se houve falha no EXCAuto
	lMsErroAuto := .F.

	Self:SetContentType('application/json')
	oJSon := JsonObject():New() //Cria o Objeto JSON 
	cError := oJson:FromJson(cJson) // Retorna as informações do Objeto 

	//Se tiver algum erro no Parse, encerra a execução 
	IF ! Empty(cError)
		self:setStatus(500)
		oResponse['ERRO']			:= 'Erro ao Enviar a Requisição pelo HTTP'
		
	else
		
		DbSelectArea(cAlias)

		//Alterando os Dados dentro do EXCAUTO

		aAdd(aDados, {'A2_COD', oJson:GetJsonObject('cod'), Nil})
		aAdd(aDados, {'A2_LOJA', oJson:GetJsonObject('loja'), Nil})
		aAdd(aDados, {'A2_NOME', oJson:GetJsonObject('nome'), Nil})
		aAdd(aDados, {'A2_NREDUZ', oJson:GetJsonObject('nreduz'), Nil})
		aAdd(aDados, {'A2_END', oJson:GetJsonObject('end'), Nil})
		aAdd(aDados, {'A2_EST', oJson:GetJsonObject('est'), Nil})
		aAdd(aDados, {'A2_MUN', oJson:GetJsonObject('mun'), Nil})
		aAdd(aDados, {'A2_TIPO',   oJson:GetJsonObject('tipo'),   Nil})

		MsExecAuto({|x,y| MATA020(x,y)}, aDados,4)
		
		If lMsErroAuto
			self:setStatus(500)
			oResponse['Erro'] 	:= 'Nao foi possivel Alterar o registro || Verifique se o Codigo: ' + ADADOS[1][2] + ' | do Fornecedor: ' + ADADOS[3][2] + ' existe no Sistema ||
			oResponse['Erro_']	:= 'Nenhum Codigo e Loja podem ser alterado || Verifique se o estado tem dois Digito EX: SP  '
			lRet := .F.
		ELSE
			oResponse["Registro: " + ADADOS[1][2] ]		:= ' Alterado com Sucesso'
		ENDIF 
	ENDIF	

	Self:SetResponse(EncodeUTF8(oResponse:toJSON()))

	
	(cAlias)->(DbCloseArea())		//Fecha a Tabela selecionada
	RestArea(aArea)					//Fecha a Area
Return lRet

//Deletando Fornecedor
WSMETHOD DELETE PATHPARAM id WSREST restfor
	local cFornecedor   	:= PadL(Upper(AllTrim(::id)),6,"0") // Pega o Codigo do Fornecedor
	local oResponse 	:= JsonObject():New()				// Cria o Objeto Json
	Local oModel    	:= FwLoadModel("MATA020")			// Carrega EXCT Auto de Cadastro de Fornecedores em MVC
	local lRet			:= .T.
	local aArea 		:= GetArea()						//Mapeia a Area para não se perder
	
	::SetContentType("application/json")
	//Verifica se o Codigo Existe na Tabela 

	IF SA2->(DbSeek(xFilial("SA2") + cFornecedor))
		oModel:SetOperation(MODEL_OPERATION_DELETE)		
		oModel:Activate()

		//VALIDA AS INFORMAÇÕES E DEPOIS COMITA
		if(oModel:VldData() .and. oModel:CommitData())
			lRet := .T.
			oResponse["Fornecedor | " + cFornecedor ]			:= "Removido com Sucesso"
			cResponse 	:= FWJsonSerialize(oResponse, .F.,.F.,.T.)
			Self:SetResponse(cResponse)
		else
			lRet := .F.
			aError := oModel:GetErrorMessage()
			cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
			SetRestFault(400, cRetorno)
		EndIf
		oModel:Deactivate()
	else
		SetRestFault(400,EncodeUTF8("Não foi localizado o Fornecedor"))
	ENDIF
	
	RestArea(aArea)					//Fecha a Area
	
		
Return lRet


	






