# ============================================================
# ARQUIVO: 04-operacoes-crud.py
# O QUE FAZ: Demonstra TODAS as operações DynamoDB usando Boto3
#
# CONCEITOS: PutItem, GetItem, UpdateItem, DeleteItem, Query, Scan
#             Condition Expressions, Update Expressions
#
# EXECUTE: python 04-operacoes-crud.py
# PRÉ-REQUISITO: tabela criada com 01-tabela-simples.yaml
# CUSTO: ~$0.00 — Free Tier cobre estas operações
# ============================================================

import json
import logging
import os
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import boto3
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# ============================================================
# CONFIGURAÇÃO
# ============================================================
NOME_TABELA = os.environ.get('NOME_TABELA', 'tarefas-aprendizado')
USUARIO_TESTE = "user-001"

# Cliente DynamoDB — interface de baixo nível (tipos explícitos)
dynamo_client = boto3.client('dynamodb', region_name='us-east-1')

# Resource DynamoDB — interface pythonica (tipos automáticos)
dynamo_resource = boto3.resource('dynamodb', region_name='us-east-1')
tabela = dynamo_resource.Table(NOME_TABELA)


def demonstrar_put_item():
    """
    PutItem: CRIA ou SUBSTITUI um item completo
    Equivalente SQL: INSERT INTO tarefas VALUES (...) ON CONFLICT REPLACE
    """
    print("\n" + "="*50)
    print("1. PutItem — Criando tarefas")
    print("="*50)
    
    tarefas = [
        {
            'usuarioId': USUARIO_TESTE,
            'tarefaId': f'tarefa-{uuid.uuid4().hex[:8]}',
            'titulo': 'Estudar DynamoDB',
            'descricao': 'Aprender PutItem, GetItem, Query, UpdateItem, DeleteItem',
            'concluida': False,
            'prioridade': 'alta',
            'tags': ['aws', 'dynamodb', 'estudo'],    # Lists funcionam nativamente!
            'metadados': {                             # Maps (dicts) também!
                'criado_por': 'usuario-admin',
                'versao': 1
            },
            'criado_em': datetime.now(timezone.utc).isoformat(),
            'pontos': Decimal('10.5')                  # Use Decimal para números no DynamoDB Python SDK
        },
        {
            'usuarioId': USUARIO_TESTE,
            'tarefaId': f'tarefa-{uuid.uuid4().hex[:8]}',
            'titulo': 'Praticar Query vs Scan',
            'concluida': True,
            'prioridade': 'media',
            'tags': ['dynamodb', 'performance'],
            'criado_em': datetime.now(timezone.utc).isoformat(),
            'pontos': Decimal('5.0')
        }
    ]
    
    for tarefa in tarefas:
        # CONDITION EXPRESSION: só insere se NÃO existir
        # Evita sobrescrever dados existentes acidentalmente
        try:
            tabela.put_item(
                Item=tarefa,
                ConditionExpression='attribute_not_exists(usuarioId)'  # Só cria se não existir
            )
            logger.info("✅ Tarefa criada: %s — %s", tarefa['tarefaId'], tarefa['titulo'])
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                logger.warning("⚠️  Tarefa já existe: %s", tarefa['tarefaId'])
            else:
                raise
    
    return [t['tarefaId'] for t in tarefas]


def demonstrar_get_item(tarefa_id: str):
    """
    GetItem: LEITURA de um item específico por PK + SK
    É a operação mais eficiente do DynamoDB — O(1)
    Equivalente SQL: SELECT * FROM tarefas WHERE usuarioId='...' AND tarefaId='...'
    """
    print("\n" + "="*50)
    print("2. GetItem — Lendo um item específico")
    print("="*50)
    
    response = tabela.get_item(
        Key={
            'usuarioId': USUARIO_TESTE,    # PK
            'tarefaId': tarefa_id          # SK
        },
        # ProjectionExpression: retorna apenas estes campos (economiza RCU em itens grandes)
        ProjectionExpression='titulo, concluida, prioridade, pontos',
        # ConsistentRead: 
        #   False (default) = eventual consistency (usa RCU normal, pode ter lag de ms)
        #   True = strong consistency (usa 2x mais RCU, garantido mais recente)
        ConsistentRead=False
    )
    
    if 'Item' not in response:
        logger.warning("Item não encontrado: %s", tarefa_id)
        return None
    
    item = response['Item']
    logger.info("✅ Item encontrado: %s", json.dumps(item, default=str))
    return item


def demonstrar_update_item(tarefa_id: str):
    """
    UpdateItem: ATUALIZA atributos específicos (sem sobrescrever o item inteiro)
    É mais eficiente que PutItem quando só quer mudar 1-2 campos
    Equivalente SQL: UPDATE tarefas SET concluida=true, pontos=pontos+5 WHERE ...
    """
    print("\n" + "="*50)
    print("3. UpdateItem — Atualizando campos específicos")
    print("="*50)
    
    response = tabela.update_item(
        Key={
            'usuarioId': USUARIO_TESTE,
            'tarefaId': tarefa_id
        },
        # UpdateExpression: o que atualizar
        #   SET   = define ou substitui um valor
        #   ADD   = incrementa número ou adiciona a um Set
        #   REMOVE = remove um atributo
        #   DELETE = remove itens de um Set
        UpdateExpression='''
            SET concluida = :concluida,
                concluida_em = :data,
                metadados.versao = metadados.versao + :incremento
            ADD pontos :bonus_pontos
        ''',
        # ExpressionAttributeValues: valores para os placeholders ":nome"
        ExpressionAttributeValues={
            ':concluida': True,
            ':data': datetime.now(timezone.utc).isoformat(),
            ':incremento': 1,
            ':bonus_pontos': Decimal('2.5'),
            ':deve_existir': USUARIO_TESTE        # Para a condição abaixo
        },
        # ConditionExpression: só atualiza se esta condição for verdadeira
        ConditionExpression='usuarioId = :deve_existir',    # Garante que o item existe
        # ReturnValues: o que retornar
        #   NONE = nada (default, mais eficiente)
        #   ALL_OLD = item antes da atualização
        #   ALL_NEW = item após a atualização
        #   UPDATED_OLD / UPDATED_NEW = apenas campos atualizados
        ReturnValues='ALL_NEW'
    )
    
    item_atualizado = response.get('Attributes', {})
    logger.info("✅ Item atualizado. Pontos: %s, Versão: %s", 
                item_atualizado.get('pontos'),
                item_atualizado.get('metadados', {}).get('versao'))
    return item_atualizado


