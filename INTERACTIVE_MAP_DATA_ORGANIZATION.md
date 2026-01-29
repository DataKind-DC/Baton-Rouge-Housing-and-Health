# Interactive Map Data Organization Framework
## Cook County Housing & Veterans Data

---

## TAB 1: HOUSING SUPPLY & CHARACTERISTICS

### Group 1.1: Housing Supply Overview
**Primary Map Layers:**
- Total_Housing_Units
- Pct_Vacant
- Occupancy_Rate
- Housing_units_per_sqmi (density)

**Sidebar Context Variables:**
- Total_Population
- Occupied_Units
- Vacant_Units
- Avg_Household_Size
- Population_per_sqmi

**Why Together:** Shows basic housing stock and utilization. Vacancy and density help identify housing pressure or abandonment.

---

### Group 1.2: Housing Tenure
**Primary Map Layers:**
- Pct_Owner_Occupied
- Pct_Renter_Occupied
- Owner_Occupied (count)
- Renter_Occupied (count)

**Sidebar Context Variables:**
- Median_Home_Value
- Median_Gross_Rent
- Median_Income_Owner_Occupied
- Median_Income_Renter_Occupied
- Total_Households

**Why Together:** Ownership patterns reveal neighborhood stability and wealth. Comparing owner/renter splits with income shows affordability dynamics.

---

### Group 1.3: Structure Types
**Primary Map Layers:**
- Pct_Single_Family
- Pct_Multi_Family_5_Plus
- Multi_Family_10_Plus_Units (count)
- Multi_Family_20_Plus_Units (count)

**Sidebar Context Variables:**
- Single_Family_Detached
- Single_Family_Attached
- Multi_Family_2_4_Units
- Mobile_Home
- Gross_housing_density_per_sqmi

**Why Together:** Shows urban form and density patterns. Single-family vs multi-family reveals neighborhood character and development patterns.

---

### Group 1.4: Unit Size & Bedrooms
**Primary Map Layers:**
- Three_Plus_Bedroom_Units
- Two_Plus_Bedroom_Units
- One_Bedroom (count)

**Sidebar Context Variables:**
- Two_Bedrooms
- Three_Bedrooms
- Four_Bedrooms
- Five_Plus_Bedrooms
- Pct_Households_With_Children
- Large_Owner_Households_4_Plus
- Large_Renter_Households_4_Plus

**Why Together:** Unit size should correlate with household composition. Mismatches (small units with children, large units with singles) reveal housing stress or opportunity.

---

### Group 1.5: Housing Age
**Primary Map Layers:**
- Built_2020_Later
- Built_2010_2019
- Built_2000_2009
- Built_Before_1960

**Sidebar Context Variables:**
- Built_1990_1999
- Built_1980_1989
- Built_1970_1979
- Built_1960_1969
- Median_Home_Value (newer housing often more expensive)

**Why Together:** Age of housing stock reveals investment patterns and maintenance needs. Correlates with home values and neighborhood evolution.

---

## TAB 2: HOUSING AFFORDABILITY

### Group 2.1: Housing Costs
**Primary Map Layers:**
- Median_Home_Value
- Median_Gross_Rent
- Price_To_Income_Ratio
- Rent_Burden_Ratio

**Sidebar Context Variables:**
- Median_Household_Income
- Median_Income_Owner_Occupied
- Median_Income_Renter_Occupied
- Pct_Below_Poverty
- High_Rent_Burden_50_Plus_Units

**Why Together:** Core affordability metrics. Price-to-income and rent-burden ratios show true affordability relative to local incomes.

---

### Group 2.2: Cost Burden & Financial Stress
**Primary Map Layers:**
- High_Rent_Burden_30_Plus_Units (30%+ of income on rent)
- High_Rent_Burden_50_Plus_Units (50%+ of income on rent)
- Pct_Below_Poverty

**Sidebar Context Variables:**
- Median_Gross_Rent
- Median_Household_Income
- Pct_Renter_Occupied
- HH_Received_SNAP
- Pct_HH_SNAP
- HH_With_Public_Assistance

