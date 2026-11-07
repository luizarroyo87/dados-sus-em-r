# Taxa bruta x taxa padronizada

Reproduz o exemplo **hipotético** do carrossel *"Mais óbitos por 100 mil não significa, necessariamente, maior risco"*.

Dois municípios têm o mesmo risco de óbito em cada faixa etária, mas estruturas etárias diferentes:

| Município | Taxa bruta (por 100 mil) | Taxa padronizada (por 100 mil) |
| --- | --- | --- |
| A (25% com 60 anos ou mais) | 325 | 280 |
| B (10% com 60 anos ou mais) | 190 | 280 |

A taxa bruta de A é cerca de 70% maior que a de B (325 ÷ 190 = 1,71), embora o risco em cada idade seja o mesmo. A padronização direta, com uma população-padrão de 80% abaixo de 60 anos e 20% com 60 anos ou mais, elimina essa diferença.

## Arquivo

- `padronizacao_de_taxas.R`: monta os dados do exemplo, calcula as taxas brutas e aplica a padronização direta com uma função reutilizável, `taxa_padronizada_direta()`. Usa apenas o R base.

## Para usar com dados reais

- Informe sempre a população-padrão usada. O valor da taxa padronizada depende dela.
- A taxa padronizada serve para comparar e não representa o risco real da população.
- Com números pequenos, agregue anos ou use métodos de suavização.
