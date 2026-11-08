# Sistema de Design Híbrido Linear-Apple e Arquitetura de Motion

Adotamos uma linguagem visual híbrida baseada no minimalismo utilitário e refinamento de superfícies do Linear.app e Apple Human Interface Guidelines, combinada com micro-interações táteis e motion fluido a 60 FPS no GitHub Pages e no aplicativo Flutter. Essa decisão elimina poluição decorativa artificial (partículas caóticas, néon saturado e gradientes ruidosos) em favor de tipografia geométrica precisa (`Plus Jakarta Sans` e `JetBrains Mono`), paleta monocromática escura (`#090a0f`), bordas com destaque de luz sob cursor (spotlight de 1px) e curvas contínuas (squircles sutis de 12px a 16px).

## Considerações e Alternativas

- **Descartado (SaaS Genérico / AI-Slop):** Efeitos de gradientes mesh multicoloridos, canvas com rajadas de partículas e temas alternativos excessivos, que adicionavam ruído cognitivo e degradavam o rigor acadêmico do projeto.
- **Descartado (Material Design 3 Padrão Puro):** Cartões com elevações excessivas e cantos excessivamente arredondados (pill shapes) que transmitiam aparência genérica de template não customizado.
- **Selecionado (Linear + Apple HIG):** Foco em macro-espaçamento, contraste tipográfico alto, micro-compressão em toques (`scale(0.98)`), transições cúbicas suaves (`cubic-bezier(0.16, 1, 0.3, 1)`) e respeito estrito a `prefers-reduced-motion`.