**Why Together:** Identifies areas with severe housing cost burden. SNAP and public assistance show broader economic hardship.

---

### Group 2.3: Income Distribution
**Primary Map Layers:**
- Median_Household_Income
- Low_Income_Under_35K
- High_Income_100K_Plus

**Sidebar Context Variables:**
- Middle_Income_35K_100K
- Individual income brackets (Income_Under_10K through Income_200K_Plus)
- Below_Poverty_Level
- Children_Below_Poverty
- Pct_Below_Poverty

**Why Together:** Shows income inequality and concentration. Helps identify areas needing affordable housing or economic development.

---

## TAB 3: DEMOGRAPHICS

### Group 3.1: Population Overview
**Primary Map Layers:**
- Total_Population
- Population_per_sqmi
- Avg_Household_Size

**Sidebar Context Variables:**
- Total_Housing_Units
- Occupied_Units
- Total_Households
- Family_Households
- Nonfamily_Living_Alone

**Why Together:** Basic population metrics that provide context for all other variables.

---

### Group 3.2: Race & Ethnicity
**Primary Map Layers:**
- Pct_White
- Pct_Black
- Pct_Hispanic
- Pct_Asian

**Sidebar Context Variables:**
- White_Alone (count)
- Black_Alone (count)
- Hispanic_Latino (count)
- Asian_Alone (count)
- Total_Population
- Median_Household_Income (shows racial wealth gaps)

**Why Together:** Shows demographic composition and segregation patterns. Adding income reveals racial equity issues.

---

### Group 3.3: Household Composition
**Primary Map Layers:**
- Pct_Households_With_Children
- Family_Households
- Nonfamily_Living_Alone

**Sidebar Context Variables:**
- Total_Own_Children_Under_18
- Children_In_Married_Couple_Families
- Children_In_Single_Mother_Families
- Large_Owner_Households_4_Plus
- Large_Renter_Households_4_Plus
- Multigenerational_Households
- Pct_Multigenerational
- Grandparents_Responsible_For_Grandchildren

**Why Together:** Reveals family structure and caregiving arrangements. Important for understanding housing needs and social services demand.

---

## TAB 4: VETERANS

### Group 4.1: Veteran Population Overview
**Primary Map Layers:**
- Vet_Total_Veterans
- Pct_Veterans_Of_Adult_Pop
- Veterans_per_sqmi
- Veterans_per_1000_pop

**Sidebar Context Variables:**
- Vet_Total_Pop_18_Plus
- Vet_Total_Non_Veterans
- Total_Population
- Median_Household_Income

**Why Together:** Shows veteran concentration. Density metrics help identify communities with strong veteran presence.

---

### Group 4.2: Veteran Demographics
**Primary Map Layers:**
- Pct_Veterans_Male
- Pct_Veterans_Female
- Vet_Total_65_Plus (age group)

**Sidebar Context Variables:**
- Vet_Male_Veterans
- Vet_Female_Veterans
- Vet_Total_18_34
- Vet_Total_35_54
- Vet_Total_55_64
- Vet_Total_65_74
- Vet_Total_75_Plus
- Pct_Veterans_18_34
- Pct_Veterans_65_Plus

**Why Together:** Age and gender reveal different veteran cohorts with different needs. Younger veterans need jobs, older need healthcare.

---

### Group 4.3: Veteran Race & Ethnicity
**Primary Map Layers:**
- Pct_Veterans_White
- Pct_Veterans_Black
- Pct_Veterans_Latino
- Pct_Veterans_Asian

**Sidebar Context Variables:**
- Vet_Total_White
- Vet_Total_Black
- Vet_Total_Latino
- Vet_Total_Asian
- Compare with overall population percentages (Pct_White, Pct_Black, etc.)

**Why Together:** Shows diversity of veteran population compared to general population. Reveals over/under-representation.

---

