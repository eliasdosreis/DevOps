# ============================================================
# ARQUIVO: 01-lambda-api-handler.py
# O QUE FAZ: Lambda que implementa um CRUD completo via HTTP
#
# FLUXO: Cliente → API Gateway → ESTA Lambda → Response
#
# Responde aos métodos: GET, POST, PUT, DELETE
# Simula operações em uma lista de "produtos" em memória
# (No Módulo 4, conectaremos ao DynamoDB real)
#
# CUSTO: $0.00 — Free Tier Lambda + API Gateway
# ============================================================

import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ============================================================
# "BANCO DE DADOS" EM MEMÓRIA — APENAS PARA DEMO
# (Em produção real: use DynamoDB — Módulo 4)
# ⚠️  Dados são perdidos a cada cold start!
# ============================================================
PRODUTOS = {
    "1": {"id": "1", "nome": "Notebook", "preco": 2999.00, "categoria": "eletronicos"},
    "2": {"id": "2", "nome": "Mouse", "preco": 89.90, "categoria": "eletronicos"},
    "3": {"id": "3", "nome": "Camiseta Python", "preco": 59.90, "categoria": "roupas"},
}


def handler(event, context):
    """
    Handler principal que roteia as requisições pelo método HTTP e path.
    
    API Gateway envia um 'event' com esta estrutura (HTTP API):
    {
      "routeKey": "GET /produtos/{id}",
      "rawPath": "/produtos/1",
      "pathParameters": {"id": "1"},
      "queryStringParameters": {"categoria": "eletronicos"},
      "body": "{\"nome\": \"...\"}",
      "requestContext": {
        "http": {"method": "GET", "path": "/produtos/1"},
        "requestId": "abc-123"
      }
    }
    """
    
    logger.info("Requisição: %s %s", 
                event.get('requestContext', {}).get('http', {}).get('method', 'UNKNOWN'),
                event.get('rawPath', '/'))
    
    try:
        # Extrai método HTTP e path
        metodo = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
        path = event.get('rawPath', '/')
        path_params = event.get('pathParameters', {}) or {}
        query_params = event.get('queryStringParameters', {}) or {}
        
        # Parse do body (vem como string JSON)
        body = None
        if event.get('body'):
            try:
                body = json.loads(event['body'])
            except json.JSONDecodeError:
                return _resposta(400, {'erro': 'Body inválido: não é JSON válido'})
        
        # --------------------------------------------------------
        # ROTEAMENTO — decide qual ação executar
        # --------------------------------------------------------
        produto_id = path_params.get('id')
        
        if metodo == 'GET' and not produto_id:
            return _listar_produtos(query_params)
        
        elif metodo == 'GET' and produto_id:
            return _obter_produto(produto_id)
        
        elif metodo == 'POST' and not produto_id:
            return _criar_produto(body)
        
        elif metodo == 'PUT' and produto_id:
            return _atualizar_produto(produto_id, body)
        
        elif metodo == 'DELETE' and produto_id:
            return _deletar_produto(produto_id)
        
        else:
            return _resposta(405, {'erro': f'Método {metodo} não suportado nesta rota'})
    
    except Exception as e:
        logger.error("Erro interno: %s", str(e), exc_info=True)
        return _resposta(500, {'erro': 'Erro interno do servidor', 'detalhe': str(e)})


def _listar_produtos(query_params: dict) -> dict:
    """GET /produtos → Lista todos os produtos com filtros opcionais."""
    produtos = list(PRODUTOS.values())
    
    # Filtro opcional por categoria
    categoria = query_params.get('categoria')
    if categoria:
        produtos = [p for p in produtos if p.get('categoria') == categoria]
    
    # Paginação simples (em DynamoDB real, use LastEvaluatedKey)
    limite = int(query_params.get('limite', 10))
    produtos = produtos[:limite]
    
    return _resposta(200, {
        'produtos': produtos,
        'total': len(produtos),
        'filtros': query_params
    })


def _obter_produto(produto_id: str) -> dict:
    """GET /produtos/{id} → Retorna um produto específico."""
    produto = PRODUTOS.get(produto_id)
    
    if not produto:
        return _resposta(404, {'erro': f'Produto "{produto_id}" não encontrado'})
    
    return _resposta(200, produto)


