# Interactive Map - Quick Reference Guide

## Tab Structure Overview

```
1. HOUSING SUPPLY & CHARACTERISTICS
   ├── 1.1 Housing Supply Overview
   ├── 1.2 Housing Tenure
   ├── 1.3 Structure Types
   ├── 1.4 Unit Size & Bedrooms
   └── 1.5 Housing Age

2. HOUSING AFFORDABILITY
   ├── 2.1 Housing Costs
   ├── 2.2 Cost Burden & Financial Stress
   └── 2.3 Income Distribution

3. DEMOGRAPHICS
   ├── 3.1 Population Overview
   ├── 3.2 Race & Ethnicity
   └── 3.3 Household Composition

4. VETERANS
   ├── 4.1 Veteran Population Overview
   ├── 4.2 Veteran Demographics
   ├── 4.3 Veteran Race & Ethnicity
   ├── 4.4 Period of Service
   └── 4.5 Veteran Employment & Income

5. HEALTH & INSURANCE
   ├── 5.1 Overall Coverage Status
   ├── 5.2 Private Insurance
   ├── 5.3 Public Insurance Programs
   ├── 5.4 Military & Veteran Healthcare
   └── 5.5 Coverage Gaps & Vulnerable Populations

6. EDUCATION & OPPORTUNITY
   ├── 6.1 Educational Attainment
   └── 6.2 Veteran vs Non-Veteran Education

7. ECONOMIC HARDSHIP
   ├── 7.1 Poverty & Assistance Programs
   └── 7.2 Child Poverty & Family Hardship

8. TRANSPORTATION & CONNECTIVITY
   ├── 8.1 Commute Patterns
   ├── 8.2 Vehicle Access
   └── 8.3 Digital Access

9. HOUSING MOBILITY & STABILITY
   ├── 9.1 Residential Stability
   └── 9.2 Move-In Timing & Housing Age

10. DISABILITY & SPECIAL NEEDS
    ├── 10.1 Disability Prevalence
    └── 10.2 Complex Caregiving Arrangements
```

---

## Top Priority Variables by Tab

### Housing Supply
🔥 Pct_Vacant
🔥 Total_Housing_Units
🔥 Pct_Owner_Occupied
🔥 Housing_units_per_sqmi

### Affordability
🔥 Median_Home_Value
🔥 Median_Gross_Rent
🔥 High_Rent_Burden_50_Plus_Units
🔥 Price_To_Income_Ratio

### Demographics
🔥 Total_Population
🔥 Pct_White, Pct_Black, Pct_Hispanic, Pct_Asian
🔥 Pct_Households_With_Children

### Veterans
🔥 Vet_Total_Veterans
🔥 Pct_Veterans_Of_Adult_Pop
🔥 Pct_Veterans_Unemployed
🔥 Vet_Median_Income_Veterans

### Health & Insurance
🔥 Pct_No_Health_Insurance (MOST IMPORTANT!)
🔥 Pct_With_Medicare
🔥 Pct_With_Medicaid
🔥 Pct_With_VA_HealthCare

### Education
🔥 Pct_Bachelors_Plus
🔥 Pct_Less_Than_HS

### Economic Hardship
🔥 Pct_Below_Poverty
🔥 Pct_HH_SNAP
🔥 Children_Below_Poverty

### Transportation
🔥 Pct_HH_No_Vehicle
🔥 Pct_Commute_60_Plus
🔥 Pct_HH_With_Broadband

### Mobility
🔥 Pct_Same_House_1_Year
🔥 Moved_In_2020_Later

### Disability
🔥 Pct_With_Disability
🔥 Pct_Multigenerational

---

## Pre-Built Story Views

### Story 1: Veteran Support Needs
**Primary Layer:** Vet_Total_Veterans
**Sidebar:**
- Pct_Veterans_Unemployed
- Pct_With_VA_HealthCare
- Vet_Median_Income_Veterans
- Pct_Veterans_With_Service_Disability
- Pct_Below_Poverty