def demonstrar_query():
    """
    Query: BUSCA eficiente por Partition Key + condição no Sort Key
    Retorna MÚLTIPLOS itens em ordem definida pela Sort Key
    Equivalente SQL: SELECT * FROM tarefas WHERE usuarioId='...' ORDER BY tarefaId
    """
    print("\n" + "="*50)
    print("4. Query — Buscando todas as tarefas do usuário")
    print("="*50)
    
    # Query básic por PK apenas
    response = tabela.query(
        KeyConditionExpression='usuarioId = :uid',
        ExpressionAttributeValues={':uid': USUARIO_TESTE},
        # ScanIndexForward: True = ordem crescente (default), False = decrescente
        ScanIndexForward=False,               # Mais recentes primeiro
        # Limit: quantos itens AVALIAR (não necessariamente retornar)
        Limit=10
    )
    
    itens = response.get('Items', [])
    logger.info("✅ Query encontrou %d itens", len(itens))
    
    for item in itens:
        status = "✅" if item.get('concluida') else "⬜"
        logger.info("  %s %s [%s] — %s pts", 
                    status, item.get('titulo', ''), 
                    item.get('prioridade', ''), item.get('pontos', 0))
    
    # PAGINAÇÃO — quando há muitos itens
    # LastEvaluatedKey indica que há mais itens
    if 'LastEvaluatedKey' in response:
        logger.info("⚠️  Há mais itens! Use ExclusiveStartKey para paginar:")
        logger.info("  next_page = tabela.query(..., ExclusiveStartKey=%s)", 
                    response['LastEvaluatedKey'])
    
    return itens


def demonstrar_scan_com_filtro():
    """
    Scan: EVITE em produção! Lê a tabela inteira.
    Use apenas para: operações one-time, tabelas pequenas, ou migração de dados.
    
    ⚠️  IMPORTANTE: FilterExpression filtra APÓS a leitura completa!
                    Scan de 1M itens com FilterExpression = lê 1M itens
                    Só retorna os que passam no filtro
                    Mas COBRA por todos os 1M lidos!
    """
    print("\n" + "="*50)
    print("5. Scan — (APENAS para demo, EVITE em produção!)")
    print("="*50)
    
    response = tabela.scan(
        # FilterExpression: aplica APÓS ler todos os itens (não economiza RCU!)
        FilterExpression='prioridade = :prioridade AND concluida = :status',
        ExpressionAttributeValues={
            ':prioridade': 'alta',
            ':status': True
        },
        # ProjectionExpression: reduz dados transferidos (economiza bandwidth)
        ProjectionExpression='usuarioId, tarefaId, titulo, pontos'
    )
    
    logger.info("⚠️  Scan leu %d itens no total", response.get('ScannedCount', 0))
    logger.info("   Retornou após filtro: %d itens", response.get('Count', 0))
    logger.info("   RCU consumidas: ~%d (cobradas mesmo com filtro!)", 
                response.get('ScannedCount', 0))
    
    return response.get('Items', [])


def demonstrar_delete_item(tarefa_id: str):
    """
    DeleteItem: REMOVE um item específico
    Equivalente SQL: DELETE FROM tarefas WHERE usuarioId='...' AND tarefaId='...'
    """
    print("\n" + "="*50)
    print("6. DeleteItem — Removendo um item")
    print("="*50)
    
    response = tabela.delete_item(
        Key={
            'usuarioId': USUARIO_TESTE,
            'tarefaId': tarefa_id
        },
        ReturnValues='ALL_OLD'    # Retorna o item ANTES de deletar
    )
    
    if 'Attributes' in response:
        logger.info("✅ Item deletado: %s", response['Attributes'].get('titulo'))
    else:
        logger.warning("Item não existia: %s", tarefa_id)


if __name__ == '__main__':
    print("\n" + "="*60)
    print("DEMONSTRAÇÃO CRUD COMPLETO — DYNAMODB")
    print("Tabela:", NOME_TABELA)
    print("="*60)
    
    try:
        # 1. Criar tarefas
        ids_criados = demonstrar_put_item()
        
        if ids_criados:
            # 2. Ler uma tarefa específica
            demonstrar_get_item(ids_criados[0])
            
            # 3. Atualizar uma tarefa
            demonstrar_update_item(ids_criados[0])
            
            # 4. Query — listar todas as tarefas
            demonstrar_query()
            
            # 5. Scan (demonstração do que EVITAR)
            demonstrar_scan_com_filtro()
            
            # 6. Deletar a segunda tarefa
            if len(ids_criados) > 1:
                demonstrar_delete_item(ids_criados[1])
        
        print("\n" + "="*60)
        print("✅ DEMONSTRAÇÃO CONCLUÍDA!")
        print("Próximo: veja 05-lambda-crud-api.py para integrar com API Gateway")
        print("="*60)
    
    except Exception as e:
        logger.error("Erro: %s", str(e))
        logger.error("Certifique-se de ter criado a tabela com 01-tabela-simples.yaml")