def _criar_produto(body: dict) -> dict:
    """POST /produtos → Cria um novo produto."""
    if not body:
        return _resposta(400, {'erro': 'Body obrigatório para criação'})
    
    # Validação dos campos obrigatórios
    campos_obrigatorios = ['nome', 'preco']
    campos_ausentes = [c for c in campos_obrigatorios if c not in body]
    if campos_ausentes:
        return _resposta(400, {
            'erro': 'Campos obrigatórios ausentes',
            'campos': campos_ausentes
        })
    
    # Valida tipo do preço
    try:
        preco = float(body['preco'])
        if preco < 0:
            raise ValueError("Preço não pode ser negativo")
    except (ValueError, TypeError):
        return _resposta(422, {'erro': 'Campo "preco" deve ser um número positivo'})
    
    # Cria o novo produto
    novo_id = str(len(PRODUTOS) + 1)
    novo_produto = {
        'id': novo_id,
        'nome': str(body['nome']),
        'preco': preco,
        'categoria': body.get('categoria', 'geral'),
        'criado_em': datetime.utcnow().isoformat() + 'Z'
    }
    PRODUTOS[novo_id] = novo_produto
    
    logger.info("Produto criado: %s", novo_produto)
    
    # 201 Created = recurso criado com sucesso
    # Location header indica onde o novo recurso pode ser acessado
    return {
        'statusCode': 201,
        'headers': {
            'Content-Type': 'application/json',
            'Location': f'/produtos/{novo_id}',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(novo_produto, ensure_ascii=False)
    }


def _atualizar_produto(produto_id: str, body: dict) -> dict:
    """PUT /produtos/{id} → Atualiza um produto existente (substituição total)."""
    if produto_id not in PRODUTOS:
        return _resposta(404, {'erro': f'Produto "{produto_id}" não encontrado'})
    
    if not body:
        return _resposta(400, {'erro': 'Body obrigatório para atualização'})
    
    # PUT = substituição total (PATCH = substituição parcial)
    produto_atualizado = {
        'id': produto_id,
        'nome': body.get('nome', PRODUTOS[produto_id]['nome']),
        'preco': body.get('preco', PRODUTOS[produto_id]['preco']),
        'categoria': body.get('categoria', PRODUTOS[produto_id].get('categoria', 'geral')),
        'atualizado_em': datetime.utcnow().isoformat() + 'Z'
    }
    PRODUTOS[produto_id] = produto_atualizado
    
    return _resposta(200, produto_atualizado)


def _deletar_produto(produto_id: str) -> dict:
    """DELETE /produtos/{id} → Remove um produto."""
    if produto_id not in PRODUTOS:
        return _resposta(404, {'erro': f'Produto "{produto_id}" não encontrado'})
    
    produto_removido = PRODUTOS.pop(produto_id)
    logger.info("Produto deletado: %s", produto_id)
    
    # 204 No Content = sucesso sem corpo de resposta
    # (alguns clientes preferem 200 com o item deletado)
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
        'body': json.dumps({'mensagem': f'Produto "{produto_id}" removido', 'produto': produto_removido})
    }


def _resposta(status_code: int, dados: dict) -> dict:
    """Helper: formata a resposta no padrão do API Gateway."""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json; charset=utf-8',
            'Access-Control-Allow-Origin': '*',           # CORS
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        },
        'body': json.dumps(dados, ensure_ascii=False)
    }


# ============================================================
# TESTE LOCAL
# ============================================================
if __name__ == '__main__':
    class MockContext:
        function_name = 'api-lambda'
        aws_request_id = 'test-001'
        memory_limit_in_mb = 128
        def get_remaining_time_in_millis(self): return 14000
    
    ctx = MockContext()
    base_event = {'requestContext': {'http': {'method': '', 'path': ''}}}
    
    # Testa GET todos
    event = {**base_event, 'rawPath': '/produtos',
             'requestContext': {'http': {'method': 'GET', 'path': '/produtos'}}}
    r = handler(event, ctx)
    print(f"GET /produtos → {r['statusCode']}")
    
    # Testa POST
    event = {**base_event, 'rawPath': '/produtos',
             'requestContext': {'http': {'method': 'POST', 'path': '/produtos'}},
             'body': json.dumps({'nome': 'Teclado', 'preco': 199.90, 'categoria': 'eletronicos'})}
    r = handler(event, ctx)
    print(f"POST /produtos → {r['statusCode']}: {r['body'][:80]}...")
