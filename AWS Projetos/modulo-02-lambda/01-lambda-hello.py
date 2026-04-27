# ============================================================
# ARQUIVO: 01-lambda-hello.py
# O QUE FAZ: Função Lambda mais simples possível
#             Retorna "Olá, Mundo!" em formato JSON
#
# ANALOGIA: Este é o "garçom" mais básico:
#           você chama → ele responde → pronto.
#
# CUSTO: $0.00 — Totalmente dentro do Free Tier
# RUNTIME: Python 3.12 (versão mais recente disponível)
# HANDLER: hello.handler (arquivo: hello.py, função: handler)
# CONCEITO NOVO: handler, event, context, retorno JSON
# ============================================================

import json       # Para formatar a resposta em JSON
import logging    # Para escrever logs no CloudWatch
from datetime import datetime  # Para timestamp no response

# ============================================================
# LOGGING — Configure FORA do handler (boas práticas)
# O logger persiste entre invocações no mesmo container (warm start)
# logging.INFO → mostra logs normais no CloudWatch
# logging.DEBUG → mostra logs detalhados (só em desenvolvimento!)
# ============================================================
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Handler principal da função Lambda.
    
    Parâmetros:
        event   (dict): Dados de entrada. Estrutura varia por trigger.
                        API Gateway, S3, SQS, etc. enviam formatos diferentes.
        context (obj):  Metadados da execução atual. Contém:
                        - context.function_name: nome da Lambda
                        - context.aws_request_id: ID único desta invocação
                        - context.get_remaining_time_in_millis(): tempo restante
                        - context.memory_limit_in_mb: memória configurada
    
    Retorno:
        dict: Para triggers HTTP (API Gateway), DEVE ter statusCode e body.
              Para outros triggers (S3, SQS), pode retornar qualquer valor ou None.
    """
    
    # --------------------------------------------------------
    # LOG DO EVENTO COMPLETO — fundamental para debug
    # Em produção: cuidado com dados sensíveis no log!
    # --------------------------------------------------------
    logger.info("Evento recebido: %s", json.dumps(event))
    logger.info("Function: %s | Request ID: %s | Memória: %s MB",
                context.function_name,
                context.aws_request_id,
                context.memory_limit_in_mb)
    logger.info("Tempo restante: %d ms", context.get_remaining_time_in_millis())
    
    # --------------------------------------------------------
    # LÓGICA DO NEGÓCIO — onde fica seu código de verdade
    # --------------------------------------------------------
    
    # Extrai parâmetros do event (com .get() para evitar KeyError)
    nome = event.get('nome', 'Mundo')       # Default: 'Mundo' se não vier no evento
    linguagem = event.get('linguagem', 'pt-BR')
    
    # Monta a resposta
    resposta = {
        'mensagem': f'Olá, {nome}! 🚀 Lambda funcionando!',
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'funcao': context.function_name,
        'request_id': context.aws_request_id,
        'linguagem': linguagem,
        'modulo': 'Módulo 2 — Lambda'
    }
    
    logger.info("Resposta gerada com sucesso para: %s", nome)
    
    # --------------------------------------------------------
    # RETORNO — Formato para API Gateway HTTP/REST
    # statusCode: código HTTP (200 = sucesso, 400 = erro do usuário, 500 = erro interno)
    # headers: headers HTTP da resposta
    # body: DEVE ser string (use json.dumps())
    # --------------------------------------------------------
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Request-Id': context.aws_request_id,    # Rastreabilidade
            'X-Powered-By': 'AWS Lambda'
        },
        'body': json.dumps(resposta, ensure_ascii=False)  # ensure_ascii=False para acentos
    }


# ============================================================
# TESTE LOCAL — Execute: python 01-lambda-hello.py
# (AWS não executa este bloco, é apenas para testar localmente)
# ============================================================
if __name__ == '__main__':
    
    # Simula o objeto 'context' que a AWS envia
    class MockContext:
        function_name = 'minha-lambda-hello'
        aws_request_id = 'test-request-id-12345'
        memory_limit_in_mb = 128
        def get_remaining_time_in_millis(self):
            return 14000  # 14 segundos restantes
    
    # Simula o objeto 'event' que a API Gateway enviaria
    evento_teste = {
        'nome': 'Desenvolvedor',
        'linguagem': 'pt-BR'
    }
    
    resultado = handler(evento_teste, MockContext())
    
    print("\n=== RESULTADO DO TESTE LOCAL ===")
    print(f"Status Code: {resultado['statusCode']}")
    print(f"Body: {json.dumps(json.loads(resultado['body']), indent=2, ensure_ascii=False)}")