### Group 4.4: Period of Service
**Primary Map Layers:**
- Vet_Gulf_War_2001_Later
- Vet_Vietnam_Era
- Vet_Gulf_War_1990_2001

**Sidebar Context Variables:**
- Vet_Korean_War
- Vet_World_War_II
- Vet_Other_Periods
- Vet_Total_Veterans
- NOTE: Veterans can serve in multiple periods

**Why Together:** Shows which conflicts veterans served in. Important for understanding benefit eligibility and service era-specific needs.

---

### Group 4.5: Veteran Employment & Income
**Primary Map Layers:**
- Pct_Veterans_Employed
- Pct_Veterans_Unemployed
- Vet_Median_Income_Veterans

**Sidebar Context Variables:**
- Vet_Veterans_18_64_Total
- Vet_Veterans_In_Labor_Force
- Vet_Veterans_Employed
- Vet_Veterans_Unemployed
- Vet_Veterans_Not_In_Labor_Force
- Vet_Median_Income_Non_Veterans
- Median_Household_Income

**Why Together:** Shows veteran economic outcomes. Compare veteran income to non-veterans to see if they're doing better/worse.

---

## TAB 5: HEALTH & INSURANCE

### Group 5.1: Overall Coverage Status
**Primary Map Layers:**
- Pct_No_Health_Insurance (UNINSURED - most important!)
- Pct_With_Health_Insurance
- With_Health_Insurance (count)
- No_Health_Insurance (count)

**Sidebar Context Variables:**
- Total_Pop_Insurance_Universe
- Median_Household_Income
- Pct_Below_Poverty
- Pct_Employed_With_Insurance (Employment-based health coverage)
- Compare to city/county average

**Why Together:** Uninsured rate is the key metric. Income and poverty show why people lack coverage.

---

### Group 5.2: Private Insurance
**Primary Map Layers:**
- Pct_With_Private_Insurance
- Pct_With_Employer_Insurance
- Pct_With_DirectPurchase_Insurance (Marketplace/ACA)

**Sidebar Context Variables:**
- With_Private_Insurance
- With_Employer_Insurance
- With_DirectPurchase_Insurance
- Median_Household_Income
- Income distribution variables
- Pct_Below_Poverty

**Why Together:** Shows access to private coverage. Employer insurance correlates with good jobs. Marketplace usage shows self-employment or job gaps.

---

### Group 5.3: Public Insurance Programs
**Primary Map Layers:**
- Pct_With_Medicare
- Pct_With_Medicaid
- Pct_With_TRICARE
- Pct_With_VA_HealthCare

**Sidebar Context Variables:**
- With_Medicare (count)
- With_Medicaid (count)
- With_TRICARE (count)
- With_VA_HealthCare (count)
- Pct_Below_Poverty
- Vet_Total_Veterans
- Population age distribution
- Pct_With_Public_Coverage (total)

**Why Together:** Different public programs serve different populations (elderly, low-income, military/veterans). High Medicaid = poverty. High Medicare = elderly.

---

### Group 5.4: Military & Veteran Healthcare
**Primary Map Layers:**
- Pct_With_TRICARE
- Pct_With_VA_HealthCare
- Vet_Total_Veterans

**Sidebar Context Variables:**
- With_TRICARE
- With_VA_HealthCare
- Vet_Total_Veterans
- Veterans_per_1000_pop
- Pct_Employed_With_Insurance (Employment-based health coverage)
- Median_Household_Income

**Why Together:** Shows veteran healthcare usage. Compare TRICARE vs VA to see active duty families vs veteran usage patterns. Employment-based insurance shows general workforce health coverage.

---

### Group 5.5: Coverage Gaps & Vulnerable Populations
**Primary Map Layers:**
- Pct_No_Health_Insurance
- No_Health_Insurance (count)
- Pct_Below_Poverty

**Sidebar Context Variables:**
- Pct_Hispanic (often high uninsured rates)
- Pct_With_DirectPurchase_Insurance (marketplace uptake)
- Median_Household_Income
- HH_Received_SNAP
- Children_Below_Poverty
- Pct_Renter_Occupied

