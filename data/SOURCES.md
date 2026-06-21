# Sources and License

## Historical Football Data

Primary historical data:

- OpenFootball World Cup: `https://github.com/openfootball/worldcup`
- OpenFootball World Cup More: `https://github.com/openfootball/worldcup.more`

License:

- CC0-1.0

The Kaggle package is designed as a historical, reproducible dataset. It excludes live/provisional 2026 API data.

## Flags

Flag URLs are generated with FlagCDN:

- FlagCDN: `https://flagcdn.com/`
- FlagCDN code list: `https://flagcdn.com/en/codes.json`

FlagCDN is used for visual enrichment only. The dataset keeps two fields:

- `fifaCode`: football/team identity code.
- `flagCode`: code used by FlagCDN to render the correct flag.

## Transformation Notes

The ETL pipeline:

1. Downloads raw Football.TXT files.
2. Parses tournaments, groups, and matches.
3. Normalizes team identity.
4. Adds `fifaCode`, `flagCode`, and `flagUrl`.
5. Exports analysis-friendly CSV files.

The public Kaggle package is generated from `data/processed/` into `kaggle_dataset/`.

