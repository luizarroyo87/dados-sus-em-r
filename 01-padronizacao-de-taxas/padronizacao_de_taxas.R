# =============================================================================
# Taxa bruta x taxa padronizada por idade (padronização direta)
# Exemplo HIPOTÉTICO do carrossel "Mais óbitos por 100 mil não significa,
# necessariamente, maior risco" (LinkedIn, 12/11/2026).
#
# Autor: Luiz Henrique Arroyo · InfoSaúde Estratégica
# Licença: MIT (veja LICENSE na raiz do repositório)
# Requer: apenas R base
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Dados do exemplo (hipotéticos)
# -----------------------------------------------------------------------------
# Dois municípios com o MESMO risco em cada faixa etária,
# mas com estruturas etárias diferentes.

taxa_por_idade <- c("<60" = 100, "60+" = 1000)   # óbitos por 100 mil hab.

# Proporção da população em cada faixa etária
estrutura <- data.frame(
  municipio = c("A", "B"),
  menos_60  = c(0.75, 0.90),
  mais_60   = c(0.25, 0.10)
)

# Para trabalhar com contagens, usamos 100 mil habitantes em cada município
populacao_total <- 100000

dados <- data.frame(
  municipio    = rep(estrutura$municipio, each = 2),
  faixa_etaria = rep(c("<60", "60+"), times = 2),
  populacao    = populacao_total * c(t(estrutura[, c("menos_60", "mais_60")]))
)
dados$obitos <- dados$populacao * taxa_por_idade[dados$faixa_etaria] / 1e5

print(dados)

# -----------------------------------------------------------------------------
# 2. Taxa bruta: total de óbitos / população total x 100 mil
# -----------------------------------------------------------------------------
taxa_bruta <- function(obitos, populacao, por = 1e5) {
  sum(obitos) / sum(populacao) * por
}

brutas <- sapply(split(dados, dados$municipio),
                 function(d) taxa_bruta(d$obitos, d$populacao))
print(round(brutas, 1))
# A = 325 ; B = 190  -> A parece ter risco 71% maior (325/190 = 1,71)

# -----------------------------------------------------------------------------
# 3. Padronização direta
# -----------------------------------------------------------------------------
# Aplica as taxas específicas de cada faixa etária a uma MESMA
# população-padrão e soma os óbitos "esperados".

taxa_padronizada_direta <- function(obitos, populacao, pop_padrao, por = 1e5) {
  stopifnot(length(obitos) == length(populacao),
            length(populacao) == length(pop_padrao))
  taxas_especificas <- obitos / populacao
  pesos <- pop_padrao / sum(pop_padrao)
  sum(taxas_especificas * pesos) * por
}

# População-padrão do exemplo: 80% abaixo de 60 anos, 20% com 60 anos ou mais
pop_padrao <- c("<60" = 80, "60+" = 20)

padronizadas <- sapply(split(dados, dados$municipio), function(d) {
  taxa_padronizada_direta(d$obitos, d$populacao, pop_padrao[d$faixa_etaria])
})
print(round(padronizadas, 1))
# A = 280 ; B = 280  -> a diferença desaparece

# -----------------------------------------------------------------------------
# 4. Resumo
# -----------------------------------------------------------------------------
resumo <- data.frame(
  municipio        = names(brutas),
  taxa_bruta       = round(brutas, 1),
  taxa_padronizada = round(padronizadas, 1),
  row.names        = NULL
)
print(resumo)

# Cuidados ao usar com dados reais:
# - Informe sempre qual população-padrão foi usada (ex.: Brasil, Censo 2022;
#   OMS 2000-2025). O valor da taxa padronizada muda conforme o padrão.
# - A taxa padronizada serve para COMPARAR; não é o risco real da população.
# - Com números pequenos, as taxas ficam instáveis: agregue anos ou use
#   métodos de suavização (ex.: bayesiano empírico).
