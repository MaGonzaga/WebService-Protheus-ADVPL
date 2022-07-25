
function fazPost(url, body) {
    console.log("Body=", body)
    let request = new XMLHttpRequest()
    request.open("POST", url, true)
    request.setRequestHeader("Content-type", "application/json")
    request.send(JSON.stringify(body))

    request.onload = function() {
        console.log(this.responseText)
    }

    return request.responseText
}


function cadastraUsuario() {
    preventDefault()
    let url = "http://192.168.20.175:8080/rest/restfor/fornecedor/novo"
    let codigo = document.getElementById("codigo").value
    let loja = document.getElementById("loja").value
    let nome = document.getElementById("nome").value
    let fantasia = document.getElementById('fantasia').value
    let endereco = document.getElementById('endereco').value
    let tipo = document.getElementById('tipo').value
    let estado = document.getElementById('estado').value
    let municipio = document.getElementById('municipio').value


    body = {
        "codigo": codigo,
        "loja": loja,
        "nome": nome,
        "fantasia": fantasia,
        "endereco": endereco,
        "tipo": tipo,
        "estado": estado,
        "municipio": municipio
    }
    

    fazPost(url, body)
}