#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} restfor
	(WebService REST para realização de métodos GET,POST E DELETE dentro do Microsiga Protheus)
	Protheus 12.1.27
	@type  Function
	@author Marcio GOnzaga
	@since 23/05/2022
	@version 1.0	
	@return Todos os Fornecedores / Apenas um Fornecedor / Criar novo Fornecedor / Deletar Fornecedor
	@example

		(Metodo GET) 				(localhost:8080/rest/restfor/fornecedores/") Listar Todos os Fornecedor 
		(Metodo GET)				(localhost:8080/rest/restfor/fornecedor/00003") Retornar apenas um Fornecedor 
		(Metodo PUT Envia o JSON )	(localhost:8080/rest/restfor/fornecedor/novo") Criar novo Fornecedor 
		( Metodo Delete ) 			(localhost:8080/rest/restfor/fornecedor/00003") Deleta o FOrnecedor 
		
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
		WSSYNTAX "localhost:8080/rest/restfor/fornecedores/"

	WSMETHOD GET GetById;
		DESCRIPTION "Retornar apenas um Fornecedor";
		WSSYNTAX "fornecedor/{id}";
		PATH "fornecedor/{id}"

	WSMETHOD POST;
		DESCRIPTION "Criar Fornecedor";
		PATH "fornecedor/novo";
		WSSYNTAX "fornecedor/novo"

	WSMETHOD DELETE;
		DESCRIPTION "Excluir Fornecedor";
		PATH "fornecedor/{id}";
		WSSYNTAX "fornecedor/{id}";

END WSRESTFUL


// Retornar todos os Fornecedores
WSMETHOD GET WSSERVICE restfor


	local lRet          :=  .T. 	// Variavel de Retorno do Metodo GET
	local aAray         := {}		// Array para adicionar o Objeto Json
	local cResponse     := ""		// Variavel de Retorno para o usuário (HTTP)
	

	//Inicia a Query 
	cAlias        := GetNextAlias()
	BeginSql Alias cAlias
            SELECT 
                A2_NOME,
                A2_COD
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
			oObjeto['Nome']:= (cAlias)->A2_NOME
			oObjeto['Codigo']:= (cAlias)->A2_COD
			Aadd(aAray, oObjeto)
			(cAlias)->(DbSkip())
			
		ENDDO

		
		// Retornando a menságem para o usuário 
		self:SetContentType('application/json')
		cResponse := FWJsonSerialize(aAray, .F.,.F.,.T.)
		::SetResponse(cResponse)
		(cAlias)->(DbCloseArea())
	ENDIF


Return lRet


//RETORNA APENAS UM FORNECEDOR
WSMETHOD GET GetById PATHPARAM id WSSERVICE restfor
	local lRet 			:= .T.						// Variavel de Retorno do Metodo GET
	local oObjetoo 		:= JsonObject():New() 		// Criando o Objeto JSON
	local cAlias 		:= GetNextAlias()			// Alias para manipular o Banco 

	
	

	::SetContentType("application/json")
	// ID que sera adicionada dentro da Query, para utilizar na URL(HTTP)
	cid := "%" + ::id + "%"							
	BeginSql Alias cAlias
		SELECT A2_COD,A2_NOME FROM %table:SA2% SA2 
		WHERE A2_FILIAL = %xFilial:SA2% AND A2_COD = %Exp:cid% AND SA2.%notDel%
	ENDSQL


	// ADICIONANDO OS DADOS DA QUERY DENTRO DO OBJETO json "OOBJETO"
	IF (cAlias)->(!Eof())
		lRet := .T.
		oObjetoo['Codigo'] 	:= (cAlias) -> A2_COD
		oObjetoo['Nome'] 	:= (cAlias) -> A2_NOME
		
		cResponse :=oObjetoo:toJson()
		self:SetResponse(cResponse)
	ELSE
		lRet := .F.
		cRetorno := "Cliente Não encontrado"
		SetRestFault(490,cRetorno)
	ENDIF

	(cAlias)->(DbCloseArea())


		
Return lRet

// Criando novo Fornecedor 

WSMETHOD POST WSSERVICE restfor 
	local lRet 			:= .T. 						// Variavel de Retorno do Metodo POST
	local aDados 		:= {}						//Array que sera Utilizado dentro do ExcAuto
	local cAlias 		:= 'SA2'					// Manipulação do Banco
	local cErrorLog 	:= ''						// Variavel para manipular o Erro 
	local aLogAuto 		:= {}						// Array para manipular o Erro 
	local nLinha 		:= 0						// Variavel para manipular o Erro 
	Local cJson             := Self:GetContent()	// Pega o Conteudo da transação do Json(Conteudo da URL)	
	Local cDirLog           := '\x_logs\'			// Variavel para manipular o Erro
    Local cArqLog           := ''    				// Variavel para manipular o Erro
	Local oResponse         := JsonObject():New()	// Cria o Objeto JSON 

	//Variavel que verificar se houve falha no EXCAuto
	private lMsErroAuto := .F.
	// Força a gravação das informações de erro em  Array
	private lAutoErrNoFile := .T.

	Self:SetContentType('application/json')
	oJSon := JsonObject():New() //Cria o Objeto JSON 
	cError := oJson:FromJson(cJson) // Retorna as informações do Objeto 

	//Se tiver algum erro no Parse, encerra a execução 
	IF ! Empty(cError)
		self:setStatus(500)
		oResponse['errorId']		:= 'NEW004'
		oResponse['error']			:= 'Parse do JSON'
		oResponse['solution']		:= 'Erro ao fazer o Parse do JSON'
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
			cErrorLog 	:= ''
			aLogAuto 	:= GetAutoGrLog()
			for nLinha := 1 to Len(aLogAuto)
				cErrorLog += aLogAuto[nLinha] + CRLF
			Next nLinha

			cArqLog := 'POSTF_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
			MemoWrite(cDirLog + cArqLog, cErrorLog)

			self:setStatus(500)
			oResponse['errorId'] 	:= 'NEW005'
			oResponse['error']		:= 'Erro na inclusão do Registro'
			oResponse['solution'] 	:= 'Nao foi possivel incluir o registro, foi gerado um arquivo de log em ' + cDirLog + cArqLog + ' '
			lRet := .F.
		ELSE
			oResponse['note']		:= 'Registro incluido com Sucesso'
		ENDIF 
	ENDIF	

	Self:SetResponse(oResponse:toJSON())




Return lRet


// MEtodo Delete em MVC 

WSMETHOD DELETE PATHPARAM id WSREST restfor
	local cCliente   	:= PadL(Upper(AllTrim(::id)),6,"0") // Pega o Codigo do Cliente
	local oResponse 	:= JsonObject():New()				// Cria o Objeto Json
	Local oModel    	:= FwLoadModel("MATA020")			// Carrega EXCT Auto de Cadastro de Fornecedores em MVC

	

	::SetContentType("application/json")
	//Verifica se o Codigo Existe na Tabela 

	IF SA2->(DbSeek(xFilial("SA2") + cCliente))
		oModel:SetOperation(MODEL_OPERATION_DELETE)
		
		oModel:Activate()
		//VALIDA AS INFORMAÇÕES E DEPOIS COMITA
		if(oModel:VldData() .and. oModel:CommitData())
			lRet := .T.
			oResponse['sucess']		:= .T.
			cResponse 	:= FWJsonSerialize(oResponse, .F.,.F.,.T.)
			::SetResponse(cResponse)
		else
			lRet := .F.
			aError := oModel:GetErrorMessage()
			cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
			SetRestFault(400, cRetorno)
		EndIf
		oModel:Deactivate()
	else
		SetRestFault(400,"Não foi localizado o Cliente")
	ENDIF
		
Return lRet


	

 





