# Cook County Housing & Veterans Data Dictionary
## American Community Survey 5-Year Estimates (2023)

**Geographic Coverage:** Census tracts in Cook County, Illinois  
**Source:** U.S. Census Bureau American Community Survey (ACS) 5-Year Estimates  
**Year:** 2023  
**Survey:** ACS 5-Year (2019-2023)

---

## Table of Contents
1. [Geography](#geography)
2. [Population & Demographics](#population--demographics)
3. [Veterans Data](#veterans-data)
4. [Housing Supply & Tenure](#housing-supply--tenure)
5. [Structure Type](#structure-type)
6. [Unit Size (Bedrooms)](#unit-size-bedrooms)
7. [Year Structure Built](#year-structure-built)
8. [Households & Family Composition](#households--family-composition)
9. [Income & Financial Characteristics](#income--financial-characteristics)
10. [Poverty](#poverty)
11. [Affordability Metrics](#affordability-metrics)
12. [Housing Vulnerability Metrics](#housing-vulnerability-metrics)
13. [Disability](#disability)
14. [Educational Attainment](#educational-attainment)
15. [Health Insurance Coverage](#health-insurance-coverage)
16. [Digital Access](#digital-access)
17. [Transportation](#transportation)
18. [Housing Mobility & Stability](#housing-mobility--stability)
19. [Economic Hardship](#economic-hardship)
20. [Multigenerational Households](#multigenerational-households)
21. [Spatial Metrics](#spatial-metrics)

---

## Geography

| Variable | Description | Source Table |
|----------|-------------|--------------|
| GEOID | 11-digit Census tract identifier (State+County+Tract) | Census Geography |
| NAME | Census tract name (e.g., "Census Tract 8001, Cook County, Illinois") | Census Geography |

---

## Population & Demographics

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Population | Total population | B01003 |
| White_Alone | Population identifying as White alone | B02001 |
| Black_Alone | Population identifying as Black or African American alone | B02001 |
| Asian_Alone | Population identifying as Asian alone | B02001 |
| Hispanic_Latino | Population identifying as Hispanic or Latino (any race) | B03003 |
| Pct_White | Percentage of population that is White alone | Calculated |
| Pct_Black | Percentage of population that is Black alone | Calculated |
| Pct_Asian | Percentage of population that is Asian alone | Calculated |
| Pct_Hispanic | Percentage of population that is Hispanic or Latino | Calculated |

---

## Veterans Data

### Total Veterans

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Total_Pop_18_Plus | Total civilian population 18 years and over | B21001 |
| Vet_Total_Veterans | Total veteran population | B21001 |
| Vet_Total_Non_Veterans | Total non-veteran population | B21001 |
| Pct_Veterans_Of_Adult_Pop | Percentage of adults who are veterans | Calculated |

### Veterans by Gender

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Male_Veterans | Male veterans | B21001 |
| Vet_Female_Veterans | Female veterans | B21001 |
| Pct_Veterans_Male | Percentage of veterans who are male | Calculated |
| Pct_Veterans_Female | Percentage of veterans who are female | Calculated |

### Veterans by Age

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Male_18_34 | Male veterans age 18-34 | B21001 |
| Vet_Male_35_54 | Male veterans age 35-54 | B21001 |
| Vet_Male_55_64 | Male veterans age 55-64 | B21001 |
| Vet_Male_65_74 | Male veterans age 65-74 | B21001 |
| Vet_Male_75_Plus | Male veterans age 75+ | B21001 |
| Vet_Female_18_34 | Female veterans age 18-34 | B21001 |
| Vet_Female_35_54 | Female veterans age 35-54 | B21001 |
| Vet_Female_55_64 | Female veterans age 55-64 | B21001 |
| Vet_Female_65_74 | Female veterans age 65-74 | B21001 |
| Vet_Female_75_Plus | Female veterans age 75+ | B21001 |
| Vet_Total_18_34 | Total veterans age 18-34 | Calculated |
| Vet_Total_35_54 | Total veterans age 35-54 | Calculated |
| Vet_Total_55_64 | Total veterans age 55-64 | Calculated |
| Vet_Total_65_74 | Total veterans age 65-74 | Calculated |
| Vet_Total_75_Plus | Total veterans age 75+ | Calculated |
| Pct_Veterans_18_34 | Percentage of veterans age 18-34 | Calculated |
| Pct_Veterans_35_54 | Percentage of veterans age 35-54 | Calculated |
| Pct_Veterans_55_64 | Percentage of veterans age 55-64 | Calculated |
| Pct_Veterans_65_Plus | Percentage of veterans age 65+ | Calculated |

### Veterans by Race/Ethnicity

**Note:** Race/ethnicity data uses C21001 tables with simplified age groups (18-64, 65+)

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_White_Alone_Total_Pop | Total population 18+ (White alone) | C21001A |
| Vet_White_Alone_Male_18_64 | White male veterans age 18-64 | C21001A |
| Vet_White_Alone_Male_65_Plus | White male veterans age 65+ | C21001A |
| Vet_White_Alone_Female_18_64 | White female veterans age 18-64 | C21001A |
| Vet_White_Alone_Female_65_Plus | White female veterans age 65+ | C21001A |
| Vet_White_NH_Total_Pop | Total population 18+ (White non-Hispanic) | C21001H |
| Vet_White_NH_Male_18_64 | White non-Hispanic male veterans age 18-64 | C21001H |
| Vet_White_NH_Male_65_Plus | White non-Hispanic male veterans age 65+ | C21001H |
| Vet_White_NH_Female_18_64 | White non-Hispanic female veterans age 18-64 | C21001H |
| Vet_White_NH_Female_65_Plus | White non-Hispanic female veterans age 65+ | C21001H |
| Vet_Black_Total_Pop | Total population 18+ (Black alone) | C21001B |
| Vet_Black_Male_18_64 | Black male veterans age 18-64 | C21001B |
| Vet_Black_Male_65_Plus | Black male veterans age 65+ | C21001B |
| Vet_Black_Female_18_64 | Black female veterans age 18-64 | C21001B |
| Vet_Black_Female_65_Plus | Black female veterans age 65+ | C21001B |
| Vet_Asian_Total_Pop | Total population 18+ (Asian alone) | C21001D |
| Vet_Asian_Male_18_64 | Asian male veterans age 18-64 | C21001D |
| Vet_Asian_Male_65_Plus | Asian male veterans age 65+ | C21001D |
| Vet_Asian_Female_18_64 | Asian female veterans age 18-64 | C21001D |
| Vet_Asian_Female_65_Plus | Asian female veterans age 65+ | C21001D |
| Vet_Latino_Total_Pop | Total population 18+ (Hispanic/Latino) | C21001I |
| Vet_Latino_Male_18_64 | Hispanic/Latino male veterans age 18-64 | C21001I |
| Vet_Latino_Male_65_Plus | Hispanic/Latino male veterans age 65+ | C21001I |
| Vet_Latino_Female_18_64 | Hispanic/Latino female veterans age 18-64 | C21001I |
| Vet_Latino_Female_65_Plus | Hispanic/Latino female veterans age 65+ | C21001I |
| Vet_Total_White | Total White veterans (all ages, both genders) | Calculated |
| Vet_Total_Black | Total Black veterans (all ages, both genders) | Calculated |
| Vet_Total_Asian | Total Asian veterans (all ages, both genders) | Calculated |
| Vet_Total_Latino | Total Hispanic/Latino veterans (all ages, both genders) | Calculated |
| Pct_Veterans_White | Percentage of veterans who are White | Calculated |
| Pct_Veterans_Black | Percentage of veterans who are Black | Calculated |
| Pct_Veterans_Asian | Percentage of veterans who are Asian | Calculated |
| Pct_Veterans_Latino | Percentage of veterans who are Hispanic/Latino | Calculated |

### Period of Military Service

**Important Note:** Veterans can serve during multiple periods, so totals may exceed the total veteran count.

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Period_Total | Total veterans 18+ for period calculation | B21002 |
| Vet_Gulf_War_Post_9_11_Only | Veterans who served Gulf War (9/2001 or later) only | B21002 |
| Vet_Gulf_War_Post_9_11_And_Pre_9_11 | Veterans who served both post-9/11 and pre-9/11 Gulf War | B21002 |
| Vet_Gulf_War_Post_9_11_And_Pre_9_11_And_Vietnam | Veterans who served post-9/11, pre-9/11, and Vietnam | B21002 |
| Vet_Gulf_War_Pre_9_11_Only | Veterans who served Gulf War (8/1990 - 8/2001) only | B21002 |
| Vet_Gulf_War_Pre_9_11_And_Vietnam | Veterans who served pre-9/11 Gulf War and Vietnam | B21002 |
| Vet_Vietnam_Era_Only | Veterans who served Vietnam era only | B21002 |
| Vet_Vietnam_And_Korean_War | Veterans who served Vietnam and Korean War | B21002 |
| Vet_Vietnam_And_Korean_And_WWII | Veterans who served Vietnam, Korean, and WWII | B21002 |
| Vet_Korean_War_Only | Veterans who served Korean War only | B21002 |
| Vet_Korean_War_And_WWII | Veterans who served Korean War and WWII | B21002 |
| Vet_WWII_Only | Veterans who served WWII only | B21002 |
| Vet_Between_Gulf_War_And_Vietnam_Only | Veterans who served between Gulf War and Vietnam only | B21002 |
| Vet_Between_Vietnam_And_Korean_Only | Veterans who served between Vietnam and Korean only | B21002 |
| Vet_Between_Korean_And_WWII_Only | Veterans who served between Korean and WWII only | B21002 |
| Vet_Pre_WWII_Only | Veterans who served pre-WWII only | B21002 |
| Vet_Any_Post_9_11 | Veterans who served any post-9/11 period | Calculated |
| Vet_Any_Gulf_War | Veterans who served any Gulf War period | Calculated |
| Vet_Any_Vietnam | Veterans who served any Vietnam period | Calculated |

### Veteran Educational Attainment

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Ed_Total_Pop_25_Plus | Total population 25 years and over | B21003 |
| Vet_Ed_Veteran_Total | Total veterans 25+ | B21003 |
| Vet_Ed_Veteran_Less_Than_HS | Veterans 25+ with less than high school | B21003 |
| Vet_Ed_Veteran_HS_Grad | Veterans 25+ with high school diploma | B21003 |
| Vet_Ed_Veteran_Some_College_AA | Veterans 25+ with some college or associate's | B21003 |
| Vet_Ed_Veteran_Bachelors_Plus | Veterans 25+ with bachelor's or higher | B21003 |
| Vet_Ed_NonVeteran_Total | Total non-veterans 25+ | B21003 |
| Vet_Ed_NonVeteran_Less_Than_HS | Non-veterans 25+ with less than high school | B21003 |
| Vet_Ed_NonVeteran_HS_Grad | Non-veterans 25+ with high school diploma | B21003 |
| Vet_Ed_NonVeteran_Some_College_AA | Non-veterans 25+ with some college or associate's | B21003 |
| Vet_Ed_NonVeteran_Bachelors_Plus | Non-veterans 25+ with bachelor's or higher | B21003 |
| Pct_Vet_Ed_Less_Than_HS | Percentage of veterans with less than high school | Calculated |
| Pct_Vet_Ed_HS_Grad | Percentage of veterans with high school diploma | Calculated |
| Pct_Vet_Ed_Some_College | Percentage of veterans with some college/associate's | Calculated |
| Pct_Vet_Ed_Bachelors_Plus | Percentage of veterans with bachelor's or higher | Calculated |

### Veteran Income

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Median_Income_Total | Median income for population 16+ | B21004 |
| Vet_Median_Income_Veteran_Total | Median income for veterans | B21004 |
| Vet_Median_Income_Veteran_Male | Median income for male veterans | B21004 |
| Vet_Median_Income_Veteran_Female | Median income for female veterans | B21004 |
| Vet_Median_Income_NonVeteran_Total | Median income for non-veterans | B21004 |
| Vet_Median_Income_NonVeteran_Male | Median income for male non-veterans | B21004 |
| Vet_Median_Income_NonVeteran_Female | Median income for female non-veterans | B21004 |

### Veteran Employment Status

**Note:** Employment data aggregated across age groups 18-34, 35-54, 55-64 (working-age veterans)

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Emp_Total_18_64 | Total civilian population 18-64 | B21005 |
| Vet_Emp_Veteran_Total | Total veterans 18-64 | Calculated |
| Vet_Emp_Veteran_In_Labor_Force | Veterans 18-64 in labor force | Calculated |
| Vet_Emp_Veteran_Employed | Veterans 18-64 employed | Calculated |
| Vet_Emp_Veteran_Unemployed | Veterans 18-64 unemployed | Calculated |
| Pct_Veterans_Employed | Percentage of veterans in labor force who are employed | Calculated |
| Pct_Veterans_Unemployed | Percentage of veterans in labor force who are unemployed | Calculated |
| Pct_Veterans_In_Labor_Force | Percentage of veterans who are in labor force | Calculated |

### Veteran Poverty Status

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Pov_Total_Pop_18_Plus | Total civilian population 18+ | C21007 |
| Vet_Pov_Total_18_64 | Total population 18-64 | C21007 |
| Vet_Pov_Veteran_18_64 | Veterans 18-64 | C21007 |
| Vet_Pov_Veteran_18_64_Below_Poverty | Veterans 18-64 below poverty | C21007 |
| Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability | Veterans 18-64 below poverty with disability | C21007 |
| Vet_Pov_Veteran_18_64_Below_Poverty_No_Disability | Veterans 18-64 below poverty without disability | C21007 |
| Vet_Pov_Veteran_18_64_At_Above_Poverty | Veterans 18-64 at/above poverty | C21007 |
| Vet_Pov_Veteran_18_64_At_Above_Poverty_With_Disability | Veterans 18-64 at/above poverty with disability | C21007 |
| Vet_Pov_Veteran_18_64_At_Above_Poverty_No_Disability | Veterans 18-64 at/above poverty without disability | C21007 |
| Vet_Pov_Total_65_Plus | Total population 65+ | C21007 |
| Vet_Pov_Veteran_65_Plus | Veterans 65+ | C21007 |
| Vet_Pov_Veteran_65_Plus_Below_Poverty | Veterans 65+ below poverty | C21007 |
| Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability | Veterans 65+ below poverty with disability | C21007 |
| Vet_Pov_Veteran_65_Plus_Below_Poverty_No_Disability | Veterans 65+ below poverty without disability | C21007 |
| Vet_Pov_Veteran_65_Plus_At_Above_Poverty | Veterans 65+ at/above poverty | C21007 |
| Vet_Pov_Veteran_65_Plus_At_Above_Poverty_With_Disability | Veterans 65+ at/above poverty with disability | C21007 |
| Vet_Pov_Veteran_65_Plus_At_Above_Poverty_No_Disability | Veterans 65+ at/above poverty without disability | C21007 |
| Pct_Vet_18_64_In_Poverty | Percentage of veterans 18-64 in poverty | Calculated |
| Pct_Vet_65_Plus_In_Poverty | Percentage of veterans 65+ in poverty | Calculated |
| Pct_Vet_18_64_With_Disability | Percentage of veterans 18-64 with disability | Calculated |
| Pct_Vet_65_Plus_With_Disability | Percentage of veterans 65+ with disability | Calculated |
| Pct_Vet_18_64_Poverty_With_Disability | Percentage of poor veterans 18-64 with disability | Calculated |
| Pct_Vet_65_Plus_Poverty_With_Disability | Percentage of poor veterans 65+ with disability | Calculated |

### Service-Connected Disability Rating

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Vet_Dis_Rating_Total | Total veterans 18+ | B21100 |
| Vet_Dis_No_Rating | Veterans with no service-connected disability rating | B21100 |
| Vet_Dis_Has_Rating | Veterans with service-connected disability rating | B21100 |
| Vet_Dis_Rating_0_Pct | Veterans with 0% service-connected disability rating | B21100 |
| Vet_Dis_Rating_10_20_Pct | Veterans with 10% or 20% rating | B21100 |
| Vet_Dis_Rating_30_40_Pct | Veterans with 30% or 40% rating | B21100 |
| Vet_Dis_Rating_50_60_Pct | Veterans with 50% or 60% rating | B21100 |
| Vet_Dis_Rating_70_Plus_Pct | Veterans with 70% to 100% rating | B21100 |
| Vet_Dis_Rating_Not_Reported | Veterans with rating not reported | B21100 |
| Vet_Dis_Summary_Total | Total veterans (summary table) | C21100 |
| Vet_Dis_Summary_No_Rating | Veterans with no rating (summary) | C21100 |
| Vet_Dis_Summary_Has_Rating | Veterans with rating (summary) | C21100 |
| Pct_Vet_With_Service_Disability | Percentage of veterans with service-connected disability | Calculated |
| Pct_Vet_Disability_70_Plus | Percentage of disabled veterans with 70%+ rating | Calculated |

---

## Housing Supply & Tenure

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Housing_Units | Total number of housing units | B25001 |
| Occupied_Units | Number of occupied housing units | B25002 |
| Vacant_Units | Number of vacant housing units | B25002 |
| Owner_Occupied | Number of owner-occupied housing units | B25003 |
| Renter_Occupied | Number of renter-occupied housing units | B25003 |
| Pct_Vacant | Percentage of housing units that are vacant | Calculated |
| Pct_Owner_Occupied | Percentage of occupied units that are owner-occupied | Calculated |
| Pct_Renter_Occupied | Percentage of occupied units that are renter-occupied | Calculated |
| Occupancy_Rate | Percentage of housing units that are occupied | Calculated |

---

## Structure Type

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Single_Family_Detached | Number of single-family detached homes | B25024 |
| Single_Family_Attached | Number of single-family attached homes (townhomes, row houses) | B25024 |
| Multi_Family_2_Units | Number of units in 2-unit buildings | B25024 |
| Multi_Family_3_4_Units | Number of units in 3-4 unit buildings | B25024 |
| Multi_Family_5_9_Units | Number of units in 5-9 unit buildings | B25024 |
| Multi_Family_10_19_Units | Number of units in 10-19 unit buildings | B25024 |
| Multi_Family_20_49_Units | Number of units in 20-49 unit buildings | B25024 |
| Multi_Family_50_Plus_Units | Number of units in buildings with 50+ units | B25024 |
| Multi_Family_All_Units | Total units in multi-family buildings (2+ units) | Calculated |
| Multi_Family_2_4_Units | Total units in 2-4 unit buildings | Calculated |
| Multi_Family_5_Plus_Units | Total units in buildings with 5+ units | Calculated |
| Multi_Family_10_Plus_Units | Total units in buildings with 10+ units | Calculated |
| Multi_Family_20_Plus_Units | Total units in buildings with 20+ units | Calculated |
| Mobile_Home | Number of mobile homes | B25024 |
| Pct_Single_Family | Percentage of housing units that are single-family detached | Calculated |
| Pct_Multi_Family_5_Plus | Percentage of housing units in buildings with 5+ units | Calculated |

---

## Unit Size (Bedrooms)

| Variable | Description | Source Table |
|----------|-------------|--------------|
| No_Bedroom | Number of housing units with no bedroom (studio) | B25041 |
| One_Bedroom | Number of housing units with 1 bedroom | B25041 |
| Two_Bedrooms | Number of housing units with 2 bedrooms | B25041 |
| Three_Bedrooms | Number of housing units with 3 bedrooms | B25041 |
| Four_Bedrooms | Number of housing units with 4 bedrooms | B25041 |
| Five_Plus_Bedrooms | Number of housing units with 5 or more bedrooms | B25041 |
| Two_Plus_Bedroom_Units | Number of housing units with 2 or more bedrooms | Calculated |
| Three_Plus_Bedroom_Units | Number of housing units with 3 or more bedrooms | Calculated |

---

## Year Structure Built

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Built_2020_or_Later | Housing units built in 2020 or later | B25034 |
| Built_2010_2019 | Housing units built between 2010-2019 | B25034 |
| Built_2000_2009 | Housing units built between 2000-2009 | B25034 |
| Built_1990_1999 | Housing units built between 1990-1999 | B25034 |
| Built_1980_1989 | Housing units built between 1980-1989 | B25034 |
| Built_1970_1979 | Housing units built between 1970-1979 | B25034 |
| Built_1960_1969 | Housing units built between 1960-1969 | B25034 |
| Built_1950_1959 | Housing units built between 1950-1959 | B25034 |
| Built_1940_1949 | Housing units built between 1940-1949 | B25034 |
| Built_1939_or_Earlier | Housing units built in 1939 or earlier | B25034 |

---

## Households & Family Composition

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Households | Total number of households | B11001 |
| Family_Households | Number of family households | B11001 |
| Nonfamily_Living_Alone | Number of non-family households with person living alone | B11001 |
| Households_With_Children_Under_18 | Number of households with children under 18 years | B11005 |
| Total_Own_Children_Under_18 | Total number of own children under 18 years | B09002 |
| Children_In_Married_Couple_Families | Own children under 18 in married-couple families | B09002 |
| Children_In_Single_Mother_Families | Own children under 18 in single-mother families | B09002 |
| Large_Owner_Households_4_Plus | Owner households with 4 or more persons | B25115 |
| Large_Renter_Households_4_Plus | Renter households with 4 or more persons | B25115 |
| Avg_Household_Size | Average number of persons per household | Calculated |
| Pct_Households_With_Children | Percentage of households with children under 18 | Calculated |

---

## Income & Financial Characteristics

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Median_Home_Value | Median value of owner-occupied housing units (dollars) | B25077 |
| Median_Gross_Rent | Median gross rent (dollars) | B25064 |
| Median_Household_Income | Median household income (dollars) | B19013 |
| Median_Income_Owner_Occupied | Median household income for owner-occupied units (dollars) | B25119 |
| Median_Income_Renter_Occupied | Median household income for renter-occupied units (dollars) | B25119 |
| Income_Under_10K | Households with income under $10,000 | B19001 |
| Income_10K_15K | Households with income $10,000-$14,999 | B19001 |
| Income_15K_20K | Households with income $15,000-$19,999 | B19001 |
| Income_20K_25K | Households with income $20,000-$24,999 | B19001 |
| Income_25K_30K | Households with income $25,000-$29,999 | B19001 |
| Income_30K_35K | Households with income $30,000-$34,999 | B19001 |
| Income_35K_40K | Households with income $35,000-$39,999 | B19001 |
| Income_40K_45K | Households with income $40,000-$44,999 | B19001 |
| Income_45K_50K | Households with income $45,000-$49,999 | B19001 |
| Income_50K_60K | Households with income $50,000-$59,999 | B19001 |
| Income_60K_75K | Households with income $60,000-$74,999 | B19001 |
| Income_75K_100K | Households with income $75,000-$99,999 | B19001 |
| Income_100K_125K | Households with income $100,000-$124,999 | B19001 |
| Income_125K_150K | Households with income $125,000-$149,999 | B19001 |
| Income_150K_200K | Households with income $150,000-$199,999 | B19001 |
| Income_200K_Plus | Households with income $200,000 or more | B19001 |
| Low_Income_Under_35K | Households with income under $35,000 | Calculated |
| Middle_Income_35K_100K | Households with income $35,000-$99,999 | Calculated |
| High_Income_100K_Plus | Households with income $100,000 or more | Calculated |

---

## Poverty

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Below_Poverty_Level | Population for whom poverty status is determined that is below poverty level | B17001 |
| Children_Below_Poverty | Children (under 18) below poverty level | B17001 |
| Pct_Below_Poverty | Percentage of population below poverty level | Calculated |

---

## Affordability Metrics

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Rent_Burden_Ratio | Median gross rent as percentage of median household income | Calculated |
| Price_To_Income_Ratio | Median home value divided by median income for owner-occupied units | Calculated |
| High_Rent_Burden_30_Plus_Units | Renter households spending 30% or more of income on rent | Calculated |
| High_Rent_Burden_50_Plus_Units | Renter households spending 50% or more of income on rent | B25070 |

---

## Housing Vulnerability Metrics

### Age of Householder - Aging in Place

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Owner_Householder_15_24 | Owner-occupied units with householder age 15-24 | B25007 |
| Owner_Householder_25_34 | Owner-occupied units with householder age 25-34 | B25007 |
| Owner_Householder_35_44 | Owner-occupied units with householder age 35-44 | B25007 |
| Owner_Householder_45_54 | Owner-occupied units with householder age 45-54 | B25007 |
| Owner_Householder_55_59 | Owner-occupied units with householder age 55-59 | B25007 |
| Owner_Householder_60_64 | Owner-occupied units with householder age 60-64 | B25007 |
| Owner_Householder_65_74 | Owner-occupied units with householder age 65-74 | B25007 |
| Owner_Householder_75_84 | Owner-occupied units with householder age 75-84 | B25007 |
| Owner_Householder_85_Plus | Owner-occupied units with householder age 85+ | B25007 |
| Renter_Householder_15_24 | Renter-occupied units with householder age 15-24 | B25007 |
| Renter_Householder_25_34 | Renter-occupied units with householder age 25-34 | B25007 |
| Renter_Householder_35_44 | Renter-occupied units with householder age 35-44 | B25007 |
| Renter_Householder_45_54 | Renter-occupied units with householder age 45-54 | B25007 |
| Renter_Householder_55_59 | Renter-occupied units with householder age 55-59 | B25007 |
| Renter_Householder_60_64 | Renter-occupied units with householder age 60-64 | B25007 |
| Renter_Householder_65_74 | Renter-occupied units with householder age 65-74 | B25007 |
| Renter_Householder_75_84 | Renter-occupied units with householder age 75-84 | B25007 |
| Renter_Householder_85_Plus | Renter-occupied units with householder age 85+ | B25007 |
| Owner_Householder_65_Plus | Owner-occupied units with householder age 65+ | Calculated |
| Owner_Householder_75_Plus | Owner-occupied units with householder age 75+ | Calculated |
| Pct_Owners_65_Plus | Percentage of owner-occupied units with householder age 65+ | Calculated |
| Pct_Owners_75_Plus | Percentage of owner-occupied units with householder age 75+ | Calculated |
| Pct_Owners_85_Plus | Percentage of owner-occupied units with householder age 85+ | Calculated |

### Overcrowding (Occupants Per Room)

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Owner_0_5_Or_Less_Per_Room | Owner units with 0.50 or fewer occupants per room | B25014 |
| Owner_0_51_To_1_Per_Room | Owner units with 0.51 to 1.00 occupants per room | B25014 |
| Owner_1_01_To_1_5_Per_Room | Owner units with 1.01 to 1.50 occupants per room | B25014 |
| Owner_1_51_To_2_Per_Room | Owner units with 1.51 to 2.00 occupants per room | B25014 |
| Owner_2_Plus_Per_Room | Owner units with 2.01 or more occupants per room | B25014 |
| Renter_0_5_Or_Less_Per_Room | Renter units with 0.50 or fewer occupants per room | B25014 |
| Renter_0_51_To_1_Per_Room | Renter units with 0.51 to 1.00 occupants per room | B25014 |
| Renter_1_01_To_1_5_Per_Room | Renter units with 1.01 to 1.50 occupants per room | B25014 |
| Renter_1_51_To_2_Per_Room | Renter units with 1.51 to 2.00 occupants per room | B25014 |
| Renter_2_Plus_Per_Room | Renter units with 2.01 or more occupants per room | B25014 |
| Owner_Overcrowded | Owner units with more than 1.0 occupants per room | Calculated |
| Renter_Overcrowded | Renter units with more than 1.0 occupants per room | Calculated |
| Total_Overcrowded | All housing units with more than 1.0 occupants per room | Calculated |
| Pct_Owner_Overcrowded | Percentage of owner units that are overcrowded | Calculated |
| Pct_Renter_Overcrowded | Percentage of renter units that are overcrowded | Calculated |
| Pct_All_HH_Overcrowded | Percentage of all households that are overcrowded | Calculated |

### Housing Cost Burden - Owners

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Owner_Cost_Burden_30_34_9_Pct | Owner households spending 30.0-34.9% of income on housing | B25091 |
| Owner_Cost_Burden_35_39_9_Pct | Owner households spending 35.0-39.9% of income on housing | B25091 |
| Owner_Cost_Burden_40_49_9_Pct | Owner households spending 40.0-49.9% of income on housing | B25091 |
| Owner_Cost_Burden_50_Plus_Pct | Owner households spending 50% or more of income on housing | B25091 |
| Owner_Cost_Burden_30_Plus | Owner households spending 30% or more of income on housing | Calculated |
| Owner_Cost_Burden_50_Plus | Owner households spending 50% or more of income on housing | Calculated |
| Pct_Owners_Cost_Burdened_30_Plus | Percentage of owners spending 30%+ of income on housing | Calculated |
| Pct_Owners_Cost_Burdened_50_Plus | Percentage of owners spending 50%+ of income on housing | Calculated |

### Housing Cost Burden - Renters

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Renters_Cost_Burden_Universe | Total renter households for cost burden calculation | B25070 |
| Rent_Burden_30_34_9_Pct | Renter households spending 30.0-34.9% of income on rent | B25070 |
| Rent_Burden_35_39_9_Pct | Renter households spending 35.0-39.9% of income on rent | B25070 |
| Rent_Burden_40_49_9_Pct | Renter households spending 40.0-49.9% of income on rent | B25070 |
| Rent_Burden_50_Plus_Pct | Renter households spending 50% or more of income on rent | B25070 |
| Renter_Cost_Burden_30_Plus | Renter households spending 30% or more of income on rent | Calculated |
| Renter_Cost_Burden_50_Plus | Renter households spending 50% or more of income on rent | Calculated |
| Pct_Renters_Cost_Burdened_30_Plus | Percentage of renters spending 30%+ of income on rent | Calculated |
| Pct_Renters_Cost_Burdened_50_Plus | Percentage of renters spending 50%+ of income on rent | Calculated |

### Combined Cost Burden (All Households)

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Cost_Burdened_30_Plus | All households spending 30% or more of income on housing | Calculated |
| Total_Cost_Burdened_50_Plus | All households spending 50% or more of income on housing | Calculated |
| Pct_All_HH_Cost_Burdened_30_Plus | Percentage of all households spending 30%+ on housing | Calculated |
| Pct_All_HH_Cost_Burdened_50_Plus | Percentage of all households spending 50%+ on housing | Calculated |

---

## Disability

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Pop_Disability_Universe | Total civilian non-institutionalized population | B18101 |
| Male_With_Disability | Males with a disability (all ages) | B18101 |
| Male_No_Disability | Males without a disability (all ages) | B18101 |
| Female_With_Disability | Females with a disability (all ages) | B18101 |
| Female_No_Disability | Females without a disability (all ages) | B18101 |
| Total_With_Disability | Total population with a disability | Calculated |
| Total_No_Disability | Total population without a disability | Calculated |
| Pct_With_Disability | Percentage of population with a disability | Calculated |

---

## Educational Attainment

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Pop_25_Plus | Total population 25 years and over | B15003 |
| Less_Than_HS | Population 25+ with less than high school diploma | B15003 |
| HS_Grad_Or_Equivalent | Population 25+ with high school diploma or GED | B15003 |
| Some_College_Or_Associates | Population 25+ with some college or associate's degree | B15003 |
| Bachelors_Degree | Population 25+ with bachelor's degree | B15003 |
| Graduate_Or_Professional | Population 25+ with graduate or professional degree | B15003 |
| Total_Bachelors_Plus | Population 25+ with bachelor's degree or higher | Calculated |
| Pct_Less_Than_HS | Percentage of population 25+ with less than high school | Calculated |
| Pct_HS_Grad | Percentage of population 25+ with high school diploma | Calculated |
| Pct_Some_College | Percentage of population 25+ with some college/associate's | Calculated |
| Pct_Bachelors | Percentage of population 25+ with bachelor's degree | Calculated |
| Pct_Graduate | Percentage of population 25+ with graduate degree | Calculated |
| Pct_Bachelors_Plus | Percentage of population 25+ with bachelor's or higher | Calculated |

---

## Health Insurance Coverage

### Overall Coverage

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Pop_Insurance_Universe | Total civilian non-institutionalized population | B27001 |
| With_Health_Insurance | Population with any health insurance coverage | B27001 |
| No_Health_Insurance | Population without health insurance coverage | B27001 |
| Pct_With_Health_Insurance | Percentage of population with health insurance | Calculated |
| Pct_No_Health_Insurance | Percentage of population without health insurance | Calculated |

### Children's Insurance Coverage

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Children_Under_18 | Total children under 18 years | Calculated |
| Children_With_Insurance | Children under 18 with health insurance | B27001 |
| Children_No_Insurance | Children under 18 without health insurance | B27001 |
| Pct_Children_With_Insurance | Percentage of children with health insurance | Calculated |
| Pct_Children_No_Insurance | Percentage of children without health insurance | Calculated |

### Insurance by Type

**Note:** People can have multiple types of insurance coverage simultaneously. Percentages are calculated as percent of total population, not percent of insured population.

| Variable | Description | Source Table |
|----------|-------------|--------------|
| With_Private_Insurance | Population with private health insurance | B27002 |
| With_Public_Coverage | Population with public health coverage | B27003 |
| With_Employer_Insurance | Population with employer-based health insurance | C27004 |
| With_DirectPurchase_Insurance | Population with direct-purchase health insurance (including ACA Marketplace) | C27005 |
| With_Medicare | Population with Medicare coverage | C27006 |
| With_Medicaid | Population with Medicaid or means-tested public coverage | C27007 |
| With_TRICARE | Population with TRICARE/military health coverage | C27008 |
| With_VA_HealthCare | Population with VA health care | C27009 |
| Pct_With_Private_Insurance | Percentage with private insurance | Calculated |
| Pct_With_Public_Coverage | Percentage with public coverage | Calculated |
| Pct_With_Employer_Insurance | Percentage with employer insurance | Calculated |
| Pct_With_DirectPurchase_Insurance | Percentage with direct-purchase insurance | Calculated |
| Pct_With_Medicare | Percentage with Medicare | Calculated |
| Pct_With_Medicaid | Percentage with Medicaid | Calculated |
| Pct_With_TRICARE | Percentage with TRICARE | Calculated |
| Pct_With_VA_HealthCare | Percentage with VA health care | Calculated |

### Employment Status and Health Insurance

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Employed_Total | Total employed population 16+ | B27011 |
| Employed_With_Health_Insurance | Employed population with health insurance | B27011 |
| Pct_Employed_With_Insurance | Percentage of employed with health insurance | Calculated |
| Unemployed_With_Health_Insurance | Unemployed population with health insurance | B27011 |
| Unemployed_With_Private_Insurance | Unemployed population with private insurance | B27011 |

---

## Digital Access

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Households_Internet_Universe | Total households | B28002 |
| HH_With_Internet | Households with internet subscription | B28002 |
| HH_No_Internet | Households without internet subscription | B28002 |
| HH_Broadband | Households with broadband internet subscription | B28002 |
| Total_Pop_Computer_Universe | Total population in households | B28003 |
| Has_Computer_And_Internet | Population with computer and internet subscription | B28003 |
| No_Computer | Population without a computer | B28003 |
| Pct_HH_With_Internet | Percentage of households with internet | Calculated |
| Pct_HH_With_Broadband | Percentage of households with broadband | Calculated |
| Pct_HH_No_Computer | Percentage of population without computer | Calculated |

---

## Transportation

### Commute Times

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Workers_Commute_Universe | Total workers 16 years and over | B08303 |
| Commute_Under_5_Min | Workers with commute time less than 5 minutes | B08303 |
| Commute_5_9_Min | Workers with commute time 5 to 9 minutes | B08303 |
| Commute_10_14_Min | Workers with commute time 10 to 14 minutes | B08303 |
| Commute_15_19_Min | Workers with commute time 15 to 19 minutes | B08303 |
| Commute_20_24_Min | Workers with commute time 20 to 24 minutes | B08303 |
| Commute_25_29_Min | Workers with commute time 25 to 29 minutes | B08303 |
| Commute_30_34_Min | Workers with commute time 30 to 34 minutes | B08303 |
| Commute_35_44_Min | Workers with commute time 35 to 44 minutes | B08303 |
| Commute_45_59_Min | Workers with commute time 45 to 59 minutes | B08303 |
| Commute_60_89_Min | Workers with commute time 60 to 89 minutes | B08303 |
| Commute_90_Plus_Min | Workers with commute time 90 or more minutes | B08303 |
| Work_At_Home | Workers who work at home | B08303 |
| Commute_Under_30_Min | Workers with commute time under 30 minutes | Calculated |
| Commute_30_59_Min | Workers with commute time 30 to 59 minutes | Calculated |
| Commute_60_Plus_Min | Workers with commute time 60+ minutes | Calculated |
| Pct_Commute_Under_30 | Percentage with commute under 30 minutes | Calculated |
| Pct_Commute_30_59 | Percentage with commute 30-59 minutes | Calculated |
| Pct_Commute_60_Plus | Percentage with commute 60+ minutes | Calculated |
| Pct_Work_At_Home | Percentage who work at home | Calculated |

### Vehicle Availability

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Owner_No_Vehicle | Owner-occupied units with no vehicle available | B25044 |
| Owner_1_Vehicle | Owner-occupied units with 1 vehicle available | B25044 |
| Owner_2_Vehicles | Owner-occupied units with 2 vehicles available | B25044 |
| Owner_3_Plus_Vehicles | Owner-occupied units with 3+ vehicles available | B25044 |
| Renter_No_Vehicle | Renter-occupied units with no vehicle available | B25044 |
| Renter_1_Vehicle | Renter-occupied units with 1 vehicle available | B25044 |
| Renter_2_Vehicles | Renter-occupied units with 2 vehicles available | B25044 |
| Renter_3_Plus_Vehicles | Renter-occupied units with 3+ vehicles available | B25044 |
| Total_No_Vehicle | Total households with no vehicle available | Calculated |
| Total_With_Vehicle | Total households with vehicle(s) available | Calculated |
| Pct_HH_No_Vehicle | Percentage of households with no vehicle | Calculated |
| Pct_Owner_No_Vehicle | Percentage of owner households with no vehicle | Calculated |
| Pct_Renter_No_Vehicle | Percentage of renter households with no vehicle | Calculated |

---

## Housing Mobility & Stability

### Year Householder Moved In

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Moved_In_2020_Later | Householders who moved in 2020 or later | B25026 |
| Moved_In_2010_2019 | Householders who moved in 2010-2019 | B25026 |
| Moved_In_2000_2009 | Householders who moved in 2000-2009 | B25026 |
| Moved_In_1990_1999 | Householders who moved in 1990-1999 | B25026 |
| Moved_In_Before_1990 | Householders who moved in before 1990 | B25026 |
| Total_Moved_Since_2020 | Householders who moved in since 2020 | Calculated |
| Total_Moved_Since_2010 | Householders who moved in since 2010 | Calculated |
| Pct_Moved_Since_2020 | Percentage of householders who moved in since 2020 | Calculated |
| Pct_Moved_Since_2010 | Percentage of householders who moved in since 2010 | Calculated |

### Geographic Mobility (Past Year)

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Pop_Mobility_Universe | Total population 1 year and over | B07003 |
| Same_House_1_Year_Ago | Population in same house 1 year ago | B07003 |
| Moved_Within_County | Population that moved within same county | B07003 |
| Moved_From_Different_County | Population that moved from different county | B07003 |
| Moved_From_Different_State | Population that moved from different state | B07003 |
| Moved_From_Abroad | Population that moved from abroad | B07003 |
| Pct_Same_House_1_Year | Percentage in same house 1 year ago | Calculated |
| Pct_Moved_Within_County | Percentage that moved within county | Calculated |

---

## Economic Hardship

### SNAP/Food Stamps

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_HH_SNAP_Universe | Total households for SNAP calculation | B22001 |
| HH_Received_SNAP | Households that received SNAP/food stamps in past 12 months | B22001 |
| HH_No_SNAP | Households that did not receive SNAP/food stamps | B22001 |
| Pct_HH_SNAP | Percentage of households receiving SNAP | Calculated |
| Pct_HH_No_SNAP | Percentage of households not receiving SNAP | Calculated |

### SNAP - Families with Children

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_HH_SNAP_Children_Universe | Total households for children SNAP calculation | B22002 |
| Total_HH_With_Children | Total households with children under 18 | Calculated |
| HH_SNAP_With_Children | Households with children receiving SNAP | B22002 |
| HH_No_SNAP_With_Children | Households with children not receiving SNAP | B22002 |
| Pct_HH_With_Children_On_SNAP | Percentage of households with children receiving SNAP | Calculated |

### SNAP by Poverty Status

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_HH_SNAP_Poverty_Universe | Total households for poverty SNAP calculation | B22003 |
| HH_SNAP_Below_Poverty | Households receiving SNAP below poverty level | B22003 |
| HH_SNAP_At_Above_Poverty | Households receiving SNAP at/above poverty level | B22003 |
| HH_No_SNAP_Below_Poverty | Households not receiving SNAP below poverty level | B22003 |
| HH_No_SNAP_At_Above_Poverty | Households not receiving SNAP at/above poverty level | B22003 |
| Pct_HH_SNAP_Below_Poverty | Percentage of poor households receiving SNAP | Calculated |
| Pct_HH_SNAP_At_Above_Poverty | Percentage of non-poor households receiving SNAP | Calculated |

### Social Security, SSI, and Public Assistance

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_HH_SSI_Universe | Total households for Social Security calculation | B19055 |
| HH_With_Social_Security | Households with Social Security income | B19055 |
| HH_No_Social_Security | Households without Social Security income | B19055 |
| Pct_HH_With_Social_Security | Percentage with Social Security income | Calculated |
| Total_HH_SupplementalSSI_Universe | Total households for SSI calculation | B19056 |
| HH_With_SSI | Households with Supplemental Security Income (SSI) | B19056 |
| HH_No_SSI | Households without SSI | B19056 |
| Pct_HH_With_SSI | Percentage with SSI | Calculated |
| Total_HH_PublicAssist_Universe | Total households for public assistance calculation | B19057 |
| HH_With_Public_Assistance | Households with public assistance income | B19057 |
| HH_No_Public_Assistance | Households without public assistance income | B19057 |
| Pct_HH_Public_Assistance | Percentage with public assistance | Calculated |
| Total_HH_PublicAssist_Or_SNAP_Universe | Total households for combined calculation | B19058 |
| HH_With_PublicAssist_Or_SNAP | Households with public assistance or SNAP | B19058 |
| HH_No_PublicAssist_Or_SNAP | Households without public assistance or SNAP | B19058 |
| Pct_HH_PublicAssist_Or_SNAP | Percentage with public assistance or SNAP | Calculated |

---

## Multigenerational Households

| Variable | Description | Source Table |
|----------|-------------|--------------|
| Total_Households_Multigen_Universe | Total households | B11017 |
| Multigenerational_Households | Multigenerational households (3+ generations) | B11017 |
| Not_Multigenerational | Non-multigenerational households | B11017 |
| Pct_Multigenerational | Percentage of multigenerational households | Calculated |

---

## Spatial Metrics

**Note:** These variables are only available when geometry data is successfully retrieved.

| Variable | Description | Calculation |
|----------|-------------|-------------|
| tract_area_sqft | Tract area in square feet | st_area() in projected CRS |
| tract_area_sqmi | Tract area in square miles | tract_area_sqft / 27,878,400 |
| tract_area_acres | Tract area in acres | tract_area_sqft / 43,560 |
| housing_units_per_sqmi | Housing units per square mile | Total_Housing_Units / tract_area_sqmi |
| housing_units_per_acre | Housing units per acre | Total_Housing_Units / tract_area_acres |
| population_per_sqmi | Population per square mile | Total_Population / tract_area_sqmi |
| population_per_acre | Population per acre | Total_Population / tract_area_acres |
| veterans_per_sqmi | Veterans per square mile | Vet_Total_Veterans / tract_area_sqmi |
| veterans_per_1000_pop | Veterans per 1,000 population | (Vet_Total_Veterans / Total_Population) * 1000 |
| gross_housing_density_per_sqmi | Gross housing density (all units) per square mile | housing_units_per_sqmi |
| net_housing_density_per_sqmi | Net housing density (occupied units only) per square mile | Occupied_Units / tract_area_sqmi |

---

## Data Quality Notes

### Missing Data
- Missing values in the ACS data are represented as `NA`
- Zero counts may indicate either no population in that category or data suppression for privacy
- Percentages calculated from zero denominators result in `NA`

### Margins of Error
- The script pulls ACS estimates but does not include margins of error in the final output
- For statistical testing, margins of error should be considered
- Original margins of error are available in the source ACS tables

### Important Considerations

#### Health Insurance
- People can have multiple types of insurance coverage simultaneously
- The sum of different insurance types will exceed the total insured population
- Percentages are calculated as percentage of total population, not percentage of insured

#### Veterans Period of Service
- Veterans can serve during multiple time periods
- The sum of period-specific counts may exceed total veteran count
- This is expected and reflects veterans who served during multiple conflicts/eras

#### Cost Burden Calculations
- Owner cost burden includes mortgage payment, utilities, insurance, taxes, and fees
- Renter gross rent includes contract rent plus utilities
- Households spending 30%+ of income on housing are considered "cost burdened"
- Households spending 50%+ are considered "severely cost burdened"

#### Geographic Boundaries
- Census tract boundaries may change between decennial censuses
- 2023 ACS data uses 2020 Census tract definitions
- Some tracts may have small populations, leading to unreliable estimates

---

## Citation

When using this data, please cite:

U.S. Census Bureau, American Community Survey 5-Year Estimates, 2019-2023. Retrieved from https://www.census.gov/programs-surveys/acs

---

## Questions or Issues

For questions about:
- **Variable definitions:** Refer to ACS technical documentation at https://www.census.gov/programs-surveys/acs/technical-documentation.html
- **Data quality:** Review ACS data quality measures at https://www.census.gov/programs-surveys/acs/technical-documentation/data-quality.html
- **Script functionality:** Contact the data team at RLD Foundation

---

**Last Updated:** January 2026  
**Script Version:** Cook County Housing & Veterans ACS Data Pull v1.0
