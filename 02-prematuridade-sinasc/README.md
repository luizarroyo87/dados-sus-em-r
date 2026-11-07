# Prematuridade por UF — Brasil, 2024

Reproduz os números e o gráfico do carrossel do **Dia Mundial da Prematuridade** (17/11/2026).

## Resultado principal

Em 2024, **12,4%** dos nascidos vivos no Brasil (294.123 bebês) tiveram menos de 37 semanas de gestação, e 1,7% nasceram antes de 32 semanas. Entre as UFs, a proporção variou de 10,8% (Espírito Santo) a 16,8% (Roraima).

## Fonte e método

- **Fonte:** MS/SVSA/CGIAE, Sistema de Informações sobre Nascidos Vivos (Sinasc), via [TabNet/DATASUS](http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sinasc/cnv/nvuf.def). Dados finais de 2024, extraídos em 02/12/2025.
- **Tabela:** nascidos vivos por UF de residência da mãe, segundo a duração da gestação.
- **Prematuro:** nascido vivo com menos de 37 semanas de gestação.
- **Denominador:** nascidos vivos com duração da gestação informada. A proporção de registros sem essa informação também é calculada (0,7% no Brasil).

## Arquivos

- `dados/sinasc_2024_duracao_gestacao_uf.csv`: tabela exportada do TabNet (separador `;`).
- `prematuridade_sinasc.R`: confere os totais, calcula os indicadores, salva a tabela e o gráfico em `resultados/`. Requer o pacote `ggplot2`.
- A seção 4 do script, opcional, mostra como chegar ao mesmo indicador a partir dos microdados, com o pacote [microdatasus](https://github.com/rfsaude/microdatasus). Os números podem diferir um pouco do TabNet por causa da data de extração.

## Cuidados de interpretação

- O método de estimativa da idade gestacional (data da última menstruação ou ultrassom) varia entre serviços e pode afetar a classificação de bebês perto das 37 semanas.
- Diferenças entre UFs podem refletir o perfil das gestantes, a assistência ao pré-natal e ao parto e a qualidade do registro. Proporção não indica causa.
