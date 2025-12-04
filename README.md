# 📊 Análise de Dados SQL + R

> **Plataforma de Business Intelligence com Extração de Dados e Visualização Avançada**
>
> Projeto completo de análise de dados: Extração de bancos de dados SQL, transformação em R, visualizações interativas com Shiny e relatórios automáticos com RMarkdown.

---

## 🎯 Recursos

✅ **Extração SQL Avançada** - Queries complexas em PostgreSQL, MySQL, SQLite
✅ **Transformação de Dados** - Manipulação com dplyr, tidyverse
✅ **Visualizações Interativas** - Dashboards com Shiny e Plotly
✅ **Relatórios Dinâmicos** - RMarkdown com outputs automatizados
✅ **Análise Estatística** - Métodos descritivos e preditivos
✅ **Logística & Finanças** - Análises de supply chain e investimentos
✅ **Produção** - Scripts reutilizáveis e CI/CD

---

## 🛠️ Stack

**Linguagens:** R 4.0+ | SQL | Bash
**Ferramentas:** RStudio | Docker | PostgreSQL
**Pacotes R:** tidyverse | ggplot2 | Shiny | rmarkdown | caret

---

## 🚀 Início Rápido

```bash
# Clonar
git clone https://github.com/danilodk/data-analytics-sql-r.git

# Instalar dependências
cd data-analytics-sql-r
Rscript install_packages.R

# Executar análise
Rscript analysis/extract_data.R

# Gerar relatório
Rscript -e "rmarkdown::render('reports/analise.Rmd')"

# Executar dashboard Shiny
Rscript -e "shiny::runApp('shiny_app/')"
```

---

## 📁 Estrutura

```
data-analytics-sql-r/
├── sql/                    # Queries SQL
│   ├── logistics_data.sql
│   ├── financial_data.sql
│   └── aggregations.sql
├── analysis/               # Scripts R de análise
│   ├── extract_data.R
│   ├── transform_data.R
│   └── statistical_analysis.R
├── shiny_app/             # Dashboard interativo
│   ├── app.R
│   ├── ui.R
│   └── server.R
├── reports/               # RMarkdown para relatórios
│   ├── analise.Rmd
│   └── templates/
├── data/                  # Dados processados
│   ├── raw/
│   └── processed/
└── install_packages.R     # Setup de pacotes
```

---

## 📊 Análises Disponíveis

### Logística
- Rastreamento de movimentações
- Análise de rotas eficientes
- Predição de atrasos
- Otimização de custos

### Finanças
- Retorno de investimentos
- Análise de portfólio
- Previsão de fluxo de caixa
- Relatórios de lucratividade

---

## 📊 Exemplos de Uso

### Executar Query SQL
```r
library(RPostgres)
con <- dbConnect(RPostgres::Postgres(),
  dbname = "logistica_db",
  user = "admin",
  password = "senha"
)

data <- dbGetQuery(con, 
  "SELECT * FROM movimentacoes WHERE data >= '2025-01-01'")
```

### Transformar e Visualizar
```r
library(tidyverse)

data %>%
  filter(status == 'entregue') %>%
  group_by(rota) %>%
  summarise(custo_medio = mean(custo)) %>%
  ggplot(aes(x = rota, y = custo_medio)) +
  geom_col(fill = '#3498db')
```

---

## 💻 Requisitos

- R 4.0 ou superior
- RStudio (recomendado)
- PostgreSQL/MySQL/SQLite
- Git
- Docker (opcional)

---

## 🧪 Testes

```r
# Executar testes de código
testthat::test_dir('tests/')

# Verificar performance
profvis::profvis({
  source('analysis/extract_data.R')
})
```

---

## 📝 Licença

MIT License - Sinta-se livre para usar

---

## 👨‍💻 Autor

**Danilo Araujo** | Analista de Dados & Full Stack
- 📧 damdanilo2020@icloud.com
- 📱 (11) 99682-2641
- [LinkedIn](https://www.linkedin.com/in/danilo-ara%C3%BAjo-3592501b8/) | [GitHub](https://github.com/danilodk)

---

**⭐ Se útil, deixe uma estrela!**
