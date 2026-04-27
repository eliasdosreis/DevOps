#!/usr/bin/env python3
# ============================================================
# ARQUIVO: 02-app.py
# O QUE FAZ: API Flask simples para containerizar no ECS Fargate
#
# ENDPOINTS:
#   GET /        → Página principal
#   GET /health  → Health check (usado pelo ECS/ALB)
#   GET /info    → Informações do container/ambiente
#   GET /echo    → Retorna os headers e params recebidos
#
# CUSTO: $0.00 — o custo é do ECS Fargate (template 05)
# ============================================================

import json
import logging
import os
import platform
import socket
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer

# ============================================================
# CONFIGURAÇÃO
# ============================================================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)

APP_PORT = int(os.environ.get('APP_PORT', 8080))
APP_ENV = os.environ.get('APP_ENV', 'development')
VERSAO = os.environ.get('APP_VERSION', '1.0.0')

# Timestamp de quando o container iniciou
INICIO_CONTAINER = datetime.now(timezone.utc).isoformat()


class APIHandler(BaseHTTPRequestHandler):
    """Handler HTTP simples sem dependências externas (mínimo)."""
    
    def do_GET(self):
        """Roteia requisições GET."""
        logger.info("%s %s", self.command, self.path)
        
        if self.path == '/':
            self._responder(200, self._homepage())
        
        elif self.path == '/health':
            self._responder(200, {
                'status': 'healthy',
                'timestamp': datetime.now(timezone.utc).isoformat()
            })
        
        elif self.path == '/info':
            self._responder(200, self._info_container())
        
        elif self.path.startswith('/echo'):
            self._responder(200, self._echo_request())
        
        else:
            self._responder(404, {'erro': f'Rota não encontrada: {self.path}'})
    
    def _responder(self, status: int, dados: dict, content_type='application/json'):
        """Envia a resposta HTTP."""
        corpo = json.dumps(dados, ensure_ascii=False, indent=2).encode('utf-8')
        
        self.send_response(status)
        self.send_header('Content-Type', f'{content_type}; charset=utf-8')
        self.send_header('Content-Length', str(len(corpo)))
        self.send_header('X-Container-Id', socket.gethostname())
        self.send_header('X-App-Version', VERSAO)
        self.end_headers()
        self.wfile.write(corpo)
    
    def _homepage(self) -> dict:
        return {
            'mensagem': '🚀 Container rodando no AWS ECS Fargate!',
            'aplicacao': 'AWS Learning — Módulo 8',
            'versao': VERSAO,
            'ambiente': APP_ENV,
            'endpoints': {
                'GET /':      'Esta página',
                'GET /health': 'Health check (ECS usa isto)',
                'GET /info':  'Informações do container',
                'GET /echo':  'Ecoa os headers da requisição'
            }
        }
    
    def _info_container(self) -> dict:
        """Retorna informações sobre o ambiente do container."""
        return {
            'container': {
                'hostname': socket.gethostname(),          # ID do container ECS
                'plataforma': platform.platform(),
                'python': platform.python_version(),
                'cpu_count': os.cpu_count(),
            },
            'aplicacao': {
                'versao': VERSAO,
                'ambiente': APP_ENV,
                'porta': APP_PORT,
                'iniciou_em': INICIO_CONTAINER,
                'uptime_segundos': (datetime.now(timezone.utc) - 
                                   datetime.fromisoformat(INICIO_CONTAINER)).total_seconds()
            },
            'variaveis_ambiente': {
                # Filtra apenas as vars relevantes (nunca exponha todas!)
                k: v for k, v in os.environ.items() 
                if k.startswith(('APP_', 'AWS_REGION', 'ECS_')) 
                and 'SECRET' not in k and 'KEY' not in k and 'PASSWORD' not in k
            }
        }
    
    def _echo_request(self) -> dict:
        """Ecoa os headers recebidos (útil para debug de redes)."""
        return {
            'method': self.command,
            'path': self.path,
            'client_ip': self.client_address[0],
            'headers': dict(self.headers)
        }
    
    def log_message(self, format, *args):
        """Sobrescreve o log padrão para usar o logging Python."""
        logger.info("HTTP %s", format % args)


def main():
    """Inicia o servidor HTTP."""
    logger.info("=" * 50)
    logger.info("Container iniciando — Módulo 8 AWS ECS Fargate")
    logger.info("Versão: %s | Ambiente: %s | Porta: %d", VERSAO, APP_ENV, APP_PORT)
    logger.info("Hostname (Container ID): %s", socket.gethostname())
    logger.info("=" * 50)
    
    server = HTTPServer(('0.0.0.0', APP_PORT), APIHandler)
    logger.info("Servidor iniciado em http://0.0.0.0:%d", APP_PORT)
    logger.info("Health check em http://localhost:%d/health", APP_PORT)
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Servidor encerrado pelo usuário")
        server.server_close()


if __name__ == '__main__':
    main()
