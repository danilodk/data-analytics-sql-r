#!/usr/bin/env Rscript
# ============================================================
# Análise Avançada de Logística e Suprimentos
# Projeto: Data Analytics SQL + R
# Autor: Danilo Araujo
# Data: Dezembro 2025
# ============================================================

# Carregar bibliotecas necessarias
library(tidyverse)      # Manipulacao de dados
library(DBI)            # Conexao com banco de dados
library(RPostgres)      # Driver PostgreSQL
library(ggplot2)        # Visualizacoes
library(dplyr)          # Data wrangling
library(lubridate)      # Manipulacao de datas

# ============================================================
# CONEXAO COM BANCO DE DADOS
# ============================================================

# Configurar conexão (usar variáveis de ambiente em produção)
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "logistica_db"),
  user = Sys.getenv("DB_USER", "admin"),
  password = Sys.getenv("DB_PASSWORD", ""),
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", 5432))
)

cat("[INFO] Conectado ao banco de dados com sucesso!\\n")

# ============================================================
# EXTRACAO DE DADOS
# ============================================================

# Query para extrair dados de movimentação de logística
query_movimentacoes <- "
SELECT 
  id_movimento,
  data_movimentacao,
  rota,
  origem,
  destino,
  produto,
  quantidade,
  valor_frete,
  status,
  dias_atraso
FROM movimentacoes
WHERE data_movimentacao >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY data_movimentacao DESC
"

# Executar query
movimentacoes <- dbGetQuery(con, query_movimentacoes)

cat("[INFO] Extração de", nrow(movimentacoes), "registros concluída!\\n")

# ============================================================
# TRANSFORMACAO E LIMPEZA
# ============================================================

# Converter tipos de dados
movimentacoes <- movimentacoes %>%
  mutate(
    data_movimentacao = as.Date(data_movimentacao),
    valor_frete = as.numeric(valor_frete),
    quantidade = as.numeric(quantidade),
    dias_atraso = as.numeric(dias_atraso),
    status = factor(status, 
      levels = c("Em Transito", "Entregue", "Atrasado", "Cancelado")),
    mes = month(data_movimentacao),
    semana = week(data_movimentacao),
    dia_semana = wday(data_movimentacao, label = TRUE)
  )

# Remover valores faltantes
movimentacoes <- na.omit(movimentacoes)

cat("[INFO] Dados transformados! Total:", nrow(movimentacoes), "linhas\\n")

# ============================================================
# ANALISE DESCRITIVA
# ============================================================

cat("\\n[ANALISE DESCRITIVA]\\n")
cat("==============================\\n")

# Resumo estatístico
cat("\\nValor médio do frete: R$", 
    round(mean(movimentacoes$valor_frete), 2), "\\n")
cat("Quantidade média transportada:", 
    round(mean(movimentacoes$quantidade), 2), "unidades\\n")
cat("Atraso médio: ", round(mean(movimentacoes$dias_atraso), 2), "dias\\n")

# Distribuição por status
status_summary <- movimentacoes %>%
  group_by(status) %>%
  summarise(
    total = n(),
    percentual = round(n() / nrow(movimentacoes) * 100, 2),
    valor_total = sum(valor_frete),
    .groups = "drop"
  )

cat("\\nDistribuição por Status:\\n")
print(status_summary)

# ============================================================
# ANALISE POR ROTA
# ============================================================

analise_rotas <- movimentacoes %>%
  group_by(rota) %>%
  summarise(
    total_movimentacoes = n(),
    custo_medio = mean(valor_frete),
    custo_total = sum(valor_frete),
    quantidade_media = mean(quantidade),
    atraso_medio = mean(dias_atraso),
    taxa_atraso = round(sum(dias_atraso > 0) / n() * 100, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(custo_total))

cat("\\n[TOP 5 ROTAS POR CUSTO TOTAL]\\n")
print(head(analise_rotas, 5))

# ============================================================
# VISUALIZACOES
# ============================================================

# Gráfico 1: Distribuição de Status
p1 <- movimentacoes %>%
  group_by(status) %>%
  summarise(total = n(), .groups = "drop") %>%
  ggplot(aes(x = status, y = total, fill = status)) +
  geom_col() +
  geom_text(aes(label = total), vjust = -0.5) +
  theme_minimal() +
  labs(
    title = "Distribuição de Status de Movimentações",
    x = "Status",
    y = "Total de Movimentações"
  )

# Gráfico 2: Custo de Frete por Rota (Top 10)
p2 <- analise_rotas %>%
  head(10) %>%
  ggplot(aes(x = reorder(rota, custo_total), y = custo_total, fill = custo_total)) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top 10 Rotas por Custo Total",
    x = "Rota",
    y = "Custo Total (R$)"
  )

# Gráfico 3: Taxa de Atraso por Rota
p3 <- analise_rotas %>%
  head(8) %>%
  ggplot(aes(x = reorder(rota, taxa_atraso), y = taxa_atraso, fill = taxa_atraso)) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Taxa de Atraso por Rota",
    x = "Rota",
    y = "Taxa de Atraso (%)"
  )

# Salvar gráficos
ggsave("plots/status_distribution.png", p1, width = 10, height = 6)
ggsave("plots/top_rotas.png", p2, width = 12, height = 8)
ggsave("plots/atraso_por_rota.png", p3, width = 12, height = 8)

cat("[INFO] Gráficos salvos em plots/\\n")

# ============================================================
# RECOMENDACOES E INSIGHTS
# ============================================================

cat("\\n[INSIGHTS E RECOMENDACOES]\\n")
cat("==============================\\n")

# Rotas com maior taxa de atraso
rotas_criticas <- analise_rotas %>%
  filter(taxa_atraso > 20) %>%
  arrange(desc(taxa_atraso))

if (nrow(rotas_criticas) > 0) {
  cat("\\n[ALERTA] Rotas com taxa de atraso > 20%:\\n")
  print(rotas_criticas)
  cat("\\nRECOMENDACAO: Revisar processos logísticos nestas rotas.\\n")
}

# Oportunidade de economia
custo_evitavel <- movimentacoes %>%
  filter(dias_atraso > 0) %>%
  summarise(custo_atrasos = sum(valor_frete * dias_atraso / 30))

cat("\\n[ECONOMIA POTENCIAL]\\n")
cat("Custo estimado de atrasos: R$", 
    round(custo_evitavel$custo_atrasos, 2), "\\n")
cat("Recomendação: Implementar melhorias operacionais\\n")

# ============================================================
# EXPORTAR RESULTADOS
# ============================================================

# Salvar dados processados
write.csv(analise_rotas, "data/processed/analise_rotas_resumo.csv", row.names = FALSE)
write.csv(movimentacoes, "data/processed/movimentacoes_completo.csv", row.names = FALSE)

cat("\\n[INFO] Dados processados exportados para data/processed/\\n")

# ============================================================
# FECHAR CONEXAO
# ============================================================

dbDisconnect(con)
cat("\\n[INFO] Conexão fechada. Análise concluída!\\n")
cat("[TEMPO] Execução finalizada em", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\\n")
