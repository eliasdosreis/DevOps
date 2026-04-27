# ============================================================
# ARQUIVO: 02-lambda-com-s3.py
# O QUE FAZ: Lambda que lê e escreve arquivos no S3 usando Boto3
#
# ANALOGIA: O garçom agora vai até o "depósito" (S3) buscar
#           ingredientes, prepara o prato e guarda o resultado.
#
# BOTO3: A biblioteca Python oficial da AWS.
#        Permite chamar qualquer serviço AWS de dentro do Python.
#        Está PRÉ-INSTALADA no runtime Lambda (não precisa incluir).
#
# CUSTO: $0.00 — Free Tier cobre Lambda + S3
# RUNTIME: Python 3.12
# ============================================================

import json
import logging
import os
from datetime import datetime

# ============================================================
# boto3 — A biblioteca AWS para Python
# Já vem instalada no Lambda (runtime Python)
# Para testar LOCAL: pip install boto3
# ============================================================
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ============================================================
# INICIALIZAÇÃO FORA DO HANDLER — BOTO3 CLIENTS
# Criados UMA VEZ e reutilizados em warm starts
# Isso evita o overhead de criar novos clients a cada invocação
# ============================================================
s3_client = boto3.client('s3')         # Cliente para operações S3
s3_resource = boto3.resource('s3')     # Resource (interface mais pythonica)

# ============================================================
# VARIÁVEIS DE AMBIENTE — Configure no template CloudFormation
# NUNCA hardcode valores sensíveis ou que mudam por ambiente!
# ============================================================
BUCKET_NOME = os.environ.get('BUCKET_NOME', 'meu-bucket-aprendizado')
PASTA_INPUT = os.environ.get('PASTA_INPUT', 'entrada/')
PASTA_OUTPUT = os.environ.get('PASTA_OUTPUT', 'saida/')


def handler(event, context):
    """
    Lambda que demonstra operações S3 com Boto3:
    - Ler um arquivo do S3
    - Processar o conteúdo
    - Gravar o resultado de volta no S3
    """
    
    logger.info("Iniciando processamento S3 | Bucket: %s", BUCKET_NOME)
    logger.info("Evento: %s", json.dumps(event))
    
    try:
        # Determina qual arquivo processar
        # Pode vir do event (chamada manual) ou do trigger S3
        arquivo_input = event.get('arquivo', f'entrada/dados-{datetime.utcnow().strftime("%Y%m%d")}.json')
        
        # --------------------------------------------------------
        # OPERAÇÃO 1: LER objeto do S3
        # get_object() retorna um dict com Body (stream)
        # --------------------------------------------------------
        logger.info("Lendo arquivo: s3://%s/%s", BUCKET_NOME, arquivo_input)
        
        try:
            resposta = s3_client.get_object(
                Bucket=BUCKET_NOME,           # Nome do bucket
                Key=arquivo_input             # Caminho do objeto
                # VersionId='...'            # Opcional: ler versão específica
            )
            
            # Body é um StreamingBody — precisa chamar .read() e decodificar
            conteudo = resposta['Body'].read().decode('utf-8')
            dados = json.loads(conteudo)
            
            logger.info("Arquivo lido com sucesso: %d bytes", resposta['ContentLength'])
            
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchKey':
                # Arquivo não existe — cria um de exemplo
                logger.warning("Arquivo não encontrado. Criando dados de exemplo...")
                dados = _criar_dados_exemplo()
                _salvar_no_s3(dados, BUCKET_NOME, arquivo_input)
            else:
                raise  # Re-lança outros erros
        
        # --------------------------------------------------------
        # OPERAÇÃO 2: PROCESSAR os dados
        # (aqui vai a lógica de negócio real)
        # --------------------------------------------------------
        resultado = _processar_dados(dados)
        
        # --------------------------------------------------------
        # OPERAÇÃO 3: ESCREVER resultado no S3
        # put_object() envia um objeto para o S3
        # --------------------------------------------------------
        arquivo_output = arquivo_input.replace(PASTA_INPUT, PASTA_OUTPUT)
        _salvar_no_s3(resultado, BUCKET_NOME, arquivo_output)
        
        # --------------------------------------------------------
        # OPERAÇÃO 4: LISTAR objetos (demonstração)
        # list_objects_v2() lista até 1000 objetos por vez
        # --------------------------------------------------------
        objetos = _listar_objetos(BUCKET_NOME, PASTA_OUTPUT)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'mensagem': 'Processamento concluído!',
                'arquivo_input': arquivo_input,
                'arquivo_output': arquivo_output,
                'objetos_em_saida': objetos,
                'timestamp': datetime.utcnow().isoformat() + 'Z'
            }, ensure_ascii=False)
        }
        
    except ClientError as e:
        # Erro de permissão, bucket não existe, etc.
        logger.error("Erro AWS: %s", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({
                'erro': str(e),
                'codigo': e.response['Error']['Code']
            })
        }
    
    except Exception as e:
        # Erro genérico — sempre logue antes de re-lançar!
        logger.error("Erro inesperado: %s", str(e), exc_info=True)
        raise  # Re-lança para o Lambda marcar como falha (CloudWatch Alarms)


