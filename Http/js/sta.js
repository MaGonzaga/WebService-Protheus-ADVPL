'use strict';


const limparFormulario = (carrega) =>{

    document.getElementById('processamento').value = '';

}


const preencherFormulario = (carrega) => {    
    
    document.getElementById('processamento').value = carrega.processamento

}

const pesquisarData = async () => {
    limparFormulario();
    const datee = document.getElementById('datee').value;
    const url = `http://192.168.20.175:8080/rest/mondigi/contadores/${datee}`;
    const dados = await fetch(url);
    const carrega = await dados.json();
    if (carrega.hasOwnProperty('errorCode')){
        document.getElementById('processamento').value = "VERIFIQUE SE A DATA ESTA CORRETA!"
    }else {
        preencherFormulario(carrega);
    } 

    fetch(url).then(console.log);
    console.log(datee);
}

document.getElementById('datee')
        .addEventListener('focusout',pesquisarData);