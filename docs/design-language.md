# Kaji Design Language

Kaji is a native utility. The UI should feel calm beside Wi-Fi, battery, and
other system status items.

## Direction

```text
graphite utility + paper surface + muted copper accent
```

The old bright orange made the product feel louder than its job. Copper keeps a
warm identity without turning quota pressure into decoration.

## Palette

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| Background | `#F7F5F1` | `#151514` | App ground |
| Surface | `#FEFCF8` | `#20201E` | Popover and controls |
| Text | `#24231F` | `#EDEAE4` | Primary labels and values |
| Secondary | `#77736B` | `#9B968D` | Captions and metadata |
| Track | `#E4DFD5` | `#35322D` | Ring background |
| Accent | `#A76540` | `#B98259` | Normal quota arc |
| Warning | `#8F4B2F` | `#C66E42` | Near-limit arc |

## Rules

- Use copper only for quota arcs, selected controls, and tiny identity marks.
- Keep tracks neutral. Never tint the entire gauge orange/copper.
- Mono menu bar stays default. Color menu bar is opt-in.
- Use warning copper only for real threshold pressure.
- Avoid decorative gradients, glow, bokeh, or bright orange marketing accents.
- Keep surfaces native-adjacent: small radius, quiet contrast, dense but readable.

## Reference Direction

- Mobbin / Pinterest mood: native utility, low-saturation, restrained surfaces.
- Raycast / Linear mood: calm dark surfaces, sharp hierarchy, minimal accent use.

Kaji should not look like a dashboard. It should look like a trustworthy signal.