**Why Together:** Identifies vulnerable populations. Hispanic communities often have high uninsured rates. Poverty predicts lack of coverage.

---

## TAB 6: EDUCATION & OPPORTUNITY

### Group 6.1: Educational Attainment (General Population)
**Primary Map Layers:**
- Pct_Bachelors_Plus
- Pct_Less_Than_HS
- Pct_Graduate

**Sidebar Context Variables:**
- Total_Pop_25_Plus
- Less_Than_HS
- HS_Grad_Or_Equivalent
- Some_College_Or_Associates
- Bachelors_Degree
- Graduate_Or_Professional
- Median_Household_Income
- Median_Home_Value

**Why Together:** Education strongly correlates with income and home values. Shows opportunity and investment patterns.

---

### Group 6.2: Veteran vs Non-Veteran Education
**Primary Map Layers:**
- Vet_Education_Bachelors_Plus
- NonVet_Education_Bachelors_Plus

**Sidebar Context Variables:**
- Vet_Education_Less_Than_HS
- Vet_Education_HS_Grad
- Vet_Education_Some_College
- NonVet_Education_Less_Than_HS
- NonVet_Education_HS_Grad
- NonVet_Education_Some_College
- Vet_Median_Income_Veterans
- Vet_Median_Income_Non_Veterans

**Why Together:** Shows if veterans have better/worse education than non-veterans. GI Bill impact visible here.

---

## TAB 7: ECONOMIC HARDSHIP

### Group 7.1: Poverty & Assistance Programs
**Primary Map Layers:**
- Pct_Below_Poverty
- Pct_HH_SNAP
- Pct_HH_Public_Assistance

**Sidebar Context Variables:**
- Below_Poverty_Level
- Children_Below_Poverty
- HH_Received_SNAP
- HH_With_Public_Assistance
- Median_Household_Income
- Low_Income_Under_35K
- Pct_With_Medicaid

**Why Together:** Multiple indicators of economic distress. SNAP and cash assistance show safety net reliance.

---

### Group 7.2: Child Poverty & Family Hardship
**Primary Map Layers:**
- Children_Below_Poverty
- Pct_Below_Poverty
- Children_In_Single_Mother_Families

**Sidebar Context Variables:**
- Total_Own_Children_Under_18
- Children_In_Married_Couple_Families
- Pct_Households_With_Children
- HH_Received_SNAP
- Pct_HH_SNAP
- Median_Household_Income
- High_Rent_Burden_50_Plus_Units

**Why Together:** Child poverty is particularly concerning. Single-parent families face higher economic stress. SNAP usage and rent burden show acute need.

---

## TAB 8: TRANSPORTATION & CONNECTIVITY

### Group 8.1: Commute Patterns
**Primary Map Layers:**
- Pct_Commute_60_Plus (long commutes)
- Pct_Commute_Under_30
- Pct_Work_At_Home

**Sidebar Context Variables:**
- Total_Workers_Commute_Universe
- Commute_Under_30_Min
- Commute_30_59_Min
- Commute_60_Plus_Min
- Work_At_Home
- Median_Household_Income
- Pct_Owner_Occupied (long commutes often in homeowner suburbs)

**Why Together:** Commute time affects quality of life. Long commutes suggest job-housing mismatch or choice to live further out.

---

### Group 8.2: Vehicle Access
**Primary Map Layers:**
- Pct_HH_No_Vehicle
- Pct_Renter_No_Vehicle
- Pct_Owner_No_Vehicle

**Sidebar Context Variables:**
- Total_No_Vehicle
- Total_With_Vehicle
- Owner_No_Vehicle
- Renter_No_Vehicle
- Pct_Below_Poverty
- Pct_Commute_60_Plus (no car + long commute = hardship)
- Population_per_sqmi (urban areas need fewer cars)

**Why Together:** Car access affects job access. Renters without cars face mobility challenges. Urban density makes carlessness more viable.

---

