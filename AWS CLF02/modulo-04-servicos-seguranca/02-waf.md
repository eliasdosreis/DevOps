# AWS WAF — firewall de aplicação web

## 1. Analogia do Dia a Dia
AWS WAF é como um filtro de segurança na porta de um prédio: só deixa entrar quem está na lista, bloqueia visitantes suspeitos e pode ser ajustado conforme novas ameaças aparecem.

## 2. O que é (definição técnica oficial AWS)
AWS Web Application Firewall (WAF) protege aplicações web contra ataques comuns, como SQL injection e XSS, permitindo criar regras personalizadas de bloqueio e permissão.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS WAF
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Firewall de aplicação web
- Protege contra ataques como SQLi, XSS
- Regras customizáveis

PALAVRAS-CHAVE NA PROVA:
→ "firewall de aplicação"
→ "bloqueio de ataques web"
→ "regras personalizadas"

QUANDO USAR:
✅ Aplicações web públicas
✅ Proteger APIs

QUANDO NÃO USAR:
❌ Aplicações internas sem exposição
❌ Ignorar regras de segurança

DIFERENCIAIS:
- Integração com CloudFront e ALB
============================================================

## 4. Questões de Fixação
1. O que faz o AWS WAF?
A) Protege aplicações web contra ataques (correta)
B) Gera relatórios de custos
C) Cria backups
D) Gerencia usuários

Explicação:
- A) Correta: WAF protege aplicações web.
- B), C), D) não são funções do WAF.

Armadilha: confundir WAF com firewall de rede tradicional.

2. Com o que o WAF se integra?
A) CloudFront e ALB (correta)
B) S3
C) RDS
D) Lambda

Explicação:
- A) Correta: integra com CloudFront e ALB.
- B), C), D) não são integrações do WAF.

Armadilha: achar que WAF protege toda a rede.

## 5. Conceito Senior
- WAF permite resposta rápida a novas ameaças via regras dinâmicas.
- Essencial para compliance em aplicações públicas.

## 6. Resumo para Revisão
- WAF = firewall de aplicação web | protege contra SQLi/XSS | integra com CloudFront/ALB | regras customizáveis | essencial para apps públicas