### Story 2: Affordability Crisis
**Primary Layer:** High_Rent_Burden_50_Plus_Units
**Sidebar:**
- Median_Gross_Rent
- Median_Household_Income
- Pct_Below_Poverty
- Pct_Renter_Occupied
- Pct_HH_SNAP

### Story 3: Healthcare Access Gaps
**Primary Layer:** Pct_No_Health_Insurance
**Sidebar:**
- Pct_Below_Poverty
- Pct_Hispanic
- Median_Household_Income
- Pct_With_DirectPurchase_Insurance
- Children_Below_Poverty

### Story 4: Child Well-Being
**Primary Layer:** Children_Below_Poverty
**Sidebar:**
- Pct_Households_With_Children
- Children_In_Single_Mother_Families
- Pct_HH_SNAP
- Pct_No_Health_Insurance
- Three_Plus_Bedroom_Units

### Story 5: Digital Divide
**Primary Layer:** Pct_HH_With_Broadband
**Sidebar:**
- Pct_HH_No_Computer
- Median_Household_Income
- Pct_Below_Poverty
- Pct_Bachelors_Plus
- Pct_With_Employer_Insurance

### Story 6: Transit Dependency
**Primary Layer:** Pct_HH_No_Vehicle
**Sidebar:**
- Pct_Commute_60_Plus
- Below_Poverty_Level
- Population_per_sqmi
- Pct_Renter_Occupied
- Pct_HH_SNAP

### Story 7: Opportunity Zones
**Primary Layer:** Pct_Bachelors_Plus
**Sidebar:**
- Median_Household_Income
- Median_Home_Value
- Pct_With_Employer_Insurance
- Pct_Below_Poverty
- Pct_HH_With_Broadband

---

## Color Palette Recommendations

### Housing (Blues)
- Low values: #e3f2fd (light blue)
- High values: #0d47a1 (dark blue)

### Affordability (Yellow-Orange-Red for cost burden)
- Low burden: #fff9c4 (light yellow)
- Medium burden: #ff9800 (orange)  
- High burden: #c62828 (red)

### Demographics (Greens)
- Low density: #e8f5e9 (light green)
- High density: #1b5e20 (dark green)

### Veterans (Navy/Military)
- Low: #bbdefb (light blue)
- High: #1a237e (navy)

### Health Insurance (Medical Blue-Green)
- Good coverage: #00897b (teal)
- Poor coverage: #c62828 (red)
- For uninsured: Reverse scale

### Poverty/Hardship (Red)
- Low poverty: #fff9c4 (light yellow)
- High poverty: #b71c1c (dark red)

### Education (Purple)
- Low education: #f3e5f5 (light purple)
- High education: #4a148c (dark purple)

---

## Special Handling Notes

### Health Insurance
⚠️ Percentages can sum to >100% (multiple coverage)
Add tooltip: "People may have multiple types of insurance"

### Veterans Period of Service
⚠️ Veterans can serve in multiple periods
Add tooltip: "Totals may exceed veteran population"

### Density Calculations
⚠️ Check for division by zero (tract_area = 0)
Handle with: "Unable to calculate density"

### Missing/Suppressed Data
⚠️ Census suppresses data in small tracts
Show with: Hatched pattern or "Data suppressed" label

### Percentage vs Count Toggle
✓ Allow users to switch between:
- Percentage view (Pct_*) - better for comparison
- Count view (raw numbers) - better for scale

---

## Sidebar Auto-Population Rules

When user selects a primary layer, auto-populate sidebar with:

**Rule 1:** Always show the denominator/universe
Example: If showing Pct_Vacant, show Total_Housing_Units

**Rule 2:** Show complementary metric
Example: If showing Pct_Owner_Occupied, show Pct_Renter_Occupied

**Rule 3:** Show related socioeconomic context
Example: If showing housing costs, show Median_Household_Income

**Rule 4:** Show related outcomes
Example: If showing Pct_Below_Poverty, show Pct_HH_SNAP

**Rule 5:** Limit to 5-7 sidebar variables
More creates cognitive overload

