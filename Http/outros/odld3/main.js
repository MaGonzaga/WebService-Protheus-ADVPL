function fazGet(url) {
    let request = new XMLHttpRequest()
    request.open("GET", url, false)
    request.send()
    return request.responseText
}

function criaLinha(usuario) {
    console.log(usuario)
    linha = document.createElement("tr");
    tdId = document.createElement("td");
    tdNome = document.createElement("td");
    tdId.innerHTML = cResponse.id
    tdNome.innerHTML = cResponse.name

    linha.appendChild(tdId);
    linha.appendChild(tdNome);

    return linha;
}

function main() {
    data = fazGet('http://localhost:8080/rest/restfor/fornecedor/000020');
    usuarios = JSON.parse(data);
    tabela = document.getElementById("tabela");
    console.log(usuarios)
    usuarios.forEach(element => {
        linha = criaLinha(element);
        tabela.appendChild(linha);
    });
    // Para cada usuario
        // criar uma linha
        // adicionar na tabela
}

main()