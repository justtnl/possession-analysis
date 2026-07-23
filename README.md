# Possession Analysis - What characteristics of a possession make it more likely to end in a shot or goal?

## Data Source
- Data provided by [StatsBomb Open Data]. This project uses their publicly available Copa América 2024 event data for research and educational purposes. Events were pulled using the [StatsBombR](https://github.com/statsbomb/StatsBombR) package.

## Research Questions
- How long are successful possessions? (Q1 - Q2)
    - average duration
    - number of events
    - number of passes
    - distance travelled
    - number of players involved
- Where do possessions start? (Q3)
    - which attacking third?
- How many passes generally lead to a shot? (Q4)
- Does possession speed matter? (Q5)
    - time of possession
- How does possession end? (Q6)
    - goal
    - interception
    - tackles
    - offside
    - clearance

## Methodology

### Unit of analysis
StatsBomb provides one row per individual event (pass, carry, shot tackle, etc.), each event is tagged as an individual with a 'possession id'.
Events were grouped into possessions (one row per possession) so that possession-level questions such as duration, number of passes, outcome, etc., could be answered directly since calculating based on one event alone is difficult. 

### Penalty shootout exclusion
Penalties were excluded (StatsBomb 'period == 5') were identified and removed from the dataset. Shoot out kicks were logged as single instantaneous possessions (single shot event with no other metrics - i.e passes, carries, dribbles) which did not represent possession characteristics in this project. There were no build up play or meaningful pattern to analyse. Including them would have distorted duration and activity level findings for 'Goal' outcome category. 

### Outcome classification
Goal 
  - A possession including a shot that results in a goal or an own goal. 

Shot (no goal)
  - A possession including a shot that did not result in a goal.

 Foul won
   - A possession ended when a team won a free kick.

Turnover
  - A possession ended via loss of the ball in open play (Passes, Duel, Miscontrol, Block, Dribble, Ball recovery). 

Interception
  - A possession ended via an opponent's interception.

Clearance
  - A possession ended via a defensive clearance.

Offside
  - A possession ended in an offside call.

Administrative/non-footballing events (half-time, substitutions, injury stoppages, etc.) were removed since they represent the game being paused or not in motion.

*Note: for simplicity, all shot outcomes (saved, off target, blocked, wayward) are grouped into a single "Shot (no goal)" category rather than analyzed separately, and tackles/dispossessions are grouped under "Turnover" rather than kept as a distinct outcome.

### Derived metrics
- **Duration** = difference between first and last event's elapsed time within a possession.
- **Starting third** = the pitch third in which possession began (Attacking, Middle or Defensive). (Each third is split into 40 yard sections based on StatsBomb 120 yard x-axis pitch size, with attacking direction always left-to-right.)
- **Distance travelled** = sum of straight line of on-ball movements (pass, carry, dribble, or shot).
- **Possession speed** = total distance traveled  divided by duration (yards/second).

### Limitations
- Data is only analyses a small section of the full data catalogue found in StatsBomb (Copa America 2024). Findings may not generalise other leagues or competitions. 
- Distance is measured in a straight line - curved balls or passes that are not straight, are not accounted for. Thus, true distance may be shorter.
- This analysis does not go in-depth on specific categories such as progressive carrying or the direction of passes.
- Small sample size for some outcome categories (Offside, n = 3) limit their overall effect on analysis.

## Key findings
- Possessions starting in the attacking third are far more likely to produce a shot (31.1%) than those starting in the middle (12.7%) or defensive third (7.96%) — the single strongest effect found in this analysis
- Only ~14% of all possessions produce a shot, and of those, ~10% result in a goal
- Goal-scoring possessions have the highest mean duration (32.7s) of any outcome, but a much lower median (14.1s) — a mix of quick breaks and patient buildup, rather than one consistent pattern
- Passing volume alone is a weak predictor of whether a possession creates a shot — total events (which include carries and dribbles) differentiate far more clearly

## Detailed results
### Q1 - How long are successful possessions?
- Goal and Shot (no goal) have highest mean duration (32.7s, 26.3s)
    - Mean/median gap (32.7s, 14.1s) → highest = right-skewed distribution (some possessions that are longer than the median affect gap) 
    - Shot to goal conversion rate = ~10%
- Turnover, Interception, Clearance and Foul won → mean/median gap is closer
    - (16.7s/11.7s, 16s/10.7s, 15.5s/9.1s, 14.5s/9.2s)
    - Generally shorter resolution compared to shots/goals (quick breaks and patient buildup)

| Outcome | n | Mean Duration (s) | Median Duration (s) |
| :---: | :---: | :---: | :---: |
|Goal | 69 | 32.7 | 14.1 |
|Shot (no goal) | 618 | 26.3 | 16.0 |
|Offside | 3 | 25.9 | 19.1 |
|Turnover | 3150 | 16.7 | 11.7 |
|Interception | 105 | 16.0 | 10.7 |
|Clearance | 315 | 15.5 | 9.1 |
|Foul won | 659 | 14.5 | 9.2 |

### Q2 - Possession in accordance to events, passes, players, and distance.
- Shot (no goal) leads on every metric - highest in events (24.7), passes (6.0), player involvements (8.6), and distance travelled (199 yards)
- Goal = second in → events (21.1) and player involvements (7.4) but middle in passes (5.1) [behind turnovers (5.4) and interception (5.4)]
- Passes has the smallest spread - weak predictor by itself.

| Outcome | n | Mean Events | Mean Passes | Mean Players | Mean Distance |
| :---: | :---: | :---: | :---: | :---: | :---: |
|Offside | 3 | 19 | 6.7 | 7.3 | 191 |
|Shot (no goal) | 618 | 24.7 | 6.0 | 8.6 | 199 |
|Interception | 105 | 18.0 | 5.4 | 6.8 | 129 |
|Turnover | 3150 | 18.1 | 18.1 | 5.4 | 6.3 | 144 |
|Goal | 69 | 21.1 | 5.1 | 7.4 | 155 |
|Clearance | 315 | 16.9 | 5.05 | 6.3 | 122 |
|Foul Won | 659 | 18.0 | 4.4 | 6.3 | 124 |

### Q3 - Where do Possessions start?
- Turnovers dominant every category but is smallest in attacking (49%) compared to defensive and middle third (69.5%, 64.9%) → starting closer to goal reduces the chance of simply losing the ball
- Combined shot + goal rate = attacking (31.1%) vs. defensive (7.96%) vs. middle (12.7%) → attacking third produces 2.5-4x more likely to produce a shot than the other two
- Foul won is highest in defensive half (15.7%) and middle (13.6%) compared to attacking (7.45%) → consistent with teams defending and committing fouls early to prevent counters or attack from reaching dangerous areas.


### Q4 - How many passes lead to a shot?
- Passing is a weak differentiator to determine if possession actually leads to goals → mean gap is small (5.94 v 5.20).
- Gap found in Q2 (shot attempt v goal) is much larger than found here → suggests non-passing actions matter more to creating a shot than passing

| Led to a shot | n | Mean passes | Median passes |
| :---: | :---: | :---: | :---: |
|FALSE | 4232 | 5.2 | 4 |
|TRUE | 687 | 5.94 | 4 |

### Q5 - Does possession speed matter?
- Shot (no goal) → has the highest mean and median speed (9.14yps, 8.45yps)
- Only 2 categories have the median speed greater than mean → clearance and offside (5.75yps v 6.53 yps, 5.25 yps v 7.47 yps), so left-skewed by some slow possessions are dragging the average down
- Overall ranking → shot (no goal) > goal > turnover > foul won > interception > clearance (offside excluded n=3 → too small)

| Outcome | n | Mean Speed | Median Speed |
| :---: | :---: | :---: | :---: |
|Shot (no goal) | 616 | 9.1 | 8.5 |
|Goal | 69 | 8.4 | 8.1 |
|Turnover | 2984 | 8.2 | 7.7 |
|Foul Won | 655 | 7.0 | 6.7 |
|Interception | 105 | 6.7 | 6.5 |
|Clearance | 315 | 5.8 | 6.5 |
|Offside | 3 | 5.3 | 7.5 |

### Q6 - How does possession end?
- Turnovers are highest at 64% > foul won (13.4%) > shot (no goal) - 12.6% > clearance (6.4%) > interception (2.13%) > goal (1.4%)
  - Turnovers dominate → consistent with football being a low-scoring sport where most possessions lead to no shot on goal
- Only 14% of possession produce a shot at goal, only 10% of those result in a goal
