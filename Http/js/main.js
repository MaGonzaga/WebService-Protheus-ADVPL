'use strict';







const limparFormulario = (carrega) =>{
    document.getElementById('nome').value = '';
    document.getElementById('cnpj').value = '';
    document.getElementById('endereco').value = '';
    document.getElementById('bairro').value = '';
    document.getElementById('municipio').value = '';
    document.getElementById('telefone').value = '';
    document.getElementById('qtdcompras').value = '';
    document.getElementById('ultcompra').value = '';
    document.getElementById('saldotitulos').value = '';
}


const preencherFormulario = (carrega) => {
    
    document.getElementById('nome').value = carrega.nome
    document.getElementById('cnpj').value = carrega.cnpj
    document.getElementById('endereco').value = carrega.endereco
    document.getElementById('bairro').value = carrega.bairro
    document.getElementById('municipio').value = carrega.municipio
    document.getElementById('telefone').value = carrega.telefone
    document.getElementById('qtdcompras').value = carrega.qtdcompras
    document.getElementById('ultcompra').value = carrega.ultcompra
    document.getElementById('maiorcompra').value = carrega.maiorcompra 
    document.getElementById('saldotitulos').value = carrega.saldotitulos
}

const pesquisarCodigo = async () => {
    limparFormulario();
    const codigo = document.getElementById('codigo').value;
    const url = `http://192.168.20.175:8080/rest/restfor/fornecedor/${codigo}`;
    const dados = await fetch(url);
    const carrega = await dados.json();
    if (carrega.hasOwnProperty('errorCode')){
        document.getElementById('nome').value = "CODIGO NAO ENCONTRADO !"
    }else {
        preencherFormulario(carrega);
    } 


   //fetch(url).then(console.log);
    //console.log(codigo);
}

document.getElementById('codigo')
        .addEventListener('focusout',pesquisarCodigo);