---

## Tooltip Format Examples

### For Percentages:
```
Census Tract: 17031010100
Renter-Occupied: 68.5%
[Additional context:]
Total Households: 1,450
Renter Households: 993
Owner Households: 457
Median Gross Rent: $1,250
Median Home Value: $385,000
```

### For Counts:
```
Census Tract: 17031010100
Total Veterans: 215
[Additional context:]
% of Adult Population: 4.8%
Male Veterans: 190 (88.4%)
Female Veterans: 25 (11.6%)
Median Income (Veterans): $52,000
```

### For Multiple Coverage (Health Insurance):
```
Census Tract: 17031010100
With Medicare: 920 people (18.2%)
[Note: Some residents have multiple types of insurance]
[Additional context:]
Total Population: 5,050
Also have Private Insurance: ~340 (estimated overlap)
65+ Population: ~850 (eligible for Medicare)
```

---

## Mobile Responsiveness

### Desktop View:
- Map: 70% width
- Sidebar: 30% width
- Show full variable names

### Tablet View:
- Map: 100% width
- Sidebar: Collapsible drawer from right
- Show abbreviated variable names

### Mobile View:
- Map: 100% width, full screen
- Sidebar: Bottom sheet (swipe up)
- Show short labels only
- Prioritize top 3 sidebar variables

---

## Search & Filter Features

### Search by:
- Census Tract ID (GEOID)
- Tract Name
- Address (geocode to tract)
- ZIP code (show all tracts in ZIP)

### Filter by:
- Value ranges (e.g., "Show tracts with >20% poverty")
- Quartiles (e.g., "Top 25% by median income")
- Multiple conditions (e.g., "High poverty AND low insurance")
- Veteran presence (e.g., "Tracts with >100 veterans")

### Comparison Features:
- Select up to 3 tracts for side-by-side comparison
- Compare to county/city averages
- Compare to Illinois state averages
- Highlight tracts that match criteria

---

## Performance Optimization

### For Tract-Level Data:
- ~1,300 tracts in Cook County
- Pre-calculate all percentages server-side
- Cache common queries
- Use vector tiles for map rendering
- Lazy-load sidebar data (don't load until tract selected)

### For Variables:
- ~300+ variables total
- Group by tab/category to reduce initial load
- Load tab data on-demand when tab opened
- Consider IndexedDB for client-side caching

---

## Accessibility

### Color Blindness:
- Use patterns in addition to colors
- Provide color-blind friendly palettes
- Allow custom color schemes

### Screen Readers:
- Alt text for all map layers
- ARIA labels for controls
- Keyboard navigation for tract selection

### Text:
- Minimum 14px font size
- High contrast (WCAG AA minimum)
- Plain language explanations

---

## Export Features

### Allow users to export:
1. **Selected tract data** (CSV)
2. **Visible map view** (PNG/PDF)
3. **Comparison table** (Excel)
4. **Custom report** (PDF with selected variables)
5. **GeoJSON** (for GIS users)

---

## Data Updates

### Version Control:
- Show data year prominently (2023 ACS 5-Year)
- Note: "Data from 2019-2023"
- Add timestamp: "Last updated: [date]"

### Future Years:
- Allow year-over-year comparison
- Show trend arrows (↑↓)
- Calculate change percentages
- Highlight gentrifying areas

---

## Help/Documentation

### In-App Tooltips:
- Hover over variable names for definitions
- "?" icon next to complex metrics
- "Learn more" links to methodology

### User Guide Sections:
1. How to use the map
2. Understanding the data
3. Interpretation guidelines
4. Common questions
5. Data sources & methods
6. Contact for questions

---

## Analytics to Track

### User Behavior:
- Most viewed tabs
- Most mapped variables
- Average session time
- Search terms used
- Tracts most frequently selected

### Feature Usage:
- Story mode usage
- Comparison feature usage
- Export feature usage
- Filter feature usage

### Performance:
- Load times
- Error rates
- Browser/device types
- Geographic distribution of users