### Group 8.3: Digital Access
**Primary Map Layers:**
- Pct_HH_With_Broadband
- Pct_HH_No_Computer
- Pct_HH_With_Internet

**Sidebar Context Variables:**
- HH_With_Internet
- HH_Broadband
- No_Computer
- Total_Households_Internet_Universe
- Median_Household_Income
- Pct_Below_Poverty
- Pct_Bachelors_Plus (education correlates with tech access)

**Why Together:** Digital divide affects education, employment, healthcare access. Income and education strongly predict connectivity.

---

## TAB 9: HOUSING MOBILITY & STABILITY

### Group 9.1: Residential Stability
**Primary Map Layers:**
- Pct_Same_House_1_Year
- Pct_Moved_Since_2020
- Pct_Moved_Since_2010

**Sidebar Context Variables:**
- Same_House_1_Year_Ago
- Moved_Within_County
- Moved_From_Different_County
- Moved_From_Different_State
- Moved_From_Abroad
- Pct_Owner_Occupied (owners more stable)
- Pct_Renter_Occupied (renters more mobile)

**Why Together:** Shows neighborhood stability or turnover. Owner/renter splits explain movement patterns.

---

### Group 9.2: Move-In Timing & Housing Age
**Primary Map Layers:**
- Moved_In_2020_Later (recent arrivals)
- Moved_In_Before_1990 (long-term residents)

**Sidebar Context Variables:**
- Moved_In_2010_2019
- Moved_In_2000_2009
- Moved_In_1990_1999
- Built_2020_Later (new construction attracts movers)
- Median_Home_Value
- Median_Gross_Rent

**Why Together:** When people moved in vs when housing built reveals gentrification or disinvestment patterns.

---

## TAB 10: DISABILITY & SPECIAL NEEDS

### Group 10.1: Disability Prevalence
**Primary Map Layers:**
- Pct_With_Disability
- Total_With_Disability

**Sidebar Context Variables:**
- Total_No_Disability
- Total_Pop_Disability_Universe
- Pct_Veterans_With_Service_Disability
- Vet_Has_Service_Disability
- Median_Household_Income
- Pct_With_Medicaid (disability often leads to Medicaid)

**Why Together:** Shows communities with accessibility needs. Income drops with disability. Veterans have service-connected disabilities.

---

### Group 10.2: Complex Caregiving Arrangements
**Primary Map Layers:**
- Pct_Multigenerational
- Pct_Grandparents_Caring
- Elderly_Living_Alone

**Sidebar Context Variables:**
- Multigenerational_Households
- Grandparents_Responsible_For_Grandchildren
- Pct_Households_With_Children
- Median_Household_Income
- Three_Plus_Bedroom_Units (need space for multi-gen)

**Why Together:** Shows non-traditional household arrangements. Often driven by economic necessity or cultural preference.

---

## CROSS-TAB ANALYSIS SUGGESTIONS

### Most Powerful Combinations Across Tabs:

**1. Affordability Crisis Analysis:**
Map Layer: High_Rent_Burden_50_Plus_Units
Sidebar from multiple tabs:
- Median_Gross_Rent (Housing)
- Median_Household_Income (Economic)
- Pct_Below_Poverty (Economic)
- Pct_No_Health_Insurance (Health)
- Pct_HH_SNAP (Hardship)

**2. Veteran Needs Assessment:**
Map Layer: Vet_Total_Veterans
Sidebar from multiple tabs:
- Pct_Veterans_Unemployed (Veterans)
- Pct_With_VA_HealthCare (Health)
- Pct_Veterans_With_Service_Disability (Disability)
- Vet_Median_Income_Veterans (Economic)
- Median_Home_Value (Housing)

**3. Opportunity Mapping:**
Map Layer: Pct_Bachelors_Plus
Sidebar from multiple tabs:
- Median_Household_Income (Economic)
- Median_Home_Value (Housing)
- Pct_With_Employer_Insurance (Health)
- Pct_Below_Poverty (Hardship)
- Pct_HH_With_Broadband (Connectivity)

