# Data Dictionary

## tournaments.csv

One row per World Cup edition.

| Column | Type | Description |
|---|---|---|
| `year` | integer | Tournament year. |
| `name` | string | Standardized tournament name. |
| `host_info` | string | Host/period notes extracted from the source text when available. |

## teams.csv

One row per national team appearing in the historical dataset.

| Column | Type | Description |
|---|---|---|
| `team` | string | Team name used in the historical source. |
| `fifaCode` | string | Football/FIFA-style team code. |
| `flagCode` | string | FlagCDN code used to render the flag. |
| `flagUrl` | string | PNG flag URL from FlagCDN. |

Important: `fifaCode` and `flagCode` are intentionally separate.

## groups.csv

One row per team listed in a group for a tournament.

| Column | Type | Description |
|---|---|---|
| `tournament_year` | integer | Tournament year. |
| `group_name` | string | Group name, such as `Group A` or `Group 1`. |
| `team` | string | Team name. |
| `team_order` | integer | Order in which the team appears in the source group line. |
| `team_fifaCode` | string | FIFA-style code for the team. |
| `team_flagCode` | string | FlagCDN code for the team. |
| `team_flagUrl` | string | FlagCDN PNG URL. |

## matches.csv

One row per historical match.

| Column | Type | Description |
|---|---|---|
| `tournament_year` | integer | Tournament year. |
| `stage` | string | Tournament stage, such as group, semi-final, final, etc. |
| `match_date` | date | Match date in `YYYY-MM-DD` format. |
| `match_time` | string | Local match time when available. |
| `utc_offset` | string | UTC offset when available in the source. |
| `home_team` | string | First listed team in the source. |
| `away_team` | string | Second listed team in the source. |
| `home_goals` | integer | Main score goals for the first listed team. |
| `away_goals` | integer | Main score goals for the second listed team. |
| `result_extra` | string | Extra result context, such as halftime score, extra time, or penalties. |
| `venue` | string | Stadium or venue. |
| `city` | string | City when available. |
| `status` | string | Match status. Historical rows are `played`. |
| `home_fifaCode` | string | FIFA-style code for `home_team`. |
| `home_flagCode` | string | FlagCDN code for `home_team`. |
| `home_flagUrl` | string | FlagCDN PNG URL for `home_team`. |
| `away_fifaCode` | string | FIFA-style code for `away_team`. |
| `away_flagCode` | string | FlagCDN code for `away_team`. |
| `away_flagUrl` | string | FlagCDN PNG URL for `away_team`. |

## Row Counts

Current generated package:

| File | Rows |
|---|---:|
| `tournaments.csv` | 22 |
| `teams.csv` | 88 |
| `groups.csv` | 488 |
| `matches.csv` | 964 |

