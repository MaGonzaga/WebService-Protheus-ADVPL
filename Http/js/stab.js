'use strict';


const limparFormulario = (carrega) =>{

    document.getElementById('processamento').value = '';
}

const limparFormulario2 = (carrega2) =>{

    document.getElementById('erro').value = '';


}


const preencherFormulario = (carrega) => {    
    
    document.getElementById('processamento').value = carrega.processamento
   
}

const preencherFormulario2 = (carrega2) => {    

    document.getElementById('erro').value = carrega2.erro

}


const pesquisarData = async () => {
    limparFormulario();
    const url = `http://192.168.20.175:8080/rest/mondigi/processamento`;
    const dados = await fetch(url);
    const carrega = await dados.json();
    preencherFormulario(carrega);
    

    fetch(url).then(console.log);
    console.log(processamento);
}


const pesquisarErro = async () => {
    limparFormulario2();
    const url2 = `http://192.168.20.175:8080/rest/mondigi/erro`;
    const dados2 = await fetch(url2);
    const carrega2 = await dados2.json();
    preencherFormulario2(carrega2);
    

    fetch(url2).then(console.log);
    console.log(erro);
}

document.getElementById('processamento')
        window.addEventListener("load",pesquisarData);

document.getElementById('erro')
        window.addEventListener('load',pesquisarErro);