**4. Child Well-Being Index:**
Map Layer: Children_Below_Poverty
Sidebar from multiple tabs:
- Pct_Households_With_Children (Demographics)
- Children_In_Single_Mother_Families (Demographics)
- Pct_HH_SNAP (Hardship)
- Three_Plus_Bedroom_Units (Housing)
- Pct_No_Health_Insurance (Health)

**5. Gentrification/Displacement Risk:**
Map Layer: Median_Home_Value (show change over time if data available)
Sidebar from multiple tabs:
- Pct_Renter_Occupied (Housing)
- Moved_In_2020_Later (Mobility)
- Pct_Below_Poverty (Hardship)
- Pct_White vs Pct_Black (Demographics)
- High_Rent_Burden_50_Plus_Units (Affordability)

**6. Transit Dependency:**
Map Layer: Pct_HH_No_Vehicle
Sidebar from multiple tabs:
- Pct_Commute_60_Plus (Transportation)
- Below_Poverty_Level (Economic)
- Population_per_sqmi (Demographics)
- Pct_Renter_Occupied (Housing)
- Pct_With_Medicaid (Health - shows income)

---

## UI/UX RECOMMENDATIONS

### Color Schemes by Tab:
- **Housing:** Blues (cool, structural)
- **Demographics:** Greens (growth, life)
- **Economic:** Yellows to reds (caution to danger for poverty)
- **Veterans:** Navy/military colors
- **Health:** Medical blues and greens
- **Education:** Purple (academic)
- **Hardship:** Reds (urgent)
- **Transportation:** Oranges (movement)
- **Mobility:** Teals (flow)
- **Disability:** Warm neutrals (supportive)

### Comparison Features:
1. **Side-by-side tract comparison:** Select 2-3 tracts to compare all metrics
2. **Historical comparison:** If you get multiple years of data
3. **Benchmark comparison:** Compare to county/city averages
4. **Veteran vs Non-Veteran toggle:** Show same metrics split by veteran status

### Smart Defaults:
When user selects a primary layer, auto-populate sidebar with most relevant context variables from that group.

### Story Mode:
Pre-built views that combine multiple layers to tell specific stories:
- "Where are veterans struggling economically?"
- "Housing affordability crisis zones"
- "Communities with high uninsured rates"
- "Digital divide hotspots"
- "Areas with highest child poverty"

---

## TECHNICAL NOTES

### Handle Missing Data:
Some enrichment variables may be NA for certain tracts. Show "Data not available" rather than 0.

### Calculation Variables:
Many percentage and density variables are calculated. Make sure to handle division by zero (tract_area = 0, population = 0).

### Multiple Coverage:
For health insurance, make it clear that percentages can sum to >100% because people have multiple coverage types.

### Census Suppression:
Small tracts may have suppressed data. Flag these with a different color or pattern.

---

## VARIABLE IMPORTANCE RANKINGS

For each tab, here are the "must have" primary map layers:

**Housing:** Pct_Vacant, Median_Home_Value, Pct_Owner_Occupied, Pct_Single_Family
**Affordability:** Median_Home_Value, High_Rent_Burden_50_Plus_Units, Price_To_Income_Ratio
**Demographics:** Total_Population, Pct_White/Black/Hispanic/Asian
**Veterans:** Vet_Total_Veterans, Pct_Veterans_Of_Adult_Pop, Vet_Median_Income_Veterans
**Health:** Pct_No_Health_Insurance, Pct_With_Medicare, Pct_With_Medicaid
**Education:** Pct_Bachelors_Plus, Pct_Less_Than_HS
**Hardship:** Pct_Below_Poverty, Pct_HH_SNAP, Children_Below_Poverty
**Transportation:** Pct_HH_No_Vehicle, Pct_Commute_60_Plus, Pct_HH_With_Broadband
**Mobility:** Pct_Same_House_1_Year, Moved_In_2020_Later
**Disability:** Pct_With_Disability, Pct_Multigenerational

These should be the default/featured layers when users open each tab.
