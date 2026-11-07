# =============================================================================
# Proporção de nascidos vivos prematuros por UF — Brasil, 2024
# Reproduz os números e o gráfico do carrossel do Dia Mundial da
# Prematuridade (LinkedIn, 17/11/2026).
#
# Autor: Luiz Henrique Arroyo · InfoSaúde Estratégica
# Licença: MIT (veja LICENSE na raiz do repositório)
# Requer: R (>= 4.1) e ggplot2  ->  install.packages("ggplot2")
#
# Fonte: MS/SVSA/CGIAE - Sistema de Informações sobre Nascidos Vivos (Sinasc),
# via TabNet/DATASUS. Dados finais de 2024, extraídos em 02/12/2025.
# Tabela: nascidos vivos por UF de residência da mãe x duração da gestação.
# =============================================================================

library(ggplot2)

# Rode este script a partir da pasta 02-prematuridade-sinasc
# (no RStudio: Session > Set Working Directory > To Source File Location)
dir.create("resultados", showWarnings = FALSE)

# -----------------------------------------------------------------------------
# 1. Leitura da tabela exportada do TabNet
# -----------------------------------------------------------------------------
sinasc <- read.csv2("dados/sinasc_2024_duracao_gestacao_uf.csv",
                    encoding = "UTF-8", check.names = FALSE)

# Conferência: as categorias somam o total de cada linha
categorias <- c("lt22", "s22_27", "s28_31", "s32_36",
                "s37_41", "s42mais", "ignorado")
stopifnot(all(rowSums(sinasc[, categorias]) == sinasc$total))

# Conferência: a soma das UFs é igual ao total do Brasil
ufs    <- sinasc[sinasc$uf != "Brasil", ]
brasil <- sinasc[sinasc$uf == "Brasil", ]
stopifnot(all(colSums(ufs[, c(categorias, "total")]) ==
              unlist(brasil[, c(categorias, "total")])))

# -----------------------------------------------------------------------------
# 2. Indicadores
# -----------------------------------------------------------------------------
# Prematuro: nascido vivo com menos de 37 semanas de gestação.
# Denominador: nascidos vivos com duração da gestação INFORMADA.
sinasc <- within(sinasc, {
  prematuros       <- lt22 + s22_27 + s28_31 + s32_36
  menos_32         <- lt22 + s22_27 + s28_31
  conhecida        <- total - ignorado
  pct_prematuros   <- 100 * prematuros / conhecida
  pct_menos_32     <- 100 * menos_32 / conhecida
  pct_ignorado     <- 100 * ignorado / total        # 100 - completude
})

tabela <- sinasc[order(-sinasc$pct_prematuros),
                 c("uf", "total", "prematuros", "pct_prematuros",
                   "pct_menos_32", "pct_ignorado")]
tabela[, 4:6] <- round(tabela[, 4:6], 1)
print(tabela, row.names = FALSE)

write.csv2(tabela, "resultados/prematuridade_uf_2024.csv",
           row.names = FALSE, fileEncoding = "UTF-8")

# Números citados no carrossel
with(sinasc[sinasc$uf == "Brasil", ], cat(sprintf(
  "\nBrasil 2024: %s prematuros | %.1f%% < 37 semanas | %.1f%% < 32 semanas | %.1f%% sem informação\n",
  format(prematuros, big.mark = ".", decimal.mark = ","), pct_prematuros, pct_menos_32, pct_ignorado)))

# -----------------------------------------------------------------------------
# 3. Gráfico
# -----------------------------------------------------------------------------
graf <- sinasc
graf$destaque <- ifelse(graf$uf == "Brasil", "Brasil", "UF")
graf$uf <- reorder(graf$uf, graf$pct_prematuros)

p <- ggplot(graf, aes(x = pct_prematuros, y = uf, fill = destaque)) +
  geom_col(width = 0.75) +
  geom_text(aes(label = paste0(formatC(pct_prematuros, format = "f", digits = 1,
                                       decimal.mark = ","), "%")),
            hjust = -0.15, size = 3.2) +
  scale_fill_manual(values = c(Brasil = "#E08A1E", UF = "#4FA3A2"),
                    guide = "none") +
  scale_x_continuous(limits = c(0, 19), expand = c(0, 0),
                     labels = function(x) paste0(x, "%")) +
  labs(title = "Proporção de nascidos vivos prematuros por UF, 2024",
       subtitle = "% de nascidos vivos com menos de 37 semanas, por UF de residência da mãe",
       x = NULL, y = NULL,
       caption = "Fonte: MS/SVSA/CGIAE, Sinasc (TabNet/DATASUS), dados finais de 2024") +
  theme_minimal(base_size = 11) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        plot.title.position = "plot")

ggsave("resultados/prematuridade_uf_2024.png", p,
       width = 7, height = 8, dpi = 200, bg = "white")

# -----------------------------------------------------------------------------
# 4. (Opcional) Partindo dos microdados do Sinasc
# -----------------------------------------------------------------------------
# Para quem quiser ir além (outros anos, municípios, estabelecimentos),
# o pacote microdatasus baixa os microdados direto do DATASUS.
# Atenção: o download do Brasil inteiro tem mais de 2 milhões de registros,
# e os números podem diferir um pouco do TabNet por causa da data de
# extração. Mude FALSE para TRUE para rodar.
if (FALSE) {
  # install.packages("remotes"); remotes::install_github("rfsaude/microdatasus")
  library(microdatasus)

  nv <- fetch_datasus(year_start = 2024, year_end = 2024,
                      information_system = "SINASC",
                      vars = c("CODMUNRES", "GESTACAO"))

  # GESTACAO: 1 = <22 sem; 2 = 22-27; 3 = 28-31; 4 = 32-36;
  #           5 = 37-41; 6 = 42 ou mais; 9 = ignorado
  nv$uf_res     <- substr(nv$CODMUNRES, 1, 2)          # código IBGE da UF
  nv$conhecida  <- nv$GESTACAO %in% as.character(1:6)
  nv$prematuro  <- nv$GESTACAO %in% as.character(1:4)

  micro <- aggregate(cbind(prematuro, conhecida) ~ uf_res, data = nv, FUN = sum)
  micro$pct_prematuros <- round(100 * micro$prematuro / micro$conhecida, 1)
  print(micro[order(-micro$pct_prematuros), ])
}