def _processar_dados(dados: dict) -> dict:
    """
    Processa os dados de entrada.
    Em um sistema real: transformações, validações, enriquecimento.
    """
    return {
        **dados,                              # Mantém dados originais
        'processado': True,
        'processado_em': datetime.utcnow().isoformat() + 'Z',
        'versao_processador': '1.0.0',
        'itens_contados': len(dados.get('itens', []))
    }


def _salvar_no_s3(dados: dict, bucket: str, chave: str) -> None:
    """Serializa e salva um dict como JSON no S3."""
    conteudo = json.dumps(dados, ensure_ascii=False, indent=2).encode('utf-8')
    
    s3_client.put_object(
        Bucket=bucket,
        Key=chave,
        Body=conteudo,
        ContentType='application/json; charset=utf-8',   # MIME type
        # ServerSideEncryption='AES256',                 # Criptografia (opcional)
        # Metadata={'source': 'lambda-processador'},     # Metadados customizados
    )
    
    logger.info("Arquivo salvo: s3://%s/%s (%d bytes)", bucket, chave, len(conteudo))


def _listar_objetos(bucket: str, prefixo: str) -> list:
    """Lista objetos no S3 com um prefixo específico."""
    resposta = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=prefixo,
        MaxKeys=10                      # Limite de objetos retornados
    )
    
    objetos = [obj['Key'] for obj in resposta.get('Contents', [])]
    logger.info("Objetos encontrados em '%s': %d", prefixo, len(objetos))
    return objetos


def _criar_dados_exemplo() -> dict:
    """Cria dados de exemplo para demonstração."""
    return {
        'titulo': 'Dados de Exemplo',
        'criado_em': datetime.utcnow().isoformat() + 'Z',
        'itens': [
            {'id': 1, 'nome': 'Item A', 'valor': 100.50},
            {'id': 2, 'nome': 'Item B', 'valor': 200.75},
            {'id': 3, 'nome': 'Item C', 'valor': 50.00}
        ],
        'total': 351.25
    }


# ============================================================
# TESTE LOCAL
# Execute: BUCKET_NOME=meu-bucket python 02-lambda-com-s3.py
# ============================================================
if __name__ == '__main__':
    class MockContext:
        function_name = 'lambda-com-s3'
        aws_request_id = 'test-local-001'
        memory_limit_in_mb = 256
        def get_remaining_time_in_millis(self): return 14000
    
    # Para testar localmente, você precisa ter credenciais AWS configuradas
    resultado = handler({'arquivo': 'entrada/teste.json'}, MockContext())
    print(json.dumps(json.loads(resultado['body']), indent=2, ensure_ascii=False))
