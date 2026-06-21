# FIFA World Cup Historical Dataset

This dataset contains cleaned historical FIFA World Cup data from 1930 to 2022, prepared for analysis, dashboards, machine learning experiments, and football data storytelling.

The package is part of the World Cup Data Hub project. The Kaggle release is intentionally historical only: it does not include provisional 2026 API data, live updates, or non-verified match snapshots.

## What Is Included

- `tournaments.csv`: World Cup editions.
- `teams.csv`: national team identity table with separate `fifaCode`, `flagCode`, and FlagCDN URL.
- `groups.csv`: group-stage team composition by tournament edition.
- `matches.csv`: historical World Cup matches, scores, venues, stages, teams, and flag metadata.

## Dataset Scope

Current scope:

- Men FIFA World Cup tournaments from 1930 to 2022.
- Historical match results.
- Group compositions.
- Team identity metadata.
- FlagCDN URLs for visual use.

Out of scope:

- 2026 live or provisional match data.
- Minute-by-minute live data.
- Betting odds.
- Player-level event data for every edition.
- Fully normalized relational IDs. The Kaggle version is kept as analysis-friendly CSV files.

## Why `fifaCode` and `flagCode` Are Separate

Football team codes are not always equal to flag/country codes.

Examples:

| Team | fifaCode | flagCode |
|---|---|---|
| England | ENG | gb-eng |
| Scotland | SCO | gb-sct |
| Wales | WAL | gb-wls |
| South Korea | KOR | kr |
| Germany | GER | de |
| Côte d'Ivoire | CIV | ci |

Use `fifaCode` for football/team identity. Use `flagCode` or `flagUrl` for flags.

## Suggested Analysis Ideas

- Goals by tournament.
- Host country performance.
- Team appearances across tournaments.
- Knockout-stage trends.
- Match outcomes by region or era.
- Venue/city distribution.
- Group-stage scoring evolution.

## Files

See `DATA_DICTIONARY.md` for full column definitions.

## Sources

Primary historical data comes from OpenFootball public domain repositories. Flag URLs are generated using FlagCDN codes.

See `SOURCES.md` for source and license details.

## License

The historical football data source is CC0-1.0. The dataset is prepared for public Kaggle release under CC0-1.0.

